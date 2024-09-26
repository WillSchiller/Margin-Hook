// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {Deployers} from "@uniswap/v4-core/test/utils/Deployers.sol";
import {MockERC20} from "solmate/src/test/utils/mocks/MockERC20.sol";
import {PoolManager} from "v4-core/PoolManager.sol";
import {IPoolManager} from "v4-core/interfaces/IPoolManager.sol";
import {Currency, CurrencyLibrary} from "v4-core/types/Currency.sol";
import {PoolId, PoolIdLibrary} from "v4-core/types/PoolId.sol";
import {LPFeeLibrary} from "v4-core/libraries/LPFeeLibrary.sol";
import {PoolKey} from "v4-core/types/PoolKey.sol";
import {Hooks} from "v4-core/libraries/Hooks.sol";
import {PoolSwapTest} from "v4-core/test/PoolSwapTest.sol";
import {TickMath} from "v4-core/libraries/TickMath.sol";
import {console} from "forge-std/console.sol";

import {MarginHook} from "../src/MarginHook.sol";

contract TestMarginHook is Test, Deployers {
    using CurrencyLibrary for Currency;
    using PoolIdLibrary for PoolKey;

    MarginHook hook;

    function setUp() public {
        // Deploy v4-core
        deployFreshManagerAndRouters();

        // Deploy, mint tokens, and approve all periphery contracts for two tokens
        deployMintAndApprove2Currencies();

        // Deploy our hook with the proper flags
        address hookAddress = address(
            uint160(
                    Hooks.AFTER_SWAP_FLAG            
            )
        );

        // Set gas price = 10 gwei and deploy our hook
        //vm.txGasPrice(10 gwei);
        deployCodeTo("MarginHook", abi.encode(manager), hookAddress);
        hook = MarginHook(hookAddress);

                // Initialize a pool
        (key, ) = initPool(
            currency0,
            currency1,
            hook,
            3000, 
            SQRT_PRICE_1_1,
            ZERO_BYTES
        );

        // Add some liquidity
        modifyLiquidityRouter.modifyLiquidity(
            key,
            IPoolManager.ModifyLiquidityParams({
                tickLower: -60,
                tickUpper: 60,
                liquidityDelta: 100 ether,
                salt: bytes32(0)
            }),
            ZERO_BYTES
        );
    }

    function testBeforeSwap() public {
        // Swap 1 token0 for token1
        bool zeroForOne =  true;
        int256 amountSpecified = 1 ether;

        int256 leverageAmount = 5;
        bool leverage = true;
        bytes memory hookData = abi.encode(leverageAmount,leverage);


        // Call beforeSwap
        Deployers.swap(key, zeroForOne, amountSpecified, hookData);
    }


}