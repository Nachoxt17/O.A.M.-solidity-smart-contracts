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

describe("Open Art Market: Dutch auction Scenario", function () {
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
      addr8,
      addr9,
      addr10,
      addr11,
      addr12,
      addr13,
      addr14,
      addr15,
      addr16,
      server,
      admin,
      ...addrs
    ] = await ethers.getSigners();
    await setupCurrencyTokens(owner);
    await setupSupportContracts(owner);
    await setupServersAndAdmin(owner, server, admin);
    await setupArtWorkNFT("OAMNFT3", owner, server, collector, addr1, addr2);


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
  it("We want to have OAM 3 NFT as the artwork", async function () {
    expect(await ArtWorkNFTContract.ERC721name()).to.equal("Artwork 2022 03");
    expect(await ArtWorkNFTContract.ERC721symbol()).to.equal("OAM2203");
    expect(
      await UserValidationContract.onlyPlatformNFTs(ArtWorkNFTContract.address)
    ).to.equal(true);
  });
  it("We can set the value and amount token shares to exist", async function () {
    await ITOContract.connect(owner).setNFTInitialPrice(
      ArtWorkNFTContract.address,
      2000000
    );
    await ITOContract.connect(owner).setNFTInitialTokenShares(
      ArtWorkNFTContract.address,
      1000
    );

    // Checking that we get expected values from setup
    expect(
      (await ITOContract.getNFTValue(ArtWorkNFTContract.address)).toString()
    ).to.equal("2000000");
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
    ).to.equal("2000");
  });
  it("We can start ITO and set 90% of tokens available for sale", async function () {
    await setITOTokensAvailable(ArtWorkNFTContract.address, owner, 900);
    // The ITO should have 70000 shares available for sale
    expect(
      await ITOContract.getItoInitialAvailableShares(ArtWorkNFTContract.address)
    ).to.equal(900);
    expect(
      await ITOContract.getItoStarted(ArtWorkNFTContract.address)
    ).to.equal(false);

    await expect(
      ITOContract.connect(owner).startIto(ArtWorkNFTContract.address)
    )
      .to.emit(ITOContract, "StartITO")
      .withArgs(ArtWorkNFTContract.address);

    expect(
      await ITOContract.getItoStarted(ArtWorkNFTContract.address)
    ).to.equal(true);
  });
  it("Members can buy into I.T.O.", async function () {
    await UserValidationContract.connect(owner).addVerified(addr6.address);
    await UserValidationContract.connect(owner).addVerified(addr7.address);
    await UserValidationContract.connect(owner).addVerified(addr8.address);
    await UserValidationContract.connect(owner).addVerified(addr9.address);

    // Check that we have the expected number of shares
    expect(
      await ITOContract.getItoShareSupply(ArtWorkNFTContract.address)
    ).to.equal(1000);
    // Check that we have the expected number of shares
    expect(
      await ITOContract.getItoSharePrice(ArtWorkNFTContract.address)
    ).to.equal(2000);

    await transferMoneyToWallet(owner, addr6.address, 100000);
    await transferMoneyToWallet(owner, addr7.address, 100000);
    await transferMoneyToWallet(owner, addr8.address, 100000);
    await transferMoneyToWallet(owner, addr9.address, 100000);

    await NOKTokenContract.connect(addr6).ERC20approve(
      ITOContract.address,
      100000
    );
    await NOKTokenContract.connect(addr7).ERC20approve(
      ITOContract.address,
      100000
    );
    await NOKTokenContract.connect(addr8).ERC20approve(
      ITOContract.address,
      100000
    );
    await NOKTokenContract.connect(addr9).ERC20approve(
      ITOContract.address,
      100000
    );
    // Buy tokens
    await ITOContract.connect(addr6).buyShare(ArtWorkNFTContract.address, 10);
    await ITOContract.connect(addr7).buyShare(ArtWorkNFTContract.address, 10);
    await ITOContract.connect(addr8).buyShare(ArtWorkNFTContract.address, 10);
    await ITOContract.connect(addr9).buyShare(ArtWorkNFTContract.address, 10);
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
    expect(await NOKTokenContract.ERC20balanceOf(addr6.address)).to.equal(
      80000
    );
    expect(await NOKTokenContract.ERC20balanceOf(collector.address)).to.equal(
      80000
    );
    expect(await NOKTokenContract.ERC20balanceOf(owner.address)).to.equal(0);
    expect(await ArtWorkNFTContract.ERC20balanceOf(addr6.address)).to.equal(10);
    expect(await ArtWorkNFTContract.ERC20balanceOf(addr7.address)).to.equal(10);
    expect(await ArtWorkNFTContract.ERC20balanceOf(addr8.address)).to.equal(10);
    expect(await ArtWorkNFTContract.ERC20balanceOf(addr9.address)).to.equal(10);
    expect(await ArtWorkNFTContract.ERC20balanceOf(collector.address)).to.equal(
      910
    );
    expect(await ArtWorkNFTContract.ERC20balanceOf(owner.address)).to.equal(50);
  });
  describe("We can offer the art work in an Dutch Auction", async function () {
    it("Owner can Enable an ArtWork to be Sold by Auction", async function () {
      await expect(
        OAMDAContract.connect(owner).enableDutchAuction(
          ArtWorkNFTContract.address,
          true
        )
      )
        .to.emit(OAMDAContract, "DutchAuctionAllowed")
        .withArgs(ArtWorkNFTContract.address, true);
    });
    it("Collector can add ArtWork to Auction listing", async function () {
      //https://ethereum.stackexchange.com/questions/86633/time-dependent-tests-with-hardhat
      //https://hardhat.org/hardhat-network/reference/#special-testing-debugging-methods
      await network.provider.send("evm_setNextBlockTimestamp", [1654034460]);
      await network.provider.send("evm_mine"); //+-This will have 2022-06-01 00:01 as its TimeStamp, no matter what the previous Block has.
      //+-DutchAuctions Parameters:_StartingPrice:_ 100.000,00.-EndingPrice:_ 15.000,00-daysAuctionEndTime:_ 7 Days.
      await expect(
        OAMDAContract.connect(collector).createMarketDutchAuction(
          ArtWorkNFTContract.address,
          10000000,
          1500000,
          3
        )
      )
        .to.emit(NFTSalesContract, "MarketItemCreated")
        .withArgs(
          1,
          ArtWorkNFTContract.address,
          collector.address,
          "0x0000000000000000000000000000000000000000",
          10000000,
          false
        ); //+-(We Expect the First Parameter, the ItemId, to be == 1 since it would be the 1st Item to be Created in the N.F.T. Sales S.C.).
      await transferMoneyToWallet(owner, addr1.address, 21000000);
      await expect(
        NOKTokenContract.connect(addr1).ERC20approve(
          OAMDAContract.address,
          21000000
        )
      );
      await network.provider.send("evm_setNextBlockTimestamp", [1654034490]);
      await network.provider.send("evm_mine"); //+-This will have 2022-06-02 00:01 as its TimeStamp, no matter what the previous Block has.
//      console.log("+-Current Time After Advancing E.V.M. Time:_ ", Date.now());
      //+-Addr1 makes a Bid to the Dutch Auction:_
      let startingPrice = await OAMDAContract.getStartingPriceDutchAuction(1);
      let currentPrice = await OAMDAContract.getCurrentPriceDutchAuction(1);
      let paymentAmount =
        currentPrice +
        (currentPrice / 100) * marketPlaceContract.getSharesSalesPercPrice();
      await NOKTokenContract.connect(addr1).ERC20approve(
        OAMDAContract.address,
        12000000
      ); /**+-120.000,00 is a Mock Number that is = to DutchAuctionStartingPrice + 20%(The Maximum Possible Number for
      "SharesSalesPercPrice"). The Number was Implemented this way because is the Simpler one for this Test Purpose.*/
      await expect(
        OAMDAContract.connect(addr1).createDutchAuctionSale(
          ArtWorkNFTContract.address,
          1
        )
      )
        .to.emit(OAMDAContract, "DutchAuctionEnded")
        .withArgs(addr1.address, 9998951);
      // console.log(
      //   "Addr1 NOK Balance:_ ",
      //   await NOKTokenContract.ERC20balanceOf(addr1.address)
      // );
    });
  });
});
