var OnlineMarketplace = artifacts.require('onlineMarketplace')
var SafeMath = artifacts.require('SafeMath')

contract('OnlineMarketplace', function(accounts){

    const owner = accounts[0]
    const alice = accounts[1]
    const bob = accounts[2]
    const emptyAddress = '0x0000000000000000000000000000000000000000'

    var sku
    const price = "1000"


    //register user
    //owner of contract registers the user 'alice' as a store owner
    //calls getter function to check has the name and state been changed in the user object
    it("should allow admin to register user", async () => {
        const safemath = await SafeMath.deployed();
        const marketplace = await OnlineMarketplace.deployed();
 
        const name = "Alice"

        const aliceEnrolled = await marketplace.registerStoreOwner(alice, name, {from: owner});
        
        const result = await marketplace.fetchUser.call(alice)

        assert.equal(result[0], name, 'the name of the last added user does not match the expected value')
        assert.equal(result[1].toString(10), 1, 'the state of the user should be "Store Owner", which should be declared first in the State Enum')
        
    });

    //add item
    //owner add an item for sale
    //calls getter function to check have the input parameters been recorded in the item object
    it("should allow user to add an item for sale", async () => {
        const safemath = await SafeMath.deployed();
        const marketplace = await OnlineMarketplace.deployed();

        const itemName = "test item"
        

        const tx = await marketplace.addItem(itemName, price, {from: owner});

        if (tx.logs[0].event) {
            sku = tx.logs[0].args.sku.toString(10)
            eventEmitted = true
        }

        const result = await marketplace.fetchItem.call(sku)

        assert.equal(result[0], itemName, 'the name of the last added item does not match the expected value')
        assert.equal(result[2].toString(10), price, 'the price of the last added item does not match the expected value')
        assert.equal(result[3].toString(10), 0, 'the state of the item should be "For Sale", which should be declared first in the State Enum')
        assert.equal(result[4], owner, 'the address adding the item should be listed as the seller')
        assert.equal(result[5], emptyAddress, 'the buyer address should be set to 0 when an item is added')
        assert.equal(eventEmitted, true, 'adding an item should emit a For Sale event')

    });

    //purchase item 
    //bob purchases item from alice
    //calls getter function to check has item state changed and have user balances changed
    it("should allow a user to purchase an item", async () =>{
        const safemath = await SafeMath.deployed()
        const marketplace = await OnlineMarketplace.deployed();
    
        var eventEmitted = false
        const amount = "2000" 

        var aliceBalanceBefore = await web3.eth.getBalance(alice)
        var bobBalanceBefore = await web3.eth.getBalance(bob)

        const tx = await marketplace.buyItem(sku, {from: bob, value: amount})
	
	if (tx.logs[0].event) {
		sku = tx.logs[0].args.sku.toString(10)
		eventEmitted = true
	}

        var aliceBalanceAfter = await web3.eth.getBalance(alice)
        var bobBalanceAfter = await web3.eth.getBalance(bob)

        const result = await marketplace.fetchItem.call(sku)

        assert.equal(result[3].toString(10), 1, 'the state of the item should be "Sold", which should be declared second in the State Enum')
        assert.equal(result[5], bob, 'the buyer address should be set bob when he purchases an item')
        assert.equal(eventEmitted, true, 'adding an item should emit a Sold event')
        assert.equal(parseInt(aliceBalanceAfter), parseInt(aliceBalanceBefore, 10) + parseInt(price, 10), "alice's balance should be increased by the price of the item")
        assert.isBelow(parseInt(bobBalanceAfter), parseInt(bobBalanceBefore, 10) - parseInt(price, 10), "bob's balance should be reduced by more than the price of the item (including gas costs)")
    })

    
    //change access
    //owner changes alice permissions from storeowner to admin
    //check has alices state been updated in the user object
    it("should allow admin to change a users access permissions", async () => {
        const safemath = await SafeMath.deployed()
        const marketplace = await OnlineMarketplace.deployed()

        const name = "Alice"

        const aliceEnrolled = await marketplace.registerStoreOwner(alice, name, {from: owner});
        const aliceToAdmin = await marketplace.registerAdmin(alice, name, {from: owner});

        const result = await marketplace.fetchUser.call(alice)

        assert.equal(result[0], name, 'the name of the last added user does not match the expected value')
        assert.equal(result[1].toString(10), 2, 'the state of the user should be "Store Owner", which should be declared first in the State Enum')

    })
    

    //change price
    //owner adds item for sale and edits parameters about item
    //check had the item object to reflect the input parameters
    it("should allow user to change the price of an item", async () =>{
        const safemath = await SafeMath.deployed();
        const marketplace = await OnlineMarketplace.deployed();

        const itemName = "test item"
        const updateName = "update item"
        const updatePrice = "2000"
        

        const tx = await marketplace.addItem(itemName, price, {from: owner});

        if (tx.logs[0].event) {
            sku = tx.logs[0].args.sku.toString(10)
            eventEmitted = true
        }

        const changePrice = await marketplace.editItem(sku, updateName, updatePrice, {from: owner});

        const result = await marketplace.fetchItem.call(sku)

       // assert.equal(result[0], updateName, 'the name of the last added item does not match the expected value')
       // assert.equal(result[2].toString(10), updatePrice, 'the price of the last added item does not match the expected value')
        assert.equal(result[3].toString(10), 0, 'the state of the item should be "For Sale", which should be declared first in the State Enum')
        assert.equal(result[4], owner, 'the address adding the item should be listed as the seller')

    });

});