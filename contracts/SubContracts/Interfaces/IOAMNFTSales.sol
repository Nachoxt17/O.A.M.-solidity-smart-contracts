// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.4;

interface IOAMNFTSales {
    //+-Event that is triggered every time an Item is Created, this is useful to execute things in the Front-End:_
    event MarketItemCreated(
        uint256 indexed itemId,
        address indexed nftContract,
        address seller,
        address owner,
        uint256 price,
        bool sold
    );

    event BuyOut(address nftAddress, uint256 price);
    event BuyOutPriceSet(address nftAddress);

    /**+-ArtWork N.F.T.s S.C.s or Platform Owner can set the Implied Value of the N.F.T..
    +-The Number must include 2 Decimals(Without the ",") and the Calculation of this Value is done Off-Chain:_*/
    function setNFTImpliedValueInOriginalDAOFiatToken(
        address _nftAddress,
        uint256 _impliedValueInOriginalDAOFiatToken
    ) external;

    function setNFTBuyoutValueInOriginalDAOFiatToken(
        address _nftAddress,
        uint256 _buyoutValueInOriginalDAOFiatToken
    ) external;

    //+-Get an ArtWork N.F.T. Implied Value in its Default Fiat Token:_
    function getNFTImpliedValueInOriginalDAOFiatToken(address _nftAddress)
        external
        view
        returns (uint256);

    //+-Get if an ArtWork N.F.T. is Currently on Sale:_
    function getNFTIsOnSale(address _nftAddress) external view returns (bool);

    //+-Get Current Item I.D.:_
    function getItemIds() external view returns (uint256);

    //+-Get MarketItem Price:_
    function getItemPrice(uint256 itemId) external view returns (uint256);

    //+-Increment Current Item I.D.:_
    function incrementItemIds() external;

    //+-Decrease Current Item I.D.:_
    function decreaseItemIds() external;

    //+-Create a New MarketItem Struct from External S.C.s.
    function setMarketItem(
        uint256 itemId,
        address _nftAddress,
        address seller,
        address owner,
        uint256 startingPrice
    ) external;

    //+-Get MarketItem FiatToken:_
    function getItemFiatToken(uint256 itemId) external view returns (address);

    //+-Set MarketItem New Owner:_
    function setItemNewOwner(uint256 itemId, address newOwner) external;

    //+-Set MarketItem Sold Status:_
    function setItemSoldStatus(uint256 itemId, bool sold) external;

    //+-Set MarketItem Sold-in-Auction Price:_
    function setItemPrice(uint256 itemId, uint256 price) external;

    //+-Get MarketItem Seller:_
    function getItemSeller(uint256 itemId) external view returns (address);

    //+-Delete MarketItem Struct:_
    function deleteMarketItem(uint256 itemId) external;

    //+-Set N.F.T. MarketItem I.D.:_
    function setNFTItemID(address _nftAddress, uint256 itemId) external;

    //+-Other S.C.s can Emit this Event:_
    function emitMarketItemCreated(
        uint256 itemId,
        address nftContract,
        address seller,
        address owner,
        uint256 price,
        bool sold
    ) external;

    //+-Increment Current Sold Items:_
    function incrementSoldItems() external;

    //+-Set If N.F.T. MarketItem Is On Sale or Not.:_
    function setNFTisOnSale(address _nftAddress, bool isOnSale) external;
}
