pragma solidity ^0.4.23;

import "./ERC721.sol";
import "./AddressUtils.sol";

contract SmartSignature is ERC721{
    using AddressUtils for address;
    mapping (uint256 => mapping(address => uint256)) public balanceOfToken;

    constructor() public {
        owner = msg.sender;
        admins[owner] = true;    
    }

    function withdrawFromToken(uint256 _tokenId) public {
        // To be implement.
        uint256 value = balanceOfToken[_tokenId][msg.sender];
        balanceOfToken[_tokenId][msg.sender] = 0;
        msg.sender.transfer(value);
    }
}