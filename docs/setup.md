# Setup

## Server.conf
### Install
Download the resource
``
cd C:\[path to txdata]\txData\FiveMBasicServerCFXDefault_9C3FD3.base\resources
git clone https://github.com/oracularhades/hades_claymore.git
``

Add the following line to your ``server.conf`` to add hades_claymore.
``
ensure hades_claymore
``

### Permissions
Give yourself permission to use Claymorees in your ``server.conf``
```
add_ace identifier.fivem:9685307 claymore.view_and_place allow 
```

## SQL
Run:
```
CREATE TABLE hades_claymore (id BIGINT AUTO_INCREMENT PRIMARY KEY, player_id VARCHAR(255), x FLOAT, y FLOAT, z FLOAT, created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, entity BIGINT);
```

## Ox_inventory
Append ``/example/items.lua`` to ``C:\[path to txdata]\txData\FiveMBasicServerCFXDefault_9C3FD3.base\resources\ox_inventory\data\items.lua``