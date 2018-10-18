
if SERVER then
	AddCSLuaFile()
elseif CLIENT then
	-- hook.Add("InitPostEntity", "InitPHud", function()
		local function ShowDraw(name)
			return hook.Call("HUDShouldDraw", GM, name)
		end

		surface.CreateFont("PHudSmallText", {font = "Arial", size = 13, weight = 500})
		surface.CreateFont("PHudText", {font = "Arial", size = 18, weight = 1000})
		surface.CreateFont("PHudTitle", {font = "Arial", size = 22, weight = 600})

		PHud = {}

		PHud.EnableHUD = {
			"PHudUndoList",
			"PHudHealth",
			"PHudArmor"
		}

		PHud.DisableHUD = {
		  	"CHudHealth",
		  	"CHudBattery"
		--	"CHudAmmo"
		}

		PHud.UndoList = {}
		PHud.UndoList.PosX, PHud.UndoList.PosY = 36, ScrH() - 80
		PHud.UndoList.Interval = -22
		PHud.UndoList.Margin = 3
		PHud.UndoList.Number = 5
		PHud.UndoList.BackgroundColor = Color(0,0,0,75)
		PHud.UndoList.TextColor = Color(255,255,255,255)

		PHud.Health = {}
		PHud.Health.PosX, PHud.Health.PosY = 36, ScrH() - 58
		PHud.Health.BarWide = 250
		PHud.Health.BarPosX = 75
		PHud.Health.Margin = 3
		PHud.Health.LineTall = 3
		PHud.Health.TitleColor = Color(255,255,255,255)
		PHud.Health.BackgroundColor = Color(0, 0, 0, 75)
		PHud.Health.BarBackgroundColor = Color(0, 0, 0, 125)
		PHud.Health.BarColor = Color(255, 255, 255, 255)
		PHud.Health.InsideBarColor = Color(75,75,75,255)

		PHud.Armor = {}
		PHud.Armor.PosX, PHud.Armor.PosY = 36, ScrH()
		PHud.Armor.BarWide = 250
		PHud.Armor.BarPosX = 75
		PHud.Armor.Margin = 3
		PHud.Armor.LineTall = 3
		PHud.Armor.TitleColor = Color(255,255,255,255)
		PHud.Armor.BackgroundColor = Color(0, 0, 0, 75)
		PHud.Armor.BarBackgroundColor = Color(0, 0, 0, 125)
		PHud.Armor.BarColor = Color(255, 255, 255, 255)
		PHud.Armor.InsideBarColor = Color(75,75,75,255)

		local smooth = {}

		----------------------
		--UndoList
		----------------------
		function PHud.drawUndoList()
			local undotab = undo.GetTable()

			local ypos = PHud.UndoList.PosY - 31 * smooth.armorshow

			for i = 1, math.min(PHud.UndoList.Number, #undotab) do
				local boxy = ypos + PHud.UndoList.Interval*(i-1)
				local text = "[" .. undotab[i].Key .. "]: " .. undotab[i].Name

				surface.SetFont("PHudSmallText")
				local textx, texty = surface.GetTextSize(text)

				draw.RoundedBox(0, PHud.UndoList.PosX, boxy, textx + PHud.UndoList.Margin*2, texty + PHud.UndoList.Margin*2, PHud.UndoList.BackgroundColor)

				surface.SetTextPos(PHud.UndoList.PosX + PHud.UndoList.Margin, boxy + PHud.UndoList.Margin)
				surface.SetTextColor(PHud.UndoList.TextColor)
				surface.DrawText(text)
			end
		end

		----------------------
		--Health
		----------------------
		smooth.health = 0  -- LocalPlayer():Health()
		smooth.god = 0 -- LocalPlayer():HasGodMode() and 1 or 0
		function PHud.drawHealth()
			local ypos = PHud.Health.PosY - 31 * smooth.armorshow

			local health = math.max(LocalPlayer():Health(), 0)
			local healthdisplay = health

			local isgod = LocalPlayer():HasGodMode() and 1 or 0
			smooth.god = smooth.god + (isgod - smooth.god)/20

			surface.SetFont("PHudText")
			local godx = surface.GetTextSize("God")

			local testatx = PHud.Health.PosX + PHud.Health.BarPosX + PHud.Health.Margin*3 + (PHud.Health.BarWide/2 - godx/2 - PHud.Health.Margin)*(smooth.god)

			if LocalPlayer():HasGodMode() then
				health = 100 + math.max(LocalPlayer():Health() - 100, 0)*(1-smooth.god)
				healthdisplay = "God"
			end


			surface.SetFont("PHudTitle")
			local textx, texty = surface.GetTextSize("Health: ")

			smooth.health = smooth.health + (health-smooth.health)/18

			draw.RoundedBox(0, PHud.Health.PosX, ypos, PHud.Health.BarPosX + PHud.Health.Margin*3 + PHud.Health.BarWide, texty + PHud.Health.Margin*2, PHud.Health.BackgroundColor)

			surface.SetTextPos(PHud.Health.PosX + PHud.Health.Margin, ypos + PHud.Health.Margin)
			surface.SetTextColor(PHud.Health.TitleColor)
			surface.DrawText("Health: ")

			surface.SetFont("PHudText")
			local texthx, texthy = surface.GetTextSize(health)
			local healthbarmin = texthx + PHud.Health.Margin*2

			draw.RoundedBox(0, PHud.Health.PosX + PHud.Health.BarPosX + PHud.Health.Margin*2, ypos + PHud.Health.Margin, PHud.Health.BarWide, texty, PHud.Health.BarBackgroundColor)
			draw.RoundedBox(0, PHud.Health.PosX + PHud.Health.BarPosX + PHud.Health.Margin*2, ypos + PHud.Health.Margin, math.max(PHud.Health.BarWide*math.min(smooth.health/100, 1), healthbarmin), texty, PHud.Health.BarColor)

			surface.SetTextPos(testatx, ypos + PHud.Health.Margin + texty/2 - texthy/2)
			surface.SetTextColor(PHud.Health.InsideBarColor)
			surface.DrawText(healthdisplay)

			if (1-smooth.god) > 0.001  then
				local m = math.max(10^(math.floor(math.log10(smooth.health))-1),10)

				for i = 1, math.floor(smooth.health/m) do
					local p = PHud.Health.BarWide/math.max(smooth.health, 100)*m*i
					local ex = 1
					if i%10 == 0 then
						ex = 2
					end
					draw.RoundedBox(0, PHud.Health.PosX + PHud.Health.BarPosX + PHud.Health.Margin*2 + p, ypos + PHud.Health.Margin + texty - PHud.Health.LineTall*ex*(1-smooth.god), 1, PHud.Health.LineTall*ex*(1-smooth.god), PHud.Health.InsideBarColor)
					draw.RoundedBox(0, PHud.Health.PosX + PHud.Health.BarPosX + PHud.Health.Margin*2 + p, ypos + PHud.Health.Margin, 1, PHud.Health.LineTall*ex*(1-smooth.god), PHud.Health.InsideBarColor)
				end
			end
		end

		----------------------
		--Armor---------------
		----------------------
		smooth.armor = 0
		smooth.armorshow = 0
		function PHud.drawArmor()
			local armor = math.max(LocalPlayer():Armor(), 0)
			smooth.armor = smooth.armor + (armor-smooth.armor)/18
			smooth.armorshow = smooth.armorshow + ((smooth.armor > 0.2 and 1 or 0) - smooth.armorshow)/10

			if smooth.armorshow > 0.2 then
				local ypos = PHud.Armor.PosY - 58 * smooth.armorshow
				PHud.ArmorHudActive = true
				surface.SetFont("PHudTitle")
				local textx, texty = surface.GetTextSize("Armor: ")

				draw.RoundedBox(0, PHud.Armor.PosX, ypos, PHud.Armor.BarPosX + PHud.Armor.Margin*3 + PHud.Armor.BarWide, texty + PHud.Armor.Margin*2, PHud.Armor.BackgroundColor)

				surface.SetTextPos(PHud.Armor.PosX + PHud.Armor.Margin, ypos + PHud.Armor.Margin)
				surface.SetTextColor(PHud.Armor.TitleColor)
				surface.DrawText("Armor: ")

				surface.SetFont("PHudText")
				local textAx, textAy = surface.GetTextSize(armor)
				local armorbarmin = textAx + PHud.Armor.Margin*2

				draw.RoundedBox(0, PHud.Armor.PosX + PHud.Armor.BarPosX + PHud.Armor.Margin*2, ypos + PHud.Armor.Margin, PHud.Armor.BarWide, texty, PHud.Armor.BarBackgroundColor)
				draw.RoundedBox(0, PHud.Armor.PosX + PHud.Armor.BarPosX + PHud.Armor.Margin*2, ypos + PHud.Armor.Margin, math.max(PHud.Armor.BarWide*math.min(smooth.armor/100, 1), armorbarmin), texty, PHud.Armor.BarColor)

				surface.SetTextPos(PHud.Armor.PosX + PHud.Armor.BarPosX + PHud.Armor.Margin*3, ypos + PHud.Armor.Margin + texty/2 - textAy/2)
				surface.SetTextColor(PHud.Armor.InsideBarColor)
				surface.DrawText(armor)

				local m = math.max(10^(math.floor(math.log10(smooth.armor))-1),10)

				for i = 1, math.floor(smooth.armor/m) do
					local p = PHud.Armor.BarWide/math.max(smooth.armor, 100)*m*i
					local ex = 1
					if i%10 == 0 then
						ex = 2
					end
					draw.RoundedBox(0, PHud.Armor.PosX + PHud.Armor.BarPosX + PHud.Armor.Margin*2 + p, ypos + PHud.Armor.Margin + texty - PHud.Armor.LineTall*ex, 1, PHud.Armor.LineTall*ex, PHud.Armor.InsideBarColor)
					draw.RoundedBox(0, PHud.Armor.PosX + PHud.Armor.BarPosX + PHud.Armor.Margin*2 + p, ypos + PHud.Armor.Margin, 1, PHud.Armor.LineTall*ex, PHud.Armor.InsideBarColor)
				end
			else
				PHud.ArmorHudActive = false
			end
		end



		hook.Add("HUDPaint", "PHud", function()
			if ShowDraw("PHudUndoList") then
				PHud.drawUndoList()
			end

			if ShowDraw("PHudHealth") then
				PHud.drawHealth()
			end

			if ShowDraw("PHudArmor") then
				PHud.drawArmor()
			end
		end)



		hook.Add("HUDShouldDraw","PHud",function( name )
			for _,v in pairs(PHud.EnableHUD) do
				if name == v then
					return true
				end
			end

			for _,v in pairs(PHud.DisableHUD) do
				if name == v then
					return false
				end
			end
		end)

		hook.Call("InitPostPHud")
	-- end)
end
