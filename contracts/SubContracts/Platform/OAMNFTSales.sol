// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.4;
import "../../Libraries/Interfaces/IERC20.sol";
import "../../Libraries/Interfaces/IERC721.sol";
import "../../Libraries/Utils/Ownable.sol";
import "../../Libraries/Utils/Strings.sol";
import "../../Libraries/Utils/Counters.sol";
import "../../Libraries/Utils/ReentrancyGuard.sol";
import "../Interfaces/IOAMNFTSales.sol";
import "../Interfaces/IOAMUsersVerification.sol";
import "../Interfaces/IOAMarketManagement.sol";
import "../Interfaces/IOAMNFT.sol";
import "../Interfaces/IOAMITOManagement.sol";
import "../Interfaces/IOAMDAO.sol";

contract OAMNFTSales is Ownable, ReentrancyGuard, IOAMNFTSales {
    //+-We enable the S.Contract to use the Struct "Counter" of the Counters Utils S.Contract:_
    using Counters for Counters.Counter;
    Counters.Counter internal _itemIds;
    Counters.Counter internal _itemsSold;

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
    address public OAMEnglishAuctionsAddress;
    address public OAMDutchAuctionsAddress;

    //+-List of ItemIds by Addresses.
    mapping(address => uint256) internal addresstoItemId;

    //+-Market Sales Allowances:_
    mapping(address => bool) internal marketSaleAllowed;

    //+-Input S.C. Address of an N.F.T. and get its Implied Value in the Default Fiat Token set in its S.C.:_
    mapping(address => uint256)
        public NFTAddresstoImpliedValueInOriginalDAOFiatToken;

    //+-Input S.C. Address of an N.F.T. and get its Buyout Value in the Default Fiat Token set in its S.C.:_
    mapping(address => uint256)
        public NFTAddresstoBuyoutValueInOriginalDAOFiatToken;

    //+-Input S.C. Address of an N.F.T. and get if it is Currently on Sale:_
    mapping(address => bool) public NFTAddresstoIsOnSale;

    //+-Struct (Data Structure) of every Item in the Marketplace:_
    struct MarketItem {
        uint256 itemId;
        address nftContract;
        address payable seller;
        address payable owner;
        address defaultFiatToken;
        uint256 price;
        bool sold;
    }

    //+-Mapping in which you Give an Item ID and you receive that Item Struct:_
    mapping(uint256 => MarketItem) internal idToMarketItem;

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

    function setNewEnglishAuctionsAddress(address _addr) public onlyOwner {
        OAMEnglishAuctionsAddress = _addr;
    }

    function setNewDutchAuctionsAddress(address _addr) public onlyOwner {
        OAMDutchAuctionsAddress = _addr;
    }

    //+-Get Current Item I.D.:_
    function getItemIds() public view override returns (uint256) {
        return _itemIds.current();
    }

    //+-Increment Current Item I.D.:_
    function incrementItemIds() public override {
        require(
            msg.sender == OAMEnglishAuctionsAddress ||
                msg.sender == OAMDutchAuctionsAddress,
            "Only Auctions S.C.s."
        );
        _itemIds.increment();
    }

    //+-Decrease Current Item I.D.:_
    function decreaseItemIds() public override {
        require(
            msg.sender == OAMEnglishAuctionsAddress ||
                msg.sender == OAMDutchAuctionsAddress,
            "Only Auctions S.C.s."
        );
        _itemIds.decrement();
    }

    //+-Create a New MarketItem Struct from External S.C.s.
    function setMarketItem(
        uint256 itemId,
        address _nftAddress,
        address seller,
        address owner,
        uint256 startingPrice
    ) public override {
        require(
            msg.sender == OAMEnglishAuctionsAddress ||
                msg.sender == OAMDutchAuctionsAddress,
            "Only Auctions S.C.s."
        );
        idToMarketItem[itemId] = MarketItem(
            itemId,
            _nftAddress,
            payable(seller),
            payable(owner),
            IOAMNFT(_nftAddress).getDAOFiatTokenAddress(),
            startingPrice,
            false
        );
    }

    //+-Get MarketItem FiatToken:_
    function getItemFiatToken(uint256 itemId)
        public
        view
        override
        returns (address)
    {
        return idToMarketItem[itemId].defaultFiatToken;
    }

    //+-Set MarketItem New Owner:_
    function setItemNewOwner(uint256 itemId, address newOwner) public override {
        require(
            msg.sender == OAMEnglishAuctionsAddress ||
                msg.sender == OAMDutchAuctionsAddress,
            "Only Auctions S.C.s."
        );
        idToMarketItem[itemId].owner = payable(newOwner);
    }

    //+-Set MarketItem Sold Status:_
    function setItemSoldStatus(uint256 itemId, bool sold) public override {
        require(
            msg.sender == OAMEnglishAuctionsAddress ||
                msg.sender == OAMDutchAuctionsAddress,
            "Only Auctions S.C.s."
        );
        idToMarketItem[itemId].sold = sold;
    }

    //+-Get MarketItem Price:_
    function getItemPrice(uint256 itemId)
        public
        view
        override
        returns (uint256)
    {
        uint256 itemPrice = idToMarketItem[itemId].price;
        return itemPrice;
    }

    //+-Set MarketItem Sold-in-Auction Price:_
    function setItemPrice(uint256 itemId, uint256 newPrice) public override {
        require(
            msg.sender == OAMEnglishAuctionsAddress ||
                msg.sender == OAMDutchAuctionsAddress,
            "Only Auctions S.C.s."
        );
        idToMarketItem[itemId].price = newPrice;
    }

    //+-Get MarketItem Seller:_
    function getItemSeller(uint256 itemId)
        public
        view
        override
        returns (address)
    {
        return idToMarketItem[itemId].seller;
    }

    //+-Delete MarketItem Struct:_
    function deleteMarketItem(uint256 itemId) public override {
        require(
            msg.sender == OAMEnglishAuctionsAddress ||
                msg.sender == OAMDutchAuctionsAddress,
            "Only Auctions S.C.s."
        );
        delete idToMarketItem[itemId];
    }

    //+-Set N.F.T. MarketItem I.D.:_
    function setNFTItemID(address _nftAddress, uint256 itemId) public override {
        require(
            msg.sender == OAMEnglishAuctionsAddress ||
                msg.sender == OAMDutchAuctionsAddress,
            "Only Auctions S.C.s."
        );
        addresstoItemId[_nftAddress] = itemId;
    }

    //+-Set If N.F.T. MarketItem Is On Sale or Not.:_
    function setNFTisOnSale(address _nftAddress, bool isOnSale)
        public
        override
    {
        require(
            msg.sender == OAMEnglishAuctionsAddress ||
                msg.sender == OAMDutchAuctionsAddress,
            "Only Auctions S.C.s."
        );
        NFTAddresstoIsOnSale[_nftAddress] = isOnSale;
    }

    //+-Other S.C.s can Emit this Event:_
    function emitMarketItemCreated(
        uint256 itemId,
        address nftContract,
        address seller,
        address owner,
        uint256 price,
        bool sold
    ) public override {
        require(
            msg.sender == OAMEnglishAuctionsAddress ||
                msg.sender == OAMDutchAuctionsAddress,
            "Only Auctions S.C.s."
        );
        emit MarketItemCreated(itemId, nftContract, seller, owner, price, sold);
    }

    //+-Increment Current Sold Items:_
    function incrementSoldItems() public override {
        require(
            msg.sender == OAMEnglishAuctionsAddress ||
                msg.sender == OAMDutchAuctionsAddress,
            "Only Auctions S.C.s."
        );
        _itemsSold.increment();
    }

    //+-Platform Owner allows an ArtWork N.F.T. to be sold by Market Sale after a Voting in the N.F.T. D.A.O. Determines that:_
    function enableMarketSale(address _nftAddress, bool allows)
        public
    {
        require(OAMUVContract.onlyOwnerOrServer(msg.sender), 'Only Owner or Server can perform this function');
        require(
            OAMUVContract.onlyPlatformNFTs(_nftAddress),
            "Not a Platform N.F.T."
        );
        marketSaleAllowed[_nftAddress] = allows;
    }

    //+-An ArtWork Owner Places an Item for sale on the Marketplace after a Voting in the D.A.O. Determines that:_
    function createMarketItem(address _nftAddress, uint256 price)
        public
        nonReentrant
    {
        require(OAMUVContract.isVerified(msg.sender), "Not a Verified User.");
        require(
            OAMITOManagementContract.getIsFreezedAfterITO(_nftAddress) == false,
            "Token Shares Freezed after I.T.O."
        );
        require(marketSaleAllowed[_nftAddress], "Market Sale is not allowed.");
        require(price > 0, "Price must be >= 1 FiatToken");

        //+-We Allow the S.C. to Spend ArtWork Owner's Fee Payment NOK Fiat Tokens and we transfer the ListingFee to the Owner:_
        IERC20(OAMMContract.getNOKTokenAddress()).ERC20approve(
            address(this),
            OAMMContract.getListingPrice()
        );
        IERC20(OAMMContract.getNOKTokenAddress()).ERC20transferFrom(
            msg.sender,
            payable(_owner),
            OAMMContract.getListingPrice()
        );

        _itemIds.increment();
        uint256 itemId = _itemIds.current();
        addresstoItemId[_nftAddress] = itemId;

        idToMarketItem[itemId] = MarketItem(
            itemId,
            _nftAddress,
            payable(msg.sender),
            payable(address(0)),
            IOAMNFT(_nftAddress).getDAOFiatTokenAddress(),
            price,
            false
        );
        NFTAddresstoIsOnSale[_nftAddress] = true;

        IERC721(_nftAddress).ERC721transferFrom(
            msg.sender,
            address(this),
            IOAMNFT(_nftAddress).getArtWorkId()
        );

        emit MarketItemCreated(
            itemId,
            _nftAddress,
            msg.sender,
            address(0),
            price,
            false
        );
    }

    //+-An ArtWork Owner Removes an item for sale on the Marketplace:_
    function removeMarketItem(address _nftAddress) public nonReentrant {
        require(OAMUVContract.isVerified(msg.sender), "Not a Verified User.");
        require(
            OAMUVContract.onlyPlatformNFTs(_nftAddress),
            "Not a Platform N.F.T."
        );
        require(
            msg.sender == idToMarketItem[addresstoItemId[_nftAddress]].seller,
            "Only the Seller can do this."
        );

        IERC721(_nftAddress).ERC721transferFrom(
            address(this),
            idToMarketItem[addresstoItemId[_nftAddress]].seller,
            1
        );

        delete idToMarketItem[addresstoItemId[_nftAddress]];
        NFTAddresstoIsOnSale[_nftAddress] = false;
    }

    //+-Creates the sale of a Marketplace Item. Transfers ownership of the item, as well as funds between parties:_
    function createMarketSale(address _nftAddress, uint256 itemId)
        public
        nonReentrant
    {
        require(OAMUVContract.isVerified(msg.sender), "Not a Verified User.");
        require(
            OAMUVContract.onlyPlatformNFTs(_nftAddress),
            "Not a Platform N.F.T."
        );
        uint256 price = idToMarketItem[itemId].price;

        //+-We Allow the S.C. to Spend Buyer's Payment Tokens, which are the same as the D.A.O. Default Fiat Token:_
        IERC20(IOAMNFT(_nftAddress).getDAOFiatTokenAddress()).ERC20approve(
            address(this),
            price
        );

        /**+-We Transfer from the Buyer's Wallet to the Marketplace Smart Contract the Pay
        for the ArtWork N.F.T.:_*/
        IERC20(IOAMNFT(_nftAddress).getDAOFiatTokenAddress()).ERC20transferFrom(
                msg.sender,
                address(this),
                price
            );

        /**+-We Transfer from the Smart Contract to the Buyer's Wallet the ArtWork N.F.T. that he/she bought together
        with the N.F.T. D.A.O. OwnerShip:_*/
        IERC721(_nftAddress).ERC721transferFrom(
            address(this),
            msg.sender,
            IOAMNFT(_nftAddress).getArtWorkId()
        );

        IERC721(_nftAddress).ERC721transferFrom(
            address(this),
            msg.sender,
            IOAMNFT(_nftAddress).getArtWorkId()
        );
        /**+-We Inform to the ArtWork N.F.T. & D.A.O. S.C. that the Actions of the D.A.O. cannot continue since the new
        Owner has 100% Ownership of the ArtWork N.F.T. and its Shares:_*/
        OAMDAOContract.buyOutTookPlace(_nftAddress);
        idToMarketItem[itemId].owner = payable(msg.sender);
        idToMarketItem[itemId].sold = true;
        NFTAddresstoIsOnSale[_nftAddress] = false;
        _itemsSold.increment();
    }

    //+-Returns all UnSold Market Items:_
    function fetchMarketItems() public view returns (MarketItem[] memory) {
        uint256 itemCount = _itemIds.current();
        uint256 unsoldItemCount = _itemIds.current() - _itemsSold.current();
        uint256 currentIndex = 0;

        MarketItem[] memory items = new MarketItem[](unsoldItemCount);
        for (uint256 i = 0; i < itemCount; i++) {
            if (idToMarketItem[i + 1].owner == address(0)) {
                uint256 currentId = i + 1;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    //+-Returns only Items that an User has purchased:_
    function fetchMyNFTs() public view returns (MarketItem[] memory) {
        uint256 totalItemCount = _itemIds.current();
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].owner == msg.sender) {
                itemCount += 1;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);
        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].owner == msg.sender) {
                uint256 currentId = i + 1;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    //+-Returns only items an User has Created:_
    function fetchItemsCreated() public view returns (MarketItem[] memory) {
        uint256 totalItemCount = _itemIds.current();
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].seller == msg.sender) {
                itemCount += 1;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);
        for (uint256 j = 0; j < totalItemCount; j++) {
            if (idToMarketItem[j + 1].seller == msg.sender) {
                uint256 currentId = j + 1;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    /**+-Platform  Owner can set the Implied Value of the N.F.T..
    +-The Number must include 2 Decimals(Without the ",") and the Calculation of this Value is done Off-Chain:_*/
    function setNFTImpliedValueInOriginalDAOFiatToken(
        address _nftAddress,
        uint256 _impliedValueInOriginalDAOFiatToken
    ) public override {
        require(OAMITOManagementAddress == msg.sender, "Not ITO contract.");
        require(
            getNFTIsOnSale(_nftAddress) == false,
            "The N.F.T. is Currently on Sale."
        );
        NFTAddresstoImpliedValueInOriginalDAOFiatToken[
            _nftAddress
        ] = _impliedValueInOriginalDAOFiatToken;
    }

    /**+-Platform  Owner can set the BuyOut Price of the N.F.T..
    +-The Number must include 2 Decimals(Without the ",") and the Calculation of this Value is done Off-Chain:_*/
    function setNFTBuyoutValueInOriginalDAOFiatToken(
        address _nftAddress,
        uint256 _buyoutValueInOriginalDAOFiatToken
    ) public override {
        require(OAMUVContract.onlyOwnerOrServer(msg.sender), 'Only Owner or Server can perform this function');
        require(
            getNFTIsOnSale(_nftAddress) == false,
            "The N.F.T. is Currently on Sale."
        );
        NFTAddresstoBuyoutValueInOriginalDAOFiatToken[
            _nftAddress
        ] = _buyoutValueInOriginalDAOFiatToken;
        emit BuyOutPriceSet(_nftAddress);
    }

    //+-Get an ArtWork N.F.T. Implied Value in its Default Fiat Token:_
    function getNFTImpliedValueInOriginalDAOFiatToken(address _nftAddress)
        public
        view
        override
        returns (uint256)
    {
        return NFTAddresstoImpliedValueInOriginalDAOFiatToken[_nftAddress];
    }

    //+-Get if an ArtWork N.F.T. is Currently on Sale:_
    function getNFTIsOnSale(address _nftAddress)
        public
        view
        override
        returns (bool)
    {
        return NFTAddresstoIsOnSale[_nftAddress];
    }

    //+-Any Verified User can call this to Buy Instantly an ArtWork N.F.T.:_
    function NFTBuyOut(address _nftAddress) public nonReentrant {
        require(OAMUVContract.isVerified(msg.sender), "Not a Verified User.");
        require(
            OAMUVContract.onlyPlatformNFTs(_nftAddress),
            "Not a Platform N.F.T."
        );
        //+-We Allow the S.C. to Spend Buyer's Payment Tokens, which are the same as the D.A.O. Default Fiat Token:_
        IERC20(IOAMNFT(_nftAddress).getDAOFiatTokenAddress()).ERC20approve(
            address(this),
            NFTAddresstoBuyoutValueInOriginalDAOFiatToken[_nftAddress]
        );

        /**+-We Transfer from the Buyer's Wallet to the Marketplace Smart Contract the Pay
        for the ArtWork N.F.T.:_*/
        IERC20(IOAMNFT(_nftAddress).getDAOFiatTokenAddress()).ERC20transferFrom(
                msg.sender,
                address(this),
                NFTAddresstoBuyoutValueInOriginalDAOFiatToken[_nftAddress]
            );

        if (OAMITOManagementContract.getItoStarted(_nftAddress) == true) {
            /**+-In case the ArtWork I.T.O Started, We Transfer from the I.T.O. Management Smart Contract to the Buyer's Wallet the ArtWork N.F.T.
            that he/she bought together with the N.F.T. D.A.O. OwnerShip:_*/
            IERC721(_nftAddress).ERC721transferFrom(
                OAMITOManagementAddress,
                msg.sender,
                IOAMNFT(_nftAddress).getArtWorkId()
            );
        } else if (
            OAMITOManagementContract.getItoStarted(_nftAddress) == false
        ) {
            /**+-In case the ArtWork I.T.O DIDN'T Started, We Transfer from the Collector's to the Buyer's Wallet the ArtWork N.F.T.
            that he/she bought together with the N.F.T. D.A.O. OwnerShip:_*/
            IERC721(_nftAddress).ERC721transferFrom(
                IOAMNFT(_nftAddress).getArtWorkOwner(),
                msg.sender,
                IOAMNFT(_nftAddress).getArtWorkId()
            );
        }

        /**+-We Inform to the ArtWork N.F.T. & D.A.O. S.C. that the Actions of the D.A.O. cannot continue since the new
        Owner has 100% Ownership of the ArtWork N.F.T. and its Shares:_*/
        OAMDAOContract.buyOutTookPlace(_nftAddress);
        emit BuyOut(
            _nftAddress,
            NFTAddresstoBuyoutValueInOriginalDAOFiatToken[_nftAddress]
        );
    }

    //+-ArtWork N.F.T. D.A.O. Token Share Holders can Claim their Rewards after the ArtWork is sold by BuyOut/Auction/MarketSale:_
    function claimBuyOutOrAuctionReward(address _nftAddress) public {
        require(OAMUVContract.isVerified(msg.sender), "Not a Verified User.");
        require(
            OAMUVContract.onlyPlatformNFTs(_nftAddress),
            "Not a Platform N.F.T."
        );
        require(
            OAMDAOContract.getBuyOutTookPlace(_nftAddress),
            "The Buy Out Reward cannot be claimed."
        );
        require(
            OAMDAOContract.isShareholder(_nftAddress, msg.sender),
            "Not registered Token Holder."
        );

        uint256 claimerBalance = IERC20(_nftAddress).ERC20balanceOf(msg.sender);

        //+-We Allow the S.C. to Spend Token Holder's Token Shares:_
        IERC20(_nftAddress).ERC20approve(msg.sender, claimerBalance);

        //+-We Transfer from the Claimers's Wallet to the Marketplace Smart Contract all his/her Token Shares:_
        IERC20(_nftAddress).ERC20transferFrom(
            msg.sender,
            address(this),
            claimerBalance
        );
        // Calculate the token price, how much the tokens are worth, the total, the platform fee and payout
        uint256 tokenprice = (NFTAddresstoBuyoutValueInOriginalDAOFiatToken[
            _nftAddress
        ] / OAMITOManagementContract.getItoShareSupply(_nftAddress));
        uint256 claimertokenvalue = claimerBalance * tokenprice;
        uint256 platformfee = (claimertokenvalue *
            OAMMContract.getSharesSalesPercPrice()) / 100;
        uint256 payout = claimertokenvalue - platformfee;
        /**+-We Transfer from the Marketplace S.C. to the Claimer's Wallet the Pay for his/her Token Shares less the Platform Fee:_*/
        IERC20(IOAMNFT(_nftAddress).getDAOFiatTokenAddress()).ERC20transferFrom(
                address(this),
                msg.sender,
                payout
            );

        /**+-We Transfer from the Marketplace S.C. to the Owner's Wallet the Pay for Fee for the Platform Fee:_*/
        IERC20(IOAMNFT(_nftAddress).getDAOFiatTokenAddress()).ERC20transferFrom(
                address(this),
                payable(_owner),
                platformfee
            );

        //+-Now that the Marketplace S.C. have all the Claimer's Token Shares, it can Burn them:_
        IERC20(_nftAddress)._ERC20burn(claimerBalance);
    }
}
