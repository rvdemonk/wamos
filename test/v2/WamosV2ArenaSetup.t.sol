// SPDX-License-Identifier: UNLICENSED
pragma solidity <0.9.0;

import "forge-std/Test.sol";
import "~/test/VRFCoordinatorV2Mock.sol";
import "~/v2/WamosV2.sol";
import "~/v2/WamosV2Arena.sol";
import "./WamosV2TestHelper.sol";

contract WamosV2ArenaSetupTest is Test, WamosV2TestHelper {
    address[3] ACTORS = [player1, player2, badActor];

    // contracts
    WamosV2 wamos;
    WamosV2Arena arena;
    VRFCoordinatorV2Mock vrfCoordinator;

    // VRF COORD
    uint64 subscriptionId;
    uint256[] requestIds;

    // TEST GAME
    uint256 testGameId;

    function setUp() public {
        // mock vrf setup
        vrfCoordinator = new VRFCoordinatorV2Mock(BASE_FEE, GAS_PRICE_LINK);
        subscriptionId = vrfCoordinator.createSubscription();
        // deploy wamos v2
        wamos = new WamosV2(
            address(vrfCoordinator),
            VRF_MOCK_KEYHASH,
            subscriptionId,
            MINT_PRICE
        );
        // configure vrf subscription
        vrfCoordinator.addConsumer(subscriptionId, address(wamos));
        vrfCoordinator.fundSubscription(subscriptionId, SUB_FUNDING);
        // deploy wamos arena
        arena = new WamosV2Arena(address(wamos));
        // set wamos address in battle
        wamos.setWamosArenaAddress(address(arena));

        // approve staking for players
        vm.prank(player1);
        wamos.approveArenaStaking();
        vm.prank(player2);
        wamos.approveArenaStaking();
        // badActor player not approved for testing
        // deal some funny money
        vm.deal(player1, ACTOR_STARTING_BAL);
        vm.deal(player2, ACTOR_STARTING_BAL);
        vm.deal(badActor, ACTOR_STARTING_BAL);

        // mint 6 wamos for p1, p2, badActor
        uint256 requestId;

        for (uint i = 0; i < ACTORS.length; i++) {
            vm.prank(ACTORS[i]);
            requestId = wamos.requestSpawn{value: SETUP_BATCH_SIZE * MINT_PRICE}(uint32(SETUP_BATCH_SIZE));
            vrfCoordinator.fulfillRandomWords(requestId, address(wamos));
            wamos.completeSpawn(requestId);
        }
    }

    // ------------------ UTILITIES -------------------- //

    function init3WGameAsP1() internal returns (uint256 gameId, uint256[3] memory party1, uint256[3] memory party2) {
        uint256 partySize = 3;
        party1 = [uint256(1), uint256(2), uint256(3)];
        party2 = [uint256(7), uint256(8), uint256(9)];
        vm.prank(player1);
        gameId = arena.createGame(player2, partySize);
        // both players connect wamos
        vm.prank(player1);
        arena.connectWamos(testGameId, party1);
        vm.prank(player2);
        arena.connectWamos(testGameId, party2); 
    }

    // ------------------ TESTS -------------------- //

    function testWamoSetupOwnership() public {
        address owner;
        for (uint256 i=1; i<=3*SETUP_BATCH_SIZE; i++) {
            owner = ACTORS[(i-1)/6];
            assertTrue(owner == wamos.ownerOf(i));
            // console.log(wamos.ownerOf(i));
        }
    }

    function testGameCountStartsZero() public {
        assertTrue(arena.gameCount() == 0);
    }

    function testSpawnedWamoStatusStartsOutOfArena() public {
        uint256 supply = wamos.nextWamoId();
        for (uint256 i=1; i<supply; i++) {
            WamoStatus memory status = arena.getWamoStatus(i);
            assertFalse(status.inArena);
        }
    }

    function testInitGameStatusIsPregame() public {
        uint256 partySize = 3;
        uint256[3] memory party1 = [uint256(1), uint256(2), uint256(3)];
        uint256[3] memory party2 = [uint256(7), uint256(8), uint256(9)];
        vm.prank(player1);
        uint256 gameId = arena.createGame(player2, partySize);
        assertTrue(arena.getGameStatus(gameId) == GameStatus.PREGAME);
    }

    function testGameCountIncrements() public {
        (uint256 gameId,,) = init3WGameAsP1();
        uint256 gameCount = arena.gameCount();
        assertTrue(gameCount == 1);
    }

    function testGameOnFootAfterConnecting() public {
        (uint256 gameId,,) = init3WGameAsP1();
        GameStatus status = arena.getGameStatus(gameId);
        assertTrue(status == GameStatus.ONFOOT);
    }

    function testArenaOwnsWamosAfterConnecting() public {
        (uint256 gameId, uint256[3] memory party1, uint256[3] memory party2) 
            = init3WGameAsP1();
        for (uint256 i=0; i<3; i++) {
            assertTrue(wamos.ownerOf(party1[i]) == address(arena));
            assertTrue(wamos.ownerOf(party2[i]) == address(arena));
        }
    }

    function testWamoStakingStatusAfterConnecting() public {
        (uint256 gameId, uint256[3] memory party1, uint256[3] memory party2) 
            = init3WGameAsP1();
        for (uint256 i=0; i<3; i++) {
            WamoStatus memory status1 = arena.getWamoStatus(party1[i]);
            WamoStatus memory status2 = arena.getWamoStatus(party2[i]);
            assertTrue(status1.inArena);
            assertTrue(status2.inArena);
        }   
    }



}
