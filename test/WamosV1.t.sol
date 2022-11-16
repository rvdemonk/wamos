// SPDX-License-Identifier: UNLICENSED
pragma solidity <0.9.0;

import "forge-std/Test.sol";
import "../src/v1/WamosV1.sol";
import "../src/test/VRFCoordinatorV2Mock.sol";

contract WamosV1Test is Test {
    uint96 BASE_FEE = 10000;
    uint96 GAS_PRICE_LINK = 10000;
    uint96 SUB_FUNDING = 100000000000000000;
    bytes32 VRF_MOCK_KEYHASH =
        0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc;
    uint256 MINT_PRICE = 0.01 ether;

    address deployer = 0xA5cd5af52b504895c8525B5A5677859Fb04F8907;
    address player1 = 0x316DBF75409134CBcb1b3e0f013ABbfcF63CA040;
    address player2 = 0x417622F534d5F30321CF78cB7355773f8BAC7621;

    uint256 ACTOR_STARTING_BAL = 1 ether;

    VRFCoordinatorV2Mock vrfCoordinator;
    WamosV1 wamos;
    uint64 subscriptionId;
    uint256[] requestIds;

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
        // fund wallet
        vm.deal(player1, ACTOR_STARTING_BAL);
        // console.log("Rvdemonk setup balance: %s", actor.balance);
    }

    function testWamosIsDeployed() public {
        assertTrue(address(wamos) != address(0));
    }

    function testWamosAddedAsConsumer() public {
        bool consumerIsAdded = vrfCoordinator.consumerIsAdded(
            subscriptionId,
            address(wamos)
        );
        assertTrue(consumerIsAdded);
    }

    function testSubscriptionIsFunded() public {
        (uint96 balance, , , address[] memory consumers) = vrfCoordinator
            .getSubscription(subscriptionId);
        assertTrue(balance == SUB_FUNDING);
        assertTrue(consumers[0] == address(wamos));
    }

    function testInitialTokenCount() public {
        assert(wamos.tokenCount() == 0);
    }

    function testSpawnRequestDoesntExist() public {
        uint256 requestId = 0;
        SpawnRequest memory request = wamos.getSpawnRequest(requestId);
        assertFalse(request.exists);
        assertFalse(request.randomnessFulfilled);
        assertFalse(request.completed);
        // alternate method
        bool requestIsFulfilled = wamos.getSpawnRequestStatus(requestId);
        assertFalse(requestIsFulfilled);
    }

    function testSpawnRequestExists() public {
        uint256 mintPrice = wamos.mintPrice();
        vm.prank(player1);
        uint256 requestId = wamos.requestSpawnWamo{value: mintPrice}();
        SpawnRequest memory request = wamos.getSpawnRequest(requestId);

        assertTrue(request.exists);
        assertTrue(wamos.lastRequestId() == requestId);
        assertTrue(wamos.requestIds(0) == requestId);
    }

    function testCountIncrementsAfterSpawn() public {
        uint256 beforeCount = wamos.tokenCount();
        vm.prank(player1);
        uint256 requestId = wamos.requestSpawnWamo{value: MINT_PRICE}();
        uint256 afterCount = wamos.tokenCount();
        assertTrue(beforeCount + 1 == afterCount);
        console.log("before count: %s", beforeCount);
        console.log("after count: %s", afterCount);
    }

    function testRequestRandomnessFulfills() public {
        vm.prank(player1);
        uint256 requestId = wamos.requestSpawnWamo{value: MINT_PRICE}();
        vrfCoordinator.fulfillRandomWords(requestId, address(wamos));
        SpawnRequest memory request = wamos.getSpawnRequest(requestId);
        assertTrue(request.randomnessFulfilled);
        assertTrue(request.randomWord != 0);
        console.log("Random word: %s", request.randomWord);
    }

    function testRequestStoredTokenId() public {
        vm.prank(player1);
        uint256 requestId = wamos.requestSpawnWamo{value: MINT_PRICE}();
        vrfCoordinator.fulfillRandomWords(requestId, address(wamos));
        SpawnRequest memory request = wamos.getSpawnRequest(requestId);

        uint256 predictedTokenId = wamos.getTokenIdFromRequestId(requestId);
        assertTrue(predictedTokenId == request.tokenId);
    }

    function testActorOwnsCompletedSpawn() public {
        vm.prank(player1);
        uint256 requestId = wamos.requestSpawnWamo{value: MINT_PRICE}();
        vrfCoordinator.fulfillRandomWords(requestId, address(wamos));
        uint256 tokenId = wamos.getTokenIdFromRequestId(requestId);
        console.log("request id: %s", requestId);
        console.log("token id: %s", tokenId);
        console.log("token count: %s", wamos.tokenCount());
        // complete mint
        wamos.completeSpawnWamo(tokenId);
        // check ownership
        assertTrue(wamos.ownerOf(tokenId) == player1);
    }

    function testCompletedSpawnHasTraits() public {
        vm.prank(player1);
        uint256 requestId = wamos.requestSpawnWamo{value: MINT_PRICE}();
        vrfCoordinator.fulfillRandomWords(requestId, address(wamos));
        uint256 tokenId = wamos.getTokenIdFromRequestId(requestId);
        // complete mint
        wamos.completeSpawnWamo(tokenId);
        // check traits
        WamoTraits memory traits = wamos.getWamoTraits(tokenId);
        console.log(
            "randomness: %s",
            wamos.getSpawnRequest(requestId).randomWord
        );
        console.log("health %s", traits.health);
        console.log("attack %s", traits.meeleeAttack);
        console.log("fecundity: %s", traits.fecundity);
        assertTrue(traits.health != 0);
        assertTrue(traits.meeleeAttack != 0);
        assertTrue(traits.meeleeDefence != 0);
        assertTrue(traits.magicAttack != 0);
        assertTrue(traits.magicDefence != 0);
    }

    function testBuyerCanTransfer() public {
        vm.prank(player1);
        uint256 requestId = wamos.requestSpawnWamo{value: MINT_PRICE}();
        vrfCoordinator.fulfillRandomWords(requestId, address(wamos));
        uint256 tokenId = wamos.getTokenIdFromRequestId(requestId);
        // complete mint
        wamos.completeSpawnWamo(tokenId);
        vm.prank(player1);
        wamos.safeTransferFrom(player1, player2, tokenId);
        assertTrue(wamos.ownerOf(tokenId) == player2);
    }

    function testCannotSpawnForFree() public {
        assert(player2.balance == 0);
        vm.prank(player2);
        vm.expectRevert();
        uint256 requestId = wamos.requestSpawnWamo{value: 0}();
    }

    function testBuyerDoesntOwnUnfulfilledSpawn() public {
        vm.prank(player1);
        uint256 requestId = wamos.requestSpawnWamo{value: MINT_PRICE}();
        uint256 tokenId = wamos.getTokenIdFromRequestId(requestId);
        vm.expectRevert();
        // should revert due to openzep erc721 design
        assertTrue(wamos.ownerOf(tokenId) == address(0));
    }

    function testMultipleIncompleteSpawnsCanComplete(address[5] memory players)
        public
    {
        uint256 beforeReqCount = requestIds.length;
        for (uint256 i = 0; i < 5; i++) {
            vm.deal(players[i], 1 ether);
            vm.prank(players[i]);
            uint256 requestId = wamos.requestSpawnWamo{value: MINT_PRICE}();
            requestIds.push(requestId);
        }
        // no tokens completed yet
        assertTrue(wamos.tokenCount() == 5);
        assertTrue(wamos.getRequestCount() == 5);
    }

    function testWithdraw() public {
        uint256 numberSold = 10;
        uint256 requestId;
        for (uint256 i = 0; i < 10; i++) {
            vm.prank(player1);
            requestId = wamos.requestSpawnWamo{value: MINT_PRICE}();
        }
        console.log("this balance: %s", address(this).balance);
        // assertTrue(wamos.tokenCount() == numberSold);
        assertTrue(deployer.balance == 0);
        vm.prank(deployer);
        wamos.withdrawFunds();
        assertTrue(deployer.balance == numberSold * MINT_PRICE);
    }

    function testCannotWithdrawByBadActor() public {
        uint256 numberSold = 10;
        uint256 requestId;
        for (uint256 i = 0; i < 10; i++) {
            vm.prank(player1);
            requestId = wamos.requestSpawnWamo{value: MINT_PRICE}();
        }
        console.log("this balance: %s", address(this).balance);
        // assertTrue(wamos.tokenCount() == numberSold);
        assertTrue(deployer.balance == 0);
        vm.prank(player2);
        vm.expectRevert();
        wamos.withdrawFunds();
    }

    /** ABILITIES TESTS */

    function testAbilitiesExist() public {
        vm.startPrank(player1);
        uint256 requestId = wamos.requestSpawnWamo{value: MINT_PRICE}();
        vrfCoordinator.fulfillRandomWords(requestId, address(wamos));
        uint256 tokenId = wamos.getTokenIdFromRequestId(requestId);
        wamos.completeSpawnWamo(tokenId);
        assertTrue(wamos.ownerOf(0) == player1);
        Ability[] memory abilities = wamos.getWamoAbilities(tokenId);
        Ability memory a = abilities[0];
        console.log("Ability 1 of wam0 #0");
        console.log("meelee?", a.meeleeDamage);
        console.log("magic?", a.magicDamage);
        console.log("range?", a.rangeDamage);
        console.log("power ", a.power);
        console.log("accuracy ", a.accuracy);
        console.log("range ", a.range);
        console.log("cost ", a.cost);
    }

    /** LIBRARY FUNCTION TESTS */

    function testShaveOff() public {
        vm.prank(player1);
        uint256 requestId = wamos.requestSpawnWamo{value: MINT_PRICE}();
        vrfCoordinator.fulfillRandomWords(requestId, address(wamos));
        SpawnRequest memory request = wamos.getSpawnRequest(requestId);
        uint256 word = request.randomWord;
        console.log("Random word: %s", word);
        // shave
        {
            (uint256 a, uint256 b, uint256 c, uint256 d, uint256 e) = wamos
                .shaveOffRandomIntegers(word, 2, 0);
            console.log(a);
            console.log(b);
            console.log(c);
            console.log(d);
            console.log(e);
        }
        {
            (uint256 a, uint256 b, uint256 c, uint256 d, uint256 e) = wamos
                .shaveOffRandomIntegers(word, 2, 1);
            console.log(a);
            console.log(b);
            console.log(c);
            console.log(d);
            console.log(e);
        }
        {
            (uint256 a, uint256 b, uint256 c, uint256 d, uint256 e) = wamos
                .shaveOffRandomIntegers(word, 2, 2);
            console.log(a);
            console.log(b);
            console.log(c);
            console.log(d);
            console.log(e);
        }
        {
            (uint256 a, uint256 b, uint256 c, uint256 d, uint256 e) = wamos
                .shaveOffRandomIntegers(word, 2, 3);
            console.log(a);
            console.log(b);
            console.log(c);
            console.log(d);
            console.log(e);
        }
        {
            (uint256 a, uint256 b, uint256 c, uint256 d, uint256 e) = wamos
                .shaveOffRandomIntegers(word, 2, 4);
            console.log(a);
            console.log(b);
            console.log(c);
            console.log(d);
            console.log(e);
        }
        {
            (uint256 a, uint256 b, uint256 c, uint256 d, uint256 e) = wamos
                .shaveOffRandomIntegers(word, 2, 5);
            console.log(a);
            console.log(b);
            console.log(c);
            console.log(d);
            console.log(e);
        }
        {
            (uint256 a, uint256 b, uint256 c, uint256 d, uint256 e) = wamos
                .shaveOffRandomIntegers(word, 2, 6);
            console.log(a);
            console.log(b);
            console.log(c);
            console.log(d);
            console.log(e);
        }
    }
}
