--[[
	Description: This file is part of Roulette System (refactored)
	Author: Lyµ
	Discord: Lyµ#8767
	Adaptado para o Canary:  NvSo#4349
]]

local Constants = dofile(DATA_DIRECTORY .. '/scripts/magic_roulette/lib/core/constants.lua')
local Strings = dofile(DATA_DIRECTORY .. '/scripts/magic_roulette/lib/core/strings.lua')
local DatabaseRoulettePlays = dofile(DATA_DIRECTORY .. '/scripts/magic_roulette/lib/database/roulette_plays.lua')
local Functions = dofile(DATA_DIRECTORY .. '/scripts/magic_roulette/lib/core/functions.lua')

local MAX_DROPSET_RATE = 10000

local Slot = {}

function Slot:generatePositions()
	local centerPos = self.centerPosition
	self.positions = {}

	local half = math.floor(self.tilesPerSlot / 2)
	self.startPosition = Position(centerPos.x - half, centerPos.y, centerPos.z)
	self.endPosition = Position(centerPos.x + half, centerPos.y, centerPos.z)

	for i = 0, self.tilesPerSlot - 1 do
		local position = self.startPosition + Position(i, 0, 0)
		local tile = Tile(position)

		if tile then
			self.positions[#self.positions + 1] = position
		end
	end
end

function Slot:generateLeverPosition()
    local LeverPos = self.leverPosition
    local LeverID = self.leverId
    self.leverpositions = {}

    local position = Position(LeverPos.x, LeverPos.y, LeverPos.z)
    local tile = Tile(position)

    if tile then
        local items = tile:getItems()
        for i = 1, #items do
            local item = items[i]
            if item:getId() == LeverID then
                table.insert(self.leverpositions, item)
            end
        end
    end
end

function Slot:clearDummies()
	for _, position in ipairs(self:getPositions()) do
		local tile = Tile(position)
		if tile then
			local dummy = tile:getTopCreature()
			if dummy then
				position:sendMagicEffect(CONST_ME_POFF)
				dummy:remove()
			end
		end
	end
end

function Slot:registerChanceItem(item)
	local rate = item.chance

	if rate < 0.01 or rate > 100 then
		print(Strings.LOAD_CHANCE_MINMAX_WARNING:format(
			item.id
		))
		return false
	end

	for i = 1, (rate / 100) * MAX_DROPSET_RATE do
		self.itemChances[#self.itemChances + 1] = item
	end
end

function Slot:loadChances(id)
	self.itemChances = {}

	for _, item in pairs(self.items) do
		self:registerChanceItem(item)
	end

	local chanceCount = #self.itemChances
	if chanceCount ~= MAX_DROPSET_RATE then
		print(Strings.PRECISE_DROP_WARNING:format(
			id,
			(chanceCount / MAX_DROPSET_RATE) * 100
		))
	end
end

function Slot:buildAnimationItems(rewardId)
	local list = {}

	local halfTiles = math.floor(self.tilesPerSlot / 2)
	local itemsCount = 42

	for i = 1, itemsCount do
		local itemId = self.itemChances[math.random(#self.itemChances)].id
		if i == (itemsCount - halfTiles) then
			itemId = rewardId
		end

		list[#list + 1] = itemId
	end

	return list
end

function Slot:generateReward()
	return self.itemChances[math.random(#self.itemChances)]
end

function Slot:deliverReward()
	local reward = DatabaseRoulettePlays:select(self.uuid)
	if not reward then
		return false
	end

	local player = Player(reward.playerGuid)
	if not player then
		DatabaseRoulettePlays:update(reward.uuid, Constants.PLAY_STATUS_PENDING)
		return false
	end

	Functions:giveReward(player, reward)
end

function Slot:getPositions()
	return self.positions
end

function  Slot:isRolling()
	return self.rolling
end

function Slot:setRolling(value)
	self.rolling = value
end

function Slot:getNeedItem()
	return self.needItem
end

function Slot:getLeverPosition()
	return self.leverpositions
end

return function(object)
	return setmetatable(object, {__index = Slot})
end
