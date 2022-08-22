// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.4;

import "../../Libraries/Utils/Ownable.sol";
import "../../Libraries/Utils/Strings.sol";
import "../../Libraries/Utils/Counters.sol";
import "../Interfaces/IOAMarketManagement.sol";
import "../../Libraries/Utils/CollectableDust.sol";

contract OAMarketManagement is Ownable, IOAMarketManagement, CollectableDust {
    using Strings for uint256;
    //+-We enable the S.Contract to use the Struct "Counter" of the Counters Utils S.Contract:_
    using Counters for Counters.Counter;

    address public USDfiatTokenAddress;
    address public EURfiatTokenAddress;
    address public GBPfiatTokenAddress;
    address public NOKfiatTokenAddress;

    address public OAMUsersVerificationAddress;
    address public OAMDAOAddress;
    address public OAMITOManagementAddress;
    address public OAMNFTSalesAddress;
    address public OAMP2PMarketAddress;
    address public OAMEnglishAuctionsAddress;
    address public OAMDutchAuctionsAddress;

    //+-Register of the Addresses of all the S.C.s that are part of the Platform:_
    mapping(address => bool) internal isPlatformSC;

    event SharesSalesPercPriceChanged(uint256);
    //+-Listing Price:_ The Fee that the ArtWork Owner Pays in NOK Fiat Tokens for Listing a N.F.T. on the Platform:_
    uint256 listingPrice = 1;

    //+-Number of % of Fees that are charged by the MarketPlace S.C. to the ArtWorks Token Shares Sellers:_
    uint256 tokenSharesSalesPercFee = 12;

    constructor() {
        _owner = payable(msg.sender);
    }

    //+-MarketPlace Functionalities:_

    //+-Returns the Listing Price of the Smart Contract:_
    function getListingPrice() public view override returns (uint256) {
        return listingPrice;
    }

    //+-Sets the Listing Price of the Smart Contract in NOK Fiat Tokens:_
    function setListingPriceNOK(uint256 newPrice) public onlyOwner {
        listingPrice = newPrice;
    }

    //+-Gets the P2P Token Shares Market Sales Fee Price of the Smart Contract:_
    function getSharesSalesPercPrice() public view override returns (uint256) {
        return tokenSharesSalesPercFee;
    }

    //+-Sets the P2P Token Shares Market Sales Fee Price of the Smart Contract:_
    function setSharesSalesPercPrice(uint256 newPrice) public onlyOwner {
        require(newPrice < 21, "You cannot charge a fee >= 20%.");
        tokenSharesSalesPercFee = newPrice;
        emit SharesSalesPercPriceChanged(newPrice);
    }

    //+-Gets USD Fiat Token Address:_
    function getUSDTokenAddress() public view override returns (address) {
        return USDfiatTokenAddress;
    }

    //+-Platform Owner Sets a new Fiat Token Address if needed:_
    function setNewUSDTokenAddress(address newAddress) public onlyOwner {
        if (USDfiatTokenAddress != address(0)) {
            _removeProtocolToken(USDfiatTokenAddress);
        }
        USDfiatTokenAddress = newAddress;
        _addProtocolToken(USDfiatTokenAddress);
    }

    //+-Gets EUR Fiat Token Address:_
    function getEURTokenAddress() public view override returns (address) {
        return EURfiatTokenAddress;
    }

    //+-Platform Owner Sets a new Fiat Token Address if needed:_
    function setNewEURTokenAddress(address newAddress) public onlyOwner {
        if (EURfiatTokenAddress != address(0)) {
            _removeProtocolToken(EURfiatTokenAddress);
        }
        EURfiatTokenAddress = newAddress;
        _addProtocolToken(EURfiatTokenAddress);
    }

    //+-Gets GBP Fiat Token Address:_
    function getGBPTokenAddress() public view override returns (address) {
        return GBPfiatTokenAddress;
    }

    //+-Platform Owner Sets a new Fiat Token Address if needed:_
    function setNewGBPTokenAddress(address newAddress) public onlyOwner {
        if (GBPfiatTokenAddress != address(0)) {
            _removeProtocolToken(GBPfiatTokenAddress);
        }
        GBPfiatTokenAddress = newAddress;
        _addProtocolToken(GBPfiatTokenAddress);
    }

    //+-Gets NOK Fiat Token Address:_
    function getNOKTokenAddress() public view override returns (address) {
        return NOKfiatTokenAddress;
    }

    //+-Platform Owner Sets a new Fiat Token Address if needed:_
    function setNewNOKTokenAddress(address newAddress) public onlyOwner {
        if (NOKfiatTokenAddress != address(0)) {
            _removeProtocolToken(NOKfiatTokenAddress);
        }
        NOKfiatTokenAddress = newAddress;
        _addProtocolToken(NOKfiatTokenAddress);
    }

    //+-Only lets O.A.M. S.C.s to Interact with the O.A.M. Marketplace:_
    function onlyPlatformSCs(address addr) public view override returns (bool) {
        return isPlatformSC[addr];
    }

    //+-Gets OAMUsersVerificationAddress:_
    function getOAMUsersVerificationAddress()
        public
        view
        override
        returns (address)
    {
        return OAMUsersVerificationAddress;
    }

    //+-Platform Owner Sets a new OAMUsersVerification Address if needed:_
    function setNewOAMUVAddress(address newAddress)
        public
        onlyOwner
    {
        if (OAMUsersVerificationAddress != address(0)) {
            isPlatformSC[OAMUsersVerificationAddress] = false;
        }
        OAMUsersVerificationAddress = newAddress;
        isPlatformSC[OAMUsersVerificationAddress] = true;
    }

    //+-Gets OAMITOManagementAddress:_
    function getOAMITOManagementAddress()
        public
        view
        override
        returns (address)
    {
        return OAMITOManagementAddress;
    }

    //+-Platform Owner Sets a new OAMITOManagement Address if needed:_
    function setNewOAMITOManagementAddress(address newAddress) public onlyOwner {
        if (OAMITOManagementAddress != address(0)) {
            isPlatformSC[OAMITOManagementAddress] = false;
        }
        OAMITOManagementAddress = newAddress;
        isPlatformSC[OAMITOManagementAddress] = true;
    }

    //+-Gets OAMDAOAddress:_
    function getOAMDAOAddress() public view override returns (address) {
        return OAMDAOAddress;
    }

    //+-Platform Owner Sets a new OAMDAO Address if needed:_
    function setNewOAMDAOAddress(address newAddress) public onlyOwner {
        if (OAMDAOAddress != address(0)) {
            isPlatformSC[OAMDAOAddress] = false;
        }
        OAMDAOAddress = newAddress;
        isPlatformSC[OAMDAOAddress] = true;
    }

    //+-Gets OAMNFTSalesAddress:_
    function getOAMNFTSalesAddress() public view override returns (address) {
        return OAMNFTSalesAddress;
    }

    //+-Platform Owner Sets a new OAMNFTSales Address if needed:_
    function setNewOAMNFTSalesAddress(address newAddress) public onlyOwner {
        if (OAMNFTSalesAddress != address(0)) {
            isPlatformSC[OAMNFTSalesAddress] = false;
        }
        OAMNFTSalesAddress = newAddress;
        isPlatformSC[OAMNFTSalesAddress] = true;
    }

    //+-Gets OAMEnglishAuctionsAddress:_
    function getOAMEnglishAuctionsAddress()
        public
        view
        override
        returns (address)
    {
        return OAMEnglishAuctionsAddress;
    }

    //+-Platform Owner Sets a new OAMEnglishAuctions Address if needed:_
    function setNewOAMEnglishAuctionsAddress(address newAddress) public onlyOwner {
        if (OAMEnglishAuctionsAddress != address(0)) {
            isPlatformSC[OAMEnglishAuctionsAddress] = false;
        }
        OAMEnglishAuctionsAddress = newAddress;
        isPlatformSC[OAMEnglishAuctionsAddress] = true;
    }

    //+-Gets OAMDutchAuctionsAddress:_
    function getOAMDutchAuctionsAddress()
        public
        view
        override
        returns (address)
    {
        return OAMDutchAuctionsAddress;
    }

    //+-Platform Owner Sets a new OAMDutchAuctions Address if needed:_
    function setNewOAMDutchAuctionsAddress(address newAddress) public onlyOwner {
        if (OAMDutchAuctionsAddress != address(0)) {
            isPlatformSC[OAMDutchAuctionsAddress] = false;
        }
        OAMDutchAuctionsAddress = newAddress;
        isPlatformSC[OAMDutchAuctionsAddress] = true;
    }

    //+-Gets OAMP2PMarketAddresss:_
    function getOAMP2PMarketAddress() public view override returns (address) {
        return OAMP2PMarketAddress;
    }

    //+-Platform Owner Sets a new OAMP2PMarket Address if needed:_
    function setNewOAMP2PMarketAddress(address newAddress) public onlyOwner {
        if (OAMP2PMarketAddress != address(0)) {
            isPlatformSC[OAMP2PMarketAddress] = false;
        }
        OAMP2PMarketAddress = newAddress;
        isPlatformSC[OAMP2PMarketAddress] = true;
    }

    //+-Platform Owner can Safely Return UnWanted Tokens that were sent to the S.C. by Mistake by some User:_
    function sendDustTokensBack(
        address _to,
        address _token,
        uint256 _amount
    ) public onlyOwner {
        _sendDust(_to, _token, _amount);
    }
}
