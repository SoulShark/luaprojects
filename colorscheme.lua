--[[
function Initialize()
    if not file.IsDir("hexcolor", "DATA") then
        file.CreateDir("hexcolor", "DATA")
    end
end

hook.Add("Initialize", "InitializeTime", Initialize)

function LoadPlayer(ply)
    local hexcolorchoice = "hexcolor/" .. ply:SteamID() .. ".txt"

    if file.Exists(hexcolorchoice, "DATA") then
        local getcurrentcolor = file.Read(hexcolorchoice, "DATA")
        currentcolor = tostring(getcurrentcolor)
    else
        file.Write(hexcolorchoice, "255,255,255")
        currentstatus = "255,255,255"
    end
end

hook.Add("PlayerInitialSpawn", "LoadPlayerTime", LoadPlayer)

timer.Create("Calculatestatus", 5, 0, function()
    for k, v in pairs(player.GetAll()) do
        v:SetNWInt("updated_color", currentstatus)
    end
end)

function Saveplayers(ply)
    local hexcolorchoice = "hexcolor/" .. ply:SteamID() .. ".txt"
    file.Write(hexcolorchoice, currentstatus)
end

hook.Add("PlayerDisconnected", "SavePlayerColor", SavePlayer)
]]
--
--
--
--
--
--
if SERVER then
    AddCSLuaFile()
    util.AddNetworkString("OpenMixer")

    hook.Add("PlayerSay", "ColorMixerOpen", function(ply, text, public)
        local text = string.lower(text)

        if (string.sub(text, 1, 8) == "!hvcolor") then
            net.Start("OpenMixer")
            net.Send(ply)

            return false
        end
    end)
end

if CLIENT then
    -- Declare our convars and variables
    local hv_color = CreateClientConVar("hex_color", "255, 255, 0", true, true)
    local alpha = 0

    local function GrabColor()
        local coltable = string.Explode(",", hv_color:GetString())
        local newcol = {}

        for k, v in pairs(coltable) do
            v = tonumber(v)

            if v == nil then
                coltable[k] = 0
            end
            -- Fixes missing values
        end

        newcol[1], newcol[2], newcol[3] = coltable[1] or 0, coltable[2] or 0, coltable[3] or 0 -- Fixes missing keys
        -- Returns the finished color

        return Color(newcol[1], newcol[2], newcol[3])
    end

    -- Used for retrieving the console color
    net.Receive("OpenMixer", function(len, ply)
        -- Creating the color mixer panel
        local Frame = vgui.Create("DFrame")
        Frame:SetTitle("Hex vault Color Option")
        Frame:SetSize(300, 400)
        Frame:Center()
        Frame:MakePopup()
        local colMix = vgui.Create("DColorMixer", Frame)
        colMix:Dock(TOP)
        colMix:SetPalette(true)
        colMix:SetAlphaBar(false)
        colMix:SetWangs(false)
        colMix:SetColor(GrabColor()) -- Sets the default color to your current one
        local Butt = vgui.Create("DButton", Frame)
        Butt:SetText("Save Color")
        Butt:SetSize(150, 70)
        Butt:SetPos(70, 290)

        Butt.DoClick = function(Butt)
            local colors = colMix:GetColor()
            local colstring = tostring(colors.r .. ", " .. colors.g .. ", " .. colors.b)
            RunConsoleCommand("hex_color", colstring)
        end
    end)
    -- Concatenate your choices together and set the color
    -- Receive the server message
else
    return
end

if SERVER then
    hook.Add("PlayerSay", "requestcolordebug", function(ply, text)
        local text = string.lower(text)

        if text == "!colordebug" then
            print(GetConVar("hex_color"):GetString())
        end
    end)
else
    return
end
