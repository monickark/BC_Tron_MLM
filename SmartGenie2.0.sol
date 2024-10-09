pragma solidity 0.5.12;

contract SmartGenie {
    address public ownerWallet;
 
    struct UserStruct {
        bool isExist;
        uint id;
        uint referrerID;
        address[] referral;
        mapping(uint => uint) levelExpired;
        uint joined;
    }
    
    
    mapping(uint => uint) public LEVEL_PRICE;
    mapping (address => UserStruct) public users;
    mapping (uint => address) public userList;
    
    uint public currUserID = 0;
    
    event regLevelEvent(address indexed _user, address indexed _referrer, uint _time);
    event getMoneyForLevelEvent(address indexed _user, address indexed _referral, uint _level, uint _time);
    event lostMoneyForLevelEvent(address indexed _user, address indexed _referral, uint _level, uint _time);
    
    constructor() public {
         
        // Contract deployer will be the owner wallet 
        ownerWallet = msg.sender;

        // Setting the price for buying each level
        LEVEL_PRICE[1] = 150 trx;
        LEVEL_PRICE[2] = LEVEL_PRICE[1]*2 trx;
        LEVEL_PRICE[3] = LEVEL_PRICE[2]*2 trx;
        LEVEL_PRICE[4] = LEVEL_PRICE[3]*2 trx;
        LEVEL_PRICE[5] = LEVEL_PRICE[4]*2 trx;
        LEVEL_PRICE[6] = LEVEL_PRICE[5]*2 trx;
        LEVEL_PRICE[7] = LEVEL_PRICE[6]*2 trx;
        LEVEL_PRICE[8] = LEVEL_PRICE[7]*2 trx;
        LEVEL_PRICE[9] = LEVEL_PRICE[8]*2 trx;
        LEVEL_PRICE[10] = LEVEL_PRICE[9]*2 trx;

        // Create contract deployer as first user
        UserStruct memory userStruct;
        currUserID++;

        userStruct = UserStruct({
            isExist: true,
            id: currUserID,
            referrerID: 0,
            referral: new address[](0),
            joined:now
        });
        users[ownerWallet] = userStruct;
        userList[currUserID] = ownerWallet;

    }
    
    
    // User Registraion must provide Refferrer Id
    function regUser(uint _referrerID) public payable {
        // Caller should not registered already, so his existence in 'users'
        require(!users[msg.sender].isExist, 'User exist');
        // Referrer is should not be empty or caller's own id
        require(_referrerID > 0 && _referrerID <= currUserID, 'Incorrect referrer Id');
        // Caller must provide first level 'LEVEL_PRICE' for registration
        require(msg.value == LEVEL_PRICE[1], 'Incorrect Value');

        
        // Conditions verified. Now Registering user
        UserStruct memory userStruct;
        currUserID++;
        
        // Cretaing user object
        userStruct = UserStruct({
            isExist: true,
            id: currUserID,
            referrerID: _referrerID,
            referral: new address[](0),
            joined:now
        });
        users[msg.sender] = userStruct;
        
        // Add new user to existing userlist
        userList[currUserID] = msg.sender;

        // Add the new user as referral for the given referrer id
        users[userList[_referrerID]].referral.push(msg.sender);
       
        // Payment for the level
        payForLevel(1, msg.sender);
            
    
        // registration done. Emit event
        emit regLevelEvent(msg.sender, userList[_referrerID], now);
    }
    
    
    // Payment function for a level
    function payForLevel(uint _level, address _user) internal {
        address payer;
        uint level;
        // Check level and get referrer id for the user
        if(_level == 1) {
            level = _level;
             if(users[userList[users[_user].referrerID]].referral.length == 1) {
                 payer = userList[users[_user].referrerID];
             } else if(users[userList[users[_user].referrerID]].referral.length == 3) {
                 address referrer = userList[users[_user].referrerID];
                 payer = userList[users[referrer].referrerID];
                 level = _level+1;
             } else {
                 //  A particular users joined 2 referalls, for the 2nd referall transfer amount to contract
                 payer = address(this);
            }
        }
        
        bool sent = false;
            sent = address(uint160(payer)).send(LEVEL_PRICE[level]);

            if (sent) {
                emit getMoneyForLevelEvent(payer, msg.sender, level, now);
            }
            if(!sent) {
                emit lostMoneyForLevelEvent(payer, msg.sender, level, now);
    
                payForLevel(level, payer);
            }
    }
    
    // Get smartcontract balance
    function getContractBalance() public view returns(uint256) {
        return address(this).balance;
    }
    
    
}