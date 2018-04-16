--[[

    Copyright (c) 2017 Martin Jesper Low Madsen

    This library is free software; you can redistribute it and/or modify it
    under the terms of the GNU Lesser General Public License as published by the
    Free Software Foundation; either version 2.1 of the License, or (at your
    option) any later version.

    This library is distributed in the hope that it will be useful, but WITHOUT
    ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
    FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License
    for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with this library; if not, write to the Free Software Foundation,
    Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA

--]]


if not LibStub then return end

local Modernizr = LibStub:NewLibrary('ModernizrLib-1.0', 0)
if not Modernizr then return end

local _G = getfenv(0)

local GetPlayerBuff = GetPlayerBuff
local GetPlayerBuffApplications = GetPlayerBuffApplications
local GetPlayerBuffDispelType = GetPlayerBuffDispelType
local GetPlayerBuffTexture = GetPlayerBuffTexture
local GetPlayerBuffTimeLeft = GetPlayerBuffTimeLeft
local GetTime = GetTime
local UnitBuff = UnitBuff
local UnitDebuff = UnitDebuff
local UnitIsUnit = UnitIsUnit
local UnitName = UnitName
local stringFormat = string.format
local stringLower = string.lower
local stringMatch = string.match
local stringSplit = string.split
local stringTrim = string.trim
local tableGetn = table.getn
local tableRemove = table.remove
local tableWipe = table.wipe
local type = type

local MODERNIZR = CreateFrame('GameTooltip')
MODERNIZR:SetOwner(MODERNIZR, 'ANCHOR_NONE')
MODERNIZR.leftLines, MODERNIZR.rightLines = {}, {}
for i = 1, 30 do
    MODERNIZR.leftLines[i], MODERNIZR.rightLines[i] =
        MODERNIZR:CreateFontString(), MODERNIZR:CreateFontString()
    MODERNIZR.leftLines[i]:SetFontObject(GameFontNormal)
    MODERNIZR.rightLines[i]:SetFontObject(GameFontNormal)
    MODERNIZR:AddFontStrings(MODERNIZR.leftLines[i], MODERNIZR.rightLines[i])
end
function MODERNIZR:Erase()
    self:ClearLines()
    for i = 1, 30 do
        self.rightLines[i]:SetText()
    end
    if not self:IsOwned(self) then
        self:SetOwner(self, 'ANCHOR_NONE')
    end
end

function MODERNIZR:GetLine(line, right)
    if self:NumLines() < line then return end
    if right then
        return self.rightLines[line] and self.rightLines[line]:GetText()
    elseif self.leftLines[line] then
        return self.leftLines[line]:GetText(), self.rightLines[line]:GetText()
    end
end


local spellIcons = {
	["Abolish Disease"] = "Spell_Nature_NullifyDisease",
	["Abolish Poison Effect"] = "Spell_Nature_NullifyPoison_02",
	["Abolish Poison"] = "Spell_Nature_NullifyPoison_02",
        ['Stormpike Battle Charger'] = 'Ability_Mount_MountainRam',
	["Activate MG Turret"] = "INV_Weapon_Rifle_10",
        ['Rallying Cry of the Dragonslayer'] = 'inv_misc_head_dragon_01',
        ['Swift White Mechanostrider'] = 'ability_mount_mechastrider',
        ['Elixir of the Mongoose'] = 'inv_potion_32',
        ['Yaaarrrr'] = 'ability_rogue_disguise',
        ['Agility'] = 'inv_potion_93',
        ['Brown Horse'] = 'ability_mount_ridinghorse',
        ['Black War Tiger'] = 'ability_mount_blackpanther',
	["Adrenaline Rush"] = "Spell_Shadow_ShadowWordDominate",
	["Aftermath"] = "Spell_Fire_Fire",
	["Aggression"] = "Ability_Racial_Avatar",
	["Aimed Shot"] = "INV_Spear_07",
	["Alchemy"] = "Trade_Alchemy",
	["Ambush"] = "Ability_Rogue_Ambush",
	["Amplify Curse"] = "Spell_Shadow_Contagion",
	["Amplify Magic"] = "Spell_Holy_FlashHeal",
	["Ancestral Healing"] = "Spell_Nature_UndyingStrength",
	["Ancestral Knowledge"] = "Spell_Shadow_GrimWard",
	["Ancestral Spirit"] = "Spell_Nature_Regenerate",
	["Anger Management"] = "Spell_Holy_BlessingOfStamina",
	["Anticipation"] = "Spell_Nature_MirrorImage",
	["Aquatic Form"] = "Ability_Druid_AquaticForm",
	["Arcane Brilliance"] = "Spell_Holy_ArcaneIntellect",
	["Arcane Concentration"] = "Spell_Shadow_ManaBurn",
	["Arcane Explosion"] = "Spell_Nature_WispSplode",
	["Arcane Focus"] = "Spell_Holy_Devotion",
	["Arcane Instability"] = "Spell_Shadow_Teleport",
	["Arcane Intellect"] = "Spell_Holy_MagicalSentry",
	["Arcane Meditation"] = "Spell_Shadow_SiphonMana",
	["Arcane Mind"] = "Spell_Shadow_Charm",
	["Arcane Missiles"] = "Spell_Nature_StarFall",
	["Arcane Power"] = "Spell_Nature_Lightning",
	["Arcane Resistance"] = "Spell_Nature_StarFall",
	["Arcane Shot"] = "Ability_ImpalingBolt",
	["Arcane Subtlety"] = "Spell_Holy_DispelMagic",
	["Arctic Reach"] = "Spell_Shadow_DarkRitual",
	["Aspect of the Beast"] = "Ability_Mount_PinkTiger",
	["Aspect of the Cheetah"] = "Ability_Mount_JungleTiger",
	["Aspect of the Hawk"] = "Spell_Nature_RavenForm",
	["Aspect of the Monkey"] = "Ability_Hunter_AspectOfTheMonkey",
	["Aspect of the Pack"] = "Ability_Mount_WhiteTiger",
	["Aspect of the Wild"] = "Spell_Nature_ProtectionformNature",
	["Astral Recall"] = "Spell_Nature_AstralRecal",
	["Attack"] = "Temp",
	["Attacking"] = "Temp",
	["Auto Shot"] = "Ability_Whirlwind",
	["Axe Specialization"] = "INV_Axe_06",
	["Backstab"] = "Ability_BackStab",
	["Bane"] = "Spell_Shadow_DeathPact",
	["Banish"] = "Spell_Shadow_Cripple",
	["Barkskin Effect"] = "Spell_Nature_StoneClawTotem",
	["Barkskin"] = "Spell_Nature_StoneClawTotem",
	["Barrage"] = "Ability_UpgradeMoonGlaive",
	["Bash"] = "Ability_Druid_Bash",
	["Basic Campfire"] = "Spell_Fire_Fire",
	["Battle Shout"] = "Ability_Warrior_BattleShout",
	["Battle Stance Passive"] = "Ability_Warrior_OffensiveStance",
	["Battle Stance"] = "Ability_Warrior_OffensiveStance",
	["Bear Form"] = "Ability_Racial_BearForm",
	["Beast Lore"] = "Ability_Physical_Taunt",
	["Beast Slaying"] = "INV_Misc_Pelt_Bear_Ruin_02",
	["Beast Training"] = "Ability_Hunter_BeastCall02",
	["Benediction"] = "Spell_Frost_WindWalkOn",
	["Berserker Rage"] = "Spell_Nature_AncestralGuardian",
	["Berserker Stance Passive"] = "Ability_Racial_Avatar",
	["Berserker Stance"] = "Ability_Racial_Avatar",
	["Berserking"] = "Racial_Troll_Berserk",
	["Bestial Discipline"] = "Spell_Nature_AbolishMagic",
	["Bestial Swiftness"] = "Ability_Druid_Dash",
	["Bestial Wrath"] = "Ability_Druid_FerociousBite",
	["Bite"] = "Ability_Racial_Cannibalize",
	["Black Arrow"] = "Ability_TheBlackArrow",
	["Blackout"] = "Spell_Shadow_GatherShadows",
	["Blacksmithing"] = "Trade_BlackSmithing",
	["Blade Flurry"] = "Ability_Warrior_PunishingBlow",
	["Blast Wave"] = "Spell_Holy_Excorcism_02",
	["Blessed Recovery"] = "Spell_Holy_BlessedRecovery",
	["Blessing of Freedom"] = "Spell_Holy_SealOfValor",
	["Blessing of Kings"] = "Spell_Magic_MageArmor",
	["Blessing of Light"] = "Spell_Holy_PrayerOfHealing02",
	["Blessing of Might"] = "Spell_Holy_FistOfJustice",
	["Blessing of Protection"] = "Spell_Holy_SealOfProtection",
	["Blessing of Sacrifice"] = "Spell_Holy_SealOfSacrifice",
	["Blessing of Salvation"] = "Spell_Holy_SealOfSalvation",
	["Blessing of Sanctuary"] = "Spell_Nature_LightningShield",
	["Blessing of Wisdom"] = "Spell_Holy_SealOfWisdom",
	["Blind"] = "Spell_Shadow_MindSteal",
	["Blinding Powder"] = "INV_Misc_Ammo_Gunpowder_02",
	["Blink"] = "Spell_Arcane_Blink",
	["Blizzard"] = "Spell_Frost_IceStorm",
	["Block"] = "Ability_Defend",
	["Blood Craze"] = "Spell_Shadow_SummonImp",
	["Blood Frenzy"] = "Ability_GhoulFrenzy",
	["Blood Fury"] = "Racial_Orc_BerserkerStrength",
	["Blood Pact"] = "Spell_Shadow_BloodBoil",
	["Bloodrage"] = "Ability_Racial_BloodRage",
	["Bloodthirst"] = "Spell_Nature_BloodLust",
	["Booming Voice"] = "Spell_Nature_Purge",
	["Bow Specialization"] = "INV_Weapon_Bow_12",
	["Bows"] = "INV_Weapon_Bow_05",
	["Bright Campfire"] = "Spell_Fire_Fire",
	["Brutal Impact"] = "Ability_Druid_Bash",
	["Burning Soul"] = "Spell_Fire_Fire",
	["Call Pet"] = "Ability_Hunter_BeastCall",
	["Call of Flame"] = "Spell_Fire_Immolation",
	["Call of Thunder"] = "Spell_Nature_CallStorm",
	["Camouflage"] = "Ability_Stealth",
	["Cannibalize"] = "Ability_Racial_Cannibalize",
	["Cat Form"] = "Ability_Druid_CatForm",
	["Cataclysm"] = "Spell_Fire_WindsofWoe",
	["Chain Heal"] = "Spell_Nature_HealingWaveGreater",
	["Chain Lightning"] = "Spell_Nature_ChainLightning",
	["Challenging Roar"] = "Ability_Druid_ChallangingRoar",
	["Challenging Shout"] = "Ability_BullRush",
	["Charge Rage Bonus Effect"] = "Ability_Warrior_Charge",
	["Charge"] = "Ability_Warrior_Charge",
	["Cheap Shot"] = "Ability_CheapShot",
	["Chilled"] = "Spell_Frost_IceStorm",
	["Claw"] = "Ability_Druid_Rake",
	["Cleanse"] = "Spell_Holy_Renew",
	["Clearcasting"] = "Spell_Shadow_ManaBurn",
	["Cleave"] = "Ability_Warrior_Cleave",
	["Clever Traps"] = "Spell_Nature_TimeStop",
	["Closing"] = "Temp",
	["Cloth"] = "INV_Chest_Cloth_21",
	["Cobra Reflexes"] = "Spell_Nature_GuardianWard",
	["Cold Blood"] = "Spell_Ice_Lament",
	["Cold Snap"] = "Spell_Frost_WizardMark",
	["Combat Endurance"] = "Spell_Nature_AncestralGuardian",
	["Combustion"] = "Spell_Fire_SealOfFire",
	["Command"] = "Ability_Warrior_WarCry",
	["Concentration Aura"] = "Spell_Holy_MindSooth",
	["Concussion Blow"] = "Ability_ThunderBolt",
	["Concussion"] = "Spell_Fire_Fireball",
	["Concussive Shot"] = "Spell_Frost_Stun",
	["Cone of Cold"] = "Spell_Frost_Glacier",
	["Conflagrate"] = "Spell_Fire_Fireball",
	["Conjure Food"] = "INV_Misc_Food_10",
	["Conjure Mana Agate"] = "INV_Misc_Gem_Emerald_01",
	["Conjure Mana Citrine"] = "INV_Misc_Gem_Opal_01",
	["Conjure Mana Jade"] = "INV_Misc_Gem_Emerald_02",
	["Conjure Mana Ruby"] = "INV_Misc_Gem_Ruby_01",
	["Conjure Water"] = "INV_Drink_06",
	["Consecration"] = "Spell_Holy_InnerFire",
	["Consume Shadows"] = "Spell_Shadow_AntiShadow",
	["Convection"] = "Spell_Nature_WispSplode",
	["Conviction"] = "Spell_Holy_RetributionAura",
	["Cooking"] = "INV_Misc_Food_15",
	["Corruption"] = "Spell_Shadow_AbominationExplosion",
	["Counterattack"] = "Ability_Warrior_Challange",
	["Counterspell"] = "Spell_Frost_IceShock",
	["Cower"] = "Ability_Druid_Cower",
	["Create Firestone (Lesser)"]="INV_Ammo_FireTar",
	["Create Firestone"]="INV_Ammo_FireTar",
	["Create Firestone (Greater)"]="INV_Ammo_FireTar",
	["Create Firestone (Major)"]="INV_Ammo_FireTar",
	["Create Healthstone (Minor)"]="INV_Stone_04",
	["Create Healthstone (Lesser)"]="INV_Stone_04",
	["Create Healthstone"]="INV_Stone_04",
	["Create Healthstone (Greater)"]="INV_Stone_04",
	["Create Healthstone (Major)"]="INV_Stone_04",
	["Create Soulstone (Minor)"]="Spell_Shadow_SoulGem",
	["Create Soulstone (Lesser)"]="Spell_Shadow_SoulGem",
	["Create Soulstone"]="Spell_Shadow_SoulGem",
	["Create Soulstone (Greater)"]="Spell_Shadow_SoulGem",
	["Create Soulstone (Major)"]="Spell_Shadow_SoulGem",
	["Create Spellstone"]="INV_Misc_Gem_Sapphire_01",
	["Create Spellstone (Greater)"]="INV_Misc_Gem_Sapphire_01",
	["Create Spellstone (Major)"]="INV_Misc_Gem_Sapphire_01",
	["Crippling Poison II"] = "Ability_PoisonSting",
	["Crippling Poison"] = "Ability_PoisonSting",
	["Critical Mass"] = "Spell_Nature_WispHeal",
	["Crossbows"] = "INV_Weapon_Crossbow_01",
	["Cruelty"] = "Ability_Rogue_Eviscerate",
	["Cultivation"] = "INV_Misc_Flower_01",
	["Cure Disease"] = "Spell_Holy_NullifyDisease",
	["Cure Poison"] = "Spell_Nature_NullifyPoison",
	["Curse of Agony"] = "Spell_Shadow_CurseOfSargeras",
	["Curse of Doom Effect"] = "Spell_Shadow_AuraOfDarkness",
	["Curse of Doom"] = "Spell_Shadow_AuraOfDarkness",
	["Curse of Exhaustion"] = "Spell_Shadow_GrimWard",
	["Curse of Idiocy"] = "Spell_Shadow_MindRot",
	["Curse of Recklessness"] = "Spell_Shadow_UnholyStrength",
	["Curse of Shadow"] = "Spell_Shadow_CurseOfAchimonde",
	["Curse of Tongues"] = "Spell_Shadow_CurseOfTounges",
	["Curse of Weakness"] = "Spell_Shadow_CurseOfMannoroth",
	["Curse of the Elements"] = "Spell_Shadow_ChillTouch",
	["Dagger Specialization"] = "INV_Weapon_ShortBlade_05",
	["Daggers"] = "Ability_SteelMelee",
	["Dampen Magic"] = "Spell_Nature_AbolishMagic",
	["Dark Pact"] = "Spell_Shadow_DarkRitual",
	["Darkness"] = "Spell_Shadow_Twilight",
	["Dash"] = "Ability_Druid_Dash",
	["Deadly Poison II"] = "Ability_Rogue_DualWeild",
	["Deadly Poison III"] = "Ability_Rogue_DualWeild",
	["Deadly Poison IV"] = "Ability_Rogue_DualWeild",
	["Deadly Poison V"] = "Ability_Rogue_DualWeild",
	["Deadly Poison"] = "Ability_Rogue_DualWeild",
	["Death Coil"] = "Spell_Shadow_DeathCoil",
	["Death Wish"] = "Spell_Shadow_DeathPact",
	["Deep Wounds"] = "Ability_BackStab",
	["Defense"] = "Ability_Racial_ShadowMeld",
	["Defensive Stance Passive"] = "Ability_Warrior_DefensiveStance",
	["Defensive Stance"] = "Ability_Warrior_DefensiveStance",
	["Defensive State 2"] = "Ability_Defend",
	["Defensive State"] = "Ability_Defend",
	["Defiance"] = "Ability_Warrior_InnerRage",
	["Deflection"] = "Ability_Parry",
	["Demon Armor"] = "Spell_Shadow_RagingScream",
	["Demon Skin"] = "Spell_Shadow_RagingScream",
	["Demonic Embrace"] = "Spell_Shadow_Metamorphosis",
	["Demonic Sacrifice"] = "Spell_Shadow_PsychicScream",
	["Demoralizing Roar"] = "Ability_Druid_DemoralizingRoar",
	["Demoralizing Shout"] = "Ability_Warrior_WarCry",
	["Desperate Prayer"] = "Spell_Holy_Restoration",
	["Destructive Reach"] = "Spell_Shadow_CorpseExplode",
	["Detect Greater Invisibility"] = "Spell_Shadow_DetectInvisibility",
	["Detect Invisibility"] = "Spell_Shadow_DetectInvisibility",
	["Detect Lesser Invisibility"] = "Spell_Shadow_DetectLesserInvisibility",
	["Detect Magic"] = "Spell_Holy_Dizzy",
	["Detect Traps"] = "Ability_Spy",
	["Detect"] = "Ability_Hibernation",
	["Deterrence"] = "Ability_Whirlwind",
	["Devastation"] = "Spell_Fire_FlameShock",
	["Devotion Aura"] = "Spell_Holy_DevotionAura",
	["Devour Magic Effect"] = "Spell_Nature_Purge",
	["Devour Magic"] = "Spell_Nature_Purge",
	["Devouring Plague"] = "Spell_Shadow_BlackPlague",
	["Diplomacy"] = "INV_Misc_Note_02",
	["Dire Bear Form"] = "Ability_Racial_BearForm",
	["Disarm Trap"] = "Spell_Shadow_GrimWard",
	["Disarm"] = "Ability_Warrior_Disarm",
	["Disease Cleansing Totem"] = "Spell_Nature_DiseaseCleansingTotem",
	["Disenchant"] = "Spell_Holy_RemoveCurse",
	["Disengage"] = "Ability_Rogue_Feint",
	["Dismiss Pet"] = "Spell_Nature_SpiritWolf",
	["Dispel Magic"] = "Spell_Holy_DispelMagic",
	["Distract"] = "Ability_Rogue_Distract",
	["Distracting Shot"] = "Spell_Arcane_Blink",
	["Dive"] = "Spell_Shadow_BurningSpirit",
	["Divine Favor"] = "Spell_Holy_Heal",
	["Divine Fury"] = "Spell_Holy_SealOfWrath",
	["Divine Intellect"] = "Spell_Nature_Sleep",
	["Divine Intervention"] = "Spell_Nature_TimeStop",
	["Divine Protection"] = "Spell_Holy_Restoration",
	["Divine Shield"] = "Spell_Holy_DivineIntervention",
	["Divine Spirit"] = "Spell_Holy_DivineSpirit",
	["Divine Strength"] = "Ability_GolemThunderClap",
	["Dodge"] = "Spell_Nature_Invisibilty",
	["Drain Life"] = "Spell_Shadow_LifeDrain02",
	["Drain Mana"] = "Spell_Shadow_SiphonMana",
	["Drain Soul"] = "Spell_Shadow_Haunting",
	["Dual Wield Specialization"] = "Ability_DualWield",
	["Dual Wield"] = "Ability_DualWield",
	["Duel"] = "Temp",
	["Eagle Eye"] = "Ability_Hunter_EagleEye",
	["Earth Shock"] = "Spell_Nature_EarthShock",
	["Earthbind Totem"] = "Spell_Nature_StrengthOfEarthTotem02",
	["Efficiency"] = "Spell_Frost_WizardMark",
	["Elemental Focus"] = "Spell_Shadow_ManaBurn",
	["Elemental Fury"] = "Spell_Fire_Volcano",
	["Elemental Mastery"] = "Spell_Nature_WispHeal",
	["Elune's Grace"] = "Spell_Holy_ElunesGrace",
	["Elusiveness"] = "Spell_Magic_LesserInvisibilty",
	["Emberstorm"] = "Spell_Fire_SelfDestruct",
	["Enchanting"] = "Trade_Engraving",
	["Endurance Training"] = "Spell_Nature_Reincarnation",
	["Endurance"] = "Spell_Nature_UnyeildingStamina",
	["Engineering Specialization"] = "INV_Misc_Gear_01",
	["Engineering"] = "Trade_Engineering",
	["Enrage"] = "Ability_Druid_Enrage",
	["Enslave Demon"] = "Spell_Shadow_EnslaveDemon",
	["Entangling Roots"] = "Spell_Nature_StrangleVines",
	["Entrapment"] = "Spell_Nature_StrangleVines",
	["Escape Artist"] = "Ability_Rogue_Trip",
	["Evasion"] = "Spell_Shadow_ShadowWard",
	["Eventide"] = "Spell_Frost_Stun",
	["Eviscerate"] = "Ability_Rogue_Eviscerate",
	["Evocation"] = "Spell_Nature_Purge",
	["Execute"] = "INV_Sword_48",
	["Exorcism"] = "Spell_Holy_Excorcism_02",
	["Expansive Mind"] = "INV_Enchant_EssenceEternalLarge",
	["Explosive Trap Effect"] = "Spell_Fire_SelfDestruct",
	["Explosive Trap"] = "Spell_Fire_SelfDestruct",
	["Expose Armor"] = "Ability_Warrior_Riposte",
	["Eye for an Eye"] = "Spell_Holy_EyeforanEye",
	["Eye of Kilrogg"] = "Spell_Shadow_EvilEye",
	["Eyes of the Beast"] = "Ability_EyeOfTheOwl",
	["Fade"] = "Spell_Magic_LesserInvisibilty",
	["Faerie Fire"] = "Spell_Nature_FaerieFire",
	["Far Sight"] = "Spell_Nature_FarSight",
	["Fear Ward"] = "Spell_Holy_Excorcism",
	["Fear"] = "Spell_Shadow_Possession",
	["Feed Pet"] = "Ability_Hunter_BeastTraining",
	["Feedback"] = "Spell_Shadow_RitualOfSacrifice",
	["Feign Death"] = "Ability_Rogue_FeignDeath",
	["Feint"] = "Ability_Rogue_Feint",
	["Fel Concentration"] = "Spell_Shadow_FingerOfDeath",
	["Fel Domination"] = "Spell_Nature_RemoveCurse",
	["Fel Intellect"] = "Spell_Holy_MagicalSentry",
	["Fel Stamina"] = "Spell_Shadow_AntiShadow",
	["Felfire"] = "Spell_Fire_Fireball",
	["Feline Grace"] = "INV_Feather_01",
	["Feline Swiftness"] = "Spell_Nature_SpiritWolf",
	["Feral Aggression"] = "Ability_Druid_DemoralizingRoar",
	["Feral Charge"] = "Ability_Hunter_Pet_Bear",
	["Feral Instinct"] = "Ability_Ambush",
	["Ferocious Bite"] = "Ability_Druid_FerociousBite",
	["Ferocity"] = "INV_Misc_MonsterClaw_04",
	["Fetish"] = "INV_Misc_Horn_01",
	["Find Herbs"] = "INV_Misc_Flower_02",
	["Find Minerals"] = "Spell_Nature_Earthquake",
	["Find Treasure"] = "Racial_Dwarf_FindTreasure",
	["Fire Blast"] = "Spell_Fire_Fireball",
	["Fire Nova Totem"] = "Spell_Fire_SealOfFire",
	["Fire Power"] = "Spell_Fire_Immolation",
	["Fire Resistance Aura"] = "Spell_Fire_SealOfFire",
	["Fire Resistance Totem"] = "Spell_FireResistanceTotem_01",
	["Fire Resistance"] = "Spell_Fire_FireArmor",
	["Fire Shield"] = "Spell_Fire_FireArmor",
	["Fire Vulnerability"] = "Spell_Fire_SoulBurn",
	["Fire Ward"] = "Spell_Fire_FireArmor",
	["Fireball"] = "Spell_Fire_FlameBolt",
	["Firebolt"] = "Spell_Fire_FireBolt",
	["First Aid"] = "Spell_Holy_SealOfSacrifice",
	["Fishing Poles"] = "Trade_Fishing",
	["Fishing"] = "Trade_Fishing",
	["Fist Weapon Specialization"] = "INV_Gauntlets_04",
	["Fist Weapons"] = "INV_Gauntlets_04",
	["Flame Shock"] = "Spell_Fire_FlameShock",
	["Flame Throwing"] = "Spell_Fire_Flare",
	["Flamestrike"] = "Spell_Fire_SelfDestruct",
	["Flamethrower"] = "Spell_Fire_Incinerate",
	["Flametongue Totem"] = "Spell_Nature_GuardianWard",
	["Flametongue Weapon"] = "Spell_Fire_FlameTounge",
	["Flare"] = "Spell_Fire_Flare",
	["Flash Heal"] = "Spell_Holy_FlashHeal",
	["Flash of Light"] = "Spell_Holy_FlashHeal",
	["Flurry"] = "Ability_GhoulFrenzy",
	["Focused Casting"] = "Spell_Arcane_Blink",
	["Force of Will"] = "Spell_Nature_SlowingTotem",
	["Freezing Trap"] = "Spell_Frost_ChainsOfIce",
	["Frenzied Regeneration"] = "Ability_BullRush",
	["Frenzy"] = "INV_Misc_MonsterClaw_03",
	["Frost Armor"] = "Spell_Frost_FrostArmor02",
	["Frost Channeling"] = "Spell_Frost_Stun",
	["Frost Nova"] = "Spell_Frost_FrostNova",
	["Frost Resistance Aura"] = "Spell_Frost_WizardMark",
	["Frost Resistance Totem"] = "Spell_FrostResistanceTotem_01",
	["Frost Resistance"] = "Spell_Frost_FrostWard",
	["Frost Shock"] = "Spell_Frost_FrostShock",
	["Frost Trap"] = "Spell_Frost_FreezingBreath",
	["Frost Ward"] = "Spell_Frost_FrostWard",
	["Frostbite"] = "Spell_Frost_FrostArmor",
	["Frostbolt"] = "Spell_Frost_FrostBolt02",
	["Frostbrand Weapon"] = "Spell_Frost_FrostBrand",
	["Furious Howl"] = "Ability_Hunter_Pet_Wolf",
	["Furor"] = "Spell_Holy_BlessingOfStamina",
	["Garrote"] = "Ability_Rogue_Garrote",
	["Generic"] = "INV_Shield_09",
	["Ghost Wolf"] = "Spell_Nature_SpiritWolf",
	["Ghostly Strike"] = "Spell_Shadow_Curse",
	["Gift of Nature"] = "Spell_Nature_ProtectionformNature",
	["Gift of the Wild"] = "Spell_Nature_Regeneration",
	["Gouge"] = "Ability_Gouge",
	["Grace of Air Totem"] = "Spell_Nature_InvisibilityTotem",
	["Great Stamina"] = "Spell_Nature_UnyeildingStamina",
	["Greater Blessing of Kings"] = "Spell_Magic_GreaterBlessingofKings",
	["Greater Blessing of Light"] = "Spell_Holy_GreaterBlessingofLight",
	["Greater Blessing of Might"] = "Spell_Holy_GreaterBlessingofKings",
	["Greater Blessing of Salvation"] = "Spell_Holy_GreaterBlessingofSalvation",
	["Greater Blessing of Sanctuary"] = "Spell_Holy_GreaterBlessingofSanctuary",
	["Greater Blessing of Wisdom"] = "Spell_Holy_GreaterBlessingofWisdom",
	["Greater Heal"] = "Spell_Holy_GreaterHeal",
	["Grim Reach"] = "Spell_Shadow_CallofBone",
	["Grounding Totem"] = "Spell_Nature_GroundingTotem",
	["Grovel"] = "Temp",
	["Growl"] = "Ability_Physical_Taunt",
	["Guardian's Favor"] = "Spell_Holy_SealOfProtection",
	["Gun Specialization"] = "INV_Musket_03",
	["Guns"] = "INV_Weapon_Rifle_01",
	["Hammer of Justice"] = "Spell_Holy_SealOfMight",
	["Hammer of Wrath"] = "Ability_ThunderClap",
	["Hamstring"] = "Ability_ShockWave",
	["Harass"] = "Ability_Hunter_Harass",
	["Hardiness"] = "INV_Helmet_23",
	["Hawk Eye"] = "Ability_TownWatch",
	["Heal"] = "Spell_Holy_Heal",
	["Healing Focus"] = "Spell_Holy_HealingFocus",
	["Healing Light"] = "Spell_Holy_HolyBolt",
	["Healing Stream Totem"] = "INV_Spear_04",
	["Healing Touch"] = "Spell_Nature_HealingTouch",
	["Healing Wave"] = "Spell_Nature_MagicImmunity",
	["Health Funnel"] = "Spell_Shadow_LifeDrain",
	["Heart of the Wild"] = "Spell_Holy_BlessingOfAgility",
	["Hellfire Effect"] = "Spell_Fire_Incinerate",
	["Hellfire"] = "Spell_Fire_Incinerate",
	["Hemorrhage"] = "Spell_Shadow_LifeDrain",
	["Herbalism"] = "Spell_Nature_NatureTouchGrow",
	["Herb Gathering"] = "Spell_Nature_NatureTouchGrow",
	["Heroic Strike"] = "Ability_Rogue_Ambush",
	["Hex of Weakness"] = "Spell_Shadow_FingerOfDeath",
	["Hibernate"] = "Spell_Nature_Sleep",
	["Holy Fire"] = "Spell_Holy_SearingLight",
	["Holy Light"] = "Spell_Holy_HolyBolt",
	["Holy Nova"] = "Spell_Holy_HolyNova",
	["Holy Power"] = "Spell_Holy_Power",
	["Holy Reach"] = "Spell_Holy_Purify",
	["Holy Shield"] = "Spell_Holy_BlessingOfProtection",
	["Holy Shock"] = "Spell_Holy_SearingLight",
	["Holy Specialization"] = "Spell_Holy_SealOfSalvation",
	["Holy Wrath"] = "Spell_Holy_Excorcism",
	["Honorless Target"] = "Spell_Magic_LesserInvisibilty",
	["Horse Riding"] = "Spell_Nature_Swiftness",
	["Howl of Terror"] = "Spell_Shadow_DeathScream",
	["Humanoid Slaying"] = "Spell_Holy_PrayerOfHealing",
	["Hunter's Mark"] = "Ability_Hunter_SniperShot",
	["Hurricane"] = "Spell_Nature_Cyclone",
	["Ice Armor"] = "Spell_Frost_FrostArmor02",
	["Ice Barrier"] = "Spell_Ice_Lament",
	["Ice Block"] = "Spell_Frost_Frost",
	["Ice Shards"] = "Spell_Frost_IceShard",
	["Ignite"] = "Spell_Fire_Incinerate",
	["Illumination"] = "Spell_Holy_GreaterHeal",
	["Immolate"] = "Spell_Fire_Immolation",
	["Immolation Trap Effect"] = "Spell_Fire_FlameShock",
	["Immolation Trap"] = "Spell_Fire_FlameShock",
	["Impact"] = "Spell_Fire_MeteorStorm",
	["Impale"] = "Ability_SearingArrow",
	["Improved Ambush"] = "Ability_Rogue_Ambush",
	["Improved Arcane Explosion"] = "Spell_Nature_WispSplode",
	["Improved Arcane Missiles"] = "Spell_Nature_StarFall",
	["Improved Arcane Shot"] = "Ability_ImpalingBolt",
	["Improved Aspect of the Hawk"] = "Spell_Nature_RavenForm",
	["Improved Aspect of the Monkey"] = "Ability_Hunter_AspectOfTheMonkey",
	["Improved Backstab"] = "Ability_BackStab",
	["Improved Battle Shout"] = "Ability_Warrior_BattleShout",
	["Improved Berserker Rage"] = "Spell_Nature_AncestralGuardian",
	["Improved Blessing of Might"] = "Spell_Holy_FistOfJustice",
	["Improved Blessing of Wisdom"] = "Spell_Holy_SealOfWisdom",
	["Improved Blizzard"] = "Spell_Frost_IceStorm",
	["Improved Bloodrage"] = "Ability_Racial_BloodRage",
	["Improved Chain Heal"] = "Spell_Nature_HealingWaveGreater",
	["Improved Chain Lightning"] = "Spell_Nature_ChainLightning",
	["Improved Challenging Shout"] = "Ability_Warrior_Challange",
	["Improved Charge"] = "Ability_Warrior_Charge",
	["Improved Cheap Shot"] = "Ability_CheapShot",
	["Improved Cleave"] = "Ability_Warrior_Cleave",
	["Improved Concentration Aura"] = "Spell_Holy_MindSooth",
	["Improved Concussive Shot"] = "Spell_Frost_Stun",
	["Improved Cone of Cold"] = "Spell_Frost_Glacier",
	["Improved Corruption"] = "Spell_Shadow_AbominationExplosion",
	["Improved Counterspell"] = "Spell_Frost_IceShock",
	["Improved Curse of Agony"] = "Spell_Shadow_CurseOfSargeras",
	["Improved Curse of Exhaustion"] = "Spell_Shadow_GrimWard",
	["Improved Curse of Weakness"] = "Spell_Shadow_CurseOfMannoroth",
	["Improved Dampen Magic"] = "Spell_Nature_AbolishMagic",
	["Improved Deadly Poison"] = "Ability_Rogue_DualWeild",
	["Improved Demoralizing Shout"] = "Ability_Warrior_WarCry",
	["Improved Devotion Aura"] = "Spell_Holy_DevotionAura",
	["Improved Disarm"] = "Ability_Warrior_Disarm",
	["Improved Distract"] = "Ability_Rogue_Distract",
	["Improved Drain Life"] = "Spell_Shadow_LifeDrain02",
	["Improved Drain Mana"] = "Spell_Shadow_SiphonMana",
	["Improved Drain Soul"] = "Spell_Shadow_Haunting",
	["Improved Enrage"] = "Ability_Druid_Enrage",
	["Improved Enslave Demon"] = "Spell_Shadow_EnslaveDemon",
	["Improved Entangling Roots"] = "Spell_Nature_StrangleVines",
	["Improved Evasion"] = "Spell_Shadow_ShadowWard",
	["Improved Eviscerate"] = "Ability_Rogue_Eviscerate",
	["Improved Execute"] = "INV_Sword_48",
	["Improved Expose Armor"] = "Ability_Warrior_Riposte",
	["Improved Eyes of the Beast"] = "Ability_EyeOfTheOwl",
	["Improved Fade"] = "Spell_Magic_LesserInvisibilty",
	["Improved Feign Death"] = "Ability_Rogue_FeignDeath",
	["Improved Fire Blast"] = "Spell_Fire_Fireball",
	["Improved Fire Nova Totem"] = "Spell_Fire_SealOfFire",
	["Improved Fire Ward"] = "Spell_Fire_FireArmor",
	["Improved Fireball"] = "Spell_Fire_FlameBolt",
	["Improved Firebolt"] = "Spell_Fire_FireBolt",
	["Improved Firestone"] = "INV_Ammo_FireTar",
	["Improved Flamestrike"] = "Spell_Fire_SelfDestruct",
	["Improved Flametongue Weapon"] = "Spell_Fire_FlameTounge",
	["Improved Flash of Light"] = "Spell_Holy_FlashHeal",
	["Improved Frost Nova"] = "Spell_Frost_FreezingBreath",
	["Improved Frost Ward"] = "Spell_Frost_FrostWard",
	["Improved Frostbolt"] = "Spell_Frost_FrostBolt02",
	["Improved Frostbrand Weapon"] = "Spell_Frost_FrostBrand",
	["Improved Garrote"] = "Ability_Rogue_Garrote",
	["Improved Ghost Wolf"] = "Spell_Nature_SpiritWolf",
	["Improved Gouge"] = "Ability_Gouge",
	["Improved Grace of Air Totem"] = "Spell_Nature_InvisibilityTotem",
	["Improved Grounding Totem"] = "Spell_Nature_GroundingTotem",
	["Improved Hammer of Justice"] = "Spell_Holy_SealOfMight",
	["Improved Hamstring"] = "Ability_ShockWave",
	["Improved Healing Stream Totem"] = "INV_Spear_04",
	["Improved Healing Touch"] = "Spell_Nature_HealingTouch",
	["Improved Healing Wave"] = "Spell_Nature_MagicImmunity",
	["Improved Healing"] = "Spell_Holy_Heal02",
	["Improved Health Funnel"] = "Spell_Shadow_LifeDrain",
	["Improved Healthstone"] = "INV_Stone_04",
	["Improved Heroic Strike"] = "Ability_Rogue_Ambush",
	["Improved Hunter's Mark"] = "Ability_Hunter_SniperShot",
	["Improved Immolate"] = "Spell_Fire_Immolation",
	["Improved Imp"] = "Spell_Shadow_SummonImp",
	["Improved Inner Fire"] = "Spell_Holy_InnerFire",
	["Improved Instant Poison"] = "Ability_Poisons",
	["Improved Intercept"] = "Ability_Rogue_Sprint",
	["Improved Intimidating Shout"] = "Ability_GolemThunderClap",
	["Improved Judgement"] = "Spell_Holy_RighteousFury",
	["Improved Kick"] = "Ability_Kick",
	["Improved Kidney Shot"] = "Ability_Rogue_KidneyShot",
	["Improved Lash of Pain"] = "Spell_Shadow_Curse",
	["Improved Lay on Hands"] = "Spell_Holy_LayOnHands",
	["Improved Lesser Healing Wave"] = "Spell_Nature_HealingWaveLesser",
	["Improved Life Tap"] = "Spell_Shadow_BurningSpirit",
	["Improved Lightning Bolt"] = "Spell_Nature_Lightning",
	["Improved Lightning Shield"] = "Spell_Nature_LightningShield",
	["Improved Magma Totem"] = "Spell_Fire_SelfDestruct",
	["Improved Mana Burn"] = "Spell_Shadow_ManaBurn",
	["Improved Mana Shield"] = "Spell_Shadow_DetectLesserInvisibility",
	["Improved Mana Spring Totem"] = "Spell_Nature_ManaRegenTotem",
	["Improved Mark of the Wild"] = "Spell_Nature_Regeneration",
	["Improved Mend Pet"] = "Ability_Hunter_MendPet",
	["Improved Mind Blast"] = "Spell_Shadow_UnholyFrenzy",
	["Improved Moonfire"] = "Spell_Nature_StarFall",
	["Improved Nature's Grasp"] = "Spell_Nature_NaturesWrath",
	["Improved Overpower"] = "INV_Sword_05",
	["Improved Power Word: Fortitude"] = "Spell_Holy_WordFortitude",
	["Improved Power Word: Shield"] = "Spell_Holy_PowerWordShield",
	["Improved Prayer of Healing"] = "Spell_Holy_PrayerOfHealing02",
	["Improved Psychic Scream"] = "Spell_Shadow_PsychicScream",
	["Improved Pummel"] = "INV_Gauntlets_04",
	["Improved Regrowth"] = "Spell_Nature_ResistNature",
	["Improved Reincarnation"] = "Spell_Nature_Reincarnation",
	["Improved Rejuvenation"] = "Spell_Nature_Rejuvenation",
	["Improved Rend"] = "Ability_Gouge",
	["Improved Renew"] = "Spell_Holy_Renew",
	["Improved Retribution Aura"] = "Spell_Holy_AuraOfLight",
	["Improved Revenge"] = "Ability_Warrior_Revenge",
	["Improved Revive Pet"] = "Ability_Hunter_BeastSoothe",
	["Improved Righteous Fury"] = "Spell_Holy_SealOfFury",
	["Improved Rockbiter Weapon"] = "Spell_Nature_RockBiter",
	["Improved Rupture"] = "Ability_Rogue_Rupture",
	["Improved Sap"] = "Ability_Sap",
	["Improved Scorch"] = "Spell_Fire_SoulBurn",
	["Improved Scorpid Sting"] = "Ability_Hunter_CriticalShot",
	["Improved Seal of Righteousness"] = "Ability_ThunderBolt",
	["Improved Seal of the Crusader"] = "Spell_Holy_HolySmite",
	["Improved Searing Pain"] = "Spell_Fire_SoulBurn",
	["Improved Searing Totem"] = "Spell_Fire_SearingTotem",
	["Improved Serpent Sting"] = "Ability_Hunter_Quickshot",
	["Improved Shadow Bolt"] = "Spell_Shadow_ShadowBolt",
	["Improved Shadow Word: Pain"] = "Spell_Shadow_ShadowWordPain",
	["Improved Shield Bash"] = "Ability_Warrior_ShieldBash",
	["Improved Shield Block"] = "Ability_Defend",
	["Improved Shield Wall"] = "Ability_Warrior_ShieldWall",
	["Improved Shred"] = "Spell_Shadow_VampiricAura",
	["Improved Sinister Strike"] = "Spell_Shadow_RitualOfSacrifice",
	["Improved Slam"] = "Ability_Warrior_DecisiveStrike",
	["Improved Slice and Dice"] = "Ability_Rogue_SliceDice",
	["Improved Spellstone"] = "INV_Misc_Gem_Sapphire_01",
	["Improved Sprint"] = "Ability_Rogue_Sprint",
	["Improved Starfire"] = "Spell_Arcane_StarFire",
	["Improved Stoneclaw Totem"] = "Spell_Nature_StoneClawTotem",
	["Improved Stoneskin Totem"] = "Spell_Nature_StoneSkinTotem",
	["Improved Strength of Earth Totem"] = "Spell_Nature_EarthBindTotem",
	["Improved Succubus"] = "Spell_Shadow_SummonSuccubus",
	["Improved Sunder Armor"] = "Ability_Warrior_Sunder",
	["Improved Taunt"] = "Spell_Nature_Reincarnation",
	["Improved Thorns"] = "Spell_Nature_Thorns",
	["Improved Thunder Clap"] = "Ability_ThunderClap",
	["Improved Tranquility"] = "Spell_Nature_Tranquility",
	["Improved Vampiric Embrace"] = "Spell_Shadow_ImprovedVampiricEmbrace",
	["Improved Vanish"] = "Ability_Vanish",
	["Improved Voidwalker"] = "Spell_Shadow_SummonVoidWalker",
	["Improved Windfury Weapon"] = "Spell_Nature_Cyclone",
	["Improved Wing Clip"] = "Ability_Rogue_Trip",
	["Improved Wrath"] = "Spell_Nature_AbolishMagic",
	["Incinerate"] = "Spell_Fire_FlameShock",
	["Inferno"] = "Spell_Shadow_SummonInfernal",
	["Initiative"] = "Spell_Shadow_Fumble",
	["Inner Fire"] = "Spell_Holy_InnerFire",
	["Inner Focus"] = "Spell_Frost_WindWalkOn",
	["Innervate"] = "Spell_Nature_Lightning",
	["Insect Swarm"] = "Spell_Nature_InsectSwarm",
	["Inspiration"] = "Spell_Holy_LayOnHands",
	["Instant Poison II"] = "Ability_Poisons",
	["Instant Poison III"] = "Ability_Poisons",
	["Instant Poison IV"] = "Ability_Poisons",
	["Instant Poison V"] = "Ability_Poisons",
	["Instant Poison VI"] = "Ability_Poisons",
	["Instant Poison"] = "Ability_Poisons",
	["Intensity"] = "Spell_Fire_LavaSpawn",
	["Intercept"] = "Ability_Rogue_Sprint",
	["Intimidating Shout"] = "Ability_GolemThunderClap",
	["Intimidation"] = "Ability_Devour",
	["Iron Will"] = "Spell_Magic_MageArmor",
	["Judgement of Command"] = "Ability_Warrior_InnerRage",
	["Judgement of Justice"] = "Spell_Holy_SealOfWrath",
	["Judgement of Light"] = "Spell_Holy_HealingAura",
	["Judgement of Righteousness"] = "Ability_ThunderBolt",
	["Judgement of Wisdom"] = "Spell_Holy_RighteousnessAura",
	["Judgement of the Crusader"] = "Spell_Holy_HolySmite",
	["Judgement"] = "Spell_Holy_RighteousFury",
	["Kick"] = "Ability_Kick",
	["Kidney Shot"] = "Ability_Rogue_KidneyShot",
	["Killer Instinct"] = "Spell_Holy_BlessingOfStamina",
	["Kodo Riding"] = "Spell_Nature_Swiftness",
	["Lash of Pain"] = "Spell_Shadow_Curse",
	["Last Stand"] = "Spell_Holy_AshesToAshes",
	["Lasting Judgement"] = "Spell_Holy_HealingAura",
	["Lay on Hands"] = "Spell_Holy_LayOnHands",
	["Leader of the Pack"] = "Spell_Nature_UnyeildingStamina",
	["Leather"] = "INV_Chest_Leather_09",
	["Leatherworking"] = "INV_Misc_ArmorKit_17",
	["Lesser Heal"] = "Spell_Holy_LesserHeal",
	["Lesser Healing Wave"] = "Spell_Nature_HealingWaveLesser",
	["Lesser Invisibility"] = "Spell_Magic_LesserInvisibilty",
	["Lethal Shots"] = "Ability_SearingArrow",
	["Lethality"] = "Ability_CriticalStrike",
	["Levitate"] = "Spell_Holy_LayOnHands",
	["Libram"] = "INV_Misc_Book_11",
	["Life Tap"] = "Spell_Shadow_BurningSpirit",
	["Lightning Bolt"] = "Spell_Nature_Lightning",
	["Lightning Breath"] = "Spell_Nature_Lightning",
	["Lightning Mastery"] = "Spell_Lightning_LightningBolt01",
	["Lightning Reflexes"] = "Spell_Nature_Invisibilty",
	["Lightning Shield"] = "Spell_Nature_LightningShield",
	["Lightwell Renew"] = "Spell_Holy_SummonLightwell",
	["Lightwell"] = "Spell_Holy_SummonLightwell",
	["Long Daze"] = "Spell_Frost_Stun",
	["Mace Specialization"] = "INV_Mace_01",
	["Mace Stun Effect"] = "Spell_Frost_Stun",
	["Mage Armor"] = "Spell_MageArmor",
	["Magma Totem"] = "Spell_Fire_SelfDestruct",
	["Mail"] = "INV_Chest_Chain_05",
	["Malice"] = "Ability_Racial_BloodRage",
	["Mana Burn"] = "Spell_Shadow_ManaBurn",
	["Mana Shield"] = "Spell_Shadow_DetectLesserInvisibility",
	["Mana Spring Totem"] = "Spell_Nature_ManaRegenTotem",
	["Mana Tide Totem"] = "Spell_Frost_SummonWaterElemental",
	["Mangle"] = "Ability_Druid_Mangle.tga",
	["Mark of the Wild"] = "Spell_Nature_Regeneration",
	["Martyrdom"] = "Spell_Nature_Tranquility",
	["Master Demonologist"] = "Spell_Shadow_ShadowPact",
	["Master Summoner"] = "Spell_Shadow_ImpPhaseShift",
	["Master of Deception"] = "Spell_Shadow_Charm",
	["Maul"] = "Ability_Druid_Maul",
	["Mechanostrider Piloting"] = "Spell_Nature_Swiftness",
	["Meditation"] = "Spell_Nature_Sleep",
	["Melee Specialization"] = "INV_Axe_02",
	["Mend Pet"] = "Ability_Hunter_MendPet",
	["Mental Agility"] = "Ability_Hibernation",
	["Mental Strength"] = "Spell_Nature_EnchantArmor",
	["Mind Blast"] = "Spell_Shadow_UnholyFrenzy",
	["Mind Control"] = "Spell_Shadow_ShadowWordDominate",
	["Mind Flay"] = "Spell_Shadow_SiphonMana",
	["Mind Soothe"] = "Spell_Holy_MindSooth",
	["Mind Vision"] = "Spell_Holy_MindVision",
	["Mind-numbing Poison II"] = "Spell_Nature_NullifyDisease",
	["Mind-numbing Poison III"] = "Spell_Nature_NullifyDisease",
	["Mind-numbing Poison"] = "Spell_Nature_NullifyDisease",
	["Mining"] = "Trade_Mining",
	["Mocking Blow"] = "Ability_Warrior_PunishingBlow",
	["Mongoose Bite"] = "Ability_Hunter_SwiftStrike",
	["Monster Slaying"] = "INV_Misc_Head_Dragon_Black",
	["Moonfire"] = "Spell_Nature_StarFall",
	["Moonfury"] = "Spell_Nature_MoonGlow",
	["Moonglow"] = "Spell_Nature_Sentinal",
	["Moonkin Aura"] = "Spell_Nature_MoonGlow",
	["Moonkin Form"] = "Spell_Nature_ForceOfNature",
	["Mortal Shots"] = "Ability_PierceDamage",
	["Mortal Strike"] = "Ability_Warrior_SavageBlow",
	["Multi-Shot"] = "Ability_UpgradeMoonGlaive",
	["Murder"] = "Spell_Shadow_DeathScream",
	["Natural Armor"] = "Spell_Nature_SpiritArmor",
	["Natural Shapeshifter"] = "Spell_Nature_WispSplode",
	["Natural Weapons"] = "INV_Staff_01",
	["Nature Resistance Totem"] = "Spell_Nature_NatureResistanceTotem",
	["Nature Resistance"] = "Spell_Nature_ResistNature",
	["Nature's Focus"] = "Spell_Nature_HealingWaveGreater",
	["Nature's Grace"] = "Spell_Nature_NaturesBlessing",
	["Nature's Grasp"] = "Spell_Nature_NaturesWrath",
	["Nature's Reach"] = "Spell_Nature_NatureTouchGrow",
	["Nature's Swiftness"] = "Spell_Nature_RavenForm",
	["Nightfall"] = "Spell_Shadow_Twilight",
	["Omen of Clarity"] = "Spell_Nature_CrystalBall",
	["One-Handed Axes"] = "INV_Axe_01",
	["One-Handed Maces"] = "INV_Mace_01",
	["One-Handed Swords"] = "Ability_MeleeDamage",
	["One-Handed Weapon Specialization"] = "INV_Sword_20",
	["Opening - No Text"] = "Trade_Engineering",
	["Opening"] = "Trade_Engineering",
	["Opportunity"] = "Ability_Warrior_WarCry",
	["Overpower"] = "Ability_MeleeDamage",
	["Paranoia"] = "Spell_Shadow_AuraOfDarkness",
	["Parry"] = "Ability_Parry",
	["Pathfinding"] = "Ability_Mount_JungleTiger",
	["Perception"] = "Spell_Nature_Sleep",
	["Permafrost"] = "Spell_Frost_Wisp",
	["Pet Aggression"] = "Ability_Druid_Maul",
	["Pet Hardiness"] = "Ability_BullRush",
	["Pet Recovery"] = "Ability_Hibernation",
	["Pet Resistance"] = "Spell_Holy_BlessingOfAgility",
	["Phase Shift"] = "Spell_Shadow_ImpPhaseShift",
	["Pick Lock"] = "Spell_Nature_MoonKey",
	["Pick Pocket"] = "INV_Misc_Bag_11",
	["Piercing Howl"] = "Spell_Shadow_DeathScream",
	["Piercing Ice"] = "Spell_Frost_Frostbolt",
	["Plate Mail"] = "INV_Chest_Plate01",
	["Poison Cleansing Totem"] = "Spell_Nature_PoisonCleansingTotem",
	["Poisons"] = "Trade_BrewPoison",
	["Polearm Specialization"] = "INV_Weapon_Halbard_01",
	["Polearms"] = "INV_Spear_06",
	["Polymorph"] = "Spell_Nature_Polymorph",
	["Polymorph: Pig"] = "Spell_Magic_PolymorphPig",
	["Polymorph: Turtle"] = "Ability_Hunter_Pet_Turtle",
	["Portal: Darnassus"] = "Spell_Arcane_PortalDarnassus",
	["Portal: Ironforge"] = "Spell_Arcane_PortalIronForge",
	["Portal: Orgrimmar"] = "Spell_Arcane_PortalOrgrimmar",
	["Portal: Stormwind"] = "Spell_Arcane_PortalStormWind",
	["Portal: Thunder Bluff"] = "Spell_Arcane_PortalThunderBluff",
	["Portal: Undercity"] = "Spell_Arcane_PortalUnderCity",
	["Pounce Bleed"] = "Ability_Druid_SupriseAttack",
	["Pounce"] = "Ability_Druid_SupriseAttack",
	["Power Infusion"] = "Spell_Holy_PowerInfusion",
	["Power Word: Fortitude"] = "Spell_Holy_WordFortitude",
	["Power Word: Shield"] = "Spell_Holy_PowerWordShield",
	["Prayer of Fortitude"] = "Spell_Holy_PrayerOfFortitude",
	["Prayer of Healing"] = "Spell_Holy_PrayerOfHealing02",
	["Prayer of Shadow Protection"] = "Spell_Holy_PrayerofShadowProtection",
	["Prayer of Spirit"] = "Spell_Holy_PrayerofSpirit",
	["Precision"] = "Ability_Marksmanship",
	["Predatory Strikes"] = "Ability_Hunter_Pet_Cat",
	["Premeditation"] = "Spell_Shadow_Possession",
	["Preparation"] = "Spell_Shadow_AntiShadow",
	["Presence of Mind"] = "Spell_Nature_EnchantArmor",
	["Primal Fury"] = "Ability_Racial_Cannibalize",
	["Prowl"] = "Ability_Druid_SupriseAttack",
	["Psychic Scream"] = "Spell_Shadow_PsychicScream",
	["Pummel"] = "INV_Gauntlets_04",
	["Purge"] = "Spell_Nature_Purge",
	["Purification"] = "Spell_Frost_WizardMark",
	["Purify"] = "Spell_Holy_Purify",
	["Pursuit of Justice"] = "Spell_Holy_PersuitofJustice",
	["Pyroblast"] = "Spell_Fire_Fireball02",
	["Pyroclasm"] = "Spell_Fire_Volcano",
	["Quickness"] = "Ability_Racial_ShadowMeld",
	["Rain of Fire"] = "Spell_Shadow_RainOfFire",
	["Rake"] = "Ability_Druid_Disembowel",
	["Ram Riding"] = "Spell_Nature_Swiftness",
	["Ranged Weapon Specialization"] = "INV_Weapon_Rifle_06",
	["Rapid Concealment"] = "Ability_Ambush",
	["Rapid Fire"] = "Ability_Hunter_RunningShot",
	["Raptor Riding"] = "Spell_Nature_Swiftness",
	["Raptor Strike"] = "Ability_MeleeDamage",
	["Ravage"] = "Ability_Druid_Ravage",
	["Readiness"] = "Spell_Nature_Sleep",
	["Rebirth"] = "Spell_Nature_Reincarnation",
	["Recklessness"] = "Ability_CriticalStrike",
	["Reckoning"] = "Spell_Holy_BlessingOfStrength",
	["Redemption"] = "Spell_Holy_Resurrection",
	["Redoubt"] = "Ability_Defend",
	["Reflection"] = "Spell_Frost_WindWalkOn",
	["Regeneration"] = "Spell_Nature_Regenerate",
	["Regrowth"] = "Spell_Nature_ResistNature",
	["Reincarnation"] = "Spell_Nature_Reincarnation",
	["Rejuvenation"] = "Spell_Nature_Rejuvenation",
	["Relentless Strikes"] = "Ability_Warrior_DecisiveStrike",
	["Remorseless Attacks"] = "Ability_FiegnDead",
	["Remove Curse"] = "Spell_Holy_RemoveCurse",
	["Remove Insignia"] = "Temp",
	["Remove Lesser Curse"] = "Spell_Nature_RemoveCurse",
	["Rend"] = "Ability_Gouge",
	["Renew"] = "Spell_Holy_Renew",
	["Repentance"] = "Spell_Holy_PrayerOfHealing",
	["Resurrection"] = "Spell_Holy_Resurrection",
	["Retaliation"] = "Ability_Warrior_Challange",
	["Retribution Aura"] = "Spell_Holy_AuraOfLight",
	["Revenge Stun"] = "Ability_Warrior_Revenge",
	["Revenge"] = "Ability_Warrior_Revenge",
	["Reverberation"] = "Spell_Frost_FrostWard",
	["Revive Pet"] = "Ability_Hunter_BeastSoothe",
	["Righteous Fury"] = "Spell_Holy_SealOfFury",
	["Rip"] = "Ability_GhoulFrenzy",
	["Riposte"] = "Ability_Warrior_Challange",
	["Ritual of Doom Effect"] = "Spell_Arcane_PortalDarnassus",
	["Ritual of Doom"] = "Spell_Shadow_AntiMagicShell",
	["Ritual of Summoning"] = "Spell_Shadow_Twilight",
	["Rockbiter Weapon"] = "Spell_Nature_RockBiter",
	["Rogue Passive"] = "Ability_Stealth",
	["Ruin"] = "Spell_Shadow_ShadowWordPain",
	["Rupture"] = "Ability_Rogue_Rupture",
	["Ruthlessness"] = "Ability_Druid_Disembowel",
	["Sacrifice"] = "Spell_Shadow_SacrificialShield",
	["Safe Fall"] = "INV_Feather_01",
	["Sanctity Aura"] = "Spell_Holy_MindVision",
	["Sap"] = "Ability_Sap",
	["Savage Fury"] = "Ability_Druid_Ravage",
	["Savage Strikes"] = "Ability_Racial_BloodRage",
	["Scare Beast"] = "Ability_Druid_Cower",
	["Scatter Shot"] = "Ability_GolemStormBolt",
	["Scorch"] = "Spell_Fire_SoulBurn",
	["Scorpid Poison"] = "Ability_PoisonSting",
	["Scorpid Sting"] = "Ability_Hunter_CriticalShot",
	["Screech"] = "Ability_Hunter_Pet_Bat",
	["Seal Fate"] = "Spell_Shadow_ChillTouch",
	["Seal of Command"] = "Ability_Warrior_InnerRage",
	["Seal of Justice"] = "Spell_Holy_SealOfWrath",
	["Seal of Light"] = "Spell_Holy_HealingAura",
	["Seal of Righteousness"] = "Ability_ThunderBolt",
	["Seal of Wisdom"] = "Spell_Holy_RighteousnessAura",
	["Seal of the Crusader"] = "Spell_Holy_HolySmite",
	["Searing Light"] = "Spell_Holy_SearingLightPriest",
	["Searing Pain"] = "Spell_Fire_SoulBurn",
	["Searing Totem"] = "Spell_Fire_SearingTotem",
	["Seduction"] = "Spell_Shadow_MindSteal",
	["Sense Demons"] = "Spell_Shadow_Metamorphosis",
	["Sense Undead"] = "Spell_Holy_SenseUndead",
	["Sentry Totem"] = "Spell_Nature_RemoveCurse",
	["Serpent Sting"] = "Ability_Hunter_Quickshot",
	["Setup"] = "Spell_Nature_MirrorImage",
	["Shackle Undead"] = "Spell_Nature_Slow",
	["Shadow Affinity"] = "Spell_Shadow_ShadowWard",
	["Shadow Bolt"] = "Spell_Shadow_ShadowBolt",
	["Shadow Focus"] = "Spell_Shadow_BurningSpirit",
	["Shadow Mastery"] = "Spell_Shadow_ShadeTrueSight",
	["Shadow Protection"] = "Spell_Shadow_AntiShadow",
	["Shadow Reach"] = "Spell_Shadow_ChillTouch",
	["Shadow Resistance Aura"] = "Spell_Shadow_SealOfKings",
	["Shadow Resistance"] = "Spell_Shadow_AntiShadow",
	["Shadow Trance"] = "Spell_Shadow_Twilight",
	["Shadow Ward"] = "Spell_Shadow_AntiShadow",
	["Shadow Weaving"] = "Spell_Shadow_BlackPlague",
	["Shadow Word: Pain"] = "Spell_Shadow_ShadowWordPain",
	["Shadowburn"] = "Spell_Shadow_ScourgeBuild",
	["Shadowform"] = "Spell_Shadow_Shadowform",
	["Shadowguard"] = "Spell_Nature_LightningShield",
	["Shadowmeld Passive"] = "Ability_Ambush",
	["Shadowmeld"] = "Ability_Ambush",
	["Sharpened Claws"] = "INV_Misc_MonsterClaw_04",
	["Shatter"] = "Spell_Frost_FrostShock",
	["Shell Shield"] = "Ability_Hunter_Pet_Turtle",
	["Shield Bash"] = "Ability_Warrior_ShieldBash",
	["Shield Block"] = "Ability_Defend",
	["Shield Slam"] = "INV_Shield_05",
	["Shield Specialization"] = "INV_Shield_06",
	["Shield Wall"] = "Ability_Warrior_ShieldWall",
	["Shield"] = "INV_Shield_04",
	["Shoot Bow"] = "Ability_Marksmanship",
	["Shoot Crossbow"] = "Ability_Marksmanship",
	["Shoot Gun"] = "Ability_Marksmanship",
	["Shoot"] = "Ability_ShootWand",
	["Shred"] = "Spell_Shadow_VampiricAura",
	["Silence"] = "Spell_Shadow_ImpPhaseShift",
	["Silent Resolve"] = "Spell_Nature_ManaRegenTotem",
	["Sinister Strike"] = "Spell_Shadow_RitualOfSacrifice",
	["Siphon Life"] = "Spell_Shadow_Requiem",
	["Skinning"] = "INV_Misc_Pelt_Wolf_01",
	["Slam"] = "Ability_Warrior_DecisiveStrike",
	["Slice and Dice"] = "Ability_Rogue_SliceDice",
	["Slow Fall"] = "Spell_Magic_FeatherFall",
	["Smelting"] = "Spell_Fire_FlameBlades",
	["Smite"] = "Spell_Holy_HolySmite",
	["Soothe Animal"] = "Ability_Hunter_BeastSoothe",
	["Soothing Kiss"] = "Spell_Shadow_SoothingKiss",
	["Soul Fire"] = "Spell_Fire_Fireball02",
	["Soul Link"] = "Spell_Shadow_GatherShadows",
	["Soulstone Resurrection"] = "INV_Misc_Orb_04",
	["Spell Lock"] = "Spell_Shadow_MindRot",
	["Spell Warding"] = "Spell_Holy_SpellWarding",
	["Spirit Bond"] = "Ability_Druid_DemoralizingRoar",
	["Spirit Tap"] = "Spell_Shadow_Requiem",
	["Spirit of Redemption"] = "INV_Enchant_EssenceEternalLarge",
	["Spiritual Focus"] = "Spell_Arcane_Blink",
	["Spiritual Guidance"] = "Spell_Holy_SpiritualGuidence",
	["Spiritual Healing"] = "Spell_Nature_MoonGlow",
	["Sprint"] = "Ability_Rogue_Sprint",
	["Starfire"] = "Spell_Arcane_StarFire",
	["Starshards"] = "Spell_Arcane_StarFire",
	["Staves"] = "INV_Staff_08",
	["Stealth"] = "Ability_Stealth",
	["Stoneclaw Totem"] = "Spell_Nature_StoneClawTotem",
	["Stoneform"] = "Spell_Shadow_UnholyStrength",
	["Stoneskin Totem"] = "Spell_Nature_StoneSkinTotem",
	["Stormstrike"] = "Spell_Holy_SealOfMight",
	["Strength of Earth Totem"] = "Spell_Nature_EarthBindTotem",
	["Stuck"] = "Spell_Shadow_Teleport",
	["Subtlety"] = "Ability_EyeOfTheOwl",
	["Suffering"] = "Spell_Shadow_BlackPlague",
	["Summon Charger"] = "Ability_Mount_Charger",
	["Summon Dreadsteed"] = "Ability_Mount_Dreadsteed",
	["Summon Felhunter"] = "Spell_Shadow_SummonFelHunter",
	["Summon Felsteed"] = "Spell_Nature_Swiftness",
	["Summon Imp"] = "Spell_Shadow_SummonImp",
	["Summon Succubus"] = "Spell_Shadow_SummonSuccubus",
	["Summon Voidwalker"] = "Spell_Shadow_SummonVoidWalker",
	["Summon Warhorse"] = "Spell_Nature_Swiftness",
	["Sunder Armor"] = "Ability_Warrior_Sunder",
	["Suppression"] = "Spell_Shadow_UnsummonBuilding",
	["Surefooted"] = "Ability_Kick",
	["Survivalist"] = "Spell_Shadow_Twilight",
	["Sweeping Strikes"] = "Ability_Rogue_SliceDice",
	["Swipe"] = "INV_Misc_MonsterClaw_03",
	["Sword Specialization"] = "INV_Sword_27",
	["Tactical Mastery"] = "Spell_Nature_EnchantArmor",
	["Tailoring"] = "Trade_Tailoring",
	["Tainted Blood"] = "Spell_Shadow_LifeDrain",
	["Tame Beast"] = "Ability_Hunter_BeastTaming",
	["Tamed Pet Passive"] = "Ability_Mount_PinkTiger",
	["Taunt"] = "Spell_Nature_Reincarnation",
	["Teleport: Darnassus"] = "Spell_Arcane_TeleportDarnassus",
	["Teleport: Ironforge"] = "Spell_Arcane_TeleportIronForge",
	["Teleport: Moonglade"] = "Spell_Arcane_TeleportMoonglade",
	["Teleport: Orgrimmar"] = "Spell_Arcane_TeleportOrgrimmar",
	["Teleport: Stormwind"] = "Spell_Arcane_TeleportStormWind",
	["Teleport: Thunder Bluff"] = "Spell_Arcane_TeleportThunderBluff",
	["Teleport: Undercity"] = "Spell_Arcane_TeleportUnderCity",
	["The Human Spirit"] = "INV_Enchant_ShardBrilliantSmall",
	["Thick Hide"] = "INV_Misc_Pelt_Bear_03",
	["Thorns"] = "Spell_Nature_Thorns",
	["Throw"] = "Ability_Throw",
	["Throwing Specialization"] = "INV_ThrowingAxe_03",
	["Throwing Weapon Specialization"] = "INV_ThrowingKnife_01",
	["Thrown"] = "INV_ThrowingKnife_02",
	["Thunder Clap"] = "Spell_Nature_ThunderClap",
	["Thundering Strikes"] = "Ability_ThunderBolt",
	["Thunderstomp"] = "Ability_Hunter_Pet_Gorilla",
	["Tidal Focus"] = "Spell_Frost_ManaRecharge",
	["Tidal Mastery"] = "Spell_Nature_Tranquility",
	["Tiger Riding"] = "Spell_Nature_Swiftness",
	["Tiger's Fury"] = "Ability_Mount_JungleTiger",
	["Torment"] = "Spell_Shadow_GatherShadows",
	["Totem"] = "Spell_Nature_StoneClawTotem",
	["Totemic Focus"] = "Spell_Nature_MoonGlow",
	["Touch of Weakness"] = "Spell_Shadow_DeadofNight",
	["Toughness"] = "Spell_Holy_Devotion",
	["Track Beasts"] = "Ability_Tracking",
	["Track Demons"] = "Spell_Shadow_SummonFelHunter",
	["Track Dragonkin"] = "INV_Misc_Head_Dragon_01",
	["Track Elementals"] = "Spell_Frost_SummonWaterElemental",
	["Track Giants"] = "Ability_Racial_Avatar",
	["Track Hidden"] = "Ability_Stealth",
	["Track Humanoids"] = "Ability_Tracking",
	["Track Undead"] = "Spell_Shadow_DarkSummoning",
	["Tranquil Air Totem"] = "Spell_Nature_Brilliance",
	["Tranquil Spirit"] = "Spell_Holy_ElunesGrace",
	["Tranquility"] = "Spell_Nature_Tranquility",
	["Tranquilizing Shot"] = "Spell_Nature_Drowsy",
	["Trap Mastery"] = "Ability_Ensnare",
	["Travel Form"] = "Ability_Druid_TravelForm",
	["Tremor Totem"] = "Spell_Nature_TremorTotem",
	["Trueshot Aura"] = "Ability_TrueShot",
	["Turn Undead"] = "Spell_Holy_TurnUndead",
	["Two-Handed Axes and Maces"] = "INV_Axe_10",
	["Two-Handed Axes"] = "INV_Axe_04",
	["Two-Handed Maces"] = "INV_Mace_04",
	["Two-Handed Swords"] = "Ability_MeleeDamage",
	["Two-Handed Weapon Specialization"] = "INV_Axe_09",
	["Unarmed"] = "Ability_GolemThunderClap",
	["Unbreakable Will"] = "Spell_Magic_MageArmor",
	["Unbridled Wrath Effect"] = "Spell_Nature_StoneClawTotem",
	["Unbridled Wrath"] = "Spell_Nature_StoneClawTotem",
	["Undead Horsemanship"] = "Spell_Nature_Swiftness",
	["Underwater Breathing"] = "Spell_Shadow_DemonBreath",
	["Unending Breath"] = "Spell_Shadow_DemonBreath",
	["Unholy Power"] = "Spell_Shadow_ShadowWordDominate",
	["Unleashed Fury"] = "Ability_BullRush",
	["Unyielding Faith"] = "Spell_Holy_UnyieldingFaith",
	["Vampiric Embrace"] = "Spell_Shadow_UnsummonBuilding",
	["Vanish"] = "Ability_Vanish",
	["Vanished"] = "Ability_Vanish",
	["Vengeance"] = "Spell_Nature_Purge",
	["Vigor"] = "Spell_Nature_EarthBindTotem",
	["Vile Poisons"] = "Ability_Rogue_FeignDeath",
	["Vindication"] = "Spell_Holy_Vindication",
	["Viper Sting"] = "Ability_Hunter_AimedShot",
	["Volley"] = "Ability_Marksmanship",
	["Wand Specialization"] = "INV_Wand_01",
	["Wands"] = "Ability_ShootWand",
	["War Stomp"] = "Ability_WarStomp",
	["Water Breathing"] = "Spell_Shadow_DemonBreath",
	["Water Walking"] = "Spell_Frost_WindWalkOn",
	["Weakened Soul"] = "Spell_Holy_AshesToAshes",
	["Whirlwind"] = "Ability_Whirlwind",
	["Will of the Forsaken"] = "Spell_Shadow_RaiseDead",
	["Windfury Totem"] = "Spell_Nature_Windfury",
	["Windfury Weapon"] = "Spell_Nature_Cyclone",
	["Windwall Totem"] = "Spell_Nature_EarthBind",
	["Wing Clip"] = "Ability_Rogue_Trip",
	["Winter's Chill"] = "Spell_Frost_ChillingBlast",
	["Wisp Spirit"] = "Spell_Nature_WispSplode",
	["Wolf Riding"] = "Spell_Nature_Swiftness",
	["Wound Poison II"] = "INV_Misc_Herb_16",
	["Wound Poison III"] = "INV_Misc_Herb_16",
	["Wound Poison IV"] = "INV_Misc_Herb_16",
	["Wound Poison"] = "INV_Misc_Herb_16",
	["Wrath"] = "Spell_Nature_AbolishMagic",
	["Wyvern Sting"] = "INV_Spear_02"
}

local staticBuffDurations = {
    ['Abolish Disease'] = 20,
    ['Abolish Magic'] = 5,
    ['Abolish Poison'] = 8,
    ['Acid Breath'] = 45,
    ['Acid Slime'] = 30,
    ['Acid Spit'] = 30,
    ['Acid Splash'] = 30,
    ['Acid Spray'] = 10,
    ['Acid Volley'] = 25,
    ['Acid of Hakkar'] = 60,
    ['Adaptive Warding'] = 30,
    ["Admiral's Hat"] = 600,
    ['Adrenaline Rush'] = 15,
    ['Aegis of Preservation'] = 20,
    ['Aegis of Ragnaros'] = 300,
    ['Aftermath'] = 5,
    ['Agility'] = 1800,
    ['Agonizing Pain'] = 15,
    ['Air Bubbles'] = 4,
    ['Alterac Spring Water'] = 600,
    ['Amplify Curse'] = 30,
    ['Amplify Magic'] = 600,
    ["Ancestor's Vengeance"] = 20,
    ['Ancestral Fortitude'] = 15,
    ['Ancient Despair'] = 5,
    ['Ancient Dread'] = 900,
    ['Ancient Hysteria'] = 900,
    ['Anti-Magic Shield'] = 10,
    ["Anub'Rekhan's Aura"] = 5,
    ['Aquatic Miasma'] = 3600,
    ["Arantir's Rage"] = 6,
    ['Arcane Bomb'] = 5,
    ['Arcane Brilliance'] = 3600,
    ['Arcane Bubble'] = 8,
    ['Arcane Burst'] = 8,
    ['Arcane Elixir'] = 1800,
    ['Arcane Focus'] = 30,
    ['Arcane Infused'] = 10,
    ['Arcane Intellect'] = 1800,
    ['Arcane Might'] = 1800,
    ['Arcane Potency'] = 20,
    ['Arcane Power'] = 15,
    ['Arcane Resistance'] = 30,
    ['Arcane Weakness'] = 45,
    ['Argent Avenger'] = 10,
    ['Argent Avenger'] = 10,
    ['Argent Dawn'] = 10,
    ['Armor Shatter'] = 45,
    ['Armor'] = 1800,
    ["Arugal's Curse"] = 10,
    ['Ascendance'] = 20,
    ["Atal'ai Corpse Eat"] = 12,
    ["Atal'ai Poison"] = 30,
    ["Atal'ai Poison"] = 30,
    ['Attack Order'] = 10,
    ['Attack'] = 15,
    ['Aura of Agony'] = 8,
    ['Aura of Command'] = 30,
    ['Aura of Command'] = 30,
    ['Aura of Fear'] = 3,
    ['Aura of Frost'] = 5,
    ['Aura of Protection'] = 20,
    ['Aura of Shock'] = 300,
    ['Aura of the Blue Dragon'] = 15,
    ['Aural Shock'] = 300,
    ['Avatar of Flame'] = 10,
    ['Avatar'] = 15,
    ["Azrethoc's Stomp"] = 5,
    ['Backhand'] = 10,
    ['Badge of the Swarmguard'] = 30,
    ['Balnazzar Transform Stun'] = 5,
    ['Baneful Poison'] = 120,
    ['Banish'] = 30,
    ['Banshee Curse'] = 12,
    ['Banshee Shriek'] = 5,
    ['Barbed Sting'] = 300,
    ['Barkskin'] = 15,
    ["Baron Rivendare's Soul Drain"] = 3,
    ['Bash'] = 4,
    ['Basilisk Skin'] = 5,
    ['Battle Fury'] = 240,
    ['Battle Net'] = 10,
    ['Battle Roar'] = 60,
    ['Battle Shout'] = 180,
    ['Battle Squawk'] = 240,
    ['Beast Claws'] = 10,
    ['Befuddlement'] = 15,
    ['Bellowing Roar'] = 3,
    ['Berserker Rage'] = 10,
    ['Berserker Stance'] = 240,
    ['Berserking'] = 10,
    ['Bestial Wrath'] = 18,
    ['Big Bronze Bomb'] = 2,
    ['Big Iron Bomb'] = 3,
    ['Bile Vomit'] = 20,
    ['Biletoad Infection'] = 180,
    ['Black Arrow'] = 30,
    ['Black March Blessing'] = 6,
    ['Black Rot'] = 1800,
    ['Black Sapphire'] = 11,
    ['Black Sludge'] = 120,
    ['Blackout'] = 3,
    ['Blade Flurry'] = 15,
    ['Bladestorm'] = 9,
    ['Blast Wave'] = 6,
    ['Blaze'] = 30,
    ['Blazing Emblem'] = 15,
    ['Blessed Recovery'] = 6,
    ['Blessing of Aman'] = 1800,
    ['Blessing of Blackfathom'] = 3600,
    ['Blessing of Freedom'] = 10,
    ['Blessing of Kings'] = 300,
    ['Blessing of Light'] = 300,
    ['Blessing of Might'] = 300,
    ['Blessing of Nordrassil'] = 10,
    ['Blessing of Protection'] = 10,
    ['Blessing of Sacrifice'] = 30,
    ['Blessing of Salvation'] = 300,
    ['Blessing of Sanctuary'] = 300,
    ['Blessing of Shahram'] = 20,
    ['Blessing of Thule'] = 8,
    ['Blessing of Wisdom'] = 300,
    ['Blessing of the Black Book'] = 30,
    ['Blessing of the Claw'] = 4,
    ['Blight'] = 60,
    ['Blind'] = 10,
    ['Blind'] = 10,
    ['Blink'] = 1,
    ['Blood Craze'] = 6,
    ['Blood Fury'] = 25,
    ['Blood Siphon'] = 8,
    ['Blood Siphon'] = 8,
    ['Bloodfang'] = 60,
    ['Bloodlust II'] = 30,
    ['Bloodpetal Poison'] = 30,
    ['Bloodrage'] = 10,
    ['Bloodthirst'] = 8,
    ['Bloody Howl'] = 15,
    ['Boar Charge'] = 1,
    ['Bolt Discharge Bramble'] = 120,
    ['Bone Armor'] = 60,
    ['Bone Shards'] = 10,
    ['Bone Shield'] = 300,
    ['Bone Smelt'] = 20,
    ["Bonereaver's Edge"] = 10,
    ['Bottle of Poison'] = 30,
    ['Brain Damage'] = 30,
    ['Brain Freeze'] = 120,
    ['Brain Hacker'] = 30,
    ['Brain Wash'] = 240,
    ['Breath of Fire'] = 5,
    ['Breath of Fire'] = 5,
    ['Breath of Sargeras'] = 90,
    ['Brilliant Light'] = 15,
    ['Brood Affliction: Black'] = 600,
    ['Brood Affliction: Blue'] = 600,
    ['Brood Affliction: Bronze'] = 5,
    ['Brood Affliction: Green'] = 600,
    ['Brood Affliction: Red'] = 600,
    ['Bruise'] = 10,
    ['Bruising Blow'] = 5,
    ['Bubbly Refreshment'] = 1800,
    ['Bull Rush'] = 30,
    ['Burning Adrenaline'] = 20,
    ['Burning Adrenaline'] = 20,
    ['Burning Flesh'] = 21,
    ['Burning Spirit'] = 180,
    ['Burning Winds'] = 8,
    ['Burst of Knowledge'] = 10,
    ['Buttermilk Delight'] = 3600,
    ['Cadaver Stun'] = 3,
    ['Cadaver Worms'] = 600,
    ['Call Reavers'] = 600,
    ['Call of the Grave'] = 60,
    ['Calm Dragonkin'] = 30,
    ['Cannibalize'] = 10,
    ['Capture Felhound Spirit'] = 9,
    ['Capture Infernal Spirit'] = 9,
    ['Capture Spirit'] = 9,
    ['Capture Treant'] = 5,
    ['Cause Insanity'] = 9,
    ['Cauterizing Flames'] = 900,
    ['Celebrate Good Times!'] = 1800,
    ['Chains of Ice'] = 20,
    ["Chains of Kel'Thuzad"] = 20,
    ['Challenger is Dazed'] = 30,
    ['Challenging Roar'] = 6,
    ['Challenging Shout'] = 6,
    ['Chaos Fire'] = 60,
    ['Chaotic Focus'] = 1800,
    ['Charge (TEST)'] = 1,
    ['Charge Stun'] = 1,
    ['Charisma'] = 30,
    ['Cheap Shot'] = 4,
    ['Cheap Shot'] = 4,
    ['Cheat Death'] = 5,
    ['Cheetah Sprint'] = 4,
    ['Chest Pains'] = 5,
    ['Chill Nova'] = 10,
    ['Chill'] = 15,
    ['Chilled'] = 5,
    ['Chilling Breath'] = 12,
    ['Chilling Touch'] = 8,
    ['Chilling Touch'] = 8,
    ['Chitinous Spikes'] = 30,
    ['Chromatic Chaos'] = 300,
    ['Chromatic Infusion'] = 15,
    ['Chromatic Mutation'] = 300,
    ['Chromatic Resistance'] = 7200,
    ['Circle of Flame'] = 10,
    ['Claw Grasp'] = 4,
    ['Clearcasting'] = 15,
    ['Cleave Armor'] = 20,
    ['Cloak of Fire'] = 15,
    ['Cloaking'] = 10,
    ['Cobrahn Serpent Form'] = 300,
    ['Cold Eye'] = 15,
    ['Concussion Blow'] = 5,
    ['Concussive Shot'] = 4,
    ['Cone of Cold'] = 8,
    ['Conflagration'] = 10,
    ['Consume Shadows'] = 10,
    ['Consuming Shadows'] = 15,
    ['Contagion of Rot'] = 240,
    ['Control Machine'] = 60,
    ['Control Shredder'] = 1800,
    ['Copy of Poison Bolt Volley'] = 10,
    ['Copy of Wandering Plague'] = 300,
    ['Corrosive Acid Breath'] = 30,
    ['Corrosive Acid Spit'] = 10,
    ['Corrosive Acid'] = 300,
    ['Corrosive Ooze'] = 60,
    ['Corrosive Poison'] = 30,
    ['Corrosive Venom Spit'] = 10,
    ['Corrupt Healing'] = 30,
    ['Corrupted Agility'] = 4,
    ['Corrupted Fear'] = 2,
    ['Corrupted Healing'] = 30,
    ['Corrupted Intellect'] = 4,
    ['Corrupted Mind'] = 60,
    ['Corrupted Spirit'] = 4,
    ['Corrupted Stamina'] = 4,
    ['Corrupted Strength'] = 4,
    ['Corruption of the Earth'] = 10,
    ['Corruption'] = 18,
    ['Counterattack'] = 5,
    ['Counterspell - Silenced'] = 4,
    ['Cowardly Flight'] = 30,
    ['Cowering Roar'] = 5,
    ['Cozy Fire'] = 60,
    ['Cracking Stone'] = 180,
    ['Crash of Waves'] = 10,
    ['Crazed Hunger'] = 6,
    ['Crazed'] = 60,
    ['Creature - Frog Form'] = 60,
    ['Creature of Nightmare'] = 30,
    ['Creeper Venom'] = 600,
    ['Creeping Mold'] = 15,
    ['Creeping Plague'] = 20,
    ['Cripple'] = 15,
    ['Crippling Poison'] = 12,
    ['Critical Strike'] = 30,
    ['Crusader Strike'] = 30,
    ["Crusader's Hammer"] = 4,
    ["Crusader's Wrath"] = 10,
    ['Crush Armor'] = 30,
    ['Crystal Flash'] = 15,
    ['Crystal Force'] = 1800,
    ['Crystal Gaze'] = 6,
    ['Crystal Prison'] = 18,
    ['Crystal Protection'] = 60,
    ['Crystal Restore'] = 15,
    ['Crystal Spire'] = 600,
    ['Crystal Ward'] = 1800,
    ['Crystal Yield'] = 120,
    ['Crystalline Slumber'] = 15,
    ['Crystallize'] = 6,
    ['Cthun Vulnerable'] = 45,
    ['Curse of Agony'] = 24,
    ['Curse of Blackheart'] = 180,
    ['Curse of Blood'] = 20,
    ['Curse of Darkmaster'] = 60,
    ['Curse of Deadwood'] = 120,
    ['Curse of Doom'] = 60,
    ['Curse of Dreadmaul'] = 60,
    ['Curse of Exhaustion'] = 12,
    ['Curse of Hakkar'] = 120,
    ['Curse of Impotence'] = 120,
    ['Curse of Mending'] = 180,
    ['Curse of Recklessness'] = 120,
    ['Curse of Shadow'] = 300,
    ['Curse of Shahram'] = 10,
    ['Curse of Stalvan'] = 600,
    ['Curse of Thorns'] = 180,
    ['Curse of Thule'] = 240,
    ['Curse of Timmy'] = 60,
    ['Curse of Tongues'] = 30,
    ["Curse of Tuten'kash"] = 900,
    ['Curse of Vengeance'] = 900,
    ['Curse of Weakness'] = 120,
    ['Curse of the Darkmaster'] = 60,
    ['Curse of the Deadwood'] = 120,
    ['Curse of the Elemental Lord'] = 15,
    ['Curse of the Elements'] = 300,
    ['Curse of the Eye'] = 120,
    ['Curse of the Fallen Magram'] = 900,
    ['Curse of the Firebrand'] = 300,
    ['Curse of the Plague Rat'] = 14,
    ['Curse of the Plaguebringer'] = 10,
    ['Curse of the Shadowhorn'] = 300,
    ['Curse of the Tribes'] = 1800,
    ['Cursed Blade'] = 20,
    ['Cursed Blood'] = 600,
    ['Damage Absorb'] = 15,
    ['Damage Shield'] = 10,
    ['Dampen Magic'] = 600,
    ['Dark Desire'] = 3600,
    ['Dark Iron Bomb'] = 4,
    ['Dark Plague'] = 90,
    ['Dark Sludge'] = 300,
    ['Dark Wispers'] = 600,
    ['Darken Vision'] = 12,
    ['Dash'] = 15,
    ['Daunting Growl'] = 30,
    ['Dazed'] = 4,
    ['Deadful Fright'] = 5,
    ['Deadly Acid'] = 10,
    ['Deadly Leech Poison'] = 45,
    ['Deadly Poison II'] = 12,
    ['Deadly Poison III'] = 12,
    ['Deadly Poison IV'] = 12,
    ['Deadly Poison V'] = 12,
    ['Deadly Poison'] = 12,
    ['Deadly Toxin II'] = 12,
    ['Deadly Toxin III'] = 12,
    ['Deadly Toxin IV'] = 12,
    ['Deadly Toxin'] = 12,
    ['Deafening Screech'] = 8,
    ['Death Bed'] = 10,
    ['Death Coil'] = 3,
    ['Death Wish'] = 30,
    ['Debilitate'] = 15,
    ['Debilitating Charge'] = 8,
    ['Debilitating Touch'] = 120,
    ['Decayed Strength'] = 30,
    ['Decimate'] = 30,
    ['Decrepit Fever'] = 21,
    ['Decrepit Fever'] = 21,
    ['Deep Sleep'] = 10,
    ['Deep Wound'] = 12,
    ['Defensive Stance'] = 180,
    ['Defiling Aura'] = 5,
    ['Defiling Aura'] = 5,
    ["Delusions of Jin'do"] = 20,
    ['Demon Armor'] = 1800,
    ['Demon Skin'] = 1800,
    ['Demonfork'] = 25,
    ['Demonic Frenzy'] = 30,
    ['Demonic Safricice'] = 1800,
    ['Demonic TranstringFormation'] = 15,
    ['Demoralizing Roar'] = 30,
    ['Demoralizing Shout'] = 30,
    ['Deserter'] = 900,
    ['Destiny'] = 10,
    ['Detect Demon'] = 3600,
    ['Detect Greater Invisibility'] = 600,
    ['Detect Invisibility'] = 600,
    ['Detect Lesser Invisibility'] = 600,
    ['Detect Magic'] = 120,
    ['Detect Undead'] = 3600,
    ['Deterrence'] = 10,
    ['Detonate Mana'] = 5,
    ['Devilsaur Barb'] = 10,
    ['Devilsaur Fury'] = 20,
    ['Devilsaur Fury'] = 20,
    ['Devouring Plague'] = 24,
    ['Devouring Plague'] = 24,
    ['Diamond Flask'] = 60,
    ['Digestive Acid'] = 5,
    ['Dire Brew'] = 3600,
    ['Disarm'] = 10,
    ['Discombobulate'] = 12,
    ['Disease Buffet'] = 20,
    ['Diseased Shot'] = 10,
    ['Diseased Slime'] = 120,
    ['Diseased Spit'] = 10,
    ['Disjunction'] = 300,
    ['Dismember'] = 10,
    ['Dismounting Shot'] = 2,
    ['Dismounting Shot'] = 2,
    ['Dissolve Armor'] = 30,
    ['Distilled Wisdom'] = 7200,
    ['Distracting Pain'] = 15,
    ['Distracting Spit'] = 15,
    ['Dive'] = 15,
    ['Divine Protection'] = 6,
    ['Divine Shield'] = 12,
    ['Divine Spirit'] = 1800,
    ['Dominate Mind'] = 15,
    ['Domination'] = 15,
    ['Dominion of Soul'] = 60,
    ['Dragonbreath Chili'] = 600,
    ['Drain Life'] = 5,
    ['Drain Mana'] = 5,
    ['Drain Soul'] = 15,
    ['Draw Spirit'] = 5,
    ['Draw from the Earth']	= 10,
    ['Draw of Thistlenettle'] = 8,
    ['Dream Vision'] = 120,
    ['Dreamless Sleep'] = 12,
    ['Dredge Sickness'] = 300,
    ['Drink Disease Bottle'] = 10,
    ['Drink'] = 30,
    ['Drowning Death'] = 300,
    ["Druid's Slumber"] = 15,
    ['Drunken Pit Crew'] = 30,
    ['Drunken Rage'] = 15,
    ['Drunken Stupor'] = 3,
    ['Dust Cloud'] = 12,
    ['Dust Cloud'] = 12,
    ['Dust Field'] = 8,
    ['Eagle Claw'] = 15,
    ['Eagle Eye'] = 60,
    ['Earthbind Totem Passive'] = 45,
    ['Earthbind'] = 5,
    ['Earthborer Acid'] = 30,
    ['Earthen Sigil'] = 10,
    ['Earthshaker'] = 3,
    ['Earthstrike'] = 20,
    ['Echoing Roar'] = 20,
    ['Ectoplasmic Distiller'] = 3,
    ['Elderberry Pie'] = 3600,
    ['Electrified Net'] = 10,
    ['Electromagnetic Gigaflux Reactivator'] = 3,
    ['Elemental Armor'] = 60,
    ['Elemental Devastation'] = 10,
    ['Elemental Fire'] = 8,
    ['Elemental Fury'] = 30,
    ['Elemental Vulnerability'] = 30,
    ['Elixir of Brute Force'] = 1800,
    ['Elixir of Brute Force'] = 3600,
    ['Elixir of Demonslaying'] = 300,
    ['Elixir of Dodging'] = 1800,
    ['Elixir of Giants'] = 3600,
    ['Elixir of Resistance'] = 1800,
    ['Elixir of the Giants'] = 3600,
    ['Elixir of the Mongoose'] = 3600,
    ['Elixir of the Sages'] = 3600,
    ["Elune's Blessing"] = 3600,
    ["Elune's Grace"] = 15,
    ['Emeriss Aura'] = 10,
    ['Encasing Webs'] = 6,
    ['Enchanting Lullaby'] = 10,
    ['Encouragement'] = 1800,
    ['Energized Shield'] = 20,
    ['Engulfing Flames'] = 6,
    ["Enigma's Answer"] = 20,
    ['Enlarge'] = 120,
    ['Enrage (druid ability)'] = 10,
    ['Enrage'] = 12,
    ['Enraging Bite'] = 6,
    ['Enraging Howl'] = 30,
    ['Enslave Demon'] = 300,
    ['Enslave'] = 15,
    ['Entangle'] = 10,
    ['Entangling Roots'] = 27,
    ['Enveloping Winds'] = 10,
    ['Epiphany'] = 30,
    ["Eskhandar's Rage"] = 5,
    ["Eskhandar's Rake"] = 30,
    ['Essence of Sapphiron'] = 20,
    ['Essence of the Red'] = 180,
    ['Evasion'] = 15,
    ['Evil Twin'] = 7200,
    ['Evocation'] = 8,
    ['Expose Armor'] = 30,
    ['Expose Weakness'] = 7,
    ['Extra-Dimensional Ghost Revealer'] = 600,
    ['Extract Essence'] = 12,
    ['Eye Peck'] = 12,
    ["Eye of Immol'thar"] = 4,
    ['Eyes of the Beast'] = 60,
    ['Fade Out'] = 2,
    ['Fade'] = 10,
    ['Faerie Fire (Feral)'] = 40,
    ['Faerie Fire'] = 40,
    ['Fake Death'] = 300,
    ['Fanatic Blade'] = 10,
    ['Fang of the Crystal Spider'] = 10,
    ['Far Sight'] = 60,
    ['Fatal Sting'] = 12,
    ['Fatigued'] = 2,
    ['Fear Ward'] = 180,
    ['Fear'] = 20,
    ['Feed Pet Effect'] = 20,
    ['Feedback'] = 15,
    ['Feign Death'] = 360,
    ['Fel Curse Effect'] = 15,
    ['Fel Domination'] = 15,
    ['Fel Energy'] = 1800,
    ['Fel Stamina'] = 1800,
    ['Fel Stomp'] = 3,
    ['Felsh Rot'] = 10,
    ['Felstriker'] = 3,
    ["Fengus' Ferocity"] = 7200,
    ['Feral Charge Effect'] = 4,
    ['Feral Charge'] = 4,
    ['Festering Bite'] = 1800,
    ['Festering Bites'] = 1800,
    ['Fevered Exhaustion'] = 900,
    ['Fevered Fatigue'] = 1800,
    ['Fevered Plague'] = 180,
    ['Fiend Fury'] = 10,
    ['Fire Festival Fortitude'] = 3600,
    ['Fire Festival Fury'] = 3600,
    ['Fire Power'] = 1800,
    ['Fire Protection'] = 3600,
    ['Fire Reflector'] = 5,
    ['Fire Resistance'] = 30,
    ['Fire Shield II'] = 60,
    ['Fire Shield III'] = 30,
    ['Fire Shield IV'] = 15,
    ['Fire Shield'] = 180,
    ['Fire Vulnerability'] = 30,
    ['Fire Ward'] = 30,
    ['Fire Weakness'] = 45,
    ['Fire-Toasted Bun'] = 3600,
    ['Fireball'] = 8,
    ['Fist of Ragnaros'] = 5,
    ['Fist of Shahram'] = 8,
    ['Fist of Stone'] = 12,
    ['Five Fat Finger Exploding Heart Technique'] = 30,
    ['Flame Buffet'] = 20,
    ['Flame Lash'] = 45,
    ['Flame Shock'] = 12,
    ['Flame Spike'] = 9,
    ['Flame Wrath'] = 15,
    ['Flameblade'] = 180,
    ['Flames of Chaos'] = 35,
    ["Flameshocker's Revenge"] = 2,
    ["Flameshocker's Touch"] = 3,
    ['Flamestrike'] = 8,
    ['Flamethrower'] = 2,
    ['Flash Bomb'] = 10,
    ['Flash Freeze'] = 5,
    ['Flash'] = 8,
    ['Flask of the Titans'] = 7200,
    ['Flee'] = 10,
    ['Flight of the Peregrine'] = 15,
    ['Flip Out'] = 3600,
    ['Flow of the Northspring'] = 15,
    ['Flurry'] = 15,
    ['Focused Casting'] = 6,
    ['Food'] = 30,
    ['Forbearance'] = 60,
    ['Force of Will'] = 10,
    ['Forcefield Collapse'] = 20,
    ['Form of the Moonstalker'] = 300,
    ['Forsaken Skill: 2H Axes'] = 60,
    ['Forsaken Skill: 2H Maces'] = 60,
    ['Forsaken Skill: 2H Swords'] = 60,
    ['Forsaken Skill: Axes'] = 60,
    ['Forsaken Skill: Bows'] = 60,
    ['Forsaken Skill: Daggers'] = 60,
    ['Forsaken Skill: Defense'] = 60,
    ['Forsaken Skill: Fire'] = 60,
    ['Forsaken Skill: Frost'] = 60,
    ['Forsaken Skill: Guns'] = 60,
    ['Forsaken Skill: Holy'] = 60,
    ['Forsaken Skill: Maces'] = 60,
    ['Forsaken Skill: Shadow'] = 60,
    ['Forsaken Skill: Staves'] = 60,
    ['Forsaken Skill: Swords'] = 60,
    ['Forsaken Skills'] = 300,
    ['Foul Chill'] = 120,
    ['Free Action'] = 30,
    ['Freeze Solid'] = 10,
    ['Freezing Claw'] = 5,
    ['Freezing Trap Effect'] = 20,
    ['Frenzied Capo the Mean'] = 15,
    ['Frenzied Command'] = 10,
    ['Frenzied Dive'] = 2,
    ['Frenzied Rage'] = 5,
    ['Frenzied Regeneration'] = 10,
    ['Frenzy Effect'] = 8,
    ['Frenzy'] = 8,
    ['Frightalon'] = 60,
    ['Frightening Shriek'] = 6,
    ['Frost Armor'] = 1800,
    ['Frost Aura'] = 5,
    ['Frost Aura'] = 5,
    ['Frost Blast'] = 5,
    ['Frost Breath'] = 10,
    ['Frost Burn'] = 15,
    ['Frost Nova'] = 8,
    ['Frost Oil'] = 1800,
    ['Frost Power'] = 1800,
    ['Frost Protection'] = 3600,
    ['Frost Reflector'] = 5,
    ['Frost Shock'] = 8,
    ['Frost Shot'] = 10,
    ['Frost Trap Aura'] = 30,
    ['Frost Trap'] = 30,
    ['Frost Ward'] = 30,
    ['Frost Weakness'] = 45,
    ['Frost'] = 10,
    ['Frostbite'] = 5,
    ['Frostbolt'] = 9,
    ['Frostbrand Attack'] = 8,
    ['Frostmane Strength'] = 180,
    ["Frostwhisper's Lifeblood"] = 20,
    ['Fungal Bloom'] = 90,
    ['Furbolg Form'] = 180,
    ['Furbolg Medicine Pouch'] = 10,
    ['Furious Anger'] = 60,
    ['ability_hunter_pet_wolf|Furious Howl'] = 10,
    ['spell_nature_strength|Furious Howl'] = 15,
    ['Fury of Forgewright'] = 10,
    ['Fury of the Frostwolf'] = 120,
    ['Garrote'] = 18,
    ['Gathering Speed'] = 180,
    ["Gehennas' Curse"] = 300,
    ["General's Warcry"] = 120,
    ['Geyser'] = 5,
    ['Ghostly Strike'] = 7,
    ['Ghostly'] = 60,
    ['Ghoul Plague'] = 1800,
    ['Ghoul Rot'] = 600,
    ['Gift of Arthas'] = 180,
    ['Gift of Life'] = 20,
    ['Gift of the Wild'] = 3600,
    ['Glacial Roar'] = 3,
    ['Glimpse of Madness'] = 3,
    ['Glyph of Deflection'] = 20,
    ['Gnarlpine Vengance'] = 6,
    ['Gnomish Death Ray'] = 4,
    ['Gnomish Mind Control Cap'] = 20,
    ['Gnomish Rocket Boots'] = 20,
    ['Gnomish Rocket Boots'] = 20,
    ['Goblin Land Mine'] = 60,
    ['Goblin Rocket Boots'] = 20,
    ['Gordok Green Grog'] = 900,
    ['ordok Ogre Suit'] = 600,
    ['Gouge'] = 4,
    ['Gouge'] = 5.5,
    ["Graccu's Mince Meat Fruitcake"] = 20,
    ['Grap Weapon'] = 15,
    ['Grasping Vines'] = 10,
    ['Greater Agility'] = 3600,
    ['Greater Arcane Elixir'] = 3600,
    ['Greater Armor'] = 3600,
    ['Greater Armor'] = 3600,
    ['Greater Blessing of Kings'] = 900,
    ['Greater Blessing of Light'] = 900,
    ['Greater Blessing of Might'] = 900,
    ['Greater Blessing of Salvation'] = 900,
    ['Greater Blessing of Sanctuary'] = 900,
    ['Greater Blessing of Wisdom'] = 900,
    ['Greater Dreamless Sleep'] = 12,
    ['Greater Firepower'] = 1800,
    ['Greater Heal'] = 15,
    ['Greater Intellect'] = 3600,
    ['Greater Invisibility'] = 120,
    ['Greater Mark of the Dawn'] = 3600,
    ['Greater Polymorph'] = 20,
    ['Greater Polymorph'] = 20,
    ['Greater Spellstone'] = 60,
    ['Greater Stoneshield'] = 120,
    ['Greater Water Breathing'] = 3600,
    ['Ground Smash'] = 3,
    ['Ground Stomp'] = 5,
    ['Ground Tremor'] = 2,
    ['Grow'] = 30,
    ['Growing Flames'] = 6,
    ['Growl of Fortitude'] = 300,
    ['Growl'] = 3,
    ['Guardian Effect'] = 15,
    ['Gust of Wind'] = 4,
    ['Gutgore Ripper'] = 30,
    ["Hallow's End Candy"] = 1200,
    ["Hallow's End Fright"] = 6,
    ['Hammer of Justice'] = 6,
    ['Hamstring'] = 15,
    ['Hand Snap'] = 8,
    ['Hand of Thaurissan'] = 5,
    ['Happy Pet'] = 3,
    ['Harden Skin'] = 10,
    ['Harm Prevention Belt'] = 600,
    ['Harsh Winds'] = 1,
    ['Harvest Soul'] = 60,
    ['Haste'] = 30,
    ['Haunted'] = 600,
    ['Haunting Phantoms'] = 300,
    ['Haunting Spirits'] = 10,
    ['Head Butt'] = 2,
    ['Head Crack'] = 20,
    ['Head Smash'] = 2,
    ["Headmaster's Charge"] = 900,
    ['Healing Way'] = 15,
    ['Healing of the Ages'] = 20,
    ['Health Funnel'] = 10,
    ['Health II'] = 3600,
    ['Health III'] = 3600,
    ['Health'] = 3600,
    ['Healthy Spirit'] = 1800,
    ['Heartbroken'] = 3600,
    ['Hellfire'] = 15,
    ['Hemorrhage'] = 15,
    ["Hercular's Ward"] = 5,
    ["Hex of Jammal'an"] = 10,
    ['Hex of Ravenclaw'] = 30,
    ['Hex of Weakness'] = 120,
    ['Hex'] = 10,
    ['Hibernate'] = 40,
    ['Holy Fire'] = 10,
    ['Holy Power'] = 8,
    ['Holy Protection'] = 3600,
    ['Holy Shield'] = 10,
    ['Holy Strength'] = 15,
    ['Holy Sunder'] = 60,
    ['Honorless Target'] = 30,
    ['Hooked Net'] = 10,
    ['Howl of Terror'] = 15,
    ['Howling Blade'] = 30,
    ['Howling Rage'] = 300,
    ["Hunter's Mark"] = 120,
    ['Hurricane'] = 10,
    ['Hyper Coward'] = 10,
    ['Ice Armor'] = 1800,
    ['Ice Barrier'] = 60,
    ['Ice Block'] = 10,
    ['Ice Claw'] = 6,
    ['Ice Nova'] = 2,
    ['Ice Tomb'] = 10,
    ['Icebolt'] = 2,
    ['Icicle'] = 10,
    ['Icy Grasp'] = 5,
    ['Identify Brood'] = 20,
    ['Ignite Flesh'] = 60,
    ['Ignite'] = 4,
    ['Illusion: Black Dragonkin'] = 900,
    ['Immolate'] = 15,
    ['Impact'] = 2,
    ['Improved Blocking'] = 6,
    ['Improved Concussive Shot'] = 3,
    ['Improved Hamstring'] = 5,
    ['Improved Shadow Bolt'] = 10,
    ['Improved Shield Block'] = 2,
    ['Incapacitating Shout'] = 60,
    ['Incite Flames'] = 60,
    ['Increased Agility'] = 600,
    ['Increased Intellect'] = 600,
    ['Increased Spirit'] = 600,
    ['Increased Stamina'] = 600,
    ['Inevitable Doom'] = 10,
    ['Infallible Mind'] = 3600,
    ['Infatuation'] = 1800,
    ['Infected Bite'] = 180,
    ['Infected Spine'] = 300,
    ['Infected Wound'] = 300,
    ['Inferno Effect'] = 2,
    ['Inferno Shell'] = 10,
    ['Inferno'] = 8,
    ['Inner Fire'] = 600,
    ['Innervate'] = 20,
    ['Insect Swarm'] = 12,
    ['Insight'] = 10,
    ['Inspiration'] = 15,
    ['Intellect'] = 1800,
    ['Intense Pain'] = 15,
    ['Intercept Stun'] = 3,
    ['Intimidating Growl'] = 5,
    ['Intimidating Shout'] = 8,
    ['Intimidation'] = 3,
    ['Intoxicating Venom'] = 120,
    ['Invisibility'] = 18,
    ['Invocation of the Wickerman'] = 7200,
    ['Involuntary TranstringFormation'] = 30,
    ['Invulnerability'] = 6,
    ['Iron Grenade'] = 3,
    ["Ishamuhale's Rage"] = 1800,
    ['Jadefire'] = 8,
    ["Jang'thraze"] = 20,
    ["Jin'Zil's Curse"] = 10,
    ['Judgement of Light'] = 10,
    ['Judgement of the Crusader'] = 10,
    ['Judgement of the Crusader'] = 10,
    ['Judgement of the Wisdom'] = 10,
    ['Juju Chill'] = 600,
    ['Juju Ember'] = 600,
    ['Juju Escape'] = 10,
    ['Juju Flurry'] = 20,
    ['Juju Guile'] = 1800,
    ['Juju Might'] = 600,
    ['Juju Power'] = 1800,
    ['Kick - Silenced'] = 2,
    ['Kidney Shot'] = 6,
    ['Kidney Shot'] = 6,
    ['Kiss of the Spider'] = 15,
    ['Knockdown'] = 2,
    ['Knockout'] = 6,
    ['Kodo Stomp'] = 3,
    ["Krazek's Drug"] = 10,
    ["Kreeg's Stout Beatdown"] = 900,
    ['Lacerate'] = 8,
    ['Lacerations'] = 60,
    ['Lag'] = 10,
    ['Large Copper Bomb'] = 1,
    ['Lash of Submission'] = 18,
    ['Lash'] = 2,
    ['Last Stand'] = 20,
    ['Lay on Hands'] = 120,
    ['Leech Poison'] = 40,
    ['Lesser Agility'] = 3600,
    ['Lesser Armor'] = 3600,
    ['Lesser Intellect'] = 3600,
    ['Lesser Invisibility'] = 600,
    ['Lesser Mark of the Dawn'] = 3600,
    ['Lesser Strength'] = 3600,
    ['Levitate'] = 120,
    ['Life Drain'] = 12,
    ['Light of Elune'] = 10,
    ['Lightheaded'] = 30,
    ['Lightning Cloud'] = 15,
    ['Lightning Shield'] = 600,
    ['Living Bomb'] = 8,
    ['Living Free Action'] = 5,
    ['Lock Down'] = 10,
    ['Locust Swarm'] = 6,
    ['Locust Swarm'] = 6,
    ["Lord General's Sword"] = 30,
    ["Lordaeron's Blessing"] = 1800,
    ['Low Swipe'] = 15,
    ["Lucifron's Curse"] = 300,
    ['Lunar Fortune'] = 1800,
    ['Lung Puncture'] = 260,
    ['M73 Frag Grenade'] = 3,
    ['Mace Stun Effect'] = 3,
    ['Mage Armor'] = 1800,
    ['Magenta Cap Sickness'] = 1200,
    ['Maggot Goo'] = 6,
    ['Maggot Slime'] = 1800,
    ['Magic Reflection'] = 10,
    ['Magma Shackles'] = 15,
    ['Magma Spit'] = 30,
    ['Magma Splash'] = 30,
    ['Magmakin Confuse'] = 1,
    ['Major Spellstone'] = 60,
    ["Malown's Slam"] = 2,
    ['Mana Regeneration'] = 3600,
    ['Mana Shield'] = 60,
    ["Mar'li's Brain Boost"] = 30,
    ["Marduk's Curse"] = 5,
    ['Mark of Arlokk'] = 120,
    ['Mark of Blaumeux'] = 75,
    ['Mark of Detonation'] = 30,
    ['Mark of Flames'] = 120,
    ['Mark of Frost'] = 900,
    ['Mark of Kazzak'] = 60,
    ["Mark of Korth'azz"] = 75,
    ['Mark of Mograine'] = 75,
    ['Mark of Nature'] = 900,
    ['Mark of Zeliek'] = 75,
    ['Mark of the Chosen'] = 60,
    ['Mark of the Dawn'] = 3600,
    ['Mark of the Wild'] = 1800,
    ['Massive Destruction'] = 20,
    ['Massive Tremor'] = 2,
    ['Melt Armor'] = 60,
    ['Melt Ore'] = 20,
    ['Mend Dragon'] = 20,
    ['Mental Domination'] = 120,
    ['Mercurial Shield'] = 60,
    ['Midsummer Sausage'] = 3600,
    ['Might of Shahram'] = 5,
    ['Mighty Rage'] = 20,
    ['Mind Bomb Effect'] = 60,
    ['Mind Control'] = 60,
    ['Mind Exhaustion'] = 60,
    ['Mind Flay'] = 10,
    ['Mind Quickening'] = 20,
    ['Mind Rot'] = 30,
    ['Mind Shatter'] = 3,
    ['Mind Soothe'] = 15,
    ['Mind Tremor'] = 600,
    ['Mind Vision'] = 60,
    ['Mind-numbing Poison II'] = 12,
    ['Mind-numbing Poison III'] = 14,
    ['Mind-numbing Poison'] = 10,
    ['Minor Scorpion Venom Effect'] = 60,
    ['Minor Scorpion Venom'] = 60,
    ['Mirefin Fungus'] = 8,
    ['Miring Mud'] = 5,
    ['Mirkfallon Fungus'] = 2700,
    ['Mistletoe'] = 1800,
    ['Mithril Frag Bomb'] = 2,
    ['Mobility Malfunction'] = 20,
    ['Mocking Blow'] = 6,
    ["Mol'dar's Moxie"] = 7200,
    ['Molten Metal'] = 15,
    ['Moonfire'] = 12,
    ['Mortal Strike'] = 10,
    ['Mortal Wound'] = 15,
    ['Moss Hide'] = 10,
    ['Muculent Fever'] = 600,
    ['Muscle Tear'] = 5,
    ['Mutating Injection'] = 10,
    ['Mystical Disjunction'] = 8,
    ['Narain!'] = 1800,
    ["Naralex's Nightmare"] = 15,
    ['Nature Protection'] = 3600,
    ['Nature Resistance'] = 30,
    ['Nature Weakness'] = 45,
    ["Nature's Grasp"] = 45,
    ["Nature's Swiftness"] = 10,
    ['Necrotic Poison'] = 30,
    ['Negative Charge'] = 60,
    ['Net Guard'] = 20,
    ['Net'] = 5,
    ['Net-o-Matic'] = 10,
    ['Net-o-Matic'] = 10,
    ['Netherwind Focus'] = 10,
    ['Nimble Healing Touch'] = 15,
    ['Nimble Healing Touch'] = 15,
    ['Noggenfogger Elixir'] = 600,
    ['Noxious Breath'] = 30,
    ['Noxious Poison'] = 8,
    ['Nullify Poison'] = 30,
    ['Numbing Pain'] = 10,
    ['Obsidian Armor'] = 6,
    ['Obsidian Insight'] = 30,
    ['Omen of Clarity'] = 600,
    ['Orb of Deception'] = 300,
    ['Overdrive'] = 6,
    ["Overseer's Poison"] = 60,
    ["Pagle's Broken Reel"] = 15,
    ['ability_creature_poison_05|Paralyze'] = 10,
    ['spell_shadow_charm|Paralyze'] = 30,
    ['Paralyzing Poison'] = 8,
    ['Party Fever Effect'] = 120,
    ['Party Fever'] = 120,
    ['Party Time'] = 120,
    ['Perception'] = 20,
    ['Persistent Shield'] = 8,
    ['Petrification'] = 60,
    ['Petrify'] = 8,
    ['Phantom Strike'] = 20,
    ['Phase Shift'] = 6,
    ['Phasing'] = 4,
    ['Physical Protection'] = 10,
    ['Pierce Armor'] = 20,
    ['Piercing Ankle'] = 6,
    ['Piercing Howl'] = 6,
    ['Piercing Shadow'] = 1800,
    ['Piercing Shot'] = 15,
    ['Piercing Shriek'] = 6,
    ['Plague Cloud'] = 240,
    ['Plague Mind'] = 600,
    ['Plague Mist'] = 8,
    ['Plague'] = 40,
    ['Plague'] = 40,
    ['Poison Aura'] = 12,
    ['Poison Bolt Volley'] = 10,
    ['Poison Bolt Volley'] = 10,
    ['Poison Bolt Volley'] = 10,
    ['Poison Bolt Volley'] = 10,
    ['Poison Bolt'] = 10,
    ['Poison Charge'] = 9,
    ['Poison Cloud'] = 45,
    ['Poison Mind'] = 15,
    ['Poison Mushroom'] = 30,
    ['Poison Stinger'] = 10,
    ['Poison'] = 15,
    ['Poisonous Blood'] = 90,
    ['Poisonous Spit'] = 15,
    ['Poisonous Stab'] = 15,
    ['Polished Armor'] = 1800,
    ['Polymorph Backfire'] = 8,
    ['Polymorph'] = 50,
    ['Polymorph: Chicken'] = 10,
    ['Polymorph: Cow'] = 50,
    ['Polymorph: Pig'] = 50,
    ['Polymorph: Pig'] = 50,
    ['Polymorph: Sheep'] = 10,
    ['Polymorph: Turtle'] = 50,
    ['Polymorph: Turtle'] = 50,
    ['Positive Charge'] = 60,
    ['Possess'] = 120,
    ['Pounce Bleed'] = 18,
    ['Pounce'] = 3,
    ['Power Infusion'] = 15,
    ['Power Surge'] = 10,
    ['Power Word: Fortitude'] = 1800,
    ['Power Word: Shield'] = 30,
    ['Prayer Beads Blessing'] = 20,
    ['Prayer of Fortitude'] = 3600,
    ['Prayer of Shadow Protection'] = 1200,
    ['Prayer of Spirit'] = 3600,
    ['Presence of Death'] = 10,
    ['Presence of Mind'] = 10,
    ['Primal Blessing'] = 12,
    ['Primal Blessing'] = 12,
    ['Prismstone'] = 20,
    ['Prismstone'] = 30,
    ['Psychic Scream'] = 8,
    ['Pummel'] = 5,
    ['Puncture Armor'] = 30,
    ['Puncture'] = 10,
    ['Purge'] = 2,
    ['Purity'] = 2,
    ['Putrid Bile'] = 45,
    ['Putrid Bite'] = 30,
    ['Putrid Breath'] = 30,
    ['Pyroblast'] = 12,
    ['Pyroclast Barrage'] = 6,
    ['Quick Flame Ward'] = 10,
    ['Quick Frost Ward'] = 10,
    ['Quick Shots'] = 12,
    ['Radiation Cloud'] = 30,
    ['Radiation Poisoning'] = 25,
    ['Rage of Ages'] = 3600,
    ['Rage of Thule'] = 120,
    ['Rage'] = 15,
    ["Ragged John's Neverending Cup"] = 600,
    ['Rake'] = 9,
    ['Rallying Cry of the Dragonslayer'] = 7200,
    ['Rapid Fire'] = 15,
    ['Raptor Punch'] = 300,
    ['Rat Nova'] = 10,
    ['Ravage'] = 2,
    ['Razor Mane'] = 45,
    ['Razorhide'] = 600,
    ['Razorlash Root'] = 10,
    ['Reactive Fade'] = 4,
    ['Recently Bandaged'] = 60,
    ['Reckless Charge'] = 30,
    ['Recklessness'] = 15,
    ['Redoubt'] = 10,
    ['Reduced to Rubble'] = 1800,
    ['Regeneration'] = 3600,
    ['Regrowth'] = 21,
    ['Rejuvenation'] = 12,
    ['Remorseless Attacks'] = 20,
    ['Rend Flesh'] = 12,
    ['Rend'] = 21,
    ['Renew'] = 15,
    ['Repentance'] = 6,
    ['Repulsive Gaze'] = 8,
    ['Resist Arcane'] = 3600,
    ['Resist Fire'] = 3600,
    ['Resistance'] = 180,
    ['Ressurection Sickness'] = 600,
    ['Restless Strength'] = 20,
    ['Restoration'] = 30,
    ['Retching Plague'] = 300,
    ['Revenge Stun'] = 3,
    ["Rhahk'Zor Slam"] = 3,
    ['Rift Beacon'] = 60,
    ['Righteous Fire'] = 8,
    ['Righteous Fury'] = 1800,
    ['Rip'] = 12,
    ['Riposte'] = 6,
    ['Riptide'] = 4,
    ['Ritual Candle Aura'] = 6,
    ['Rock Skin'] = 3600,
    ['Rocket Boots Malfunction'] = 5,
    ['Rough Copper Bomb'] = 1,
    ['Rumsey Rum Black Label'] = 900,
    ['Rumsey Rum Dark'] = 900,
    ['Rumsey Rum Light'] = 900,
    ['Rumsey Rum'] = 900,
    ['Run Away!'] = 5,
    ['Running Speed'] = 15,
    ['Rupture'] = 16,
    ['Rushing Charge'] = 3,
    ['Ruthless Strength'] = 20,
    ["Ryson's All Seeing Eye"] = 1800,
    ['Sacrifice'] = 30,
    ['Sanctified Orb'] = 25,
    ['Sanctuary'] = 10,
    ['Sand Blast'] = 5,
    ['Sand Breath'] = 10,
    ['Sand Storm'] = 7,
    ['Sand Trap'] = 20,
    ['Sap Might'] = 300,
    ['Sap'] = 45,
    ['Sapta Sight'] = 1200,
    ['Savage Assault II'] = 30,
    ['Savage Assault III'] = 30,
    ['Savage Assault IV'] = 30,
    ['Savage Assault V'] = 30,
    ['Savage Assault'] = 30,
    ['Savage Pummel'] = 5,
    ['Savage Rage'] = 4,
    ['Savage Rage'] = 4,
    ['Savagery'] = 8,
    ["Savior's Sacrifice"] = 10,
    ["Sayge's Dark Fortune of Agility"] = 7200,
    ["Sayge's Dark Fortune of Armor"] = 7200,
    ["Sayge's Dark Fortune of Damage"] = 7200,
    ["Sayge's Dark Fortune of Intelligence"] = 7200,
    ["Sayge's Dark Fortune of Resistance"] = 7200,
    ["Sayge's Dark Fortune of Spirit"] = 7200,
    ["Sayge's Dark Fortune of Stamina"] = 7200,
    ["Sayge's Dark Fortune of Strength"] = 7200,
    ['Scare Beast'] = 20,
    ['Scarlet Illusion'] = 900,
    ['Scatter Shot'] = 4,
    ['Scorch Breath'] = 15,
    ['Scorpid Poison'] = 10,
    ['Scorpid Sting'] = 10,
    ['Screech'] = 4,
    ['Seal of Command'] = 30,
    ['Seal of Justice'] = 10,
    ['Seal of Protection'] = 8,
    ['Seal of Reckoning'] = 30,
    ['Seal of Righteousness'] = 30,
    ['Seal of Wisdom'] = 30,
    ['Seal of the Crusader'] = 10,
    ['Searing Blast'] = 30,
    ['Searing Flames'] = 9,
    ['Second Wind'] = 10,
    ['Seduction'] = 15,
    ['Seeping Willow'] = 30,
    ['Self Invulnerability'] = 3,
    ['Sentry Totem'] = 300,
    ['Seperation Anxiety'] = 5,
    ['Serious Wound'] = 10,
    ['Serpent Form'] = 10,
    ['Serpent Sting'] = 15,
    ['Serrated Bite'] = 30,
    ['Shackle Undead'] = 50,
    ['Shadow Barrier'] = 600,
    ['Shadow Bolt'] = 6,
    ['Shadow Charge'] = 6,
    ['Shadow Fissure'] = 10,
    ['Shadow Flame'] = 10,
    ['Shadow Mark'] = 15,
    ['Shadow Oil'] = 1800,
    ['Shadow Port'] = 10,
    ['Shadow Power'] = 1800,
    ['Shadow Reflector'] = 5,
    ['Shadow Resistance'] = 30,
    ['Shadow Shell'] = 10,
    ['Shadow Shield'] = 30,
    ['Shadow Trance'] = 10,
    ['Shadow Vulnerability'] = 12,
    ['Shadow Ward'] = 30,
    ['Shadow Weakness'] = 45,
    ['Shadow Word: Fumble'] = 10,
    ['Shadow Word: Pain'] = 18,
    ['Shadow Word: Silence'] = 6,
    ['Shadow of Ebonroc'] = 8,
    ['Shadowburn'] = 5,
    ['Shadowguard'] = 600,
    ['Shadowhorn Charge'] = 6,
    ['Shadowstalker Stab'] = 5,
    ['Shared Bonds'] = 4,
    ["Shazzrah's Curse"] = 300,
    ['Sheen of Zanza'] = 7200,
    ['Shell Shield'] = 12,
    ['Shield Bash - Silenced'] = 4,
    ['Shield Block'] = 5,
    ['Shield Generator'] = 30,
    ['Shield Slam'] = 2,
    ['Shield Wall'] = 10,
    ['Shield of Rajaxx'] = 6,
    ['Shred'] = 12,
    ['Shrink Ray'] = 20,
    ['Shrink'] = 30,
    ['Silence'] = 5,
    ['Silithid Pox'] = 1800,
    ['Siphon Blessing'] = 30,
    ['Siphon Health'] = 15,
    ['Siphon Life'] = 30,
    ['Siphon Soul'] = 10,
    ["Siren's Song"] = 180,
    ['Skin of Rock'] = 8,
    ['Skullforge Brand'] = 30,
    ['Slap!'] = 3,
    ["Slavedriver's Cane"] = 30,
    ['Sleep Walk'] = 10,
    ['Sleep'] = 30,
    ['Sleepy'] = 30,
    ['Slime Bolt'] = 10,
    ['Slime Burst'] = 5,
    ['Slime Dysentery'] = 1800,
    ['Slime Stream'] = 3,
    ['Sling Dirt'] = 10,
    ['Sling Mud'] = 15,
    ["Slip'kik's Savvy"] = 7200,
    ['Slow Fall'] = 30,
    ['Slow'] = 10,
    ['Slowing Poison'] = 25,
    ['Sludge Toxin'] = 45,
    ['Sludge'] = 3,
    ['Small Bronze Bomb'] = 2,
    ['Smite Stomp'] = 10,
    ['Smoke Cloud'] = 3,
    ['Smolderweb Protection'] = 30,
    ['Smothering Sands'] = 20,
    ['Snap Kick'] = 2,
    ['Songflower Serenade'] = 3600,
    ['Soothe Animal'] = 15,
    ['Soul Breaker'] = 30,
    ['Soul Corruption'] = 15,
    ['Soul Drain'] = 10,
    ['Soul Siphon'] = 10,
    ['Soul Trap'] = 12,
    ['Soulstone Ressurection'] = 900,
    ['Speed Slash'] = 6,
    ['Speed of Owatanka'] = 1800,
    ['Speed'] = 15,
    ['Spell Blasting'] = 10,
    ['Spell Lock'] = 3,
    ['Spell Vulnerability'] = 5,
    ['Spellstone'] = 60,
    ['Spider Poison'] = 30,
    ["Spider's Kiss"] = 10,
    ['Spirit Decay'] = 1200,
    ['Spirit Heal Channel'] = 30,
    ['Spirit Shock'] = 30,
    ['Spirit Tap'] = 15,
    ['Spirit of Boar'] = 3600,
    ['Spirit of Wind'] = 300,
    ['Spirit of Zandalar'] = 7200,
    ['Spirit of Zanza'] = 7200,
    ['Spirit'] = 1800,
    ['Spiritual Domination'] = 3600,
    ['Spitelash'] = 20,
    ['Splintered Obsidian'] = 3600,
    ['Spore Cloud'] = 5,
    ['Sprint'] = 15,
    ['Stamina'] = 1800,
    ['Starshards'] = 6,
    ['Static Barrier'] = 600,
    ['Stealth Detection'] = 600,
    ['Sticky Tar'] = 4,
    ['Stinging Trauma'] = 18,
    ['Stomp'] = 2,
    ['Stone Skin'] = 6,
    ['Stoneform'] = 15,
    ['Stoneform'] = 8,
    ['Stoneshield'] = 90,
    ["Stormcaller's Wrath"] = 8,
    ["Stormpike's Salvation"] = 120,
    ['Stormstout'] = 300,
    ['Stormstrike'] = 12,
    ["Strength of Arko'narin"] = 1800,
    ['Strength of Isha Awak'] = 1800,
    ['Strength of the Champion'] = 30,
    ['Strength'] = 1800,
    ['Strike of the Scorpok'] = 3600,
    ['Strong Cleave'] = 10,
    ['Stun Bomb'] = 5,
    ['Stun Bomb'] = 5,
    ['Stunning Blow'] = 8,
    ['Stygian Grasp'] = 5,
    ['Submersion'] = 60,
    ["Sul'thraze"] = 15,
    ['Sunder Armor'] = 30,
    ['Sundering Cleave'] = 30,
    ['Super Shrink Ray'] = 20,
    ['Supercharge'] = 10,
    ['Superheated Flames'] = 10,
    ['Suppression Aura'] = 6,
    ['Supreme Power'] = 7200,
    ['Surge of Strength'] = 30,
    ['Surprise Attack'] = 2.5,
    ['Survival Instinct'] = 2,
    ['Sweet Surprise'] = 3600,
    ['Swift Wind'] = 3600,
    ['Swiftness of Zanza'] = 7200,
    ['Swiftness'] = 30,
    ['Swim Speed'] = 20,
    ['Swim Speed'] = 20,
    ['Swoop'] = 2,
    ['Tail Lash'] = 2,
    ['Taint of Shadow'] = 1200,
    ['Tainted Blood'] = 60,
    ['Tainted Howl'] = 120,
    ['Tainted Mind'] = 600,
    ['Tame Adult Plainstrider'] = 20,
    ['Tame Armored Scorpid'] = 20,
    ['Tame Beast'] = 20,
    ['Tame Dire Mottled Boar'] = 20,
    ['Tame Ice Claw Bear'] = 20,
    ['Tame Large Crag Boar'] = 20,
    ['Tame Nightsaber Stalker'] = 20,
    ['Tame Prairie Stalker'] = 20,
    ['Tame Snow Leopard'] = 20,
    ['Tame Strigid Screecher'] = 20,
    ['Tame Surf Crawler'] = 20,
    ['Tame Swoop'] = 20,
    ['Tame Webwood Lurker'] = 20,
    ['Taunt'] = 3,
    ['Teleport from Azshara Tower'] = 3,
    ['Teleport to Azshara Tower'] = 3,
    ['Tendon Rip'] = 8,
    ['Tendon Slice'] = 8,
    ['Tendrils of Air'] = 2,
    ['Terrify'] = 4,
    ['Terrifying Howl'] = 3,
    ['Terrifying Roar'] = 5,
    ['Terrifying Screech'] = 4,
    ['Thaumaturgy Channel'] = 5,
    ["The Baron's Ultimatum"] = 2700,
    ['The Black Sheep'] = 10,
    ['The Eye of Diminution'] = 20,
    ['The Furious Storm'] = 10,
    ['The Lion Horn of Stormwind'] = 30,
    ['The Lion Horn'] = 30,
    ['Thorium Grenade'] = 3,
    ['Thorn Volley'] = 2,
    ['Thorns Aura'] = 60,
    ['Thorns'] = 600,
    ['Threatening Gaze'] = 6,
    ['Threatening Growl'] = 30,
    ['Thunder Clap'] = 30,
    ['Thunderbrew Lager'] = 300,
    ['Thunderclap'] = 10,
    ['Thundercrack'] = 3,
    ['Thunderfury'] = 12,
    ['Thundershock'] = 5,
    ['Tidal Charm'] = 3,
    ["Tiger's Fury"] = 6,
    ['Time Lapse'] = 8,
    ['Time Step'] = 10,
    ['Time Stop'] = 4,
    ['Toast'] = 1800,
    ['Toasted Smorch'] = 3600,
    ['Torch'] = 8,
    ['Tornado'] = 4,
    ['Totemic Power'] = 8,
    ['Touch of Ravenclaw'] = 5,
    ['Touch of Shadow'] = 1800,
    ['Touch of Weakness'] = 120,
    ['Touch of Zanzil'] = 604800,
    ['Tough Shell'] = 12,
    ['Toughen Hide'] = 10,
    ['Toxic Contagion'] = 60,
    ['Toxic Saliva'] = 120,
    ['Toxic Vapors'] = 12,
    ['Toxic Volley'] = 15,
    ['Toxin'] = 9,
    ['Traces of Silithyst'] = 1800,
    ['Tranquility'] = 10,
    ['Tranquilizing Poison'] = 8,
    ['Transporter Malfunction'] = 10,
    ['Trap'] = 10,
    ["Trelane's Freezing Touch"] = 12,
    ['Trip'] = 3,
    ['True Fulfillment'] = 20,
    ['Trueshot Aura'] = 1800,
    ['Tune Up'] = 20,
    ['Tunneler Acid'] = 30,
    ['Turn Undead'] = 15,
    ['Twin Colossals Teleport'] = 3,
    ['Twisted Tranquility'] = 10,
    ['Unbalancing Strike'] = 6,
    ['Undead Tracker'] = 60,
    ['Unending Breath'] = 600,
    ['Unholy Curse'] = 12,
    ['Unholy Curse'] = 12,
    ['Unholy Frenzy'] = 20,
    ['Unholy Shield'] = 600,
    ['Unkillable Off'] = 3,
    ['Unleashed Rage'] = 10,
    ['Unrelenting Anguish'] = 5,
    ['Unstable Power'] = 20,
    ['Untamed Fury'] = 8,
    ['Untamed Fury'] = 8,
    ['Using Control Console'] = 300,
    ["Uther's Light Effect"] = 15,
    ['Vampiric Embrace'] = 60,
    ['Vanish'] = 10,
    ['Veil of Shadow'] = 6,
    ['Veil of Shadow'] = 8,
    ['Vengeance'] = 8,
    ['Venom Spit'] = 10,
    ['Venom Sting'] = 45,
    ['Venomhide Poison'] = 30,
    ['Venomous Totem'] = 20,
    ['Very Berry Cream'] = 3600,
    ['Vindication'] = 10,
    ['Violent Shield Effect'] = 8,
    ['Violent Shield'] = 8,
    ['Viper Sting'] = 8,
    ['Viper Sting'] = 8,
    ['Virulent Poison'] = 30,
    ['Volatile Infection'] = 15,
    ['Voodoo Hex'] = 120,
    ['Wail of Nightlash'] = 15,
    ['Wail of the Banshee'] = 12,
    ['Wailing Dead'] = 6,
    ['Wandering Plague'] = 300,
    ['War Stomp'] = 2,
    ["Warchief's Blessing"] = 3600,
    ['Ward of the Eye'] = 8,
    ['Warlock Channeling'] = 7,
    ['Warlock Terror'] = 2,
    ["Warrior's Wrath"] = 10,
    ["Washte Pawne's Resolve"] = 1800,
    ['Water Breathing'] = 1800,
    ['Water Bubble'] = 30,
    ['Water Walking'] = 1800,
    ['Weak Poison'] = 12,
    ['Weakened Soul'] = 15,
    ['Weakening Disease'] = 30,
    ['Weakness Disease'] = 30,
    ['Web Explosion'] = 10,
    ['Web Spin'] = 7,
    ['Web Spray'] = 10,
    ['Web Wrap'] = 60,
    ['Web'] = 10,
    ['Whipweed Entangle'] = 18,
    ['Whirlwind Primer'] = 2,
    ['Whirlwind'] = 6,
    ["Whisperings of C'Thun"] = 60,
    ['Widow Bite'] = 4,
    ["Widow's Embrace"] = 30,
    ['Wild Magic'] = 30,
    ['Wild Polymorph'] = 20,
    ['Wild Rage'] = 60,
    ['Wild Regeneration'] = 20,
    ['Will of Shahram'] = 20,
    ['Will of the Forsaken'] = 5,
    ["Windsor's Frenzy"] = 600,
    ['Wing Clip'] = 10,
    ['Wings of Despair'] = 6,
    ["Winter's Chill"] = 15,
    ['Winterfall Firewater'] = 1200,
    ['Wither Strike'] = 8,
    ['Wither Touch'] = 120,
    ['Wither'] = 21,
    ['Withered Touch'] = 180,
    ['Withering Heat'] = 900,
    ['Withering Poison'] = 180,
    ['World Enlarger'] = 300,
    ['Wound Poison'] = 15,
    ['Wound'] = 25,
    ['Wracking Pains'] = 180,
    ['Wrath of the Plaguebringer'] = 10,
    ['Wrath of the Plaguebringer'] = 10,
    ['Wyvern Sting '] = 12,
    ['Wyvern Sting'] = 12,
    ['Yaaarrr'] = 3600,
    ['Zeal'] = 15,
    ['confused'] = 2,
    ['spell_shadow_antishadow|Shadow Protection'] = 600,
    ['spell_shadow_ragingscream|Shadow Protection'] = 3600,
    ['Arcane Protection'] = 3600,
    ['Well Fed'] = 900,
}

local function tooltipScan(func, unit, line, ...)
    local text

    for i = 1, 28 do
        MODERNIZR:Erase()

        func(MODERNIZR, unit, i)

        text = MODERNIZR:GetLine(line)

        if not text then
            break
        end

        for j = 1, arg.n do
            if stringMatch(text, arg[j]) then
                return true
            end
        end
    end

    return false
end

IsStealthed = IsStealthed or
    function()
        return tooltipScan(MODERNIZR.SetUnitBuff, 'player', 1, 'Stealth', 'Prowl')
    end

IsMounted = IsMounted or
    function()
        return tooltipScan(MODERNIZR.SetUnitBuff, 'player', 2, 'Increases movement speed')
    end

local shapeshiftForms = {
    -- Druid
    ['Bear Form'] = 1,
    ['Aquatic Form'] = 2,
    ['Cat Form'] = 3,
    ['Travel Form'] = 4,
    ['Moonkin Form'] = 5,

    -- Rogue
    ['Stealth'] = 1,

    -- Warrior
    ['Battle Stance'] = 1,
    ['Defensive Stance'] = 2,
    ['Berserker Stance'] = 3,
}

GetShapeshiftForm = GetShapeshiftForm or function()
    local numForms = GetNumShapeshiftForms()
    local name, isActive, formIndex
    for i = 1, NUM_SHAPESHIFT_SLOTS do
        if i <= numForms then
            _, name, isActive = GetShapeshiftFormInfo(i)
            name = name == 'Dire Bear Form' and 'Bear Form' or name
            formIndex = shapeshiftForms[name]
            if formIndex and isActive then
                return formIndex
            end
        end
    end

    return 0
end


function UnitHasAura(unit, aura)
    local text
    for i = 1, 30 do
        MODERNIZR:SetUnitBuff(unit, i)

        text = MODERNIZR:GetLine(1)

        if text == aura then
            return i
        end

        if not text then
            return nil
        end

        MODERNIZR:Erase()
    end
end


local processAuraChange, TargetAction, cacheAuras, unitHasAura
do
    local playerName = UnitName('player')
    local buffExpires = { }
    local runTime

    function TargetAction(func, action, unit)
        if unit and type(unit) == 'string' then
            local hasTarget = UnitName('target')
            local isCurrentTarget = UnitIsUnit('target', unit)

            if not isCurrentTarget then
                TargetUnit(unit)
            end

            local name = UnitName('target')
            local spell = type(action) == 'string' and stringMatch(action, '(.+)%(.+%)') or action
            local expires = buffExpires[name]

            if expires and expires[spell] then
                local duration = staticBuffDurations[spell]
                buffExpires[name][spell] = duration and duration + GetTime() or expires[spell]
            end

            func(action)

            if hasTarget then
                if not isCurrentTarget then
                    TargetLastTarget()
                end
            else
                ClearTarget()
            end
        else
            local onSelf = unit
            local name = not onSelf and UnitName('target')
            local spell = type(action) == 'string' and stringMatch(action, '(.+)%(.+%)') or action
            local expires = buffExpires[name]

            if expires and expires[spell] then
                local duration = staticBuffDurations[spell]
                buffExpires[name][spell] = duration and duration + GetTime() or expires[spell]
            end

            func(action, onSelf)
        end
    end

    local unitAura = function(buffFunc, tooltipFunc, unit, index, rank, filter)
        local name, icon, count, auraType, duration, expires, caster
        if type(index) == 'string' then
            name = index
        end

        local timeLeft
        local now = GetTime()
        local targetName = UnitName(unit)

        MODERNIZR:Erase()
        if name then
            index = 0

            local text
            for i = 1, 30 do
                tooltipFunc(MODERNIZR, unit, i)

                text, auraType = MODERNIZR:GetLine(1)

                if not text or text == name then
                    index = i
                    break
                end

                MODERNIZR:Erase()
            end

            name = text
        else
            if targetName == playerName then
                local buffIndex = GetPlayerBuff(index - 1, filter)

                if buffIndex > -1 then
                    MODERNIZR:SetPlayerBuff(buffIndex)
                    name = MODERNIZR:GetLine(1)
                    count = GetPlayerBuffApplications(buffIndex)
                    icon = GetPlayerBuffTexture(buffIndex)
                    timeLeft = GetPlayerBuffTimeLeft(buffIndex)
                    auraType = GetPlayerBuffDispelType(buffIndex)

                    expires = now + timeLeft
                end
            else
                tooltipFunc(MODERNIZR, unit, index)

                name, auraType = MODERNIZR:GetLine(1)
            end
        end

        if not name then
            return
        end

        name = stringTrim(name)

        expires = expires or buffExpires[targetName] and buffExpires[targetName][name] or 0

        local _auraType
        if not icon then
            icon, count, _auraType = buffFunc(unit, index)
        end

        auraType = auraType or _auraType

        count = count or 1

        -- Some buffs have identical names but different duration, lookup by
        -- icon and name instead
        duration = staticBuffDurations[name]
        if (not duration) and icon then
            local pathParts = { stringSplit('\\', icon) }
            duration = staticBuffDurations[stringFormat('%s|%s', stringLower(pathParts[3]), name)]
        end

        duration = expires > 0 and duration or timeLeft or 0

        if not icon then
            icon = spellIcons[name]
            icon = icon and 'Interface/Icons/' .. icon
        end

        return name, rank, icon, count, auraType, duration, expires, caster
    end


    UnitAura = function(unit, index, rank, filter)
        if type(index) == 'number' or not filter then
            filter = rank
        end

        local name, icon, count, dispelType, duration, expires, caster

        if filter == 'HARMFUL' then
            name, rank, icon, count, dispelType, duration, expires, caster =
                unitAura(UnitDebuff, MODERNIZR.SetUnitDebuff, unit, index, rank, filter)
        else
            name, rank, icon, count, dispelType, duration, expires, caster =
                unitAura(UnitBuff, MODERNIZR.SetUnitBuff, unit, index, rank, filter)
            if filter and stringMatch(filter, 'HARMFUL') and not name then
                name, rank, icon, count, dispelType, duration, expires, caster =
                    unitAura(UnitDebuff, MODERNIZR.SetUnitDebuff, unit, index, rank, filter)
            end
        end

        return name, '', icon, count, dispelType, duration, expires, caster
    end

    MUnitBuff = function(unit, index, rank, filter)
        if type(index) == 'number' or not filter then
            filter = rank
        end

        local name, rank, icon, count, dispelType, duration, expires, caster =
            unitAura(UnitBuff, MODERNIZR.SetUnitBuff, unit, index, rank, filter)

        return name, '', icon, count, dispelType, duration, expires, caster
    end

    MUnitDebuff = function(unit, index, rank, filter)
        if type(index) == 'number' or not filter then
            filter = rank
        end

        local name, rank, icon, count, dispelType, duration, expires, caster =
            unitAura(UnitDebuff, MODERNIZR.SetUnitDebuff, unit, index, rank, filter)

        return name, '', rank, icon, count, dispelType, duration, expires, caster
    end

    processAuraChange = function(msg)
        local now = GetTime()
        local buff, target

        buff, target = stringMatch(msg, '(.+) fades from (.+).')
        if buff and target ~= 'you' then
            buffExpires[target] = buffExpires[target] or {}
            buffExpires[target][buff] = nil
            return
        end

        target, buff = stringMatch(msg, '(.+) gains? ?f?r?o?m? (.+).')
        buff = buff and stringMatch(buff, 'from') and nil or buff
        if buff and target ~= 'You' then
            buffExpires[target] = buffExpires[target] or {}
            buffExpires[target][buff] = now + (staticBuffDurations[buff] or 0)
            return
        end

        target, buff = stringMatch(msg, '(.+) is afflicted by (.+).')
        buff = buff and stringMatch(buff, '(.+) %(%d+%)') or buff
        if buff then
            buffExpires[target] = buffExpires[target] or {}
            buffExpires[target][buff] = now + (staticBuffDurations[buff] or 0)
            return
        end
    end


    local setBuff = function(unit, i)
        if unit == 'player' then
            local buffIndex = GetPlayerBuff(i - 1, 'HELPFUL')

            if buffIndex > -1 then
                local count, icon, type, timeLeft

                MODERNIZR:SetPlayerBuff(buffIndex)
                icon = GetPlayerBuffTexture(buffIndex)
                count = GetPlayerBuffApplications(buffIndex)
                type = GetPlayerBuffDispelType(buffIndex)
                timeLeft = GetPlayerBuffTimeLeft(buffIndex)

                return icon, count, type, timeLeft
            end
        else
            MODERNIZR:SetUnitBuff(unit, i)
        end
    end

    local setDebuff = function(unit, i)
        if unit == 'player' then
            local buffIndex = GetPlayerBuff(i - 1, 'HARMFUL')

            if buffIndex > -1 then
                local count, icon, type, timeLeft

                MODERNIZR:SetPlayerBuff(buffIndex)
                icon = GetPlayerBuffTexture(buffIndex)
                count = GetPlayerBuffApplications(buffIndex)
                type = GetPlayerBuffDispelType(buffIndex)
                timeLeft = GetPlayerBuffTimeLeft(buffIndex)

                return icon, count, type, timeLeft
            end
        else
            MODERNIZR:SetUnitDebuff(unit, i)
        end
    end


    local cacheAura = function(tooltipFunc, buffFunc, cache, unit, index)
        local icon, count, dispelType, timeLeft = tooltipFunc(unit, index)

        local text, auraType = MODERNIZR:GetLine(1)

        MODERNIZR:Erase()

        if not text then
            for k in next, cache do
                cache[k] = nil
            end

            return false
        end

        local name = stringTrim(text)

        local duration
        local now = GetTime()

        if not icon then
            icon, count, dispelType = buffFunc(unit, index)
        end

        local targetName = UnitName(unit)
        expires = (timeLeft and now + timeLeft) or
            (buffExpires[targetName] and buffExpires[targetName][name]) or 0

        auraType = auraType or dispelType

        count = count or 1

        -- Some buffs have identical names but different duration, lookup by
        -- icon and name instead
        duration = staticBuffDurations[name]

        if (not duration) and icon then
            local pathParts = { stringSplit('\\', icon) }
            duration = staticBuffDurations[stringFormat('%s|%s', stringLower(pathParts[3]), name)]
        end

        duration = expires > 0 and duration or timeLeft or 0

        if not icon then
            icon = spellIcons[name]
            icon = icon and 'Interface/Icons/' .. icon
        end

        cache.name = name
        cache.rank = ''
        cache.icon = icon
        cache.count = count
        cache.auraType = auraType
        cache.duration = duration
        cache.expires = expires

        return true
    end

    local auraCache = {}
    cacheAuras = function(unit)
        unit = UnitIsUnit(unit, 'player') and 'player' or unit

        local cache = auraCache[unit] or { buffs = {}, debuffs = {} }

        local exists, isNextCached
        for i = 1, 32 do
            cache.buffs[i] = cache.buffs[i] or {}

            exists = cacheAura(setBuff, UnitBuff, cache.buffs[i], unit, i)
            isNextCached = cache.buffs[i + 1] and cache.buffs[i + 1][1]

            if not exists and not isNextCached then
                break
            end
        end

        for i = 1, 16 do
            cache.debuffs[i] = cache.debuffs[i] or {}

            exists = cacheAura(setDebuff, UnitDebuff, cache.debuffs[i], unit, i)

            isNextCached = cache.debuffs[i + 1] and cache.debuffs[i + 1][1]

            if not exists and not isNextCached then
                break
            end
        end

        auraCache[unit] = cache
    end

    unitHasAura = function(unit, aura)
        unit = UnitIsUnit(unit, 'player') and 'player' or unit

        return auraCache[unit] and auraCache[unit].buffs[1]
    end

    unitAuraNew = function(unit, index, filter)
        unit = UnitIsUnit(unit, 'player') and 'player' or unit

        local name
        if type(index) == 'string' then
            name = index
        end

        if not auraCache[unit] then
            return
        end

        local aura
        if filter == 'HARMFUL' then
            if name then
                for i = 1, 16 do
                    aura = auraCache[unit].debuffs[i]

                    if not aura.name then
                        return
                    end

                    if aura.name == name then
                        break
                    end
                end
            else
                aura = auraCache[unit].debuffs[index]
            end
        else
            if name then
                for i = 1, 32 do
                    aura = auraCache[unit].buffs[i]

                    if not aura.name then
                        return
                    end

                    if aura.name == name then
                        break
                    end
                end
            else
                aura = auraCache[unit].buffs[index]
            end
        end

        if aura then
            return aura.name, aura.rank, aura.icon, aura.count, aura.auraType,
            aura.duration, aura.expires
        end
    end
end



function localtest()
    local t = GetTime()

    local a
    for i = 1, (40 * 7) do
        a = unitAuraNew('target', "Warchief's Blessing")
    end

    print(GetTime() - t)
end

local function cacheAurasProxy()
    unit = event == 'PLAYER_AURAS_CHANGED' and 'player' or
        event == 'PLAYER_TARGET_CHANGED' and 'target' or
        arg1

    if not unit then
        return
    end

    cacheAuras(unit)
end

local f = CreateFrame('Frame')
f:SetScript('OnEvent', cacheAurasProxy)
f:RegisterEvent('UNIT_AURA')
f:RegisterEvent('PLAYER_AURAS_CHANGED')
f:RegisterEvent('PLAYER_TARGET_CHANGED')

local g = CreateFrame('Frame')
-- g:SetScript('OnEvent', localtest)
g:RegisterEvent('UNIT_AURA')
-- f:RegisterEvent('HAT_MSG_COMBAT_HOSTILEPLAYER_MISSES'
-- f:RegisterEvent('HAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE'
-- f:RegisterEvent('HAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE'
-- f:RegisterEvent('HAT_MSG_COMBAT_CREATURE_VS_SELF_HITS'
-- f:RegisterEvent('HAT_MSG_COMBAT_CREATURE_VS_SELF_MISSES'
-- f:RegisterEvent('HAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE'
-- f:RegisterEvent('HAT_MSG_COMBAT_CREATURE_VS_PARTY_HITS'
-- f:RegisterEvent('HAT_MSG_COMBAT_CREATURE_VS_PARTY_MISSES'
-- f:RegisterEvent('HAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE'
-- f:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_CREATURE_HITS")
-- f:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_CREATURE_MISSES")
-- f:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE")
-- f:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE")
-- f:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE")
-- f:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE")
-- f:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE")

local _CastSpellByName
local _CastPetAction
-- local _UnitIsDead

function MODERNIZR:PLAYER_LOGIN()
    _CastSpellByName = CastSpellByName
    _CastPetAction = CastPetAction
    -- _UnitIsDead = UnitIsDead

    CastSpellByName = function(spell, unit)
        TargetAction(_CastSpellByName, spell, unit)
    end

    CastPetAction = function(action, unit)
        TargetAction(_CastPetAction, action, unit)
    end

    -- UnitIsDead = function(unit)
    --     local isFeignDeath = tooltipScan(MODERNIZR.SetUnitBuff, unit, 1, 'Feign Death')
    --     -- print({unit, _UnitIsDead(unit), not isFeignDeath})
    --     return _UnitIsDead(unit) and not isFeignDeath
    -- end
end

local function OnEvent()
    if MODERNIZR[event] then
        MODERNIZR[event](this, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)
    elseif stringMatch(event, 'CHAT_MSG_SPELL') then
        processAuraChange(arg1)
    end
end
MODERNIZR:SetScript('OnEvent', OnEvent)
MODERNIZR:RegisterEvent('PLAYER_LOGIN')
-- MODERNIZR:RegisterEvent('CHAT_MSG_SPELL_SELF_BUFF')
-- MODERNIZR:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS")
-- MODERNIZR:RegisterEvent("CHAT_MSG_SPELL_FRIENDLYPLAYER_BUFF")
MODERNIZR:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_BUFFS") -- X
-- MODERNIZR:RegisterEvent("CHAT_MSG_SPELL_HOSTILEPLAYER_BUFF")
-- MODERNIZR:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_BUFFS")
-- MODERNIZR:RegisterEvent("CHAT_MSG_SPELL_PARTY_BUFF")
-- MODERNIZR:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_BUFFS")
-- MODERNIZR:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF")
MODERNIZR:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER") -- X
-- MODERNIZR:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_PARTY")
MODERNIZR:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE")
