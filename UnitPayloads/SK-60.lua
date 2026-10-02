local unitPayloads = {
    ["name"] = "SK-60",
    ["payloads"] = {
        [1] = {
            ["name"] = "HE Rockets x12 (2 per wing pylon)",
            ["pylons"] = {
                [1] = { ["CLSID"] = "{d694b359-e7a8-4909-88d4-7100b77afd11}", ["num"] = 1 },-- 135mm rocket x2
                [2] = { ["CLSID"] = "{d694b359-e7a8-4909-88d4-7100b77afd11}", ["num"] = 2 },-- 135mm rocket x2
                [3] = { ["CLSID"] = "{d694b359-e7a8-4909-88d4-7100b77afd11}", ["num"] = 3 },-- 135mm rocket x2
                [4] = { ["CLSID"] = "{d694b359-e7a8-4909-88d4-7100b77afd11}", ["num"] = 4 },-- 135mm rocket x2
                [5] = { ["CLSID"] = "{d694b359-e7a8-4909-88d4-7100b77afd11}", ["num"] = 5 },-- 135mm rocket x2
                [6] = { ["CLSID"] = "{d694b359-e7a8-4909-88d4-7100b77afd11}", ["num"] = 6 },-- 135mm rocket x2
            },
            ["tasks"] = {
                [1] = 32,
            },
        },
        [2] = {
            ["name"] = "HE/HEAT Mix (2+1+1)",
            ["pylons"] = {
                [1] = { ["CLSID"] = "{d694b359-e7a8-4909-88d4-7100b77afd12}", ["num"] = 1 },-- 145mm rocket
                [2] = { ["CLSID"] = "{d694b359-e7a8-4909-88d4-7100b77afd12}", ["num"] = 2 },-- 145mm rocket
                [3] = { ["CLSID"] = "{d694b359-e7a8-4909-88d4-7100b77afd11}", ["num"] = 3 },-- 135mm rocket x2
                [4] = { ["CLSID"] = "{d694b359-e7a8-4909-88d4-7100b77afd11}", ["num"] = 4 },-- 135mm rocket x2
                [5] = { ["CLSID"] = "{d694b359-e7a8-4909-88d4-7100b77afd12}", ["num"] = 5 },-- 145mm rocket
                [6] = { ["CLSID"] = "{d694b359-e7a8-4909-88d4-7100b77afd12}", ["num"] = 6 },-- 145mm rocket
            },
            ["tasks"] = {
                [1] = 32,
            },
        },
        [3] = {
            ["name"] = "HEAT Rockets x6",
            ["pylons"] = {
                [1] = { ["CLSID"] = "{d694b359-e7a8-4909-88d4-7100b77afd12}", ["num"] = 1 },-- 145mm rocket
                [2] = { ["CLSID"] = "{d694b359-e7a8-4909-88d4-7100b77afd12}", ["num"] = 2 },-- 145mm rocket
                [3] = { ["CLSID"] = "{d694b359-e7a8-4909-88d4-7100b77afd12}", ["num"] = 3 },-- 145mm rocket
                [4] = { ["CLSID"] = "{d694b359-e7a8-4909-88d4-7100b77afd12}", ["num"] = 4 },-- 145mm rocket
                [5] = { ["CLSID"] = "{d694b359-e7a8-4909-88d4-7100b77afd12}", ["num"] = 5 },-- 145mm rocket
                [6] = { ["CLSID"] = "{d694b359-e7a8-4909-88d4-7100b77afd12}", ["num"] = 6 },-- 145mm rocket
            },
            ["tasks"] = {
                [1] = 32,
            },
        },
        [4] = {
            ["name"] = "AKAN Gunpods (Middle Wing Pylons)",
            ["pylons"] = {
                [1] = { ["CLSID"] = "{5d5aa063-a002-4de8-8a89-6eda1e80ee7b}", ["num"] = 2 },-- AKAN
                [2] = { ["CLSID"] = "{5d5aa063-a002-4de8-8a89-6eda1e80ee7b}", ["num"] = 5 },-- AKAN
            },
            ["tasks"] = {
                [1] = 32,
            },
        },
        [5] = {
            ["name"] = "Smoke Pods WHITE",
            ["pylons"] = {
                [1] = { ["CLSID"] = "{3d7bfa20-fefe-4642-ba1f-380d5ae4f9c1}", ["num"] = 2 },-- Smokepod WHITE
                [2] = { ["CLSID"] = "{3d7bfa20-fefe-4642-ba1f-380d5ae4f9c1}", ["num"] = 5 },-- Smokepod WHITE
            },
            ["tasks"] = {
                [1] = 17,
            },
        },
        [6] = {
            ["name"] = "Smoke Pods BLUE",
            ["pylons"] = {
                [1] = { ["CLSID"] = "{3d7bfa20-fefe-4642-ba1f-380d5ae4f9c6}", ["num"] = 2 },-- Smokepod BLUE
                [2] = { ["CLSID"] = "{3d7bfa20-fefe-4642-ba1f-380d5ae4f9c6}", ["num"] = 5 },-- Smokepod BLUE
            },
            ["tasks"] = {
                [1] = 17,
            },
        },
        [7] = {
            ["name"] = "Smoke Pods YELLOW",
            ["pylons"] = {
                [1] = { ["CLSID"] = "{3d7bfa20-fefe-4642-ba1f-380d5ae4f9c3}", ["num"] = 2 },-- Smokepod YELLOW
                [2] = { ["CLSID"] = "{3d7bfa20-fefe-4642-ba1f-380d5ae4f9c3}", ["num"] = 5 },-- Smokepod YELLOW
            },
            ["tasks"] = {
                [1] = 17,
            },
        },
        [8] = {
            ["name"] = "60mm ÖRAK Practice Rockets x4",
            ["pylons"] = {
                [1] = { ["CLSID"] = "{d694b359-e7a8-4909-88d4-7100b77afd60}", ["num"] = 1 },-- 60mm ÖRAK m/70 practice rocket
                [2] = { ["CLSID"] = "{d694b359-e7a8-4909-88d4-7100b77afd60}", ["num"] = 3 },-- 60mm ÖRAK m/70 practice rocket
                [3] = { ["CLSID"] = "{d694b359-e7a8-4909-88d4-7100b77afd60}", ["num"] = 4 },-- 60mm ÖRAK m/70 practice rocket
                [4] = { ["CLSID"] = "{d694b359-e7a8-4909-88d4-7100b77afd60}", ["num"] = 6 },-- 60mm ÖRAK m/70 practice rocket
            },
            ["tasks"] = {
                [1] = 32,
            },
        },
        [9] = {
            ["name"] = "63mm SÖRAK Smoke Practice Rockets x4",
            ["pylons"] = {
                [1] = { ["CLSID"] = "{d694b359-e7a8-4909-88d4-7100b77afd63}", ["num"] = 1 },-- 63mm SÖRAK m/70 smoke practice rocket
                [2] = { ["CLSID"] = "{d694b359-e7a8-4909-88d4-7100b77afd63}", ["num"] = 3 },-- 63mm SÖRAK m/70 smoke practice rocket
                [3] = { ["CLSID"] = "{d694b359-e7a8-4909-88d4-7100b77afd63}", ["num"] = 4 },-- 63mm SÖRAK m/70 smoke practice rocket
                [4] = { ["CLSID"] = "{d694b359-e7a8-4909-88d4-7100b77afd63}", ["num"] = 6 },-- 63mm SÖRAK m/70 smoke practice rocket
            },
            ["tasks"] = {
                [1] = 32,
            },
        },
    },
    ["tasks"] = {
        [1] = 17,
        [2] = 32,
    },
}

return unitPayloads
