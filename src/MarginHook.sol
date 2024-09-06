// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {BaseHook} from "v4-periphery/src/base/hooks/BaseHook.sol";
import {Hooks} from "v4-core/libraries/Hooks.sol";
import {IPoolManager} from "v4-core/interfaces/IPoolManager.sol";
import {PoolKey} from "v4-core/types/PoolKey.sol";


import {BeforeSwapDelta, toBeforeSwapDelta} from "v4-core/types/BeforeSwapDelta.sol";
import {BalanceDeltaLibrary, BalanceDelta} from "v4-core/types/BalanceDelta.sol";

contract MarginHook is BaseHook {

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
            // We'll add more code here shortly
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
            // We'll add more code here shortly
            return (this.afterSwap.selector, 0);
        }

    




} 

