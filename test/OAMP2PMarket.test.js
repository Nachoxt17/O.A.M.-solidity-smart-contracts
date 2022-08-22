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

describe("Open Art Market: P2P Market Scenario", function () {
  before(async function () {
    [
      owner,
      collector,
      addr1,
      addr2,
      addr3,
      server,
      admin,
      addr6,
      addr7,
      addr8,
      addr9,
      addr10,
      addr11,
      addr12,
      addr13,
      addr14,
      addr15,
      addr16,
      addr17,
      ...addrs
    ] = await ethers.getSigners();
    await setupCurrencyTokens(owner);
    await setupSupportContracts(owner);
    await setupServersAndAdmin(owner, server, admin);
    await setupArtWorkNFT("OAMNFT2", owner, server, collector, addr1, addr2);

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

    await transferMoneyToWallet(owner, addr1.address, 400000000);
    await transferMoneyToWallet(owner, addr2.address, 100000000);
  });
  it("We want to have OAM 2 NFT as the artwork", async function () {
    expect(await ArtWorkNFTContract.ERC721name()).to.equal("Artwork 2022 02");
    expect(await ArtWorkNFTContract.ERC721symbol()).to.equal("OAM2202");
  });
  it("We can set the value and amount token shares to exist", async function () {
    await ITOContract.connect(owner).setNFTInitialPrice(
      ArtWorkNFTContract.address,
      10000000
    );
    await ITOContract.connect(owner).setNFTInitialTokenShares(
      ArtWorkNFTContract.address,
      1000
    );

    // Checking that we get expected values from setup
    expect(
      (await ITOContract.getNFTValue(ArtWorkNFTContract.address)).toString()
    ).to.equal("10000000");
    expect(
      (
        await ITOContract.getItoShareSupply(ArtWorkNFTContract.address)
      ).toString()
    ).to.equal("1000");
    // Checking that token value calculated correctly:
    expect(
      (
        await ITOContract.getItoSharePrice(ArtWorkNFTContract.address)
      ).toString()
    ).to.equal("10000");
  });
  it("We can start ITO and set 90% of tokens available for sale", async function () {
    await setITOTokensAvailable(ArtWorkNFTContract.address, owner, 900);
    // The ITO should have 70000 shares available for sale
    expect(
      await ITOContract.getItoInitialAvailableShares(ArtWorkNFTContract.address)
    ).to.equal(900);

    await expect(
      ITOContract.connect(owner).startIto(ArtWorkNFTContract.address)
    )
      .to.emit(ITOContract, "StartITO")
      .withArgs(ArtWorkNFTContract.address);
  });
  it("Members can buy into ITO", async function () {
    await UserValidationContract.connect(owner).addVerified(addr6.address);
    await UserValidationContract.connect(owner).addVerified(addr7.address);
    await UserValidationContract.connect(owner).addVerified(addr8.address);
    await UserValidationContract.connect(owner).addVerified(addr9.address);
    await UserValidationContract.connect(owner).addVerified(addr10.address);
    await UserValidationContract.connect(owner).addVerified(addr11.address);
    await UserValidationContract.connect(owner).addVerified(addr12.address);
    await UserValidationContract.connect(owner).addVerified(addr13.address);
    await UserValidationContract.connect(owner).addVerified(addr14.address);
    await UserValidationContract.connect(owner).addVerified(addr15.address);
    await UserValidationContract.connect(owner).addVerified(addr16.address);
    await UserValidationContract.connect(owner).addVerified(addr17.address);

    await transferMoneyToWallet(owner, addr6.address, 900000);
    await transferMoneyToWallet(owner, addr7.address, 900000);
    await transferMoneyToWallet(owner, addr8.address, 900000);
    await transferMoneyToWallet(owner, addr9.address, 900000);
    await transferMoneyToWallet(owner, addr10.address, 900000);
    await transferMoneyToWallet(owner, addr11.address, 900000);
    await transferMoneyToWallet(owner, addr12.address, 900000);
    await transferMoneyToWallet(owner, addr13.address, 900000);
    await transferMoneyToWallet(owner, addr14.address, 900000);
    await transferMoneyToWallet(owner, addr15.address, 900000);
    await transferMoneyToWallet(owner, addr16.address, 900000);
    await transferMoneyToWallet(owner, addr17.address, 900000);

    await NOKTokenContract.connect(addr6).ERC20approve(
      ITOContract.address,
      900000
    );
    await NOKTokenContract.connect(addr7).ERC20approve(
      ITOContract.address,
      900000
    );
    await NOKTokenContract.connect(addr8).ERC20approve(
      ITOContract.address,
      900000
    );
    await NOKTokenContract.connect(addr9).ERC20approve(
      ITOContract.address,
      900000
    );
    await NOKTokenContract.connect(addr10).ERC20approve(
      ITOContract.address,
      900000
    );
    await NOKTokenContract.connect(addr11).ERC20approve(
      ITOContract.address,
      900000
    );
    await NOKTokenContract.connect(addr12).ERC20approve(
      ITOContract.address,
      900000
    );
    await NOKTokenContract.connect(addr13).ERC20approve(
      ITOContract.address,
      900000
    );
    await NOKTokenContract.connect(addr14).ERC20approve(
      ITOContract.address,
      900000
    );
    await NOKTokenContract.connect(addr15).ERC20approve(
      ITOContract.address,
      900000
    );
    await NOKTokenContract.connect(addr16).ERC20approve(
      ITOContract.address,
      900000
    );
    // Buy tokens
    await ITOContract.connect(addr6).buyShare(ArtWorkNFTContract.address, 90);
    await ITOContract.connect(addr7).buyShare(ArtWorkNFTContract.address, 90);
    await ITOContract.connect(addr8).buyShare(ArtWorkNFTContract.address, 90);
    await ITOContract.connect(addr9).buyShare(ArtWorkNFTContract.address, 90);
    await ITOContract.connect(addr10).buyShare(ArtWorkNFTContract.address, 90);
    await ITOContract.connect(addr11).buyShare(ArtWorkNFTContract.address, 90);
    await ITOContract.connect(addr12).buyShare(ArtWorkNFTContract.address, 90);
    await ITOContract.connect(addr13).buyShare(ArtWorkNFTContract.address, 90);
    await ITOContract.connect(addr14).buyShare(ArtWorkNFTContract.address, 90);
    await ITOContract.connect(addr15).buyShare(ArtWorkNFTContract.address, 90);
    try {
      await ITOContract.connect(addr16).buyShare(
        ArtWorkNFTContract.address,
        90
      );
    } catch (error) {
      expect(error.message).to.equal(
        "VM Exception while processing transaction: reverted with reason string 'Not Enough Shares left.'"
      );
    }
    // Check that we have the expected number of shares
    expect(
      await ITOContract.getItoShareSupply(ArtWorkNFTContract.address)
    ).to.equal(1000);
    // Check that we have the expected number of shares
    expect(
      await ITOContract.getItoSharePrice(ArtWorkNFTContract.address)
    ).to.equal(10000);
  });
  it("We can close ITO and give remaining tokens to the artwork owner", async function () {
    await expect(
      ITOContract.connect(owner).finishIto(ArtWorkNFTContract.address)
    )
      .to.emit(ITOContract, "EndITO")
      .withArgs(ArtWorkNFTContract.address);

    expect(
      await ITOContract.connect(collector).withdrawItoUnSoldShares(
        ArtWorkNFTContract.address
      )
    )
      .to.emit(DAOContract, "VoterRegistered")
      .withArgs(ArtWorkNFTContract.address, collector.address);
  });
  it("Balances of each address should be correct after ITO", async function () {
    expect(await NOKTokenContract.ERC20balanceOf(addr6.address)).to.equal(0);
    expect(await NOKTokenContract.ERC20balanceOf(collector.address)).to.equal(
      9000000
    );
    expect(await NOKTokenContract.ERC20balanceOf(owner.address)).to.equal(0);
    expect(await ArtWorkNFTContract.ERC20balanceOf(addr6.address)).to.equal(90);
    expect(await ArtWorkNFTContract.ERC20balanceOf(addr7.address)).to.equal(90);
    expect(await ArtWorkNFTContract.ERC20balanceOf(addr8.address)).to.equal(90);
    expect(await ArtWorkNFTContract.ERC20balanceOf(addr9.address)).to.equal(90);
    expect(await ArtWorkNFTContract.ERC20balanceOf(addr10.address)).to.equal(
      90
    );
    expect(await ArtWorkNFTContract.ERC20balanceOf(addr11.address)).to.equal(
      90
    );
    expect(await ArtWorkNFTContract.ERC20balanceOf(addr12.address)).to.equal(
      90
    );
    expect(await ArtWorkNFTContract.ERC20balanceOf(addr13.address)).to.equal(
      90
    );
    expect(await ArtWorkNFTContract.ERC20balanceOf(addr14.address)).to.equal(
      90
    );
    expect(await ArtWorkNFTContract.ERC20balanceOf(addr15.address)).to.equal(
      90
    );
    expect(await ArtWorkNFTContract.ERC20balanceOf(addr16.address)).to.equal(0);
    expect(await ArtWorkNFTContract.ERC20balanceOf(collector.address)).to.equal(
      50
    );
    expect(await ArtWorkNFTContract.ERC20balanceOf(owner.address)).to.equal(50);
  });
  it("User wants to buy in second hand market", async function () {
    await NOKTokenContract.connect(addr17).ERC20approve(
      P2PMarketContract.address,
      900000
    );
    expect(
      await P2PMarketContract.connect(addr17).placeBuyOffer(
        ArtWorkNFTContract.address,
        2,
        15000
      )
    ).to.emit(P2PMarketContract, "TradeOfferCreated");
    await NOKTokenContract.connect(addr16).ERC20approve(
      P2PMarketContract.address,
      900000
    );
    expect(
      await P2PMarketContract.connect(addr16).placeBuyOffer(
        ArtWorkNFTContract.address,
        2,
        15000
      )
    ).to.emit(P2PMarketContract, "TradeOfferCreated");
  });
  it("User can take buy order in second hand market", async function () {
    await ITOContract.connect(owner).setIsFreezedAfterITO(
      ArtWorkNFTContract.address,
      false
    );
    await ArtWorkNFTContract.connect(addr6).ERC20approve(
      P2PMarketContract.address,
      2
    );

    await P2PMarketContract.connect(addr6).takeBuyOffer(2, 2);

    expect(await ArtWorkNFTContract.ERC20balanceOf(addr6.address)).to.equal(
      "88"
    );

    expect(await ArtWorkNFTContract.ERC20balanceOf(addr16.address)).to.equal(
      "2"
    );

    expect(await NOKTokenContract.ERC20balanceOf(addr16.address)).to.equal(
      870000
    );
    expect(await NOKTokenContract.ERC20balanceOf(addr6.address)).to.equal(
      26400
    );
    expect(await NOKTokenContract.ERC20balanceOf(owner.address)).to.equal(3600);
  });
  it("User wants to sell tokens in second hand market", async function () {
    await ArtWorkNFTContract.connect(addr9).ERC20approve(
      P2PMarketContract.address,
      90
    );
    expect(
      await P2PMarketContract.connect(addr9).placeSellOffer(
        ArtWorkNFTContract.address,
        90,
        5000
      )
    ).to.emit(P2PMarketContract, "TradeOfferCreated");
    await ArtWorkNFTContract.connect(addr6).ERC20approve(
      P2PMarketContract.address,
      10
    );
    expect(
      await P2PMarketContract.connect(addr6).placeSellOffer(
        ArtWorkNFTContract.address,
        10,
        4500
      )
    ).to.emit(P2PMarketContract, "TradeOfferCreated");
  });
  it("Market can list a Sell Order", async function () {
    let market = await P2PMarketContract.fetchP2PMarketOffers();
    //+-The 3rd Order Placed was a Sell Order by Addr9.
    expect(market[2].typeOfTrade).to.equal(0);
    expect(market[2]._offerCreator).to.equal(addr9.address);
    expect(market[2].assetAddress).to.equal(ArtWorkNFTContract.address);
    expect(market[2].pricePerToken).to.equal(5000);
    expect(market[2].assetAmount).to.equal(90);
    expect(market[2].sold).to.be.false;
    //+-The 4th Order Placed was a Sell Order by Addr6.
    expect(market[3].typeOfTrade).to.equal(0);
    expect(market[3]._offerCreator).to.equal(addr6.address);
    expect(market[3].assetAddress).to.equal(ArtWorkNFTContract.address);
    expect(market[3].pricePerToken).to.equal(4500);
    expect(market[3].assetAmount).to.equal(10);
    expect(market[3].sold).to.be.false;
  });
  it("User can take sell order in second hand market", async function () {
    await ITOContract.connect(owner).setIsFreezedAfterITO(
      ArtWorkNFTContract.address,
      false
    );
    expect(
      await ArtWorkNFTContract.ERC20balanceOf(P2PMarketContract.address)
    ).to.equal("100");
    await NOKTokenContract.connect(addr1).ERC20approve(
      P2PMarketContract.address,
      9000
    );
    await P2PMarketContract.connect(addr1).takeSellOffer(4, 2);

    expect(await ArtWorkNFTContract.ERC20balanceOf(addr1.address)).to.equal(
      "2"
    );
    expect(
      await ArtWorkNFTContract.ERC20balanceOf(P2PMarketContract.address)
    ).to.equal("98");

    expect(await NOKTokenContract.ERC20balanceOf(addr6.address)).to.equal(
      34320
    );
    expect(await NOKTokenContract.ERC20balanceOf(owner.address)).to.equal(4680);
  });
  it("Market can list remainder of a Sell Orders", async function () {
    let market = await P2PMarketContract.fetchP2PMarketOffers();
    //console.log(market);
    expect(market[3].typeOfTrade).to.equal(0);
    expect(market[3].assetAddress).to.equal(ArtWorkNFTContract.address);
    expect(market[3].pricePerToken).to.equal(4500);
    expect(market[3].assetAmount).to.equal(8);
    expect(market[3].sold).to.be.false;
  });
  it("Users can withdraw offers in the marketplace", async function () {
    await P2PMarketContract.connect(addr17).withdrawOffer(1, true);
    await P2PMarketContract.connect(addr6).withdrawOffer(4, false);
    await P2PMarketContract.connect(addr9).withdrawOffer(3, false);
    let market = await P2PMarketContract.fetchP2PMarketOffers();
    //console.log(market);
    expect(market).to.be.lengthOf(1);
  });
});
