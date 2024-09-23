// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {StateView} from "v4-periphery/src/lens/StateView.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";



contract DeployStateView is Script {
   function run() external returns (StateView) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

    IPoolManager manager = IPoolManager(vm.envAddress("POOL_MANAGER_ADDRESS"));

       StateView st =  new StateView(manager);

    vm.stopBroadcast();
    return st;
    }

}

