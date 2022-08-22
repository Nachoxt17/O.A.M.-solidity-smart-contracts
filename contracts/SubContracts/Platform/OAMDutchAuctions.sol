// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.4;

import "hardhat/console.sol";
import "../../Libraries/Utils/Ownable.sol";
import "../../Libraries/Utils/Strings.sol";
import "../../Libraries/Utils/Counters.sol";
import "../../Libraries/Interfaces/IERC721.sol";
import "../../Libraries/Interfaces/IERC20.sol";
import "../../Libraries/Utils/ReentrancyGuard.sol";
import "../Interfaces/IOAMUsersVerification.sol";
import "../Interfaces/IOAMarketManagement.sol";
import "../Interfaces/IOAMNFT.sol";
import "../Interfaces/IOAMITOManagement.sol";
import "../Interfaces/IOAMDAO.sol";
import "../Interfaces/IOAMNFTSales.sol";
import "../Interfaces/IOAMDutchAuctions.sol";

contract OAMDutchAuctions is Ownable, ReentrancyGuard, IOAMDutchAuctions {
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

    //+-Parameters of the Dutch Auction:_
    mapping(uint256 => uint256) public dutchAuctionStartingPrices;
    mapping(uint256 => uint256) internal dutchAuctionEndingPrices;
    mapping(uint256 => uint256) internal dutchAuctionStartTimes;
    mapping(uint256 => uint256) internal auctionEndTimes;
    mapping(uint256 => bool) internal auctionEnded;

    //+-Dutch Auction Allowances:_
    mapping(address => bool) internal dutchAuctionAllowed;

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
    function enableDutchAuction(address _nftAddress, bool allows)
        public
    {
        require(OAMUVContract.onlyOwnerOrServer(msg.sender), 'Only Owner or Server can perform this function');
        require(
            OAMUVContract.onlyPlatformNFTs(_nftAddress),
            "Not a Platform N.F.T."
        );
        dutchAuctionAllowed[_nftAddress] = allows;
        emit DutchAuctionAllowed(_nftAddress, allows);
    }

    //+-An ArtWork Owner Places an item for sale in an Dutch Auction on the Marketplace after a Voting in the D.A.O. Determines that:_
    function createMarketDutchAuction(
        address _nftAddress,
        uint256 startingPrice,
        uint256 endingPrice,
        uint256 daysAuctionEndTime
    ) public nonReentrant {
        require(OAMUVContract.isVerified(msg.sender), "Not a Verified User.");
        require(
            OAMITOManagementContract.getIsFreezedAfterITO(_nftAddress) == false,
            "Token Shares Freezed after I.T.O."
        );
        require(dutchAuctionAllowed[_nftAddress], "Auction is not allowed.");
        require(
            msg.sender == IOAMNFT(_nftAddress).getArtWorkOwner(),
            "Not the ArtWork Owner."
        );
        require(
            startingPrice > endingPrice,
            "Starting Price must be > Ending Price"
        );
        require(endingPrice > 0, "Price must be >= 1 Fiat Token");
        require(daysAuctionEndTime >= 1, "daysAuctionEndTime must be >= 1");

        OAMNFTSalesContract.incrementItemIds();
        uint256 itemId = OAMNFTSalesContract.getItemIds();
        OAMNFTSalesContract.setNFTItemID(_nftAddress, itemId);

        dutchAuctionStartTimes[itemId] = block.timestamp;
        auctionEndTimes[itemId] =
            block.timestamp +
            (daysAuctionEndTime * auctionStandardTime);
        // console.log(
        //     "+-Current Time when Creating Dutch Auction:_ ",
        //     block.timestamp
        // );
        // console.log(
        //     "+-Dutch Auction Start Time:_ ",
        //     dutchAuctionStartTimes[itemId]
        // );
        // console.log("+-Dutch Auction End Time:_ ", auctionEndTimes[itemId]);
        // console.log(
        //     "+-Dutch Auction Time in Seconds:_ ",
        //     (daysAuctionEndTime * auctionStandardTime)
        // );
        auctionEnded[itemId] = false;
        dutchAuctionStartingPrices[itemId] = startingPrice;
        dutchAuctionEndingPrices[itemId] = endingPrice;

        OAMNFTSalesContract.setMarketItem(
            itemId,
            _nftAddress,
            payable(msg.sender),
            payable(address(0)),
            startingPrice
        );

        /**+-If the I.T.O. in the D.A.O. of the ArtWork N.F.T. did not take place yet, we transfer the N.F.T.
        from the ArtWork Owner's wallet to the DutchAuction S.C.:_*/
        if (OAMITOManagementContract.getItoStarted(_nftAddress) == false) {
            IERC721(_nftAddress).ERC721transferFrom(
                msg.sender,
                address(this),
                IOAMNFT(_nftAddress).getArtWorkId()
            );
        } else if (
            OAMITOManagementContract.getItoStarted(_nftAddress) == true
        ) {
            /**+-If the I.T.O. in the D.A.O. of the ArtWork N.F.T. DID already take place, we transfer the N.F.T.
        from the I.T.O. Management S.C. to the DutchAuction S.C.:_*/
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

    //+-Get the Starting price of a Dutch Auction in the Default Fiat Token of the D.A.O. of the N.F.T.:_
    function getStartingPriceDutchAuction(uint256 itemId)
        public
        view
        returns (uint256)
    {
        return dutchAuctionStartingPrices[itemId];
    }

    //+-Get the Current price of a Dutch Auction in the Default Fiat Token of the D.A.O. of the N.F.T.:_
    function getCurrentPriceDutchAuction(uint256 itemId)
        public
        view
        returns (uint256)
    {
        require(
            block.timestamp < auctionEndTimes[itemId],
            "The auction has already ended"
        );

        uint256 elapsedTime = block.timestamp - dutchAuctionStartTimes[itemId];
        uint256 timeRange = auctionEndTimes[itemId] -
            dutchAuctionStartTimes[itemId];
        uint256 priceRange = dutchAuctionStartingPrices[itemId] -
            dutchAuctionEndingPrices[itemId];
        return
            dutchAuctionStartingPrices[itemId] -
            ((elapsedTime * priceRange) / timeRange);
    }

    //+-Creates the Sale for the first and only Bidder in a Marketplace Dutch Auction:_
    function createDutchAuctionSale(address _nftAddress, uint256 itemId)
        public
        nonReentrant
    {
        require(OAMUVContract.isVerified(msg.sender), "Not a Verified User.");
        require(
            OAMUVContract.onlyPlatformNFTs(_nftAddress),
            "Not a Platform N.F.T."
        );
        require(
            auctionEnded[itemId] == false,
            "Function has already been called"
        );
        require(
            block.timestamp < auctionEndTimes[itemId],
            "The auction has already ended"
        );
        uint256 paymentAmount = (getCurrentPriceDutchAuction(itemId) +
            ((getCurrentPriceDutchAuction(itemId) / 100) *
                OAMMContract.getSharesSalesPercPrice()));
        require(
            IERC20(OAMNFTSalesContract.getItemFiatToken(itemId)).ERC20balanceOf(
                msg.sender
            ) >= paymentAmount,
            "Insufficient Funds for Paying Price and Fee."
        );

        //+-We Allow the S.C. to Spend Bidder's Payment Tokens to Paying for the Bid + PlatForm Fees:_
        IERC20(OAMNFTSalesContract.getItemFiatToken(itemId)).ERC20approve(
            address(this),
            paymentAmount
        );

        if (OAMITOManagementContract.getItoStarted(_nftAddress) == false) {
            /**+-We Transfer from the Bidder's Wallet to the ArtWork Owner the Amount of Fiat Tokens of the Bid:_*/
            IERC20(OAMNFTSalesContract.getItemFiatToken(itemId))
                .ERC20transferFrom(
                    msg.sender,
                    IOAMNFT(_nftAddress).getArtWorkOwner(),
                    getCurrentPriceDutchAuction(itemId)
                );
        } else if (
            OAMITOManagementContract.getItoStarted(_nftAddress) == true
        ) {
            /**+-We Transfer from the Bidder's Wallet to the N.F.T.Sales S.C. the Amount of Fiat Tokens of the Bid(So Users can Claim their Reward):_*/
            IERC20(OAMNFTSalesContract.getItemFiatToken(itemId))
                .ERC20transferFrom(
                    msg.sender,
                    OAMNFTSalesAddress,
                    getCurrentPriceDutchAuction(itemId)
                );
            /**+-We Inform to the ArtWork N.F.T. & D.A.O. S.C. that the Actions of the D.A.O. cannot continue since the new
            Owner has 100% Ownership of the ArtWork N.F.T. and its Shares:_*/
            OAMDAOContract.buyOutTookPlace(_nftAddress);
        }

        /**+-We Transfer from the Bidder's Wallet to Marketplace Owner's Wallet the Fees of the Bid:_*/
        IERC20(OAMNFTSalesContract.getItemFiatToken(itemId)).ERC20transferFrom(
            msg.sender,
            payable(_owner),
            ((getCurrentPriceDutchAuction(itemId) / 100) *
                OAMMContract.getSharesSalesPercPrice())
        );

        IERC721(_nftAddress).ERC721transferFrom(
            address(this),
            msg.sender,
            IOAMNFT(_nftAddress).getArtWorkId()
        );
        OAMNFTSalesContract.setItemNewOwner(itemId, payable(msg.sender));
        OAMNFTSalesContract.setItemSoldStatus(itemId, true);
        OAMNFTSalesContract.setItemPrice(
            itemId,
            getCurrentPriceDutchAuction(itemId)
        );
        OAMNFTSalesContract.incrementItemIds();

        auctionEnded[itemId] = true;
        emit DutchAuctionEnded(msg.sender, OAMNFTSalesContract.getItemPrice(1));
        // console.log(
        //     "Dutch Auction Sale Price:_ ",
        //     OAMNFTSalesContract.getItemPrice(1)
        // );
    }

    /**+-This function needs to be Manually Called when the Time of a DutchAuction finished and nobody bided to Remove the Listed Item 
from the Marketplace and return the N.F.T. to the Seller.*/
    function dutchAuctionEnd(address _nftAddress, uint256 itemId)
        public
        nonReentrant
    {
        require(OAMUVContract.onlyOwnerOrServer(msg.sender), 'Only Owner or Server can perform this function');
        require(
            OAMUVContract.onlyPlatformNFTs(_nftAddress),
            "Not a Platform N.F.T."
        );
        require(
            msg.sender == IOAMNFT(_nftAddress).getArtWorkOwner(),
            "You are not the ArtWork Owner."
        );
        require(
            auctionEnded[itemId] == false,
            "Function has already been called or ArtWork sold."
        );
        require(
            block.timestamp < auctionEndTimes[itemId],
            "The auction has not ended yet"
        );

        auctionEnded[itemId] = true;
        emit DutchAuctionEnded(address(0), 0);

        if (OAMITOManagementContract.getItoStarted(_nftAddress) == false) {
            IERC721(_nftAddress).ERC721transferFrom(
                address(this),
                OAMNFTSalesContract.getItemSeller(itemId),
                IOAMNFT(_nftAddress).getArtWorkId()
            );
        }

        OAMNFTSalesContract.deleteMarketItem(itemId);
    }
}
