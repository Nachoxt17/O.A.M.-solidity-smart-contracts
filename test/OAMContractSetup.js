let owner;
let collector;
let addr1;
let addr2;
let USDOAM;
let USDTokenContract;
let EUROAM;
let EURTokenContract;
let GBPOAM;
let GBPTokenContract;
let NOKOAM;
let NOKTokenContract;

let OAMUsersVerification;
let UserValidationContract;
let OAMarketManagement;
let marketPlaceContract;
let OAMITOManagement;
let ITOContract;
let OAMDAO;
let DAOContract;
let OAMNFTSales;
let NFTSalesContract;
let OAMEnglishAuctions;
let OAMEAContract;
let OAMDucthAuctions;
let OAMDAContract;
let OAMNFT;
let ArtWorkNFTContract;
let OAMP2PMarket;
let P2PMarketContract;

let setupCurrencyTokens = async () => {
  USDOAM = await ethers.getContractFactory("USDOAM");
  USDTokenContract = await USDOAM.deploy();

  EUROAM = await ethers.getContractFactory("EUROAM");
  EURTokenContract = await EUROAM.deploy();
  await EURTokenContract.deployed();

  GBPOAM = await ethers.getContractFactory("GBPOAM");
  GBPTokenContract = await GBPOAM.deploy();
  await GBPTokenContract.deployed();

  NOKOAM = await ethers.getContractFactory("NOKOAM");
  NOKTokenContract = await NOKOAM.deploy();
  await NOKTokenContract.deployed();
};

let setupSupportContracts = async (owner) => {
  //+-Deployment of S.Contracts:_
  OAMUsersVerification = await ethers.getContractFactory(
    "OAMUsersVerification"
  );
  UserValidationContract = await OAMUsersVerification.deploy();
  await UserValidationContract.deployed();

  OAMarketManagement = await ethers.getContractFactory("OAMarketManagement");
  marketPlaceContract = await OAMarketManagement.deploy();
  await marketPlaceContract.deployed();

  OAMITOManagement = await ethers.getContractFactory("OAMITOManagement");
  ITOContract = await OAMITOManagement.deploy();
  await ITOContract.deployed();

  OAMDAO = await ethers.getContractFactory("OAMDAO");
  DAOContract = await OAMDAO.deploy();
  await DAOContract.deployed();

  OAMP2PMarket = await ethers.getContractFactory("OAMP2PMarket");
  P2PMarketContract = await OAMP2PMarket.deploy();
  await P2PMarketContract.deployed();

  OAMNFTSales = await ethers.getContractFactory("OAMNFTSales");
  NFTSalesContract = await OAMNFTSales.deploy();
  await NFTSalesContract.deployed();

  OAMEnglishAuctions = await ethers.getContractFactory("OAMEnglishAuctions");
  OAMEAContract = await OAMEnglishAuctions.deploy();
  await OAMEAContract.deployed();

  OAMDutchAuctions = await ethers.getContractFactory("OAMDutchAuctions");
  OAMDAContract = await OAMDutchAuctions.deploy();
  await OAMDAContract.deployed();

  //+-Setting S.C.s Addresses in Every other S.C.s to Connect them between Each other:_
  //+-Adding Fiat Tokens and Platform S.C.s Addresses to O.A.M.M.:_
  await marketPlaceContract
    .connect(owner)
    .setNewUSDTokenAddress(USDTokenContract.address);
  await marketPlaceContract
    .connect(owner)
    .setNewEURTokenAddress(EURTokenContract.address);
  await marketPlaceContract
    .connect(owner)
    .setNewGBPTokenAddress(GBPTokenContract.address);
  await marketPlaceContract
    .connect(owner)
    .setNewNOKTokenAddress(NOKTokenContract.address);

  await marketPlaceContract
    .connect(owner)
    .setNewOAMUVAddress(UserValidationContract.address);
  await marketPlaceContract
    .connect(owner)
    .setNewOAMITOManagementAddress(ITOContract.address);
  await marketPlaceContract
    .connect(owner)
    .setNewOAMDAOAddress(DAOContract.address);
  await marketPlaceContract
    .connect(owner)
    .setNewOAMNFTSalesAddress(NFTSalesContract.address);
  await marketPlaceContract
    .connect(owner)
    .setNewOAMEnglishAuctionsAddress(OAMEAContract.address);
  await marketPlaceContract
    .connect(owner)
    .setNewOAMDutchAuctionsAddress(OAMDAContract.address);
  await marketPlaceContract
    .connect(owner)
    .setNewOAMP2PMarketAddress(P2PMarketContract.address);

  //+-Adding Platform S.C.s to I.T.O. Management:_
  await ITOContract.connect(owner).setNewOAMUVAddress(
    UserValidationContract.address
  );
  await ITOContract.connect(owner).setNewOAMDAOAddress(DAOContract.address);
  await ITOContract.connect(owner).setNewOAMNFTSalesAddress(
    NFTSalesContract.address
  );

  //+-Adding Platform S.C.s to D.A.O. Management:_
  await DAOContract.connect(owner).setNewOAMUVAddress(
    UserValidationContract.address
  );
  await DAOContract.connect(owner).setNewOAMMAddress(
    marketPlaceContract.address
  );
  await DAOContract.connect(owner).setNewOAMEnglishAuctionsAddress(
    OAMEAContract.address
  );
  await DAOContract.connect(owner).setNewOAMDutchAuctionsAddress(
    OAMDAContract.address
  );

  //+-Adding Platform S.C.s to N.F.T. Sales:_
  await NFTSalesContract.connect(owner).setNewOAMUVAddress(
    UserValidationContract.address
  );
  await NFTSalesContract.connect(owner).setNewOAMMAddress(
    marketPlaceContract.address
  );
  await NFTSalesContract.connect(owner).setNewOAMITOManagementAddress(
    ITOContract.address
  );
  await NFTSalesContract.connect(owner).setNewOAMDAOAddress(
    DAOContract.address
  );
  await NFTSalesContract.connect(owner).setNewEnglishAuctionsAddress(
    OAMEAContract.address
  );
  await NFTSalesContract.connect(owner).setNewDutchAuctionsAddress(
    OAMDAContract.address
  );

  //+-Adding Platform S.C.s to English Auctions:_
  await OAMEAContract.connect(owner).setNewOAMUVAddress(
    UserValidationContract.address
  );
  await OAMEAContract.connect(owner).setNewOAMMAddress(
    marketPlaceContract.address
  );
  await OAMEAContract.connect(owner).setNewOAMITOManagementAddress(
    ITOContract.address
  );
  await OAMEAContract.connect(owner).setNewOAMDAOAddress(DAOContract.address);
  await OAMEAContract.connect(owner).setNewOAMNFTSalesAddress(
    NFTSalesContract.address
  );

  //+-Adding Platform S.C.s to Dutch Auctions:_
  await OAMDAContract.connect(owner).setNewOAMUVAddress(
    UserValidationContract.address
  );
  await OAMDAContract.connect(owner).setNewOAMMAddress(
    marketPlaceContract.address
  );
  await OAMDAContract.connect(owner).setNewOAMITOManagementAddress(
    ITOContract.address
  );
  await OAMDAContract.connect(owner).setNewOAMDAOAddress(DAOContract.address);
  await OAMDAContract.connect(owner).setNewOAMNFTSalesAddress(
    NFTSalesContract.address
  );

  //+-Adding Platform S.C.s to P2PMarket:_
  await P2PMarketContract.connect(owner).setNewOAMUVAddress(
    UserValidationContract.address
  );
  await P2PMarketContract.connect(owner).setNewOAMMAddress(
    marketPlaceContract.address
  );
  await P2PMarketContract.connect(owner).setNewOAMITOManagementAddress(
    ITOContract.address
  );

  await UserValidationContract.connect(owner).addVerified(
    P2PMarketContract.address
  );
};

let setupArtWorkNFT = async (NFT, owner, server, collector, addr1, addr2) => {
  //+-Deploy N.F.T.:_
  OAMNFT = await ethers.getContractFactory(NFT);
  ArtWorkNFTContract = await OAMNFT.deploy();
  await ArtWorkNFTContract.deployed();

  //+-Setting S.C.s Addresses in the N.F.T. S.C. to Connect it with the others:_
  await ArtWorkNFTContract.connect(owner).setNewOAMUVAddress(
    UserValidationContract.address
  );
  await ArtWorkNFTContract.connect(owner).setNewOAMMAddress(
    marketPlaceContract.address
  );
  await ArtWorkNFTContract.connect(owner).setNewOAMITOManagementAddress(
    ITOContract.address
  );
  await ArtWorkNFTContract.connect(owner).setNewOAMDAOAddress(
    DAOContract.address
  );
  await ArtWorkNFTContract.connect(owner).setNewOAMNFTSalesAddress(
    NFTSalesContract.address
  );
  await ArtWorkNFTContract.connect(owner).setNewOAMEnglishAuctionsAddress(
    OAMEAContract.address
  );
  //+-Add this N.F.T. as one of the Platform:_
  await UserValidationContract.connect(owner).addPlatformNFT(
    ArtWorkNFTContract.address
  );
  //+-This N.F.T. S.C. Allows all Platform S.C.s to Transfer it:_
  await ArtWorkNFTContract.connect(owner).setApprovAllPlatformContracts();
  
  await UserValidationContract.connect(server).addVerified(NFTSalesContract.address);
  await UserValidationContract.connect(server).addVerified(collector.address);
  await UserValidationContract.connect(server).addVerified(addr1.address);
  await UserValidationContract.connect(server).addVerified(addr2.address);
  await ArtWorkNFTContract.connect(server).setArtWorkOwner(collector.address);
  await ArtWorkNFTContract.connect(server).createAndSendNFT();
  await ArtWorkNFTContract.connect(server).setDAOFiatToken(
    NOKTokenContract.address
  );
};

let setupServersAndAdmin = async (owner, server, admin) => {
  await UserValidationContract.connect(owner).addServer(server.address);
  await UserValidationContract.connect(owner).addAdmin(admin.address);
}

let transferMoneyToWallet = async (owner, wallet, amount) => {
  let ver = await UserValidationContract.isVerified(wallet);
  if (!ver) await UserValidationContract.connect(owner).addVerified(wallet);
  await NOKTokenContract._ERC20mint(owner.address, wallet, amount);
};

let setITOTokensAvailable = async (artwork, _owner, amount) => {
  // be able to change the amount of tokens to be sold
  await ITOContract.connect(_owner).setItoInitialAvailableShares(
    artwork,
    amount
  );
};

let startITO = async (artwork, _owner) => {
  await artwork.connect(_owner).setDAOFiatToken(NOKTokenContract.address);
  await ITOContract.connect(_owner).setNFTInitialPrice(artwork.address, 100000);
  await ITOContract.connect(_owner).setNFTInitialTokenShares(
    artwork.address,
    1000
  );
  await setITOTokensAvailable(artwork.address, _owner, 900);
  await ITOContract.connect(_owner).startIto(artwork.address);
};

let buyIntoITO = async (artwork, _owner, buyer, amount) => {
  await transferMoneyToWallet(_owner, buyer.address, amount * 100);
  await NOKTokenContract.connect(buyer).ERC20approve(
    ITOContract.address,
    amount * 100
  );
  return ITOContract.connect(buyer).buyShare(artwork, amount);
};

let getElements = () => {
  return {
    owner,
    collector,
    addr1,
    addr2,
    USDOAM,
    USDTokenContract,
    EUROAM,
    EURTokenContract,
    GBPOAM,
    GBPTokenContract,
    NOKOAM,
    NOKTokenContract,
    OAMUsersVerification,
    UserValidationContract,
    OAMarketManagement,
    marketPlaceContract,
    OAMITOManagement,
    ITOContract,
    OAMDAO,
    DAOContract,
    OAMNFTSales,
    NFTSalesContract,
    OAMEnglishAuctions,
    OAMEAContract,
    OAMDucthAuctions,
    OAMDAContract,
    OAMNFT,
    ArtWorkNFTContract,
    OAMP2PMarket,
    P2PMarketContract,
  };
};

module.exports = {
  getElements,
  setupCurrencyTokens,
  setupSupportContracts,
  setupArtWorkNFT,
  transferMoneyToWallet,
  setITOTokensAvailable,
  setupServersAndAdmin,
  startITO,
  buyIntoITO,
};
