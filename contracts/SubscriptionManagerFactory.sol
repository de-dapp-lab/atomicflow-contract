// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import {SubscriptionManager} from "./SubscriptionManager.sol";

contract SubscriptionManagerFactory is Ownable {
    event Created(bytes32 salt, address addr);

    /**
     * @dev receiver => manager contract
     */
    mapping(address => address) public contractOfReceiver;

    /**
     * @dev all created contracts
     */
    address[] public managerContracts;

    // sample code of create new contract using CREATE2
    function createSubscriptionManager(address _receiver, bytes32 _salt) public {
        SubscriptionManager _manager = new SubscriptionManager{salt: _salt}(
            _receiver
        );

        // transfer ownership from factory to creator
        _manager.transferOwnership(msg.sender);

        contractOfReceiver[_receiver] = address(_manager);
        managerContracts.push(address(_manager));

        emit Created(_salt, address(_manager));
    }

    /**
     * @dev get caller's manager contract
     */
    function getManagerContract() external view returns (address) {
        return contractOfReceiver[msg.sender];
    }

    /**
     * @dev get all manager contracts
     */
    function getAllManagerContracts() external view returns (address[] memory) {
        return managerContracts;
    }
}
