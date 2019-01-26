# Design Pattern Decisions

## Access Restriction

Access modifiers to limit access to functions
Admins have the most access while customers the least
Prevents customers accessing functions like addding an item
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

## Circuit Breaker

The circuit breaker pattern allows the contract owner (or in this case anyone with Admin privelages) the ablility to stop certain functions in case there is an unexpected bug that is found.
```
  //circuit breaker modifiers
  modifier stopInEmergency {if (!stopped) _;}
  modifier onlyInEmergency {if (stopped) _;}
  
  //circuit breaker function
  function toggleContractActive() isAdmin public {
    // You can add an additional modifier that restricts stopping a contract to be based on another action, such as a vote of users
    stopped = !stopped;
}
```

## Auto-Deprecation

Included the mortal design pattern to allow the owner of the contract to self destruct if the need arises
```
function kill() private isAdmin{
    if (msg.sender == owner) selfdestruct(msg.sender);
  }
```
