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

describe("Open Art Market: Buyout Scenario", function () {
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
    await setupArtWorkNFT("OAMNFT4", owner, server, collector, addr1, addr2);


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
    expect(await ArtWorkNFTContract.ERC721name()).to.equal("Artwork 2022 04");
    expect(await ArtWorkNFTContract.ERC721symbol()).to.equal("OAM2204");
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
  it("Members can buy into ITO", async function () {
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
    await ITOContract.connect(addr6).buyShare(ArtWorkNFTContract.address, 50);
    await ITOContract.connect(addr7).buyShare(ArtWorkNFTContract.address, 50);
    await ITOContract.connect(addr8).buyShare(ArtWorkNFTContract.address, 50);
    await ITOContract.connect(addr9).buyShare(ArtWorkNFTContract.address, 50);
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
      0
    );
    expect(await NOKTokenContract.ERC20balanceOf(collector.address)).to.equal(
      400000
    );
    expect(await NOKTokenContract.ERC20balanceOf(owner.address)).to.equal(0);
    expect(await ArtWorkNFTContract.ERC20balanceOf(addr6.address)).to.equal(50);
    expect(await ArtWorkNFTContract.ERC20balanceOf(addr7.address)).to.equal(50);
    expect(await ArtWorkNFTContract.ERC20balanceOf(addr8.address)).to.equal(50);
    expect(await ArtWorkNFTContract.ERC20balanceOf(addr9.address)).to.equal(50);
    expect(await ArtWorkNFTContract.ERC20balanceOf(collector.address)).to.equal(
      750
    );
    expect(await ArtWorkNFTContract.ERC20balanceOf(owner.address)).to.equal(50);
  });
  it("DAO has voted over buyout price, and platform sets it", async function () {
    await expect(
      NFTSalesContract.connect(owner).setNFTBuyoutValueInOriginalDAOFiatToken(
        ArtWorkNFTContract.address,
        2000000
      )
    )
      .to.emit(NFTSalesContract, "BuyOutPriceSet")
      .withArgs(ArtWorkNFTContract.address);
  });
  it("Once buyout price is set, user can buy Artwork outright", async function () {
    await transferMoneyToWallet(owner, addr10.address, 2000000);
    await NOKTokenContract.connect(addr10).ERC20approve(
      NFTSalesContract.address,
      2000000
    );
    await expect(
      NFTSalesContract.connect(addr10).NFTBuyOut(ArtWorkNFTContract.address)
    )
      .to.emit(NFTSalesContract, "BuyOut")
      .withArgs(ArtWorkNFTContract.address, 2000000);
  });
  it("The user gets the Artwork outright", async function () {
    expect(await ArtWorkNFTContract.ERC721balanceOf(addr10.address)).to.equal(
      1
    );
  });
  it("The tokenholders gets correct amount of currency tokens", async function () {
    expect(await NOKTokenContract.ERC20balanceOf(addr6.address)).to.equal(
      0
    );
    expect(await ArtWorkNFTContract.ERC20balanceOf(addr6.address)).to.equal(50);
    await ArtWorkNFTContract.connect(addr6).ERC20approve(NFTSalesContract.address, 50);
    await NFTSalesContract.connect(addr6).claimBuyOutOrAuctionReward(ArtWorkNFTContract.address);
    ethers.provider.send("evm_mine", []);
    expect(await NOKTokenContract.ERC20balanceOf(addr6.address)).to.equal(88000);

    expect(await NOKTokenContract.ERC20balanceOf(addr7.address)).to.equal(
      0
    );
    expect(await ArtWorkNFTContract.ERC20balanceOf(addr7.address)).to.equal(50);
    await ArtWorkNFTContract.connect(addr7).ERC20approve(NFTSalesContract.address, 50);
    await NFTSalesContract.connect(addr7).claimBuyOutOrAuctionReward(ArtWorkNFTContract.address);
    ethers.provider.send("evm_mine", []);
    expect(await NOKTokenContract.ERC20balanceOf(addr7.address)).to.equal(88000);

    expect(await NOKTokenContract.ERC20balanceOf(addr8.address)).to.equal(
      0
    );
    expect(await ArtWorkNFTContract.ERC20balanceOf(addr8.address)).to.equal(50);
    await ArtWorkNFTContract.connect(addr8).ERC20approve(NFTSalesContract.address, 50);
    await NFTSalesContract.connect(addr8).claimBuyOutOrAuctionReward(ArtWorkNFTContract.address);
    ethers.provider.send("evm_mine", []);
    expect(await NOKTokenContract.ERC20balanceOf(addr8.address)).to.equal(88000);

    expect(await NOKTokenContract.ERC20balanceOf(addr9.address)).to.equal(
      0
    );
    expect(await ArtWorkNFTContract.ERC20balanceOf(addr9.address)).to.equal(50);
    await ArtWorkNFTContract.connect(addr9).ERC20approve(NFTSalesContract.address, 50);
    await NFTSalesContract.connect(addr9).claimBuyOutOrAuctionReward(ArtWorkNFTContract.address);
    ethers.provider.send("evm_mine", []);
    expect(await NOKTokenContract.ERC20balanceOf(addr9.address)).to.equal(88000);

  });
  it("Platform receives fees from payout", async function () {
    expect (await marketPlaceContract.getSharesSalesPercPrice()).to.equal(12);
    expect(await NOKTokenContract.ERC20balanceOf(owner.address)).to.equal(48000);
  });
  it("Platform can collect currency tokens for artwork tokens", async function () {
    expect(await NOKTokenContract.ERC20balanceOf(owner.address)).to.equal(
      48000
    );
    expect(await ArtWorkNFTContract.ERC20balanceOf(owner.address)).to.equal(50);
    await ArtWorkNFTContract.connect(owner).ERC20approve(NFTSalesContract.address, 50);
    await NFTSalesContract.connect(owner).claimBuyOutOrAuctionReward(ArtWorkNFTContract.address);
    ethers.provider.send("evm_mine", []);
    expect(await NOKTokenContract.ERC20balanceOf(owner.address)).to.equal(148000);
  });
  it("The artwork owner can collect correct amount of currency tokens", async function () {
    expect(await NOKTokenContract.ERC20balanceOf(collector.address)).to.equal(
      400000
    );
    expect(await ArtWorkNFTContract.ERC20balanceOf(collector.address)).to.equal(750);
    await ArtWorkNFTContract.connect(collector).ERC20approve(NFTSalesContract.address, 750);
    await NFTSalesContract.connect(collector).claimBuyOutOrAuctionReward(ArtWorkNFTContract.address);
    ethers.provider.send("evm_mine", []);
    expect(await NOKTokenContract.ERC20balanceOf(collector.address)).to.equal(1720000);
  });

});
