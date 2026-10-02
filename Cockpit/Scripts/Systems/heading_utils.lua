-- Heading helpers for keeping cockpit heading displays in the same magnetic
-- reference frame.
--
-- DCS exposes both a terrain-grid/world heading and a magnetic heading. On maps
-- where the local terrain grid is rotated away from geographic north, such as
-- Kola, a grid heading can be tens of degrees away from the cockpit magnetic
-- heading. Do not add a separate geo-derived grid-convergence correction to
-- getMagneticHeading(); that value is already the cockpit magnetic reference.
-- Instead, use it directly for magnetic instruments and only use the grid delta
-- when converting headings that were explicitly calculated in the local grid.

local HeadingUtils = {}

local RAD_TO_DEGREE = 57.29577951308233

local function normalize_degrees(degrees)
    degrees = degrees % 360
    if degrees < 0 then
        degrees = degrees + 360
    end
    return degrees
end

local function shortest_angle_delta(from_degrees, to_degrees)
    return ((to_degrees - from_degrees + 540) % 360) - 180
end

local function get_grid_heading_degrees(sensor_data)
    if sensor_data == nil or type(sensor_data.getHeading) ~= "function" then
        return nil
    end

    local heading = sensor_data.getHeading()
    if type(heading) ~= "number" then
        return nil
    end

    -- getHeading() uses the DCS world/grid convention. Convert it to the same
    -- clockwise compass-bearing convention as getMagneticHeading() before taking
    -- deltas between the two reference frames.
    return normalize_degrees(360 - (heading * RAD_TO_DEGREE))
end

function HeadingUtils.normalize_degrees(degrees)
    return normalize_degrees(degrees)
end

function HeadingUtils.get_magnetic_heading(sensor_data)
    if sensor_data == nil or type(sensor_data.getMagneticHeading) ~= "function" then
        return 0
    end

    local heading = sensor_data.getMagneticHeading()
    if type(heading) ~= "number" then
        return 0
    end

    return normalize_degrees(heading * RAD_TO_DEGREE)
end

function HeadingUtils.get_grid_to_magnetic_correction(sensor_data)
    local grid_heading = get_grid_heading_degrees(sensor_data)
    if grid_heading == nil then
        return 0
    end

    return shortest_angle_delta(grid_heading, HeadingUtils.get_magnetic_heading(sensor_data))
end

function HeadingUtils.grid_to_magnetic(sensor_data, grid_heading_degrees)
    return normalize_degrees(grid_heading_degrees + HeadingUtils.get_grid_to_magnetic_correction(sensor_data))
end

-- Backwards-compatible name used by cockpit scripts. This intentionally returns
-- DCS's magnetic heading directly; getMagneticHeading() is not a grid heading and
-- must not receive an additional terrain-grid convergence correction.
function HeadingUtils.get_corrected_magnetic_heading(sensor_data)
    return HeadingUtils.get_magnetic_heading(sensor_data)
end

return HeadingUtils
