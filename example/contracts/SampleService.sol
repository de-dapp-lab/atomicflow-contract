// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Subscribable} from "../../contracts/Subscribable.sol";

// Uncomment this line to use console.log
// import "hardhat/console.sol";

// Sample to use Subscribable contract
contract SampleService is Subscribable {
    uint256 constant PLAN_FOO = uint256(keccak256("Foo"));
    uint256 constant PLAN_BAR = uint256(keccak256("Bar"));

    event UseAwesomeFeatureForPlanFoo(address user);
    event UseAwesomeFeatureForPlanBar(address user);

    function forPlanFooMember() public onlySubscriber(PLAN_FOO) {
        emit UseAwesomeFeatureForPlanFoo(msg.sender);
    }

    function forPlanBarMember() public onlySubscriber(PLAN_BAR) {
        emit UseAwesomeFeatureForPlanBar(msg.sender);
    }
}
