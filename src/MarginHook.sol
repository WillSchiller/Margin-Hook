// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {BaseHook} from "v4-periphery/src/base/hooks/BaseHook.sol";
import {Hooks} from "v4-core/libraries/Hooks.sol";
import {IPoolManager} from "v4-core/interfaces/IPoolManager.sol";
import {PoolKey} from "v4-core/types/PoolKey.sol";
import {StateLibrary} from "v4-core/libraries/StateLibrary.sol";
import {TickMath} from "v4-core/libraries/TickMath.sol";


import {BeforeSwapDelta, toBeforeSwapDelta} from "v4-core/types/BeforeSwapDelta.sol";
import {BalanceDeltaLibrary, BalanceDelta} from "v4-core/types/BalanceDelta.sol";

contract MarginHook is BaseHook {
    using StateLibrary for IPoolManager;

    // convert to transient storage later
    bool disableLeverage; 
    uint256 currentTickPrice;

    error leverageNotInRange();

    constructor(IPoolManager _poolManager) BaseHook(_poolManager) {}

    function getHookPermissions()
            public
            pure
            override
            returns (Hooks.Permissions memory)
        {
            return
                Hooks.Permissions({
                    beforeInitialize: false,
                    afterInitialize: false,
                    beforeAddLiquidity: false,
                    beforeRemoveLiquidity: false,
                    afterAddLiquidity: false,
                    afterRemoveLiquidity: false,
                    beforeSwap: true,
                    afterSwap: true,
                    beforeDonate: false,
                    afterDonate: false,
                    beforeSwapReturnDelta: true,
                    afterSwapReturnDelta: true,
                    afterAddLiquidityReturnDelta: false,
                    afterRemoveLiquidityReturnDelta: false
                });
        }

        function beforeSwap(
            address,
            PoolKey calldata key,
            IPoolManager.SwapParams calldata swapParams,
            bytes calldata hookData
        ) external override returns (bytes4, BeforeSwapDelta, uint24) {
            (int256 leverageAmount, bool leverage) = abi.decode(hookData, (int, bool));
            if(!(leverageAmount >= 1 && leverageAmount <= 5)) {revert leverageNotInRange();}
            if(leverageAmount != 1 && leverage == true) {
                // current tick price
                (, int24 currentTick, , ) = poolManager.getSlot0(key.toId());
                // get real price
                uint160 sqrtPriceX96 = TickMath.getSqrtPriceAtTick(currentTick);
                uint256 price = uint256(sqrtPriceX96) ** 2 / (2 ** 192);

                uint256 loanAmount = leverageAmount -1; 
                uint256 swapAmount;
                // Will likely be all sorts of rounding errors here: Not for production
                //Borrow Token0
                if(swapParams.zeroForOne == true) {
                    if(swapParams.exactInputForOutput == true) {
                        swapAmount = SwapParams.amountSpecified * loanAmount;
                    } else {
                        swapAmount = (price / SwapParams.amountSpecified) * loanAmount;
                    }
                } else {
                //Borrow Token1
                    if(swapParams.exactInputForOutput == true) {
                        swapAmount = SwapParams.amountSpecified * loanAmount;
                    } else {
                        (price / SwapParams.amountSpecified) * loanAmount;
                    }
                    swapAmount = SwapParams.amountSpecified * loanAmount
            
                            //SwapParams.amountSpecified
                
                /*
                                 Token0                Token1
                                    |                     getSlot0|
                                    |                     |
                                    v                     v
                    +----------------+---------------------+
                    |                |                     |
                    |  1 zeroToOne   |   exactInputForOutput
                    |                | ------------------>
                    |                |                     |
                    |  2 zeroToOne   |   exactOutputForInput
                    |                | ------------------>
                    |                |                     |
                    |  3 oneToZero   |   exactInputForOutput
                    |                | <------------------
                    |                |                     |
                    |  4 oneToZero   |   exactOutputForInput
                    |                | <------------------
                    |                |                     |
                    +----------------+---------------------+

                Borrow 0
                1. SwapParams.amountSpecified * (leverageAmount)
                2. (price / SwapParams.amountSpecified) * leverageAmount
                Borrow 1
                3. SwapParams.amountSpecified * leverageAmount
                4. (price / SwapParams.amountSpecified) * leverageAmount

                



                For 5X leverage
                I have USD 10 USD which will be swapped
                Take swap amount (10) X 4 = 40
                Buy 40 worth of ether (leverage false)
                Keep the Ether in Hook
                Update position
                */

            }
            disableLeverage = true;


            



            BeforeSwapDelta beforeSwapDelta = toBeforeSwapDelta(0, 0);
            return (this.beforeSwap.selector, beforeSwapDelta, 0);
        }
 
        function afterSwap(
            address,
            PoolKey calldata key,
            IPoolManager.SwapParams calldata swapParams,
            BalanceDelta delta,
            bytes calldata hookData
        ) external override returns (bytes4, int128) {
            /*
            Normal swap for 10USD happened but keep the claim tokens

            */
            return (this.afterSwap.selector, 0);
        }

    




} 

