-- Copy to Saved Games/<DCS profile>/Config/SK60Multicrew.lua on BOTH PCs.
-- Install the same modified SK60 on both PCs. Start the relay before flying.
return {
    enabled = true,
    host = "127.0.0.1", -- relay IP, preferably on a private VPN
    port = 10660,
    room = "sk60-training",
    token = "REPLACE_WITH_A_RANDOM_SHARED_SECRET", -- same as relay's token file
    -- Absolute directory containing protocol.lua and schema.lua:
    mod_path = [[C:/Users/YOUR_NAME/Saved Games/DCS/Mods/aircraft/SK60]],
}
