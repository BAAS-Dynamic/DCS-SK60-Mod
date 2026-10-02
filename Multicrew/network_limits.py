"""Per-connection work budgets, in addition to existing frame/connection limits."""
import time

class TrafficBudget:
    def __init__(self, clock=time.monotonic):
        self.clock = clock
        self.last = clock()
        self.frames = 240.0
        self.bytes = float(8 * 1024 * 1024)

    def consume(self, size):
        now = self.clock()
        elapsed = max(0, now-self.last)
        self.last = now
        self.frames = min(240.0, self.frames + elapsed*120)
        self.bytes = min(8*1024*1024, self.bytes + elapsed*4*1024*1024)
        if size < 0 or self.frames < 1 or self.bytes < size:
            raise ValueError('connection traffic limit exceeded')
        self.frames -= 1
        self.bytes -= size
