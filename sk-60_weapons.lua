function declear_smoke_pod(_name, _color, _red, _green, _blue, _alpha, uuid)
	local data = {
		category		= CAT_PODS,
		CLSID			= "{"..uuid.."}",
		Picture	        = "smokePod.png",
		PictureBlendColor = _color,		
		displayName		= _("Team60 ".._name.." Smoke Pod"),
		
		attribute	=	{4,	15,	50,	WSTYPE_PLACEHOLDER},			
		Smoke  = {
			alpha = _alpha,
			r  = _red,
			g  = _green,
			b  = _blue,
			dx = -1.6,
			dy = -0.05
		},
		
		shape_table_data = 
		{
			{
				name 	= "TEAM60-SMOKE-POD",
				file	= "TEAM60-SMOKE-POD";
				life	= 1;
				fire	= {0, 1};
				username= "{"..uuid.."}";
				index	= WSTYPE_PLACEHOLDER;
			},
		},
		Weight			= 155,
		Count 			= 1,
		Cx_pil			= 0.0005,
		Elements		={{
							ShapeName	=	"TEAM60-SMOKE-POD", 
							Position	=	{0, 0, 0},
						}}
	}

    declare_loadout(data)
end

function declear_smoke_nozzle(_name, _color, _red, _green, _blue, _alpha, uuid)
	local data = {
		category		= CAT_PODS,
		CLSID			= "{"..uuid.."}",
		Picture	        = "Nozzlesmoke.png",
		PictureBlendColor = _color,		
		displayName		= _("Team60 ".._name.." Nozzle Smoke"),
		
		attribute	=	{4,	15,	50,	WSTYPE_PLACEHOLDER},			
		Smoke  = {
			alpha = _alpha,
			r  = _red,
			g  = _green,
			b  = _blue,
			dx = -1.6,
			dy = -0.05
		},
		
		shape_table_data = 
		{
			{
				name 	= "TEAM60",
				file	= "TEAM60";
				life	= 1;
				fire	= {0, 1};
				username= "{"..uuid.."}";
				index	= WSTYPE_PLACEHOLDER;
			},
		},
		Weight			= 1,
		Count 			= 1,
		Cx_pil			= 0,
		Elements		={{
                            ShapeName	=	"TEAM60-SMOKE", 
							Position	=	{0, 0, 0},
						}}
	}

    declare_loadout(data)
end

declear_smoke_pod('WHITE', '0xffffffff', 255, 255, 255, 200, '3d7bfa20-fefe-4642-ba1f-380d5ae4f9c1')
declear_smoke_pod('RED', '0xcb1b45ff', 255, 30, 60, 200, '3d7bfa20-fefe-4642-ba1f-380d5ae4f9c2')
declear_smoke_pod('YELLOW', '0xffc408ff', 255, 196, 8, 200, '3d7bfa20-fefe-4642-ba1f-380d5ae4f9c3')
declear_smoke_pod('ORANGE', '0xffb11bff', 255, 177, 27, 200, '3d7bfa20-fefe-4642-ba1f-380d5ae4f9c4')
declear_smoke_pod('GREEN', '0x1b813eff', 27, 130, 62, 200, '3d7bfa20-fefe-4642-ba1f-380d5ae4f9c5')
declear_smoke_pod('BLUE', '0x2ea9dfff', 46, 169, 233, 200, '3d7bfa20-fefe-4642-ba1f-380d5ae4f9c6')


declear_smoke_nozzle('WHITE', '0xffffffff', 255, 255, 255, 200, '3d7bfa20-fefe-4642-ba1f-380d5ae4f9d1')
declear_smoke_nozzle('RED', '0xcb1b45ff', 255, 30, 60, 200, '3d7bfa20-fefe-4642-ba1f-380d5ae4f9d2')
declear_smoke_nozzle('YELLOW', '0xffc408ff', 255, 196, 8, 200, '3d7bfa20-fefe-4642-ba1f-380d5ae4f9d3')
declear_smoke_nozzle('ORANGE', '0xffb11bff', 255, 177, 27, 200, '3d7bfa20-fefe-4642-ba1f-380d5ae4f9d4')
declear_smoke_nozzle('GREEN', '0x1b813eff', 27, 130, 62, 200, '3d7bfa20-fefe-4642-ba1f-380d5ae4f9d5')
declear_smoke_nozzle('BLUE', '0x2ea9dfff', 46, 169, 233, 200, '3d7bfa20-fefe-4642-ba1f-380d5ae4f9d6')