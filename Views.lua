ViewSettings = {
	Cockpit = {
	[1] = {-- player slot 1
		CockpitLocalPoint = { 2.00, 0.2553,-0.2576},--with dummy at 0,0,0, 3rd is across, 2nd is up/down, 1st is forward backward 
		CameraViewAngleLimits  = {20.000000,140.000000},
		CameraAngleRestriction = {false	   ,90.000000,0.500000},
		CameraAngleLimits      = {200,-80.000000,110.000000},--Kopf drehen = links rechts,runter,hoch
		EyePoint               = {0 ,0 ,0},-- { 2.96   , 1.4653 , -0.2576},
		limits_6DOF            = {x = {-0.050000,0.4500000},y ={-0.300000,0.100000},z = {-0.220000,0.220000},roll = 90.000000}, --Bewegen = hinten vorne,oben unten,links rechts
		ShoulderSize		   = 0.2,-- bewegt K�rper, wenn Azimuth Wert mehr als 90 Grad
		Allow360rotation	   = false,
		},
	[2] = {-- player slot 1
		CockpitLocalPoint = { 2.11, 0.2153, 0.2576},-- with dummy at 0,0,0, 3rd is across, 2nd is up/down, 1st is forward backward 
		CameraViewAngleLimits  = {20.000000,140.000000},
		CameraAngleRestriction = {false	   ,90.000000,0.500000},
		CameraAngleLimits      = {200,-80.000000,110.000000},--Kopf drehen = links rechts,runter,hoch
		EyePoint               = {0 ,0 ,0},-- { 2.96   , 1.4653 , -0.2576},
		limits_6DOF            = {x = {-0.050000,0.4500000},y ={-0.300000,0.100000},z = {-0.220000,0.220000},roll = 90.000000}, --Bewegen = hinten vorne,oben unten,links rechts
		ShoulderSize		   = 0.2,-- bewegt K�rper, wenn Azimuth Wert mehr als 90 Grad
		Allow360rotation	   = false,
		},	
	}, -- Cockpit 
	Chase = {
		LocalPoint      = {2.532000,1.800000,0.000000},
		AnglesDefault   = {0.000000,0.000000},
	}, -- Chase 
	Arcade = {
		LocalPoint      = {-8.390000,-1.104000,0.000000}, --{-13.790000,6.204000,0.000000},
		AnglesDefault   = {0.000000,-8.000000},
	}, -- Arcade 
}

SnapViews = {
[1] = {-- player slot 1
	[1] = {--LWin + Num0 : Snap View 0
		viewAngle = 60.000000,--FOV
		hAngle	 = 0.000000,
		vAngle	 = 0.000000,
		x_trans	 = 0.000000,
		y_trans	 = 0.000000,
		z_trans	 = 0.000000,
		rollAngle = 0.000000,
	},
	[2] = {--LWin + Num1 : Snap View 1
		viewAngle = 60.000000,--FOV
		hAngle	 = 0.000000,
		vAngle	 = 0.000000,
		x_trans	 = 0.000000,
		y_trans	 = 0.000000,
		z_trans	 = 0.000000,
		rollAngle = 0.000000,
	},
	[3] = {--LWin + Num2 : Snap View 2
		viewAngle = 60.000000,--FOV
		hAngle	 = 0.000000,
		vAngle	 = 0.000000,
		x_trans	 = 0.000000,
		y_trans	 = 0.000000,
		z_trans	 = 0.000000,
		rollAngle = 0.000000,
	},
	[4] = {--LWin + Num3 : Snap View 3
		viewAngle = 60.000000,--FOV
		hAngle	 = 0.000000,
		vAngle	 = 0.000000,
		x_trans	 = 0.000000,
		y_trans	 = 0.000000,
		z_trans	 = 0.000000,
		rollAngle = 0.000000,
	},
	[5] = {--LWin + Num4 : Snap View 4
		viewAngle = 60.000000,--FOV
		hAngle	 = 0.000000,
		vAngle	 = 0.000000,
		x_trans	 = 0.000000,
		y_trans	 = 0.000000,
		z_trans	 = 0.000000,
		rollAngle = 0.000000,
	},
	[6] = {--LWin + Num5 : Snap View 5
		viewAngle = 60.000000,--FOV
		hAngle	 = 0.000000,
		vAngle	 = 0.000000,
		x_trans	 = 0.000000,
		y_trans	 = 0.000000,
		z_trans	 = 0.000000,
		rollAngle = 0.000000,
	},
	[7] = {--LWin + Num6 : Snap View 6
		viewAngle = 60.000000,--FOV
		hAngle	 = 0.000000,
		vAngle	 = 0.000000,
		x_trans	 = 0.000000,
		y_trans	 = 0.000000,
		z_trans	 = 0.000000,
		rollAngle = 0.000000,
	},
	[8] = {--LWin + Num7 : Snap View 7
		viewAngle = 60.000000,--FOV
		hAngle	 = 0.000000,
		vAngle	 = 0.000000,
		x_trans	 = 0.000000,
		y_trans	 = 0.000000,
		z_trans	 = 0.000000,
		rollAngle = 0.000000,
	},
	[9] = {--LWin + Num8 : Snap View 8
		viewAngle = 60.000000,--FOV
		hAngle	 = 0.000000,
		vAngle	 = 0.000000,
		x_trans	 = 0.000000,
		y_trans	 = 0.000000,
		z_trans	 = 0.000000,
		rollAngle = 0.000000,
	},
	[10] = {--LWin + Num9 : Snap View 9
		viewAngle = 60.000000,--FOV
		hAngle	 = 0.000000,
		vAngle	 = 0.000000,
		x_trans	 = 0.000000,
		y_trans	 = 0.000000,
		z_trans	 = 0.000000,
		rollAngle = 0.000000,
	},
	[11] = {--look at left  mirror
		viewAngle = 60.000000,--FOV
		hAngle	 = 0.000000,
		vAngle	 = 0.000000,
		x_trans	 = 0.000000,
		y_trans	 = 0.000000,
		z_trans	 = 0.000000,
		rollAngle = 0.000000,
	},
	[12] = {--look at right mirror
		viewAngle = 60.000000,--FOV
		hAngle	 = 0.000000,
		vAngle	 = 0.000000,
		x_trans	 = 0.000000,
		y_trans	 = 0.000000,
		z_trans	 = 0.000000,
		rollAngle = 0.000000,
	},
	[13] = {--default view
		viewAngle = 88.727844,--FOV
		hAngle	 = 0.000000,
		vAngle	 = -8.414850,
		x_trans	 = 0.1,
		y_trans	 = 0,
		z_trans	 = 0,
		rollAngle = 0.000000,
	},
},
}