// SPDX-License-Identifier: UNLICENSED
pragma solidity <0.9.0;

import "forge-std/Test.sol";
import "~/test/VRFCoordinatorV2Mock.sol";
import "~/v2/WamosV2.sol";
import "~/v2/WamosV2Arena.sol";
import "./WamosV2TestHelper.sol";

contract WamosV2ArenaPlayTest is Test, WamosV2TestHelper {
    address[3] ACTORS = [player1, player2, badActor];

    // contracts
    WamosV2 wamos;
    WamosV2Arena arena;
    VRFCoordinatorV2Mock vrfCoordinator;

    // VRF COORD
    uint64 subscriptionId;
    uint256[] requestIds;

    // TEST GAME STORAGE
    uint256 testGameId;
    uint256[3] party1;
    uint256[3] party2;

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

        uint256 partySize = 3;
        party1 = [uint256(1), uint256(2), uint256(3)];
        party2 = [uint256(7), uint256(8), uint256(9)];
        vm.prank(player1);
        testGameId = arena.createGame(player2, partySize);
        // both players connect wamos
        vm.prank(player1);
        arena.connectWamos(testGameId, party1);
        vm.prank(player2);
        arena.connectWamos(testGameId, party2); 
        // game should now be onfoot
    }

    function moveForwardAsWith(address player, uint256 wamoId) internal {
        vm.prank(player);
        arena.commitTurn(
            testGameId,
            wamoId,
            7,
            3,
            0,
            true,
            true,
            false
        );        
    }

    function testGameOnFoot() public {
        assertTrue(arena.getGameStatus(testGameId) == GameStatus.ONFOOT);
    }

    function testMoveChangesIdenCorrectly() public {
        uint256 actingWamo = 1;
        uint256 moveSelection = 3; // should be +16

        int16 startPos = arena.getWamoPosition(actingWamo);
        int16 idenMutation = wamos.getMovement(actingWamo, moveSelection);

        assertTrue(idenMutation == 16);

        vm.prank(player1);
        bool isMoved = true;

        // move but do not use ability
        arena.commitTurn(
            testGameId,
            actingWamo,
            7,
            moveSelection,
            0,
            isMoved,
            true,
            false
        );

        int16 newIden = arena.getWamoPosition(actingWamo);
        assertTrue(newIden == startPos + idenMutation);
    }

    function testTurnCountIncrements() public {
        uint256 startCount = arena.getTurnCount(testGameId);
        moveForwardAsWith(player1, 1);
        assertTrue(arena.getTurnCount(testGameId) == startCount+1);
    }

    function testAbilityDamageIsInflicted() public {
        // use admin tools to first move wamos within range
        uint256 attacker = 1;
        uint256 target = 7;
        arena.setWamoPosition(attacker, 100);
        arena.setWamoPosition(target, 101);
        assertTrue(arena.getWamoPosition(attacker) == 100);
        assertTrue(arena.getWamoPosition(target) == 101);
        uint256 abilityChoice = 0;
        Ability memory ability = wamos.getAbility(attacker, abilityChoice);
        uint256 expectedDamage = arena.calculateDamage(attacker, target, ability);
        uint256 targetHealthStart = arena.getWamoStatus(target).health;
        // console.log("target full health:", targetHealthStart);
        // console.log("damage:", expectedDamage);
        // use ability without moving
        vm.prank(player1);
        arena.commitTurn(
            testGameId,
            attacker,
            target,
            0,
            abilityChoice,
            false,
            false,
            true
        );
        // check damage inficted
        uint256 targetHealthAfter = arena.getWamoStatus(target).health;
        // console.log("target updated health:", targetHealthAfter);
        assertTrue(targetHealthAfter == targetHealthStart - expectedDamage);
    }
}
