// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/GridGame3.sol";

contract GridGame3Test is Test {
    address achilles = 0x417622F534d5F30321CF78cB7355773f8BAC7621; //p1
    address hector = 0x316DBF75409134CBcb1b3e0f013ABbfcF63CA040; //p2
    address diomedes = 0xA5cd5af52b504895c8525B5A5677859Fb04F8907; //p3

    GridGame3 public gridGame;

    uint256 public gameId;

    int8 public LARGEST_COORD = 15;

    function setUp() public {
        gridGame = new GridGame3();
        gameId = gridGame.create(achilles, hector);
    }

    // test the gas cost of deploying contract
    function testDeployGas() public {
        GridGame3 newGridGameContract = new GridGame3();
    }

    function testGameInitGas() public {
        uint256 newGameId = gridGame.create(diomedes, hector);
    }

    // test game count function
    function testGameCount(
        uint256 gamesToGen,
        address[401] memory users,
        uint256 randomIndex
    ) public {
        vm.assume(gamesToGen < 200);
        vm.assume(randomIndex < 200);
        uint256 startingCount = gridGame.gameCount();
        for (uint256 i = 0; i < gamesToGen; i++) {
            gridGame.create(users[0 + i], users[1 + i]);
        }
        // test game count
        assertTrue(gridGame.gameCount() == startingCount + gamesToGen);
    }

    function testGameId(uint256 gamesToGen, uint256 randomIndex) public {
        vm.assume(gamesToGen < 1000);
        vm.assume(randomIndex < gamesToGen);
        uint256 startingCount = gridGame.gameCount();
        for (uint256 i = 0; i < gamesToGen; i++) {
            gridGame.create(achilles, hector);
        }

        (uint256 id, , , , ) = gridGame.games(randomIndex);

        console.log("Starting count: %s", startingCount);
        console.log("Games to gen: %s", gamesToGen);
        console.log("New game count: %s", gridGame.gameCount());
        console.log("Random index: %s", randomIndex);
        console.log("the id: %s", id);

        // check whether index matches id
        assertTrue(id == randomIndex);
    }

    function testInitGameStatus() public {}

    function testStart() public {}
}
