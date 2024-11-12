pragma solidity 0.5.12;

contract SmartGenie {
    // 1. 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
    // 2. 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
    // 3. 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db
    // 6. 0x17F6AD8Ef982297579C203069C1DbfFE4348c372
    // 7. 0x5c6B0f7Bf3E7ce046039Bd8FABdfD3f9F5021678
    // 8. 0x03C6FcED478cBbC9a4FAB34eF9f40767739D1Ff7
    
    address public ownerWallet;
    address public ursWallet;
    address public promotionWallet;
 
    struct UserStruct {
        bool isExist;
        uint id;
        uint referrerID;
        address[] referral;
        mapping(uint => uint) levelExpired;
        uint joined;
        mapping(uint => uint) incomeCount;
        uint[] levelEligibility;
        uint legCount;
    }
    
    mapping(uint => uint) public LEVEL_PRICE;
    mapping(address => UserStruct) public users;
    mapping(uint => address) public userList;
    
    uint public currUserID = 0;
    uint256 promAmt = 0;
    uint256 ursAmt = 0;
    uint256 regFee = 500 trx;
    
    event regLevelEvent(address indexed _user, address indexed _referrer, uint _time);
    event getMoneyForLevelEvent(address indexed _user, address indexed _referral, uint _level, uint _time);
    event lostMoneyForLevelEvent(address indexed _user, address indexed _referral, uint _level, uint _time);
    
    constructor(address _ursWallet, address _promotionWallet) public {
        // Contract deployer will be the owner wallet 
        ownerWallet = msg.sender;
        ursWallet = _ursWallet;
        promotionWallet = _promotionWallet;
        
        // Setting the price for buying each level
        LEVEL_PRICE[1] = 150 trx;
        LEVEL_PRICE[2] = LEVEL_PRICE[1]*2;
        LEVEL_PRICE[3] = LEVEL_PRICE[2]*2;
        LEVEL_PRICE[4] = LEVEL_PRICE[3]*2;
        LEVEL_PRICE[5] = LEVEL_PRICE[4]*2;
        LEVEL_PRICE[6] = LEVEL_PRICE[5]*2;
        LEVEL_PRICE[7] = LEVEL_PRICE[6]*2;
        LEVEL_PRICE[8] = LEVEL_PRICE[7]*2;
        LEVEL_PRICE[9] = LEVEL_PRICE[8]*2;
        LEVEL_PRICE[10] = LEVEL_PRICE[9]*2;
        LEVEL_PRICE[11] = LEVEL_PRICE[10]*2;
        LEVEL_PRICE[12] = LEVEL_PRICE[11]*2;

        // Create contract deployer as first user
        UserStruct memory userStruct;
        currUserID++;

        userStruct = UserStruct({
            isExist: true,
            id: currUserID,
            referrerID: 0,
            referral: new address[](0),
            joined:now,
            levelEligibility: new uint[](0),
            legCount:0
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
        require(msg.value == regFee, 'Incorrect Value');

        // Conditions verified. Now Registering user
        UserStruct memory userStruct;
        currUserID++;
        
        // Cretaing user object
        userStruct = UserStruct({
            isExist: true,
            id: currUserID,
            referrerID: _referrerID,
            referral: new address[](0),
            joined:now,
            levelEligibility: new uint[](0),
            legCount:0
        });
        users[msg.sender] = userStruct;
        
        // Add new user to existing userlist
        userList[currUserID] = msg.sender;
        
        // push the caller to referral under referrerid
        users[userList[_referrerID]].referral.push(msg.sender);
        
        // update split wallet balances
        ursAmt += LEVEL_PRICE[1];
        promAmt += LEVEL_PRICE[1];
        
        //  A particular users joined 2 referalls, for the 2nd referall transfer amount to contract
        uint referrerReferralLength = users[userList[_referrerID]].referral.length;
        if(referrerReferralLength != 2) {
            // Payment for the level
            payment(1, msg.sender);
        } 
         
        // registration done. Emit event
        emit regLevelEvent(msg.sender, userList[_referrerID], now);
    }
    
    // Payment function for a level
    function payment(uint _level, address _user) internal {
        
        address payer;
        uint256 length = users[userList[users[_user].referrerID]].referral.length; 
        uint256 _levelEligibility;
        bool loop = false;
        if (length == 3) {
             address referrer = userList[users[_user].referrerID]; //3
             users[referrer].incomeCount[_level] = users[referrer].incomeCount[_level]+2;
             
            for(int i=0; i<12; i++) { 
                 uint256 _lelevel = users[referrer].levelEligibility.length-1;
                 _levelEligibility = users[referrer].levelEligibility[_lelevel]; //1  
                 
                 if(_levelEligibility < 2) { 
                     address payer1 = userList[users[referrer].referrerID]; //3
                     referrer = userList[users[payer1].referrerID]; //2
                    if(!users[referrer].isExist || users[payer1].referrerID == 1 || users[payer1].referrerID ==2) { 
                        payer = userList[users[payer1].referrerID];
                        break;
                    } 
                    payer = referrer; //2
                    
                 } else {
                     payer = referrer; // 2
                     break;
                 }
            }
            
            _level = _level+1;
            users[userList[users[_user].referrerID]].levelEligibility.push(_level);
                    
        }
        
        else if (length >= 4 && length % 4 == 0) { // 18 7
             address referrer;
             if(!loop) {
                 referrer = userList[users[_user].referrerID]; //8 6
                 users[referrer].incomeCount[_level] = users[referrer].incomeCount[_level]+1; //8 6
             } else { referrer = _user; }
             
             payer = userList[users[referrer].referrerID]; //7 5
        } else {
            users[userList[users[_user].referrerID]].levelEligibility.push(_level);
            payer = userList[users[_user].referrerID]; //2
        } 
        uint256 payerTempPaymentCount = users[payer].incomeCount[_level]+1;
        // temp increment payer income count to check actual will inctrement during payment
        if(payerTempPaymentCount >= 4 &&
          payerTempPaymentCount % 4 == 0  &&
          users[payer].referrerID!=0
        ) {
           users[payer].incomeCount[_level] = users[payer].incomeCount[_level]+1; 
           loop = true;
           payment(_level, payer); //7(4)
           
        } else 
        {
        /* PROCEEDS PAYMENT */
            if(!users[payer].isExist) payer = userList[1];
            
            users[payer].incomeCount[_level]= users[payer].incomeCount[_level]+1; //7 6
            
            bool sent = false;
            sent = address(uint160(payer)).send(LEVEL_PRICE[_level]);
    
            if (sent) {
                emit getMoneyForLevelEvent(payer, msg.sender, _level, now);
            }
            if(!sent) {
                emit lostMoneyForLevelEvent(payer, msg.sender, _level, now);
            }
        }
    }
    
    
    // // Transfer Promotion Value
    // function transferPromotion(uint256 _amount) public returns (bool) {
    //     require(msg.sender == promotionWallet, "Invalid caller");
    //     require(_amount <= promAmt, "Invalid Amount");
    //      bool sent = false;
    //       sent = address(uint160(promotionWallet)).send(_amount);
    //       return sent;
    // }
     
    //   // Transfer URS Value
    // function transferURS(uint256 _amount) public returns (bool) {
    //     require(msg.sender == ursWallet, "Invalid caller");
    //     require(_amount <= ursAmt, "Invalid Amount");
    //      bool sent = false;
    //       sent = address(uint160(ursWallet)).send(_amount);
    //       return sent;
    // }
    
    
    // Get smartcontract balance
    function getContractBalance() public view returns(uint256) {
        return address(this).balance;
    }
    
    // Get User Level Eligiblities balance
    function getUserLevelEligibility(address _user) public view returns(uint256[] memory) {
        return users[_user].levelEligibility;
    }
    
     // Get Referral users
    function getUserReferrals(address _user) public view returns(address[] memory) {
        return users[_user].referral;
    }
    
       // Get User Level Eligiblities balance
    function getUserIncomeCount(address _user, uint256 _level) public view returns(uint256) {
        return users[_user].incomeCount[_level];
    }

    
}