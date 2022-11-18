// run mint script - mint one wamo
// enter hardhat terminal

const wamos = await hre.ethers.getContractAt("WamosV1", hre.config.WAMOS_DEPLOY_ADDR);
const battle = await hre.ethers.getContractAt("WamosBattleV1", hre.config.WAMOS_BATTLE_ADDR);

const [p1,p2] = await hre.ethers.getSigners()

await wamos.approveBattleStaking()
await wamos.connect(p2).approveBattleStaking()

// create game
const gameid = await wamos.connect(p1).createGame(p2.address)

// p2 stakes 11 and 12
// p1 stake 3 and 4

await battle.connect(p2).connectWamo(0, 1)
await battle.connect(p2).connectWamo(0, 2)

await battle.connect(p1).connectWamo(0, 3)
await battle.connect(p1).connectWamo(0, 4)

await battle.connect(p1).playerReady(0);
await battle.connect(p2).playerReady(0);

await battle.getGameStatus(0);

// game has begun
const LEFT = 0;
const RIGHT = 1;
const UP = 2;
const DOWN = 3;
await battle.connect(pl2).commitTurn( 
    0,
    12,
    0,
    UP,
    0,
    true,
    true,
    false
);