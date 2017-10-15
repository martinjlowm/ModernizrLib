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

local _G = getenv(0)

local TOOLTIP_SCANNER = CreateFrame('GameTooltip', 'ModernizrLibTooltip', nil,
                                    'GameTooltipTemplate')
TOOLTIP_SCANNER:SetOwner(UIParent, 'ANCHOR_NONE')


local function tooltipScan(func, line, ...)
    local i = 0
    local text
    while true do
        TOOLTIP_SCANNER[func](i)

        text = _G[string.format('%sTextLeft%d', TOOLTIP_SCANNER:GetName(),
                                line)]:GetText()
        if not text then
            break
        end

        for _, value in next, arg do
            if value == text then
                return true
            end
        end

        i = i + 1
    end

    TOOLTIP_SCANNER:Hide()
end

local function playerHasBuff(...)
    return tooltipScan('SetPlayerBuff', 1, unpack(arg))
end

IsMounted = IsMounted or function()

end

IsStealthed = IsStealthed or function()
    return playerHasBuff('Stealth', 'Prowl')
end

local shapeshift_forms = {
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
    local num_forms = GetNumShapeshiftForms();
    local name, is_active, form_index
    for i = 1, NUM_SHAPESHIFT_SLOTS do
        if i <= num_forms then
            _, name, is_active = GetShapeshiftFormInfo(i);
            name = name == 'Dire Bear Form' and 'Bear Form' or name
            form_index = shapeshift_forms[name]
            if form_index and is_active then
                return form_index
            end
        end
    end

    return 0
end
