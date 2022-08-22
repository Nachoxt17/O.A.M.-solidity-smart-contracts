// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.4;

//+-Interface for  N.F.T. & D.A.O. Smart Contract to Access to the Functionalities of the Marketplace:_
interface IOAMarketManagement {
    //+-Returns the Listing Price of the Smart Contract:_
    function getListingPrice() external view returns (uint256);

    //+-Gets the P2P Token Shares Market Sales Fee Price of the Smart Contract:_
    function getSharesSalesPercPrice() external view returns (uint256);

    //+-Gets USD Fiat Token Address:_
    function getUSDTokenAddress() external view returns (address);

    //+-Gets EUR Fiat Token Address:_
    function getEURTokenAddress() external view returns (address);

    //+-Gets GBP Fiat Token Address:_
    function getGBPTokenAddress() external view returns (address);

    //+-Gets NOK Fiat Token Address:_
    function getNOKTokenAddress() external view returns (address);

    //+-Only lets O.A.M. S.C.s to Interact with the O.A.M. Marketplace:_
    function onlyPlatformSCs(address addr) external view returns (bool);

    //+-Gets OAMUsersVerificationAddress:_
    function getOAMUsersVerificationAddress() external view returns (address);

    //+-Gets OAMDAOAddress:_
    function getOAMDAOAddress() external view returns (address);

    //+-Gets OAMITOManagementAddress:_
    function getOAMITOManagementAddress() external view returns (address);

    //+-Gets OAMNFTSalesAddress:_
    function getOAMNFTSalesAddress() external view returns (address);

    //+-Gets OAMP2PMarketAddresss:_
    function getOAMP2PMarketAddress() external view returns (address);

    //+-Gets OAMEnglishAuctionsAddress:_
    function getOAMEnglishAuctionsAddress() external view returns (address);

    //+-Gets OAMDutchAuctionsAddress:_
    function getOAMDutchAuctionsAddress() external view returns (address);
}
