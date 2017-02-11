pragma solidity ^0.4.9;

import "./legends_token.sol";


/**
 * @title LegendsCrowdfund
 */
contract LegendsCrowdfund {
    
    uint public start;
    uint public membershipPrice;
    uint public membershipPriceReduced;

    mapping (address => uint) public recipientETH;
    mapping (address => uint) public recipientMemberships;

    uint public totalETH;
    uint public totalMemberships;
    uint public limitMemberships;

    address public exitAddress;
    address public creator;

    LegendsToken public legendsToken;

    event MembershipPurchase(address indexed sender, address indexed recipient, uint ETH);

    modifier saleActive() {
        if (address(legendsToken) == 0) {
            throw;
        }
        if (block.timestamp < start) {
            throw;
        }
        if (totalMemberships >= limitMemberships) {
            throw;
        }
        _;
    }

    modifier paymentIncluded() {
        uint price;
        if (block.timestamp - start < 14 days) {
            price = membershipPriceReduced;
        }
        else {
            price = membershipPrice;
        }
        if (msg.value < price) {
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
     * @param _start Timestamp of when the crowdsale will start.
     * @param _limitMemberships Maximum number of memberships that can be sold.
     * @param _exitAddress Address that all ETH should be forwarded to.
     */
    function LegendsCrowdfund(uint _start, uint _membershipPrice, uint _membershipPriceReduced, uint _limitMemberships, address _exitAddress) {
        creator = msg.sender;
        start = _start;
        membershipPrice = _membershipPrice;
        membershipPriceReduced = _membershipPriceReduced;
        limitMemberships = _limitMemberships;
        exitAddress = _exitAddress;
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
    function purchaseMembership(address recipient) external payable saleActive paymentIncluded recipientIsValid(recipient) {
        
        // Attempt to send the ETH to the exit address.
        if (!exitAddress.send(msg.value)) {
            throw;
        }
        
        // Update ETH amounts.
        recipientETH[recipient] += msg.value;
        totalETH += msg.value;

        // Update membership totals.
        recipientMemberships[recipient]++;
        totalMemberships++;

        // Tell the token contract about the increase.
        legendsToken.addTokens(recipient, 3000 ether);

        // Log this purchase.
        MembershipPurchase(msg.sender, recipient, msg.value);
    }

}
