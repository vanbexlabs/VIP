pragma solidity ^0.4.9;

import "dapple/test.sol";
import "./legends_token.sol";


contract LegendsTokenNotActiveNotFromCrowdfund is Test {

    LegendsToken legendsToken;

    uint start;

    address crowdfund = 0x5678;
    address preallocation = 0x5678;

    function setUp() {
        start = block.timestamp + 20000;
        legendsToken = new LegendsToken(crowdfund, preallocation, start, false);
    }

    function testInitialState() {
        assertEq(legendsToken.start(), start);
        assertEq(legendsToken.legendsCrowdfund(), crowdfund);
    }

    function testThrowsAddTokens() {
        legendsToken.addTokens(this, 1 ether);
    }

}


contract LegendsTokenNotActiveTest is Test {

    LegendsToken legendsToken;

    uint start;

    address preallocation = 0x5678;

    address recipient1 = 0x1111;
    address recipient2 = 0x2222;

    function setUp() {
        start = block.timestamp + 20000;
        legendsToken = new LegendsToken(this, preallocation, start, false);
    }

    function testInitialState() {
        assertEq(legendsToken.start(), start);
        assertEq(legendsToken.legendsCrowdfund(), this);
    }

    function testAddTokens() {
        legendsToken.addTokens(recipient1, 1 ether);
        assertEq(legendsToken.balanceOf(recipient1), 1 ether);
        assertEq(legendsToken.balanceOf(recipient2), 0);
        assertEq(legendsToken.totalSupply(), 25001 ether);

        legendsToken.addTokens(recipient2, 5 ether);
        assertEq(legendsToken.balanceOf(recipient1), 1 ether);
        assertEq(legendsToken.balanceOf(recipient2), 5 ether);
        assertEq(legendsToken.totalSupply(), 25006 ether);

        legendsToken.addTokens(recipient2, 3 ether);
        assertEq(legendsToken.balanceOf(recipient1), 1 ether);
        assertEq(legendsToken.balanceOf(recipient2), 8 ether);
        assertEq(legendsToken.totalSupply(), 25009 ether);
    }


    function testThrowsTransfer() {
        legendsToken.addTokens(this, 1 ether);
        legendsToken.transfer(recipient1, 0.2 ether);
    }

    function testThrowsApprove() {
        legendsToken.approve(recipient1, 4 ether);
    }

}


contract LegendsTokenActiveTest is Test {

    LegendsToken legendsToken;

    uint start;

    address preallocation = 0x5678;

    address recipient1 = 0x1111;
    address recipient2 = 0x2222;

    function setUp() {
        start = block.timestamp;
        legendsToken = new LegendsToken(this, preallocation, start, false);
    }

    function testInitialState() {
        assertEq(legendsToken.start(), start);
        assertEq(legendsToken.legendsCrowdfund(), this);
    }

    function testThrowsAddTokens() {
        legendsToken.addTokens(recipient1, 1 ether);
    }

}

contract LegendsTokenTestingModeTest is Test {

    LegendsToken legendsToken;

    uint start;

    address preallocation = 0x5678;

    address recipient1 = 0x1111;
    address recipient2 = 0x2222;

    function setUp() {
        start = block.timestamp;
        legendsToken = new LegendsToken(this, preallocation, start, true);
    }

    function testInitialState() {
        assertEq(legendsToken.start(), start);
        assertEq(legendsToken.legendsCrowdfund(), this);
    }

    function testTransfer() {
        legendsToken.addTokens(this, 1 ether);
        assertEq(legendsToken.balanceOf(this), 1 ether);
        assertEq(legendsToken.balanceOf(recipient1), 0);
        assertEq(legendsToken.totalSupply(), 25001 ether);

        legendsToken.transfer(recipient1, 0.2 ether);
        assertEq(legendsToken.balanceOf(this), 0.8 ether);
        assertEq(legendsToken.balanceOf(recipient1), 0.2 ether);
        assertEq(legendsToken.totalSupply(), 25001 ether);
    }

    function testThrowsTransferRecipientIsZero() {
        legendsToken.addTokens(this, 1 ether);
        legendsToken.transfer(0, 0.2 ether);
    }

    function testThrowsTransferRecipientIsTokenContract() {
        legendsToken.addTokens(this, 1 ether);
        legendsToken.transfer(legendsToken, 0.2 ether);
    }

    function testApprove() {
        legendsToken.approve(recipient1, 4 ether);
        assertEq(legendsToken.allowance(this, recipient1), 4 ether);
        assertEq(legendsToken.allowance(this, recipient2), 0 ether);
        legendsToken.approve(recipient2, 3 ether);
        assertEq(legendsToken.allowance(this, recipient1), 4 ether);
        assertEq(legendsToken.allowance(this, recipient2), 3 ether);
        legendsToken.approve(recipient1, 0 ether);
        assertEq(legendsToken.allowance(this, recipient1), 0 ether);
        assertEq(legendsToken.allowance(this, recipient2), 3 ether);
        legendsToken.approve(recipient1, 5 ether);
        assertEq(legendsToken.allowance(this, recipient1), 5 ether);
        assertEq(legendsToken.allowance(this, recipient2), 3 ether);
    }

    function testThrowsApproveAllowanceNotZero() {
        legendsToken.approve(recipient1, 4 ether);
        legendsToken.approve(recipient1, 5 ether);
    }

    function testTransferFrom() {
        legendsToken.addTokens(this, 1 ether);
        assertEq(legendsToken.balanceOf(this), 1 ether);
        assertEq(legendsToken.balanceOf(recipient1), 0);
        legendsToken.approve(this, 1 ether);
        assertEq(legendsToken.allowance(this, this), 1 ether);
        legendsToken.transferFrom(this, recipient1, 1 ether);
        assertEq(legendsToken.balanceOf(this), 0);
        assertEq(legendsToken.balanceOf(recipient1), 1 ether);
        assertEq(legendsToken.allowance(this, this), 0 ether);
    }

    function testThrowsTransferFromRecipientIsZero() {
        legendsToken.addTokens(this, 1 ether);
        legendsToken.approve(this, 1 ether);
        legendsToken.transferFrom(this, 0, 1 ether);
    }

    function testThrowsTransferFromRecipientIsTokenContract() {
        legendsToken.addTokens(this, 1 ether);
        legendsToken.approve(this, 1 ether);
        legendsToken.transferFrom(this, legendsToken, 1 ether);
    }

    function testThrowsTransferFromNotEnough() {
        legendsToken.addTokens(this, 1 ether);
        legendsToken.approve(this, 2 ether);
        legendsToken.transferFrom(this, recipient1, 2 ether);
    }

    function testThrowsTransferFromNotEnoughApproved() {
        legendsToken.addTokens(this, 2 ether);
        legendsToken.approve(this, 1 ether);
        legendsToken.transferFrom(this, recipient1, 2 ether);
    }

}
