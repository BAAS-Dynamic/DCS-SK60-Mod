dofile(LockOn_Options.script_path.."debug_util.lua")

range_scale 		  	= 60000.0
TDC_range_carret_size 	= 5000
render_debug_info 		= false--true


perfomance =
{
-- simplified calculation; cannot rotate
	roll_compensation_limits	= {0, 0},
	pitch_compensation_limits	= {0, 0},

	tracking_azimuth   			= { -math.rad(90),math.rad(90)}, -- available to use, set to 90 for better performance
	-- tracking_elevation 			= { -math.rad(80),math.rad(80)}, -- not available: only +- 30 deg limite

-- with the current settings, the scan interval is 5 deg and the scan period is 41/50 s.
	scan_volume_azimuth 	= math.rad(120), --scan range
	scan_volume_elevation	= math.rad(120),
	scan_beam				= math.rad(120), --vertical scan-sector area
-- scan_speed				= math.rad(10*80), -- unused parameter

	max_available_distance  = 20 * 60000.0,--200*60000.0,
	dead_zone 				= 200.0,

	ground_clutter =
	{-- spot RCS = A + B * random + C * random
		sea		   	   = {0 ,0,0},
		land 	   	   = {0 ,0,0},
		artificial 	   = {0 ,0,0},
		rays_density   = 0.01,
		max_distance   = 60000,
	}

}


------------------------------------------------------------------------------

RadarSystem 	    	= GetSelf()
DEBUG_ACTIVE 	= false
Sensor_Data_Raw = get_base_data()


update_time_step 	= 0.02 --50 times per second
RadarSystemice_timer_dt		= 0.02

make_default_activity(update_time_step)



Radar = 	{
				mode_h 		= get_param_handle("RADAR_MODE"), -- 1:searching, 2:trying to lock, 3:STT lock
				szoe_h 		= get_param_handle("SCAN_ZONE_ORIGIN_ELEVATION"),
				szoa_h 		= get_param_handle("SCAN_ZONE_ORIGIN_AZIMUTH"),

				opt_pb_stab_h 	= get_param_handle("RADAR_PITCH_BANK_STABILIZATION"),
				opt_bank_stab_h = get_param_handle("RADAR_BANK_STABILIZATION"),
				opt_pitch_stab_h= get_param_handle("RADAR_PITCH_STABILIZATION"),


				tdc_azi_h 		= get_param_handle("RADAR_TDC_AZIMUTH"),
				tdc_range_h 	= get_param_handle("RADAR_TDC_RANGE"),
				tdc_closet_h	= get_param_handle("CLOSEST_RANGE_RESPONSE"),

				tdc_rcsize_h	= get_param_handle("RADAR_TDC_RANGE_CARRET_SIZE"),
				tdc_acqzone_h   = get_param_handle("ACQUSITION_ZONE_VOLUME_AZIMUTH"),



				stt_azimuth_h 	= get_param_handle("RADAR_STT_AZIMUTH"),
				stt_elevation_h = get_param_handle("RADAR_STT_ELEVATION"),

				sz_azimuth_h 	= get_param_handle("SCAN_ZONE_ORIGIN_AZIMUTH"),
				sz_elevation_h 	= get_param_handle("SCAN_ZONE_ORIGIN_ELEVATION"),

				tdc_ele_up_h 	= get_param_handle("RADAR_TDC_ELEVATION_AT_RANGE_UPPER"),
				tdc_ele_down_h 	= get_param_handle("RADAR_TDC_ELEVATION_AT_RANGE_LOWER"),

				ws_ir_slave_azimuth_h	= get_param_handle("WS_IR_MISSILE_SEEKER_DESIRED_AZIMUTH"),
				ws_ir_slave_elevation_h	= get_param_handle("WS_IR_MISSILE_SEEKER_DESIRED_ELEVATION"),

				iff_status_h			= get_param_handle("IFF_INTERROGATOR_STATUS"),
				bit_h 					= get_param_handle("RADAR_BIT"),

				antenna_pos 	= get_param_handle("SCAN_BEAM_AZIMUTH"), --set the scan-sector display
			}

function post_initialize()

	dprintf("Radar - INIT")

		RadarSystem:listen_command(100)

		RadarSystem:listen_command(139)		--scanzone left
		RadarSystem:listen_command(140)		--scanzone right

		RadarSystem:listen_command(141)		--scanzone up
		RadarSystem:listen_command(142)		--scanzone down

		RadarSystem:listen_command(394)		--change PRF (radar puls freqency)

		RadarSystem:listen_command(509)		--lock start
		RadarSystem:listen_command(510)		--lock finish

		RadarSystem:listen_command(285)		--Change radar mode RWS/TWS

		RadarSystem:listen_command(2025)
		RadarSystem:listen_command(2026)
		RadarSystem:listen_command(2031)
		RadarSystem:listen_command(2032)


		Radar.opt_pb_stab_h:set(1)
		Radar.opt_pitch_stab_h:set(1)
		Radar.opt_bank_stab_h:set(1)


end

function SetCommand(command,value)
	--dprintf(string.format("Radar SetCom: C %i   V%.8f",command,value))

---------------------------------------------------------------------

	if command == 141 and value == 0.0 then
		Radar.sz_elevation_h:set(Radar.sz_elevation_h:get() + 0.003)
	elseif command == 142 and value == 0.0 then
		Radar.sz_elevation_h:set(Radar.sz_elevation_h:get() - 0.003)
	end

	if command == 139 and value == 0.0 then
		Radar.sz_azimuth_h:set(Radar.sz_azimuth_h:get() + 0.003)
	elseif command == 140 and value == 0.0 then
		Radar.sz_azimuth_h:set(Radar.sz_azimuth_h:get() - 0.003)
	end

----------------------------------------------------------------------

	if Radar.tdc_range_h:get() > 20000 then
		Radar.tdc_range_h:set(20000) -- target indicator range
	elseif Radar.tdc_range_h:get() < 0 then
		Radar.tdc_range_h:set(0)
	end

	if Radar.tdc_azi_h:get() > 0.5 then
		Radar.tdc_azi_h:set(0.5) -- target indicator direction
	elseif Radar.tdc_azi_h:get() < -0.5 then
		Radar.tdc_azi_h:set(-0.5)
	end

-------------------------------------------------

	if command == 2032  then
			Radar.tdc_range_h:set(Radar.tdc_range_h:get()- value*200000)

	end

	if command == 2031  then
			Radar.tdc_azi_h:set(Radar.tdc_azi_h:get()+ value*10)

	end

-------------------------------------------------




end

-- radar calibration data
local radar_scan_pos_align = 0
local radar_scan_align_target = 0
-- ownship state array
local self_status_array = {}
-- radar scan-result array
local radar_result_temp_array = {}
-- radar track array
local radar_target_tracing_array = {}
-- radar scan stabilization-mode state
local radar_stable_status = 1

-- set radar stabilization state
function setRadarStable(stab_signal)
	if stab_signal == true then
-- stabilization enabled for long-range scan tracking
		Radar.opt_pb_stab_h:set(1)
		Radar.opt_pitch_stab_h:set(1)
		Radar.opt_bank_stab_h:set(1)
		radar_stable_status = 1
	else
-- stabilization disabled for close-range combat
		Radar.opt_pb_stab_h:set(0)
		Radar.opt_pitch_stab_h:set(0)
		Radar.opt_bank_stab_h:set(0)
		radar_stable_status = 0
	end
end

-- ownship state update function
function self_change_update()

end

local test_param = get_param_handle("RADAR_CONTACT_01_TIME")
local param_ele
local param_azm
local param_range
local param_time
local sum_target = 0
local basic_gs_dis = get_param_handle("BASIC_GS_DIS")

-- refresh radar scan data
-- current testing indicates each scan result remains valid for 10 seconds, then later entries shift forward after it disappears
function update_scan_result()
	sum_target = 0
	for ia = 1,900 do
		if ia  < 10 then
			i = "_0".. ia .."_"
		else
			i = "_".. ia .."_"
		end
		param_time = get_param_handle("RADAR_CONTACT"..i.."TIME")
		if (param_time:get() < 0.82 and param_time:get() > 0) then --check whether the target belongs to the current scan
			param_ele = get_param_handle("RADAR_CONTACT"..i.."ELEVATION")
			param_azm = get_param_handle("RADAR_CONTACT"..i.."AZIMUTH")
			param_range = get_param_handle("RADAR_CONTACT"..i.."RANGE")
			sum_target = sum_target + 1
		end
-- current tests show matching timestamps up to program startup
		if ia == 1 then
			Radar.tdc_ele_up_h:set(test_param:get()) --used to test whether the two timestamps match
		elseif ia == 800 then
			Radar.tdc_ele_down_h:set(test_param:get())
		end
	end
	basic_gs_dis:set(sum_target)
end

function update()

-- display the target identifier altitude band at the current position
	--Radar.tdc_ele_up_h:set(((Sensor_Data_Raw.getBarometricAltitude() + math.tan(Radar.sz_elevation_h:get() + (perfomance.scan_volume_elevation/2)  ) * Radar.tdc_range_h:get())))
	--Radar.tdc_ele_down_h:set(((Sensor_Data_Raw.getBarometricAltitude() + math.tan(Radar.sz_elevation_h:get() - (perfomance.scan_volume_elevation/2)  ) * Radar.tdc_range_h:get())))

-- update aircraft state
	--self_change_update()

-- scan period is 41/50 s
-- check radar calibration state and calibrate scan state in search mode
-- each radar result lifetime is 10 seconds
	if (Radar.mode_h:get() == 1) then
		if (radar_scan_pos_align < 19 and radar_scan_align_target == 0) then
			radar_scan_pos_align = radar_scan_pos_align + 1
		elseif (radar_scan_pos_align >=19 and radar_scan_align_target == 0) then
			radar_scan_align_target = 1
			update_scan_result() -- this indicates one cycle has ended; start refreshing this scan pass
		elseif (radar_scan_pos_align > -20 and radar_scan_align_target == 1) then
			radar_scan_pos_align = radar_scan_pos_align - 1
		elseif (radar_scan_pos_align <= -20 and radar_scan_align_target == 1) then
			radar_scan_align_target = 0
			update_scan_result() -- this indicates one cycle has ended; start refreshing this scan pass
		end
-- recalibrate when entering single-target lock or pre-lock mode
	elseif (Radar.mode_h:get() == 2 or Radar.mode_h:get() == 3) then
		radar_scan_pos_align = 0
		radar_scan_align_target = 0
	end

-- display radar scan direction
	Radar.antenna_pos:set(math.rad(radar_scan_pos_align * 2.5))
end

need_to_be_closed = false --do not close this Lua device
-- SK60 shared cockpit integration
dofile(LockOn_Options.script_path .. "Multicrew/runtime.lua").install(8)
