pragma solidity ^0.4.22;

contract OwnerableContract{
    address public owner;
    mapping (address => bool) public admins;

    constructor () public { 
        owner = msg.sender; 
        addAdmin(owner);
    }    
  
    /* Modifiers */
    // This contract only defines a modifier but does not use
    // it: it will be used in derived contracts.
    // The function body is inserted where the special symbol
    // `_;` in the definition of a modifier appears.
    // This means that if the owner calls this function, the
    // function is executed and otherwise, an exception is
    // thrown.
    modifier onlyOwner {
        require(
            msg.sender == owner,
            "Only owner can call this function."
        );
        _;
    }
    modifier onlyAdmins() {
        require(
            admins[msg.sender],
            "Only owner can call this function."
        );
        _;
    }    
    
    /* Owner */
    function setOwner (address _owner) onlyOwner() public {
        owner = _owner;
    }

    function addAdmin (address _admin) onlyOwner() public {
        admins[_admin] = true;
    }

    function removeAdmin (address _admin) onlyOwner() public {
        delete admins[_admin];
    }  
    
      /* Withdraw */
    function withdrawAll () onlyAdmins() public {
        msg.sender.transfer(address(this).balance);
    }

    function withdrawAmount (uint256 _amount) onlyAdmins() public {
        msg.sender.transfer(_amount);
    }  
}