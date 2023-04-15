// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @notice This contract manages the status of whether the subscription is continued.
 * @dev owner = status manager (atomicflow operator)
 */
contract SubscriptionManager is Ownable {
    /**
    + @dev
    * planKey: keccak256(planName) e.g. keccak256("basic"), keccak256("pro")
    * tokenAddress: L2 token address
    * receiverWallet: L2 receiver wallet address
    */
    struct Plan {
        uint256 planKey;
        uint256 tokenAddress;
        uint256 receiverWallet;
        uint256 amountPerMonth;
        uint256 maxMember;
        uint256 planName;
    }

    /** @dev
     * planKey: keccak256(planName) e.g. keccak256("basic"), keccak256("pro")
     * payer: EVM payer address
     * payerWallet: L2 payer wallet
     * startTime: The time when subscription is started
     * status: normal / interrupted -> true / false
     * memberCount:  member of payer and they are able to use 3rd tool
     */
    struct Payment {
        uint256 planKey;
        address payer;
        uint256 payerWallet;
        uint256 startTime;
        bool status;
        uint256 memberCount;
    }

    /**
     * @dev PaymentKey is key to be used to search member etc.
     */
    struct PaymentKey {
        uint256 planKey;
        address payer;
    }

    /**
     * @dev PaymentKey is
     */
    PaymentKey[] public paymentKeys;

    // memo : payer => planKey => memberAddress => isExist?
    mapping(address => mapping(uint256 => mapping(address => bool)))
        public members;

    /**
     * @dev payment receiver (service provider)
     */
    address receiver;

    // TODO: Ownableではダメな可能性があるので別の権限の検討
    constructor(address _receiver) Ownable() {
        receiver = _receiver;
    }

    // payer => planKey => Payment
    mapping(address => mapping(uint256 => Payment)) public payments;

    // planKey => plan
    mapping(uint256 => Plan) public plans;

    // member => payer
    mapping(address => address) public memberToPayer;

    // planKeyのリスト
    uint256[] public planKeys;

    // dapp-lab（serverが持っている）が使うmethod
    // server側のpriv key（owner）を使ってstatusを更新する
    function saveStatus(
        address _payer,
        uint256 _planKey,
        bool _status
    ) external onlyOwner {
        // paymentsから_paymentIdを指定して、statusを_statusに変更する
        payments[_payer][_planKey].status = _status;
    }

    // 以下receiver（事業者側）が使うメソッド
    // receiverが新しいplanを作成する
    function createPlan(Plan calldata plan) external onlyReceiver {
        // plansに追加する
        plans[plan.planKey] = plan;
        planKeys.push(plan.planKey);
    }

    // 以下Payer（支払い側）が使うmethod
    // Payerが支払いを開始をするメソッド（支払い側が事業者側のbasic planを契約する）
    function startPayment(uint256 _planKey, uint256 _payerWallet) external {
        // paymentsを追加する

        // paymentsに入れたい値が元々あるかどうかを確認したい
        // payer addressが0の場合値が存在しないと表せるのでpayments[msg.sender][_planKey].payer == address(0)と比較する
        if (payments[msg.sender][_planKey].payer == address(0)) {
            payments[msg.sender][_planKey] = Payment(
                _planKey,
                msg.sender,
                _payerWallet,
                block.timestamp,
                true,
                0
            );
            paymentKeys.push(PaymentKey(_planKey, msg.sender));
            return;
        }

        if (!payments[msg.sender][_planKey].status) {
            payments[msg.sender][_planKey].status = true;
        }
        //payments[msg.sender][_planKey] = Payment({planKey: _planKey, payer: msg.sender, payerWallet: _payerWallet, startTime: block.timestamp, status: true});
    }

    // function stopPayment(int256 _planKey) external {
    // paymentsを削除する
    // payer = msg.sender

    // }

    //
    function addMembers(uint256 _planKey, address[] memory _users) external {
        // payerの当該のplanにuserを追加する
        for (uint i = 0; i < _users.length; i++) {
            // 重複がないことを確認する
            //if (payments[msg.sender][_planKey].members[_users[i]]) {
            if (members[msg.sender][_planKey][_users[i]]) {
                continue;
            }

            // 追加する
            //payments[msg.sender][_planKey].members[_users[i]] = true;
            members[msg.sender][_planKey][_users[i]] = true;
            payments[msg.sender][_planKey].memberCount++;
            memberToPayer[_users[i]] = msg.sender;
        }

        // maxMemberと比較して、人数制限を超えていないことを確認する
        if (
            payments[msg.sender][_planKey].memberCount >
            plans[_planKey].maxMember
        ) {
            revert("Over max member count of plan");
        }
    }

    function removeMembers(uint256 _planKey, address[] memory _users) external {
        // payerの当該のplanからuserを削除する
        for (uint i = 0; i < _users.length; i++) {
            if (!members[msg.sender][_planKey][_users[i]]) {
                continue;
            }

            members[msg.sender][_planKey][_users[i]] = false;
            payments[msg.sender][_planKey].memberCount--;
        }
    }

    // receiverのダッシュボードに使う、dapp-labが更新するときの設定を取得するのに使う
    function getAllPlans() external view returns (Plan[] memory) {
        Plan[] memory allPlans = new Plan[](planKeys.length);
        for (uint i = 0; i < planKeys.length; i++) {
            allPlans[i] = (plans[planKeys[i]]);
        }
        return allPlans;
    }

    // receiverのダッシュボードと、dapp-labが更新する対象を取るのに使う
    function getAllPayments() external view returns (Payment[] memory) {
        Payment[] memory allPayments = new Payment[](paymentKeys.length);
        for (uint i = 0; i < paymentKeys.length; i++) {
            allPayments[i] = payments[paymentKeys[i].payer][
                paymentKeys[i].planKey
            ];
        }
        return allPayments;
    }

    // SDK (Subscribable) で使う
    // member => payer, planId => payer add => paymentId,  payments[paymentId].status
    function getMemberStatus(
        uint256 _planKey,
        address _user
    ) external view returns (bool) {
        return
            payments[memberToPayer[_user]][_planKey].status &&
            members[memberToPayer[_user]][_planKey][_user];
    }

    function getPlan(uint256 _planKey) external view returns (Plan memory){
        return plans[_planKey];
    }

    modifier onlyReceiver() {
        require(msg.sender == receiver, "caller is not the reciever");
        _;
    }
}
