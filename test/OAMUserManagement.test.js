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

describe("Open Art Market: User & NFT management", function () {
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
      admin,
      addr16,
      server,
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
    await UserValidationContract.connect(owner).addPlatformNFT(
      DAOContract.address
    );
  });
  it("The contract has an owner that controls its members", async function () {
    try {
      await UserValidationContract.connect(addr1).addVerified(addr1.address);
    } catch (error) {
      expect(error.message).to.eq(
        "VM Exception while processing transaction: reverted with reason string 'Only Owner, Server or Admin can perform this action'"
      );
    }
    expect(await UserValidationContract.getUsersAmount()).to.eq(7);
    expect(await UserValidationContract.owner()).to.eq(owner.address);
  });
  it("The contract can add servers that get special access to functions", async function () {
    await UserValidationContract.connect(owner).addServer(addr14.address);
    expect(await UserValidationContract.isServer(addr14.address)).to.be.true;
    await UserValidationContract.connect(owner).addServer(server.address);
    expect(await UserValidationContract.isServer(server.address)).to.be.true;
  });
  it("The contract can remove servers from special access to functions", async function () {
    await UserValidationContract.connect(owner).removeServer(addr14.address);
    expect(await UserValidationContract.isServer(addr14.address)).to.be.false;
  });

  it("The contract can add admins that get special access to functions", async function () {
    await UserValidationContract.connect(owner).addAdmin(addr16.address);
    expect(await UserValidationContract.isAdmin(addr16.address)).to.be.true;
    await UserValidationContract.connect(owner).addAdmin(admin.address);
    expect(await UserValidationContract.isAdmin(admin.address)).to.be.true;
  });

  it("The contract can remove admins from special access to functions", async function () {
    await UserValidationContract.connect(owner).removeAdmin(addr16.address);
    expect(await UserValidationContract.isAdmin(addr16.address)).to.be.false;
  });

  it("Removed server and admin wallets cannot add people to the platform", async function () {
    // Removed server wallet
    try {
      await UserValidationContract.connect(addr14).addVerified(addr14.address);
    } catch (error) {
      expect(error.message).to.eq(
        "VM Exception while processing transaction: reverted with reason string 'Only Owner, Server or Admin can perform this action'"
      );
    }
    // Removed admin wallet
    try {
      await UserValidationContract.connect(addr16).addVerified(addr16.address);
    } catch (error) {
      expect(error.message).to.eq(
        "VM Exception while processing transaction: reverted with reason string 'Only Owner, Server or Admin can perform this action'"
      );
    }
    // Member
    try {
      await UserValidationContract.connect(addr1).addVerified(addr1.address);
    } catch (error) {
      expect(error.message).to.eq(
        "VM Exception while processing transaction: reverted with reason string 'Only Owner, Server or Admin can perform this action'"
      );
    }
    // Non registered wallet
    try {
      await UserValidationContract.connect(addr11).addVerified(addr11.address);
    } catch (error) {
      expect(error.message).to.eq(
        "VM Exception while processing transaction: reverted with reason string 'Only Owner, Server or Admin can perform this action'"
      );
    }
  });

  it("Users can be added to the contract by owner", async function () {
    expect(await UserValidationContract.isVerified(collector.address)).to.be
      .true;
    await UserValidationContract.connect(owner).addVerified(addr1.address);
    expect(await UserValidationContract.isVerified(addr1.address)).to.be.true;
  });
  it("Users can be added to the contract by server", async function () {
    await UserValidationContract.connect(server).addVerified(addr2.address);
    expect(await UserValidationContract.isVerified(addr2.address)).to.be.true;
    expect(await UserValidationContract.getUsersAmount()).to.eq(10);
  });
  it("Users can be added to the contract by admin", async function () {
    await UserValidationContract.connect(admin).addVerified(addr3.address);
    expect(await UserValidationContract.isVerified(addr3.address)).to.be.true;
    expect(await UserValidationContract.getUsersAmount()).to.eq(11);
  });
  it("Users can be removed to the contract", async function () {
    await UserValidationContract.connect(owner).removeVerified(addr1.address);
    expect(await UserValidationContract.isVerified(addr1.address)).to.be.false;
    await UserValidationContract.connect(owner).removeVerified(addr2.address);
    expect(await UserValidationContract.isVerified(addr2.address)).to.be.false;
    expect(await UserValidationContract.getUsersAmount()).to.eq(9);
  });
  it("Users have a hash that the platform can use internally", async function () {
    await UserValidationContract.connect(owner).addVerified(addr2.address);
    expect(await UserValidationContract.isVerified(addr2.address)).to.be.true;
    let hash = await UserValidationContract.connect(owner).getVerifiedUserHash(
      addr2.address
    );
    expect(hash).to.be.lengthOf(66);
    let hashIsPersisted = await UserValidationContract.connect(
      owner
    ).getVerifiedUserHash(addr2.address);
    expect(hash).to.equal(hashIsPersisted);
  });
  it("NFTs can be added to verified Platform NFTs", async function () {
    try {
      await UserValidationContract.connect(addr1).addPlatformNFT(addr1.address);
    } catch (error) {
      expect(error.message).to.eq(
        "VM Exception while processing transaction: reverted with reason string 'Only Owner or Server can perform this function'"
      );
    }
    await UserValidationContract.connect(owner).addPlatformNFT(
      ArtWorkNFTContract.address
    );
    expect(
      await UserValidationContract.onlyPlatformNFTs(ArtWorkNFTContract.address)
    ).to.be.true;
  });
  describe("Running ito to get some tokens in wallets", async function () {
    it("We want to have OAM 3 NFT as the artwork", async function () {
      expect(await ArtWorkNFTContract.ERC721name()).to.equal("Artwork 2022 04");
      expect(await ArtWorkNFTContract.ERC721symbol()).to.equal("OAM2204");
      expect(
        await UserValidationContract.onlyPlatformNFTs(
          ArtWorkNFTContract.address
        )
      ).to.equal(true);
    });
    it("Server can set the value and amount token shares to exist", async function () {
      await ITOContract.connect(server).setNFTInitialPrice(
        ArtWorkNFTContract.address,
        2000000
      );
      await ITOContract.connect(server).setNFTInitialTokenShares(
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
        await ITOContract.getItoInitialAvailableShares(
          ArtWorkNFTContract.address
        )
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
      expect(await NOKTokenContract.ERC20balanceOf(addr6.address)).to.equal(0);
      expect(await NOKTokenContract.ERC20balanceOf(collector.address)).to.equal(
        400000
      );
      expect(await NOKTokenContract.ERC20balanceOf(owner.address)).to.equal(0);
      expect(await ArtWorkNFTContract.ERC20balanceOf(addr6.address)).to.equal(
        50
      );
      expect(await ArtWorkNFTContract.ERC20balanceOf(addr7.address)).to.equal(
        50
      );
      expect(await ArtWorkNFTContract.ERC20balanceOf(addr8.address)).to.equal(
        50
      );
      expect(await ArtWorkNFTContract.ERC20balanceOf(addr9.address)).to.equal(
        50
      );
      expect(
        await ArtWorkNFTContract.ERC20balanceOf(collector.address)
      ).to.equal(750);
      expect(await ArtWorkNFTContract.ERC20balanceOf(owner.address)).to.equal(
        50
      );
    });
  });
  describe("KYC event: Exchange wallets for validated user", async function () {
    it("Platform can change address of wallet for a user", async function () {
      await UserValidationContract.connect(owner).addVerified(addr10.address);
      await expect(
        DAOContract.connect(owner).cancelAndReissue(
          ArtWorkNFTContract.address,
          addr9.address,
          addr10.address
        )
      )
        .to.emit(UserValidationContract, "VerifiedAddressSuperseded")
        .withArgs(addr9.address, addr10.address, owner.address);
      expect(await UserValidationContract.getCurrentFor(addr9.address)).to.eq(
        addr10.address
      );
      /**+-The N.F.T. Token Shares Balance of the Cancelled Address cannot be Burn since the Function "_ERC20burn" can Only be Called
       * by the Address that Holds the Tokens to be Burn, and Neither can We Transfer to Our Wallet or S.C. those Tokens and then Burn
       * them since the Function "ERC20approve" also needs to be Called by the Address that Holds the Tokens. Anyways, this will not
       * affect the Implied Value of all the N.F.T. Token Shares since the Data used to Calculate it is the ITOSharesInitialSupply
       * Mapping in "OAMITOManagement", which is not Modified. The ERC-20 totalSupply does not matters for this purpose.*/
      expect(await ArtWorkNFTContract.ERC20balanceOf(addr10.address)).to.eq(50);
    });
  });
});
