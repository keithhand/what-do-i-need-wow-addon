
local function WhatDoINeed_GetItemInfo(GearPiece)
    if GearPiece then
        local _, _, iRarity, iLevel, _, _, _, _, iLocation = GetItemInfo(GearPiece);
        iLocation = string.lower(string.gsub(iLocation, 'INVTYPE_', ''));
        return iLevel, iLocation, iRarity;
    end
end

local function WhatDoINeed_GetAverageItemLevel(GearList)
    local Sum, Count = 0, 0;
    for i,GearPiece in pairs(GearList) do
        Sum = Sum + WhatDoINeed_GetItemInfo(GearPiece);
        Count = Count + 1;
    end
    return string.format('%.2f', Sum / Count);
end

-- 1. pull full list of char gear
local function WhatDoINeed_GetGearList()
    local List = {};
    for i=1,18 do
        local ItemLink = GetInventoryItemLink('player', i);
        table.insert(List, ItemLink);
    end
    return List;
end

-- 2. remove unnecessary gear pieces
local function WhatDoINeed_RemoveGear(GearList)
    local ExcludedItems = {4};
    for k,v in pairs(ExcludedItems) do
        table.remove(GearList, v);
    end
end

-- 3. sort gear by ilvl
local function WhatDoINeed_SortGear(GearList)
    local SortFunction = function(a, b)
        local iLevelA, _, iRarityA = WhatDoINeed_GetItemInfo(a);
        local iLevelB, _, iRarityB = WhatDoINeed_GetItemInfo(b);
        if iRarityA < iRarityB then
            return iLevelA - (7 * (iRarityB - iRarityA)) < iLevelB;
        end
        return iLevelA < iLevelB;
    end
    table.sort(GearList, SortFunction);
end

-- 4. print lowest 10 gear pieces to screen or show display
local function WhatDoINeed_PrintList(GearList)
    local NumberToDisplay = 10;
    local Seperator = '\n\n';
    -- if user doesn't have enough gear pieces equipped, still display the correct number of slots
    if NumberToDisplay > #GearList then 
        NumberToDisplay = #GearList;
        for i=1,NumberToDisplay-#GearList+1 do
            Seperator = Seperator .. '\n';
        end
    end
    print(Seperator);
    print('The', NumberToDisplay, 'items you need the most are:');
    for i=1,NumberToDisplay do
        local GearPiece = GearList[i];
        local iLevel, iLocation = WhatDoINeed_GetItemInfo(GearPiece);
        print(iLocation, '-', GearPiece, '@', iLevel);
    end
    print('But you\'re at', WhatDoINeed_GetAverageItemLevel(GearList), 'overall, so that\'s good!');
end

local function WhatDoINeed()
    local GearList = WhatDoINeed_GetGearList();
    WhatDoINeed_RemoveGear(GearList);
    WhatDoINeed_SortGear(GearList);
    WhatDoINeed_PrintList(GearList);
end

-- Set slash commands to access addon
SLASH_WHATDOINEED1 = '/wdin';
SlashCmdList['WHATDOINEED'] = WhatDoINeed;
