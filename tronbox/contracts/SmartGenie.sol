// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.12;

/** 
* @custom:dev-run-script ./test/TestSG.js
*/

contract SmartGenie {
    // 1. 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
    // 2. 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
    // 3. 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db
    // 5. 0x617F2E2fD72FD9D5503197092aC168c91465E7f2
    // 6. 0x17F6AD8Ef982297579C203069C1DbfFE4348c372
    // 7. 0x5c6B0f7Bf3E7ce046039Bd8FABdfD3f9F5021678
    // 8. 0x03C6FcED478cBbC9a4FAB34eF9f40767739D1Ff7
    // 9. 0x1aE0EA34a72D944a8C7603FfB3eC30a6669E454C
    // 16.0x8bE8582bE8C77E06fBE63e7c54671A9444B347F6
    
    address public adminWallet;
    address public ursWallet;
    address public splPromoWallet;
    address public rewardWallet;
 
    struct UserStruct {
        bool isExist;
        uint id;
        uint referrerID;
        address[] referral;
        uint joined;
        mapping(uint => uint) incomeCount;
        uint[] levelEligibility;
    }
    address[4] public promotionWallets;
    uint8[4] public promotionPercantage = [2,1,1,1];
    
    mapping(uint => uint) public LEVEL_PRICE;
    mapping(address => UserStruct) public users;
    mapping(uint => address) public userList;
    mapping(uint256 => mapping(address => uint256)) public levelCounter;
    mapping(uint256 => mapping(address => address)) public levelUpgradePayments;
    mapping(uint256 => mapping(address => bool)) public isLevelUpgradedForAddress;
    
    uint public currUserID = 0;
    uint256 splPromAmt = 0;
    uint256 promAmt = 0;
    uint256 ursAmt = 0;
    uint256 regFee = 50 ether;
    uint256 regShare = (regFee*10)/100; // 10% of reg fee
    uint256 promotionShare = (regFee*5)/100; // 5% 0f reg fee
    uint256 splPromoShare = (regFee*8)/100; // 8% 0f reg fee
    
    event regLevelEvent(address indexed _user, address indexed _referrer, uint _time);
    event getMoneyForLevelEvent(address indexed _user, address indexed _referral, uint _level, uint _time);
    event lostMoneyForLevelEvent(address indexed _user, address indexed _referral, uint _level, uint _time);
    
    modifier onlyAdmin {
        require(msg.sender == adminWallet, "Caller is not Admin.");
        _;
    }
    
    constructor(address _prWallet1, address _prWallet2, 
                address _prWallet3, address _prWallet4, address _sprWallet,
                address _rewardWallet, address _ursWallet) {
        // Contract deployer will be the owner wallet 
        adminWallet = msg.sender;
        ursWallet = _ursWallet;
        splPromoWallet = _sprWallet;
        rewardWallet = _rewardWallet;
        promotionWallets = [_prWallet1, _prWallet2, _prWallet3, _prWallet4];
        
        // Setting the price for buying each level
        LEVEL_PRICE[1] = (regFee*30)/100;
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
        UserStruct storage userStruct = users[adminWallet];
        userStruct.isExist = true;
        userStruct.id = currUserID;
        userStruct.referrerID = 0;
        userStruct.referral = new address[](0);
        userStruct.joined = block.timestamp;
        userStruct.levelEligibility = new uint[](0); 

        currUserID++;
        userList[currUserID] = adminWallet;
    }
    
    // User Registraion must provide Refferrer Id
    function regUser(uint _referrerID) public payable returns (bool) {
        // Caller should not registered already, so his existence in 'users'
        require(!users[msg.sender].isExist, 'User exist');
        // Referrer is should not be empty or caller's own id
        require(_referrerID > 0 && _referrerID <= currUserID, 'Incorrect referrer Id');
        // Caller must provide first level 'LEVEL_PRICE' for registration
        require(msg.value == regFee, 'Incorrect Value');

        // Conditions verified. block.timestamp Registering user
        UserStruct storage userStruct = users[msg.sender];
        userStruct.isExist = true;
        userStruct.id = currUserID;
        userStruct.referrerID = _referrerID;
        userStruct.referral = new address[](0);
        userStruct.joined = block.timestamp;
        userStruct.levelEligibility = new uint[](0); 
        currUserID++;
        
        // Add new user to existing userlist
        userList[currUserID] = msg.sender;
        
        // push the caller to referral under referrerid
        users[userList[_referrerID]].referral.push(msg.sender);
        
        // update split wallet balances
        ursAmt += LEVEL_PRICE[1];
        promAmt += promotionShare;
        splPromAmt += splPromoShare;
        
        //  A particular users joined 2 referalls, for the 2nd referall transfer amount to contract
        uint referrerReferralLength = users[userList[_referrerID]].referral.length;
        if(referrerReferralLength != 1 || _referrerID == 1) {
            // Payment for the level
            payment(1, msg.sender, referrerReferralLength, false);
        } else {
            users[userList[_referrerID]].levelEligibility.push(1);
            address referrer = userList[_referrerID]; //2
            users[referrer].incomeCount[1] = users[referrer].incomeCount[1]+1;
        }
        
        // pay 10% of regfee to referrers for all new registrations
        // address(uint160(userList[_referrerID])).transfer(regShare); remove this after works
        (bool success,) = (userList[_referrerID]).call{value: regShare}("");
        require(success, 'Transaction failed!');
        // registration done. Emit event
        emit regLevelEvent(msg.sender, userList[_referrerID], block.timestamp);
        return success;
        
    }
    
    // Payment function for a level 
    function payment(uint _reglevel, address _user, uint256 length, bool loop) internal { //4
        address payer;
        bool isRenewal = false;
        bool isSameLeg = false;
        bool isPayNeed = true;
        uint256 levelEligibility; 
        uint256 payLevel = _reglevel;
        
        // level upgrade
        if (length == 2) {
          (payer, isPayNeed, isSameLeg) = levelUpgrade (_reglevel, _user, levelEligibility, isSameLeg, isPayNeed);
          payLevel = _reglevel+1;
        } 
         // level renewal
        else if (length >= 20 && length % 20 == 0) { 
           payer = rewardWallet;
        } 
        // level renewal
        else if (length >= 4 && length % 4 == 0) { 
           (payer, isRenewal) = levelRenewal(loop, _user, _reglevel);
        } 
        // other payments
        else {
            payer = userList[users[_user].referrerID];
        } 
        
        // All txion for user1 should proceed
        if (isPayNeed || !users[payer].isExist || payer == userList[1]) {
            (loop, length) = checkLoopRequired(payer, payLevel, length, isRenewal, isSameLeg);
             if(loop) {  
            // IsPayneed & !isSameleg refers the loop is for new level upgrade
                 if(isPayNeed && !isSameLeg && length==2) {
                    _reglevel = payLevel;
                }
                // Renewal of level upgrade 4th payment
                 if(isPayNeed && !isSameLeg && length == 4 && payLevel>1) {
                    _reglevel = payLevel;
                }
               
               payment(_reglevel, payer, length, true); 
            } else {
            /* PROCEEDS PAYMENT */
                if(!users[payer].isExist) payer = userList[1];
                
                users[payer].incomeCount[payLevel]= users[payer].incomeCount[payLevel]+1; 
                
               // sent = address(uint160(payer)).send(LEVEL_PRICE[payLevel]); remove this after works
                (bool success,) = (address(uint160(payer))).call{value: LEVEL_PRICE[payLevel]}("");
                require(success, 'Transaction failed!');

                if (success) {
                    emit getMoneyForLevelEvent(payer, msg.sender, payLevel, block.timestamp);
                }
                if(!success) {
                    emit lostMoneyForLevelEvent(payer, msg.sender, payLevel, block.timestamp);
                }
            }
        }
    }
    
    /**
    1. check already locked data present for the levelUpgradePayments for particular payer and level
    2. If not 
        - no payment PROCEED
        - increase incomeCount
        - update levelUpgradePayments for payer and level withreferrer
    3. If record already present
        - Check new record from same leg or not
            ** If isSameLeg
                - Proceed payment
                - increment income counter for referrer (Payer income counter will update during payment)
            ** If not isSameLeg
                - Proceed payment
                - increment incomecounter for referrer (Payer level upgrade incomecouter will update during payment)
    */
    
    function levelUpgrade(uint256 _regLevel, address _user, uint256 _levelEligibility, bool isSameLeg, bool isPayNeed ) 
             internal returns (address, bool, bool) {
            uint256 upLevel = _regLevel+1;
            address payer; address referrer;
           // find eligible payer
           if(upLevel <= 2) {
             referrer = userList[users[_user].referrerID]; //7
           } else {referrer = _user;}
            (payer, referrer) = findEligiblePayer(referrer, _regLevel, _levelEligibility);
            
           
            if(!users[payer].isExist || 
                (levelUpgradePayments[upLevel][payer] == address(0) && 
                    isLevelUpgradedForAddress[upLevel][payer] ==  false)) {
                if(!users[payer].isExist) payer = userList[1];
                
                //For payer as user1 anyways payment will proceed, so no need to update incomecount block.timestamp
                if(payer != userList[1]) {
                    users[payer].incomeCount[upLevel] = users[payer].incomeCount[upLevel]+1;
                    isPayNeed = false;
                }
                
                // for all payers update levelupgrade payments
                levelUpgradePayments[upLevel][payer] = referrer;
                
                // for all payers update levelupgrade payments
                levelCounter[upLevel][payer] = 1;
            } else {
                address existingReferrer = levelUpgradePayments[upLevel][payer];
                if (isLevelUpgradeFromSameLeg(payer, existingReferrer, referrer)) {
                    isSameLeg = true;
                } else {
                    // remove level upgrame variable after level upgrade
                    levelUpgradePayments[upLevel][payer] = address(0);
                    isLevelUpgradedForAddress[upLevel][payer] = true;
                    levelCounter[upLevel][payer] = levelCounter[upLevel][payer] + 1;
                }
            }
         
         users[referrer].levelEligibility.push(upLevel);
         return (payer, isPayNeed, isSameLeg);
    }
    
    function findEligiblePayer(address _referrer, uint256 _regLevel, uint256 _levelEligibility) internal returns (address, address){
           address _eligiblePayer;
            address _tempreferrer = _referrer; 
                
                if(users[_referrer].referrerID == 1) {
                 _eligiblePayer = userList[users[_referrer].referrerID];
                } else {
               // find eligible payer 
                for(int i=0; i<12; i++) { 
                     uint256 _lelevel = users[_tempreferrer].levelEligibility.length-1;
                     _levelEligibility = users[_tempreferrer].levelEligibility[_lelevel]; 
                     
                     address payer1 = userList[users[_tempreferrer].referrerID]; //6
                     address secReferrer = userList[users[payer1].referrerID]; //6
                     
                     if(_regLevel == 2) {
                         secReferrer = userList[users[secReferrer].referrerID]; 
                     }
                     
                     if(_regLevel == 3) {
                         address secReferrer1 = userList[users[secReferrer].referrerID]; 
                         secReferrer = userList[users[secReferrer1].referrerID]; 
                     }
                     //LE initially 
                     if(_levelEligibility < _regLevel+1) { 
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
            }
            users[_referrer].incomeCount[_regLevel] = users[_referrer].incomeCount[_regLevel]+1; 
            return (_eligiblePayer, _referrer);
    }
    
    function levelRenewal(bool _loop, address _user, uint256 _regLevel)internal returns(address, bool) {
        bool _isRenewal = true;
        address referrer; address payer;
         if(!_loop) {
             referrer = userList[users[_user].referrerID];
         } else { referrer = _user; }
        
        users[referrer].incomeCount[_regLevel] = users[referrer].incomeCount[_regLevel]+1; 
        payer = userList[users[referrer].referrerID]; 
        if(!users[payer].isExist) payer = userList[1];
        
        return (payer, _isRenewal);
    }
    
    function checkLoopRequired(address _payer, uint256 _regLevel, uint256 _length, bool isRenewal, bool isSameLeg) 
            internal view returns (bool, uint256) {
        bool loop = false;
        uint256 length = _length;
        
        // temp increment payer income count to check actual will inctrement during payment
        uint256 tempPaymentCount = users[_payer].incomeCount[_regLevel]+1;
        
        // level upgrade of diff leg
        if(levelCounter[_regLevel][_payer] == 2) {
            loop = true;
        }
        
        /**
        Every fourth income counter of first leveel increment income counter and looping again to check referrers income counter
        */
        else if(tempPaymentCount >= 4 &&
          tempPaymentCount % 4 == 0  &&
          users[_payer].referrerID!=0 && _regLevel == 1
        ) {
          if(_length == 3 && tempPaymentCount ==4) {
                length = tempPaymentCount;
          } 
           loop = true;
        }
        
        /**
        Every fourth income counter of level upgrade increment level no and looping again to check further referrer
        */
        else if (tempPaymentCount >= 4 &&
            tempPaymentCount % 4 == 0  &&
            _length == 2 && !isSameLeg &&
            _regLevel > 1) {
             // on levelupgrade 4th payment no loop required for contract owner as payer
            if(_payer == userList[1]) {
                loop = false;
            } else {
                length = 4;
                loop = true;
            }
        }
        
        // payers second level upgrade received
         else if(tempPaymentCount == 2 &&
          users[_payer].referrerID!=0 && !isRenewal && !isSameLeg) {
           if(!users[_payer].isExist) _payer = userList[1];
            if(_payer == userList[1]) {
                loop = false;
            } else {
                loop = true;
                length = tempPaymentCount;
            }
        } 
        
        // First referrer for a user, no payments just amount got hold in contract increment income count for the referrer
        else if(tempPaymentCount == 1 &&
          users[_payer].referrerID==0) {
           if(!users[_payer].isExist) _payer = userList[1];
        }
      
        return (loop, length);
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
    
    
    // Transfer Promotion Value
    function withdrawPromotion() public returns (bool) {
        bool checkCaller = false;
        uint callerIndex = 0;
        for (uint i = 0; i < promotionWallets.length; i++) {
            if (promotionWallets[i] == msg.sender) {
                checkCaller = true;
                callerIndex = i;
                break;
            }
        }

        require(checkCaller == true, "Invalid caller");
        uint maxEligibleAmount = (promAmt * promotionPercantage[callerIndex])/100;
        // bool sent = false;
        // sent = address(uint160(msg.sender)).send(maxEligibleAmount); remove this after works
        (bool success,) = (address(uint160(msg.sender))).call{value: maxEligibleAmount}("");
        require(success, 'Transaction failed!');
        return success;
    }
    
    // Withdraw Special Promotion Value
    function withdrawSplPromotion() public returns (bool) {
        require(msg.sender == splPromoWallet, "Invalid caller");
        // bool sent = false;
        // sent = address(uint160(splPromoWallet)).send(splPromAmt); remove this after works
        (bool success,) = (address(uint160(splPromoWallet))).call{value: splPromAmt}("");
        require(success, 'Transaction failed!');
        return success;
    }
     
    // Withdraw URS Value
    function transferURS() public returns (bool) {
        require(msg.sender == ursWallet, "Invalid caller");
        // bool sent = false;
        // sent = address(uint160(ursWallet)).send(ursAmt); remove this after works
        (bool success,) = (address(uint160(ursWallet))).call{value: ursAmt}("");
        require(success, 'Transaction failed!');
        return success;
    }
    
    // index 0-3 : promotion wallets, 4 : SplPromotionWallet, 5: URS Wallet
    function updatePromotionWallet(address walletAddr, uint index) onlyAdmin public {
        require(msg.sender == adminWallet, "Invalid caller");
        require(index <= 5, "Invalid Index");
        if(index <=3 ) {
            promotionWallets[index-1] = walletAddr;
        } else if (index == 4) {
            splPromoWallet = walletAddr;
        } else {
            ursWallet = walletAddr; // for index 5
        }
    }
    
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