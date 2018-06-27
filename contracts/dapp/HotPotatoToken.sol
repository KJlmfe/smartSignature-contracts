pragma solidity ^0.4.23;
/// @author MinakoKojima(https://github.com/lychees)

import "../lib/SmartSignature.sol";

contract HotPotatoToken is SmartSignature{
    struct Token {
        address creator;
        address owner;
        uint256 price;
        uint256 ratio;
        uint256 startTime;
        uint256 endTime;        
    }

    Token[] public tokens;
    constructor() public {
        owner = msg.sender;
        admins[owner] = true;
    }
    
    function getNextPrice (uint256 _id) public pure returns (uint256 _nextPrice) {
        return Token[_id].price * Token[_id].ratio / 100;
    }

     // TODO complete Token info
    function getToken(uint256 _id) public view returns (address _issuer /*, uint256 _tokenId, uint256 _ponzi*/) {
        return (tokens[_id].creator /**/ );
    }
  
    /* ... */
    function create(uint256 _price, uint256 _ratio, uint256 _startTime, uint256 _endTime) public {
        require(_startTime <= _endTime);
        issueToken(address(this));
        Token memory Token = Token({
            creator: msg.sender,
            owner: msg.sender,
            price: _price,
            ratio: _ratio,
            startTime: _startTime,
            endTime: _endTime
        });                
        if (tokensSize == tokens.length) {        
            tokens.push(Token);
        } else {    
            tokens[tokensSize] = Token;
        }
        tokensSize += 1;
    }

    function buy(uint256 _id) public payable{
        require(_id < tokensSize);  
        require(msg.value >= tokens[_id].price);
        require(msg.sender != tokens[_id].owner);
        require(!msg.sender.isContract());
        require(tokens[_id].startTime <= now && now <= tokens[_id].endTime);
        tokens[_id].owner.transfer(tokens[_id].price*24/25); // 96%
        tokens[_id].creator.transfer(tokens[_id].price/50);  // 2%    
        if (msg.value > tokens[_id].price) {
            msg.sender.transfer(msg.value - tokens[_id].price);
        }
        tokens[_id].owner = msg.sender;
        tokens[_id].price = getNextPrice(tokens[_id].price);
    }

    function redeem(uint256 _id) public {
        require(msg.sender == tokens[_id].owner);
        require(tokens[_id].endTime <= now);
        transfer(msg.sender, _id);    
        tokens[_id] = tokens[tokensSize-1];
        tokensSize -= 1;
    }
}