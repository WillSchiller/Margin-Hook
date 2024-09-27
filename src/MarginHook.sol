// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {BaseHook} from "v4-periphery/src/base/hooks/BaseHook.sol";
import {Hooks} from "v4-core/libraries/Hooks.sol";
import {IPoolManager} from "v4-core/interfaces/IPoolManager.sol";
import {PoolKey} from "v4-core/types/PoolKey.sol";
import {StateLibrary} from "v4-core/libraries/StateLibrary.sol";
import {TickMath} from "v4-core/libraries/TickMath.sol";
import {BalanceDelta} from "v4-core/types/BalanceDelta.sol";
import {PoolId, PoolIdLibrary} from "@uniswap/v4-core/src/types/PoolId.sol";
import {IUnlockCallback} from "@uniswap/v4-core/src/interfaces/callback/IUnlockCallback.sol";
import {FullMath} from "@uniswap/v4-core/src/libraries/FullMath.sol";
import {Currency, CurrencyLibrary} from "v4-core/types/Currency.sol";
import {CurrencySettler} from "@uniswap/v4-core/test/utils/CurrencySettler.sol";

contract MarginHook is BaseHook {
    using StateLibrary for IPoolManager;
    using PoolIdLibrary for PoolKey;
    using CurrencyLibrary for Currency;
    using CurrencySettler for Currency;

    error leverageNotInRange();
    error PoolNotInitialized();

     bytes internal constant ZERO_BYTES = bytes("");

    constructor(IPoolManager _poolManager) BaseHook(_poolManager) {}

    struct CallbackData {
        address sender;
        PoolKey key;
        IPoolManager.ModifyLiquidityParams params;
    }

    struct PoolInfo {
        bool hasAccruedFees;
        address liquidityToken;
    }

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
        // Get the current tick price
        (, int24 currentTick, , ) = poolManager.getSlot0(key.toId());
        // Check for liquidatable positions
        return (this.afterSwap.selector, 0);
    }

    function checkForLiquidations()
        internal
        view
        returns (bool liquidationReward, uint256 amount)
    {
        //TODO: Implement this function
        return (true, 0);
    }

    function modifyHookLiquidity(
        PoolKey calldata key,
        int256 amount
    ) external returns (uint128 liquidity) {
        
        PoolId poolId = key.toId();
        (uint160 sqrtPriceX96, int24 tick, , ) = poolManager.getSlot0(poolId);
        if (sqrtPriceX96 == 0) revert PoolNotInitialized();

        BalanceDelta addedDelta = modifyLiquidity(
            key,
            IPoolManager.ModifyLiquidityParams({
                tickLower: tick - 60,
                tickUpper: tick + 60,
                liquidityDelta: amount,
                salt: 0
            })
        );
    }

    function modifyLiquidity(
        PoolKey memory key,
        IPoolManager.ModifyLiquidityParams memory params
    ) internal returns (BalanceDelta delta) {
        delta = abi.decode(
            poolManager.unlock(
                abi.encode(CallbackData(msg.sender, key, params))
            ),
            (BalanceDelta)
        );
    }

        function _unlockCallback(bytes calldata rawData)
        internal
        override
        returns (bytes memory)
    {
        CallbackData memory data = abi.decode(rawData, (CallbackData));
        BalanceDelta delta;

        if (data.params.liquidityDelta < 0) {
            _takeDeltas(data.sender, data.key, delta);
        } else {
            (delta,) = poolManager.modifyLiquidity(data.key, data.params, ZERO_BYTES);
            _settleDeltas(data.sender, data.key, delta);
        }
        return abi.encode(delta);
    }

     function _settleDeltas(address sender, PoolKey memory key, BalanceDelta delta) internal {
        key.currency0.settle(poolManager, sender, uint256(int256(-delta.amount0())), false);
        key.currency1.settle(poolManager, sender, uint256(int256(-delta.amount1())), false);
    }

    function _takeDeltas(address sender, PoolKey memory key, BalanceDelta delta) internal {
        poolManager.take(key.currency0, sender, uint256(uint128(delta.amount0())));
        poolManager.take(key.currency1, sender, uint256(uint128(delta.amount1())));
    }


}
