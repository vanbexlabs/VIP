pragma solidity ^0.4.9;

import "dapple/test.sol";
import "./legends_crowdfund.sol";


/**
 * @title LegendsCrowdfundTest
 */
contract LegendsCrowdfundTest is Test {

    LegendsCrowdfund legendsCrowdfund;
    LegendsToken legendsToken;

    uint start;
    uint end;
    
    address exitAddress = 0x1234;
    address preallocation = 0x5678;

    address recipient1 = 0x1111;
    address recipient2 = 0x2222;

    function setUp() {
        start = block.timestamp;
        end = start + 5184000;
        legendsCrowdfund = new LegendsCrowdfund(exitAddress, start, 100 ether);
        legendsToken = new LegendsToken(legendsCrowdfund, preallocation, end, false);
        legendsCrowdfund.setTokenContract(legendsToken);
    }

    function testInitialState() {
        assertEq(legendsCrowdfund.creator(), this);
        assertEq(legendsCrowdfund.start(), start);
        assertEq(legendsCrowdfund.exitAddress(), exitAddress);
        assertEq(legendsCrowdfund.legendsToken(), legendsToken);

        assertEq(legendsToken.start(), start + 5184000);
        assertEq(legendsToken.legendsCrowdfund(), legendsCrowdfund);
    }

    function testThrowsSetTokenContractAgain() {
        legendsToken = new LegendsToken(legendsCrowdfund, preallocation, end, false);
        legendsCrowdfund.setTokenContract(legendsToken);
    }

    function testThrowsPurchaseVipLimit() {
        legendsCrowdfund.purchaseMembership.value(0.9 ether)(0x1234);
        legendsCrowdfund.purchaseMembership.value(0.9 ether)(0x1234);
        legendsCrowdfund.purchaseMembership.value(0.9 ether)(0x1234);
        legendsCrowdfund.purchaseMembership.value(0.9 ether)(0x1234);
        legendsCrowdfund.purchaseMembership.value(0.9 ether)(0x1234);
        legendsCrowdfund.purchaseMembership.value(0.9 ether)(0x1234);
        legendsCrowdfund.purchaseMembership.value(0.9 ether)(0x1234);
        legendsCrowdfund.purchaseMembership.value(0.9 ether)(0x1234);
        legendsCrowdfund.purchaseMembership.value(0.9 ether)(0x1234);
        legendsCrowdfund.purchaseMembership.value(0.9 ether)(0x1234);
        legendsCrowdfund.purchaseMembership.value(0.9 ether)(0x1234);
    }

    function testThrowPurchaseNoValue() {
        legendsCrowdfund.purchaseMembership(this);
    }

    function testThrowPurchaseRecipientIsZero() {
        legendsCrowdfund.purchaseMembership.value(0.9 ether)(0);
    }

    function testThrowPurchaseRecipientIsCrowdfund() {
        legendsCrowdfund.purchaseMembership.value(0.9 ether)(legendsCrowdfund);
    }

    function testPurchaseVip() {
        legendsCrowdfund.purchaseMembership.value(0.9 ether)(recipient1);
        assertEq(exitAddress.balance, 0.9 ether);
        assertEq(legendsCrowdfund.recipientETH(recipient1), 0.9 ether);
        assertEq(legendsCrowdfund.recipientETH(recipient2), 0);
        assertEq(legendsCrowdfund.totalETH(), 0.9 ether);
        assertEq(legendsToken.balanceOf(preallocation), 25000 ether);
        assertEq(legendsToken.balanceOf(recipient1), 10 ether);
        assertEq(legendsToken.balanceOf(recipient2), 0 ether);
        assertEq(legendsToken.totalSupply(), 25010 ether);

        legendsCrowdfund.purchaseMembership.value(0.9 ether)(recipient1);
        assertEq(exitAddress.balance, 1.8 ether);
        assertEq(legendsCrowdfund.recipientETH(recipient1), 1.8 ether);
        assertEq(legendsCrowdfund.recipientETH(recipient2), 0);
        assertEq(legendsCrowdfund.totalETH(), 1.8 ether);
        assertEq(legendsToken.balanceOf(preallocation), 25000 ether);
        assertEq(legendsToken.balanceOf(recipient1), 20 ether);
        assertEq(legendsToken.balanceOf(recipient2), 0 ether);
        assertEq(legendsToken.totalSupply(), 25020 ether);

        legendsCrowdfund.purchaseMembership.value(0.9 ether)(recipient2);
        assertEq(exitAddress.balance, 2.7 ether);
        assertEq(legendsCrowdfund.recipientETH(recipient1), 1.8 ether);
        assertEq(legendsCrowdfund.recipientETH(recipient2), 0.9 ether);
        assertEq(legendsCrowdfund.totalETH(), 2.7 ether);
        assertEq(legendsToken.balanceOf(preallocation), 25000 ether);
        assertEq(legendsToken.balanceOf(recipient1), 20 ether);
        assertEq(legendsToken.balanceOf(recipient2), 10 ether);
        assertEq(legendsToken.totalSupply(), 25030 ether);

        legendsCrowdfund.purchaseMembership.value(0.9 ether)(recipient2);
        assertEq(exitAddress.balance, 3.6 ether);
        assertEq(legendsCrowdfund.recipientETH(recipient1), 1.8 ether);
        assertEq(legendsCrowdfund.recipientETH(recipient2), 1.8 ether);
        assertEq(legendsCrowdfund.totalETH(), 3.6 ether);
        assertEq(legendsToken.balanceOf(preallocation), 25000 ether);
        assertEq(legendsToken.balanceOf(recipient1), 20 ether);
        assertEq(legendsToken.balanceOf(recipient2), 20 ether);
        assertEq(legendsToken.totalSupply(), 25040 ether);

        legendsCrowdfund.purchaseMembership.value(0.9 ether)(recipient2);
        assertEq(exitAddress.balance, 4.5 ether);
        assertEq(legendsCrowdfund.recipientETH(recipient1), 1.8 ether);
        assertEq(legendsCrowdfund.recipientETH(recipient2), 2.7 ether);
        assertEq(legendsCrowdfund.totalETH(), 4.5 ether);
        assertEq(legendsToken.balanceOf(preallocation), 25000 ether);
        assertEq(legendsToken.balanceOf(recipient1), 20 ether);
        assertEq(legendsToken.balanceOf(recipient2), 30 ether);
        assertEq(legendsToken.totalSupply(), 25050 ether);
    }

}

/**
 * @title LegendsCrowdfundOverTest
 */
contract LegendsCrowdfundNoTokenTest is Test {

    LegendsCrowdfund legendsCrowdfund;

    uint start;
    
    address exitAddress = 0x5678;

    address recipient1 = 0x1111;
    address recipient2 = 0x2222;

    function setUp() {
        start = block.timestamp;
        legendsCrowdfund = new LegendsCrowdfund(exitAddress, start, 100 ether);
    }

    function testInitialState() {
        assertEq(legendsCrowdfund.creator(), this);
        assertEq(legendsCrowdfund.start(), start);
        assertEq(legendsCrowdfund.exitAddress(), exitAddress);
    }

    function testThrowsNoToken() {
        legendsCrowdfund.purchaseMembership.value(0.9 ether)(recipient1);
    }

}

/**
 * @title LegendsCrowdfundOverTest
 */
contract LegendsCrowdfundNotStartedTest is Test {

    LegendsCrowdfund legendsCrowdfund;
    LegendsToken legendsToken;

    uint start;
    uint end;

    address exitAddress = 0x1234;
    address preallocation = 0x5678;

    address recipient1 = 0x1111;
    address recipient2 = 0x2222;

    function setUp() {
        start = block.timestamp + 200;
        end = start + 100;
        legendsCrowdfund = new LegendsCrowdfund(exitAddress, start, 100 ether);
        legendsToken = new LegendsToken(legendsCrowdfund, preallocation, end, false);
        legendsCrowdfund.setTokenContract(legendsToken);
    }

    function testInitialState() {
        assertEq(legendsCrowdfund.creator(), this);
        assertEq(legendsCrowdfund.start(), start);
        assertEq(legendsCrowdfund.exitAddress(), exitAddress);
        assertEq(legendsCrowdfund.legendsToken(), legendsToken);

        assertEq(legendsToken.start(), start + 100);
        assertEq(legendsToken.legendsCrowdfund(), legendsCrowdfund);
    }

    function testThrowsSaleNotStarted() {
        legendsCrowdfund.purchaseMembership.value(0.9 ether)(recipient1);
    }

}
