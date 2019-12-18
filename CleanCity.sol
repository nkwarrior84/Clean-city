pragma solidity ^0.5.1;

contract CleanCity {
    event LogFailure(string message);
    
    struct poolWork {
        uint reward;
        uint deadline;
        string title;
        address payable don_address;
        address payable [] participants;
    }
    
    struct donation {
        uint amount;
        address don_address;
    }
    
    struct request{
        address creator;
        address participant;
    }
    
    
    address public cityFund;
    uint fund;
    
    mapping (address => bool) public donators;
    mapping (address => donation) public donations;
    mapping (address => poolWork) public pools;
    
    mapping (address => bool) public participants;
    mapping (address => poolWork) public participations;
    
    request[] requests;
    
    uint public totalFund;
    uint public donationsCount;
    uint public donatorsCount;

    
    
    modifier onlyCityFund {
        require(msg.sender == cityFund);
        _;
    }
    
    
    constructor() public{
        cityFund = msg.sender;
    }
    
    
    function createPoolWork(uint _reward,uint _deadline, string memory _title, address payable _don_address) public {
        address payable [] memory test;
        if(donators[_don_address])
        {
            pools[_don_address] = poolWork({
                reward: _reward,
                deadline: now + _deadline* 1 days,
                title: _title,
                don_address: _don_address,
                participants: test
            });
        }
        else
        {
            emit LogFailure("Pool Work can only be initiated by a donator");
        }
    }
    
    function registerAsDonator() public {
        donators[msg.sender] = true;
        donations[msg.sender] = donation({
            amount: 0,
            don_address: msg.sender
        });
    }
    
    function donate() public payable {
        require(donators[msg.sender] == true);
        donations[msg.sender].amount = donations[msg.sender].amount + msg.value ;
        fund = fund+ msg.value ;
    }
    
    function getPool() public view returns(uint,uint,string memory,address) {
        return (pools[msg.sender].reward,pools[msg.sender].deadline,pools[msg.sender].title,pools[msg.sender].don_address);
    }
    
    function withdraw() public payable{
        require(participants[msg.sender] == true);
        msg.sender.transfer(donations[msg.sender].amount);
        fund = fund - donations[msg.sender].amount;
        donations[msg.sender].amount = 0;
    }
    
    function registerAsParticipant() public{
        participants[msg.sender] = true;
    }
    
    function registerInPool(address _creator) public{
        pools[_creator].participants.push(msg.sender);
    }
    
    function claimMoney(address _creator) public{
        require(participants[msg.sender] == true);
        request memory req = request({
                creator: _creator,
                participant: msg.sender
            });
        requests.push(req);
    }
    
    function authorizeMoney(address payable _part) public{
        require(msg.sender == cityFund);
        uint reward = participations[_part].reward;
        uint share = reward/participations[_part].participants.length;
        _part.transfer(share);
        fund = fund-share;
        request memory req = request({
                creator: participations[_part].don_address,
                participant: _part
            });
        
        for (uint i=0; i<requests.length; i++) {
            if (requests[i].creator == req.creator &&requests[i].participant == req.participant) {
                delete requests[i];
            }
        }
    }
    
    
}