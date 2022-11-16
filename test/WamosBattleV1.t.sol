// SPDX-License-Identifier: UNLICENSED
pragma solidity <0.9.0;

import "forge-std/Test.sol";
import "../src/test/VRFCoordinatorV2Mock.sol";
import "../src/v1/WamosV1.sol";
import "../src/v1/WamosBattleV1.sol";

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
}

contract WamosBattleV1Test is Test, WamosTestHelper {
    WamosBattleV1 wamosBattle;

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
        wamosBattle = new WamosBattleV1(
            address(wamos),
            address(vrfCoordinator),
            VRF_MOCK_KEYHASH,
            subscriptionId
        );

        wamos.setWamosBattleAddress(address(wamosBattle));

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

        for (uint256 i = 20; i < WAMOS_PER_PLAYER * 3; i++) {
            vm.prank(badActor);
            requestId = wamos.requestSpawnWamo{value: MINT_PRICE}();
            vrfCoordinator.fulfillRandomWords(requestId, address(wamos));
            tokenId = wamos.getTokenIdFromRequestId(requestId);
            vm.prank(badActor);
            wamos.completeSpawnWamo(tokenId);
        }
    }

    function testPlayersOwnWamos() public {
        uint256 p1Balance = wamos.balanceOf(player1);
        uint256 p2Balance = wamos.balanceOf(player2);
        assertTrue(p1Balance == WAMOS_PER_PLAYER);
        assertTrue(p2Balance == WAMOS_PER_PLAYER);
    }

    function testWamosHaveTraits() public {
        for (uint256 id = 0; id < WAMOS_PER_PLAYER * 2; id++) {
            WamoTraits memory traits = wamos.getWamoTraits(id);
            uint256 health = traits.health;
            // console.log(health);
            assertTrue(health > 0);
        }
    }

    function testWamosBattleDeployed() public {
        assertTrue(address(wamosBattle) != address(0));
        assertTrue(wamosBattle.GRID_SIZE() == 16);
    }

    /** TEST BASIC GAME CREATION FUNCTIONALITY */

    function testGameCreated() public {
        vm.prank(player1);
        uint256 gameId = wamosBattle.createGame(player2);
        // console.log(gameId);
        GameData memory game = wamosBattle.getGameData(gameId);
        assertTrue(game.id == gameId);
        assertTrue(game.createTime != 0);
        assertTrue(game.challenger == player1);
        assertTrue(game.challengee == player2);
        assertTrue(game.turnCount == 0);
    }

    function testGameStatusStartsPregame() public {
        vm.prank(player1);
        uint256 gameId = wamosBattle.createGame(player2);
        GameData memory data = wamosBattle.getGameData(gameId);
        assertTrue(data.status == GameStatus.PREGAME);
    }

    function testGameCountIncrements() public {
        uint256 gamesToCreate = 20;
        uint256 startCount = wamosBattle.gameCount();
        for (uint256 i = 0; i < gamesToCreate; i++) {
            vm.prank(player1);
            wamosBattle.createGame(player2);
        }
        uint256 endCount = wamosBattle.gameCount();
        assertTrue(endCount == startCount + gamesToCreate);
    }

    function testGameId() public {
        uint256 gamesToCreate = 20;
        uint256 startCount = wamosBattle.gameCount();
        for (uint256 i = 0; i < gamesToCreate; i++) {
            vm.prank(player1);
            wamosBattle.createGame(player2);
        }
        uint256 endCount = wamosBattle.gameCount();
        assertTrue(wamosBattle.getGameData(19).id == 19);
    }

    /** TEST WAMO CONNECTION */

    function testBattleIsTransferApproved() public {
        assertTrue(wamos.isApprovedForAll(player1, address(wamosBattle)));
        assertTrue(wamos.isApprovedForAll(player2, address(wamosBattle)));
    }

    function testCannotConnectWithoutApproving() public {
        vm.startPrank(badActor);
        uint256 id = wamosBattle.createGame(player2);
        vm.expectRevert();
        wamosBattle.connectWamo(id, 25);
    }

    function testWamosCanConnect() public {
        // create game
        vm.prank(player1);
        uint256 gameId = wamosBattle.createGame(player2);
        // connect p1 wamos
        vm.prank(player1);
        wamosBattle.connectWamo(gameId, 1);
        vm.prank(player1);
        wamosBattle.connectWamo(gameId, 3);
        // connect p2 wamos
        vm.prank(player2);
        wamosBattle.connectWamo(gameId, 2);
        vm.prank(player2);
        wamosBattle.connectWamo(gameId, 4);
        // get players parties
        // uint256[wamosBattle.PARTY_SIZE] memory party1 = wamosBattle
        //     .getPlayerParty(gameId, player1);
        // uint256[wamosBattle.PARTY_SIZE] memory party2 = wamosBattle
        //     .getPlayerParty(gameId, player2);

        // check wamos battle owns tokens
        assertTrue(wamos.ownerOf(1) == address(wamosBattle));
        assertTrue(wamos.ownerOf(2) == address(wamosBattle));
        assertTrue(wamos.ownerOf(3) == address(wamosBattle));
        assertTrue(wamos.ownerOf(4) == address(wamosBattle));

        // check mapping for staked count
        assertTrue(wamosBattle.getPlayerStakedCount(gameId, player1) == 2);
        assertTrue(wamosBattle.getPlayerStakedCount(gameId, player2) == 2);
    }

    function testCannotConnectThirdParty() public {
        vm.prank(player1);
        uint256 gameId = wamosBattle.createGame(player2);

        vm.startPrank(badActor);
        wamos.approveBattleStaking();
        vm.expectRevert();
        wamosBattle.connectWamo(gameId, 25);
    }

    function testCannotStakeExtraWamo() public {
        vm.startPrank(player1);
        uint256 gameId = wamosBattle.createGame(player2);
        wamosBattle.connectWamo(gameId, 1);
        wamosBattle.connectWamo(gameId, 3);
        // console.log(wamosBattle.getPlayerStakedCount(gameId, player1));
        vm.expectRevert();
        wamosBattle.connectWamo(gameId, 5);
        // console.log(wamosBattle.getPlayerStakedCount(gameId, player1));
    }

    function testCannotStakeUnownedWamo() public {
        vm.startPrank(player1);
        uint256 gameId = wamosBattle.createGame(player2);
        wamosBattle.connectWamo(gameId, 1);
        vm.expectRevert();
        wamosBattle.connectWamo(gameId, 4); //unowned        
    }

    function testCannotStakeSameWamoTwice() public {
        vm.startPrank(player1);
        uint256 gameId = wamosBattle.createGame(player2);
        wamosBattle.connectWamo(gameId, 1);
        vm.expectRevert();
        wamosBattle.connectWamo(gameId, 1);
    }

    /** TEST PLAYER READY */

    function testPlayerReadyToggle() public {
        vm.startPrank(player1);
        uint256 gameId = wamosBattle.createGame(player2);
        wamosBattle.connectWamo(gameId, 1);
        wamosBattle.connectWamo(gameId, 3);
        assertFalse(wamosBattle.isPlayerReady(gameId, player1));
        wamosBattle.playerReady(gameId);
        assertTrue(wamosBattle.isPlayerReady(gameId, player1));
    }

    function testCannotReadyWithoutFullParty() public {
        vm.startPrank(player1);
        uint256 gameId = wamosBattle.createGame(player2);
        wamosBattle.connectWamo(gameId, 1);
        vm.expectRevert();
        wamosBattle.playerReady(gameId);
    }

    function testGameNotStartedWithOnePlayerReady() public {
        vm.startPrank(player1);
        uint256 gameId = wamosBattle.createGame(player2);
        wamosBattle.connectWamo(gameId, 1);
        wamosBattle.connectWamo(gameId, 3);
        wamosBattle.playerReady(gameId);
        assertTrue(wamosBattle.getGameStatus(gameId) == GameStatus.PREGAME);
    }

    function testGameStartsWhenPlayersReady() public {
        vm.startPrank(player1);
        uint256 gameId = wamosBattle.createGame(player2);
        wamosBattle.connectWamo(gameId, 1);
        wamosBattle.connectWamo(gameId, 3);
        wamosBattle.playerReady(gameId);
        vm.stopPrank();
        vm.startPrank(player2);
        wamosBattle.connectWamo(gameId, 2);
        wamosBattle.connectWamo(gameId, 4);
        wamosBattle.playerReady(gameId);
        assertTrue(wamosBattle.getGameStatus(gameId) == GameStatus.ONFOOT);
    }

    /** TEST GAME START */

    function testCannotTakeTurnBeforeGameOnfoot() public {}
    
    /** TEST GAMEPLAY */

    function testCommitTurn() public {
        vm.startPrank(player1);
        uint256 wamo1 = 1;
        uint256 gameId = wamosBattle.createGame(player2);
        wamosBattle.connectWamo(gameId, wamo1);
        wamosBattle.connectWamo(gameId, 3);
        wamosBattle.playerReady(gameId);
        vm.stopPrank();
        vm.startPrank(player2);
        wamosBattle.connectWamo(gameId, 2);
        wamosBattle.connectWamo(gameId, 4);
        wamosBattle.playerReady(gameId);
        assertTrue(wamosBattle.getGameStatus(gameId) == GameStatus.ONFOOT);
        vm.stopPrank();
        //
        uint256[2] memory party1 = wamosBattle
            .getPlayerParty(gameId, player1);
        console.log(party1[0]);
        console.log(party1[1]);
        // gass 655k
        vm.prank(player1);
        wamosBattle.commitTurn(
            gameId,
            wamo1,
            4,
            0,
            17,
            true
        );
    }


    /** TEST VIEW FUNCTIONS */

    // function testGetGameData() public {}

    /** TEST POINTS OF FAILURE */

    // function testChallengesReceived() public {}
}
