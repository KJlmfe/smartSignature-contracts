pragma solidity ^0.4.23;
/// @author MinakoKojima(https://github.com/lychees)

import "../lib/OwnerableContract.sol";

contract HotPotato is OwnerableContract{
    struct Order {
        address creator;
        address issuer;
        address owner;
        uint256 tokenId;
        uint256 price;
        uint256 ratio;
        uint256 startTime;
        uint256 endTime;        
    }

    Order[] private orderBook;
    uint256 private orderBookSize;
    
    /* Util */
    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { 
            size := extcodesize(addr) 
        } // soliumdisableline
        return size > 0;
    }  

    function getNextPrice (uint256 _price) public pure returns (uint256 _nextPrice) {
        return _price * 123 / 100;
    }      

    function HotPotato() public { // 会调用父类构造函数吗？
        owner = msg.sender;
        admins[owner] = true;    
    }
  
    function totalOrder() public view returns (uint256 _totalOrder) {
        return orderBookSize;
    }
     // TODO complete order info
    function getOrder(uint256 _id) public view returns (address _issuer /*, uint256 _tokenId, uint256 _ponzi*/) {
        return (orderBook[_id].creator /**/ );
    }
  
    /* Buy */
    function put(address _issuer, uint256 _tokenId, uint256 _price, uint256 _ratio, uint256 _startTime, uint256 _endTime) public {
        require(_startTime <= _endTime);                 
        Issuer issuer = Issuer(_issuer);
        require(issuer.ownerOf(_tokenId) == msg.sender);
        issuer.transferFrom(msg.sender, address(this), _tokenId);
        Order memory order = Order({
            creator: msg.sender, 
            owner: msg.sender, 
            issuer: msg.sender, 
            tokenId: _tokenId,
            price: _price,
            ratio: _ratio,
            startTime: _startTime,
            endTime: _endTime
        });                
        if (orderBookSize == orderBook.length) {        
            orderBook.push(order);
        } else {    
            orderBook[orderBookSize] = order;
        }
        orderBookSize += 1;
    }

    function buy(uint256 _id) public payable{
        require(_id < orderBookSize);  
        require(msg.value >= orderBook[_id].price);
        require(msg.sender != orderBook[_id].owner);
        require(!isContract(msg.sender));
        require(orderBook[_id].startTime <= now && now <= orderBook[_id].endTime);
        orderBook[_id].owner.transfer(orderBook[_id].price*24/25); // 96%
        orderBook[_id].creator.transfer(orderBook[_id].price/50);  // 2%    
        if (msg.value > orderBook[_id].price) {
            msg.sender.transfer(msg.value - orderBook[_id].price);
        }
        orderBook[_id].owner = msg.sender;
        orderBook[_id].price = getNextPrice(orderBook[_id].price);
    }

    function redeem(uint256 _id) public {
        require(msg.sender == orderBook[_id].owner);
        require(orderBook[_id].endTime <= now);
        Issuer issuer = Issuer(orderBook[_id].issuer);
        issuer.transfer(msg.sender, orderBook[_id].tokenId);    
        orderBook[_id] = orderBook[orderBookSize-1];
        orderBookSize -= 1;
    }
}

interface Issuer {
    function transferFrom(address _from, address _to, uint256 _tokenId) external;  
    function transfer(address _to, uint256 _tokenId) external;
    function ownerOf (uint256 _tokenId) external view returns (address _owner);
}