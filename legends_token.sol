pragma solidity ^0.4.9;

import "./erc20.sol";


/**
 * @title LegendsToken
 */
contract LegendsToken is ERC20 {
    string public name = 'VIP';             //The Token's name: e.g. DigixDAO Tokens
    uint8 public decimals = 18;             // 1Token ¨= 1$ (1ETH ¨= 10$)
    string public symbol = 'VIP';           //An identifier: e.g. REP
    string public version = 'VIP_0.1';

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
     * @param _preallocation Address to receive the pre-allocation.
     * @param _start Timestamp when the token becomes active.
     */
    function LegendsToken(address _legendsCrowdfund, address _preallocation, uint _start, bool _testing) {
        legendsCrowdfund = _legendsCrowdfund;
        start = _start;
        testing = _testing;
        totalVIP = ownerVIP[_preallocation] = 25000 ether;
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
    function transfer(address _to, uint256 _value) isActive recipientIsValid(_to) returns (bool success) {
        if (ownerVIP[msg.sender] >= _value) {
            ownerVIP[msg.sender] -= _value;
            ownerVIP[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Implements ERC20 transferFrom()
     */
    function transferFrom(address _from, address _to, uint256 _value) isActive recipientIsValid(_to) returns (bool success) {
        if (allowed[_from][msg.sender] >= _value && ownerVIP[_from] >= _value) {
            ownerVIP[_to] += _value;
            ownerVIP[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            Transfer(_from, _to, _value);
            return true;
        } else {
            return false;
        }
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
