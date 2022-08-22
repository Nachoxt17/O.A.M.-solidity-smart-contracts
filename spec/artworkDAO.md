# Artwork Distributed Autonomous Organization:\_

(### at the End of a Text == Developed)
(--- at the End of a Text == To be Done)

## Background:\_

+-This Smart Contract should Govern the full extent of all Actions within an artwork in the platform. The Smart Contract contains the necessary functions for the following:\_

- Details (name and image)###
- Value (currency + amount)###
- Metadata (URL)###
- N.F.T. (proof of ownership)###
- Token (share of ownership)###
- Voting (YES or NO vote per token)###
- Auction (Sale of ArtWork)###

## Artwork details:\_

ArtWork I.D., Name and Official Image of the ArtWork. This is used in the Platform to list the ArtWork.###

## Artwork value:\_

The value of the Artwork D.A.O. is set by third party appraisers, where documentation of that is linked in Artwork MetaData.###

The value is set in a fiat currency, and from this value you can derive the value of each token in the D.A.O.###
+-NOTE:\_ Create Function "setNFTPrice" and take from there the Token Share Prices.

We do not want Accounts created outside the platform to hold any of the tokens the Platform issues. The D.A.O. needs to contain a reference to the allow listed Accounts that are allowed to Interact with the D.A.O..###
This allow list is Updated as we add Users to the Platform, with the Addresses for the Wallets created by the Platform.###
+-NOTE:\_ Create a "allow list" in the Marketplace S.C. so only Registered K.Y.C. Users can use the Functionalities of the Platform.

As the D.A.O. goes through its lifecycle we also need to track an implied value based on transactions within the DAO (described below).

## Artwork Metadata:\_

This is a U.R.L. to a ".json" File UpLoaded in the I.P.F.S. Storage Service https://www.pinata.cloud with information about:\_###

- the artwork
- artist
- production details
- appraisal
- insurance policy id
- vault storage id
- exhibitions

## Artwork N.F.T.:\_

The N.F.T. represents the Certificate of Ownership for the ArtWork, and is the only piece that is left of the D.A.O. when it in the end is auctioned off or sold to someone.###

The N.F.T. Certificate of ownership should contain the links to the artwork details, metadata and references back to the original DAO on the blockchain.###

The N.F.T. cannot be transferred as long as any of its linked tokens are in existence (e.g. all of the Artwork tokens needs to be burned or held by one account for it to be transferred).###

This NFT should in the end be transferrable to an "official" blockchain wallet Ethereum, Polygon or similar - following the ERC-721 standard.###

During the LifeTime of the ArtWork in the Platform the N.F.T. is not transacted or have any specific meaning.###

## Artwork Share Token:\_

The token represents the shares of the ArtWork, that the Investors on the Platform will buy, hold or sell when interacting with the D.A.O.###

It should follow an ERC-884 type of contract, where the token holder can exchange their wallet Address for their tokens given a proper 3rd party authentication and authorization. This is to ensure that we have proper governance of force and death for both investors and collectors.###

In the beginning the token value is derived from the totalSupply and Artwork value.###

-All tokens gets minted at the initiation of the DAO, where a split between the collector and the platform is set - configurable, default 5% of tokens for platform, rest for collector.###

### Token Naming:\_

The token has a name following the pattern

```
$Ox22BJMA
$Ox22TRVA
```

_split into the following pieces:_

`Ox`=> OAM token prefix
`22` => Year added to blockchain
`BJM` => Initials of artist (ex: Bjarne Melgaard)
`A` => Alphanumeric index of artist work.

## Two types of sale:\_

## Initial Token Offering:\_

The Initial Token Offering is a time-limited sale. The time-limit is configurable per D.A.O. Both Platform and ArtWork Owner can allocate a certain amount of their tokens for sale.###
At the I.T.O., the ArtWork Owner should have the option to NOT selling all his/her Token Shares but a Part.###
These tokens are open for any allow listed account to buy.###

## Second hand sales:\_

+-Retail User to User Sales of Tokens:\_

After the Initial Token Offering and the mandatory freeze period (configurable, default 6 months)### The tokens can then be sold from any holder to any allow listed account through a simple Peer to Peer(P2P) Market System:\_###

-Users can Create the Sell/Buy Offers with the Asset, Price and Amount of the Asset that they want to Trade and then they appear in a List of Sellers/Buyers with same Asset in which those with the Highest Price appear First in the Case of Buyers and those with the Lowest Price appear First in the Case of Sellers.

+-Development Notes:_ -Functions to Create in "OAMarketplace.sol":_

-function placeSellOffer(address \_tokenShareAsset, uint256 \_assetAmount, address \_paymentMethod, uint256 \_pricePerToken) public payable nonReentrant isVerifiedAddress(msg.sender)

-function placeBuyOffer(address \_tokenShareAsset, uint256 \_assetAmount, address \_paymentMethod, uint256 \_pricePerToken) public payable nonReentrant isVerifiedAddress(msg.sender)

-function takeSellOffer(uint256 \_sellOfferId, uint256 \_assetAmount) public payable nonReentrant isVerifiedAddress(msg.sender)

-function takeBuyOffer(uint256 \_buyOfferId, uint256 \_assetAmount) public payable nonReentrant isVerifiedAddress(msg.sender)

+-Users can Call this Function when they want to Withdraw an Offer that they Placed:\_
-function withdrawOffer(uint256 \_offerId) public payable nonReentrant isVerifiedAddress(msg.sender)

+-Buyout of the Whole ArtWork N.F.T. and the Physical ArtWork itself:\_###

ArtWorks will have a Special "Instant Buyout" Price that will be 90% Higher than the Initial Price of the ArtWork N.F.T.; and if a Registered User wants to buy the Whole ArtWork N.F.T. and the Physical ArtWork itself paying that Price, he/she will
be able to do it and all the Token Shares Holders will receive their Percentage of the Price (depending on how many Token Shares they Hold)
thus having a significant profit on their Investments and their Token Shares will be Burned.

## Implied value of ArtWork:\_

When there are Second Hand Sales of Tokens the Implied Value of the artwork is UpDated. Implied value is the Average Price of the Token Price that has been sold.###

**Example**

1. Artwork is worth USD$100 having 100 Token Shares (Each Token Share equals to USD$1).
2. 10 token are sold for USD$15 (1 Token Share = USD$1,5).
3. The Implied Value is now USD$105.
4. The some other 10 Token Shares are sold USD$5 (1 Token Share = USD$0,5).
5. The Implied Value is now USD$100.

## Rules of tokens:\_

## Minting of tokens:\_

Tokens are minted at the initiation of the D.A.O..###

## Burning of tokens (owner only):\_

Tokens cannot be burned until we have a Sale event from auction, or when one token holder holds all tokens. You must burn all tokens when doing so, and this action closes of the DAO leaving ONLY the N.F.T..###

## Artwork Voting:\_###

Each token holds a vote, meaning token holders can vote on arbitrary questions in a `YES` or `NO` fashion.###

**Examples are:**

- Should we sell the artwork for USD 100,000?
- Should we rent the artwork out for exhibition for USD 10,000?
- Should we freeze sale of the artwork for the next 12 months?

Questions are defined as needed and communicated to all token holders through the platform. Votes are time limited to 7 days ###, and defaults to YES for every token holder that does not explicitly vote within the time limit.### A simple majority (50,1%) of the tokens win the vote.###

## Artwork Auction:\_

We should be able to auction off the artwork to multiple bidders.###
We need a functions for registering bids and handling simple auction structures.###

1. Auction owner.
2. Minimum price.
3. Auction start and auction end.
4. Highest bid & bidder.
5. Bids map.
6. State (open, closed, cancelled).

## Artwork fees:

_Artwork Owner fees:_
For ArtWork Owners - we should deduct a 12,5 % Fee for burning Currency tokens (in other words - when they take money out of the Platform)---, the platform should take 12,5% of the amount and transfer to Platform wallet.

Example:
ArtWork owner sells 1000 Token Shares worth NOK$1 each = NOK$1000 Tokens -
then withdraws NOK$800 tokens (NOK$800 \* 12,5%) => NOK$100 tokens to platform Wallet.

_ArtWork Token Shares Second Hand P2P Market Sales Flat fee:_
Artwork Investors(Token Share Holders) should pay a 12%(The Percentage is Integer since Numbers with Decimals give Problems in Solidity) Flat Fee of the Money they get both when the ArtWork N.F.T. they Invested in through Token Shares is sold by Auction or Instant Buyout(And their Tokens Shares are Burned)### or when they Sell Token Shares to Other Investors in the P2P Market.###

+-Discarded Idea:\_
Artwork Investors should pay 12.5% of the profits they get from burning artwork tokens for currency tokens. (When the artwork itself is sold or when they sell the token at a different price to another investors).

+-Example:\_

The investor bought 10 ArtWork Tokens for NOK$100 Tokens.
He/she/they sell 5 artwork tokens for NOK$75. The platform takes ( NOK$75(New Intended Sell Price)-NOK$50(Original Buy Price) = NOK$25 \* 12,5% ) = NOK$3.125 Tokens should be sent to the Platform.
+-DEVELOPMENT NOTE:\_ Need to have a Register of at which Price Every User bought its Token Shares in the I.T.O..

The investor bought 10 ArtWork Tokens for NOK$100 Tokens.
He/she/they sell 5 ArtWork Tokens for NOK$45. The Platform takes ( NOK$45-NOK$50 = NOK$-5 \* 12.5% ) = NOK$0 NOK tokens should the sent to the Platform.

_Artwork Auction Winner Fee_###
In the event of an ArtWork Auction, the Artwork Acquirer (person with the winning bid), will need to pay 12% Fee(The Percentage is Integer since Numbers with Decimals give Problems in Solidity) on Top of the Bid Price to the Platform.

The shipping and handling fees for shipping the physical artwork to the acquirer will also be added to the final invoice for the artwork.
(This cannot be done in the Smart Contract for now since we do not have a way to get this information)

_+-S.C.s Functions Remix Testing and Debugging:\_
+-OAMarketplace.sol:_
+-(1)-OnlyOwner using all 15 Owner Functions.---
-addVerified-YES
-getVerifiedUserHash-NO
-updateVerified-NO
-removeVerified-NO
-addPlatformNFT-YES
-setNewUSDTokenAddress-YES
-setNewEURTokenAddress-YES
-setNewGBPTokenAddress-YES
-setNewNOKTokenAddress-YES
-setListingPriceNOK-YES
-setSharesSalesPercPrice-YES
-allowAuction-YES
-allowMarketSale-YES
-calculateNFTImpliedValue-
-sendDustTokensBack-

+-(2)-ArtWork Collector using all Collector Functions.---

+-(3)-Any Kind of Verified User (Owner, Collector and Normal) using all Normal Public Functions.---
-hasHash-YES

+-OAMarketplace.sol:\_
+-(1)-OnlyOwner using all 2 Owner Functions.---
-cancelAndReissue-
-deleteVoter-
-setBaseURI-
-setBaseExtension-YES
-setNFTInitialPrice-NO
-setNFTInitialTokenShares-
-setNewITOtime-YES
-startIto-
-startProposalRegistration-
-deleteProposalAdmin-
-endProposalRegistration-
-setDefaultVotingDays-YES
-startVotingSession-
-endVotingSession-
-countVotes-
-resetVotingSession-

+-(2)-ArtWork Collector using Collector Functions.---
-withdrawItoProfits-

+-(3)-Any Kind of Verified User (Owner, Collector and Normal) using all Normal Public Functions.---

# +-TASKS of Correction after Testing:\_

+-(1)-Change the P2P Marketplace so The Share Tokens can ONLY be traded in the same Fiat Currency that is Default in its D.A.O..###
+-(2)-Replace the Function "calculateNFTImpliedValue()" for a "setImpliedValue" so all the Math is done Off-Chain and DELETE all Exchange Rate Functions.###

# +-TASKS for Reducing ByteCode Size and then Testing:\_

+-(1)-In order to reduce the ByteCode Size and also save Gas Fees Costs in the Future, Set the Up the S.C.s of both the Marketplace and the
N.F.T. Template in a way that they are all Independent S.C.s separated by Features that Interact between each other for replacing the Current State of Interdependent S.C.s that are inherited in Row being the "OAMarketplace.sol" S.C. and the "OAMNFTandDAOTemplate.sol" S.C. the Final Heirs S.C.s that Accumulate all the final ByteCode of the Marketplace and the N.F.T. Features respectively. Every Individual Features S.C. should must its own Interface Contract so all the other S.C.s can Interact with them without Inheritating their whole ByteCode.---

+-This way, we should end having all this Independent S.C.s. which would be only deployed ONCE and with which Owner and Users would be able to Interact:\_

-OAMUsersVerification.-For Storing and Managing the Verification of Users in the Platform and for the Owner and other Platform S.C.s to Get/Set Data about Verified Users.
-OAMarketManagement.-For Storing and Managing all the Data about Parameters of the Marketplace such as Fees or Fiat Token Addresses and for the other Platform S.C.s to Get Data about the Marketplace Parameters.

-OAMNFTSales.-For Storing the Data and Managing all the Functions related to the Fixed Price Sales and BuyOuts of N.F.T.s.

-OAMEnglishAuctions.-For Managing all the Functions related to the English Auctions of N.F.T.s.
-OAMDutchAuctions.-For Managing all the Functions related to the Dutch Auctions of N.F.T.s.
-OAMP2PMarket.-For Storing the Data and Managing all the Functions related to the P2P Trade of ArtWork Token Shares between Users.
-OAMITOManagement.-For Storing the Data and Managing all the Functions related to ALL the N.F.T. I.T.O.s. Each N.F.T. will Store its own Data but in order to Get/Set Data from it in all the possible cases, this S.C. will be need to be Used.
-OAMDAOs.-For Storing the Data and Managing all the Functions related to ALL the N.F.T. D.A.O.s. Each N.F.T. will Store its own Data but in order to Get/Set Data from it in all the possible cases, this S.C. will be need to be Used.

+-Then we would have one re-usable N.F.T. S.C. that will ONLY store the Data of the N.F.T. Itself and as less Functionalities as Possible, delegating those tasks to the OAMITOManagement and OAMDAOs S.C.s. This re-usable N.F.T. would be the only S.C. that would be deployed more than once.

# +-Sub-TASKS for short-term Testing of the P2PMarket:\_

+-Finish the OAMUsersVerification###, OAMarketManagement###, OAMNFT###, OAMITOmanagement### and OAMP2PMarket### S.C.s and their Interfaces just for being able of Testing the OAMP2PMarket### S.C. and develop the minimum necessary of the other S.C.s for execute this Tests.###

\_+-Post Launching Ideas:\_

-Create Partnerships with N.F.T. Games Metaverses like Decentraland to show and exhibit the N.F.T. ArtWorks there in order to promote them.
