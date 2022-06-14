local __count = 0
length = 0
local function __counter()
	__count = __count + 1
	length = __count
	return __count
end
mp3List={}
local function addMusic(path,name,artist,length,img,img_w,img_h)
	if img == nil then
		img=LockOn_Options.script_path..'../../Theme/ME/briefing-map-default.png'
		img_w=1180
		img_h=1179
	end
	mp3List[__counter()]	=	{
		path=path,
		name=name,
		artist=artist,
		length=length,--歌曲长度
		img=img,
		img_w=img_w,
		img_h=img_h
	}
	
end
local ImgBasePath = LockOn_Options.script_path.."../Textures/Mp3Img/"
-- this config include a table named 
dofile(LockOn_Options.script_path.."../Config/MusicPlayerConfig.lua")
for index, value in ipairs(MusicPlayerList) do
	if value[4] == nil then
		addMusic(value[1], value[2], value[3], value[4])
	else
		addMusic(value[1], value[2], value[3], value[4], value[5], value[6], value[7])
	end
end