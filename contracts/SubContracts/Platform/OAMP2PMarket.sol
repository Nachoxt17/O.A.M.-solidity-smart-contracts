// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.4;

import "../../Libraries/Utils/Ownable.sol";
import "../../Libraries/Utils/Strings.sol";
import "../../Libraries/Utils/Counters.sol";
import "../../Libraries/Utils/ReentrancyGuard.sol";
import "../../Libraries/Interfaces/IERC20.sol";
import "../Interfaces/IOAMUsersVerification.sol";
import "../Interfaces/IOAMarketManagement.sol";
import "../Interfaces/IOAMITOManagement.sol";
import "../Interfaces/IOAMNFT.sol";
import "../Interfaces/IOAMDAO.sol";
import "../Interfaces/IOAMNFTSales.sol";

contract OAMP2PMarket is Ownable, ReentrancyGuard {
    using Strings for uint256;
    //+-We enable the S.Contract to use the Struct "Counter" of the Counters Utils S.Contract:_
    using Counters for Counters.Counter;
    //+-Market P2P Parameters:_
    Counters.Counter internal _offerIds;
    Counters.Counter internal _openOffers;
    Counters.Counter internal _FinishedOffers;

    enum TypeOfTrade {
        SELL,
        BUY
    }

    address public OAMUsersVerificationAddress;
    IOAMUsersVerification OAMUVContract =
        IOAMUsersVerification(OAMUsersVerificationAddress);
    address public OAMarketManagementAddress;
    IOAMarketManagement OAMMContract =
        IOAMarketManagement(OAMarketManagementAddress);
    address public OAMDAOAddress;
    IOAMDAO OAMDAOContract = IOAMDAO(OAMDAOAddress);
    address public OAMITOManagementAddress;
    IOAMITOManagement OAMITOManagementContract =
        IOAMITOManagement(OAMITOManagementAddress);
    address public OAMNFTSalesAddress;
    IOAMNFTSales OAMNFTSalesContract = IOAMNFTSales(OAMNFTSalesAddress);

    //+-Struct (Data Structure) of every Sell/Buy Offer in the Marketplace:_
    struct TokenShareTradeOffer {
        uint256 offerId;
        TypeOfTrade typeOfTrade;
        address payable _offerCreator;
        address assetAddress;
        uint256 assetAmount;
        uint256 pricePerToken;
        bool sold;
    }

    //+-Mapping in which you Give an Offer ID and you receive that Offer Struct:_
    mapping(uint256 => TokenShareTradeOffer) internal idToTokenShareTradeOffer;

    //+-Event that is triggered every time an Offer in the P2P Market is Created, this is useful to execute things in the Front-End:_
    event TradeOfferCreated(
        uint256 indexed offerId,
        address indexed assetAddress,
        address _offerCreator,
        TypeOfTrade typeOfTrade,
        uint256 assetAmount,
        uint256 pricePerToken,
        bool sold
    );

    function setNewOAMUVAddress(address _addr) public onlyOwner {
        OAMUsersVerificationAddress = _addr;
        OAMUVContract = IOAMUsersVerification(OAMUsersVerificationAddress);
    }

    function setNewOAMMAddress(address _addr) public onlyOwner {
        OAMarketManagementAddress = _addr;
        OAMMContract = IOAMarketManagement(OAMarketManagementAddress);
    }

    function setNewOAMDAOAddress(address _addr) public onlyOwner {
        OAMDAOAddress = _addr;
        OAMDAOContract = IOAMDAO(OAMDAOAddress);
    }

    function setNewOAMITOManagementAddress(address _addr) public onlyOwner {
        OAMITOManagementAddress = _addr;
        OAMITOManagementContract = IOAMITOManagement(OAMITOManagementAddress);
    }

    function setNewOAMNFTSalesAddress(address _addr) public onlyOwner {
        OAMNFTSalesAddress = _addr;
        OAMNFTSalesContract = IOAMNFTSales(OAMNFTSalesAddress);
    }

    //+-Any Verified User can make an offer to Sell Token Shares for the N.F.T. D.A.O. Default Fiat Token in the P2P Market:_
    function placeSellOffer(
        address _tokenShareAsset,
        uint256 _assetAmount,
        uint256 _pricePerToken
    ) public nonReentrant {
        require(OAMUVContract.isVerified(msg.sender), "Not a Verified User.");
        require(
            OAMITOManagementContract.getIsFreezedAfterITO(_tokenShareAsset) ==
                false,
            "Token Shares Freezed after I.T.O."
        );
        IERC20(_tokenShareAsset).ERC20approve(address(this), _assetAmount);
        IERC20(_tokenShareAsset).ERC20transferFrom(
            msg.sender,
            address(this),
            _assetAmount
        );

        _offerIds.increment();
        uint256 sellOfferId = _offerIds.current();
        _openOffers.increment();

        idToTokenShareTradeOffer[sellOfferId] = TokenShareTradeOffer(
            sellOfferId,
            TypeOfTrade.SELL,
            payable(msg.sender),
            _tokenShareAsset,
            _assetAmount,
            _pricePerToken,
            false
        );

        emit TradeOfferCreated(
            sellOfferId,
            _tokenShareAsset,
            msg.sender,
            TypeOfTrade.SELL,
            _assetAmount,
            _pricePerToken,
            false
        );
    }

    //+-Any Verified User can make an offer to Buy Token Shares in the P2P Market:_
    function placeBuyOffer(
        address _tokenShareAsset,
        uint256 _assetAmount,
        uint256 _pricePerToken
    ) public nonReentrant {
        require(OAMUVContract.isVerified(msg.sender), "Not a Verified User.");
        require(
            OAMITOManagementContract.getIsFreezedAfterITO(_tokenShareAsset) ==
                false,
            "Token Shares Freezed after I.T.O."
        );
        IERC20(IOAMNFT(_tokenShareAsset).getDAOFiatTokenAddress()).ERC20approve(
                address(this),
                (_assetAmount * _pricePerToken)
            );
        IERC20(IOAMNFT(_tokenShareAsset).getDAOFiatTokenAddress())
            .ERC20transferFrom(
                msg.sender,
                address(this),
                _assetAmount * _pricePerToken
            );

        _offerIds.increment();
        uint256 buyOfferId = _offerIds.current();
        _openOffers.increment();

        idToTokenShareTradeOffer[buyOfferId] = TokenShareTradeOffer(
            buyOfferId,
            TypeOfTrade.BUY,
            payable(msg.sender),
            _tokenShareAsset,
            _assetAmount,
            _pricePerToken,
            false
        );

        emit TradeOfferCreated(
            buyOfferId,
            _tokenShareAsset,
            msg.sender,
            TypeOfTrade.BUY,
            _assetAmount,
            _pricePerToken,
            false
        );
    }

    //+-Any Verified User can Accept other User's offer to Sell Token Shares in the P2P Market(This User Will Buy):_
    function takeSellOffer(uint256 _sellOfferId, uint256 _assetAmount)
        public
        nonReentrant
    {
        require(OAMUVContract.isVerified(msg.sender), "Not a Verified User.");
        //+-We Allow the S.C. to Spend Buyer's Payment Tokens:_
        IERC20(
            IOAMNFT(idToTokenShareTradeOffer[_sellOfferId].assetAddress)
                .getDAOFiatTokenAddress()
        ).ERC20approve(
                address(this),
                (_assetAmount *
                    idToTokenShareTradeOffer[_sellOfferId].pricePerToken)
            );

        /**+-We Transfer from the Buyer's Wallet to the Sell Offer Creator the Pay
        for the Amount of Token Shares that the Buyer wants to Buy less the Platform Fees:_*/
        IERC20(
            IOAMNFT(idToTokenShareTradeOffer[_sellOfferId].assetAddress)
                .getDAOFiatTokenAddress()
        ).ERC20transferFrom(
                msg.sender,
                idToTokenShareTradeOffer[_sellOfferId]._offerCreator,
                (((_assetAmount *
                    idToTokenShareTradeOffer[_sellOfferId].pricePerToken) /
                    100) * (100 - OAMMContract.getSharesSalesPercPrice()))
            );

        /**+-We Transfer from the Buyer's Wallet to the Platform Owner the Fee for the Sale of Token Shares:_*/
        IERC20(
            IOAMNFT(idToTokenShareTradeOffer[_sellOfferId].assetAddress)
                .getDAOFiatTokenAddress()
        ).ERC20transferFrom(
                msg.sender,
                _owner,
                (((_assetAmount *
                    idToTokenShareTradeOffer[_sellOfferId].pricePerToken) /
                    100) * OAMMContract.getSharesSalesPercPrice())
            );

        idToTokenShareTradeOffer[_sellOfferId].assetAmount -= _assetAmount;
        if (idToTokenShareTradeOffer[_sellOfferId].assetAmount == 0) {
            idToTokenShareTradeOffer[_sellOfferId].sold = true;
            _openOffers.decrement();
            _FinishedOffers.increment();
        }

        /**+-We Transfer from the Smart Contract to the Buyer's Wallet the Amount of
        Token Shares that he/she bought:_*/
        IERC20(idToTokenShareTradeOffer[_sellOfferId].assetAddress)
            .ERC20transferFrom(address(this), msg.sender, _assetAmount);
    }

    //+-Any Verified User can Accept other User's offer to Buy Token Shares in the P2P Market(This User Will Sell):_
    function takeBuyOffer(uint256 _buyOfferId, uint256 _assetAmount)
        public
        nonReentrant
    {
        require(OAMUVContract.isVerified(msg.sender), "Not a Verified User.");
        //+-We Allow the S.C. to Spend Seller's Asset Tokens:_
        IERC20(idToTokenShareTradeOffer[_buyOfferId].assetAddress).ERC20approve(
                address(this),
                (_assetAmount)
            );

        /**+-We Transfer from the Seller's Wallet to the Buy Offer Creator the
        Amount of Token Shares that the Seller wants to Sell:_*/
        IERC20(idToTokenShareTradeOffer[_buyOfferId].assetAddress)
            .ERC20transferFrom(
                msg.sender,
                idToTokenShareTradeOffer[_buyOfferId]._offerCreator,
                _assetAmount
            );

        idToTokenShareTradeOffer[_buyOfferId].assetAmount -= _assetAmount;
        if (idToTokenShareTradeOffer[_buyOfferId].assetAmount == 0) {
            idToTokenShareTradeOffer[_buyOfferId].sold = true;
            _openOffers.decrement();
            _FinishedOffers.increment();
        }

        /**+-We Transfer from the Smart Contract to the Sellers's Wallet the Pay
        for the Amount of Token Shares that he/she sold less the Platform Fee:_*/
        IERC20(
            IOAMNFT(idToTokenShareTradeOffer[_buyOfferId].assetAddress)
                .getDAOFiatTokenAddress()
        ).ERC20transferFrom(
                address(this),
                msg.sender,
                (((_assetAmount *
                    idToTokenShareTradeOffer[_buyOfferId].pricePerToken) /
                    100) * (100 - OAMMContract.getSharesSalesPercPrice()))
            );

        /**+-We Transfer from the Smart Contract to the Platform Owner the Fee for the Sale of Token Shares:_*/
        IERC20(
            IOAMNFT(idToTokenShareTradeOffer[_buyOfferId].assetAddress)
                .getDAOFiatTokenAddress()
        ).ERC20transferFrom(
                address(this),
                _owner,
                (((_assetAmount *
                    idToTokenShareTradeOffer[_buyOfferId].pricePerToken) /
                    100) * OAMMContract.getSharesSalesPercPrice())
            );
    }

    //+-Users can Call this when they want to Withdraw an Offer that they Placed:_
    function withdrawOffer(uint256 _offerId, bool buyOrSell)
        public
        nonReentrant
    {
        require(OAMUVContract.isVerified(msg.sender), "Not a Verified User.");
        require(
            msg.sender == idToTokenShareTradeOffer[_offerId]._offerCreator,
            "Only Offer Creator can do this."
        );

        /**+-If the Offer was for Selling Token Shares, the User gets its Token Shares back, otherwise
        if it was a Buy Offer the User gets its Payment Tokens back:_.*/
        if (buyOrSell == false) {
            IERC20(idToTokenShareTradeOffer[_offerId].assetAddress)
                .ERC20approve(
                    address(this),
                    idToTokenShareTradeOffer[_offerId].assetAmount
                );
            IERC20(idToTokenShareTradeOffer[_offerId].assetAddress)
                .ERC20transferFrom(
                    address(this),
                    idToTokenShareTradeOffer[_offerId]._offerCreator,
                    idToTokenShareTradeOffer[_offerId].assetAmount
                );
        } else if (buyOrSell == true) {
            IERC20(
                IOAMNFT(idToTokenShareTradeOffer[_offerId].assetAddress)
                    .getDAOFiatTokenAddress()
            ).ERC20approve(
                    address(this),
                    (idToTokenShareTradeOffer[_offerId].assetAmount *
                        idToTokenShareTradeOffer[_offerId].pricePerToken)
                );
            IERC20(
                IOAMNFT(idToTokenShareTradeOffer[_offerId].assetAddress)
                    .getDAOFiatTokenAddress()
            ).ERC20transferFrom(
                    address(this),
                    idToTokenShareTradeOffer[_offerId]._offerCreator,
                    (idToTokenShareTradeOffer[_offerId].assetAmount *
                        idToTokenShareTradeOffer[_offerId].pricePerToken)
                );
        }

        delete idToTokenShareTradeOffer[_offerId];
        _openOffers.decrement();
    }

    //+-Returns all the UnFulfilled P2P Market Trade Offers:_
    function fetchP2PMarketOffers()
        public
        view
        returns (TokenShareTradeOffer[] memory)
    {
        uint256 offerCount = _openOffers.current() + 1;
        uint256 currentIndex = 0;

        TokenShareTradeOffer[] memory offers = new TokenShareTradeOffer[](
            offerCount
        );
        for (uint256 i = 0; i < offerCount; i++) {
            uint256 currentId = i + 1;
            TokenShareTradeOffer
                storage currentOffer = idToTokenShareTradeOffer[currentId];
            offers[currentIndex] = currentOffer;
            currentIndex += 1;
        }
        return offers;
    }
}
