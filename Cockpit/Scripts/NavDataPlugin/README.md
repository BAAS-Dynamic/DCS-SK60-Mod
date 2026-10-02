# DCSOpenSource Navigation Information Plugin
By Hayds_93, built for the T-38C
A small drop in "API" to dynamically pull data from DCS for airport/navigation information.

---
This should work on every map. An exception is Normandy, as since its a map from the 1940s it doesnt have ICAO codes, however every other parameter should work.
It is untested on:
* Afghanistan
* South Atlantic
---
## Can I use this?
* Yes you can, but only for public mods, private mods, airshow mods etc are NOT allowed
* Please Leave the comments at the top of the file untouched
* Feel free to create pull requests to add features, but try not to make breaking changes to the existing tables
* I will continue to update this as time goes on
---
## Data included
Below is an example of one entry in the resulting table.

```lua
{
    "Nellis" = {
        name = "Nellis",
        position = { -- this is the coordinates of the icon on the F10 Map
            lon = -115.03300055101,
            lat = 36.235224110884,
            x = -398195.375,
            y = -17233.236816
        },
        runways = {
            1 = {
                runwayEnd1 = { -- this lets you draw runways on mfds
                    lon = -115.0461359287,
                    lat = 36.22726794535,
                    x = -399101.375,
                    y = -18395.236816
                },
                runwayEnd2 = { -- second point runway 1
                    lon = -115.024979770072,
                    lat = 36.246778519235,
                    x = -396898.375,
                    y = -396898.236816
                },
                runwayLength = 9455.97,
                name = 03L-21R
            },
            2 = {
                runwayEnd1 = { -- first point of runway 2
                    lon = -115.0461359287,
                    lat = 36.22726794535,
                    x = -399101.375,
                    y = -18395.236816
                },
                runwayEnd2 = { -- second point of runway 2
                    lon = -115.024979770072,
                    lat = 36.246778519235,
                    x = -396898.375,
                    y = -396898.236816
                },
                runwayLength = 9439.81,
                name = 03R-21L
            } 
        },
        radioid = { -- this is used in the backend to link radio data to airfield
            1 = airfield4_0
        },
        beacons = {
            -- Beacon data exists, but is WIP
            -- this will only have airfield beacons
            -- map beacons will be handled seperatly
        },
        radios = {
            radioId = "airfield4_0",
            uniform = 327,
            victor = 132.55
        },
        isCivilian = false,
        ICAO = KLSV
    }
}
```
---
## Install Guide

### .git submodule
1. Navigate to `Cockpit/Scripts/Systems` in your terminal
2. Run `git submodule add https://github.com/DCS-OpenSource/NavDataPlugin.git`
3. commit the submodule file to your repo

### Manual Install
1. Download the latest release (the .zip, not source code)
2. unzip, and place the folder in `Cockpit/Scripts/Systems`
3. verify the relative path to `Nav.lua` is `Cockpit/Scripts/Systems/NavDataPlugin/Nav.lua`


## Usage
1. Add `dofile(LockOn_Options.script_path.."Systems/NavDataPlugin/Nav.lua")` at the top of any file you want to access airport data
2. Get the data `local airportData = getAirports()` which returns the lua table above.
---
## Data Supplementation 
The Data DCS provides is often less than perfect, especially around radios on certain maps. Nellis (NTTR) and Caucasus work as expected, but ED seemingly updated the TDK after those maps, so data such as radios is hidden/inaccessable sometimes.

To circumvent this, I added a way to add additional data to edit the dynamically aquired information.

### How to setup data supplementation
* Make a new folder in your `Cockpit/Scripts/Systems/` folder called `NavDataPluginExtra`
* Make sub folders for each map, the name should match the theatre name.
    * You can get the theatre name using:
        ```lua
        do_mission_file("mission") -- Load the mission file
        local theatre = mission.theatre -- map name string
        ```
    * For NTTR this would look like `Cockpit/Scripts/Systems/Nevada/`
* Make a file in the new folder called `theatreName.lua` (in this example `Nevada.lua`)
* Paste the following into the file:
    ```lua
    -- This Lua file contains an array of data to supplement the existing data pulled from DCS
    local Airports = {
        ["Nellis"] = { -- This needs to match the airport name on the F10 Map
            name = "Nellis Air Force Base",
            ICAO = "KLSV",
        }, 
    }
    return Airports -- Don't forget to include this at the bottom
    ```
* You can edit every value, providing you match the format
    * Radio supplement example:
    ```lua
    ["Groom Lake"] = { -- Area 51
        name = "Homey Airport",
        radios = {
            uniform = 250.05,
            victor = 118.00,
        }
    }
    ```
* The data is automatically supplemented, if the file exists, so no extra function calls needed
* getting ICAO data for SIDs/STARs is on the wishlist, while technically implemented, I won't be providing details right now


---
# Additional Features
## `Nav.lua`
### Airport List Sorting
I put these functions in the `update()` of my lua device to update the list as I move around.
I also run this once a second, I haven't tested it running at standard lua device update speeds
* `sortAirportsByDistance({lat, lon})`  -> Sort Airports by Distance using Latitude and Longtitude.
* `sortAirportsByDistanceMetric({x, y})`-> Sort Airports by Distance using x and y (Metric).

Both Metric (x/y) and Lat/Lon values are stored in the AirportList, so you can use either, depending on your input method.

## `Nav_Utils.lua` 
(You will need to have `dofile(LockOn_Options.script_path.."Systems/NavDataPlugin/Nav_Utils.lua")` to use these)
* `printTableContents(table)` A function to recursively print data from any table
    * This is a handy function to quickly see the contents of some unknown data you arent aware of.
    * This was extremely helpful for debugging the output of the `Terrain` module, and hopefully you find it useful too.
    * Try not to run it in `update()` or your PC will melt, DCS doesnt like 1000s of `print_message_to_user()` messages
    * *note: while this works, using JNelsons ImGui is a much better way to do this, found [here](https://github.com/08jne01/dcs-lua-imgui/tree/main)*
* `getBearing(lat1, lon1, lat2, lon2)` a function to calculate the bearing from the player to an airport (or any point)
    * lat1, lon1 being ownPos

* `haversine(lat1, lon1, lat2, lon2)` Haversine formula to calculate the distance between two points on the Earth
---
## Wishlist
* Beacons, TACAN, VOR etc...
* Map Support testing and tuning, different maps handle data differently, but I think I got it all
* More a T-38 thing, but a way to list Beacons at an airport (this is relevant for my personal avionics)


