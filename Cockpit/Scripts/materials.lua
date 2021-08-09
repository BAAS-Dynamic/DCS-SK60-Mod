
--dofile(LockOn_Options.script_path.."fonts.lua")
dofile(LockOn_Options.common_script_path.."Fonts/fonts_cmn.lua")

-------MATERIALS-------
materials = {}
materials["DBG_GREY"]    = {5, 5, 5, 255}
materials["DBG_BLACK"]   = {0, 0, 0, 255}
materials["DBG_BLUE"]   = {0, 0, 100, 100}
materials["DBG_GREEN"]   = {0, 80, 0, 100}
materials["DBG_RED"]     = {255, 0, 0, 255}
materials["DBG_CLEAR"]   = {0, 0, 0, 0}
materials["BLOB_COLOR"] = {0,128,0,192}
materials["TEST_MATERIAL"] 	= {17,80,7,20}
materials["RADAR_GRID"] = {0,100,0,192}
materials["RADAR_SCRIBE"] = {0,200,0,192}
materials["GUNSIGHT_GLASS"] = {0,120,0,128}
materials["TEST_COLOR"] = {50,250,0,255}
materials["HUD_DAY_COLOR"]          = {0,200,0,200}
materials["EALT_BG_COLOR"]	= {0,50,255,255}
materials["EALT_BG_DARK_COLOR"]	= {0,30,120,255}


local IndicationFontPath = LockOn_Options.script_path.."../Textures/Fonts/"

-------TEXTURES-------
textures = {}
-- textures["BLOB_TEXTURE"] = {"radar_blob.dds",materials["BLOB_COLOR"]}
textures["TEST_TEXTURE"] = {"test4.dds",materials["TEST_COLOR"]}

-------------------------------------------------------
-------FONTS-------
fontdescription = {}

MPCD_size_mult = 2
MPCD_xsize = 29 * MPCD_size_mult
MPCD_ysize = 64 * MPCD_size_mult

fontdescription["font_MPCD"] = {
	texture		= IndicationFontPath.."font_MFD.dds",
	size		= {8, 8},
	resolution	= {1024, 1024},
	default		= {MPCD_xsize, MPCD_ysize},
	chars		= {
		[1]   = {64,  MPCD_xsize, MPCD_ysize}, -- @ == ©
		[2]   = {18,  MPCD_xsize, MPCD_ysize}, -- ^ == \18
		[3]   = {20,  MPCD_xsize, MPCD_ysize}, -- ¶ == [] == \20
		[4]   = {26,  MPCD_xsize, MPCD_ysize}, -- > == -> == \26
		[5]   = {27,  MPCD_xsize, MPCD_ysize}, -- < == <- == \27
		[6]   = {31,  MPCD_xsize, MPCD_ysize}, -- SPARE 
		[7]   = {126, MPCD_xsize, MPCD_ysize}, -- ~
		[8]   = {32,  MPCD_xsize, MPCD_ysize}, -- [space]
		[9]   = {33,  MPCD_xsize, MPCD_ysize}, -- !
		[10]  = {35,  MPCD_xsize, MPCD_ysize}, -- #
		[11]  = {40,  MPCD_xsize, MPCD_ysize}, -- (
		[12]  = {41,  MPCD_xsize, MPCD_ysize}, -- )
		[13]  = {42,  MPCD_xsize, MPCD_ysize}, -- *
		[14]  = {43,  MPCD_xsize, MPCD_ysize}, -- +
		[15]  = {45,  MPCD_xsize, MPCD_ysize}, -- -
		[16]  = {46,  MPCD_xsize, MPCD_ysize}, -- .
		[17]  = {47,  MPCD_xsize, MPCD_ysize}, -- /
		[18]  = {48,  MPCD_xsize, MPCD_ysize}, -- 0
		[19]  = {49,  MPCD_xsize, MPCD_ysize}, -- 1
		[20]  = {50,  MPCD_xsize, MPCD_ysize}, -- 2
		[21]  = {51,  MPCD_xsize, MPCD_ysize}, -- 3
		[22]  = {52,  MPCD_xsize, MPCD_ysize}, -- 4
		[23]  = {53,  MPCD_xsize, MPCD_ysize}, -- 5
		[24]  = {54,  MPCD_xsize, MPCD_ysize}, -- 6
		[25]  = {55,  MPCD_xsize, MPCD_ysize}, -- 7
		[26]  = {56,  MPCD_xsize, MPCD_ysize}, -- 8
		[27]  = {57,  MPCD_xsize, MPCD_ysize}, -- 9
		[28]  = {58,  MPCD_xsize, MPCD_ysize}, -- :
		[29]  = {61,  MPCD_xsize, MPCD_ysize}, -- =
		[30]  = {63,  MPCD_xsize, MPCD_ysize}, -- ?
		[31]  = {65,  MPCD_xsize, MPCD_ysize}, -- A
		[32]  = {66,  MPCD_xsize, MPCD_ysize}, -- B
		[33]  = {67,  MPCD_xsize, MPCD_ysize}, -- C
		[34]  = {68,  MPCD_xsize, MPCD_ysize}, -- D
		[35]  = {69,  MPCD_xsize, MPCD_ysize}, -- E
		[36]  = {70,  MPCD_xsize, MPCD_ysize}, -- F
		[37]  = {71,  MPCD_xsize, MPCD_ysize}, -- G
		[38]  = {72,  MPCD_xsize, MPCD_ysize}, -- H
		[39]  = {73,  MPCD_xsize, MPCD_ysize}, -- I
		[40]  = {74,  MPCD_xsize, MPCD_ysize}, -- J
		[41]  = {75,  MPCD_xsize, MPCD_ysize}, -- K
		[42]  = {76,  MPCD_xsize, MPCD_ysize}, -- L
		[43]  = {77,  MPCD_xsize, MPCD_ysize}, -- M
		[44]  = {78,  MPCD_xsize, MPCD_ysize}, -- N
		[45]  = {79,  MPCD_xsize, MPCD_ysize}, -- O
		[46]  = {80,  MPCD_xsize, MPCD_ysize}, -- P
		[47]  = {81,  MPCD_xsize, MPCD_ysize}, -- Q
		[48]  = {82,  MPCD_xsize, MPCD_ysize}, -- R
		[49]  = {83,  MPCD_xsize, MPCD_ysize}, -- S
		[50]  = {84,  MPCD_xsize, MPCD_ysize}, -- T
		[51]  = {85,  MPCD_xsize, MPCD_ysize}, -- U
		[52]  = {86,  MPCD_xsize, MPCD_ysize}, -- V
		[53]  = {87,  MPCD_xsize, MPCD_ysize}, -- W
		[54]  = {88,  MPCD_xsize, MPCD_ysize}, -- X
		[55]  = {89,  MPCD_xsize, MPCD_ysize}, -- Y
		[56]  = {90,  MPCD_xsize, MPCD_ysize}, -- Z
		[57]  = {91,  MPCD_xsize, MPCD_ysize}, -- [
		[58]  = {93,  MPCD_xsize, MPCD_ysize}, -- ] 
		[59]  = {124, MPCD_xsize, MPCD_ysize}, -- | == ¦
		[60]  = {38,  MPCD_xsize, MPCD_ysize}, -- & == +- 
		[61]  = {59,  MPCD_xsize, MPCD_ysize}, -- ; == ° 
		[62]  = {95,  MPCD_xsize, MPCD_ysize}, -- _
		[63]  = {37,  MPCD_xsize, MPCD_ysize},-- %
		[64]  = {24,  MPCD_xsize, MPCD_ysize},-- alpha α
	}
}

fontdescription["font_EADI"] = {
	texture		= IndicationFontPath.."font_EADI.dds",
	size		= {8, 8},
	resolution	= {1024, 1024},
	default		= {MPCD_xsize, MPCD_ysize},
	chars		= {
		[1]   = {64,  MPCD_xsize, MPCD_ysize}, -- @ == ©
		[2]   = {18,  MPCD_xsize, MPCD_ysize}, -- ^ == \18
		[3]   = {20,  MPCD_xsize, MPCD_ysize}, -- ¶ == [] == \20
		[4]   = {26,  MPCD_xsize, MPCD_ysize}, -- > == -> == \26
		[5]   = {27,  MPCD_xsize, MPCD_ysize}, -- < == <- == \27
		[6]   = {31,  MPCD_xsize, MPCD_ysize}, -- SPARE 
		[7]   = {126, MPCD_xsize, MPCD_ysize}, -- ~
		[8]   = {32,  MPCD_xsize, MPCD_ysize}, -- [space]
		[9]   = {33,  MPCD_xsize, MPCD_ysize}, -- !
		[10]  = {35,  MPCD_xsize, MPCD_ysize}, -- #
		[11]  = {40,  MPCD_xsize, MPCD_ysize}, -- (
		[12]  = {41,  MPCD_xsize, MPCD_ysize}, -- )
		[13]  = {42,  MPCD_xsize, MPCD_ysize}, -- *
		[14]  = {43,  MPCD_xsize, MPCD_ysize}, -- +
		[15]  = {45,  MPCD_xsize, MPCD_ysize}, -- -
		[16]  = {46,  MPCD_xsize, MPCD_ysize}, -- .
		[17]  = {47,  MPCD_xsize, MPCD_ysize}, -- /
		[18]  = {48,  MPCD_xsize, MPCD_ysize}, -- 0
		[19]  = {49,  MPCD_xsize, MPCD_ysize}, -- 1
		[20]  = {50,  MPCD_xsize, MPCD_ysize}, -- 2
		[21]  = {51,  MPCD_xsize, MPCD_ysize}, -- 3
		[22]  = {52,  MPCD_xsize, MPCD_ysize}, -- 4
		[23]  = {53,  MPCD_xsize, MPCD_ysize}, -- 5
		[24]  = {54,  MPCD_xsize, MPCD_ysize}, -- 6
		[25]  = {55,  MPCD_xsize, MPCD_ysize}, -- 7
		[26]  = {56,  MPCD_xsize, MPCD_ysize}, -- 8
		[27]  = {57,  MPCD_xsize, MPCD_ysize}, -- 9
		[28]  = {58,  MPCD_xsize, MPCD_ysize}, -- :
		[29]  = {61,  MPCD_xsize, MPCD_ysize}, -- =
		[30]  = {63,  MPCD_xsize, MPCD_ysize}, -- ?
		[31]  = {65,  MPCD_xsize, MPCD_ysize}, -- A
		[32]  = {66,  MPCD_xsize, MPCD_ysize}, -- B
		[33]  = {67,  MPCD_xsize, MPCD_ysize}, -- C
		[34]  = {68,  MPCD_xsize, MPCD_ysize}, -- D
		[35]  = {69,  MPCD_xsize, MPCD_ysize}, -- E
		[36]  = {70,  MPCD_xsize, MPCD_ysize}, -- F
		[37]  = {71,  MPCD_xsize, MPCD_ysize}, -- G
		[38]  = {72,  MPCD_xsize, MPCD_ysize}, -- H
		[39]  = {73,  MPCD_xsize, MPCD_ysize}, -- I
		[40]  = {74,  MPCD_xsize, MPCD_ysize}, -- J
		[41]  = {75,  MPCD_xsize, MPCD_ysize}, -- K
		[42]  = {76,  MPCD_xsize, MPCD_ysize}, -- L
		[43]  = {77,  MPCD_xsize, MPCD_ysize}, -- M
		[44]  = {78,  MPCD_xsize, MPCD_ysize}, -- N
		[45]  = {79,  MPCD_xsize, MPCD_ysize}, -- O
		[46]  = {80,  MPCD_xsize, MPCD_ysize}, -- P
		[47]  = {81,  MPCD_xsize, MPCD_ysize}, -- Q
		[48]  = {82,  MPCD_xsize, MPCD_ysize}, -- R
		[49]  = {83,  MPCD_xsize, MPCD_ysize}, -- S
		[50]  = {84,  MPCD_xsize, MPCD_ysize}, -- T
		[51]  = {85,  MPCD_xsize, MPCD_ysize}, -- U
		[52]  = {86,  MPCD_xsize, MPCD_ysize}, -- V
		[53]  = {87,  MPCD_xsize, MPCD_ysize}, -- W
		[54]  = {88,  MPCD_xsize, MPCD_ysize}, -- X
		[55]  = {89,  MPCD_xsize, MPCD_ysize}, -- Y
		[56]  = {90,  MPCD_xsize, MPCD_ysize}, -- Z
		[57]  = {91,  MPCD_xsize, MPCD_ysize}, -- [
		[58]  = {93,  MPCD_xsize, MPCD_ysize}, -- ] 
		[59]  = {124, MPCD_xsize, MPCD_ysize}, -- | == ¦
		[60]  = {38,  MPCD_xsize, MPCD_ysize}, -- & == +- 
		[61]  = {59,  MPCD_xsize, MPCD_ysize}, -- ; == ° 
		[62]  = {95,  MPCD_xsize, MPCD_ysize}, -- _
		[63]  = {37,  MPCD_xsize, MPCD_ysize},-- %
		[64]  = {24,  MPCD_xsize, MPCD_ysize},-- alpha α
	}
}

fontdescription["font_HUD"] = {
	texture		= IndicationFontPath.."font_HUD.dds",
	size		= {8, 8},
	resolution	= {1024, 1024},
	default		= {MPCD_xsize, MPCD_ysize},
	chars		= {
		[1]   = {64,  MPCD_xsize, MPCD_ysize}, -- @ == ©
		[2]   = {18,  MPCD_xsize, MPCD_ysize}, -- ^ == \18
		[3]   = {20,  MPCD_xsize, MPCD_ysize}, -- ¶ == [] == \20
		[4]   = {26,  MPCD_xsize, MPCD_ysize}, -- > == -> == \26
		[5]   = {27,  MPCD_xsize, MPCD_ysize}, -- < == <- == \27
		[6]   = {31,  MPCD_xsize, MPCD_ysize}, -- SPARE 
		[7]   = {126, MPCD_xsize, MPCD_ysize}, -- ~
		[8]   = {32,  MPCD_xsize, MPCD_ysize}, -- [space]
		[9]   = {33,  MPCD_xsize, MPCD_ysize}, -- !
		[10]  = {35,  MPCD_xsize, MPCD_ysize}, -- #
		[11]  = {40,  MPCD_xsize, MPCD_ysize}, -- (
		[12]  = {41,  MPCD_xsize, MPCD_ysize}, -- )
		[13]  = {42,  MPCD_xsize, MPCD_ysize}, -- *
		[14]  = {43,  MPCD_xsize, MPCD_ysize}, -- +
		[15]  = {45,  MPCD_xsize, MPCD_ysize}, -- -
		[16]  = {46,  MPCD_xsize, MPCD_ysize}, -- .
		[17]  = {47,  MPCD_xsize, MPCD_ysize}, -- /
		[18]  = {48,  MPCD_xsize, MPCD_ysize}, -- 0
		[19]  = {49,  MPCD_xsize, MPCD_ysize}, -- 1
		[20]  = {50,  MPCD_xsize, MPCD_ysize}, -- 2
		[21]  = {51,  MPCD_xsize, MPCD_ysize}, -- 3
		[22]  = {52,  MPCD_xsize, MPCD_ysize}, -- 4
		[23]  = {53,  MPCD_xsize, MPCD_ysize}, -- 5
		[24]  = {54,  MPCD_xsize, MPCD_ysize}, -- 6
		[25]  = {55,  MPCD_xsize, MPCD_ysize}, -- 7
		[26]  = {56,  MPCD_xsize, MPCD_ysize}, -- 8
		[27]  = {57,  MPCD_xsize, MPCD_ysize}, -- 9
		[28]  = {58,  MPCD_xsize, MPCD_ysize}, -- :
		[29]  = {61,  MPCD_xsize, MPCD_ysize}, -- =
		[30]  = {63,  MPCD_xsize, MPCD_ysize}, -- ?
		[31]  = {65,  MPCD_xsize, MPCD_ysize}, -- A
		[32]  = {66,  MPCD_xsize, MPCD_ysize}, -- B
		[33]  = {67,  MPCD_xsize, MPCD_ysize}, -- C
		[34]  = {68,  MPCD_xsize, MPCD_ysize}, -- D
		[35]  = {69,  MPCD_xsize, MPCD_ysize}, -- E
		[36]  = {70,  MPCD_xsize, MPCD_ysize}, -- F
		[37]  = {71,  MPCD_xsize, MPCD_ysize}, -- G
		[38]  = {72,  MPCD_xsize, MPCD_ysize}, -- H
		[39]  = {73,  MPCD_xsize, MPCD_ysize}, -- I
		[40]  = {74,  MPCD_xsize, MPCD_ysize}, -- J
		[41]  = {75,  MPCD_xsize, MPCD_ysize}, -- K
		[42]  = {76,  MPCD_xsize, MPCD_ysize}, -- L
		[43]  = {77,  MPCD_xsize, MPCD_ysize}, -- M
		[44]  = {78,  MPCD_xsize, MPCD_ysize}, -- N
		[45]  = {79,  MPCD_xsize, MPCD_ysize}, -- O
		[46]  = {80,  MPCD_xsize, MPCD_ysize}, -- P
		[47]  = {81,  MPCD_xsize, MPCD_ysize}, -- Q
		[48]  = {82,  MPCD_xsize, MPCD_ysize}, -- R
		[49]  = {83,  MPCD_xsize, MPCD_ysize}, -- S
		[50]  = {84,  MPCD_xsize, MPCD_ysize}, -- T
		[51]  = {85,  MPCD_xsize, MPCD_ysize}, -- U
		[52]  = {86,  MPCD_xsize, MPCD_ysize}, -- V
		[53]  = {87,  MPCD_xsize, MPCD_ysize}, -- W
		[54]  = {88,  MPCD_xsize, MPCD_ysize}, -- X
		[55]  = {89,  MPCD_xsize, MPCD_ysize}, -- Y
		[56]  = {90,  MPCD_xsize, MPCD_ysize}, -- Z
		[57]  = {91,  MPCD_xsize, MPCD_ysize}, -- [
		[58]  = {93,  MPCD_xsize, MPCD_ysize}, -- ] 
		[59]  = {124, MPCD_xsize, MPCD_ysize}, -- | == ¦
		[60]  = {38,  MPCD_xsize, MPCD_ysize}, -- & == +- 
		[61]  = {59,  MPCD_xsize, MPCD_ysize}, -- ; == ° 
		[62]  = {95,  MPCD_xsize, MPCD_ysize}, -- _
		[63]  = {37,  MPCD_xsize, MPCD_ysize},-- %
		[64]  = {24,  MPCD_xsize, MPCD_ysize},-- alpha α
	}
}

fontdescription["font_LCD"] = {
	texture		= IndicationFontPath.."lcd_font.dds",
	size		= {8, 8},
	resolution	= {1024, 1024},
	default		= {MPCD_xsize, MPCD_ysize},
	chars		= {
		[1]   = {64,  MPCD_xsize, MPCD_ysize}, -- @ == ©
		[2]   = {18,  MPCD_xsize, MPCD_ysize}, -- ^ == \18
		[3]   = {20,  MPCD_xsize, MPCD_ysize}, -- ¶ == [] == \20
		[4]   = {26,  MPCD_xsize, MPCD_ysize}, -- > == -> == \26
		[5]   = {27,  MPCD_xsize, MPCD_ysize}, -- < == <- == \27
		[6]   = {31,  MPCD_xsize, MPCD_ysize}, -- SPARE 
		[7]   = {126, MPCD_xsize, MPCD_ysize}, -- ~
		[8]   = {32,  MPCD_xsize, MPCD_ysize}, -- [space]
		[9]   = {33,  MPCD_xsize, MPCD_ysize}, -- !
		[10]  = {35,  MPCD_xsize, MPCD_ysize}, -- #
		[11]  = {40,  MPCD_xsize, MPCD_ysize}, -- (
		[12]  = {41,  MPCD_xsize, MPCD_ysize}, -- )
		[13]  = {42,  MPCD_xsize, MPCD_ysize}, -- *
		[14]  = {43,  MPCD_xsize, MPCD_ysize}, -- +
		[15]  = {45,  MPCD_xsize, MPCD_ysize}, -- -
		[16]  = {46,  MPCD_xsize, MPCD_ysize}, -- .
		[17]  = {47,  MPCD_xsize, MPCD_ysize}, -- /
		[18]  = {48,  MPCD_xsize, MPCD_ysize}, -- 0
		[19]  = {49,  MPCD_xsize, MPCD_ysize}, -- 1
		[20]  = {50,  MPCD_xsize, MPCD_ysize}, -- 2
		[21]  = {51,  MPCD_xsize, MPCD_ysize}, -- 3
		[22]  = {52,  MPCD_xsize, MPCD_ysize}, -- 4
		[23]  = {53,  MPCD_xsize, MPCD_ysize}, -- 5
		[24]  = {54,  MPCD_xsize, MPCD_ysize}, -- 6
		[25]  = {55,  MPCD_xsize, MPCD_ysize}, -- 7
		[26]  = {56,  MPCD_xsize, MPCD_ysize}, -- 8
		[27]  = {57,  MPCD_xsize, MPCD_ysize}, -- 9
		[28]  = {58,  MPCD_xsize, MPCD_ysize}, -- :
		[29]  = {61,  MPCD_xsize, MPCD_ysize}, -- =
		[30]  = {63,  MPCD_xsize, MPCD_ysize}, -- ?
		[31]  = {65,  MPCD_xsize, MPCD_ysize}, -- A
		[32]  = {66,  MPCD_xsize, MPCD_ysize}, -- B
		[33]  = {67,  MPCD_xsize, MPCD_ysize}, -- C
		[34]  = {68,  MPCD_xsize, MPCD_ysize}, -- D
		[35]  = {69,  MPCD_xsize, MPCD_ysize}, -- E
		[36]  = {70,  MPCD_xsize, MPCD_ysize}, -- F
		[37]  = {71,  MPCD_xsize, MPCD_ysize}, -- G
		[38]  = {72,  MPCD_xsize, MPCD_ysize}, -- H
		[39]  = {73,  MPCD_xsize, MPCD_ysize}, -- I
		[40]  = {74,  MPCD_xsize, MPCD_ysize}, -- J
		[41]  = {75,  MPCD_xsize, MPCD_ysize}, -- K
		[42]  = {76,  MPCD_xsize, MPCD_ysize}, -- L
		[43]  = {77,  MPCD_xsize, MPCD_ysize}, -- M
		[44]  = {78,  MPCD_xsize, MPCD_ysize}, -- N
		[45]  = {79,  MPCD_xsize, MPCD_ysize}, -- O
		[46]  = {80,  MPCD_xsize, MPCD_ysize}, -- P
		[47]  = {81,  MPCD_xsize, MPCD_ysize}, -- Q
		[48]  = {82,  MPCD_xsize, MPCD_ysize}, -- R
		[49]  = {83,  MPCD_xsize, MPCD_ysize}, -- S
		[50]  = {84,  MPCD_xsize, MPCD_ysize}, -- T
		[51]  = {85,  MPCD_xsize, MPCD_ysize}, -- U
		[52]  = {86,  MPCD_xsize, MPCD_ysize}, -- V
		[53]  = {87,  MPCD_xsize, MPCD_ysize}, -- W
		[54]  = {88,  MPCD_xsize, MPCD_ysize}, -- X
		[55]  = {89,  MPCD_xsize, MPCD_ysize}, -- Y
		[56]  = {90,  MPCD_xsize, MPCD_ysize}, -- Z
		[57]  = {91,  MPCD_xsize, MPCD_ysize}, -- [
		[58]  = {93,  MPCD_xsize, MPCD_ysize}, -- ] 
		[59]  = {124, MPCD_xsize, MPCD_ysize}, -- | == ¦
		[60]  = {38,  MPCD_xsize, MPCD_ysize}, -- & == +- 
		[61]  = {59,  MPCD_xsize, MPCD_ysize}, -- ; == ° 
		[62]  = {95,  MPCD_xsize, MPCD_ysize}, -- _
		[63]  = {37,  MPCD_xsize, MPCD_ysize},-- %
		[64]  = {24,  MPCD_xsize, MPCD_ysize},-- alpha α
	}
}

MPCD_size_mult_2048 = 2.66666667
MPCD_xsize_2k = 34 * MPCD_size_mult_2048	-- 29
MPCD_ysize_2k = 64 * MPCD_size_mult_2048

fontdescription["font_Pixel"] = {
	texture		= IndicationFontPath.."pixel_font.dds",
	size		= {12, 12},
	resolution	= {2048, 2048},
	default		= {MPCD_xsize_2k, MPCD_ysize_2k},
	chars		= {
		[1]   = {42,  MPCD_xsize_2k, MPCD_ysize_2k}, -- *
		[2]   = {33,  MPCD_xsize_2k, MPCD_ysize_2k}, -- ! {18,  MPCD_xsize_2k, MPCD_ysize_2k}, -- ^ == \18
		[3]   = {43,  MPCD_xsize_2k, MPCD_ysize_2k}, -- + {20,  MPCD_xsize_2k, MPCD_ysize_2k}, -- ¶ == [] == \20
		[4]   = {45,  MPCD_xsize_2k, MPCD_ysize_2k}, -- - {26,  MPCD_xsize_2k, MPCD_ysize_2k}, -- > == -> == \26
		[5]   = {64,  MPCD_xsize_2k, MPCD_ysize_2k}, -- @ == © -- < == <- == \27
		[6]   = {35,  MPCD_xsize_2k, MPCD_ysize_2k}, -- # {31,  MPCD_xsize_2k, MPCD_ysize_2k}, -- SPARE 
		[7]   = {44,  MPCD_xsize_2k, MPCD_ysize_2k}, -- ,
		[8]   = {63,  MPCD_xsize_2k, MPCD_ysize_2k}, -- ?
		[9]   = {58,  MPCD_xsize_2k, MPCD_ysize_2k}, -- :
		[10]  = {61,  MPCD_xsize_2k, MPCD_ysize_2k}, -- =
		[11]  = {32,  MPCD_xsize_2k, MPCD_ysize_2k}, -- [space]
		[12]  = {125,  MPCD_xsize_2k, MPCD_ysize_2k}, -- }
		-- line 2
		[13]  = {128, MPCD_xsize_2k, MPCD_ysize_2k}, -- 
		[14]  = {129, MPCD_xsize_2k, MPCD_ysize_2k}, -- 
		[15]  = {130, MPCD_xsize_2k, MPCD_ysize_2k}, -- 
		[16]  = {131, MPCD_xsize_2k, MPCD_ysize_2k}, -- 
		[17]  = {132, MPCD_xsize_2k, MPCD_ysize_2k}, -- 
		[18]  = {133, MPCD_xsize_2k, MPCD_ysize_2k}, -- 
		[19]  = {134, MPCD_xsize_2k, MPCD_ysize_2k}, -- 
		[20]  = {60, MPCD_xsize_2k, MPCD_ysize_2k}, -- <
		[21]  = {62,  MPCD_xsize_2k, MPCD_ysize_2k}, -- >
		[22]  = {40,  MPCD_xsize_2k, MPCD_ysize_2k}, -- (
		[23]  = {41,  MPCD_xsize_2k, MPCD_ysize_2k}, -- )
		[24]  = {46,  MPCD_xsize_2k, MPCD_ysize_2k}, -- .
		-- line 3
		[25]  = {47,  MPCD_xsize_2k, MPCD_ysize_2k}, -- /
		[26]  = {48,  MPCD_xsize_2k, MPCD_ysize_2k}, -- 0
		[27]  = {49,  MPCD_xsize_2k, MPCD_ysize_2k}, -- 1
		[28]  = {50,  MPCD_xsize_2k, MPCD_ysize_2k}, -- 2
		[29]  = {51,  MPCD_xsize_2k, MPCD_ysize_2k}, -- 3
		[30]  = {52,  MPCD_xsize_2k, MPCD_ysize_2k}, -- 4
		[31]  = {53,  MPCD_xsize_2k, MPCD_ysize_2k}, -- 5
		[32]  = {54,  MPCD_xsize_2k, MPCD_ysize_2k}, -- 6
		[33]  = {55,  MPCD_xsize_2k, MPCD_ysize_2k}, -- 7
		[34]  = {56,  MPCD_xsize_2k, MPCD_ysize_2k}, -- 8
		[35]  = {57,  MPCD_xsize_2k, MPCD_ysize_2k}, -- 9
		[36]  = {123,  MPCD_xsize_2k, MPCD_ysize_2k}, -- {
		[37]  = {65,  MPCD_xsize_2k, MPCD_ysize_2k}, -- A
		[38]  = {66,  MPCD_xsize_2k, MPCD_ysize_2k}, -- B
		[39]  = {67,  MPCD_xsize_2k, MPCD_ysize_2k}, -- C
		[40]  = {68,  MPCD_xsize_2k, MPCD_ysize_2k}, -- D
		[41]  = {69,  MPCD_xsize_2k, MPCD_ysize_2k}, -- E
		[42]  = {70,  MPCD_xsize_2k, MPCD_ysize_2k}, -- F
		[43]  = {71,  MPCD_xsize_2k, MPCD_ysize_2k}, -- G
		[44]  = {72,  MPCD_xsize_2k, MPCD_ysize_2k}, -- H
		[45]  = {73,  MPCD_xsize_2k, MPCD_ysize_2k}, -- I
		[46]  = {74,  MPCD_xsize_2k, MPCD_ysize_2k}, -- J
		[47]  = {75,  MPCD_xsize_2k, MPCD_ysize_2k}, -- K
		[48]  = {76,  MPCD_xsize_2k, MPCD_ysize_2k}, -- L
		[49]  = {77,  MPCD_xsize_2k, MPCD_ysize_2k}, -- M
		[50]  = {78,  MPCD_xsize_2k, MPCD_ysize_2k}, -- N
		[51]  = {79,  MPCD_xsize_2k, MPCD_ysize_2k}, -- O
		[52]  = {80,  MPCD_xsize_2k, MPCD_ysize_2k}, -- P
		[53]  = {81,  MPCD_xsize_2k, MPCD_ysize_2k}, -- Q
		[54]  = {82,  MPCD_xsize_2k, MPCD_ysize_2k}, -- R
		[55]  = {83,  MPCD_xsize_2k, MPCD_ysize_2k}, -- S
		[56]  = {84,  MPCD_xsize_2k, MPCD_ysize_2k}, -- T
		[57]  = {85,  MPCD_xsize_2k, MPCD_ysize_2k}, -- U
		[58]  = {86,  MPCD_xsize_2k, MPCD_ysize_2k}, -- V
		[59]  = {87,  MPCD_xsize_2k, MPCD_ysize_2k}, -- W
		[60]  = {88,  MPCD_xsize_2k, MPCD_ysize_2k}, -- X
		[61]  = {89,  MPCD_xsize_2k, MPCD_ysize_2k}, -- Y
		[62]  = {90,  MPCD_xsize_2k, MPCD_ysize_2k}, -- Z
		[63]  = {97,  MPCD_xsize_2k, MPCD_ysize_2k}, -- a
		[64]  = {98,  MPCD_xsize_2k, MPCD_ysize_2k}, -- b
		[65]  = {99,  MPCD_xsize_2k, MPCD_ysize_2k}, -- c
		[66]  = {100,  MPCD_xsize_2k, MPCD_ysize_2k}, -- d
		[67]  = {101,  MPCD_xsize_2k, MPCD_ysize_2k}, -- e
		[68]  = {102,  MPCD_xsize_2k, MPCD_ysize_2k}, -- f
		[69]  = {103,  MPCD_xsize_2k, MPCD_ysize_2k}, -- g
		[70]  = {104,  MPCD_xsize_2k, MPCD_ysize_2k}, -- h
		[71]  = {105,  MPCD_xsize_2k, MPCD_ysize_2k}, -- i
		[72]  = {106,  MPCD_xsize_2k, MPCD_ysize_2k}, -- j
		[73]  = {107,  MPCD_xsize_2k, MPCD_ysize_2k}, -- k
		[74]  = {108,  MPCD_xsize_2k, MPCD_ysize_2k}, -- l
		[75]  = {109,  MPCD_xsize_2k, MPCD_ysize_2k}, -- m
		[76]  = {110,  MPCD_xsize_2k, MPCD_ysize_2k}, -- n
		[77]  = {111,  MPCD_xsize_2k, MPCD_ysize_2k}, -- o
		[78]  = {112,  MPCD_xsize_2k, MPCD_ysize_2k}, -- p
		[79]  = {113,  MPCD_xsize_2k, MPCD_ysize_2k}, -- q
		[80]  = {114,  MPCD_xsize_2k, MPCD_ysize_2k}, -- r
		[81]  = {115,  MPCD_xsize_2k, MPCD_ysize_2k}, -- s
		[82]  = {116,  MPCD_xsize_2k, MPCD_ysize_2k}, -- t
		[83]  = {117,  MPCD_xsize_2k, MPCD_ysize_2k}, -- u
		[84]  = {118,  MPCD_xsize_2k, MPCD_ysize_2k}, -- v
		[85]  = {119,  MPCD_xsize_2k, MPCD_ysize_2k}, -- w
		[86]  = {120,  MPCD_xsize_2k, MPCD_ysize_2k}, -- x
		[87]  = {121,  MPCD_xsize_2k, MPCD_ysize_2k}, -- y
		[88]  = {122,  MPCD_xsize_2k, MPCD_ysize_2k}, -- z
		[89]  = {91,  MPCD_xsize_2k, MPCD_ysize_2k}, -- [
		[90]  = {93,  MPCD_xsize_2k, MPCD_ysize_2k}, -- ] 
		[91]  = {124, MPCD_xsize_2k, MPCD_ysize_2k}, -- | == ¦
		[92]  = {38,  MPCD_xsize_2k, MPCD_ysize_2k}, -- & == +- 
		[93]  = {59,  MPCD_xsize_2k, MPCD_ysize_2k}, -- ; == ° 
		[94]  = {95,  MPCD_xsize_2k, MPCD_ysize_2k}, -- _
		[95]  = {37,  MPCD_xsize_2k, MPCD_ysize_2k},-- %
		[96]  = {24,  MPCD_xsize_2k, MPCD_ysize_2k},-- alpha α
	}
}

    fonts = {}
    fonts["font_kneeboard"]			= {fontdescription_cmn["font_general_loc"], 10, {0,0,0,255}}
    fonts["font_kneeboard_hint"]	= {fontdescription_cmn["font_general_loc"], 10, {255,0,0,255}}
	fonts["mpcd_font_base"]			= {fontdescription["font_MPCD"], 10, materials["TEST_COLOR"]}
	fonts["hud_font_base"]			= {fontdescription["font_HUD"], 10, materials["HUD_DAY_COLOR"] }
	fonts["EADI_font"]				= {fontdescription["font_EADI"], 10, {200,200,200,255} }
	fonts["EADI_font_black"]		= {fontdescription["font_EADI"], 10, {0,0,0,255} }
	fonts["LCD_font_white"]			= {fontdescription["font_LCD"], 10, {200,200,200,255} }
	fonts["EHSI_font_white"]		= {fontdescription["font_EADI"], 10, {200,200,200,255} }
	fonts["EHSI_font_green"]		= {fontdescription["font_EADI"], 10, {4,239,113,255} }
	fonts["EHSI_font_purple"]		= {fontdescription["font_EADI"], 10, {217,40,113,255} }
	fonts["BS430_font_white"]		= {fontdescription["font_Pixel"], 10, {200,200,200,255} }

-- force preload resources to avoid freeze on start (list of texture files)
--[[
preload_texture =
{
}
--]]