const { expect } = require("chai");
const { ethers, network } = require("hardhat");

var chai = require("chai");
const BN = require("bn.js");
chai.use(require("chai-bn")(BN));

const {
  setupArtWorkNFT,
  setupCurrencyTokens,
  setupSupportContracts,
  transferMoneyToWallet,
  setITOTokensAvailable,
  setupServersAndAdmin,
  getElements,
  startITO,
  buyIntoITO,
} = require("./OAMContractSetup.js");

let USDTokenContract;
let EURTokenContract;
let GBPTokenContract;
let NOKTokenContract;
let UserValidationContract;
let marketPlaceContract;
let ITOContract;
let DAOContract;
let NFTSalesContract;
let OAMEAContract;
let OAMDAContract;
let ArtWorkNFTContract;
let P2PMarketContract;
const oneDay = 86400; //+-1 Day == 86.400 Seconds.

describe("Open Art Market: Decentralized Autonomous Organization", function () {
  before(async function () {
    [
      owner,
      collector,
      addr1,
      addr2,
      addr3,
      addr4,
      addr5,
      addr6,
      addr7,
      server,
      admin,
      ...addrs
    ] = await ethers.getSigners();
    await setupCurrencyTokens(owner);
    await setupSupportContracts(owner);
    await setupServersAndAdmin(owner, server, admin);
    await setupArtWorkNFT("OAMNFT", owner, server, collector, addr1, addr2);

    let o = getElements();
    USDTokenContract = o.USDTokenContract;
    EURTokenContract = o.EURTokenContract;
    GBPTokenContract = o.GBPTokenContract;
    NOKTokenContract = o.NOKTokenContract;
    UserValidationContract = o.UserValidationContract;
    marketPlaceContract = o.marketPlaceContract;
    ITOContract = o.ITOContract;
    DAOContract = o.DAOContract;
    NFTSalesContract = o.NFTSalesContract;
    OAMEAContract = o.OAMEAContract;
    OAMDAContract = o.OAMDAContract;
    ArtWorkNFTContract = o.ArtWorkNFTContract;
    P2PMarketContract = o.P2PMarketContract;
  });

  it("The DAO gets members as people buy tokens", async function () {
    await startITO(ArtWorkNFTContract, owner);
    await expect(buyIntoITO(ArtWorkNFTContract.address, owner, addr1, 100))
      .to.emit(DAOContract, "VoterRegistered")
      .withArgs(ArtWorkNFTContract.address, addr1.address);
    expect(await ArtWorkNFTContract.ERC20balanceOf(addr1.address)).to.equal(
      100
    );

    await expect(buyIntoITO(ArtWorkNFTContract.address, owner, addr2, 100))
      .to.emit(DAOContract, "VoterRegistered")
      .withArgs(ArtWorkNFTContract.address, addr2.address);
    expect(await ArtWorkNFTContract.ERC20balanceOf(addr2.address)).to.equal(
      100
    );

    await expect(buyIntoITO(ArtWorkNFTContract.address, owner, addr3, 100))
      .to.emit(DAOContract, "VoterRegistered")
      .withArgs(ArtWorkNFTContract.address, addr3.address);
    expect(await ArtWorkNFTContract.ERC20balanceOf(addr3.address)).to.equal(
      100
    );

    await ITOContract.connect(owner).finishIto(ArtWorkNFTContract.address);
    expect(
      await ITOContract.connect(collector).withdrawItoUnSoldShares(
        ArtWorkNFTContract.address
      )
    )
      .to.emit(DAOContract, "VoterRegistered")
      .withArgs(ArtWorkNFTContract.address, collector.address);

    expect(
      await DAOContract.isShareholder(ArtWorkNFTContract.address, addr1.address)
    ).to.be.true;
    expect(
      await DAOContract.isShareholder(ArtWorkNFTContract.address, addr2.address)
    ).to.be.true;
    expect(
      await DAOContract.isShareholder(ArtWorkNFTContract.address, addr3.address)
    ).to.be.true;
  });
  it("Platform set amount of days for voting", async function () {
    await expect(
      DAOContract.connect(owner).setDefaultVotingDays(
        ArtWorkNFTContract.address,
        3
      )
    )
      .to.emit(DAOContract, "VotingTime")
      .withArgs(ArtWorkNFTContract.address, 3);
  });
  it("Members cannot start proposals or voting sessions", async function(){
    try {
      await DAOContract.connect(addr1).startProposalRegistration(
          ArtWorkNFTContract.address
        );
    } catch (error) {
      expect(error.message).to.equal("VM Exception while processing transaction: reverted with reason string 'Only Owner, Server or Admins can perform this function'")
    }
    try {
      await DAOContract.connect(addr1).startVotingSession(
          ArtWorkNFTContract.address
        );
    } catch (error) {
      expect(error.message).to.equal("VM Exception while processing transaction: reverted with reason string 'Only Owner, Server or Admins can perform this function'")
    }
  })
  it("Admin can start a proposal registration session", async function () {
    await expect(
      DAOContract.connect(admin).startProposalRegistration(
        ArtWorkNFTContract.address
      )
    ).to.emit(DAOContract, "ProposalsRegistrationStarted");
  });
  it("Members can create proposals for voting", async function () {
    await expect(
      DAOContract.connect(addr1).addProposal(
        ArtWorkNFTContract.address,
        "Sell to National Gallery?"
      )
    ).to.emit(DAOContract, "ProposalRegistered");
    await expect(
      DAOContract.connect(addr1).addProposal(
        ArtWorkNFTContract.address,
        "Sell to private collector"
      )
    ).to.emit(DAOContract, "ProposalRegistered");

    await expect(
      DAOContract.endProposalRegistration(ArtWorkNFTContract.address)
    ).to.emit(DAOContract, "ProposalsRegistrationEnded");
  });

  it("Admin can start a voting session", async function () {
    await expect(DAOContract.startVotingSession(ArtWorkNFTContract.address))
      .to.emit(DAOContract, "VotingSessionStarted")
      .withArgs(ArtWorkNFTContract.address);
  });

  it("Members can vote for proposals inside the Voting Time Frame of 3 Days", async function () {
    //https://ethereum.stackexchange.com/questions/86633/time-dependent-tests-with-hardhat
    //https://hardhat.org/hardhat-network/reference/#special-testing-debugging-methods
    await network.provider.send("evm_increaseTime", [oneDay]);
    await network.provider.send("evm_mine"); //+-(This Time would be 1 Day since the Voting Started, and Users have 3 Days for Voting).
    await expect(
      DAOContract.connect(addr1).vote(ArtWorkNFTContract.address, 1, true)
    ).to.emit(DAOContract, "Voted");
    await expect(
      DAOContract.connect(addr2).vote(ArtWorkNFTContract.address, 1, true)
    ).to.emit(DAOContract, "Voted");
    await expect(
      DAOContract.connect(collector).vote(ArtWorkNFTContract.address, 0, true)
    ).to.emit(DAOContract, "Voted");
  });
  it("Users Cannot Vote after Voting Time Ended and Platform can end a Voting Session", async function () {
    await network.provider.send("evm_increaseTime", [oneDay * 3]);
    await network.provider.send("evm_mine"); //+-(This Time would be 4 Days in Total since the Voting Started, and Users had 3 Days for Voting).
    try {
      await DAOContract.connect(addr3).vote(
        ArtWorkNFTContract.address,
        1,
        true
      );
    } catch (error) {
      expect(error.message).to.equal(
        "VM Exception while processing transaction: reverted with reason string 'Default Voting Start Time Ended.'"
      );
    }
    await expect(
      DAOContract.connect(owner).endVotingSession(ArtWorkNFTContract.address)
    )
      .to.emit(DAOContract, "VotingSessionEnded")
      .withArgs(ArtWorkNFTContract.address);
  });
  it("Platform can count votes and announce the Winner Proposal", async function () {
    await expect(
      DAOContract.connect(owner).countVotes(ArtWorkNFTContract.address)
    )
      .to.emit(DAOContract, "ProposalReachedMajority")
      .withArgs(ArtWorkNFTContract.address, 0);
  });
  it("Platform cannot add shareholders to DAOs outside of having tokens", async function () {
    try {
      await DAOContract.connect(owner).updateShareholders(
        ArtWorkNFTContract.address,
        addr7.address
      );
    } catch (error) {
      expect(error.message).to.equal(
        "VM Exception while processing transaction: reverted with reason string 'Only Platform S.C. / NFT can do this.'"
      );
    }
    expect(
      await ArtWorkNFTContract.ERC20balanceOf(addr7.address)
    ).to.equal(0);
    expect(
      await DAOContract.isShareholder(ArtWorkNFTContract.address, addr7.address)
    ).to.be.false;
  });
});
