// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script, console} from "lib/forge-std/src/Script.sol";
import {HelperConfig, CodeConstants} from "./HelperConfig.s.sol";
import {Raffle} from "../src/Raffle.sol";
import {VRFCoordinatorV2PlusMock} from
    "lib/chainlink-brownie-contracts/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2PlusMock.sol";
import {LinkToken} from "test/mocks/LinkToken.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";

contract CreateSubscription is Script {
    function CreateSubscriptionUsingConfig() public returns (uint256, address) {
        HelperConfig helperConfig = new HelperConfig();

        address vrfCoordinatorV2_5 = helperConfig.getConfigByChainId(block.chainid).vrfCoordinatorV2_5;
        address account = helperConfig.getConfigByChainId(block.chainid).account;

        return createSubscription(vrfCoordinatorV2_5, account);
    }

    function createSubscription(address vrfCoordinatorV2_5, address account) public returns (uint256, address) {
        console.log("Creating subscription on chain Id: ", block.chainid);

        vm.startBroadcast(account);
        uint256 subId = VRFCoordinatorV2PlusMock(vrfCoordinatorV2_5).createSubscription();
        vm.stopBroadcast();

        console.log("Subscription created with id: ", subId);
        console.log("please update the subscription id in the HelperConfig contract");
        return (subId, vrfCoordinatorV2_5);
    }

    function run() external returns (uint256, address) {
        return CreateSubscriptionUsingConfig();
    }
}

contract AddConsumer is Script {
    function addConsumer(address contractToAddtoVrf, address vrfCoordantor, uint256 subId, address account) public {
        console.log("Adding consumer to contract", contractToAddtoVrf);
        console.log("Adding consumer to VRF Coordinator: ", vrfCoordantor);
        console.log("On Chain Id: ", block.chainid);
        console.log("owner of the contract: ", account);
        vm.startBroadcast(account);
        VRFCoordinatorV2PlusMock(vrfCoordantor).addConsumer(subId, contractToAddtoVrf);
        vm.stopBroadcast();
    }

    function AddConsumerUsingConfig(address mostRecentlyDeployed) public {
        HelperConfig helperConfig = new HelperConfig();
        uint256 subId = helperConfig.getConfig().subscriptionId;
        address vrfCoordinatorV2_5 = helperConfig.getConfig().vrfCoordinatorV2_5;
        address account = helperConfig.getConfig().account;

        addConsumer(mostRecentlyDeployed, vrfCoordinatorV2_5, subId, account);
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("Raffle", block.chainid);
        AddConsumerUsingConfig(mostRecentlyDeployed);
    }
}

contract FundSubscription is Script, CodeConstants {
    uint96 public constant FUND_AMOUNT = 3 ether; // 3 Link

    function FundSubscriptionUsingConfig() public {
        console.log("Funding subscription using config");
        HelperConfig helperConfig = new HelperConfig();
        uint256 subId = helperConfig.getConfig().subscriptionId;
        address vrfCoordinatorV2_5 = helperConfig.getConfig().vrfCoordinatorV2_5;
        uint256 subscriptionId = helperConfig.getConfig().subscriptionId;

        address linkToken = helperConfig.getConfig().link;
        address account = helperConfig.getConfig().account;

        if (subId == 0) {
            CreateSubscription createSub = new CreateSubscription();
            (uint256 updatedSubId, address updatedVRFv2) = createSub.run();
            subId = updatedSubId;
            vrfCoordinatorV2_5 = updatedVRFv2;
            console.log("New SubId Created! ", subId, "VRF Address: ", vrfCoordinatorV2_5);
        }

        fundSubscription(vrfCoordinatorV2_5, subscriptionId, linkToken, account);
    }

    function fundSubscription(address vrfCoordinatorV2_5, uint256 subscriptionId, address Linktoken, address account)
        public
    {
        console.log("Funding subscription on  Id: ", subscriptionId);
        console.log("Funding subscription on  vrfCoordinatorV2_5: ", vrfCoordinatorV2_5);
        console.log("Funding subscription on  Chain Id: ", block.chainid);
        if (block.chainid == LOCAL_CHAIN_ID) {
            vm.startBroadcast(account);
            VRFCoordinatorV2PlusMock(vrfCoordinatorV2_5).fundSubscription(subscriptionId, FUND_AMOUNT);
            vm.stopBroadcast();
            console.log("Subscription funded with amount: ", FUND_AMOUNT);
        } else {
            vm.startBroadcast(account);
            LinkToken(Linktoken).transferAndCall(vrfCoordinatorV2_5, FUND_AMOUNT, abi.encode(subscriptionId));
            vm.stopBroadcast();
        }
    }

    function run() external {
        FundSubscriptionUsingConfig();
    }
}
