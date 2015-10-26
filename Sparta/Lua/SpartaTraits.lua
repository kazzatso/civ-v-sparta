-- Lua Script1
-- Author: Anders
-- DateCreated: 10/17/2015 2:23:13 PM
--------------------------------------------------------------	

function SpartaTraitCapital(x, y, oldPop, newPop)
	local plot = Map.GetPlot(x, y);
	local city = plot:GetPlotCity();
	local player = Players[city:GetOwner()];

	if (city:IsCapital() and player:GetCivilizationType() == GameInfoTypes["CIVILIZATION_SPARTA"]) then
		if (newPop > oldPop and newPop >= city:GetHighestPopulation() and player:GetGreatGeneralsCreated() > 0) then
			local unit = player:InitUnit(getBestUnitForPlayer(player, city), x, y);
			unit:SetExperience(city:GetDomainFreeExperience(unit:GetDomainType()));

			local title = "New Unit in " .. city:GetName() .. "!";
			local text = "You have received a new " .. unit:GetName() .. " at your capital.";
			player:AddNotification(NotificationTypes["NOTIFICATION_UNIT_PROMOTION"], text, title, unit:GetX(), unit:GetY(), unit:GetUnitType());
		end
	end
end

function SpartaTraitCaptureCity(hexPos, oldPlayer, cityId, newPlayer)
	if (math.random() < 0.33) then
		local player = Players[newPlayer];
		local capital = player:GetCapitalCity();
		
		capital:ChangePopulation(1, true);
		
		local title = capital:GetName() .. " has Grown!";
		local text = "The City of " .. capital:GetName() .. " now has " .. capital:GetPopulation() .. " [ICON_CITIZEN] Citizens! The new Citizen will automatically work the land near the City for additional [ICON_FOOD] Food, [ICON_PRODUCTION] Production or [ICON_GOLD] Gold.";
		player:AddNotification(NotificationTypes["NOTIFICATION_CITY_GROWTH"], text, title, capital:GetX(), capital:GetY());
	end
end

function SpartaHoplitePromotions(player)
	for unit in player:Units() do
		if (unit:GetUnitType() == GameInfoTypes["UNIT_SPARTAN_HOPLITE"]) then
			if (unit:IsFriendlyUnitAdjacent(true)) then
				unit:SetHasPromotion(GameInfoTypes["PROMOTION_ADD_A_STEP_FORWARD"], true);
				unit:SetHasPromotion(GameInfoTypes["PROMOTION_MOLON_LABE"], false);
			else
				unit:SetHasPromotion(GameInfoTypes["PROMOTION_ADD_A_STEP_FORWARD"], false);
				unit:SetHasPromotion(GameInfoTypes["PROMOTION_MOLON_LABE"], true);
			end
		else
			unit:SetHasPromotion(GameInfoTypes["PROMOTION_ADD_A_STEP_FORWARD"], false);
			unit:SetHasPromotion(GameInfoTypes["PROMOTION_MOLON_LABE"], false);
		end
	end
end

function SpartaUnitTrained(playerId, unitId)
	if (Players[playerId]:GetUnitByID(unitId):IsCombatUnit()) then
		SpartaHoplitePromotions(Players[playerId]);
	end
end

function SpartaMoveUnit(playerId, unitId, x, y)
	if (Players[playerId]:GetCivilizationType() == GameInfoTypes["CIVILIZATION_SPARTA"]) then
		SpartaHoplitePromotions(Players[playerId]);
	end
end

function SpartaUnitKilled(killerId, killeeId, unitType)
	if (Players[killeeId]:GetCivilizationType() == GameInfoTypes["CIVILIZATION_SPARTA"]) then
		SpartaHoplitePromotions(Players[killeeId]);
	end
end

function getCivSpecificUnit(player, unitClass)
	local unitType = nil;
	local civType = GameInfo.Civilizations[player:GetCivilizationType()].Type;

	print(civType);
	print(unitClass);

	for override in GameInfo.Civilization_UnitClassOverrides{CivilizationType = civType, UnitClassType = unitClass.Type} do
		unitType = override.UnitType;
		break;
	end

	-- If we didn't get anything, yield to be returned the default UnitType for the UnitClass.
	if (unitType == nil) then
		unitType = GameInfo.UnitClasses[unitClass.ID].DefaultUnit;
	end

	-- Give whatever function called this the UnitType we yielded.
	print("Got Civ-Specific UnitType: " .. unitType .. ".\n");

	return unitType;
end

function getBestUnitForPlayer(player, city)
	local possibleUnitClasses = {
        GameInfo.UnitClasses.UNITCLASS_MECH,
        GameInfo.UnitClasses.UNITCLASS_MECHANIZED_INFANTRY,
        GameInfo.UnitClasses.UNITCLASS_INFANTRY,
        GameInfo.UnitClasses.UNITCLASS_GREAT_WAR_INFANTRY,
        GameInfo.UnitClasses.UNITCLASS_RIFLEMAN,
        GameInfo.UnitClasses.UNITCLASS_MUSKETMAN,
        GameInfo.UnitClasses.UNITCLASS_LONGSWORDSMAN,
        GameInfo.UnitClasses.UNITCLASS_PIKEMAN,
        GameInfo.UnitClasses.UNITCLASS_SWORDSMAN,
        GameInfo.UnitClasses.UNITCLASS_SPEARMAN,
        GameInfo.UnitClasses.UNITCLASS_WARRIOR
    };

	for _, unitClass in ipairs(possibleUnitClasses) do -- Thanks whoward69
		local unit = GameInfoTypes[getCivSpecificUnit(player, unitClass)];
		if (city:CanTrain(unit)) then
			return unit;
		end
	end

	return GameInfoTypes["UNIT_WARRIOR"];
end

GameEvents.SetPopulation.Add(SpartaTraitCapital);
Events.SerialEventCityCaptured.Add(SpartaTraitCaptureCity);
Events.SerialEventUnitCreated.Add(SpartaUnitTrained);
GameEvents.UnitKilledInCombat.Add(SpartaUnitKilled);
GameEvents.UnitSetXY.Add(SpartaMoveUnit);

print("My Lua traits are loaded.");
	