# Open-Art-Market-Official-Smart-Contracts

- Users can Connect their Wallets and are able to buy Possession Fractions (Stocks in the form of ERC-884 Tokens) of Real World Physical Pieces of Art (Represented in the Platform as ERC-721 Tokens) from several Artists in a Transparent (All users must go through a Know Your Customer Process) and Fiat Friendly (Users will be able to exchange Fiat for Crypto and vice versa without much technical knowledge) way with the aim of Investing in these Works of Art for the Long Term (Years or Even Decades).

https://app.skiff.org/docs/a09a24da-12b6-4258-a5a3-d415eac4b617#ERsUwIDRoyc5VDRDYN32hewtVWMkRB2JkQPMcGcsu7c=

## For Testing the Successful S.C. DEMO Deployed in the Mumbai Polygon TestNet:

Smart Contract deployed with the account: ------------------

USDOAM Contract Address: https://mumbai.polygonscan.com/address/

EUROAM Contract Address: https://mumbai.polygonscan.com/address/

GBPOAM Contract Address: https://mumbai.polygonscan.com/address/

NOKOAM Contract Address: https://mumbai.polygonscan.com/address/

OAMUsersVerification Contract Address: https://mumbai.polygonscan.com/address/

OAMarketManagement Contract Address: https://mumbai.polygonscan.com/address/

OAMITOManagement Contract Address: https://mumbai.polygonscan.com/address/

OAMDAO Contract Address: https://mumbai.polygonscan.com/address/

N.F.T.Sales Contract Address: https://mumbai.polygonscan.com/address/

English Auctions Contract Address: https://mumbai.polygonscan.com/address/

Dutch Auctions Contract Address: https://mumbai.polygonscan.com/address/

OAMP2PMarket Contract Address: https://mumbai.polygonscan.com/address/

OAMNFT Contract Address: https://mumbai.polygonscan.com/

- You can get Mumbai Test Matic Here:
https://faucet.polygon.technology

- How to Interact with the Deployed Smart Contract:
  https://docs.alchemy.com/alchemy/tutorials/hello-world-smart-contract/interacting-with-a-smart-contract#step-6-update-the-message

## Quick Project start:

:one: The first things you need to do are cloning this repository and installing its
dependencies:

```sh
npm install
```

## Setup

:two: Copy and Paste the File ".env.example" inside the same Root Folder(You will Duplicate It) and then rename it removing the part of ".example" so that it looks like ".env" and then fill all the Data Needed Inside the File. In the part of "ALCHEMY_API_KEY"
just write the KEY, not the whole URL.

```sh
cp .env.example .env && nano .env
```

:three: Open a Terminal and let's Test your Project in a Hardhat Local Node. You can also Clone the Polygon Main Network in your Local Hardhat Node:
https://hardhat.org/guides/mainnet-forking.html

```sh
npx hardhat node
```

:four: Now Open a 2nd Terminal and Deploy your Project in the Hardhat Local Node. You can also Test it in the same Terminal:

```sh
npx hardhat test
```

## Solidity Smart Contracts Auditing Tools(Always use Linux Ubuntu/WSL 2.0 If Possible):

- NOTE: Always run all the Tools Directly in the Directory where the S.C. ```.sol``` Files are Located.

:hammer_and_wrench: For a Quick and Simple Audit of the Solidity Smart Contracts, you can Install and Use Slither-Analyzer:
[Slither-Analyzer Functioning Troubleshooting](https://github.com/crytic/slither/issues/1103)
- Installation:
- First Install the Solidity Versions Selector:
```sh
pip3 install solc-select
solc-select versions
solc-select install
```
- Install Slither For Windows WSL Linux Ubuntu Console:
```sh
pip3 install -U https://github.com/crytic/crytic-compile/archive/refs/heads/dev-windows-long-paths.zip
crytic-compile --v
pip3 install -U https://github.com/elopez/slither/archive/refs/heads/windows-ci.zip
slither --v
```
Or in any other case:
```sh
pip3 install crytic-compile==0.2.2
crytic-compile --v
pip3 install slither-analyzer==0.8.2
slither --v
```
### Usage:
- Analyze all the S.C.s inside a Directory:
```sh
slither .
```
- Analyze all the S.C.s inside a Directory Ignoring all prior Warnings:
```sh
slither . --triage
```
- See all the prior Warnings Again:
```sh
rm slither.db.json
```

:hammer_and_wrench: For a More Detailed Audit of the Solidity Smart Contracts, you can Install and Use Mythril Analyzer:
- Installation:
```sh
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
rustup default nightly
pip3 install mythril
myth version
```
### Usage:
Run:
```sh
myth analyze <solidity-file>
```
Or:
```sh
myth analyze -a <contract-address>
```

## :hammer_and_wrench:Auditing Approach:
- Read about the project in its Documentation and Talk to its Developers if Possible to get an idea of what the Smart Contracts are meant to do.
- Look over the Smart Contracts to get an idea of the Smart Contracts Architecture.
- Create a threat model and make a list of theoretical attack vectors including all common pitfalls and past exploit techniques. Tools like Slither and Mythrill can help with this.
- Look at places that can do value exchange. Especially functions like transfer, transferFrom, send, call, delegatecall, and selfdestruct. Walk backward from them to ensure they are secured properly.
- Do a line-by-line review of the contracts.
- Do another review from the perspective of every actor in your threat model.
- Glance over the test cases and code coverage.

## Deploying the Project to the Mumbai TestNet:

:five: Deploy the Smart Contract to the Mumbai Polygon Test Network(https://hardhat.org/tutorial/deploying-to-a-live-network.html):

```sh
npx hardhat run scripts/deploy.js --network mumbai
```

## Deploying the Project to the Polygon MainNet:

:six: Deploy the Smart Contract to the Polygon Main Network(https://hardhat.org/tutorial/deploying-to-a-live-network.html):

```sh
npx hardhat run scripts/deploy.js --network polygon
```

## User Guide:

You can find detailed instructions on using this repository and many tips in [The Documentation](https://hardhat.org/tutorial).

- [Setting up the environment](https://hardhat.org/tutorial/setting-up-the-environment.html)
- [Testing with Hardhat, Mocha and Waffle](https://hardhat.org/tutorial/testing-contracts.html)
- [Hardhat's full documentation](https://hardhat.org/getting-started/)

For a complete introduction to Hardhat, refer to [this guide](https://hardhat.org/getting-started/#overview).

## Order sequence in which Users interact with the Smart Contract Functionalities Guide:_

(uint = UnSigned Integer)

:one: Registration in the O.A.M. Platform:
- OAMarketplace.sol:

- The Platform Owner can Register an User who passed the K.Y.C. Process(The Function Creates a Verification Hash and associates it to the User Address):
```solidity
function addVerified(address addr) public onlyOwner isVerifiedAddress(addr) isNotCancelled(addr)
```

- The Platform Owner can Delete a Registered User:
```solidity
function removeVerified(address addr) public onlyOwner isVerifiedAddress(addr)
```

:two: User with a Physical ArtWork becomes an ArtWork Owner:
- OAMNFTandDAOTemplate.sol:
_The N.F.T.-I.T.O.-D.A.O. S.C. is Deployed_

- Function for the Platform Owner to Cancel the original Address of an User and reissue the Tokens to the Replacement Address:
```solidity
function cancelAndReissue(address original, address replacement)
public
onlyOwner
isShareholder(original)
isNotShareholder(replacement)
isVerifiedAddress(replacement)
```

- Function for the ArtWork Owner to change the Initial Price of the N.F.T. and its Shares if the I.T.O/Normal Auction did not Started yet:
```solidity
function setNFTInitialPrice(uint256 nftPrice)
public
onlyCollector
isVerifiedAddress(msg.sender)
```

- Function for the ArtWork Owner to Set the Initial Amount of Token Shares if the I.T.O/Normal Auction did not Started yet:
```solidity
function setNFTInitialTokenShares(uint256 tokenSharesAmount)
public
onlyCollector
isVerifiedAddress(msg.sender)
```

- Function for the ArtWork Owner to change the I.T.O. Time in Days if the I.T.O did not Started yet:
```solidity
function setNewITOtime(uint256 newTime)
public
onlyCollector
isVerifiedAddress(msg.sender)
```

- When the ArtWork Owner wants to Start the I.T.O., We Transfer the N.F.T. from the Admin's Wallet to the O.A.MarketPlace
Smart Contract, we Divide it in Shares and We sell it in an I.T.O:
```solidity
function startIto() public onlyCollector isVerifiedAddress(msg.sender)
```

- Function for the ArtWork Owner to Withdraw the Profits in Fiat ERC-20 Token after the I.T.O finished
and the Shares of the N.F.T. that have not been Sold at the I.T.O:
```solidity
function withdrawItoProfits()
public
onlyCollector
isVerifiedAddress(msg.sender)
```

- Starts the Voting Cycle Registering the Different Proposals that Will be available to Compete between each other:
```solidity
function startProposalRegistration()
public
onlyCollector
isVerifiedAddress(msg.sender)
```

- Ends the Registration of Different Proposals that Will be available to Compete between each other:
```solidity
function endProposalRegistration()
public
onlyCollector
isVerifiedAddress(msg.sender)
```

- Function for the ArtWork Owner to change the Default Time in Days of Voting:
```solidity
function setDefaultVotingDays(uint256 days)
```

- Starts the Voting between the Different Proposals:
```solidity
function startVotingSession()
public
onlyCollector
isVerifiedAddress(msg.sender)
```

- Ends the Voting between the Different Proposals ONLY after the set Voting Time have passed:
```solidity
function endVotingSession()
public
onlyCollector
```

- The ArtWork Owner can Delete a Proposal:
```solidity
function deleteProposalAdmin(uint256 id)
public
onlyCollector
isVerifiedAddress(msg.sender)
```

- The ArtWork Owner executes the Counting of Votes:
```solidity
function countVotes() public onlyCollector isVerifiedAddress(msg.sender)
```

- ArtWork Owner ReSets the Voting Cycle so another new Voting with new Proposals can take place:
```solidity
function resetVotingSession()
public
onlyCollector
isVerifiedAddress(msg.sender)
```

:three: User who buys Token Shares in the I.T.O. becomes a Voter:
- OAMNFTandDAOTemplate.sol:

- Function for the Users to Buy Shares of the N.F.T. at the I.T.O:
```solidity
function buyShare(uint256 shareAmount)
public
isVerifiedAddress(msg.sender)
```

- Token Shares Holders can add Proposals to being voted:
```solidity
function addProposal(string memory description)
public
allowListed
isVerifiedAddress(msg.sender)
```

- Token Shares Holders can Delete the Proposals that they Added:
```solidity
function deleteProposal(uint256 id)
public
allowListed
isVerifiedAddress(msg.sender)
```

- Users can Vote for the Proposals:
```solidity
function vote(uint256 proposalId, bool yesOrNo)
public
allowListed
isVerifiedAddress(msg.sender)
```

:four: Token Shares Holder User Trade their assets in the P2P Marketplace:
- OAMNarketplace.sol:

- Function for any Verified User to make an offer to Sell Token Shares in the P2P Market:
```solidity
function placeSellOffer(
address tokenShareAsset,
uint256 assetAmount,
address paymentMethod,
uint256 pricePerToken
) public payable nonReentrant isVerifiedAddress(msg.sender)
```

- Function for any Verified User to make an offer to Buy Token Shares in the P2P Market:
```solidity
function placeBuyOffer(
address tokenShareAsset,
uint256 assetAmount,
address paymentMethod,
uint256 pricePerToken
) public payable nonReentrant isVerifiedAddress(msg.sender)
```

- Function for any Verified User to Accept other User's offer to Sell Token Shares in the P2P Market(This User Will Buy):
```solidity
function takeSellOffer(uint256 sellOfferId, uint256 assetAmount)
public
payable
nonReentrant
isVerifiedAddress(msg.sender)
```

- Function for any Verified User to Accept other User's offer to Buy Token Shares in the P2P Market(This User Will Sell):
```solidity
function takeBuyOffer(uint256 buyOfferId, uint256 assetAmount)
public
payable
nonReentrant
isVerifiedAddress(msg.sender)
```

- Users can Call this Function when they want to Withdraw an Offer that they Placed:
```solidity
function withdrawOffer(uint256 offerId)
public
payable
nonReentrant
isVerifiedAddress(msg.sender)
```

- Returns all the UnFulfilled P2P Market Trade Offers:
```solidity
function fetchP2PMarketOffers()
public
view
returns (TokenShareTradeOffer[] memory)
```

:five: ArtWork N.F.T.s can be sold in the Marketplace by Auctions or BuyOut:
- OAMNarketplace.sol:

- Function that any Verified User can call to Buy Instantly an ArtWork N.F.T.:
```solidity
function NFTBuyOut(address nftAddress)
public
payable
nonReentrant
isVerifiedAddress(msg.sender)
```

- An ArtWork Owner Places an Item for sale on the Marketplace after a Voting in the D.A.O. Determines that:
```solidity
function createMarketItem(address nftContract, uint256 price)
public
payable
nonReentrant
isVerifiedAddress(msg.sender)
```

- An ArtWork Owner Removes an item for sale on the Marketplace:
```solidity
function removeMarketItem(address nftContract)
public
payable
nonReentrant
isVerifiedAddress(msg.sender)
```

- Creates the sale of a Marketplace Item. Transfers ownership of the item, as well as funds between parties:
```solidity
function createMarketSale(address nftContract, uint256 itemId)
public
payable
nonReentrant
isVerifiedAddress(msg.sender)
```

- An ArtWork Owner Places an item for sale in an English Auction on the Marketplace after a Voting in the D.A.O. Determines that:
```solidity
function createMarketEnglishAuction(
address nftContract,
uint256 startingPrice,
uint256 daysAuctionEndTime
) public payable nonReentrant isVerifiedAddress(msg.sender)
```

- Creates a Bid for a Marketplace EnglishAuction:
```solidity
function bidEnglishAuction(uint256 itemId, uint256 bidAmount)
public
payable
nonReentrant
isVerifiedAddress(msg.sender)
```

- This function needs to be Manually Called when the Time of an EnglishAuction finishes to Reward The Highest Bidder and The N.F.T.
Owner (If the I.T.O. did not happened yet, otherwise it will reward all the Token Share Holders) in the case that someone Bided for
the N.F.T. OR to Remove the Listed Item from the Marketplace and return the N.F.T. to the ArtWork Owner (If the I.T.O. did not happened
yet, otherwise it stay in the Marketplace S.C.) if nobody bided:
```solidity
function englishAuctionEnd(address nftContract, uint256 itemId)
public
nonReentrant
isVerifiedAddress(msg.sender)
```

- An ArtWork Owner Places an item for sale in an Dutch Auction on the Marketplace after a Voting in the D.A.O. Determines that:
```solidity
function createMarketDutchAuction(
address nftContract,
uint256 startingPrice,
uint256 endingPrice,
uint256 daysAuctionEndTime
) public payable nonReentrant isVerifiedAddress(msg.sender)
```

- Get the Current price of a Dutch Auction in the Default Fiat Token of the D.A.O. of the N.F.T.:
```solidity
function getCurrentPriceDucthAuction(uint256 itemId)
public
view
returns (uint256)
```

- Creates the Sale for the first and only Bidder in a Marketplace Dutch Auction:
```solidity
function createDutchAuctionSale(address nftContract, uint256 itemId)
public
payable
nonReentrant
isVerifiedAddress(msg.sender)
```

- This function needs to be Manually Called when the Time of a DutchAuction finished and nobody bided to Remove the Listed Item
from the Marketplace and return the N.F.T. to the Seller:
```solidity
function dutchAuctionEnd(address nftContract, uint256 itemId)
public
nonReentrant
isVerifiedAddress(msg.sender)
```

- Function for ArtWork N.F.T. D.A.O. Token Share Holders to Claim their Rewards after the ArtWork is sold by BuyOut/Auction/MarketSale:
```solidity
function claimBuyOutOrAuctionReward(address nftAddress)
public
isVerifiedAddress(msg.sender)
```
