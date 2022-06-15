--初始化加载要用lua文件
dofile(LockOn_Options.common_script_path.."devices_defs.lua")
dofile(LockOn_Options.script_path.."Systems/electric_system_api.lua")
dofile(LockOn_Options.script_path.."debug_util.lua")
dofile(LockOn_Options.script_path.."command_defs.lua")
dofile(LockOn_Options.script_path.."Systems/mp3List.lua")
local modPath=LockOn_Options.script_path.."../../"

--设置循环次数
local update_time_step = 0.01 -- 20次每秒
make_default_activity(update_time_step)

local ipad = GetSelf()

--初始化DCS读取API
local sensor_data = get_base_data()

------Here Strat the general Switch Control

local SWITCH_OFF = 0
local SWITCH_ON = 1
local SWITCH_TEST = -1

switch_count = 0
function _switch_counter()
    switch_count = switch_count + 1
    return switch_count
end

local strobe_light_switch = _switch_counter()

target_status = {
    {strobe_light_switch , SWITCH_OFF, get_param_handle("PTN_124"), "PTN_124"},
}

current_status = {
    {strobe_light_switch , SWITCH_OFF, SWITCH_OFF},
}

ipad_shown = 1
ipad_handle = get_param_handle("IPAD_SHOWN")
ipad_display = get_param_handle("IPAD_DIS_ENABLE")

--local iCommandPlaneGear
--[[
local pauseOrPlay = MP3Keys.mp3Player_pauseOrPlay  --暂停/播放
local _next = MP3Keys.mp3Player_next --下一首
local last = MP3Keys.mp3Player_last --上一首
local fastForward = MP3Keys.mp3Player_fastForward --快进
local fastBack = MP3Keys.mp3Player_fastBack --快退
local lrc_view_toggle=MP3Keys.show_lrc
local volUp = MP3Keys.Vol_Up
local volDown = MP3Keys.Vol_Down
]]--

local playbackPro = 0 --歌曲进度,秒为单位
local view_mode = 0 --0光盘，1歌词
local lrcLineIndex=1--歌词进度，歌词当前行数
local loopMode = 1 --循环模式，0单曲，1，歌单循环，2单曲放完就结束
local playStatus = 0 -- 播放状态 0暂停 1播放
local currentIndex = 1 --当前播放曲目索引
local fastStatus = 0 --快退/快进状态 0正常 1快进 -1快退
local Volume = 1
local mp3_disk_rot_val=0
local mp3_mag_head_rot_val=0

ipad:listen_command(Keys.MusicPauseOrPlay)
ipad:listen_command(Keys.MusicNext)
ipad:listen_command(Keys.MusicLast)
ipad:listen_command(Keys.MusicFastForward)
ipad:listen_command(Keys.MusicFastBack)
ipad:listen_command(Keys.MusicLrcViewTrigger)
ipad:listen_command(Keys.MusicVolUp)
ipad:listen_command(Keys.MusicVolDown)

local mp3_screen_enable = get_param_handle("MP3_SCR_ENABLE")
local mp3_music_list_enable = get_param_handle("MP3_MUSIC_LIST_ENABLE")

local mp3_play_enable = get_param_handle("MP3_PLAY_ENABLE")
local mp3_pause_enable = get_param_handle("MP3_PAUSE_ENABLE")
local mp3_playback_pro_text = get_param_handle("MP3_PLAYBACK_PRO_TEXT")
local mp3_music_length_text = get_param_handle("MP3_MUSIC_LENGTH_TEXT")
local mp3_name_next_text = get_param_handle("MP3_NAME_NEXT_TEXT")
local mp3_name_text = get_param_handle("MP3_NAME_TEXT")
local mp3_name_last_text = get_param_handle("MP3_NAME_LAST_TEXT")
local mp3_playback_pro_bar = get_param_handle("MP3_PLAYBACK_PRO_BAR")
local mp3_fast_mag =1 --快进倍率
local mp3_last_lrc_text = get_param_handle("MP3_LAST_LRC_TEXT")
local mp3_cur_lrc_text = get_param_handle("MP3_CUR_LRC_TEXT")
local mp3_next_lrc_text = get_param_handle("MP3_NEXT_LRC_TEXT")
local mp3_lrc_enable = get_param_handle("MP3_LRC_ENABLE")
local mp3_disk_enable = get_param_handle("MP3_DISK_ENABLE")
local mp3_disk_rot = get_param_handle("MP3_DISK_ROT")
local mp3_vol_move = get_param_handle("MP3_VOL_MOVE")
local mp3_mag_head_rot = get_param_handle("MP3_MAG_HEAD_ROT")

local mp3DiskImgEnable={}
local sndSourceList = {}

function post_initialize()
    local birth = LockOn_Options.init_conditions.birth_place
    if birth == "GROUND_HOT" then

    elseif birth == "GROUND_COLD" then

    elseif birth == "AIR_HOT" then
        
    end
    if ipad_shown == 1 then
        ipad_handle:set(1)
        ipad_display:set(1)
    end
    sndhost = create_sound_host("COCKPIT", "HEADPHONES", 0, 0, 0)
    function initSnd(_i, _v)
		table.insert( mp3DiskImgEnable, _i, get_param_handle("MP3_DISK_IMG_ENABLE_".._i))
        table.insert( sndSourceList, _i, sndhost:create_sound(_v.path))
    end
    table.foreach(mp3List,initSnd)
end

function SetCommand(command,value)
    if (command == Keys.MusicPauseOrPlay) then
        fastStatus = 0
        if playStatus == 0 then
            print_message_to_user("play")
            print_message_to_user(mp3List[currentIndex].name)

            if sndSourceList[currentIndex]:is_playing() and playbackPro<= mp3List[currentIndex].length then
                -- 暂停是通过设置播放速度为0的方式实现的，因此需要检测是播放中暂停还是本来就没播放过
                sndSourceList[currentIndex]:update(1,1,1)
            elseif loopMode == 0 then
                sndSourceList[currentIndex]:play_continue()
            else
                sndSourceList[currentIndex]:play_once()
            end
            if mp3List[currentIndex].length <= playbackPro then
                playbackPro=0
                lrcLineIndex=1--重置歌词进度
            end
        else
            print_message_to_user("pause")
            sndSourceList[currentIndex]:update(0.0001,nil,nil)
        end
        playStatus = 1 - playStatus
    elseif (command == Keys.MusicNext) then
        print_message_to_user("next song")
		playbackPro=0--重置进度条
        lrcLineIndex=1--重置歌词进度
        fastStatus = 0
        playStatus = 1
		mp3_disk_rot_val=0
        sndSourceList[currentIndex]:stop()
        if (currentIndex >= length) then
            print_message_to_user("go first song")
            currentIndex = 1
        else
            currentIndex = currentIndex + 1
        end
        if loopMode == 0 then
            sndSourceList[currentIndex]:play_continue()
        else
            sndSourceList[currentIndex]:play_once()
        end
    elseif (command == Keys.MusicLast) then
        print_message_to_user("prev song")
		playbackPro=0--重置进度条
        lrcLineIndex=1--重置歌词进度
        fastStatus = 0
        playStatus = 1
		mp3_disk_rot_val=0
        sndSourceList[currentIndex]:stop()
        if (currentIndex <= 1) then
            print_message_to_user("go last song")
            currentIndex = length
        else
            currentIndex = currentIndex - 1
        end
        if loopMode == 0 then
            sndSourceList[currentIndex]:play_continue()
        else
            sndSourceList[currentIndex]:play_once()
        end
    elseif (command == Keys.MusicFastForward) then
        mp3_fast_mag=2*mp3_fast_mag
        if mp3_fast_mag>12 then
            fastStatus = 0
            playStatus = 1
            mp3_fast_mag=1
        else
            print_message_to_user(string.format( "fastforward X%d",mp3_fast_mag ))
            fastStatus = 1
            playStatus = 0
            sndSourceList[currentIndex]:update(6,0,nil)
        end
    elseif (command == Keys.MusicFastBack) then
        mp3_fast_mag=2*mp3_fast_mag
        if mp3_fast_mag>12 then
            fastStatus = 0
            playStatus = 1
            mp3_fast_mag=1
        else
            print_message_to_user(string.format( "fast reverse X%d",mp3_fast_mag ))
            fastStatus = -1
            playStatus = 0
        end
	elseif (command == Keys.MusicLrcViewTrigger) then
        view_mode = 1-view_mode
	elseif (command == Keys.MusicVolUp) then
        if (Volume<0.9) then
			Volume=Volume + 0.1
		else
			Volume = 1
		end
	elseif (command == Keys.MusicVolDown) then
        if (Volume>0.1) then
			Volume=Volume - 0.1
		else
			Volume = 0
		end
	end
end
-- 显示歌单的函数
local function showMusicList()
    local name1,name_1,name2,name_2,name3,name_3;
    if currentIndex<4 then
        name1=mp3List[currentIndex+1].name;
        name2=mp3List[currentIndex+2].name;
        name3=mp3List[currentIndex+3].name;
        if currentIndex==1 then
            name_1=''
            name_2=''
            name_3=''
        elseif currentIndex==2 then
            name_1=''
            name_2=''
            name_3=mp3List[currentIndex-1].name
        elseif currentIndex == 3 then
            name_1=''
            name_2=mp3List[currentIndex-2].name
            name_3=mp3List[currentIndex-1].name
        else
            name_1=mp3List[currentIndex-3].name
            name_2=mp3List[currentIndex-2].name
            name_3=mp3List[currentIndex-1].name
        end
    elseif currentIndex > length-4 then
        name_1=mp3List[currentIndex-3].name
        name_2=mp3List[currentIndex-2].name
        name_3=mp3List[currentIndex-1].name
        if currentIndex==length then
            name1='';
            name2='';
            name3='';
        elseif currentIndex==length-1 then
            name1=mp3List[currentIndex+1].name;
            name2='';
            name3='';
        elseif currentIndex == length-2 then
            name1=mp3List[currentIndex+1].name;
            name2=mp3List[currentIndex+2].name;
            name3='';
        else
            name1=mp3List[currentIndex+1].name;
            name2=mp3List[currentIndex+2].name;
            name3=mp3List[currentIndex+3].name;
        end
    else
        name_1=mp3List[currentIndex-3].name
        name_2=mp3List[currentIndex-2].name
        name_3=mp3List[currentIndex-1].name
        name1=mp3List[currentIndex+1].name;
        name2=mp3List[currentIndex+2].name;
        name3=mp3List[currentIndex+3].name;
    end
    mp3_name_last_text:set(string.format( "%s\r\n%s\r\n%s",name_1,name_2,name_3))
    mp3_name_next_text:set(string.format( "%s\r\n%s\r\n%s",name1,name2,name3))
end

local function getIntPart(x)
    if x<= 0 then
        return math.ceil(x)
    end
    if math.ceil(x) == x then
        x = math.ceil(x)
    else
        x = math.ceil(x)-1
    end


    return x
end

local function showMusicLrc()
    local cur_lrc=''
    local last_lrc=''
    local next_lrc=''
    local filePath=modPath.."sounds/effects/"..mp3List[currentIndex].path..".lua"
    local F,err=io.open(filePath,"r+");
    local _lrc=nil
    if err==nil then
        dofile(filePath)
        _lrc=lrc
    end
    if _lrc==nil then
        mp3_last_lrc_text:set('')
        mp3_cur_lrc_text:set("No Lrc")
        mp3_next_lrc_text:set('')
    else
        local pos=_lrc.data[lrcLineIndex].pos
        --[[
        if pos%0.02 ~=0 then
            pos=pos+0.01
            print_message_to_user(pos%0.02)
        end
        --]]
        local flag
        if string.format( "%.2f",playbackPro )==string.format( "%.2f",pos ) then
            flag='true'
        else
            flag='false'
        end
        if string.format( "%.2f",playbackPro )==string.format( "%.2f",pos ) then
            
            
            if lrcLineIndex-5>0 then
                last_lrc=last_lrc..'\r\n'.._lrc.data[lrcLineIndex-5].lrcText
            end
            if lrcLineIndex-4>0 then
                last_lrc=last_lrc..'\r\n'.._lrc.data[lrcLineIndex-4].lrcText
            end
            if lrcLineIndex-3>0 then
                last_lrc=last_lrc..'\r\n'.._lrc.data[lrcLineIndex-3].lrcText
            end
            if lrcLineIndex-2>0 then
                last_lrc=last_lrc..'\r\n'.._lrc.data[lrcLineIndex-2].lrcText
            end
            if lrcLineIndex-1>0 then
                last_lrc=last_lrc..'\r\n'.._lrc.data[lrcLineIndex-1].lrcText
            end
            cur_lrc=_lrc.data[lrcLineIndex].lrcText
            
            if lrcLineIndex+1<=_lrc.lrcNo then
                next_lrc=next_lrc..'\r\n'.._lrc.data[lrcLineIndex+1].lrcText
            end
            if lrcLineIndex+2<=_lrc.lrcNo then
                next_lrc=next_lrc..'\r\n'.._lrc.data[lrcLineIndex+2].lrcText
            end
            if lrcLineIndex+3<=_lrc.lrcNo then
                next_lrc=next_lrc..'\r\n'.._lrc.data[lrcLineIndex+3].lrcText
            end
            if lrcLineIndex+4<=_lrc.lrcNo then
                next_lrc=next_lrc..'\r\n'.._lrc.data[lrcLineIndex+4].lrcText
            end
            if lrcLineIndex+5<=_lrc.lrcNo then
                next_lrc=next_lrc..'\r\n'.._lrc.data[lrcLineIndex+5].lrcText
            end
            --]]
            mp3_last_lrc_text:set(last_lrc)
            mp3_cur_lrc_text:set(cur_lrc)
            mp3_next_lrc_text:set(next_lrc)
            lrcLineIndex=lrcLineIndex+1
        end
    end
end
--local time=0;

function update_mp3()
    local mp3_scr_op=mp3_screen_enable:get()
    local min=playbackPro / 60
    local second=playbackPro % 60
    mp3_playback_pro_text:set(string.format( "%02d:%02d",min,second))
    mp3_music_length_text:set(string.format( "%02d:%02d",mp3List[currentIndex].length/60,mp3List[currentIndex].length%60))
    mp3_name_text:set(mp3List[currentIndex].name)
    if playbackPro > mp3List[currentIndex].length then
        if loopMode==1 then
            -- 歌单循环
            if currentIndex==length then
                -- 最后一首，播放第一首
                currentIndex=1
            else
                currentIndex=currentIndex+1
            end
            sndSourceList[currentIndex]:play_once()
        elseif loopMode==2 then
            --播放完就结束
            playStatus=0
        end
    end
    -- showMusicList()
    mp3_music_list_enable:set(0)-- 隐藏歌单
    showMusicLrc()
    mp3_playback_pro_bar:set((playbackPro/mp3List[currentIndex].length))
	--计算进度条以及控制暂停、播放键的显示
    if playStatus == 1 then
        mp3_play_enable:set(mp3_scr_op)
        mp3_pause_enable:set(0)
        sndSourceList[currentIndex]:update(1,Volume*0.1,1)
        mp3_fast_mag=1
        playbackPro = playbackPro + update_time_step --正常计算进度
		if mp3_disk_rot_val <360 then
			mp3_disk_rot_val = mp3_disk_rot_val+0.1
		else
			mp3_disk_rot_val = 0
		end
    else
        mp3_pause_enable:set(mp3_scr_op)
        mp3_play_enable:set(0)
        if fastStatus == 1 then
            playbackPro = playbackPro + update_time_step*mp3_fast_mag --快进
			if mp3_disk_rot_val <360 then
				mp3_disk_rot_val = mp3_disk_rot_val+0.1*mp3_fast_mag
			else
				mp3_disk_rot_val = 0
			end
            sndSourceList[currentIndex]:update(mp3_fast_mag,0.001,mp3_fast_mag)
            if playbackPro>mp3List[currentIndex].length then
                --如果快进进度超过歌曲长度，自动播放下一首
                fastStatus=0
                playStatus=1
                playbackPro=0--进度清零
                mp3_fast_mag=1--快进倍率变为正常
                currentIndex=currentIndex+1--下一首
                sndSourceList[currentIndex]:play_once()
            end
        elseif fastStatus == -1 then
            playbackPro = playbackPro - update_time_step*mp3_fast_mag --快退
			if mp3_disk_rot_val <360 then
				mp3_disk_rot_val = mp3_disk_rot_val-0.1*mp3_fast_mag
			else
				mp3_disk_rot_val = 0
			end
            sndSourceList[currentIndex]:update(-mp3_fast_mag,0.001,-mp3_fast_mag)
            if playbackPro>mp3List[currentIndex].length then
                --如果快进进度超过歌曲长度，自动播放下一首
                fastStatus=0
                playStatus=1
                playbackPro=0--进度清零
                mp3_fast_mag=1--快进倍率变为正常
                currentIndex=currentIndex+1--下一首
                sndSourceList[currentIndex]:play_once()
            end
        end
    end
	if view_mode == 0 then
		mp3_lrc_enable:set(0)
		mp3_disk_enable:set(mp3_scr_op)
	else
		mp3_lrc_enable:set(mp3_scr_op)
		mp3_disk_enable:set(0)
	end
	mp3_disk_rot:set(mp3_disk_rot_val)
	--控制专辑图片显示
	for i=1,#mp3List,1 do
		if(view_mode==0) then
			if i==currentIndex then
				mp3DiskImgEnable[i]:set(mp3_scr_op)
			else
				mp3DiskImgEnable[i]:set(0)
			end
		else
			mp3DiskImgEnable[i]:set(0)
		end
	end
	if (playStatus==1 and mp3_mag_head_rot_val<1) then
		--磁头伸出
		mp3_mag_head_rot_val=mp3_mag_head_rot_val+update_time_step*4
	elseif (playStatus==0 and mp3_mag_head_rot_val>0) then
		--磁头缩回
		mp3_mag_head_rot_val=mp3_mag_head_rot_val-update_time_step*4
	end
	mp3_vol_move:set(Volume)
	mp3_mag_head_rot:set(mp3_mag_head_rot_val)
end

-- code for Apple Music Style
local mp3_half_density_elem = get_param_handle("MP3_HALF_OPC_ENABLE")
local mp3_low_density_elem = get_param_handle("MP3_LOW_OPC_ENABLE")
local mp3_current_title = get_param_handle("MP3_CURR_MUSIC_NAME")
local mp3_current_artist = get_param_handle("MP3_CURR_ARTIST_NAME")
local mp3_play_pause_status = get_param_handle("MP3_PLAY_PAUSE_SWITCH")
local mp3_cover_scale_status = get_param_handle("MP3_COVER_SWITCH")
local mp3_play_prog_status = get_param_handle("MP3_PLAY_PROG_STATUS")
local mp3_volume_status = get_param_handle("MP3_VOL_STATUS")
local mp3_loop_status = get_param_handle("MP3_LOOP_SWITCH")
local mp3_shuffle_status = get_param_handle("MP3_SHUFFLE_SWITCH")
local mp3_curren_play_time = get_param_handle("MP3_CURR_PLAY_TIME")
local mp3_rest_play_time = get_param_handle("MP3_REST_PLAY_TIME")
local mp3_main_ui_mov = get_param_handle("MP3_MIN_SEC_MOV_X")

local mp3_airplay_status = get_param_handle("MP3_AIRPLAY_SWITCH")
local mp3_lyric_status = get_param_handle("MP3_LYRIC_SWITCH")
local mp3_playlist_status = get_param_handle("MP3_PLAYLIST_SWITCH")

local current_cover_status = 0
local cover_animation_frame = 59
local cover_animation_step_length = cover_animation_frame / (0.2 * 1/update_time_step)
local current_min_ui_pos = 0
local ui_move_animation_step_length = (0.2 * 1/update_time_step)

function avionic_limit(value, min, max)
    if (value > max) then
        value = max
    elseif (value < min) then
        value = min
    end
    return value
end

function animation_move(current_animation, target_value, limit_min, limit_max, step_len)
    local return_value
    if (math.abs(current_animation - target_value) < step_len) then
        return_value = target_value
    elseif (current_animation < target_value) then
        return_value = current_animation + step_len
    elseif (current_animation > target_value) then
        return_value = current_animation - step_len
    end
    return_value = avionic_limit(return_value, limit_min, limit_max)
    return return_value
end
--current_cover_status

function updateAMstyle()
    mp3_current_title:set(mp3List[currentIndex].name)
    mp3_current_artist:set(mp3List[currentIndex].artist)
    mp3_play_pause_status:set(playStatus)
    mp3_half_density_elem:set(mp3_screen_enable:get()*0.5)
    mp3_low_density_elem:set(mp3_screen_enable:get()*0.25)
    -- set the play status of cover animation
    local target_animation_pos = playStatus*(cover_animation_frame-1)
    current_cover_status = animation_move(current_cover_status, target_animation_pos, 0, cover_animation_frame, cover_animation_step_length)
    if (current_cover_status < target_animation_pos) then
        mp3_cover_scale_status:set(math.ceil(current_cover_status))
    elseif (current_cover_status < target_animation_pos) then
        mp3_cover_scale_status:set(math.floor(current_cover_status))
    else
        mp3_cover_scale_status:set(target_animation_pos)
    end

    mp3_play_prog_status:set((playbackPro/mp3List[currentIndex].length))
    mp3_loop_status:set(2-loopMode)
    mp3_volume_status:set(Volume)
    local rest_time = mp3List[currentIndex].length - playbackPro
    mp3_curren_play_time:set(string.format( "%02d:%02d",playbackPro/60,playbackPro%60))
    mp3_rest_play_time:set(string.format( "%02d:%02d",rest_time/60,rest_time%60))
    -- set the position animation of the minimal play UI
    if view_mode == 0 then
        current_min_ui_pos = animation_move(current_min_ui_pos, 0, 0, 1, ui_move_animation_step_length)
        mp3_playlist_status:set(0)
        mp3_lyric_status:set(0)
    else
        current_min_ui_pos = animation_move(current_min_ui_pos, 1, 0, 1, ui_move_animation_step_length)
        if view_mode == 1 then
            mp3_lyric_status:set(1)
            mp3_playlist_status:set(0)
        else
            mp3_lyric_status:set(0)
            mp3_playlist_status:set(1)
        end
    end
    mp3_main_ui_mov:set(-current_min_ui_pos)
end
-- end of code

function update_switch_status()
    local switch_moving_step = 0.25
    for k,v in pairs(target_status) do
        if math.abs(target_status[k][2] - current_status[k][2]) < switch_moving_step then
            current_status[k][2] = target_status[k][2]
        elseif target_status[k][2] > current_status[k][2] then
            current_status[k][2] = current_status[k][2] + switch_moving_step
        elseif target_status[k][2] < current_status[k][2] then
            current_status[k][2] = current_status[k][2] - switch_moving_step
        end
        target_status[k][3]:set(current_status[k][2])
        local temp_switch_ref = get_clickable_element_reference(target_status[k][4])
        temp_switch_ref:update()
        -- print_message_to_user(k)
    end
end

function update()
    ipad_handle:set(-ipad_shown)
    mp3_screen_enable:set(ipad_shown)
    update_mp3()
    updateAMstyle()
end

need_to_be_closed = false