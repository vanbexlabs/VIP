pragma solidity ^0.4.9;

import "./legends_token.sol";


/**
 * @title LegendsCrowdfund
 */
contract LegendsCrowdfund {

    address public creator;
    address public exitAddress;

    uint public start;
    uint public limitVIP;

    LegendsToken public legendsToken;

    mapping (address => uint) public recipientETH;
    mapping (address => uint) public recipientVIP;

    uint public totalETH;
    uint public totalVIP;

    event VIPPurchase(address indexed sender, address indexed recipient, uint ETH, uint VIP);

    modifier saleActive() {
        if (address(legendsToken) == 0) {
            throw;
        }
        if (block.timestamp < start) {
            throw;
        }
        _;
    }

    modifier hasValue() {
        if (msg.value == 0) {
            throw;
        }
        _;
    }

    modifier recipientIsValid(address recipient) {
        if (recipient == 0 || recipient == address(this)) {
            throw;
        }
        _;
    }

    modifier isCreator() {
        if (msg.sender != creator) {
            throw;
        }
        _;
    }

    modifier tokenContractNotSet() {
        if (address(legendsToken) != 0) {
            throw;
        }
        _;
    }

    /**
     * @dev Constructor.
     * @param _exitAddress Address that all ETH should be forwarded to.
     * @param _start Timestamp of when the crowdsale will start.
     * @param _limitVIP Maximum amount of VIP that can be allocated in total. Denominated in wei.
     */
    function LegendsCrowdfund(address _exitAddress, uint _start, uint _limitVIP) {
        creator = msg.sender;
        exitAddress = _exitAddress;
        start = _start;
        limitVIP = _limitVIP;
    }

    /**
     * @dev Set the address of the token contract. Must be called by creator of this. Can only be set once.
     * @param _legendsToken Address of the token contract.
     */
    function setTokenContract(LegendsToken _legendsToken) external isCreator tokenContractNotSet {
        legendsToken = _legendsToken;
    }

    /**
     * @dev Forward Ether to the exit address. Store all ETH and VIP information in public state and logs.
     * @param recipient Address that tokens should be attributed to.
     */
    function purchaseMembership(address recipient) external payable saleActive hasValue recipientIsValid(recipient) {

        // Attempt to send the ETH to the exit address.
        if (!exitAddress.send(msg.value)) {
            throw;
        }

        // Update ETH amounts.
        recipientETH[recipient] += msg.value;
        totalETH += msg.value;

        // Calculate VIP amount.
        uint VIP = msg.value * 10;  // $1 / VIP based on $10 / ETH value.

        // Are we in the pre-sale?
        if (block.timestamp - start < 2 weeks) {
            VIP = (VIP * 10) / 9;   // 10% discount.
        }

        // Update VIP amounts.
        recipientVIP[recipient] += VIP;
        totalVIP += VIP;

        // Check we have not exceeded the maximum VIP.
        if (totalVIP > limitVIP) {
            throw;
        }

        // Tell the token contract about the increase.
        legendsToken.addTokens(recipient, VIP);

        // Log this purchase.
        VIPPurchase(msg.sender, recipient, msg.value, VIP);
    }

}
