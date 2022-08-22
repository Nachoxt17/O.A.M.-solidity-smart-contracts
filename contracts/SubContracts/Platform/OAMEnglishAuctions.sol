// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.4;

import "../../Libraries/Utils/Ownable.sol";
import "../../Libraries/Utils/Strings.sol";
import "../../Libraries/Utils/Counters.sol";
import "../../Libraries/Interfaces/IERC721.sol";
import "../../Libraries/Interfaces/IERC20.sol";
import "../../Libraries/Utils/ReentrancyGuard.sol";
import "../Interfaces/IOAMEnglishAuctions.sol";
import "../Interfaces/IOAMUsersVerification.sol";
import "../Interfaces/IOAMarketManagement.sol";
import "../Interfaces/IOAMNFT.sol";
import "../Interfaces/IOAMITOManagement.sol";
import "../Interfaces/IOAMDAO.sol";
import "../Interfaces/IOAMNFTSales.sol";

contract OAMEnglishAuctions is Ownable, ReentrancyGuard, IOAMEnglishAuctions {
    //+-We enable the S.Contract to use the Struct "Counter" of the Counters Utils S.Contract:_
    using Counters for Counters.Counter;

    address public OAMUsersVerificationAddress;
    IOAMUsersVerification OAMUVContract =
        IOAMUsersVerification(OAMUsersVerificationAddress);
    address public OAMarketManagementAddress;
    IOAMarketManagement OAMMContract =
        IOAMarketManagement(OAMarketManagementAddress);
    address public OAMITOManagementAddress;
    IOAMITOManagement OAMITOManagementContract =
        IOAMITOManagement(OAMITOManagementAddress);
    address public OAMDAOAddress;
    IOAMDAO OAMDAOContract = IOAMDAO(OAMDAOAddress);
    address public OAMNFTSalesAddress;
    IOAMNFTSales OAMNFTSalesContract = IOAMNFTSales(OAMNFTSalesAddress);

    //+-AuctionTime. By Default the time is 1 day.
    uint256 public auctionStandardTime = 1 days;
    //+-Current State of the English Auction:_
    mapping(uint256 => address) internal highestBidders;
    mapping(uint256 => uint256) internal highestBids;
    mapping(uint256 => uint256) internal auctionEndTimes;
    mapping(uint256 => bool) internal auctionEnded;
    mapping(address => uint256) internal pendingReturns;

    //+-English Auction Allowances:_
    mapping(address => bool) internal englishAuctionAllowed;

    function setNewOAMUVAddress(address _addr) public onlyOwner {
        OAMUsersVerificationAddress = _addr;
        OAMUVContract = IOAMUsersVerification(OAMUsersVerificationAddress);
    }

    function setNewOAMMAddress(address _addr) public onlyOwner {
        OAMarketManagementAddress = _addr;
        OAMMContract = IOAMarketManagement(OAMarketManagementAddress);
    }

    function setNewOAMITOManagementAddress(address _addr) public onlyOwner {
        OAMITOManagementAddress = _addr;
        OAMITOManagementContract = IOAMITOManagement(OAMITOManagementAddress);
    }

    function setNewOAMDAOAddress(address _addr) public onlyOwner {
        OAMDAOAddress = _addr;
        OAMDAOContract = IOAMDAO(OAMDAOAddress);
    }

    function setNewOAMNFTSalesAddress(address _addr) public onlyOwner {
        OAMNFTSalesAddress = _addr;
        OAMNFTSalesContract = IOAMNFTSales(OAMNFTSalesAddress);
    }

    //+-Platform Owner allows an ArtWork N.F.T. to be sold by Auction after a Voting in the N.F.T. D.A.O. Determines that:_
    function enableEnglishAuction(address _nftAddress, bool allows)
        public
    {
        require(OAMUVContract.onlyOwnerOrServer(msg.sender), 'Only Owner or Server can perform this function');
        require(
            OAMUVContract.onlyPlatformNFTs(_nftAddress),
            "Not a Platform N.F.T."
        );
        englishAuctionAllowed[_nftAddress] = allows;
        emit EnglishAuctionAllowed(_nftAddress, allows);
    }

    //+-An ArtWork Owner Places an item for sale in an English Auction on the Marketplace after a Voting in the D.A.O. Determines that:_
    function createMarketEnglishAuction(
        address _nftAddress,
        uint256 startingPrice,
        uint256 daysAuctionEndTime
    ) public nonReentrant {
        require(OAMUVContract.isVerified(msg.sender), "Not a Verified User.");
        require(
            OAMITOManagementContract.getIsFreezedAfterITO(_nftAddress) == false,
            "Token Shares Freezed after I.T.O."
        );
        require(englishAuctionAllowed[_nftAddress], "Auction is not allowed.");
        require(
            msg.sender == IOAMNFT(_nftAddress).getArtWorkOwner(),
            "Not the ArtWork Owner."
        );
        require(startingPrice > 0, "Price must be >= 1 Fiat Token");
        require(
            daysAuctionEndTime >= 1,
            "daysAuctionEndTime must be >= than 1"
        );

        OAMNFTSalesContract.incrementItemIds();
        uint256 itemId = OAMNFTSalesContract.getItemIds();
        OAMNFTSalesContract.setNFTItemID(_nftAddress, itemId);

        auctionEndTimes[itemId] =
            block.timestamp +
            (daysAuctionEndTime * auctionStandardTime);
        auctionEnded[itemId] = false;
        OAMNFTSalesContract.setNFTisOnSale(_nftAddress, true);

        OAMNFTSalesContract.setMarketItem(
            itemId,
            _nftAddress,
            payable(msg.sender),
            payable(address(0)),
            startingPrice
        );

        /**+-If the I.T.O. in the D.A.O. of the ArtWork N.F.T. did not take place yet, we transfer the N.F.T.
        from the ArtWork Owner's wallet to the E.Auction S.C., otherwise we Transfer it from the I.T.O.
        Management S.C. to the E.Auction S.C.:_*/
        if (OAMITOManagementContract.getItoStarted(_nftAddress) == false) {
            IERC721(_nftAddress).ERC721transferFrom(
                msg.sender,
                address(this),
                IOAMNFT(_nftAddress).getArtWorkId()
            );
        } else if (
            OAMITOManagementContract.getItoStarted(_nftAddress) == true
        ) {
            IERC721(_nftAddress).ERC721transferFrom(
                OAMITOManagementAddress,
                address(this),
                IOAMNFT(_nftAddress).getArtWorkId()
            );
        }

        OAMNFTSalesContract.emitMarketItemCreated(
            itemId,
            _nftAddress,
            msg.sender,
            address(0),
            startingPrice,
            false
        );
    }

    //+-Creates a Bid for a Marketplace EnglishAuction:_
    function bidEnglishAuction(uint256 itemId, uint256 bidAmount)
        public
        nonReentrant
    {
        require(OAMUVContract.isVerified(msg.sender), "Not a Verified User.");
        require(
            block.timestamp < auctionEndTimes[itemId],
            "The auction has already ended."
        );
        require(
            bidAmount > highestBids[itemId],
            "There is already a higher or equal bid."
        );

        //+-We Allow the S.C. to Spend Bidder's Payment Tokens + The Possible PlatForm Fees in case this Bidder Wins the Auction:_
        IERC20(OAMNFTSalesContract.getItemFiatToken(itemId)).ERC20approve(
            address(this),
            (bidAmount +
                ((bidAmount / 100) * OAMMContract.getSharesSalesPercPrice()))
        );

        /**+-We Transfer from the Bidder's Wallet to Marketplace S.C. the Amount of Fiat Tokens of the Bid:_*/
        IERC20(OAMNFTSalesContract.getItemFiatToken(itemId)).ERC20transferFrom(
            msg.sender,
            address(this),
            bidAmount
        );

        //+-Automatically Returns to the former Highest Bidder its Losing Bid:_
        if (highestBids[itemId] != 0) {
            IERC20(OAMNFTSalesContract.getItemFiatToken(itemId))
                .ERC20transferFrom(
                    address(this),
                    payable(highestBidders[itemId]),
                    highestBids[itemId]
                );
        }

        //+-Updates New Highest Bidder and Highest Bid.
        highestBidders[itemId] = msg.sender;
        highestBids[itemId] = bidAmount;
        emit HighestBidIncrease(msg.sender, bidAmount);
    }

    /**+-This function needs to be Manually Called when the Time of an EnglishAuction finishes to Reward The Highest Bidder and The N.F.T.
    Owner (If the I.T.O. did not happened yet, otherwise it will reward all the Token Share Holders) in the case that someone Bided for
    the N.F.T. OR to Remove the Listed Item from the Marketplace and return the N.F.T. to the ArtWork Owner (If the I.T.O. did not happened
    yet, otherwise it stay in the Marketplace S.C.) if nobody bided:_*/
    function englishAuctionEnd(address _nftAddress, uint256 itemId)
        public
    {
        require(OAMUVContract.onlyOwnerOrServer(msg.sender), 'Only Owner or Server can perform this function');
        require(OAMUVContract.isVerified(msg.sender), "Not a Verified User.");
        require(
            OAMUVContract.onlyPlatformNFTs(_nftAddress),
            "Not a Platform N.F.T."
        );
        require(
            block.timestamp > auctionEndTimes[itemId],
            "The auction has not ended yet"
        );
        require(
            auctionEnded[itemId] == false,
            "Function has already been called"
        );

        auctionEnded[itemId] = true;
        OAMNFTSalesContract.setNFTisOnSale(_nftAddress, false);

        //+-If someone Bided for the N.F.T. and the I.T.O. did not take place, we reward the Highest Bidder and the N.F.T. Owner:_
        if (
            highestBids[itemId] != 0 &&
            OAMITOManagementContract.getItoStarted(_nftAddress) == false
        ) {
            IERC20(OAMNFTSalesContract.getItemFiatToken(itemId))
                .ERC20transferFrom(
                    address(this),
                    IOAMNFT(_nftAddress).getArtWorkOwner(),
                    highestBids[itemId]
                );
            /**+-We Transfer from the Bidder's Wallet to Marketplace Owner's Wallet the Fees of the Bid:_*/
            IERC20(OAMNFTSalesContract.getItemFiatToken(itemId))
                .ERC20transferFrom(
                    highestBidders[itemId],
                    payable(_owner),
                    ((highestBids[itemId] / 100) *
                        OAMMContract.getSharesSalesPercPrice())
                );

            emit EnglishAuctionEnded(
                highestBidders[itemId],
                highestBids[itemId]
            );

            IERC721(_nftAddress).ERC721transferFrom(
                address(this),
                highestBidders[itemId],
                IOAMNFT(_nftAddress).getArtWorkId()
            );
            OAMNFTSalesContract.setItemNewOwner(
                itemId,
                payable(highestBidders[itemId])
            );
            OAMNFTSalesContract.setItemSoldStatus(itemId, true);
            OAMNFTSalesContract.setItemPrice(itemId, highestBids[itemId]);
            OAMNFTSalesContract.incrementSoldItems();
        } else if (
            /**+-If someone Bided for the N.F.T. and the I.T.O. did take place, we reward the Highest Bidder and
        all the N.F.T. Token Share Holders:_*/
            highestBids[itemId] != 0 &&
            OAMITOManagementContract.getItoStarted(_nftAddress)
        ) {
            /**+-We Transfer from the Bidder's Wallet to Marketplace Owner's Wallet the Fees of the Bid:_*/
            IERC20(OAMNFTSalesContract.getItemFiatToken(itemId))
                .ERC20transferFrom(
                    highestBidders[itemId],
                    payable(_owner),
                    ((highestBids[itemId] / 100) *
                        OAMMContract.getSharesSalesPercPrice())
                );

            emit EnglishAuctionEnded(
                highestBidders[itemId],
                highestBids[itemId]
            );

            /**+-We Inform to the ArtWork N.F.T. & D.A.O. S.C. that the Actions of the D.A.O. cannot continue since the new
        Owner has 100% Ownership of the ArtWork N.F.T. and its Shares:_*/
            OAMDAOContract.buyOutTookPlace(_nftAddress);

            IERC721(_nftAddress).ERC721transferFrom(
                address(this),
                highestBidders[itemId],
                IOAMNFT(_nftAddress).getArtWorkId()
            );
            OAMNFTSalesContract.setItemNewOwner(
                itemId,
                payable(highestBidders[itemId])
            );
            OAMNFTSalesContract.setItemSoldStatus(itemId, true);
            OAMNFTSalesContract.setItemPrice(itemId, highestBids[itemId]);
            OAMNFTSalesContract.incrementSoldItems();
        } else if (
            /**+-If no one Bided for the N.F.T. and the I.T.O. did not take place, we return the N.F.T. to the ArtWork Owner:_*/
            highestBids[itemId] == 0 &&
            OAMITOManagementContract.getItoStarted(_nftAddress) == false
        ) {
            emit EnglishAuctionEnded(address(0), 0);

            IERC721(_nftAddress).ERC721transferFrom(
                address(this),
                OAMNFTSalesContract.getItemSeller(itemId),
                IOAMNFT(_nftAddress).getArtWorkId()
            );

            OAMNFTSalesContract.deleteMarketItem(itemId);
        } else if (
            /**+-If no one Bided for the N.F.T. and the I.T.O. did take place, we keep the N.F.T. in the Marketplace S.C.:_*/
            highestBids[itemId] == 0 &&
            OAMITOManagementContract.getItoStarted(_nftAddress)
        ) {
            emit EnglishAuctionEnded(address(0), 0);

            OAMNFTSalesContract.deleteMarketItem(itemId);
        }
    }
}
