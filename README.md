# FiveM Claymore Script

*Pending documentation*

**This code needs clean-up and documentation written. Not ready for production use just yet**

TODO:
- Code clean-up. This code is based on the GoSnitch codebase and still has some skeletons.
- Sound effects
- PED animations
- Move player ids from player server IDs to CFX IDs.
- Extensions (Allows calling out to external resources for permissions to handle shouldExplode/shouldPlace/shouldDefuse/etc logic).
- /admin-claymore-clear: Option to delete Claymores in certain radius rather than always deleting all Claymores.

# Setup

## Install
In your ``resources`` folder:
```
git clone https://github.com/oracularhades/hades_claymore.git
```

Add to your ``server.conf``:
```
ensure hades_claymore
```

## Database (MySQL)
Run:
```
CREATE TABLE hades_claymore (id BIGINT AUTO_INCREMENT PRIMARY KEY, player_id VARCHAR(255), entity BIGINT, x FLOAT, y FLOAT, z FLOAT, created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP);
```

## Permissions
Give yourself permission to use Claymores:
```
add_ace identifier.fivem:[your CFX ID] claymore.view_and_place allow 
```

Give yourself Claymore admin permissions:
```
add_ace identifier.fivem:[your CFX ID] claymore.admin allow 
```

## Items
### Ox_inventory
To make Claymores usable in Ox_inventory, append ``/example/items.lua`` to ``[resource_folder]/ox_inventory/data/items.lua``

### Give yourself Claymore
```
/giveitem [your server id] claymore [amount]
```