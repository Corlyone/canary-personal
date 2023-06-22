local area = createCombatArea({
    {0, 1, 1, 1, 0},
    {1, 1, 1, 1, 1},
    {1, 1, 3, 1, 1},
    {1, 1, 1, 1, 1},
    {0, 1, 1, 1, 0},
})

local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_ENERGYHIT)
combat:setParameter(COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_DIAMONDARROW)
combat:setParameter(COMBAT_PARAM_IMPACTSOUND, SOUND_EFFECT_TYPE_DIAMOND_ARROW_EFFECT)
combat:setParameter(COMBAT_PARAM_CASTSOUND, SOUND_EFFECT_TYPE_DIST_ATK_BOW)
combat:setParameter(COMBAT_PARAM_BLOCKARMOR, true)

function getDistanceWeaponDamage(level, skill, attack, factor, weaponId, distanceSkill)
    local formulas = {
        [34088] = { min = (level / 5), max = (0.09 * factor) * distanceSkill * 27 + (level / 5) + 150 },
        [43532] = { min = (level / 5) + 320, max = (0.09 * factor) * distanceSkill * 32 + (level / 5) + 450 },
        [43554] = { min = (level / 5) + 450, max = (0.09 * factor) * distanceSkill * 44 + (level / 5) + 520 },
        [43524] = { min = (level / 5) + 550, max = (0.09 * factor) * distanceSkill * 55 + (level / 5) + 620 }
    }

    local formula = formulas[weaponId]
    if formula then
        return formula.min, formula.max
    else
        return (level / 5), (level / 5) + (0.09 * factor) * distanceSkill * 27
    end
end

function onGetFormulaValues(player, skill, attack, factor)
    local level = player:getLevel()
    local distanceSkill = player:getEffectiveSkillLevel(SKILL_DISTANCE)
    local leftHandWeapon = player:getSlotItem(CONST_SLOT_LEFT)
    local min, max

    if leftHandWeapon then
        local weaponId = leftHandWeapon:getId()
        min, max = getDistanceWeaponDamage(level, skill, attack, factor, weaponId, distanceSkill)
    else
        min, max = getDistanceWeaponDamage(level, skill, attack, factor, 0, distanceSkill)
    end

    return min, max
end

combat:setCallback(CALLBACK_PARAM_SKILLVALUE, "onGetFormulaValues")
combat:setArea(area)

local diamondArrow = Weapon(WEAPON_AMMO)

function diamondArrow.onUseWeapon(player, variant)
    return combat:execute(player, variant)
end

diamondArrow:id(25757)
diamondArrow:id(35901)
diamondArrow:level(150)
diamondArrow:attack(37)
diamondArrow:action("removecount")
diamondArrow:ammoType("arrow")
diamondArrow:shootType(CONST_ANI_DIAMONDARROW)
diamondArrow:maxHitChance(100)
diamondArrow:wieldUnproperly(true)
diamondArrow:register()