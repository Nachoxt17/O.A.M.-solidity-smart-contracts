// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.4;

interface IOAMEnglishAuctions {
    //+-English Auction Events:_
    event HighestBidIncrease(address bidder, uint256 amount);
    event EnglishAuctionEnded(address winner, uint256 amount);
    event EnglishAuctionAllowed(address _nftAddress, bool allows);
}
