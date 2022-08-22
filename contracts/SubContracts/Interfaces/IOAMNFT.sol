// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.4;

//+-Interface for the MarketPlace Smart Contract to Access to the Functionalities of any "O.A.M.N.F.T.andD.A.O.":_
interface IOAMNFT {
    //+-Returns the MetaData U.R.I. of the ArtWork:_
    function tokenURI() external view returns (string memory);

    //+-Get the Id of the ArtWork N.F.T.:_
    function getArtWorkId() external view returns (uint256);

    //+-Get the Owner's Address of the ArtWork N.F.T.:_
    function getArtWorkOwner() external view returns (address);

    //+-The MarketPlace S.C. can know which is the Default Fiat Currency Token of the D.A.O.:_
    function getDAOFiatTokenAddress() external view returns (address);
}
