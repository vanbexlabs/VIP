pragma solidity ^0.4.9;

import "./erc20.sol";


/**
 * @title LegendsToken
 */
contract LegendsToken is ERC20 {

    mapping (address => uint) ownerVIP;
    mapping (address => mapping (address => uint)) allowed;
    uint public totalVIP;
    uint public start;
    
    address public legendsCrowdfund;

    bool public testing;

    modifier fromCrowdfund() {
        if (msg.sender != legendsCrowdfund) {
            throw;
        }
        _;
    }
    
    modifier isActive() {
        if (block.timestamp < start) {
            throw;
        }
        _;
    }

    modifier isNotActive() {
        if (!testing && block.timestamp >= start) {
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

    modifier senderHasSufficient(uint VIP) {
        if (ownerVIP[msg.sender] < VIP) {
            throw;
        }
        _;
    }

    modifier transferApproved(address from, uint VIP) {
        if (allowed[from][msg.sender] < VIP || ownerVIP[from] < VIP) {
            throw;
        }
        _;
    }

    modifier allowanceIsZero(address spender, uint value) {
        // To change the approve amount you first have to reduce the addresses´
        // allowance to zero by calling `approve(_spender,0)` if it is not
        // already 0 to mitigate the race condition described here:
        // https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        if ((value != 0) && (allowed[msg.sender][spender] != 0)) {
            throw;
        }
        _;
    }

    /**
     * @dev Tokens have been added to an address by the crowdfunding contract.
     * @param recipient Address receiving the VIP.
     * @param VIP Amount of VIP added.
     */
    event TokensAdded(address indexed recipient, uint VIP);

    /**
     * @dev Constructor.
     * @param _legendsCrowdfund Address of crowdfund contract.
     * @param _start Timestamp when the token becomes active.
     */
    function LegendsToken(address _legendsCrowdfund, uint _start, bool _testing) {
        legendsCrowdfund = _legendsCrowdfund;
        start = _start;
        testing = _testing;
    }
    
    /**
     * @dev Add to token balance on address. Must be from crowdfund.
     * @param recipient Address to add tokens to.
     * @return VIP Amount of VIP to add.
     */
    function addTokens(address recipient, uint VIP) external isNotActive fromCrowdfund {
        ownerVIP[recipient] += VIP;
        totalVIP += VIP;
        TokensAdded(recipient, VIP);
    }

    /**
     * @dev Implements ERC20 totalSupply()
     */
    function totalSupply() constant returns (uint256 totalSupply) {
        totalSupply = totalVIP;
    }

    /**
     * @dev Implements ERC20 balanceOf()
     */
    function balanceOf(address _owner) constant returns (uint256 balance) {
        balance = ownerVIP[_owner];
    }

    /**
     * @dev Implements ERC20 transfer()
     */
    function transfer(address _to, uint256 _value) isActive recipientIsValid(_to) senderHasSufficient(_value) returns (bool success) {
        ownerVIP[msg.sender] -= _value;
        ownerVIP[_to] += _value;
        Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
     * @dev Implements ERC20 transferFrom()
     */
    function transferFrom(address _from, address _to, uint256 _value) isActive recipientIsValid(_to) transferApproved(_from, _value) returns (bool success) {
        ownerVIP[_to] += _value;
        ownerVIP[_from] -= _value;
        allowed[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
        return true;
    }

    /**
     * @dev Implements ERC20 approve()
     */
    function approve(address _spender, uint256 _value) isActive allowanceIsZero(_spender, _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * @dev Implements ERC20 allowance()
     */
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        remaining = allowed[_owner][_spender];
    }

}

