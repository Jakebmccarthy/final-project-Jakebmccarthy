pragma solidity ^0.5.0;

///@title Online Marketplace 
///@author Jake McCarthy

import "./SafeMath.sol";

contract OnlineMarketplace {
    
    //using openzepplin safemath library
    using SafeMath for uint256;
    
    //set owner
    address private owner;
    
    //contract lvl vars 
    uint public skuCount;
    bool private stopped = false;
    
    //mappings
    //map owners to items
    mapping (uint => Item) public items;
    
    mapping (address => User) public users;
    
    
    //States for user and items
    
    enum userState {Customer, StoreOwner, Admin }
    
    enum itemState {ForSale, Sold, Received}
    
    //Structs for Users and itemState
    
    struct User {
        string name;
        userState userstate;
    }
    
    struct Item {
        string name;
        uint256 sku;
        uint256 price;
        itemState itemstate;
        address payable seller;
        address payable buyer;
    }
    
    //events
    
    //user
    event Customer(address accountAddress);
    event StoreOwner(address accountAddress);
    event Admin(address accountAddress);
    
    //item
    event ForSale(uint sku);
    event Sold(uint sku);
    event Received(uint sku);
    
    
    //modifiers
    
    //user access modifiers
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
    
    
    //item state
    modifier forSale(uint sku){
    
    _;
    }
    
    modifier sold(uint sku){
    
    _;
    }
    
    
    //payment 
    modifier paidEnough(uint _price){
     require(msg.value >= _price, "Not paid enough");
      _;
      
  }
  
    modifier checkValue(uint _sku) {
    //refund them after pay for item (why it is before, _ checks for logic before func)
    _;
    uint _price = items[_sku].price;
    uint amountToRefund = msg.value - _price;
    items[_sku].buyer.transfer(amountToRefund);
  }
  
  //circuit breaker modifiers
  modifier stopInEmergency {if (!stopped) _;}
  modifier onlyInEmergency {if (stopped) _;}
  
  //circuit breaker function
  function toggleContractActive() isAdmin public {
    // You can add an additional modifier that restricts stopping a contract to be based on another action, such as a vote of users
    stopped = !stopped;
}
    
    //constructor
    constructor() public {
        owner = msg.sender;
        users[owner] = User({name: "Owner", userstate: userState.Admin});
        skuCount = 0;
    }
    
    

    ///@notice register a user for admins only
    ///@dev use to be registerUser funct. broken up into 3 funct for testing purposes 
    ///@param _useraddress - address of user to register 
    ///@param _name - name of user to register
    ///@param _userstate - state of user e.g access permissions(admin, store owner, customer)
    ///@return true if successful registration, false otherwise
    function registerCustomer(address _useraddress,string memory _name) public isAdmin() stopInEmergency returns(bool) {
        users[_useraddress] = User({name: _name, userstate: userState.Customer});
        emit Customer(_useraddress);
        return true;
    }

    ///@notice register a user for admins only
    ///@dev
    ///@param _useraddress - address of user to register 
    ///@param _name - name of user to register
    ///@param _userstate - state of user e.g access permissions(admin, store owner, customer)
    ///@return true if successful registration, false otherwise
    function registerStoreOwner(address _useraddress,string memory _name) public isAdmin() stopInEmergency returns(bool) {
        users[_useraddress] = User({name: _name, userstate: userState.StoreOwner});
        emit StoreOwner(_useraddress);
        require(users[_useraddress].userstate == userState.StoreOwner);
        return true;
    }

    ///@notice register a user for admins only
    ///@dev
    ///@param _useraddress - address of user to register 
    ///@param _name - name of user to register
    ///@param _userstate - state of user e.g access permissions(admin, store owner, customer)
    ///@return true if successful registration, false otherwise
    function registerAdmin(address _useraddress,string memory _name) public isAdmin() stopInEmergency returns(bool) {
        users[_useraddress] = User({name: _name, userstate: userState.Admin});
        emit Admin(_useraddress);
        return true;
    }
    
    ///@notice update a users permissions for admins only
    ///@dev
    ///@param _useraddress - address of user to update state 
    ///@param _userstate - state of user e.g access permissions(admin, store owner, customer)
    ///@return 
    function updateUserState(address _useraddress, userState _userstate) public isAdmin() stopInEmergency returns ( string memory name, userState userstate) {
        users[_useraddress].userstate = _userstate;
        name = users[_useraddress].name;
        userstate= users[_useraddress].userstate;
        return (name, userstate);
    }
    
    ///@notice add a new item to users store
    ///@dev demonstrates use of external library using add function to add to skuCount
    ///@param name - name of item to be sold
    ///@param price - price of item to be sold
    ///@return true if successfully added item, false otherwise
    function addItem(string memory _name, uint _price) public isStoreOwner() stopInEmergency returns(uint) {
    items[skuCount] = Item({name: _name, sku: skuCount, price: _price, itemstate: itemState.ForSale, seller: msg.sender, buyer: address(0)});
    emit ForSale(skuCount);
    skuCount = skuCount.add(1);
    return skuCount-1;
  }
  
    ///@notice add a new item to users store
    ///@dev
    ///@param name - name of item to be sold
    ///@param price - price of item to be sold
    ///@return true if successfully added item, false otherwise
    function editItem(uint _sku, string memory _name, uint _price) public isStoreOwner() stopInEmergency {
        items[_sku].name = _name;
        items[_sku].price = _price;
    }
    
    ///@notice add a new item to users store
    ///@dev
    ///@param name - name of item to be sold
    ///@param price - price of item to be sold
    ///@return true if successfully added item, false otherwise
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

  /* We have these functions completed so we can run tests, just ignore it :) REMOVE WHEN TEST */
  function fetchItem(uint _sku) public view returns (string memory name, uint sku, uint price, uint itemstate, address seller, address buyer) {
    name = items[_sku].name;
    sku = items[_sku].sku;
    price = items[_sku].price;
    itemstate = uint(items[_sku].itemstate);
    seller = items[_sku].seller;
    buyer = items[_sku].buyer;
    return (name, sku, price, itemstate, seller, buyer);
  }

  /* We have these functions completed so we can run tests, just ignore it :) REMOVE WHEN TEST */
  function fetchUser(address _address) public view returns (string memory name, uint userstate) {
    name = users[_address].name;
    userstate = uint(users[_address].userstate);
    return (name, userstate);
  }


    ///@notice delete contract
    ///@dev mortal design pattern
function kill() private isAdmin{
    if (msg.sender == owner) selfdestruct(msg.sender);
  }
    
    
}
