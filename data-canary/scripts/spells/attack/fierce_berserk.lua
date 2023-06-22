local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_HITAREA)
combat:setParameter(COMBAT_PARAM_BLOCKARMOR, 1)
combat:setParameter(COMBAT_PARAM_USECHARGES, 1)
combat:setArea(createCombatArea(AREA_SQUARE1X1))

function getWeaponDamage(level, skill, attack, factor, weaponId, swordSkill, axeSkill, clubSkill)
    local min, max
	
    if weaponId == 43535 then
        min = ((level / 5) + (axeSkill + 2 * attack) * 1.7) + 250
        max = ((level / 5) + (axeSkill + 2 * attack) * 3.5) + 350
    elseif weaponId == 43534 then
        min = ((level / 5) + (axeSkill + 2 * attack) * 2.1) + 450
        max = ((level / 5) + (axeSkill + 2 * attack) * 4.3) + 650
    elseif weaponId == 43525 then
        min = ((level / 5) + (axeSkill + 2 * attack) * 2.9) + 550
        max = ((level / 5) + (axeSkill + 2 * attack) * 4.5) + 950
    elseif weaponId == 43529 then
        min = ((level / 5) + (swordSkill + 2 * attack) * 1.7) + 250
        max = ((level / 5) + (swordSkill + 2 * attack) * 3.5) + 350
    elseif weaponId == 43540 then
        min = ((level / 5) + (swordSkill + 2 * attack) * 2.1) + 450
        max = ((level / 5) + (swordSkill + 2 * attack) * 4.3) + 650
    elseif weaponId == 43538 then
        min = ((level / 5) + (swordSkill + 2 * attack) * 2.9) + 550
        max = ((level / 5) + (swordSkill + 2 * attack) * 4.3) + 950
    elseif weaponId == 43526 then
        min = ((level / 5) + (clubSkill + 2 * attack) * 1.7) + 250
        max = ((level / 5) + (clubSkill + 2 * attack) * 3.5) + 350
    elseif weaponId == 43552 then
        min = ((level / 5) + (clubSkill + 2 * attack) * 2.1) + 450
        max = ((level / 5) + (clubSkill + 2 * attack) * 3.5) + 650
    elseif weaponId == 43553 then
        min = ((level / 5) + (clubSkill + 2 * attack) * 2.9) + 550
        max = ((level / 5) + (clubSkill + 2 * attack) * 4.3) + 950
    else
        min = (level / 5) + (skill + 2 * attack) * 1.7
		max = (level / 5) + (skill + 2 * attack) * 3

	
    end

    return -min * 1.1, -max * 1.1
end

function onGetFormulaValues(player, level, skill, attack, factor)
	local level = player:getLevel()
    local swordSkill = player:getEffectiveSkillLevel(SKILL_SWORD)
    local axeSkill = player:getEffectiveSkillLevel(SKILL_AXE)
    local clubSkill = player:getEffectiveSkillLevel(SKILL_CLUB)

    local leftHandWeapon = player:getSlotItem(CONST_SLOT_LEFT)
	
    if leftHandWeapon then
        local weaponId = leftHandWeapon:getId()
        return getWeaponDamage(level, skill, attack, factor, weaponId, swordSkill, axeSkill, clubSkill)
    end

    return -min * 1.1, -max * 1.1
end

combat:setCallback(CALLBACK_PARAM_SKILLVALUE, "onGetFormulaValues")

local spell = Spell("instant")

function spell.onCastSpell(creature, var)
    return combat:execute(creature, var)
end

spell:group("attack")
spell:id(105)
spell:name("Fierce Berserk")
spell:words("exori gran")
spell:castSound(SOUND_EFFECT_TYPE_SPELL_FIERCE_BERSERK)
spell:level(90)
spell:mana(340)
spell:isPremium(true)
spell:needWeapon(true)
spell:cooldown(1 * 1000)
spell:groupCooldown(1 * 800)
spell:needLearn(false)
spell:vocation("knight;true", "elite knight;true")
spell:register()