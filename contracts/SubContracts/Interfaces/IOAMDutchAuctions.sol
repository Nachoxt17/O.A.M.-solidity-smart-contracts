// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.4;

interface IOAMDutchAuctions {
    //+-Dutch Auction Events:_
    event DutchAuctionEnded(address winner, uint256 amount);
    event DutchAuctionAllowed(address _nftAddress, bool allows);
}
