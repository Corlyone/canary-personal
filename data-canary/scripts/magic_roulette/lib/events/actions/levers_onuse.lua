--[[
	Description: This file is part of Roulette System (refactored)
	Author: Lyµ
	Discord: Lyµ#8767
	Adaptado para o Canary:  NvSo#4349
]]

local Roulette = dofile(DATA_DIRECTORY .. '/scripts/magic_roulette/roulette.lua')
local Strings = dofile(DATA_DIRECTORY .. '/scripts/magic_roulette/lib/core/strings.lua')

local lever = Action()

function lever.onUse(player, item, fromPosition, itemEx, toPosition)
	local slot = Roulette:getSlot(item.actionid)
	--local slot = Roulette:getSlot(item.actionid)
	if not slot then
		player:sendTextMessage(MESSAGE_ADMINISTRADOR, string.format(Strings.SLOT_NOT_IMPLEMENTED_YET))
		item:getPosition():sendMagicEffect(CONST_ME_POFF)
		return true
	end
	
	if slot:isRolling() then
		player:sendTextMessage(MESSAGE_ADMINISTRADOR, string.format(Strings.WAIT_TO_SPIN))
		return false
	end

	Roulette:roll(player, slot)
	item:transform(item.itemid == 21129 and 21125 or 21129)
	return true
end

lever:aid(17320)
lever:aid(17321)
lever:register()