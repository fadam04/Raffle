// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script, console} from "lib/forge-std/src/Script.sol";
import {Raffle} from "../src/Raffle.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";
import {CreateSubscription, FundSubscription, AddConsumer} from "script/Interaction.s.sol";

contract DeployRaffle is Script {
    function run() external returns (Raffle, HelperConfig) {
        HelperConfig helperconfig = new HelperConfig();
        AddConsumer addConsumer = new AddConsumer();
        HelperConfig.NetworkConfig memory config = helperconfig.getConfig();

        if (config.subscriptionId == 0) {
            CreateSubscription newsubscibtion = new CreateSubscription();
            (config.subscriptionId, config.vrfCoordinatorV2_5) =
                newsubscibtion.createSubscription(config.vrfCoordinatorV2_5, config.account);

            FundSubscription fundSubscription = new FundSubscription();
            fundSubscription.fundSubscription(
                config.vrfCoordinatorV2_5, config.subscriptionId, config.link, config.account
            );
            helperconfig.setConfig(block.chainid, config);
        }
        vm.startBroadcast(config.account);
        Raffle raffle = new Raffle(
            config.entranceFee,
            config.interval,
            config.vrfCoordinatorV2_5,
            config.gasLane,
            config.subscriptionId,
            uint32(config.callbackGasLimit)
        );
        vm.stopBroadcast();

        addConsumer.addConsumer(
            address(raffle), config.vrfCoordinatorV2_5, config.subscriptionId, config.account
        );
        return (raffle, helperconfig);
    }
}
