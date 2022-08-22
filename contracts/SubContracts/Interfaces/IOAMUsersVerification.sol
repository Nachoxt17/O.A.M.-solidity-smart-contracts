// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.4;

interface IOAMUsersVerification {
    //+-ERC-884 Standard Events:_

    /**
     *  This event is emitted when a verified address and associated identity hash are
     *  added to the contract.
     *  @param addr The address that was added.
     *  @param hash The identity hash associated with the address.
     *  @param sender The address that caused the address to be added.
     */
    event VerifiedAddressAdded(
        address indexed addr,
        bytes32 hash,
        address indexed sender
    );

    /**
     *  This event is emitted when a verified address its associated identity hash are
     *  removed from the contract.
     *  @param addr The address that was removed.
     *  @param sender The address that caused the address to be removed.
     */
    event VerifiedAddressRemoved(address indexed addr, address indexed sender);

    /**
     *  This event is emitted when the identity hash associated with a verified address is updated.
     *  @param addr The address whose hash was updated.
     *  @param oldHash The identity hash that was associated with the address.
     *  @param hash The hash now associated with the address.
     *  @param sender The address that caused the hash to be updated.
     */
    event VerifiedAddressUpdated(
        address indexed addr,
        bytes32 oldHash,
        bytes32 hash,
        address indexed sender
    );

    /**
     *  This event is emitted when an address is cancelled and replaced with
     *  a new address.  This happens in the case where a shareholder has
     *  lost access to their original address and needs to have their share
     *  reissued to a new address.  This is the equivalent of issuing replacement
     *  share certificates.
     *  @param original The address being superseded.
     *  @param replacement The new address.
     *  @param sender The address that caused the address to be superseded.
     */
    event VerifiedAddressSuperseded(
        address indexed original,
        address indexed replacement,
        address indexed sender
    );

    //+-Events of the RegisteredUsers:_
    event UserRegistered(address _address);
    event UserRemoved(address _address);

    //+-ERC-884 Standard:_ Checks if an User Address have been Verified.
    function isVerified(address addr) external view returns (bool);

    //+-A Platform N.F.T. can read the ZERO_BYTES Value:_
    function getZERO_BYTES() external view returns (bytes32);

    //+-A Platform N.F.T. can read the ZERO_ADDRESS Value:_
    function getZERO_ADDRESS() external view returns (address);

    //+-ERC-884 Standard:_ Checks if an User Address have been Cancelled and Reissued.
    function isNotCancelled(address addr) external view returns (bool);

    //+-Only lets O.A.M. N.F.T.s to Interact with the O.A.M. Marketplace:_
    function onlyPlatformNFTs(address addr) external view returns (bool);

    //+-Only lets O.A.M. N.F.T.s or Owner to Interact with the O.A.M. Marketplace:_
    function onlyOwnerOrNFT(address addr) external view returns (bool);
    
    //+-Only lets Server or Owner to Interact with the O.A.M. Marketplace:_
    function onlyOwnerOrServer(address addr) external view returns (bool);
    
    //+-Only lets O.A.M. N.F.T.s, Server or Owner to Interact with the O.A.M. Marketplace:_
    function onlyOwnerServerOrNFT(address addr) external view returns (bool);
    
    //+-Only lets Admin, Server or Owner to Interact with the O.A.M. Marketplace:_
    function onlyOwnerServerOrAdmin(address addr) external view returns (bool);

    /**
     *  Gets the most recent address, given a superseded one.
     *  Addresses may be superseded multiple times, so this function needs to
     *  follow the chain of addresses until it reaches the final, verified address.
     *  @param addr The superseded address.
     *  @return the verified address that ultimately holds the share.
     */
    function getCurrentFor(address addr) external view returns (address);

    //+-Platform Owner or a Platform N.F.T. can Set a Verified User Hash:_
    function setVerifiedUserHash(address _addr, bytes32 _hash) external;

    //+-Platform Owner or a Platform N.F.T. can Set a Verified User Hash:_
    function setCancelledUserAddress(address _original, address _replacement)
        external;

    //+-N.F.T. S.C.s can emit the VerifiedAddressSuperseded Event:_
    function emitVerifiedAddressSuperseded(
        address _original,
        address _replacement,
        address _sender
    ) external;
}
