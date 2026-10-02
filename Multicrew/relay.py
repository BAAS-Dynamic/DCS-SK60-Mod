"""Two-seat SK60 relay. Python 3.10+, standard library only; data is never executed.

Run on a private LAN/VPN. The shared token authenticates the pair, not an aircraft
owner on the DCS server. TCP is not encrypted; don't expose this on the Internet.
"""
import argparse
import asyncio
import hmac
from pathlib import Path
import re
import secrets
import math
from network_limits import TrafficBudget

MAX_BYTES = 262144
MAX_LINE = 2 * MAX_BYTES + 256

def avionics_command(payload):
    """Coarse transport boundary; cockpit also checks exact per-device commands."""
    if not payload.startswith(b'C:'): return False
    rows=payload[2:].split(b',')
    if not 1 <= len(rows) <= 64: return False
    try:
        for row in rows:
            device,command,value=row.decode('ascii').split(':')
            device,command,value=int(device),int(command),float(value)
            if not math.isfinite(value) or abs(value)>1: return False
            if device in (22,23,25,26): continue
            if device==1 and command in (5500,5515,5516): continue
            if device==9 and command==5202: continue
            return False
    except (ValueError,UnicodeError): return False
    return True

def unhex(value, limit=MAX_BYTES):
    if len(value) > limit * 2 or len(value) % 2 or re.fullmatch('[0-9a-f]*', value) is None:
        raise ValueError('invalid hex')
    return bytes.fromhex(value)

class Peer:
    def __init__(self, writer, role, session, schema):
        self.writer, self.role, self.session, self.schema = writer, role, session, schema
        self.generation, self.sequence = None, 0

    async def send(self, line):
        self.writer.write(line.encode('ascii') + b'\n')
        await asyncio.wait_for(self.writer.drain(), 2)

class Relay:
    def __init__(self, token='', authorize=None, one_way=False, avionics_only=False):
        self.token = token.encode('utf-8')
        self.rooms = {}
        self.authorize = authorize
        self.one_way = one_way
        self.avionics_only = avionics_only

    def authenticated(self, room, token, role, unit):
        if self.authorize:
            return self.authorize(room, token, role, unit)
        return hmac.compare_digest(token, self.token)

    async def handle(self, reader, writer, first_line=None):
        peer, key = None, None
        try:
            raw = first_line if first_line is not None else await asyncio.wait_for(reader.readline(), 5)
            parts = raw.decode('ascii').rstrip('\n').split('|')
            if len(parts) != 7 or parts[0] != 'H':
                raise ValueError('handshake required')
            _, room, token, role, unit, session, schema = parts
            room_bytes, token_bytes, unit_bytes = unhex(room, 80), unhex(token, 256), unhex(unit, 80)
            if not self.authenticated(room_bytes, token_bytes, role, unit_bytes):
                raise ValueError('authentication failed')
            if role not in ('0', '1') or not re.fullmatch(r'[\w-]{1,80}', session) or not re.fullmatch('[0-9a-f]{24}', schema):
                raise ValueError('invalid identity')
            key = (room_bytes, unit_bytes)
            if not all(key):
                raise ValueError('empty identity')
            occupants = self.rooms.setdefault(key, {})
            if role in occupants:
                raise ValueError('seat already occupied')
            other = occupants.get('1' if role == '0' else '0')
            if other and other.schema != schema:
                raise ValueError('cockpit versions differ')
            peer = Peer(writer, role, session, schema)
            budget = TrafficBudget()
            occupants[role] = peer
            if other:
                generation = secrets.token_hex(12)
                peer.generation = other.generation = generation
                peer.sequence = other.sequence = 0
                await other.send('R|' + generation)
                await peer.send('R|' + generation)
            else:
                await peer.send('W')
            while True:
                raw = await asyncio.wait_for(reader.readline(), 15)
                if not raw:
                    break
                budget.consume(len(raw))
                if not self.authenticated(room_bytes, token_bytes, role, unit_bytes):
                    raise ValueError('session expired or revoked')
                if len(raw) > MAX_LINE or not raw.endswith(b'\n'):
                    raise ValueError('oversized frame')
                if raw == b'K\n':
                    await peer.send('K')
                    continue
                fields = raw.decode('ascii').rstrip('\n').split('|')
                if len(fields) != 4 or fields[0] != 'D':
                    raise ValueError('invalid frame')
                _, generation, sequence, encoded = fields
                if not sequence.isdigit() or len(sequence) > 16:
                    raise ValueError('invalid sequence')
                sequence = int(sequence)
                payload = unhex(encoded)
                acknowledgement = role == '1' and re.fullmatch(rb'A:[1-9][0-9]{0,15}',payload) is not None
                if self.avionics_only and role == '1' and payload != b'P' and not acknowledgement and not avionics_command(payload):
                    raise ValueError('unsupported co-pilot command')
                if self.one_way and role == '1' and payload != b'P' and not acknowledgement:
                    raise ValueError('co-pilot is read only')
                if generation != peer.generation or sequence <= peer.sequence:
                    continue  # stale generation / duplicate: no side effects
                if not (payload == b'P' or acknowledgement or payload.startswith(b'S:' if role == '0' else b'C:')):
                    raise ValueError('wrong direction')
                peer.sequence = sequence
                other = occupants.get('1' if role == '0' else '0')
                if other and other.generation == generation:
                    await other.send(raw.decode('ascii').rstrip('\n'))
        except (ValueError, UnicodeError, asyncio.TimeoutError, ConnectionError, OSError) as exc:
            # No tokens or packet contents in logs/errors.
            try:
                writer.write(b'E|connection_rejected\n')
                await asyncio.wait_for(writer.drain(), 1)
            except (ConnectionError, OSError, asyncio.TimeoutError):
                pass
        finally:
            if peer and key in self.rooms and self.rooms[key].get(peer.role) is peer:
                occupants = self.rooms[key]
                del occupants[peer.role]
                for other in occupants.values():
                    other.generation = None
                    try:
                        await other.send('W')
                    except (ConnectionError, OSError, asyncio.TimeoutError):
                        pass
                if not occupants:
                    del self.rooms[key]
            writer.close()
            try:
                await writer.wait_closed()
            except (ConnectionError, OSError):
                pass

async def run(args):
    token = Path(args.token_file).read_text(encoding='utf-8').strip()
    if len(token) < 24 or 'REPLACE' in token:
        raise SystemExit('Token file must contain a random shared secret of at least 24 characters.')
    relay = Relay(token)
    server = await asyncio.start_server(relay.handle, args.bind, args.port, limit=MAX_LINE)
    print(f'SK60 relay listening on {args.bind}:{args.port}; Ctrl+C to stop.', flush=True)
    async with server:
        await server.serve_forever()

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--bind', default='127.0.0.1')
    parser.add_argument('--port', type=int, default=10660)
    parser.add_argument('--token-file', required=True)
    args = parser.parse_args()
    try:
        asyncio.run(run(args))
    except KeyboardInterrupt:
        pass
