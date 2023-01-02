# TICKETS

## TASKS + SCRIPTS
 - get artifacts -> getWamoArtifact, getArenaArtifact
    - update getWamos, getArena
    - fix new world task to export artifacts into separate jsons
    - update front end import statements
 - split helper functions into smaller utilities modules: deployers, artifacters, getters,
    vrfers, etc
    - update task and script imports to require(helpers/deployers) etc
 - test wamo traits task
 - mint wamo task with receipient arg
 - change contract getters so that they use the abi of the deployed function, instead of potentially using the compiled abi of a newer, updated contract that was not deployed

## WAMOS CONTRACT
 - add address argument to spawn function to allow for gifting
 - ability gen
 - movement gen
 - on-chain sprite art

## ARENA CONTRACT
 - encoding of game data
 - variable party size
 - require statements in connect wamos
 - require statements everywhere actually

## OTHER
 - breeding contract design
 - tourney contract design
 - colour palette and vibes
 - lore expansion
