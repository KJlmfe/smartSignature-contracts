pragma solidity ^0.4.23;
/// @author MinakoKojima(https://github.com/lychees)

import "../lib/OwnerableContract.sol";

contract HotPotatoCreator is OwnerableContract{
    address SmartSignatureContract;
    address HotPotatoContract;

    function setSmartSignatureContract(address _addr) public onlyOwner {
        SmartSignatureContract = _addr;
        SmartSignature s = SmartSignature(_addr);
        s.addAdmin(address(this));
    }    

    function setHotPotatoContract(address _addr) public onlyOwner {
        HotPotatoContract = _addr;
    }
    
    function create(uint256 _price, uint256 _ratio, uint256 _startTime, uint256 _endTime) public {
        SmartSignature s = SmartSignature(SmartSignatureContract);
        HotPotato h = HotPotato(HotPotatoContract);
        uint256 id = s.totalSupply();
        s.issueTokenAndTransfer(msg.sender);
        h.put(SmartSignatureContract, id, _price, _ratio, _startTime, _endTime);
    }
}
interface SmartSignature {
    function issueTokenAndTransfer(address to) external; 
    function addAdmin(address _admin) external;
    function totalSupply() external view returns (uint256 _totalSupply);
}

interface HotPotato {
    function put(address _issuer, uint256 _tokenId, uint256 _price, uint256 _ratio, uint256 _startTime, uint256 _endTime) external;
}