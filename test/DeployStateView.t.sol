// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";

import {DeployStateView} from "../script/StateView.s.sol";
import {PoolId, PoolIdLibrary} from "v4-core/types/PoolId.sol";
import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {IHooks} from "@uniswap/v4-core/src/interfaces/IHooks.sol";
import {StateView} from "v4-periphery/src/lens/StateView.sol";
import {CurrencyLibrary, Currency} from "@uniswap/v4-core/src/types/Currency.sol";
import {console} from "forge-std/console.sol";



contract TestStateView is Test {
    using PoolIdLibrary for PoolId;
    PoolId poolId;
    PoolKey key;
    StateView viewer;

    function test_state_view() public {
        DeployStateView script = new DeployStateView();
        viewer = script.run();
        Currency c0 = Currency.wrap(address(0x0000000000000000000000002080de78a378c3b66e643d38e7b0fc57847be885));
        Currency c1 = Currency.wrap(address(0x000000000000000000000000637f693ee32764e6a4fc7720b6a0afd6053b65ec));

        key = PoolKey(c0, c1, 500, 60, IHooks(address(0x0)));
        poolId = key.toId();
        PoolId poolId = PoolId.wrap(bytes32(0x95cc61d763328578ace66d57080d139898ef2c8f69e67da8407bb9acf606c8ca));
        (   uint160 sqrtPriceX96,
            int24 tick,
            uint24 protocolFee,
            uint24 lpFee 
        ) = viewer.getSlot0(poolId);
        console.log("sqrtPriceX96: ", sqrtPriceX96);
        console.log("tick: ", tick);
        console.log("protocolFee: ", protocolFee);
        console.log("lpFee: ", lpFee);
    }
}