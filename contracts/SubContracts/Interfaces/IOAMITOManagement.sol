// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.4;

interface IOAMITOManagement {
    /**
    @dev Events of the ITO Management Contract
    */
    event StartITO(address _address);
    event Transfer(address _address, address _receiver, uint256 _amount);
    event EndITO(address _address);

    //+-Get the Token Share Price of the ArtWork N.F.T. at the time of the I.T.O.:_
    function getItoSharePrice(address _nftAddress)
        external
        view
        returns (uint256);

    //+-Get the Token Shares Total Supply of the ArtWork N.F.T.:_
    function getItoShareSupply(address _nftAddress)
        external
        view
        returns (uint256);

    //+-Get the Token Shares of the ArtWork N.F.T. available at the I.T.O.:_
    function getItoInitialAvailableShares(address _nftAddress)
        external
        view
        returns (uint256);

    //+-Know if the I.T.O. of an ArtWork N.F.T. has already started or not:_
    function getItoStarted(address _nftAddress) external view returns (bool);

    //+-Know if the I.T.O. of an ArtWork N.F.T. has already ended or not:_
    function getItoEnded(address _nftAddress) external view returns (bool);

    //+-Know if the Transctions of an ArtWork N.F.T. Shares are Frozen or not:_
    function getIsFreezedAfterITO(address _nftAddress)
        external
        view
        returns (bool);

    function getNFTValue(address _nftAddress) external view returns (uint256);
}
