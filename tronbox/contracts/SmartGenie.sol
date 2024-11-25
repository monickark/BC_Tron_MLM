pragma solidity 0.5.12;

contract SmartGenie {
    // 1. 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
    // 2. 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
    // 3. 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db
    // 6. 0x17F6AD8Ef982297579C203069C1DbfFE4348c372
    // 7. 0x5c6B0f7Bf3E7ce046039Bd8FABdfD3f9F5021678
    // 8. 0x03C6FcED478cBbC9a4FAB34eF9f40767739D1Ff7
    // 16.0x7e1382f17eb86CF86a5301D255420B9D14DD9fCA
    
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
    }
    
    mapping(uint => uint) public LEVEL_PRICE;
    mapping(address => UserStruct) public users;
    mapping(uint => address) public userList;
    mapping(uint256 => mapping(address => address)) public levelUpgradePayments;
    
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
            levelEligibility: new uint[](0)
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
            levelEligibility: new uint[](0)
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
        if(referrerReferralLength != 1) {
            // Payment for the level
            payment(1, msg.sender, referrerReferralLength, false);
        } else {
            users[userList[_referrerID]].levelEligibility.push(1);
            address referrer = userList[_referrerID]; //2
            users[referrer].incomeCount[1] = users[referrer].incomeCount[1]+1;
        }
         
        // registration done. Emit event
        emit regLevelEvent(msg.sender, userList[_referrerID], now);
    }
    
    // Payment function for a level 
    function payment(uint _reglevel, address _user, uint256 length, bool loop) internal { //4
        address payer;
        bool isRenewal = false;
        bool isSameLeg = false;
        bool isPayNeed = true;
        uint256 levelEligibility; 
        uint256 payLevel = _reglevel;
        if (length == 2) {
          (payer, isPayNeed, isSameLeg) = levelUpgrade (_reglevel, _user, levelEligibility, isSameLeg, isPayNeed);
          payLevel = _reglevel+1;
        } else if (length >= 4 && length % 4 == 0) { 
           (payer, isRenewal) = levelRenewal(loop, _user, _reglevel);
        } else {
            payer = userList[users[_user].referrerID];
        } 
        
        // All txion for user1 should proceed
        if (isPayNeed || !users[payer].isExist || payer == userList[1]) {
            (loop, length, _reglevel) = checkLoopRequired(payer, payLevel, length, isRenewal, isSameLeg);
             if(loop) {   
               payment(_reglevel, payer, length, true); 
            } else {
            /* PROCEEDS PAYMENT */
                if(!users[payer].isExist) payer = userList[1];
                
                users[payer].incomeCount[_reglevel]= users[payer].incomeCount[_reglevel]+1; 
                
                bool sent = false;
                sent = address(uint160(payer)).send(LEVEL_PRICE[payLevel]);
        
                if (sent) {
                    emit getMoneyForLevelEvent(payer, msg.sender, payLevel, now);
                }
                if(!sent) {
                    emit lostMoneyForLevelEvent(payer, msg.sender, payLevel, now);
                }
            }
        }
    }
    
    function levelUpgrade(uint256 _regLevel, address _user, uint256 _levelEligibility, bool isSameLeg, bool isPayNeed ) 
             internal returns (address, bool, bool) {
            uint256 upLevel = _regLevel+1;
           address payer; address referrer;
           // find eligible payer
            (payer, referrer) = findEligiblePayer(_user, _regLevel, _levelEligibility);
            
            // check already locked data present for the levelUpgradePayments
            if(!users[payer].isExist || levelUpgradePayments[upLevel][payer] == address(0)) {
                if(!users[payer].isExist) payer = userList[1];
                levelUpgradePayments[upLevel][payer] = referrer;
                users[payer].incomeCount[upLevel] = users[payer].incomeCount[upLevel]+1;
                isPayNeed = false;
            } else {
                address existingReferrer = levelUpgradePayments[upLevel][payer];
                if (isLevelUpgradeFromSameLeg(payer, existingReferrer, referrer)) {
                    users[payer].incomeCount[upLevel] = users[payer].incomeCount[upLevel]+1;
                    isSameLeg = true;
                } else {
                    levelUpgradePayments[upLevel][payer] = referrer;
                }
            }
    
         users[referrer].levelEligibility.push(upLevel);
         return (payer, isPayNeed, isSameLeg);
    }
    
    function findEligiblePayer(address _user, uint256 _regLevel, uint256 _levelEligibility) internal returns (address, address){
           address _referrer = userList[users[_user].referrerID]; //7
           address _eligiblePayer;
            address _tempreferrer = _referrer; 
           // find eligible payer 
            for(int i=0; i<12; i++) { 
                 uint256 _lelevel = users[_tempreferrer].levelEligibility.length-1;
                 _levelEligibility = users[_tempreferrer].levelEligibility[_lelevel]; 
                 
                 address payer1 = userList[users[_tempreferrer].referrerID]; //6
                 address secReferrer = userList[users[payer1].referrerID]; //6
                 
                 if(_levelEligibility < 2) { 
                    if(!users[secReferrer].isExist || users[payer1].referrerID == 0 || 
                        users[payer1].referrerID == 1 || users[payer1].referrerID == 2) { 
                            
                        if(!users[userList[users[payer1].referrerID]].isExist) { 
                            _eligiblePayer = userList[1] ;
                        } else {
                        _eligiblePayer = userList[users[payer1].referrerID];
                        }
                        break;
                    } 
                    _tempreferrer = secReferrer; 
                    _eligiblePayer = secReferrer; 
                    
                 } else {
                     _eligiblePayer = _tempreferrer; 
                     break;
                 }
            }
            
            users[_referrer].incomeCount[_regLevel] = users[_referrer].incomeCount[_regLevel]+1; 
            return (_eligiblePayer, _referrer);
    }
    
    function levelRenewal(bool _loop, address _user, uint256 _regLevel)internal returns(address, bool) {
        bool _isRenewal = true;
        address referrer; address payer;
         if(!_loop) {
             referrer = userList[users[_user].referrerID];
                users[referrer].incomeCount[_regLevel] = users[referrer].incomeCount[_regLevel]+1; 
         } else { referrer = _user; }
        
        payer = userList[users[referrer].referrerID]; 
        if(!users[payer].isExist) payer = userList[1];
        
        return (payer, _isRenewal);
    }
    
    function checkLoopRequired(address _payer, uint256 _regLevel, uint256 _length, bool isRenewal, bool isSameLeg) internal returns (bool, uint256, uint256) {
        bool loop = false;
        uint256 length = _length;
        uint256 tempPaymentCount = users[_payer].incomeCount[_regLevel]+1;
        // temp increment payer income count to check actual will inctrement during payment
        if(tempPaymentCount >= 4 &&
          tempPaymentCount % 4 == 0  &&
          users[_payer].referrerID!=0 && _regLevel == 1
        ) {
           users[_payer].incomeCount[_regLevel] = users[_payer].incomeCount[_regLevel]+1; 
           if(_length == 3 && tempPaymentCount ==4) {
                length = tempPaymentCount;
           }
           
           loop = true;
        }
        
        
        else if (tempPaymentCount >= 4 &&
            tempPaymentCount % 4 == 0  &&
            _length == 2 && !isSameLeg &&
            _regLevel > 1) {
            _regLevel = _regLevel+1;
            loop = true;
        }
        // payers second level upgrade received
         else if(tempPaymentCount == 2 &&
          users[_payer].referrerID!=0 && !isRenewal && !isSameLeg) {
           if(!users[_payer].isExist) _payer = userList[1];
           users[_payer].incomeCount[_regLevel] = users[_payer].incomeCount[_regLevel]+1; 
           length = tempPaymentCount;
           loop = true;
        } 
        
        else if(tempPaymentCount == 1 &&
          users[_payer].referrerID==0) {
           if(!users[_payer].isExist) _payer = userList[1];
           users[_payer].incomeCount[_regLevel] = users[_payer].incomeCount[_regLevel]+1; 
        }
      
        return (loop, length, _regLevel);
    }
    
    function isLevelUpgradeFromSameLeg(address _payer, address _existingReferrer, address _newReferrer) 
            internal view returns(bool){
        bool isSameLeg = false;
        
        address[] memory payerReferrals = getUserReferrals(_payer);
        address firstLeg = _existingReferrer; 
        address secondLeg = _newReferrer;
        
        address tempReferrer1 = userList[users[firstLeg].referrerID]; 
        for(int i=0; i<12; i++) { 
            bool foundReferrer = false;     
            for (uint j=0; j<payerReferrals.length; j++) {
                if(tempReferrer1 == payerReferrals[j]) {
                    firstLeg = payerReferrals[j];
                    foundReferrer = true;
                    break;
                }
            }
            if(foundReferrer) { break;} 
           tempReferrer1 =  userList[users[tempReferrer1].referrerID];
        }
        
        address tempReferrer2 = userList[users[secondLeg].referrerID]; 
        for(int i=0; i<12; i++) { 
            bool foundReferrer = false;     
            for (uint j=0; j<payerReferrals.length; j++) {
                if(tempReferrer2 == payerReferrals[j]) {
                    secondLeg = payerReferrals[j];
                    foundReferrer = true;
                    break;
                }
            }
            if(foundReferrer) { break;} 
            tempReferrer2 = userList[users[tempReferrer2].referrerID]; 
        }
        
        if(firstLeg == secondLeg) {isSameLeg = true;}
         return  isSameLeg;      
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
        return address(this).balance/1000000;
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