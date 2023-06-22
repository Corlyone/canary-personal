--[[
	Description: This file is part of Roulette System (refactored)
	Author: Lyµ
	Discord: Lyµ#8767
	Adaptado para o Canary:  NvSo#4349
]]

local Slot = dofile(DATA_DIRECTORY .. '/scripts/magic_roulette/lib/classes/slot.lua')
local Animation = dofile(DATA_DIRECTORY .. '/scripts/magic_roulette/lib/animation.lua')
local DatabaseRoulettePlays = dofile(DATA_DIRECTORY .. '/scripts/magic_roulette/lib/database/roulette_plays.lua')
local Strings = dofile(DATA_DIRECTORY .. '/scripts/magic_roulette/lib/core/strings.lua')

slots = {
		[17320] = Slot {
			needItem = {id = 35901, count = 1}, --item necessário para jogar roleta
			tilesPerSlot = 11,
			centerPosition = Position(4999, 5008, 7), --Centro da Roleta onde o prêmio do item para
			leverPosition = Position(4999, 5009, 7), --Posição da alavanca para jogar roleta

			items = {
				{id = 3043, count = 1, chance = 13, rare = true},
				{id = 3366, count = 1, chance = 13, rare = true},
				{id = 3278, count = 1, chance = 13, rare = true},
				{id = 3388, count = 1, chance = 0.2},
				{id = 3365, count = 1, chance = 0.3},
				{id = 6529, count = 1, chance = 0.5},
				{id = 14000, count = 1, chance = 9},
				{id = 3388, count = 1, chance = 5},
				{id = 3365, count = 1, chance = 5},
				{id = 6529, count = 1, chance = 5},
				{id = 14000, count = 1, chance = 9},
				{id = 3365, count = 1, chance = 9},
				{id = 6529, count = 1, chance = 9},
				{id = 14000, count = 1, chance = 9}
			},
		},

		[17321] = Slot {
			needItem = {id = 3043, count = 1},
			tilesPerSlot = 11,
			centerPosition = Position(4999, 5008, 7), --Centro da Roleta onde o pr?mio do item para

			items = {
				{id = 5903, count = 1, chance = 0.1, rare = true}, --ferumbras hat
				{id = 3423, count = 1, chance = 0.2, rare = true}, --blessed shield
				{id = 6529, count = 1, chance = 0.5, rare = true}, -- soft boots
				{id = 3278, count = 1, chance = 0.2, rare = true}, -- magic longsword
				{id = 12548, count = 1, chance = 9}, --Bag of Apple Slices
				{id = 12308, count = 1, chance = 9}, -- Reins
				{id = 22118, count = 100, chance = 9}, --Tibia Coins
				{id = 3043, count = 50, chance = 9}, --Crystal coin
				{id = 27449, count = 1, chance = 9}, --sword of destruction
				{id = 3057, count = 1, chance = 9}, --Amulet of loss	
				{id = 27451, count = 1, chance = 9}, --axe of destruction
				{id = 27457, count = 1, chance = 9}, -- wand of destruction
				{id = 14769, count = 1, chance = 9}, -- Spellbook of Ancient Arcana
				{id = 20086, count = 1, chance = 9}, --Umbral Crossbow
				{id = 27458, count = 1, chance = 9} -- rod of destruction
			},
		},
}

local Roulette = {}

function Roulette:startup()
	DatabaseRoulettePlays:updateAllRollingToPending()

	self.slots = slots
	for actionid, slot in pairs(self.slots) do
		slot:generatePositions()
		slot:loadChances(actionid)
	end
end

function Roulette:roll(player, slot)
	if slot:isRolling() then
		player:sendTextMessage(MESSAGE_ADMINISTRADOR, string.format(Strings.WAIT_TO_SPIN))
		return false
	end

	local reward = slot:generateReward()
	if not reward then
		player:sendTextMessage(MESSAGE_ADMINISTRADOR, string.format(Strings.GENERATE_REWARD_FAILURE))	
		return false
	end

	local needItem = slot:getNeedItem()
	local needItemName = ItemType(needItem.id):getName()

	if not player:removeItem(needItem.id, needItem.count) then
		player:sendTextMessage(MESSAGE_ADMINISTRADOR, string.format(Strings.NEEDITEM_TO_SPIN:format(
			needItem.count,
			needItemName
		)))
		return false
	end

	local playerName = player:getName()
	
	slot.uuid = uuid()
	DatabaseRoulettePlays:create(slot.uuid, player:getGuid(), reward)
	
	slot:setRolling(true)
	slot:clearDummies()

	local onFinish = function()
		slot:deliverReward()
		slot:setRolling(false)

		if reward.rare then
			Game.broadcastMessage(string.format(Strings.GIVE_REWARD_FOUND_RARE:format(
				playerName,
				reward.count,
				ItemType(reward.id):getName()
			)), TALKTYPE_BROADCAST)
		end
	end
	
	Animation:start({
		slot = slot,
		reward = reward,
		onFinish = onFinish
	})
	return true
end

function Roulette:getSlot(actionid)
	self:startup()
	return self.slots[actionid]
end

function Roulette:getLeverPosition(slotId)
    self:startup()
    local slot = self.slots[slotId]
    if slot then
        return slot:getLeverPosition()
    end
end

return Roulette
