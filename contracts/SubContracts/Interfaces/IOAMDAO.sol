// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.4;

interface IOAMDAO {
    //+-Events of the D.A.O.:_
    event VoterRegistered(address nftAddress, address voterAddress);
    event VoterRemoved(address nftAddress, address voterAddress);
    event ProposalsRegistrationStarted(address nftAddress);
    event ProposalsRegistrationEnded(address nftAddress);
    event ProposalRegistered(address nftAddress, uint256 proposalId);
    event ProposalRemoved(address nftAddress, uint256 proposalId);
    event VotingTime(address nftAddress, uint256 _days);
    event VotingSessionStarted(address nftAddress);
    event VotingSessionEnded(address nftAddress);
    event Voted(address nftAddress, address voter, uint256 proposalId);
    event VotesTallied(address nftAddress, uint256 winningProposals);
    event ProposalReachedMajority(address nftAddress, uint256 proposalId);
    event NoProposalReachedMajority(address nftAddress, uint256 proposalId); //+-Event for when Any Proposal reached the neccesary 50,1% Votes needed.

    function isShareholder(address nftAddr, address userAddr)
        external
        view
        returns (bool);

    function isNotShareholder(address nftAddr, address userAddr)
        external
        view
        returns (bool);

    function allowListed(address nftAddr, address userAddr)
        external
        view
        returns (bool);

    /**
     *  Cancel the original address and reissue the Tokens to the replacement address.
     *  Access to this function MUST be strictly controlled.  ONLY the Owner of the Platform can do this.
     *  The `original` address MUST be removed from the set of verified addresses.
     *  Throw if the `original` address supplied is not a shareholder.
     *  Throw if the replacement address is not a verified address.
     *  This function MUST emit the `VerifiedAddressSuperseded` event.
     *  original:_ The address to be superseded. This address MUST NOT be reused.
     *  replacement:_ The address  that supersedes the original. This address MUST be verified.
     */
    function cancelAndReissue(
        address _nftAddress,
        address original,
        address replacement
    ) external;

    function addVoter(address _nftAddress, address _addr) external;

    //+-Delete a Voter who is a Token Holder from a D.A.O.. ONLY the Owner of the Platform can do this:_
    function deleteVoter(address _nftAddress, address addr) external;

    /**
     *  The number of addresses that own tokens.
     *  return:_ the number of unique addresses that own tokens.
     */
    function holderCount(address _nftAddress) external view returns (uint256);

    /**
     *  By counting the number of token holders using `holderCount`
     *  you can retrieve the complete list of token holders, one at a time.
     *  It MUST throw if `index >= holderCount()`.
     *  index:_ The zero-based index of the holder.
     *  return:_ the address of the token holder with the given index.
     */
    function holderAt(address _nftAddress, uint256 index)
        external
        view
        returns (address);

    //+-Returns the Voters of the D.A.O.:_
    function getVoters(address _nftAddress)
        external
        view
        returns (address[] memory);

    //+-This is activated to inform that a BuyOut of an ArtWork N.F.T. has happened:_
    function buyOutTookPlace(address _nftAddress) external;

    //+-Know if the BuyOut of an ArtWork N.F.T. has happened or not:_
    function getBuyOutTookPlace(address _nftAddress)
        external
        view
        returns (bool);

    /**
     *  If the address is not in the `shareholders` array then push it
     *  and update the `holderIndices` mapping.
     *  _user:_ The address to add as a shareholder if it's not already.
     */
    function updateShareholders(address _nftAddress, address _user) external;

    /**
     *  If the address is in the `shareholders` array and the forthcoming
     *  transfer or transferFrom will reduce their balance to 0, then
     *  we need to remove them from the shareholders array.
     *  param _user The address to prune if their balance will be reduced to 0.
    @  dev see https://ethereum.stackexchange.com/a/39311
     */
    function pruneShareholders(address _nftAddress, address _user) external;
}
