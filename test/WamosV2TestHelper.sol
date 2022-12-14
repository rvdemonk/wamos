// SPDX-License-Identifier: UNLICENSED
pragma solidity <0.9.0;

import "../src/test/VRFCoordinatorV2Mock.sol";

abstract contract WamosV2TestHelper {
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
    uint256 SETUP_BATCH_SIZE = 6;

    // TEST PLAYERS
    address player1 = 0x316DBF75409134CBcb1b3e0f013ABbfcF63CA040;
    address player2 = 0x417622F534d5F30321CF78cB7355773f8BAC7621;
    address badActor = 0xA5cd5af52b504895c8525B5A5677859Fb04F8907;

    uint256 TEST_SEED =
        72984518589826227531578991903372844090998219903258077796093728159832249402700;
}
