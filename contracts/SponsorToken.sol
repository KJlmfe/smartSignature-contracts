pragma solidity ^0.4.22;

import "./lib/AddressUtils.sol";
import './lib/Owned.sol';

// TODO: SponsorToken is ERC721
contract SponsorToken is Owned {
    using AddressUtils for address;

    event CreateToken(uint256 indexed id, address indexed creator);
    event Sponsor(uint256 indexed id, uint256 value, address indexed sponsor, address indexed referrer);
    event Reward(uint256 indexed id, uint256 value, address indexed to, address indexed from);

    struct Token {
        uint256 id;
        address creator;
        uint256 value;
        uint256 head;
        uint8 ponzi;
        address [] sponsors;
        mapping (address => uint256) remain;
        mapping (address => uint256) total;
    }

    Token[] public tokens; // bug?

    constructor() public {}

    function create(uint8 ponzi) public {
        require(ponzi >= 100 && ponzi <= 200);

        uint256 tokenId = tokens.length;

        Token memory token = Token({
            id: tokenId,
            creator: msg.sender,
            ponzi: ponzi,
            head: 0,
            value: 0,
            sponsors: new address[](0)
        });

        tokens.push(token);

        emit CreateToken(tokenId, msg.sender);
    }

    function sponsor(uint256 _id, address _referrer) public payable {
        require(msg.value > 0);
        require(_id < tokens.length);
        require(_referrer != msg.sender);
        require(!_referrer.isContract());

        Token storage token = tokens[_id];
        token.sponsors.push(msg.sender);

        emit Sponsor(_id, msg.value, msg.sender, _referrer);

        token.value += msg.value;

        // 存入尚未兑现的支票
        token.total[msg.sender] += msg.value * token.ponzi / 100;
        token.remain[msg.sender] += msg.value * token.ponzi / 100;

        uint256 msgValue = msg.value * 97 / 100; // 3% cut off for contract

        if (_referrer != address(0) && token.remain[_referrer] > 0) {
            if (msgValue <= token.remain[_referrer]) {
                token.remain[_referrer] -= msgValue;
                _referrer.transfer(msgValue);
                emit Reward(_id, msgValue, _referrer, msg.sender);
                return;
            } else {
                msgValue -= token.remain[_referrer];
                _referrer.transfer(token.remain[_referrer]);
                emit Reward(_id, token.remain[_referrer], _referrer, msg.sender);
                token.remain[_referrer] = 0;
            }
        }

        while(msgValue > 0) {
            // 除了自己之外，没有站岗的人了，把钱分给Token Creator
            if (token.head + 1 == token.sponsors.length) {
                token.creator.transfer(msgValue);
                emit Reward(_id, msgValue, token.creator, msg.sender);
                return;
            }

            //  把钱分给站岗者们
            address _sponsor = token.sponsors[token.head];
            if (msgValue <= token.remain[_sponsor]) {
                token.remain[_sponsor] -= msgValue;
                _sponsor.transfer(msgValue);
                emit Reward(_id, msgValue, _sponsor, msg.sender);
                return;
            } else {
                msgValue -= token.remain[_sponsor];
                _sponsor.transfer(token.remain[_sponsor]);
                emit Reward(_id, token.remain[_sponsor], _sponsor, msg.sender);
                token.remain[_sponsor] = 0;
                token.head++;
            }
        }
    }

    function totalAndRemainOf(uint256 _id, address _sponsor) public view returns (uint256 total, uint256 remain)  {
        require(_id < tokens.length);
        Token storage token = tokens[_id];
        total = token.total[_sponsor];
        remain = token.remain[_sponsor];
    }

    function sponsorsOf(uint256 _id) public view returns (address []) {
        require(_id < tokens.length);
        Token storage token = tokens[_id];
        return token.sponsors;
    }

    function totalSupply() public view  returns (uint256)  {
        return tokens.length;
    }
}
