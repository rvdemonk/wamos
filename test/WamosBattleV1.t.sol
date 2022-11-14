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
    address deployer = 0xA5cd5af52b504895c8525B5A5677859Fb04F8907;
    address player1 = 0x316DBF75409134CBcb1b3e0f013ABbfcF63CA040;
    address player2 = 0x417622F534d5F30321CF78cB7355773f8BAC7621;

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
        vm.prank(deployer);
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

        vm.deal(player1, ACTOR_STARTING_BAL);
        vm.deal(player2, ACTOR_STARTING_BAL);

        // mint 10 wamos for each player
        uint256 requestId;
        uint256 tokenId;
        address minter;
        // player 1 owns odd wamos, player 2 owns evens
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

    function testWamosCanConnect() public {
        // create game
        vm.prank(player1);
        uint256 gameId = wamosBattle.createGame(player2);
        // connect wamos
        vm.prank(player1);
        wamosBattle.connectWamo(gameId, 1);
        // vm.prank(player1);
        // wamosBattle.connectWamo(gameId, p1Party[1]);
        // vm.prank(player2);
        // wamosBattle.connectWamo(gameId, p2Party[0]);
        // vm.prank(player2);
        // wamosBattle.connectWamo(gameId, p2Party[1]);
    }

    function testCannotConnectThirdParty() public {}

    /** TEST VIEW FUNCTIONS */

    // function testGetGameData() public {}

    /** TEST POINTS OF FAILURE */

    // function testChallengesReceived() public {}
}
