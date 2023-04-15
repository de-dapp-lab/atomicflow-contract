// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Context} from "@openzeppelin/contracts/utils/Context.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {SubscriptionManager} from "./SubscriptionManager.sol";

/**
 * @dev Contract module which provide subscription feature
 * that cooperates with a status contract.
 *
 * This module is used by inheritance.
 * And, to provide service based on the user's subscription status in your contract,
 * bind the status contract with bindStatusManager().
 *
 * This make available  the modifier `onlySubscriber(planKey)`.
 * It restricts the function to use only if the user is a member of valid subscription for the plan.
 */
contract Subscribable is Context, Ownable {
    /**
     * @dev The contract to manage subscription statuses
     */
    SubscriptionManager private manager;

    /**
     * @dev Bind manager contract.
     * Owner can change status contract, to change payment model.
     * If you stop the all subscription service, pass zero-address to remove status contract.
     */
    function bindSubscriptionManager(address _managerContract) external onlyOwner {
        manager = SubscriptionManager(_managerContract);
    }

    /**
     * @dev restrict user to a valid subscription member
     *
     * @param _planKey keccak256(planName)
     */
    modifier onlySubscriber(uint256 _planKey) {
        _checkStatusManager();
        _checkSubscriber(_planKey);
        _;
    }

    /**
     * @dev Throws if the status contract is not bound;
     */
    function _checkStatusManager() internal view virtual {
        require(address(manager) != address(0), "Status contract is not bound");
    }

    /**
     * @dev Throws if the sender is not a valid subscription member
     */
    function _checkSubscriber(uint256 _planKey) internal view virtual {
        require(
            manager.getMemberStatus(_planKey, _msgSender()) == true,
            "Sender is not member of any valid payment"
        );
    }
}
