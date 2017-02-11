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
    
    address exitAddress = 0x5678;

    address recipient1 = 0x1111;
    address recipient2 = 0x2222;

    function setUp() {
        start = block.timestamp;
        end = start + 5184000;
        legendsCrowdfund = new LegendsCrowdfund(start, 1 ether, 0.9 ether, 6, exitAddress);
        legendsToken = new LegendsToken(legendsCrowdfund, end, false);
        legendsCrowdfund.setTokenContract(legendsToken);
    }

    function testInitialState() {
        assertEq(legendsCrowdfund.creator(), this);
        assertEq(legendsCrowdfund.start(), start);
        assertEq(legendsCrowdfund.membershipPrice(), 1 ether);
        assertEq(legendsCrowdfund.membershipPriceReduced(), 0.9 ether);
        assertEq(legendsCrowdfund.start(), start);
        assertEq(legendsCrowdfund.limitMemberships(), 6);
        assertEq(legendsCrowdfund.exitAddress(), exitAddress);
        assertEq(legendsCrowdfund.legendsToken(), legendsToken);

        assertEq(legendsToken.start(), start + 5184000);
        assertEq(legendsToken.legendsCrowdfund(), legendsCrowdfund);
    }

    function testThrowsSetTokenContractAgain() {
        LegendsToken legendsToken = new LegendsToken(legendsCrowdfund, end, false);
        legendsCrowdfund.setTokenContract(legendsToken);
    }

    function testThrowsPurchaseMembershipsLimit() {
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

    function testThrowPurchaseNotEnoughEther() {
        legendsCrowdfund.purchaseMembership.value(0.5 ether)(this);
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
        assertEq(legendsCrowdfund.recipientMemberships(recipient1), 1);
        assertEq(legendsCrowdfund.recipientETH(recipient2), 0);
        assertEq(legendsCrowdfund.recipientMemberships(recipient2), 0);
        assertEq(legendsCrowdfund.totalETH(), 0.9 ether);
        assertEq(legendsCrowdfund.totalMemberships(), 1);
        assertEq(legendsToken.balanceOf(recipient1), 3000 ether);
        assertEq(legendsToken.balanceOf(recipient2), 0 ether);
        assertEq(legendsToken.totalSupply(), 3000 ether);

        legendsCrowdfund.purchaseMembership.value(0.9 ether)(recipient1);
        assertEq(exitAddress.balance, 1.8 ether);
        assertEq(legendsCrowdfund.recipientETH(recipient1), 1.8 ether);
        assertEq(legendsCrowdfund.recipientMemberships(recipient1), 2);
        assertEq(legendsCrowdfund.recipientETH(recipient2), 0);
        assertEq(legendsCrowdfund.recipientMemberships(recipient2), 0);
        assertEq(legendsCrowdfund.totalETH(), 1.8 ether);
        assertEq(legendsCrowdfund.totalMemberships(), 2);
        assertEq(legendsToken.balanceOf(recipient1), 6000 ether);
        assertEq(legendsToken.balanceOf(recipient2), 0 ether);
        assertEq(legendsToken.totalSupply(), 6000 ether);

        legendsCrowdfund.purchaseMembership.value(0.9 ether)(recipient2);
        assertEq(exitAddress.balance, 2.7 ether);
        assertEq(legendsCrowdfund.recipientETH(recipient1), 1.8 ether);
        assertEq(legendsCrowdfund.recipientMemberships(recipient1), 2);
        assertEq(legendsCrowdfund.recipientETH(recipient2), 0.9 ether);
        assertEq(legendsCrowdfund.recipientMemberships(recipient2), 1);
        assertEq(legendsCrowdfund.totalETH(), 2.7 ether);
        assertEq(legendsCrowdfund.totalMemberships(), 3);
        assertEq(legendsToken.balanceOf(recipient1), 6000 ether);
        assertEq(legendsToken.balanceOf(recipient2), 3000 ether);
        assertEq(legendsToken.totalSupply(), 9000 ether);

        legendsCrowdfund.purchaseMembership.value(0.9 ether)(recipient2);
        assertEq(exitAddress.balance, 3.6 ether);
        assertEq(legendsCrowdfund.recipientETH(recipient1), 1.8 ether);
        assertEq(legendsCrowdfund.recipientMemberships(recipient1), 2);
        assertEq(legendsCrowdfund.recipientETH(recipient2), 1.8 ether);
        assertEq(legendsCrowdfund.recipientMemberships(recipient2), 2);
        assertEq(legendsCrowdfund.totalETH(), 3.6 ether);
        assertEq(legendsCrowdfund.totalMemberships(), 4);
        assertEq(legendsToken.balanceOf(recipient1), 6000 ether);
        assertEq(legendsToken.balanceOf(recipient2), 6000 ether);
        assertEq(legendsToken.totalSupply(), 12000 ether);

        legendsCrowdfund.purchaseMembership.value(0.9 ether)(recipient2);
        assertEq(exitAddress.balance, 4.5 ether);
        assertEq(legendsCrowdfund.recipientETH(recipient1), 1.8 ether);
        assertEq(legendsCrowdfund.recipientMemberships(recipient1), 2);
        assertEq(legendsCrowdfund.recipientETH(recipient2), 2.7 ether);
        assertEq(legendsCrowdfund.recipientMemberships(recipient2), 3);
        assertEq(legendsCrowdfund.totalETH(), 4.5 ether);
        assertEq(legendsCrowdfund.totalMemberships(), 5);
        assertEq(legendsToken.balanceOf(recipient1), 6000 ether);
        assertEq(legendsToken.balanceOf(recipient2), 9000 ether);
        assertEq(legendsToken.totalSupply(), 15000 ether);
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
        legendsCrowdfund = new LegendsCrowdfund(start, 1 ether, 0.9 ether, 10, exitAddress);
    }

    function testInitialState() {
        assertEq(legendsCrowdfund.creator(), this);
        assertEq(legendsCrowdfund.start(), start);
        assertEq(legendsCrowdfund.membershipPrice(), 1 ether);
        assertEq(legendsCrowdfund.membershipPriceReduced(), 0.9 ether);
        assertEq(legendsCrowdfund.limitMemberships(), 10);
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

    address exitAddress = 0x5678;

    address recipient1 = 0x1111;
    address recipient2 = 0x2222;

    function setUp() {
        start = block.timestamp + 200;
        end = start + 100;
        legendsCrowdfund = new LegendsCrowdfund(start, 1 ether, 0.9 ether, 10, exitAddress);
        legendsToken = new LegendsToken(legendsCrowdfund, end, false);
        legendsCrowdfund.setTokenContract(legendsToken);
    }

    function testInitialState() {
        assertEq(legendsCrowdfund.creator(), this);
        assertEq(legendsCrowdfund.start(), start);
        assertEq(legendsCrowdfund.membershipPrice(), 1 ether);
        assertEq(legendsCrowdfund.membershipPriceReduced(), 0.9 ether);
        assertEq(legendsCrowdfund.limitMemberships(), 10);
        assertEq(legendsCrowdfund.exitAddress(), exitAddress);
        assertEq(legendsCrowdfund.legendsToken(), legendsToken);

        assertEq(legendsToken.start(), start + 100);
        assertEq(legendsToken.legendsCrowdfund(), legendsCrowdfund);
    }

    function testThrowsSaleIsOver() {
        legendsCrowdfund.purchaseMembership.value(0.9 ether)(recipient1);
    }

}
