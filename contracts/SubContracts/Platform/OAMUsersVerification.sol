// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.4;

import "../../Libraries/Utils/Ownable.sol";
import "../../Libraries/Utils/Strings.sol";
import "../../Libraries/Utils/Counters.sol";
import "../Interfaces/IOAMUsersVerification.sol";

contract OAMUsersVerification is Ownable, IOAMUsersVerification {
    using Strings for uint256;
    //+-We enable the S.Contract to use the Struct "Counter" of the Counters Utils S.Contract:_
    using Counters for Counters.Counter;

    //+-ERC-884 Standard Parameters:_
    bytes32 internal constant ZERO_BYTES = bytes32(0);
    address internal constant ZERO_ADDRESS = address(0);

    mapping(address => bool) internal server;
    mapping(address => bool) internal admin;
    mapping(address => bytes32) internal verified;
    mapping(address => address) internal cancellations;

    Counters.Counter public _registeredUsersAmount;

    //+-Register of the Addresses of all the N.F.T.s that are part of the Platform:_
    mapping(address => bool) internal isPlatformNFT;

    event serverAdded(address addr, address sender);
    event serverRemoved(address addr, address sender);
    event adminAdded(address addr, address sender);
    event adminRemoved(address addr, address sender);

    constructor() {
        _owner = payable(msg.sender);
        addVerified(_owner);
    }

    /**
     *  Tests that the supplied address is known to the contract.
     *  @param addr The address to test.
     *  @return true if the address is known to the contract.
     */
    //+-ERC-884 Standard:_ Checks if an User Address have been Verified.
    function isVerified(address addr) public view override returns (bool) {
        return verified[addr] != ZERO_BYTES;
    }

    function isServer(address addr) public view returns (bool) {
        return server[addr];
    }

    function isAdmin(address addr) public view returns (bool) {
        return admin[addr];
    }

    //+-ERC-884 Standard:_ Checks if an User Address have been Cancelled and Reissued.
    function isNotCancelled(address addr) public view override returns (bool) {
        return cancellations[addr] == ZERO_ADDRESS;
    }

    //+-Only lets O.A.M. N.F.T.s to Interact with the O.A.M. Marketplace:_
    function onlyPlatformNFTs(address addr)
        public
        view
        override
        returns (bool)
    {
        return isPlatformNFT[addr];
    }

    //+-Only lets O.A.M. N.F.T.s or Owner to Interact with the O.A.M. Marketplace:_
    function onlyOwnerOrNFT(address addr) public view override returns (bool) {
        if (isPlatformNFT[addr] == true) {
            return true;
        } else {
            return owner() == addr;
        }
    }

    //+-Only lets Server or Owner to Interact with the O.A.M. Marketplace:_
    function onlyOwnerOrServer(address addr)
        public
        view
        override
        returns (bool)
    {
        if (server[addr] == true) {
            return true;
        } else {
            return owner() == addr;
        }
    }

    //+-Only lets O.A.M. N.F.T.s, Server or Owner to Interact with the O.A.M. Marketplace:_
    function onlyOwnerServerOrNFT(address addr)
        public
        view
        override
        returns (bool)
    {
        if (isPlatformNFT[addr] == true) {
            return true;
        } else if (server[addr] == true) {
            return true;
        } else {
            return owner() == addr;
        }
    }

    //+-Only lets O.A.M. N.F.T.s, Server, Admin or Owner to Interact with the O.A.M. Marketplace:_
    function onlyOwnerServerOrAdmin(address addr)
        public
        view
        override
        returns (bool)
    {
        if (server[addr] == true) {
            return true;
        } else if (admin[addr] == true) {
            return true;
        } else {
            return owner() == addr;
        }
    }

    /**
     *  Checks that the supplied hash is associated with the given address.
     *  @param addr The address to test.
     *  @param _hash The hash to test.
     *  @return true if the hash matches the one supplied with the address in `addVerified`, or `updateVerified`.
     */
    function hasHash(address addr, bytes32 _hash) public view returns (bool) {
        if (addr == ZERO_ADDRESS) {
            return false;
        }
        return verified[addr] == _hash;
    }

    /**
     *  Checks to see if the supplied address was superseded.
     *  @param addr The address to check.
     *  @return true if the supplied address was superseded by another address.
     */
    function isSuperseded(address addr) public view returns (bool) {
        return cancellations[addr] != ZERO_ADDRESS;
    }

    //+-N.F.T. S.C.s can emit the VerifiedAddressSuperseded Event:_
    function emitVerifiedAddressSuperseded(
        address _original,
        address _replacement,
        address _sender
    ) public override {
        require(onlyOwnerOrNFT(msg.sender), "Only Platform N.F.T.s.");
        emit VerifiedAddressSuperseded(_original, _replacement, _sender);
    }

    /**
     *  Gets the most recent address, given a superseded one.
     *  Addresses may be superseded multiple times, so this function needs to
     *  follow the chain of addresses until it reaches the final, verified address.
     *  @param addr The superseded address.
     *  @return the verified address that ultimately holds the share.
     */
    function getCurrentFor(address addr)
        public
        view
        override
        returns (address)
    {
        address candidate = cancellations[addr];
        if (candidate == ZERO_ADDRESS) {
            return addr;
        }
        return getCurrentFor(candidate);
    }

    //+-The Platform Owner can Register an Server:_
    /**
     *  Add a server address to the contract.
     *  Upon successful addition of a server address, the contract must emit
     *  `serverAddressAdded(addr,  msg.sender)`.
     *  It MUST throw if the supplied address is zero,
     *  @param addr The address of the server
     */
    function addServer(address addr) public onlyOwner {
        require(addr != ZERO_ADDRESS);
        server[addr] = true;
        emit serverAdded(addr, msg.sender);
    }

    //+-The Platform Owner can Delete a Server:_
    /**
     *  Remove a server address. If the address is
     *  unknown to the contract then this does nothing. If the address is successfully removed, this
     *  function must emit `VerifiedAddressRemoved(addr, msg.sender)`.
     *  @param addr The verified address to be removed.
     */
    function removeServer(address addr) public onlyOwner {
        if (server[addr] == true) {
            server[addr] = false;
            emit serverRemoved(addr, msg.sender);
        }
    }

    /**
     *  Add a Admin address to the contract and creates an associated verification hash .
     *  Upon successful addition of a Admin address, the contract must emit
     *  `adminAddressAdded(addr,  msg.sender)`.
     *  It MUST throw if the supplied address is zero,
     *  @param addr The address of the Admin
     */
    function addAdmin(address addr) public onlyOwner {
        admin[addr] = true;
        addVerified(addr);
        emit adminAdded(addr, msg.sender);
    }

    //+-The Platform Owner can Delete a Admin:_
    /**
     *  Remove a Admin address. If the address is
     *  unknown to the contract then this does nothing. If the address is successfully removed, this
     *  function must emit `VerifiedAddressRemoved(addr, msg.sender)`.
     *  @param addr The verified address to be removed.
     */
    function removeAdmin(address addr) public onlyOwner {
        if (admin[addr] == true) {
            admin[addr] = false;
            removeVerified(addr);
            emit adminRemoved(addr, msg.sender);
        }
    }

    //+-The Platform Owner can Register an User who passed the K.Y.C. Process:_
    /**
     *  Add a verified address to the contract and creates an associated verification hash .
     *  Upon successful addition of a verified address, the contract must emit
     *  `VerifiedAddressAdded(addr, hash, msg.sender)`.
     *  It MUST throw if the supplied address or hash are zero, or if the address has already been supplied.
     *  @param addr The address of the person represented by the supplied hash.
     */
    function addVerified(address addr) public {
        require(
            onlyOwnerServerOrAdmin(msg.sender),
            "Only Owner, Server or Admin can perform this action"
        );
        bytes32 userHash = keccak256(
            abi.encodePacked(block.timestamp, block.difficulty, addr)
        );
        require(addr != ZERO_ADDRESS);
        require(userHash != ZERO_BYTES);
        // We should allow re-entry
        // require(verified[addr] == ZERO_BYTES);
        verified[addr] = userHash;
        _registeredUsersAmount.increment();
        emit VerifiedAddressAdded(addr, userHash, msg.sender);
    }

    //+-The Platform Owner can Delete a Registered User:_
    /**
     *  Remove a verified address, and the associated verification hash. If the address is
     *  unknown to the contract then this does nothing. If the address is successfully removed, this
     *  function must emit `VerifiedAddressRemoved(addr, msg.sender)`.
     *  It MUST throw if an attempt is made to remove a verifiedAddress that owns Tokens.
     *  @param addr The verified address to be removed.
     */
    function removeVerified(address addr) public {
        require(
            onlyOwnerServerOrAdmin(msg.sender),
            "Only Owner, Server or Admin can perform this action"
        );
        if (verified[addr] != ZERO_BYTES) {
            verified[addr] = ZERO_BYTES;
            _registeredUsersAmount.decrement();
            emit VerifiedAddressRemoved(addr, msg.sender);
        }
    }

    /**
     *  Update the hash for a verified address known to the contract.
     *  Upon successful update of a verified address the contract must emit
     *  `VerifiedAddressUpdated(addr, oldHash, hash, msg.sender)`.
     *  If the hash is the same as the value already stored then
     *  no `VerifiedAddressUpdated` event is to be emitted.
     *  It MUST throw if the hash is zero, or if the address is unverified.
     *  @param addr The verified address of the person represented by the supplied hash.
     *  @param hash A new cryptographic hash of the address holder's updated verified information.
     */

    function updateVerified(address addr, bytes32 hash) public {
        require(
            onlyOwnerOrServer(msg.sender),
            "Only Owner or Server can perform this action"
        );
        require(hash != ZERO_BYTES);
        bytes32 oldHash = verified[addr];
        if (oldHash != hash) {
            verified[addr] = hash;
            emit VerifiedAddressUpdated(addr, oldHash, hash, msg.sender);
        }
    }

    //+-A Platform N.F.T. can read the ZERO_BYTES Value:_
    function getZERO_BYTES() public pure override returns (bytes32) {
        return ZERO_BYTES;
    }

    //+-A Platform N.F.T. can read the ZERO_ADDRESS Value:_
    function getZERO_ADDRESS() public pure override returns (address) {
        return ZERO_ADDRESS;
    }

    //+-Returns the Amount of Voters of the Platform:_
    function getUsersAmount() public view returns (uint256) {
        return _registeredUsersAmount.current();
    }

    //+-The Platform Owner/N.F.T. can Know a Verified User Hash:_
    function getVerifiedUserHash(address addr) public view returns (bytes32) {
        require(
            onlyOwnerServerOrNFT(msg.sender),
            "Only Owner, Server or NFT can perform this function"
        );
        return verified[addr];
    }

    //+-Platform Owner or a Platform N.F.T. can Set a Verified User Hash:_
    function setVerifiedUserHash(address _addr, bytes32 _hash) public override {
        require(
            onlyOwnerServerOrNFT(msg.sender),
            "Only Owner, Server or NFT can perform this function"
        );
        verified[_addr] = _hash;
    }

    //+-The Platform Owner/N.F.T. can Know a Cancelled User Address:_
    function getCancelledUserAddress(address addr)
        public
        view
        returns (address)
    {
        require(
            onlyOwnerServerOrNFT(msg.sender),
            "Only Owner, Server or NFT can perform this function"
        );
        return cancellations[addr];
    }

    //+-The Platform Owner or a Platform N.F.T. can Set a Verified User Cancelled and New Address:_
    function setCancelledUserAddress(address _original, address _replacement)
        public
        override
    {
        require(
            onlyOwnerServerOrNFT(msg.sender),
            "Only Owner, Server or NFT can perform this function"
        );
        cancellations[_original] = _replacement;
    }

    //+-The Platform Owner can Add an Address of a New ArtWork N.F.T. Created in the Platform:_
    function addPlatformNFT(address _nftAddress) public {
        require(
            onlyOwnerOrServer(msg.sender),
            "Only Owner or Server can perform this function"
        );
        isPlatformNFT[_nftAddress] = true;
    }
}
