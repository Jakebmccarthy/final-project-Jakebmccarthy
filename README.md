# READ ME
# Final Project - Online Marketplace - Jake McCarthy

## Intro
Apologies but due to time constraints front end is not currently functioning
Backend can still be tested the standard way using ganache 
```truffle compile```
````truffle test```
```truffle migrate``` 
Other wise use:
```truffle develop```
```compile```
```test```

## Description
This project takes the 2nd use case (Online Marketplace) outlined in the Final Project Specifications sheet.  
Much of the functionality is not fleshed out due to time constraints. For simplicities sake, Store Owners post items directly for customers to buy rather than introduce the concept of a store. Items are unique meaning if you want to sell 2 of the same item the Store Owner must make 2 seperate calls to addItem.

Below is an image showing an outline of the project
Some point to note:
  - Blue boxes are object e.g Users and Items
  - Green boxes are functions relating to the interaction between them

![Alt test](https://i.imgur.com/jnrPkNi.png)

## Set up for evalution

## Testing
Test can be found in the file ```./test/online_marketplace.test.js ```
 - ### Register User
    owner of contract registers the user 'alice' as a store owner
    calls getter function to check has the name and state been changed in the user object
 - ### Add Item
    owner add an item for sale
    calls getter function to check have the input parameters been recorded in the item object
 - ### Purchase Item
    bob purchases item from alice
    calls getter function to check has item state changed and have user balances changed
 - ### Change User Acess
    owner changes alice permissions from storeowner to admin
    check has alices state been updated in the user object
 - ### Change Item Price
    owner adds item for sale and edits parameters about item
    check had the item object to reflect the input parameters

## Avoiding Common Attacks
can be found in file labeled ```avoiding_common_attacks.md```
![avoiding_common_attacks.md](avoiding_common_attacks.md)

## Deployed Addresses
can be found in file labeled ```deployed_addresses.md```
![deployed_addresses.md](deployed_addresses.md)

## Design Pattern Decisions
can be found in file labeled ```design_pattern_decisions.md```
![```design_pattern_decisions.md```](design_pattern_decisions.md)

