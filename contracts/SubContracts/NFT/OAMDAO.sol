// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.4;
import "hardhat/console.sol";
import "../../Libraries/Utils/Ownable.sol";
import "../../Libraries/Utils/Strings.sol";
import "../../Libraries/Utils/Counters.sol";
import "../Interfaces/IOAMUsersVerification.sol";
import "../Interfaces/IOAMarketManagement.sol";
import "../Interfaces/IOAMNFT.sol";
import "../Interfaces/IOAMDAO.sol";
import "../../Libraries/Interfaces/IERC20.sol";

contract OAMDAO is Ownable, IOAMDAO {
    using Strings for uint256;
    //+-We enable the S.Contract to use the Struct "Counter" of the Counters Utils S.Contract:_
    using Counters for Counters.Counter;

    //+-D.A.O. Parameters:_
    mapping(address => uint256) public winningProposalId;
    mapping(address => uint256) public votationStartTime;
    mapping(address => uint256) public defaultVotingTime;
    mapping(address => bool) public buyOutHappened;

    //+-Increment of I.D.s:_
    mapping(address => uint256) public proposalIds;
    mapping(address => uint256) public votersCount;

    //+-ERC884 Standard Parameters:_
    mapping(address => mapping(address => uint256)) internal holderIndices;

    mapping(address => address[]) internal shareholders;

    address public OAMEnglishAuctionAddress;
    address public OAMDutchAuctionAddress;
    address public OAMUsersVerificationAddress;
    IOAMUsersVerification OAMUVContract =
        IOAMUsersVerification(OAMUsersVerificationAddress);
    address public OAMarketManagementAddress; //+-THIS IS A MOCK ADDRESS.(Here you need to Insert the Real O.A.M. MarketPlace Smart Contract Address).
    IOAMarketManagement public OAMMContract =
        IOAMarketManagement(OAMarketManagementAddress);

    //+-Events of the D.A.O.:_
    event WorkflowStatusChange(
        address nftAddress,
        WorkflowStatus previousStatus,
        WorkflowStatus newStatus
    );

    struct Voter {
        bool isRegistered;
        address _address;
        bool hasVoted;
        uint256 votedProposalId;
    }

    struct Proposal {
        uint256 id;
        address owner;
        string description;
        uint256 voteCount;
    }

    mapping(address => mapping(address => Voter)) public AllowList;
    mapping(address => mapping(uint256 => Proposal)) public proposals;

    //+-States of the Votings in the D.A.O.:_
    enum WorkflowStatus {
        VotingStart,
        ProposalsRegistrationStarted,
        ProposalsRegistrationEnded,
        VotingSessionStarted,
        VotingSessionEnded,
        VotesTallied
    }

    mapping(address => WorkflowStatus) public status;

    function isShareholder(address nftAddr, address userAddr)
        public
        view
        override
        returns (bool)
    {
        return (holderIndices[nftAddr][userAddr] != 0);
    }

    function isNotShareholder(address nftAddr, address userAddr)
        public
        view
        override
        returns (bool)
    {
        return (holderIndices[nftAddr][userAddr] == 0);
    }

    function allowListed(address nftAddr, address userAddr)
        public
        view
        override
        returns (bool)
    {
        return (AllowList[nftAddr][userAddr].isRegistered);
    }

    function setNewOAMUVAddress(address _addr) public onlyOwner {
        OAMUsersVerificationAddress = _addr;
        OAMUVContract = IOAMUsersVerification(OAMUsersVerificationAddress);
    }

    function setNewOAMMAddress(address _addr) public onlyOwner {
        OAMarketManagementAddress = _addr;
        OAMMContract = IOAMarketManagement(OAMarketManagementAddress);
    }

    function setNewOAMEnglishAuctionsAddress(address _addr) public onlyOwner {
        OAMEnglishAuctionAddress = _addr;
    }

    function setNewOAMDutchAuctionsAddress(address _addr) public onlyOwner {
        OAMDutchAuctionAddress = _addr;
    }

    //+-ERC-884 Standard Functionalities:_

    /**
     *  If the address is not in the `shareholders` array then push it
     *  and update the `holderIndices` mapping.
     *  @param _user The address to add as a shareholder if it's not already.
     */
    function updateShareholders(address _nftAddress, address _user)
        public
        override
    {
        require(
            OAMMContract.onlyPlatformSCs(msg.sender) ||
            OAMUVContract.onlyPlatformNFTs(msg.sender),
            "Only Platform S.C. / NFT can do this."
        );
        if (holderIndices[_nftAddress][_user] == 0) {
            shareholders[_nftAddress].push(_user);
            holderIndices[_nftAddress][_user] = shareholders[_nftAddress]
                .length;
        }
    }

    /**
     *  Cancel the original address and reissue the Tokens to the replacement address.
     *  Access to this function MUST be strictly controlled.
     *  The `original` address MUST be removed from the set of verified addresses.
     *  Throw if the `original` address supplied is not a shareholder.
     *  Throw if the replacement address is not a verified address.
     *  This function MUST emit the `VerifiedAddressSuperseded` event.
     *  @param original The address to be superseded. This address MUST NOT be reused.
     *  @param replacement The address  that supersedes the original. This address MUST be verified.
     */
    function cancelAndReissue(
        address _nftAddress,
        address original,
        address replacement
    ) public override onlyOwner {
        require(
            isShareholder(_nftAddress, original),
            "Original is not a Share Holder."
        );
        require(
            isNotShareholder(_nftAddress, replacement),
            "Replacement is a Share Holder."
        );
        require(
            OAMUVContract.isVerified(replacement),
            "Replacement is not a Verified User."
        );
        OAMUVContract.setVerifiedUserHash(
            original,
            OAMUVContract.getZERO_BYTES()
        );
        OAMUVContract.setCancelledUserAddress(original, replacement);
        uint256 originalAddrBalance = IERC20(_nftAddress).ERC20balanceOf(
            original
        );
        /**+-The N.F.T. Token Shares Balance of the Cancelled Address cannot be Burn since the Function "_ERC20burn" can Only be Called
         * by the Address that Holds the Tokens to be Burn, and Neither can We Transfer to Our Wallet or S.C. those Tokens and then Burn
         * them since the Function "ERC20approve" also needs to be Called by the Address that Holds the Tokens. Anyways, this will not
         * affect the Implied Value of all the N.F.T. Token Shares since the Data used to Calculate it is the ITOSharesInitialSupply
         * Mapping in "OAMITOManagement", which is not Modified. The ERC-20 totalSupply does not matters for this purpose.*/
        deleteVoter(_nftAddress, original);
        IERC20(_nftAddress)._ERC20mint(
            msg.sender,
            replacement,
            originalAddrBalance
        );
        addVoter(_nftAddress, replacement);
        OAMUVContract.emitVerifiedAddressSuperseded(
            original,
            replacement,
            msg.sender
        );
    }

    /**
     *  If the address is in the `shareholders` array and the forthcoming
     *  transfer or transferFrom will reduce their balance to 0, then
     *  we need to remove them from the shareholders array.
     *  @param _user The address to prune if their balance will be reduced to 0.
    @  @dev see https://ethereum.stackexchange.com/a/39311
     */
    function pruneShareholders(address _nftAddress, address _user)
        public
        override
    {
        require(
            OAMMContract.onlyPlatformSCs(msg.sender) ||
            OAMUVContract.onlyOwnerServerOrNFT(msg.sender),
            "Only Platform S.C./Owner / Server can do this."
        );
        uint256 holderIndex = holderIndices[_nftAddress][_user] - 1;
        uint256 lastIndex = shareholders[_nftAddress].length - 1;
        address lastHolder = shareholders[_nftAddress][lastIndex];
        //+-Overwrite the addr's slot with the Last Shareholder:_
        shareholders[_nftAddress][holderIndex] = lastHolder;
        //+-Also Copy Over the Index:_
        holderIndices[_nftAddress][lastHolder] = holderIndices[_nftAddress][
            _user
        ];
        //+-Delete the Last Element(Address) of the ShareHolders Array:_
        shareholders[_nftAddress].pop();
        //+-And Zero Out The Index for Addr:_
        holderIndices[_nftAddress][_user] = 0;
    }

    /**
     *  The number of addresses that own tokens.
     *  @return the number of unique addresses that own tokens.
     */
    function holderCount(address _nftAddress)
        public
        view
        override
        returns (uint256)
    {
        return shareholders[_nftAddress].length;
    }

    /**
     *  By counting the number of token holders using `holderCount`
     *  you can retrieve the complete list of token holders, one at a time.
     *  It MUST throw if `index >= holderCount()`.
     *  @param index The zero-based index of the holder.
     *  @return the address of the token holder with the given index.
     */
    function holderAt(address _nftAddress, uint256 index)
        public
        view
        override
        returns (address)
    {
        require(index < shareholders[_nftAddress].length);
        return shareholders[_nftAddress][index];
    }

    //+-Function triggered by the O.A.Marketplace S.C. to inform that a Buyout of the ArtWork N.F.T. has been made:_
    function buyOutTookPlace(address _nftAddress) public override {
        require(
            OAMUVContract.onlyOwnerOrNFT(msg.sender) ||
                OAMMContract.onlyPlatformSCs(msg.sender),
            "Only Platform S.C./Owner can do this."
        );
        buyOutHappened[_nftAddress] = true;
    }

    //+-Know if the BuyOut of the ArtWork N.F.T. has happened or not:_
    function getBuyOutTookPlace(address _nftAddress)
        public
        view
        override
        returns (bool)
    {
        return buyOutHappened[_nftAddress];
    }

    //+-Returns the Voters of the D.A.O.:_
    function getVoters(address _nftAddress)
        public
        view
        override
        returns (address[] memory)
    {
        return shareholders[_nftAddress];
    }

    //+-Returns the Winning Proposal in a Voting Cycle:_
    function getWinningProposal(address _nftAddress)
        public
        view
        returns (Proposal memory proposal)
    {
        return proposals[_nftAddress][winningProposalId[_nftAddress]];
    }

    function addVoter(address _nftAddress, address _addr) public override {
        require(
            IERC20(_nftAddress).ERC20balanceOf(_addr) > 0,
            "Does not have tokens in the N.F.T."
        );
        Voter memory newVoter = Voter(true, _addr, false, 0);
        AllowList[_nftAddress][_addr] = newVoter;
        shareholders[_nftAddress].push(_addr);
        votersCount[_nftAddress]++;
        emit VoterRegistered(_nftAddress, _addr);
    }

    //+-The O.A.M. Platform Owner can Delete a Voter of this D.A.O. if needed:_
    function deleteVoter(address _nftAddress, address _addr)
        public
        override
        onlyOwner
    {
        delete AllowList[_nftAddress][_addr];
        //+-Replace the Address in the shareholders Array and UpDate all the Associated Mappings:_
        uint256 holderIndex = holderIndices[_nftAddress][_addr] - 1;
        uint256 lastIndex = shareholders[_nftAddress].length - 1;
        address lastHolder = shareholders[_nftAddress][lastIndex];
        //+-Overwrite the addr's slot with the Last Shareholder:_
        shareholders[_nftAddress][holderIndex] = lastHolder;
        //+-Also Copy Over the Index:_
        holderIndices[_nftAddress][lastHolder] = holderIndices[_nftAddress][
            _addr
        ];
        //+-Delete the Last Element(Address) of the ShareHolders Array:_
        shareholders[_nftAddress].pop();
        //+-And Zero Out The Index for Addr:_
        holderIndices[_nftAddress][_addr] = 0;
        votersCount[_nftAddress]--;
        emit VoterRemoved(_nftAddress, _addr);
    }

    //+-ArtWork Owner ReSets the Voting Cycle so another new Voting with new Proposals can take place:_
    function resetVotingSession(address _nftAddress) public {
        require(OAMUVContract.onlyOwnerServerOrAdmin(msg.sender), 'Only Owner, Server or Admins can perform this function');
        require(
            buyOutHappened[_nftAddress] == false,
            "BuyOut of the ArtWork took place, the D.A.O. must be restarted for this."
        );
        WorkflowStatus previous = status[_nftAddress];
        WorkflowStatus newStatus = WorkflowStatus.VotingStart;
        status[_nftAddress] = newStatus;
        emit WorkflowStatusChange(_nftAddress, previous, newStatus);
    }

    //+-Starts the Voting Cycle Registering the Different Proposals that Will be abailable to Compete between each other:_
    function startProposalRegistration(address _nftAddress) public {
        require(OAMUVContract.onlyOwnerServerOrAdmin(msg.sender), 'Only Owner, Server or Admins can perform this function');
        require(
            buyOutHappened[_nftAddress] == false,
            "BuyOut of the ArtWork took place, the D.A.O. must be restarted for this."
        );
        WorkflowStatus previous = status[_nftAddress];
        WorkflowStatus newStatus = WorkflowStatus.ProposalsRegistrationStarted;
        status[_nftAddress] = newStatus;
        emit ProposalsRegistrationStarted(_nftAddress);
        emit WorkflowStatusChange(_nftAddress, previous, newStatus);
    }

    //+-Ends the Registration of Different Proposals that Will be abailable to Compete between each other:_
    function endProposalRegistration(address _nftAddress) public {
        require(OAMUVContract.onlyOwnerServerOrAdmin(msg.sender), 'Only Owner, Server or Admins can perform this function');
        require(
            buyOutHappened[_nftAddress] == false,
            "BuyOut of the ArtWork took place, the D.A.O. must be restarted for this."
        );
        WorkflowStatus previous = status[_nftAddress];
        WorkflowStatus newStatus = WorkflowStatus.ProposalsRegistrationEnded;
        status[_nftAddress] = newStatus;
        emit ProposalsRegistrationEnded(_nftAddress);
        emit WorkflowStatusChange(_nftAddress, previous, newStatus);
    }

    //+-The ArtWork Owner can change the Default Time in Days of Votings:_
    function setDefaultVotingDays(address _nftAddress, uint256 _days)
        public
    {
        require(OAMUVContract.onlyOwnerServerOrAdmin(msg.sender), 'Only Owner, Server or Admins can perform this function');
        require(
            buyOutHappened[_nftAddress] == false,
            "BuyOut of the ArtWork took place, D.A.O. must be restarted for this."
        );
        require(
            status[_nftAddress] != WorkflowStatus.VotingSessionStarted,
            "Cannot change this while the Votings happening."
        );
        defaultVotingTime[_nftAddress] = 1 days * _days;
        emit VotingTime(_nftAddress, _days);
    }

    //+-Starts the Voting between the Different Proposals:_
    function startVotingSession(address _nftAddress) public {
        require(OAMUVContract.onlyOwnerServerOrAdmin(msg.sender), 'Only Owner, Server or Admins can perform this function');
        require(
            buyOutHappened[_nftAddress] == false,
            "BuyOut of the ArtWork took place, D.A.O. must be restarted for this."
        );
        WorkflowStatus previous = status[_nftAddress];
        WorkflowStatus newStatus = WorkflowStatus.VotingSessionStarted;
        votationStartTime[_nftAddress] = block.timestamp;
        status[_nftAddress] = newStatus;
        emit VotingSessionStarted(_nftAddress);
        emit WorkflowStatusChange(_nftAddress, previous, newStatus);
    }

    //+-Ends the Voting between the Different Proposals ONLY after the set Voting Time have passed:_
    function endVotingSession(address _nftAddress) public {
        require(OAMUVContract.onlyOwnerServerOrAdmin(msg.sender), 'Only Owner, Server or Admins can perform this function');
        require(
            buyOutHappened[_nftAddress] == false,
            "BuyOut of the ArtWork took place, D.A.O. must be restarted for this."
        );
        require(
            block.timestamp >=
                (votationStartTime[_nftAddress] +
                    defaultVotingTime[_nftAddress]),
            "Voting time did not ended yet"
        );
        WorkflowStatus previous = status[_nftAddress];
        WorkflowStatus newStatus = WorkflowStatus.VotingSessionEnded;
        status[_nftAddress] = newStatus;
        emit VotingSessionEnded(_nftAddress);
        emit WorkflowStatusChange(_nftAddress, previous, newStatus);
    }

    //+-Token Shares Holders can add Proposals to being voted:_
    function addProposal(address _nftAddress, string memory _description)
        public
    {
        require(allowListed(_nftAddress, msg.sender), "User not allowed.");
        require(
            OAMUVContract.isVerified(msg.sender),
            "Replacement is not a Verified User."
        );
        require(
            buyOutHappened[_nftAddress] == false,
            "BuyOut of the ArtWork took place, D.A.O. must be restarted for this."
        );
        require(
            status[_nftAddress] == WorkflowStatus.ProposalsRegistrationStarted,
            "Proposals Session has Not Started yet."
        );
        require(
            IERC20(_nftAddress).ERC20balanceOf(msg.sender) > 0,
            "Need to be a T.Share Holder."
        );
        Proposal memory newProposal = Proposal(
            proposalIds[_nftAddress],
            msg.sender,
            _description,
            0
        );
        proposals[_nftAddress][proposalIds[_nftAddress]] = newProposal;
        proposalIds[_nftAddress]++;
        emit ProposalRegistered(_nftAddress, proposalIds[_nftAddress]);
    }

    //+-Token Shares Holders can Delete the Proposals that they Added:_
    function deleteProposal(address _nftAddress, uint256 _id) public {
        require(
            OAMUVContract.isVerified(msg.sender),
            "Replacement is not a Verified User."
        );
        require(allowListed(_nftAddress, msg.sender), "User not allowed.");
        require(
            buyOutHappened[_nftAddress] == false,
            "BuyOut of the ArtWork took place, D.A.O. must be restarted for this."
        );
        require(proposals[_nftAddress][_id].owner == msg.sender);
        delete proposals[_nftAddress][_id];
        emit ProposalRemoved(_nftAddress, _id);
    }

    //+-The ArtWork Owner can Delete a Proposal:_
    function deleteProposalAdmin(address _nftAddress, uint256 _id)
        public
        onlyOwner
    {
        require(
            buyOutHappened[_nftAddress] == false,
            "BuyOut of the ArtWork took place, D.A.O. must be restarted for this."
        );
        delete proposals[_nftAddress][_id];
    }

    //+-Users can Vote for the Proposals:_
    function vote(
        address _nftAddress,
        uint256 _proposalId,
        bool yesOrNo
    ) public {
        require(
            OAMUVContract.isVerified(msg.sender),
            "Replacement is not a Verified User."
        );
        require(allowListed(_nftAddress, msg.sender), "User not allowed.");
        require(
            buyOutHappened[_nftAddress] == false,
            "BuyOut of the ArtWork took place, D.A.O. must be restarted for this."
        );
        require(status[_nftAddress] == WorkflowStatus.VotingSessionStarted);
        require(
            block.timestamp <=
                votationStartTime[_nftAddress] + defaultVotingTime[_nftAddress],
            "Default Voting Start Time Ended."
        );
        require(AllowList[_nftAddress][msg.sender].hasVoted == false);
        AllowList[_nftAddress][msg.sender].hasVoted = true;
        if (yesOrNo) {
            proposals[_nftAddress][_proposalId].voteCount += IERC20(_nftAddress)
                .ERC20balanceOf(msg.sender);
        }
        emit Voted(_nftAddress, msg.sender, _proposalId);
    }

    //+-The ArtWork Owner executes the Counting of Votes:_
    function countVotes(address _nftAddress) public  {
        require(OAMUVContract.onlyOwnerOrServer(msg.sender), 'Only Owner or Server can perform this function');
        require(
            OAMUVContract.isVerified(msg.sender),
            "Replacement is not a Verified User."
        );
        require(
            buyOutHappened[_nftAddress] == false,
            "BuyOut of the ArtWork took place, D.A.O. must be restarted for this."
        );
        require(
            status[_nftAddress] == WorkflowStatus.VotingSessionEnded,
            "Voting session has not ended"
        );
        uint256 id;
        uint256 highestCount;
        uint256 _proposalIds = proposalIds[_nftAddress];
        for (uint256 i = 0; i <= _proposalIds; i++) {
            // console.log('vote count, ', i, proposals[_nftAddress][i].voteCount, (IERC20(_nftAddress).ERC20totalSupply() / 2));
            if (highestCount < proposals[_nftAddress][i].voteCount) {
                highestCount = proposals[_nftAddress][i].voteCount;
                id = proposals[_nftAddress][i].id;
                //console.log("new winner", id, highestCount, proposals[_nftAddress][i].description);
            }
        }
        address[] memory _voters = shareholders[_nftAddress];
        //+-By Default, the Vote of every Token Holder that does not explicitly Voted within the Time Limit goes to the Winner proposal.
        for (uint256 i = 0; i < _voters.length; i++) {
            if (AllowList[_nftAddress][_voters[i]].hasVoted == false) {
                proposals[_nftAddress][id].voteCount += IERC20(_nftAddress)
                    .ERC20balanceOf(_voters[i]);
                AllowList[_nftAddress][_voters[i]].hasVoted = true;
            }
        }
        winningProposalId[_nftAddress] = id;
        //+-By Default, A simple majority (50,1%) of the Total Supply of the Tokens Shares Votes win the Voting:_
        // console.log("51,1%", proposals[_nftAddress][id].voteCount > (IERC20(_nftAddress).ERC20totalSupply() / 2));
        if (
            proposals[_nftAddress][id].voteCount >
            (IERC20(_nftAddress).ERC20totalSupply() / 2)
        ) {
            emit ProposalReachedMajority(
                _nftAddress,
                winningProposalId[_nftAddress]
            );
        } else {
            emit NoProposalReachedMajority(
                _nftAddress,
                winningProposalId[_nftAddress]
            );
        }
        emit VotesTallied(_nftAddress, winningProposalId[_nftAddress]);
        status[_nftAddress] = WorkflowStatus.VotesTallied;
    }
}
