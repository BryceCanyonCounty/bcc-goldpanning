Config = {} 
Config.locale = 'en_lang' -- Change the language in the locales folder
Config.debug = false -- Set to true to enable debug messages
Config.keys = {
    R = 0xE3BF959B,
    G = 0xA1ABB953,
    E = 0x41AC83D1,
    F = 0x26A18F47
}
--Bucketing--
Config.mudBucket = "mud_bucket" --Item to use
Config.emptyMudBucket = "empty_mud_bucket" --Item to give back after use
Config.useWaterItems = true --Set to false if you have a river script
Config.waterBucket = "wateringcan" --!!!IF YOU USE A RIVER OR WATER SCRIPT AND MATCH THE ITEM NAMES!!!
Config.emptyWaterBucket = "wateringcan_empty" --!!!IF YOU TO USE A RIVER OR WATER SCRIPT AND MATCH THE ITEM NAMES!!!
Config.bucketingTime = 8000 --Time to collect and use buckets

--Gold Washing--
Config.goldwashProp = "p_goldcradlestand01x" --Prop & DB item name (NOT LABLE)
Config.goldSiftingProp = "p_copperpan02x" --Prop to use for sifting line 298 of client to change bones etc
Config.goldPan = "goldpan" --Item name needed
Config.washBuildTime = 8000 --Time to build the wash station
Config.goldWashTime = 8000 -- Time To Pan
Config.goldWashReward = "gold_flakes" --Item to give
Config.goldWashRewardAmount = 5 --Amount of reward to give
-----------------------------------

--Extra Reward, because why not--
Config.extraReward = "gold_nugget" --Item to give
Config.extraRewardAmount = 1 --Amount of reward to give
Config.extraRewardChance = 10 --Chance of getting the extra reward


--Minigame--
Config.Minigame = {
    focus = true, -- Should minigame take nui focus (required)
    cursor = false, -- Should minigame have cursor
    maxattempts = 2, -- How many fail attempts are allowed before game over
    type = 'bar', -- What should the bar look like. (bar, trailing)
    userandomkey = false, -- Should the minigame generate a random key to press?
    keytopress = 'E', -- userandomkey must be false for this to work. Static key to press
    keycode = 69, -- The JS keycode for the keytopress
    speed = 34, -- How fast the orbiter grows
    strict = true -- if true, letting the timer run out counts as a failed attempt
}

-- Metadata

Config.ToolUsage = 2   ----- Remove Tool Usage Per Golsearch
Config.UsageLeft = "Durability: "
Config.needNewTool = "Goldpan Broken!"


Config.waterTypes = { --https://github.com/femga/rdr3_discoveries/tree/master/zones
    {hash = "WATER_AURORA_BASIN", type = "lake", label = "Aurora Basin"},
    {hash = "WATER_BARROW_LAGOON", type = "lake", label = "Barrow Lagoon"},
    {hash = "WATER_CALMUT_RAVINE", type = "lake", label = "Calmut Ravine"},
    {hash = "WATER_ELYSIAN_POOL", type = "lake", label = "Elysian Pool"},
    {hash = "WATER_FLAT_IRON_LAKE", type = "lake", label = "Flat Iron Lake"},
    {hash = "WATER_HEARTLANDS_OVERFLOW", type = "lake", label = "Heartlands Overflow"},
    {hash = "WATER_LAKE_DON_JULIO", type = "lake", label = "Lake Don Julio"},
    {hash = "WATER_LAKE_ISABELLA", type = "lake", label = "Lake Isabella"},
    {hash = "WATER_O_CREAGHS_RUN", type = "lake", label = "O Creaghs Run"},
    {hash = "WATER_OWANJILA", type = "lake", label = "Owanjila"},
    {hash = "WATER_SEA_OF_CORONADO", type = "lake", label = "Sea of Coronado"},
    {hash = "WATER_ARROYO_DE_LA_VIBORA", type = "river", label = "Arroyo de la Vibora"},
    {hash = "WATER_BEARTOOTH_BECK", type = "river", label = "Beartooth Beck"},
    {hash = "WATER_DAKOTA_RIVER", type = "river", label = "Dakota River"},
    {hash = "WATER_KAMASSA_RIVER", type = "river", label = "Kamassa River"},
    {hash = "WATER_LANNAHECHEE_RIVER", type = "river", label = "Lannahechee River"},
    {hash = "WATER_LITTLE_CREEK_RIVER", type = "river", label = "Little Creek River"},
    {hash = "WATER_LOWER_MONTANA_RIVER", type = "river", label = "Lower Montana River"},
    {hash = "WATER_SAN_LUIS_RIVER", type = "river", label = "San Luis River"},
    {hash = "WATER_UPPER_MONTANA_RIVER", type = "river", label = "Upper Montana River"},
    {hash = "WATER_BAYOU_NWA", type = "swamp", label = "Bayou Nwa"},
    {hash = "WATER_BAHIA_DE_LA_PAZ", type = "ocean", label = "Bahia de la Paz"},
    {hash = "WATER_DEADBOOT_CREEK", type = "creek", label = "Deadboot Creek"},
    {hash = "WATER_DEWBERRY_CREEK", type = "creek", label = "Dewberry Creek"},
    {hash = "WATER_HAWKS_EYE_CREEK", type = "creek", label = "Hawks Eye Creek"},
    {hash = "WATER_RINGNECK_CREEK", type = "creek", label = "Ringneck Creek"},
    {hash = "WATER_SPIDER_GORGE", type = "creek", label = "Spider Gorge"},
    {hash = "WATER_STILLWATER_CREEK", type = "creek", label = "Stillwater Creek"},
    {hash = "WATER_WHINYARD_STRAIT", type = "creek", label = "Whinyard Strait"},
    {hash = "WATER_CAIRN_LAKE", type = "pond", label = "Cairn Lake"},
    {hash = "WATER_CATTIAL_POND", type = "pond", label = "Cattial Pond"},
    {hash = "WATER_HOT_SPRINGS", type = "pond", label = "Hot Springs"},
    {hash = "WATER_MATTLOCK_POND", type = "pond", label = "Mattlock Pond"},
    {hash = "WATER_MOONSTONE_POND", type = "pond", label = "Moonstone Pond"},
    {hash = "WATER_SOUTHFIELD_FLATS", type = "pond", label = "Southfield Flats"},

}