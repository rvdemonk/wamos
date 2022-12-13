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

        // mint wamos 1-10, 11-20, 21-30 for p1, p2, badActor respectively
        uint256 requestId;
        for (uint i = 0; i < ACTORS.length; i++) {
            vm.prank(ACTORS[i]);
            requestId = wamos.requestSpawn{
                value: SETUP_BATCH_SIZE * MINT_PRICE
            }(uint32(SETUP_BATCH_SIZE));
            vrfCoordinator.fulfillRandomWords(requestId, address(wamos));
            wamos.completeSpawn(requestId);
        }

        // create game
        uint256 partySize = 3;
        uint256[3] memory party1 = [uint256(1), uint256(2), uint256(3)];
        uint256[3] memory party2 = [uint256(11), uint256(12), uint256(13)];
        vm.prank(player1);
        testGameId = arena.createGame(player2, partySize);
        // both players connect wamos
        vm.prank(player1);
        arena.connectWamos(testGameId, party1);
        vm.prank(player2);
        arena.connectWamos(testGameId, party2);
        // game should now be onfoot
    }
}