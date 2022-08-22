# Platform currency token
ERC-20 contract for tokens.

## Background
To allow easy flow of fiat currencies to and from the platform, the platform will issue its own fiat currency tokens and link the total supply of that token to the holding of an traditional fiat bank account in that currency.

The amount of tokens should at any time be the same as or less than the amount of its related currency bank account.

## Actions the customers will take with the tokens
A customer can do the following with the contract:
1. Deposit cash to a linked bank account with a unique `trx-key`
2. Withdraw cash from the wallet, creating a transaction to the customers linked bank account
3. Use tokens to buy artwork tokens
4. Use tokens to exchange into other currency tokens

### 1. Deposit
Any transaction that is to be approved and accounted for must include a transaction message containing a key `trx-key` for the current transaction, wallet and expected amount.

Any time a deposit is made with a valid `trx-key` the token contract should mint new tokens and assign those tokens to the corresponding wallet.

### 2. Withdraw
Any time a customer withdraws money, a transaction is issued by the platform with a `trx-key` deducting the amount from the corresponding wallet, and burning those tokens from the supply.

### 3. Buy Artwork tokens
An artwork token is valued in an amount of a currency token.
Any time a customer buys artwork tokens, we will transfer the amount of tokens being used to the token wallet of the user owning the tokens.

### 4. Exchange currency token for currency token
This is not a general service, but used by the platform to show the user the cost of buying artwork tokens set in different currencies than they are holding in their wallet.

## Third-party verification
Suggestion is to setup a simple API that can be the proxy for whatever service we end up using, allowing for simple events being registered with the contract.

