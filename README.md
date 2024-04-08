# bcc-goldpanning

## Features

- River driven Gold Panning with Props.
- Realistic gold panning mechanics.
- Minigame added for extra enjoyment.
- River location checks on item use.


## Installation

1. Ensure you have VORP installed and 
2. Download the latest release of the "bcc-goldpanning" script.
3. Copy the script files into your resource folder.
4. Add the script to your server.cfg file.
5. Ensure you edit the config.lua to match your river or water scripts.
6. Make sure you have all other items in your database or change the config
7. if you want to use my images look in the image folder
8. Check DEPENDENCIES! and make sure they are ensure before the script

## Usage

1. Find a suitable location near a river or stream in the game.
2. Equip your character with the necessary tools for gold panning.
3. Interact with the water source to start the gold panning activity.
4. Follow the on-screen prompts to perform the panning actions.
5. Collect any gold nuggets that you find and store them in your inventory.
6. Sell the collected gold at designated locations within the game.

## Dependency
- bcc-utils https://github.com/BryceCanyonCounty/bcc-utils
- bcc-minigame https://github.com/BryceCanyonCounty/bcc-minigames
- feather-progressbar https://github.com/FeatherFramework/feather-progressbar
 
## SQL
### If you want to use my items
```sql
INSERT IGNORE INTO items (`item`, `label`, `limit`, `can_remove`, `type`, `usable`) VALUES 
                         ('p_goldcradlestand01x', 'Gold Wash Table', 1, 1, 'item_standard', 1),
                         ('mud_bucket', 'Bucket of Mud', 20, 1, 'item_standard', 1),
                         ('empty_mud_bucket', 'Empty mud bucket', 20, 1, 'item_standard', 1),
                         ('wateringcan', 'Watering Can', 20, 1, 'item_standard', 1),
                         ('wateringcan_empty', 'empty watering can', 20, 1, 'item_standard', 1),
```


## Credits
- FistsOFury for the main development of this script.
- Jannings and BCC-Saloon for some of the prop based code
- CocomonkSKY for the images
