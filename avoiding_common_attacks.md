# Avoiding Common Attacks

## Integer Under/Overflow
Added in the SafeMath library to help prevent under/overflow. Implemented the add() function to prevent a negative sku
```
    function addItem(string memory _name, uint _price) public isStoreOwner() stopInEmergency returns(bool) {
    emit ForSale(skuCount);
    items[skuCount] = Item({name: _name, sku: skuCount, price: _price, itemstate: itemState.ForSale, seller: msg.sender, buyer: address(0)});
    skuCount = skuCount.add(1);
    return true;
  }
```

##Access Modifiers/Ownable
3 different levels of access control from cutomer upto admin(equivalent of owner). This prevents unauthorised users getting access to functions controlling contract behaviour
```
    modifier isCustomer(){
        require(users[msg.sender].userstate >= userState.Customer, "Caller not Customer/Owner/Admin" );
    _;    
    }
    
    modifier isStoreOwner(){
        require(users[msg.sender].userstate >= userState.StoreOwner, "Caller not Store Owner/Admin" );
    _;    
    }
    
    modifier isAdmin(){
        require(users[msg.sender].userstate == userState.Admin, "Caller not Admin" );
    _;    
    }
```
## Rentrancy 
To avoid rentrancy problems withdrawals have limited and ```transfer()``` is used to move ether directly from buyer to seller rather than storing ether in the contract itself
```
 function buyItem(uint sku)
    public
    payable
    forSale(sku)
    isCustomer()
    checkValue(sku)
    paidEnough(msg.value)
    stopInEmergency
  {
    items[sku].seller.transfer(items[sku].price);
    items[sku].buyer = msg.sender;
    items[sku].itemstate = itemState.Sold;
    emit Sold(sku);  
  }
```