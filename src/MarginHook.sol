// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0; //

import {BaseHook} from "v4-periphery/src/base/hooks/BaseHook.sol";
import {IPoolManager} from "v4-core/interfaces/IPoolManager.sol";
import {Hooks} from "v4-core/libraries/Hooks.sol";

contract MarginHook is BaseHook {

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

    constructor(IPoolManager _poolManager) BaseHook(_poolManager) {}


} 

