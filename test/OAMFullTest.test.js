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

describe("Open Art Market Smart Contracts", function () {
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

  describe("OAM Test data configuration:_", async function () {
    it("Users have been added to Marketplace and have currency tokens in their wallets", async function () {
      await transferMoneyToWallet(owner, addr1.address, 400000000);
      await transferMoneyToWallet(owner, addr2.address, 100000000);
      //+-Checking that the T.Supply of the Fiat Tokens is equal to the minted supply of the NOK 5.000.000,00 Currency Tokens:_
      expect(await NOKTokenContract.ERC20totalSupply()).to.equal(500000000);
      //+-Checking that Collector has an empty Wallet:_
      expect(await NOKTokenContract.ERC20balanceOf(collector.address)).to.equal(
        0
      );
      //+-Checking that addr1 has 4.000.000,00 NOK tokens & addr2 has 4.000.000,00 NOK tokens in their Wallets (two decimal places):_
      expect(await NOKTokenContract.ERC20balanceOf(addr1.address)).to.equal(
        400000000
      );
      /*console.log(
        "Addr1 Initial NOK Balance:_ ",
        await NOKTokenContract.ERC20balanceOf(addr1.address)
      );
      console.log();
      expect(await NOKTokenContract.ERC20balanceOf(addr2.address)).to.equal(
        100000000
      );
      console.log(
        "Addr2 Initial NOK Balance:_ ",
        await NOKTokenContract.ERC20balanceOf(addr2.address)
      );*/
    });

    it("Artwork is configured correctly", async function () {
      //+-Making sure the parameters of the Artwork are correct:_
      expect(await ArtWorkNFTContract.ERC721name()).to.equal("Artwork 2022 01");
      expect(await ArtWorkNFTContract.ERC721symbol()).to.equal("OAM2201");
      //+-Expect value to not be set at default:_
      expect(
        await ITOContract.getNFTValue(ArtWorkNFTContract.address)
      ).to.equal("0");
    });
  });

  describe("Initial Token Offering; Set value, Token Supply and Start the Offering", async function () {
    it("Platform Owner can set N.F.T. Initial Shares Supply and N.F.T. Initial Price.", async function () {
      //+-Checking that I.T.O. has not started yet:_
      expect(
        await ITOContract.getItoStarted(ArtWorkNFTContract.address)
      ).to.equal(false);

      //+-Artwork has been deployed, now we need to set the Default FiatToken of the D.A.O.:_
      await ArtWorkNFTContract.connect(owner).setDAOFiatToken(
        NOKTokenContract.address
      );

      //+-Now we can set the initial price and token supply:_
      await ITOContract.connect(owner).setNFTInitialPrice(
        ArtWorkNFTContract.address,
        10000000
      ); //+-N.F.T. Price = NOK 1.000.000,00 .
      await ITOContract.connect(owner).setNFTInitialTokenShares(
        ArtWorkNFTContract.address,
        100000
      ); //+-Shares Supply of the ArtWork N.F.T. = 100.000.

      //+-Checking that we get expected values from setup:_
      expect(
        (await ITOContract.getNFTValue(ArtWorkNFTContract.address)).toString()
      ).to.equal("10000000");
      expect(
        (
          await ITOContract.getItoShareSupply(ArtWorkNFTContract.address)
        ).toString()
      ).to.equal("100000");
      // Checking that token value calculated correctly:
      expect(
        (
          await ITOContract.getItoSharePrice(ArtWorkNFTContract.address)
        ).toString()
      ).to.equal("100");
      //+-I.T.O. should not be started:_
      expect(
        await ITOContract.getItoStarted(ArtWorkNFTContract.address)
      ).to.equal(false);
      //+-I.T.O. should not be ended:_
      expect(
        await ITOContract.getItoEnded(ArtWorkNFTContract.address)
      ).to.equal(false);
      //+-I.T.O. should not be freezed after the I.T.O. has ended:_
      expect(
        await ITOContract.getIsFreezedAfterITO(ArtWorkNFTContract.address)
      ).to.equal(false);
    });

    it("Platform Owner can set initial tokens for sale", async function () {
      //+-Setting the total amount of tokens to be available for sale at the I.T.O.:_
      await setITOTokensAvailable(ArtWorkNFTContract.address, owner, 70000);
      // The ITO should have 70000 shares available for sale
      expect(
        await ITOContract.getItoInitialAvailableShares(
          ArtWorkNFTContract.address
        )
      ).to.equal(70000);

      // be able to change the amount of tokens to be sold
      await setITOTokensAvailable(ArtWorkNFTContract.address, owner, 70021);
      // The ITO should have 70021 shares available for sale
      expect(
        await ITOContract.getItoInitialAvailableShares(
          ArtWorkNFTContract.address
        )
      ).to.equal(70021);
    });

    it("Platform owner can start the I.T.O.", async function () {
      //+-Start the I.T.O. and check parameters:_
      await expect(
        ITOContract.connect(owner).startIto(ArtWorkNFTContract.address)
      )
        .to.emit(ITOContract, "StartITO")
        .withArgs(ArtWorkNFTContract.address);
      // The I.T.O. should have started:_
      expect(
        await ITOContract.getItoStarted(ArtWorkNFTContract.address)
      ).to.equal(true);
      // The I.T.O. should have an implied value:_
      expect(
        await NFTSalesContract.getNFTImpliedValueInOriginalDAOFiatToken(
          ArtWorkNFTContract.address
        )
      ).to.equal(10000000); //+-N.F.T. Price = NOK 1.000.000,00 .

      // The I.T.O. should have 70021 shares available for sale:_
      expect(
        await ITOContract.getItoInitialAvailableShares(
          ArtWorkNFTContract.address
        )
      ).to.equal(70021);

      // The ITO should not be ended
      expect(
        await ITOContract.getItoEnded(ArtWorkNFTContract.address)
      ).to.equal(false);
      // The ITO tokens should not be freezed after ITO ended
      expect(
        await ITOContract.getIsFreezedAfterITO(ArtWorkNFTContract.address)
      ).to.equal(false);

      // The NFT is not available for sale
      expect(
        await NFTSalesContract.getNFTIsOnSale(ArtWorkNFTContract.address)
      ).to.equal(false);
    });
  });
  describe("Member allow listing: Only allow listed wallets can interact with the contracts", async function () {
    it("Non-members are not able to trade with tokens", async function () {
      //+-Make sure that non-members are not able to trade with tokens:_
      try {
        await NOKTokenContract.connect(addr3).ERC20approve(
          ITOContract.address,
          1100
        );
      } catch (e) {
        expect(e.message).to.equal("User is not a member of the platform");
      }
    });

    it("Platform members are able to buy tokens in an Artwork", async function () {
      //+-Make sure that platform members are able to buy tokens in an Artwork:_
      //+-Two different trades are made to check that the balance is updated correctly:_
      expect(
        (
          await ITOContract.getItoInitialAvailableShares(
            ArtWorkNFTContract.address
          )
        ).toString()
      ).to.equal("70021");
      // console.log(
      //   "ArtWork Initial Available Shares for Sale at the I.T.O.:_",
      //   await ITOContract.getItoInitialAvailableShares(
      //     ArtWorkNFTContract.address
      //   )
      //);
      // User is approving the spend on the ITO from currency tokens
      await NOKTokenContract.connect(addr1).ERC20approve(
        ITOContract.address,
        7000000
      );
      // User can buy artwork tokens
      await expect(
        ITOContract.connect(addr1).buyShare(ArtWorkNFTContract.address, 70000)
      )
        .to.emit(DAOContract, "VoterRegistered")
        .withArgs(ArtWorkNFTContract.address, addr1.address);

      // Checking the balances of the the user and collector wallets
      expect(await NOKTokenContract.ERC20balanceOf(addr1.address)).to.equal(
        393000000
      );
      // console.log(
      //   "Addr1 NOK Balance after Buying 70.000 Shares at NOK 10,00 each one in the I.T.O.:_ ",
      //   await NOKTokenContract.ERC20balanceOf(addr1.address)
      // );
      expect(await NOKTokenContract.ERC20balanceOf(collector.address)).to.equal(
        7000000
      );
      // Checking the balance of the artwork tokens
      expect(await ArtWorkNFTContract.ERC20balanceOf(addr1.address)).to.equal(
        70000
      );
      // console.log(
      //   "Addr1 ArtWork Token Shares Balance after Buying in the I.T.O.:_ ",
      //   await ArtWorkNFTContract.ERC20balanceOf(addr1.address)
      // );
      // User 2 is approving the spend on the ITO from currency tokens
      await NOKTokenContract.connect(addr2).ERC20approve(
        ITOContract.address,
        1100
      );
      // User 2 can buy artwork tokens
      await expect(
        ITOContract.connect(addr2).buyShare(ArtWorkNFTContract.address, 1)
      )
        .to.emit(DAOContract, "VoterRegistered")
        .withArgs(ArtWorkNFTContract.address, addr2.address);

      // Checking the balances of the the user and collector wallets
      expect(await NOKTokenContract.ERC20balanceOf(addr2.address)).to.equal(
        99999900
      );
      // console.log(
      //   "Addr2 NOK Balance after Buying 1 Shares at NOK 10,00 in the I.T.O.:_ ",
      //   await NOKTokenContract.ERC20balanceOf(addr2.address)
      // );
      expect(await NOKTokenContract.ERC20balanceOf(collector.address)).to.equal(
        7000100
      );
      // console.log(
      //   "Collector NOK Balance after Buying of Shares by Addr1 and Addr2 at the I.T.O.:_ ",
      //   await NOKTokenContract.ERC20balanceOf(collector.address)
      // );
      expect(await ArtWorkNFTContract.ERC20balanceOf(addr2.address)).to.equal(
        1
      );
      // console.log(
      //   "Addr2 ArtWork Token Shares Balance after Buying in the I.T.O.:_ ",
      //   await ArtWorkNFTContract.ERC20balanceOf(addr2.address)
      // );
    });

    it("New members can be added to the platform", async function () {
      //+-Checking that we can add new members:_
      //+-Trying to see if the user can interact with our contracts
      try {
        await NOKTokenContract.connect(addr3).ERC20approve(
          ITOContract.address,
          1100
        );
      } catch (e) {
        expect(e.message).to.equal("User is not a member of the platform");
      }

      // User 3 should not be verified
      expect(
        await UserValidationContract.connect(owner).isVerified(addr3.address)
      ).to.equal(false);
      // Adding user
      await UserValidationContract.connect(owner).addVerified(addr3.address);
      // User 3 should be verified
      expect(
        await UserValidationContract.connect(owner).isVerified(addr3.address)
      ).to.equal(true);
    });

    it("Members can be removed from the platform", async function () {
      //+-Checking that we can remove members:_
      // User 3 should be verified
      expect(
        await UserValidationContract.connect(owner).isVerified(addr3.address)
      ).to.equal(true);
      // Remove user
      await UserValidationContract.connect(owner).removeVerified(addr3.address);
      // User 3 should not be verified
      expect(
        await UserValidationContract.connect(owner).isVerified(addr3.address)
      ).to.equal(false);

      //+-Trying to hack the system and it should fail:_
      try {
        await NOKTokenContract.connect(addr3).ERC20approve(
          ITOContract.address,
          1100
        );
      } catch (e) {
        expect(e.message).to.equal("User is not a member of the platform");
      }
    });
  });

  describe("ITO management: Add after I.T.O. and buy tokens", async function () {
    it("Users can get currency tokens, and use them to buy artwork tokens", async function () {
      //+-Adding users after I.T.O. Start and see that they can buy tokens:_
      await UserValidationContract.connect(owner).addVerified(addr4.address);
      await NOKTokenContract._ERC20mint(owner.address, addr4.address, 2000);
      await NOKTokenContract.connect(addr4).ERC20approve(
        ITOContract.address,
        2000
      );
      // console.log(
      //   "Addr4 Initial NOK Balance:_ ",
      //   await NOKTokenContract.ERC20balanceOf(addr4.address)
      // );
      await ITOContract.connect(addr4).buyShare(ArtWorkNFTContract.address, 20);
      expect(await NOKTokenContract.ERC20balanceOf(addr4.address)).to.equal(0);
      // console.log(
      //   "Addr4 NOK Balance after Buying 20 Token Shares at NOK 10,00 each one in the I.T.O.:_ ",
      //   await NOKTokenContract.ERC20balanceOf(addr4.address)
      // );
      expect(await ArtWorkNFTContract.ERC20balanceOf(addr4.address)).to.equal(
        20
      );
      // console.log(
      //   "Addr4 ArtWork Token Shares Balance after Buying in the I.T.O.:_ ",
      //   await ArtWorkNFTContract.ERC20balanceOf(addr4.address)
      // );
    });
    it("Users cannot buy tokens when initial shares available has run out", async function () {
      await NOKTokenContract._ERC20mint(owner.address, addr4.address, 2000);
      await NOKTokenContract.connect(addr4).ERC20approve(
        ITOContract.address,
        2000
      );

      try {
        await ITOContract.connect(addr4).buyShare(
          ArtWorkNFTContract.address,
          20
        );
      } catch (e) {
        expect(e.message).to.equal(
          "VM Exception while processing transaction: reverted with reason string 'Not Enough Shares left.'"
        );
      }
    });
    it("Platform owner can change amount of shares available whilst in I.T.O.", async function () {
      await setITOTokensAvailable(ArtWorkNFTContract.address, owner, 70041);
      await ITOContract.connect(addr4).buyShare(ArtWorkNFTContract.address, 20);
      expect(await NOKTokenContract.ERC20balanceOf(addr4.address)).to.equal(0);
      // console.log(
      //   "Addr4 NOK Balance after Buying 20 more Token Shares at NOK 10,00 each one in the I.T.O.:_ ",
      //   await NOKTokenContract.ERC20balanceOf(addr4.address)
      // );
      expect(await ArtWorkNFTContract.ERC20balanceOf(addr4.address)).to.equal(
        40
      );
      // console.log(
      //   "Addr4 ArtWork Token Shares Balance after Buying in the I.T.O. again:_ ",
      //   await ArtWorkNFTContract.ERC20balanceOf(addr4.address)
      // );
    });
    it("Platform Owner can close the I.T.O. and users will not be able to buy tokens any longer.", async function () {
      //+-Check that no one can buy tokens after the I.T.O. is closed:_
      ITOContract.connect(owner).finishIto(ArtWorkNFTContract.address);

      await network.provider.send("evm_increaseTime", [6000]);
      await network.provider.send("evm_mine");

      await NOKTokenContract.connect(addr4).ERC20approve(
        ITOContract.address,
        2000
      );

      try {
        await ITOContract.connect(addr4).buyShare(
          ArtWorkNFTContract.address,
          20
        );
      } catch (e) {
        expect(e.message).to.equal(
          "VM Exception while processing transaction: reverted with reason string 'I.T.O. has closed.'"
        );
      }
    });
    it("Collector can withdraw their tokens after the I.T.O. has ended.", async function () {
      // The collector should be able to get their tokens
      expect(
        await ArtWorkNFTContract.ERC20balanceOf(collector.address)
      ).to.equal(0);

      expect(
        await ITOContract.connect(collector).withdrawItoUnSoldShares(
          ArtWorkNFTContract.address
        )
      )
        .to.emit(DAOContract, "VoterRegistered")
        .withArgs(ArtWorkNFTContract.address, collector.address);

      expect(
        await ArtWorkNFTContract.ERC20balanceOf(collector.address)
      ).to.equal(24959);
      // console.log(
      //   "Collector ArtWork Shares Balance after Withdrawing Earnings and Unsold Shares from the I.T.O.:_ ",
      //   await ArtWorkNFTContract.ERC20balanceOf(collector.address)
      // );
    });
    it("Artwork tokens can be freezed for trading after I.T.O. is ended", async function () {
      //+-We should be able to toggle Freeze after I.T.O.:_

      await ITOContract.connect(owner).setIsFreezedAfterITO(
        ArtWorkNFTContract.address,
        true
      );
      expect(
        await ITOContract.getIsFreezedAfterITO(ArtWorkNFTContract.address)
      ).to.equal(true);
    });
    it("Artwork tokens can be freezed for trading after ITO has ended", async function () {
      //+-We should be able to Set Freeze after I.T.O.:_
      await ITOContract.connect(owner).setIsFreezedAfterITO(
        ArtWorkNFTContract.address,
        true
      );
      expect(
        await ITOContract.getIsFreezedAfterITO(ArtWorkNFTContract.address)
      ).to.equal(true);
    });
  });

  describe("D.A.O. is setup and can handle votes:_", async function () {
    // DAO configuration needs to be set to handle the voting and voting results
    it("Owner can be setup with D.A.O voting configuration ", async function () {
      await expect(
        DAOContract.connect(owner).setDefaultVotingDays(
          ArtWorkNFTContract.address,
          3
        )
      )
        .to.emit(DAOContract, "VotingTime")
        .withArgs(ArtWorkNFTContract.address, 3);
    });

    // Check that we have a list of registered voters
    it("D.A.O has a registry of voters", async function () {
      //console.log(await DAOContract.getVoters(ArtWorkNFTContract.address))
      await expect(DAOContract.getVoters(ArtWorkNFTContract.address)).to.have
        .length;
    });

    // Check that we can register voting proposals
    it("Owner can start proposals process for voting at the D.A.O.", async function () {
      // Need to start the DAO propasals registration process
      await expect(
        DAOContract.connect(owner).startProposalRegistration(
          ArtWorkNFTContract.address
        )
      ).to.emit(DAOContract, "ProposalsRegistrationStarted");
    });
    // Check that we can register voting proposals
    it("Token holders can register proposals for voting at the D.A.O.", async function () {
      // Register the proposal to vote over
      await expect(
        DAOContract.connect(addr1).addProposal(
          ArtWorkNFTContract.address,
          "Start P2P market?"
        )
      ).to.emit(DAOContract, "ProposalRegistered");
      await expect(
        DAOContract.connect(addr2).addProposal(
          ArtWorkNFTContract.address,
          "Hold for 1 more year?"
        )
      ).to.emit(DAOContract, "ProposalRegistered");
    });

    // Close the DAO proposals registration process
    it("Owner can end proposals process, starting the vote", async function () {
      await expect(
        DAOContract.endProposalRegistration(ArtWorkNFTContract.address)
      ).to.emit(DAOContract, "ProposalsRegistrationEnded");
    });

    // Need to start the D.A.O. voting process
    it("D.A.O. token holders can start the voting process", async function () {
      await expect(DAOContract.startVotingSession(ArtWorkNFTContract.address))
        .to.emit(DAOContract, "VotingSessionStarted")
        .withArgs(ArtWorkNFTContract.address);
    });
    // Vote on the proposal
    it("D.A.O. token holders can vote on proposals", async function () {
      await expect(
        DAOContract.connect(addr1).vote(ArtWorkNFTContract.address, 0, true)
      ).to.emit(DAOContract, "Voted");
      await expect(
        DAOContract.connect(addr2).vote(ArtWorkNFTContract.address, 1, true)
      ).to.emit(DAOContract, "Voted");
      await expect(
        DAOContract.connect(collector).vote(ArtWorkNFTContract.address, 1, true)
      ).to.emit(DAOContract, "Voted");
    });

    it("D.A.O. can count the votes and get the results", async function () {
      await network.provider.send("evm_increaseTime", [oneDay * 4]);
      await network.provider.send("evm_mine"); //+-(This Time would be 4 Days in total since the Voting Started, and Users have 3 Days for Voting).
      // Close the DAO voting process
      await expect(
        DAOContract.connect(owner).endVotingSession(ArtWorkNFTContract.address)
      )
        .to.emit(DAOContract, "VotingSessionEnded")
        .withArgs(ArtWorkNFTContract.address);
      // Count the votes on the proposals and see the winning proposal
      await expect(
        DAOContract.connect(owner).countVotes(ArtWorkNFTContract.address)
      )
        .to.emit(DAOContract, "ProposalReachedMajority")
        .withArgs(ArtWorkNFTContract.address, 0);
    });
  });

  describe("P2P Market use case: Second hand market for trading artwork tokens", async function () {
    //+-Testing that the second hand market place for tokens works:_
    let buyOfferId;

    it("Platform can change the fee for trading", async function () {
      expect(await marketPlaceContract.getSharesSalesPercPrice()).to.equal(12);
      expect(await marketPlaceContract.setSharesSalesPercPrice(10))
        .to.emit(marketPlaceContract, "SharesSalesPercPriceChanged")
        .withArgs(10);
      expect(await marketPlaceContract.getSharesSalesPercPrice()).to.equal(10);
    });
    it("There is a maximum fee the platform can charge", async function () {
      try {
        await marketPlaceContract.setSharesSalesPercPrice(21);
      } catch (error) {
        expect(error.message).to.equal(
          "VM Exception while processing transaction: reverted with reason string 'You cannot charge a fee >= 20%.'"
        );
      }
      expect(await marketPlaceContract.getSharesSalesPercPrice()).to.equal(10);
    });
    it("Platform has a market buy/sell order listing price", async function () {
      expect(await marketPlaceContract.getListingPrice()).to.equal(1);
    });
    it("Platform can change market buy/sell order listing price", async function () {
      await marketPlaceContract.connect(owner).setListingPriceNOK(100);
      expect(await marketPlaceContract.getListingPrice()).to.equal(100);
    });

    it("User can place a buy offer", async function () {
      // Adding  a new user to the platform
      await UserValidationContract.connect(owner).addVerified(addr5.address);
      await NOKTokenContract._ERC20mint(owner.address, addr5.address, 150000);
      await NOKTokenContract.connect(addr5).ERC20approve(
        P2PMarketContract.address,
        150000
      );
      await ITOContract.connect(owner).setIsFreezedAfterITO(
        ArtWorkNFTContract.address,
        false
      );

      //+-Placing a buy offer:_
      buyOfferId = await P2PMarketContract.connect(addr5).placeBuyOffer(
        ArtWorkNFTContract.address,
        10,
        1500
      );
      //+-Placing another buy offer from a different account:_
      await NOKTokenContract.connect(addr1).ERC20approve(
        P2PMarketContract.address,
        140000
      );
      buyOfferId = await P2PMarketContract.connect(addr1).placeBuyOffer(
        ArtWorkNFTContract.address,
        10,
        1400
      );
    });
    it("User can take a buyOffer", async function () {
      //+-Make sure that token holders can accept a buy offer:_
      await ArtWorkNFTContract.connect(addr1).ERC20approve(
        P2PMarketContract.address,
        10
      );
      // Check for transaction fee for platform
      expect(await NOKTokenContract.ERC20balanceOf(owner.address)).to.equal(0);
      await P2PMarketContract.connect(addr1).takeBuyOffer(1, 5);
      // Check for transaction fee for platform
      expect(await NOKTokenContract.ERC20balanceOf(owner.address)).to.equal(
        750
      );

      expect(await NOKTokenContract.ERC20balanceOf(addr1.address)).to.equal(
        392992750
      );
      expect(await ArtWorkNFTContract.ERC20balanceOf(addr1.address)).to.equal(
        69995
      );
      expect(await ArtWorkNFTContract.ERC20balanceOf(addr5.address)).to.equal(
        5
      );
    });
    it("User can place a sellOffer", async function () {
      //+-Placing a sell offer:_
      await ArtWorkNFTContract.connect(addr1).ERC20approve(
        P2PMarketContract.address,
        10
      );
      await ITOContract.connect(owner).setIsFreezedAfterITO(
        ArtWorkNFTContract.address,
        false
      );
      sellOfferId = expect(
        await P2PMarketContract.connect(addr1).placeSellOffer(
          ArtWorkNFTContract.address,
          10,
          2000
        )
      ).to.emit(P2PMarketContract, "TradeOfferCreated");
    });
    it("User can take a sellOffer", async function () {
      //+-Make sure that token holders can accept a buy offer:_
      await NOKTokenContract.connect(addr2).ERC20approve(
        P2PMarketContract.address,
        15000
      );

      await P2PMarketContract.connect(addr2).takeSellOffer(2, 5);
      expect(await NOKTokenContract.ERC20balanceOf(addr1.address)).to.equal(
        392999050
      );
      expect(await ArtWorkNFTContract.ERC20balanceOf(addr1.address)).to.equal(
        69985
      );
      expect(await ArtWorkNFTContract.ERC20balanceOf(addr2.address)).to.equal(
        6
      );
    });
  });

  describe("English Auctions can be Created and Users can Bid and Win them:_", async function () {
    //+-Enabling an ArtWork N.F.T. to be Sold by Auction:_
    it("Owner can Enable an ArtWork to be Sold by English Auction", async function () {
      await expect(
        OAMEAContract.connect(owner).enableEnglishAuction(
          ArtWorkNFTContract.address,
          true
        )
      )
        .to.emit(OAMEAContract, "EnglishAuctionAllowed")
        .withArgs(ArtWorkNFTContract.address, true);
    });
    it("Owner can add ArtWork to English Auction listing", async function () {
      // console.log(
      //   "+-Platform Owner NOK F.Token Balance before Creation of E.Auction:_",
      //   await NOKTokenContract.ERC20balanceOf(owner.address)
      // );
      //+-ArtWork Owner can place for Sale the N.F.T. in an English Auction of 7 Days for NOK$200.000,00:_
      await expect(
        OAMEAContract.connect(collector).createMarketEnglishAuction(
          ArtWorkNFTContract.address,
          20000000,
          3
        )
      )
        .to.emit(NFTSalesContract, "MarketItemCreated")
        .withArgs(
          1,
          ArtWorkNFTContract.address,
          collector.address,
          "0x0000000000000000000000000000000000000000",
          20000000,
          false
        ); //+-(We Expect the First Parameter, the ItemId, to be == 1 since it would be the 1st Item to be Created in the N.F.T. Sales S.C.).
      // console.log(
      //   "+-If the N.F.T. was successfully Transferred to the O.A.M.E.A. S.C., this Value should be == 1:_ ",
      //   await ArtWorkNFTContract.ERC721balanceOf(OAMEAContract.address)
      // );
    });
    it("User of the platform can bid in english auction", async function () {
      //+-Checking Addr1 NOK Token Balance before Bidding in the E.A. It should be = 3.930.017,50 (two decimal places):_
      await expect(
        NOKTokenContract.connect(addr1).ERC20approve(
          OAMEAContract.address,
          21000000
        )
      );
      //+-Addr1 makes a Bid of NOK Fiat Tokens 210.000,00:_
      await expect(OAMEAContract.connect(addr1).bidEnglishAuction(1, 21000000))
        .to.emit(OAMEAContract, "HighestBidIncrease")
        .withArgs(addr1.address, 21000000);
      //+-We Check that the User Addr1 Actually spent NOK Fiat Tokens 210.000,00:_
      await expect(
        await NOKTokenContract.ERC20balanceOf(addr1.address)
      ).to.equal(371999050);
      // console.log(
      //   "Addr1 NOK Balance after making a Bid of NOK 210.000,00:_",
      //   NOKTokenContract.ERC20balanceOf(addr1.address)
      // );
    });

    it("More users can bid in the english auction", async function () {
      await expect(
        NOKTokenContract.connect(addr2).ERC20approve(
          OAMEAContract.address,
          24200000
        )
      );
      //+-Addr2 makes a Bid of NOK Fiat Tokens 220.000,00:_
      await expect(OAMEAContract.connect(addr2).bidEnglishAuction(1, 22000000))
        .to.emit(OAMEAContract, "HighestBidIncrease")
        .withArgs(addr2.address, 22000000);
      //+-We Check that the User Addr2 Actually spent NOK Fiat Tokens 220.000,00:_
      await expect(
        await NOKTokenContract.ERC20balanceOf(addr2.address)
      ).to.equal(77992900);
    });
    it("Users Cannot Bid after the English Auction Time Ended, Platform can end the auction and the winner is declared", async function () {
      await network.provider.send("evm_increaseTime", [605700]); //+-605.700 Seconds = 7 Days and 15 Minutes.
      await network.provider.send("evm_mine");
      await expect(
        NOKTokenContract.connect(addr1).ERC20approve(
          OAMEAContract.address,
          23000000
        )
      );
      //+-Addr1 Tries to make a new Bid of NOK Fiat Tokens 230.000,00 after the Auction Time Ended:_
      try {
        await OAMEAContract.connect(addr1).bidEnglishAuction(1, 23000000);
      } catch (e) {
        expect(e.message).to.equal("VM Exception while processing transaction: reverted with reason string 'The auction has already ended.'");
      }
      await expect(
        OAMEAContract.connect(owner).englishAuctionEnd(
          ArtWorkNFTContract.address,
          1
        )
      )
        .to.emit(OAMEAContract, "EnglishAuctionEnded")
        .withArgs(addr2.address, 22000000);
      //+-We Check that the User Addr2 Actually spent NOK Fiat Tokens 220.000,00:_
      await expect(
        await ArtWorkNFTContract.ERC721balanceOf(addr2.address)
      ).to.equal(1);
    });
  });
  describe("Platform fees should have been collected", async function () {
    it("Owner collected platform fees", async function () {
      /**+-Addr2 made the Winner Bid of NOK FiatTokens 220.000,00 and the SharesSalesPercentageFee of 10%
       * (NOK FiatTokens 22.000,00) that The Owner is Paid should Come from there and be Added to the NOK
       * FiatTokens 17,50 had before the Creations of this E.Auction:_*/
      expect(await NOKTokenContract.ERC20balanceOf(owner.address)).to.equal(
        2201450
      );
    });
  });
});
