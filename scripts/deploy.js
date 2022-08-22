async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  //+-USDOAM:_
  const USDOAM = await ethers.getContractFactory("USDOAM");
  const usdOAM = await USDOAM.deploy();
  console.log("USDOAM Contract Address:", usdOAM.address);

  //+-EUROAM:_
  const EUROAM = await ethers.getContractFactory("EUROAM");
  const eurOAM = await EUROAM.deploy();
  console.log("EUROAM Contract Address:", eurOAM.address);

  //+-GBPOAM:_
  const GBPOAM = await ethers.getContractFactory("GBPOAM");
  const gbpOAM = await GBPOAM.deploy();
  console.log("GBPOAM Contract Address:", gbpOAM.address);

  //+-NOKOAM:_
  const NOKOAM = await ethers.getContractFactory("NOKOAM");
  const nokOAM = await NOKOAM.deploy();
  console.log("NOKOAM Contract Address:", nokOAM.address);

  //+-Users Verification:_
  const OAMUsersVerification = await ethers.getContractFactory(
    "OAMUsersVerification"
  );
  const oamUV = await OAMUsersVerification.deploy();
  console.log("OAMUsersVerification Contract Address:", oamUV.address);

  //+-Market Management:_
  const OAMarketManagement = await ethers.getContractFactory(
    "OAMarketManagement"
  );
  const oamM = await OAMarketManagement.deploy();
  console.log("OAMarketManagement Contract Address:", oamM.address);

  //+-I.T.O. Management:_
  const OAMITOManagement = await ethers.getContractFactory("OAMITOManagement");
  const oamITOManagement = await OAMITOManagement.deploy();
  console.log("OAMITOManagement Contract Address:", oamITOManagement.address);

  //+-D.A.O.:_
  const OAMDAO = await ethers.getContractFactory("OAMDAO");
  const oamDAO = await OAMDAO.deploy();
  console.log("OAMDAO Contract Address:", oamDAO.address);

  //+-N.F.T.Sales:_
  const NFTSales = await ethers.getContractFactory("OAMNFTSales");
  const nftSales = await NFTSales.deploy();
  console.log("N.F.T.Sales Contract Address:", nftSales.address);

  //+-English Auctions:_
  const OAMEnglishAuctions = await ethers.getContractFactory(
    "OAMEnglishAuctions"
  );
  const oamEnglishAuctions = await OAMEnglishAuctions.deploy();
  console.log("English Auctions Contract Address:", oamEnglishAuctions.address);

  //+-Dutch Auctions:_
  const OAMDutchAuctions = await ethers.getContractFactory("OAMDutchAuctions");
  const oamDutchAuctions = await OAMDutchAuctions.deploy();
  console.log("Dutch Auctions Contract Address:", oamDutchAuctions.address);

  //+-P2PMarket:_
  const OAMP2PMarket = await ethers.getContractFactory("OAMP2PMarket");
  const oamP2PMarket = await OAMP2PMarket.deploy();
  console.log("OAMP2PMarket Contract Address:", oamP2PMarket.address);

  //+-N.F.T.:_
  const OAMNFT = await ethers.getContractFactory("OAMNFT");
  const oamNFT = await OAMNFT.deploy();
  console.log("OAMNFT Contract Address:", oamNFT.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
