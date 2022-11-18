# WAm0s: A Monster Battling Game Protocol

At last...the Gods have awakened...

## Getting Started

Clone repository into empty folder.

### Build and test project

`forge build` -> wait for dependencies to install
`npm i`
`forge test`

Create a .env file and `export PRIVATE_KEY=`

## Deploy to Mumbai

Get test MATIC: https://mumbaifaucet.com/

Deploy WamosV1: `npx hardhat run hh-scripts/deploy_wamosv1.js`

Create and fund a Chainlink VRF subscription at vrf.chain.link
Register the deployed WamosV1 address as a consumer.

WamosV1 is now deployed and anybody can mint with test Matic!

Paste the address of WamosV1 into the WAMOS_DEPLOY_ADDR in hardhat.config.js

Mint some Wam0s: `npx hardhat run hh-scripts/mint_wamosv1.js`

Deploy WamosBattleV1: `npx hardhat run hh-scripts/deploy_wamosbattlev1.js`

Store the deployed WamosBattle address in hardhat.config.js under key WAMOS_BATTLE_ADDR

## Play

1. mint at least two wamos
2. enter hardhat console
3. approve battle staking: `await wamos.approveBattleStaking()`
4. create a game: `await wamos.createGame(player2Address)`
5. connect two wamos: `await battle.connectWamo(0, wamo1) && await battle.connectWamo(0, wamo2)`
6. ready up: `await battle.connect(p1).playerReady(0);`
7. wait for player2 to connect both wamos and ready up
8. game has now begun
9. take turns calling `await battle.commitTurn(...)`

`    function commitTurn(
        uint256 gameId,
        uint256 actingWamoId,
        uint256 targetWamoId,
        uint256 moveChoice,
        uint256 abilityChoice,
        bool isMoved,
        bool moveBeforeAbility,
        bool useAbility
    ) external onlyPlayer(gameId) onlyOnfoot(gameId) `

Arguments include indices of move and ability choices.
See available moves with `await wamos.getWamoMovements()` and `await wamos.getWamoAbilities`, and enter index of each array to select move.

10. resign with `await battle.resign(gameId)` or defeat your opponent and call `await battle.claimVictory(gameId)`

11. retrieve wamos after game with `await battle.retrieveStakedWamos(gameId)`