// SPDX-License-Identifier: UNLICENSED
pragma solidity <0.9.0;

import "forge-std/Test.sol";
import "../../src/test/VRFCoordinatorV2Mock.sol";
import "../../src/v1/WamosV1.sol";
import "../../src/v1/WamosBattleV1.sol";

abstract contract WamosTestHelper {
    // COORDINATOR CONFIG
    uint96 BASE_FEE = 10000;
    uint96 GAS_PRICE_LINK = 10000;
    uint96 SUB_FUNDING = 100000000000000000;
    bytes32 VRF_MOCK_KEYHASH =
        0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc;

    // MINT CONFIG
    uint256 MINT_PRICE = 0.01 ether;

    // TEST CONFIG
    uint256 ACTOR_STARTING_BAL = 1 ether;
    uint256 WAMOS_PER_PLAYER = 10;
    address player1 = 0x316DBF75409134CBcb1b3e0f013ABbfcF63CA040;
    address player2 = 0x417622F534d5F30321CF78cB7355773f8BAC7621;
    address badActor = 0xA5cd5af52b504895c8525B5A5677859Fb04F8907;

    // VRF STORAGE
    uint64 subscriptionId;
    uint256[] requestIds;

    // OUTSIDE CONTRACTS
    VRFCoordinatorV2Mock vrfCoordinator;
    WamosV1 wamos;
    WamosBattleV1 battle;


    function logAbility(uint256 wamoId, uint256 abilityIndex) public {
        Ability memory ability = wamos.getWamoAbility(wamoId, abilityIndex);
        console.log("\n *****Wamo #%s Ability %s", wamoId, abilityIndex);
        console.log("damge type", uint256(ability.damageType));
        console.log("power", ability.power);
        console.log("accuracy", ability.accuracy);
        console.logInt(ability.range);
        console.log("cost", ability.cost);
    }

    function logAbility(Ability memory ability) public {
        console.log("damge type", uint256(ability.damageType));
        console.log("power", ability.power);
        console.log("accuracy", ability.accuracy);
        console.logInt(ability.range);
        console.log("cost", ability.cost);
    }

    function logWamoStatus(uint256 gameId, uint256 wamoId) public {
        WamoStatus memory status = battle.getWamoStatus(gameId, wamoId);
        console.log("--- Status wamo #%s ---", wamoId);
        console.log("health %s", status.health);
        console.log("stamina %s", status.stamina);
        console.log("mana %s", status.mana);
    }

    function logHealth(uint256 gameId, uint256 wamoId) public {
        WamoStatus memory status = battle.getWamoStatus(gameId, wamoId);
        console.log("Wamo #%s health: %s", wamoId, status.health);
    }

    // // todo
    // function logAllHealth(uint256 gameId) public {
    //     GameData memory data = battle.getGameData(gameId);
    //     address challenger = data.challenger;
    //     address challengee = data.challengee;
    //     // uint256[2] memory party1 = 
    // }

    function logTurn(uint256 gameId) public {
        GameData memory data = battle.getGameData(gameId);
        console.log("\n|---> Turn %s", data.turnCount);        
    }

    function logPosition(uint256 gameId, uint256 wamoId) public {
        int16 pos = battle.getWamoPosition(gameId, wamoId);
        console.log("Position of Wamo #%s", wamoId);
        console.logInt(pos);
    }
}

contract WamosBattleV1GameTest is Test, WamosTestHelper {

    // MOVE INDICES
    uint256 LEFT = 0;
    uint256 RIGHT = 1;
    uint256 UP = 2;
    uint256 DOWN = 3;

    uint256[] games;
    uint256 PARTY_SIZE;
    uint256[2] p1party;
    uint256[2] p2party;

    function setUp() public {
        // set up coordinator mock
        vrfCoordinator = new VRFCoordinatorV2Mock(BASE_FEE, GAS_PRICE_LINK);
        subscriptionId = vrfCoordinator.createSubscription();
        // deploy WamosV1
        wamos = new WamosV1(
            address(vrfCoordinator),
            VRF_MOCK_KEYHASH,
            subscriptionId,
            MINT_PRICE
        );
        // add wamos as consumer
        vrfCoordinator.addConsumer(subscriptionId, address(wamos));
        // fund subscription
        vrfCoordinator.fundSubscription(subscriptionId, SUB_FUNDING);

        // deploy wamos battle v1
        battle = new WamosBattleV1(
            address(wamos),
            address(vrfCoordinator),
            VRF_MOCK_KEYHASH,
            subscriptionId
        );
        PARTY_SIZE = battle.PARTY_SIZE();

        wamos.setWamosBattleAddress(address(battle));

        // approve staking in wamos for wamos battle
        vm.prank(player1);
        wamos.approveBattleStaking();
        vm.prank(player2);
        wamos.approveBattleStaking();
        // vm.prank(badActor);
        // wamos.approveBattleStaking();

        // deal some funny money
        vm.deal(player1, ACTOR_STARTING_BAL);
        vm.deal(player2, ACTOR_STARTING_BAL);
        vm.deal(badActor, ACTOR_STARTING_BAL);

        // mint 10 wamos for each player
        uint256 requestId;
        uint256 tokenId;
        address minter;
        // player 1 owns odd id wamos, player 2 owns evens
        for (uint256 i = 0; i < WAMOS_PER_PLAYER * 2; i++) {
            if (i % 2 == 1) {
                minter = player1;
            } else {
                minter = player2;
            }
            vm.prank(minter);
            requestId = wamos.requestSpawnWamo{value: MINT_PRICE}();
            vrfCoordinator.fulfillRandomWords(requestId, address(wamos));
            tokenId = wamos.getTokenIdFromRequestId(requestId);
            vm.prank(minter);
            wamos.completeSpawnWamo(tokenId);
        }
        // mint wamos 21-30 for bad actor
        for (uint256 i = 20; i < WAMOS_PER_PLAYER * 3; i++) {
            vm.prank(badActor);
            requestId = wamos.requestSpawnWamo{value: MINT_PRICE}();
            vrfCoordinator.fulfillRandomWords(requestId, address(wamos));
            tokenId = wamos.getTokenIdFromRequestId(requestId);
            vm.prank(badActor);
            wamos.completeSpawnWamo(tokenId);
        }

        // setup game 0
        vm.startPrank(player1);
        uint256 gameid = battle.createGame(player2);
        games.push(gameid);
        battle.connectWamo(gameid, 1);
        battle.connectWamo(gameid, 3);
        battle.playerReady(gameid);
        vm.stopPrank();
        vm.startPrank(player2);
        battle.connectWamo(gameid, 2);
        battle.connectWamo(gameid, 4);
        battle.playerReady(gameid);
        vm.stopPrank();

        p1party = battle.getPlayerParty(games[0], player1);
        p2party = battle.getPlayerParty(games[0], player2);
    }

    function testGameOnfoot() public {
        assertTrue(battle.getGameStatus(games[0])==GameStatus.ONFOOT);
    }

    function testPlayerPartyFull() public {
        assertTrue(battle.getPlayerStakedCount(games[0], player1) == battle.PARTY_SIZE());
        assertTrue(battle.getPlayerStakedCount(games[0], player2) == battle.PARTY_SIZE());
        uint256[2] memory party1 = battle.getPlayerParty(games[0], player1);
        uint256[2] memory party2 = battle.getPlayerParty(games[0], player2);
        assertTrue(party1[0] != 0);
        assertTrue(party1[1] != 0);
        assertTrue(party2[0] != 0);
        assertTrue(party2[1] != 0);
    }

    function testTraitsLoaded() public {
        for (uint i = 1; i < 2*PARTY_SIZE + 1; i++) {
            WamoTraits memory traits = wamos.getWamoTraits(i);
            WamoStatus memory status = battle.getWamoStatus(games[0], i);
            assertFalse(status.health == 0);
            assertTrue(traits.health == status.health);
            assertTrue(traits.mana == status.mana);
            assertTrue(traits.stamina == status.stamina);
        }
    }

    function testAbilitiesExist() public {
        for (uint i = 1; i < 2*PARTY_SIZE + 1; i++) {
            Ability[] memory abilities = wamos.getWamoAbilities(i);
            for (uint j=0; j<1; j++) {
                assertFalse(abilities[j].power == 0);
                assertFalse(abilities[j].accuracy == 0);
                assertFalse(abilities[j].range == 0);
                assertFalse(abilities[j].cost == 0);
            }
        }   
    }

    function testCommitTurnMoveOnly() public {
        // moving wamo #1
        uint256 move = 2;
        int16[8] memory w1moves = wamos.getWamoMovements(1);
        console.logInt(w1moves[move]); // +16
        assertTrue(w1moves[move] == 16);
        int16 w1posStart = battle.getWamoPosition(games[0], 1);
        assertTrue(w1posStart == 0);
        vm.startPrank(player1);
        battle.commitTurn(
            games[0],
            1,
            0,
            move,
            0,
            true,
            true,
            false
        );
        assertTrue(battle.getWamoPosition(games[0], 1) == w1posStart + w1moves[move]);
    }

    function testTurnsMoving() public {
        int16[8] memory w1moves = wamos.getWamoMovements(1);
        int16[8] memory w3moves = wamos.getWamoMovements(2);
        int16 w1Pos = battle.getWamoPosition(games[0], 1);
        int16 w2Pos = battle.getWamoPosition(games[0], 2);
        assertTrue(w1Pos == 0);
        assertTrue(w2Pos == 255);
        while (true) {
            vm.prank(player1);
            battle.commitTurn(
                games[0],
                1,
                0,
                UP,
                0,
                true,
                true,
                false
            ); 
            if (battle.getWamoPosition(games[0], 1) == 128) {
                break;
            }
            vm.prank(player2);
            battle.commitTurn(
                games[0],
                2,
                0,
                DOWN,
                0,
                true,
                true,
                false
            ); 
            if (battle.getTurnCount(games[0]) > 50) {
                break;
            }
            logPosition(games[0], 1);
            logPosition(games[0], 2);        
        }
        while (true) {
            vm.prank(player2);
            battle.commitTurn(
                games[0],
                2,
                0,
                LEFT,
                0,
                true,
                true,
                false
            ); 
            vm.prank(player1);
            battle.commitTurn(
                games[0],
                1,
                0,
                RIGHT,
                0,
                true,
                true,
                false
            ); 
            if (battle.getWamoPosition(games[0], 1) == 136) {
                break;
            } 
            if (battle.getTurnCount(games[0]) > 50) {
                break;
            }            
        }
        // get abilities
        Ability[] memory w1Abilities = wamos.getWamoAbilities(1);
        Ability[] memory w2Abilities = wamos.getWamoAbilities(2);

        uint256 w1StartHealth = battle.getWamoStatus(games[0], 1).health;
        uint256 w2StartHealth = battle.getWamoStatus(games[0], 2).health;

        vm.startPrank(player2);

        // wamos now next o each other
        int16 w1pos = battle.getWamoPosition(games[0], 1);
        int16 w2pos = battle.getWamoPosition(games[0], 2);
        assertTrue(w1pos == 136);
        assertTrue(w2pos == 135);
        console.log("---POSITIONS BEFORE ATTACK");
        logPosition(games[0], 1);
        logPosition(games[0], 2);
        

        // battle.changeWamoHealth(games[0], 1, 1);

        // WORKING UNTIL HERE

        console.log("---WAMO #2 ATTACKING");
        uint256 abilityChoice = 2;
        logAbility(2, abilityChoice );
        battle.commitTurn(
            games[0],
            2,
            1,
            RIGHT,
            abilityChoice,
            false,
            false,
            true
        );

        uint256 w1AfterHealth = battle.getWamoStatus(games[0], 1).health;
        uint256 w2AfterHealth = battle.getWamoStatus(games[0], 2).health;

        // TODO FOR SOME REASON DAMAGE IS DEALT TO ATTACKING WAMO REGARDLESS
        console.log("wamo 1 hp change: %s --> %s", w1StartHealth, w1AfterHealth);
        console.log("wamo 2 hp change: %s --> %s", w2StartHealth, w2AfterHealth);

    }
}
