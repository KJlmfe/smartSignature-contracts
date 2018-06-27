pragma solidity ^0.4.23;

import "ERC721.sol";

contract SmartSignature is ERC721{
    function SmartSignature() public {
        owner = msg.sender;
        admins[owner] = true;    
    }

    function withdrawFromToken(uint256 _tokenId) public {
        // To be implement.
    }
}