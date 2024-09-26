// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {BaseHook} from "v4-periphery/src/base/hooks/BaseHook.sol";
import {Hooks} from "v4-core/libraries/Hooks.sol";
import {IPoolManager} from "v4-core/interfaces/IPoolManager.sol";
import {PoolKey} from "v4-core/types/PoolKey.sol";
import {StateLibrary} from "v4-core/libraries/StateLibrary.sol";
import {TickMath} from "v4-core/libraries/TickMath.sol";
import {BalanceDelta} from "v4-core/types/BalanceDelta.sol";

contract MarginHook is BaseHook {
    using StateLibrary for IPoolManager;
    

    // convert to transient storage later
    int24 currentTick;
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
                    beforeSwap: false,
                    afterSwap: true,
                    beforeDonate: false,
                    afterDonate: false,
                    beforeSwapReturnDelta: false,
                    afterSwapReturnDelta: false,
                    afterAddLiquidityReturnDelta: false,
                    afterRemoveLiquidityReturnDelta: false
                });
        }

        
 
        function afterSwap(
            address,
            PoolKey calldata key,
            IPoolManager.SwapParams calldata swapParams,
            BalanceDelta delta,
            bytes calldata hookData
        ) external override returns (bytes4, int128) {
            // Here we get the current tick price
                   (,currentTick, , ) = poolManager.getSlot0(key.toId());
            return (this.afterSwap.selector, 0);
        }

}




