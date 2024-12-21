pragma solidity 0.5.12;
contract SmartGenie {
    
    // TWAY8fGTBHfWwsXLwnSsd5oh5ZrRqWusne
    // TJ1WCZPs1PJP2q368UKEdsWiYdz9GT43vj
    // TGowyTywdUG97ynWMrX2QYa5hJGxhooian
    // TBqKMWLLryq6tu23owfQgTFaVs91H3maj4
    // TUQPrDEJkV4ttkrL7cVv1p3mikWYfM7LWt
    // TAtHD5aZtCupG35MxSmgkV64C4WV2f12DT
    // TCRL1QU9ybjW8CE2sPjCMpkAJBj5Xf7iVh
    
    address public adminWallet;
    address public ursWallet;
    address public splPromoWallet;
    
    uint256 INCOME_LIMIT = 20;
    uint256 SECOND_INCOME_LIMIT = 100;uint public currUserID = 0;
    uint256 tronsportFee = 0;
    uint256 splPromAmt = 0;
    uint256 promAmt = 0;
    uint256 ursAmt = 0;
    uint256 regFee = 500 trx;
    uint256 regShare = (regFee*10)/100; // 10% of reg fee
    uint256 promotionShare = (regFee*5)/100; // 5% 0f reg fee
    uint256 splPromoShare = (regFee*8)/100; // 8% 0f reg fee
    
    address[4] public promotionWallets;
    uint8[4] public promotionPercantage = [40,20,20,20];
    uint256[4]  promotionWalletsAmount;

    mapping(uint256 => uint256) public LEVEL_PRICE;
    mapping(address => UserStruct) public users;
    mapping(uint256 => address) public userList;
    mapping(uint => uint) public TS_LEVEL_PRICE;
    mapping(address => TSUserStruct) public tsUsers;
    mapping(uint256 => mapping(address => uint256)) public levelCounter;
    mapping(uint256 => mapping(address => address)) public levelUpgradePayments;
    mapping(uint256 => mapping(address => bool)) public isLevelUpgradedForAddress;
    mapping(address => paymentStruct[]) public payments;
    
    event buyLevelEvent(address indexed _user, uint256 _level, uint256 _time);
    
    struct TSUserStruct {
        uint256 earning;
        bool isExist;
        uint256 id;
        uint256 referrerID;
        address[] referral;
        address[] indirectReferral;
        mapping(address => uint256) indirectReferralMap;
        mapping(address => uint256) referralMap;
        uint256 directReferralCount;
        uint256 indirectReferralCount;
        uint256 indirectReferralLength;
        uint256 level2PurchaseDate;
    }

    struct paymentStruct {
        uint256 payerId;
        uint256 amount;
    }
 
    struct UserStruct {
        bool isExist;
        uint id;
        uint referrerID;
        address[] referral;
        uint joined;
        mapping(uint => uint) incomeCount;
        uint[] levelEligibility;
    }
    
    event regLevelEvent(address indexed _user, address indexed _referrer, uint _time);
    event getMoneyForLevelEvent(address indexed _user, address indexed _referral, uint _level, uint _time);
    event lostMoneyForLevelEvent(address indexed _user, address indexed _referral, uint _level, uint _time);
    
    modifier onlyAdmin {
        require(msg.sender == adminWallet, "Caller is not Admin.");
        _;
    }
    
    constructor(address _prWallet1, address _prWallet2, 
                address _prWallet3, address _prWallet4, address _sprWallet,
                address _ursWallet) public {
        // Contract deployer will be the owner wallet 
        adminWallet = msg.sender;
        ursWallet = _ursWallet;
        splPromoWallet = _sprWallet;
        promotionWallets = [_prWallet1, _prWallet2, _prWallet3, _prWallet4];
        
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
        
        users[adminWallet] = userStruct;
        userList[currUserID] = adminWallet;
        
        // TRONSPORT INITIALIZATION
        
        TS_LEVEL_PRICE[1] = 200 trx;
        TS_LEVEL_PRICE[2] = 1000 trx;
        TS_LEVEL_PRICE[3] = 5000 trx;
        
        TSUserStruct memory tsUserStruct;

        tsUserStruct = TSUserStruct({
            earning: 0,
            isExist: true,
            id: currUserID,
            referrerID: 0,
            referral: new address[](0),
            indirectReferral: new address[](0),
            indirectReferralCount: 0,
            indirectReferralLength: 0,
            directReferralCount: 0,
          //  joined: now,
            level2PurchaseDate: 0
        });
        
        
        tsUsers[adminWallet] = tsUserStruct;
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
        promAmt += promotionShare;
        splPromAmt += splPromoShare;
        
        // update promotion wallet amount of individuals
        promotionWalletsAmount[0] = (promAmt * promotionPercantage[0])/100;
        promotionWalletsAmount[1] = (promAmt * promotionPercantage[1])/100;
        promotionWalletsAmount[2] = (promAmt * promotionPercantage[2])/100;
        promotionWalletsAmount[3] = (promAmt * promotionPercantage[3])/100;
        
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
        
        // Calling tronsport reg function
         tsRegUser(_referrerID);
        // require(sent, "Failed to send Ether");
        
        // pay 10% of regfee to referrers for all new registrations
        address(uint160(userList[_referrerID])).transfer(regShare);
        
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
        
        // level upgrade
        if (length == 2) {
          (payer, isPayNeed, isSameLeg) = levelUpgrade (_reglevel, _user, levelEligibility, isSameLeg, isPayNeed);
          payLevel = _reglevel+1;
        } 
         // level renewal
        else if (length >= 20 && length % 20 == 0) { 
          // payer = address(tronsport);
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
                
                //For payer as user1 anyways payment will proceed, so no need to update incomecount now
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
    
    
   function tsRegUser(uint256 _referrerID) internal {
        require(
            _referrerID > 0 && _referrerID <= currUserID,
            "Incorrect referrer Id"
        );
        _referrerID = users[findFreeReferrer(userList[_referrerID])].id;

        uint256 activeReferrerId = findActiveReferrer(_referrerID, false);
        uint256 referalCount = tsUsers[userList[_referrerID]]
            .directReferralCount +
            tsUsers[userList[_referrerID]].indirectReferralCount;

        bool storeLostProfit = true;
        if (
            activeReferrerId == _referrerID ||
            (isUserActive(userList[_referrerID]) &&
                endsWith2or4(referalCount + 1) == true)
        ) {
            storeLostProfit = false;
            tsUsers[userList[_referrerID]].directReferralCount += 1;
        } else if (
            isUserActive(userList[_referrerID]) &&
            ((payments[userList[_referrerID]].length >= INCOME_LIMIT &&
                tsUsers[userList[_referrerID]].directReferralCount < 3) ||
                (payments[userList[_referrerID]].length >=
                    SECOND_INCOME_LIMIT &&
                    tsUsers[userList[_referrerID]].directReferralCount < 5))
        ) {
            storeLostProfit = false;
            tsUsers[userList[_referrerID]].directReferralCount += 1;
        }

        tsUsers[msg.sender] = TSUserStruct({
            earning: 0,
            isExist: true,
            id: currUserID,
            referrerID: activeReferrerId,
            referral: new address[](0),
            indirectReferral: new address[](0),
            directReferralCount: 0,
            indirectReferralCount: 0,
            indirectReferralLength: 0,
          //  joined: now,
            level2PurchaseDate: 0
        });
        userList[currUserID] = msg.sender;

        if (activeReferrerId == _referrerID) {
            tsUsers[userList[activeReferrerId]].referral.push(msg.sender);
            tsUsers[userList[activeReferrerId]].referralMap[msg.sender] = users[
                userList[activeReferrerId]
            ].referral.length;
        } else {
            if (activeReferrerId == 0) {
                activeReferrerId = 1;
            }

            tsUsers[userList[activeReferrerId]].indirectReferral.push(msg.sender);
            tsUsers[userList[activeReferrerId]].indirectReferralLength += 1;
            tsUsers[userList[activeReferrerId]].indirectReferralCount += 1;

            tsUsers[userList[activeReferrerId]].indirectReferralMap[
                msg.sender
            ] = tsUsers[userList[activeReferrerId]].indirectReferralLength;

        }


        tsPayForLevel(1, userList[activeReferrerId]);

        emit regLevelEvent(msg.sender, userList[activeReferrerId], now);
    }
    
    
    function tsPayForLevel(uint256 _level, address referrer) internal {
        bool sent;
        sent = address(uint160(referrer)).send(TS_LEVEL_PRICE[_level]);

        if (sent) {
            tsUsers[referrer].earning += TS_LEVEL_PRICE[_level];
            payments[referrer].push(
                paymentStruct({
                    payerId: users[msg.sender].id,
                    amount: TS_LEVEL_PRICE[_level]
                })
            );
        }
    }
    
    function endsWith2or4(uint256 num) internal pure returns (bool) {
        uint256 lastDigit = num % 10; // Get the last digit of the number
        return lastDigit == 2 || lastDigit == 4; // Check if the last digit is 2 or 4
    }
 
   function isUserActive(address _user)
        public
        view
        returns (bool)
    {
        if (!users[_user].isExist) {
            return false;
        }

        return true;
    }
    
    function findFreeReferrer(address _user) public view returns (address) {
        if (users[_user].referral.length <2)  {
            return _user;
        }

        address[] memory referrals = new address[](126);
        referrals[0] = users[_user].referral[0];
        referrals[1] = users[_user].referral[1];

        address freeReferrer;
        bool noFreeReferrer = true;

        for (uint256 i = 0; i < 126; i++) {
            // if (
            //   // users[referrals[i]].referral.length == REFERRER_EACH_LEVEL_LIMIT
            // ) 
            
                if (i < 62) {
                    referrals[(i + 1) * 2] = users[referrals[i]].referral[0];
                    referrals[(i + 1) * 2 + 1] = users[referrals[i]].referral[
                        1
                    ];
                }
        
         else {
                noFreeReferrer = false;
                freeReferrer = referrals[i];
                break;
          }
       }

        require(!noFreeReferrer, "No Free Referrer");

        return freeReferrer;
    }
    
    function findActiveReferrer(
        uint256 referrerId,
        bool upgrading
    ) internal returns (uint256) {
        require(
            referrerId > 0 && referrerId <= currUserID,
            "Incorrect referrerId"
        );

        if (referrerId == 1) {
            return 1;
        }


        uint256 activeSponsor = 1;

        uint256 tempreferrerId = referrerId;
        bool checkSpon_Spons = false;

        for (uint256 i = 0; i < 40; i++) {
            if (isUserActive(userList[tempreferrerId])) {
                if (
                    (payments[userList[tempreferrerId]].length >=
                        INCOME_LIMIT &&
                        tsUsers[userList[tempreferrerId]].directReferralCount <
                        3) ||
                    (payments[userList[tempreferrerId]].length >=
                        SECOND_INCOME_LIMIT &&
                        tsUsers[userList[tempreferrerId]].directReferralCount < 5)
                ) {
                    // lostProfit[userList[tempreferrerId]].push(
                    //     lostProfitStruct(
                    //         users[msg.sender].id,
                    //         TS_LEVEL_PRICE[_level]
                    //     )
                    // );
                    tempreferrerId = users[userList[tempreferrerId]].referrerID;
                } else if (
                    upgrading == false &&
                    tempreferrerId != 1 &&
                    endsWith2or4(
                        tsUsers[userList[tempreferrerId]].indirectReferralCount +
                            tsUsers[userList[tempreferrerId]]
                                .directReferralCount +
                            1
                    ) ==
                    true
                ) {
                    if (checkSpon_Spons == true) {
                        tsUsers[userList[tempreferrerId]]
                            .indirectReferralCount += 1;
                        tempreferrerId = users[userList[tempreferrerId]]
                            .referrerID;
                    } else {
                        tempreferrerId = users[userList[tempreferrerId]]
                            .referrerID;
                        checkSpon_Spons = true;
                    }
                } else {
                    activeSponsor = tempreferrerId;
                    break;
                }
            } else {
                tempreferrerId = users[userList[tempreferrerId]].referrerID;
            }
        }

        return activeSponsor;
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
    
    // Withdraw Promotion Value index 0-3 : promotion wallets, 4 : SplPromotionWallet, 5: URS Wallet
    function withdrawPromotion() public returns (bool) {
        bool checkCaller = false;
        uint amount;
        if(msg.sender == splPromoWallet) {
            amount = splPromAmt;
            splPromAmt = 0;
            checkCaller = true;
        } else if(msg.sender == ursWallet) {
            amount = (ursAmt*20)/100;
            ursAmt -= amount;
            checkCaller = true;
        }  else {
            uint callerIndex = 0;
            for (uint i = 0; i < promotionWallets.length; i++) {
                if (promotionWallets[i] == msg.sender) {
                    checkCaller = true;
                    callerIndex = i;
                    break;
                }
            } 
            
            amount = promotionWalletsAmount[callerIndex];
            promotionWalletsAmount[callerIndex] -= amount;
            promAmt = promAmt - amount;
        }
        require(checkCaller == true, "Invalid caller");
        bool sent = false;
        sent = address(uint160(msg.sender)).send(amount);
        return sent;
    }
    
    
     // Withdraw Promotion Value index 0-3 : promotion wallets, 4 : SplPromotionWallet, 5: URS Wallet
    function checkWithdrawAmount() public view returns (uint) {
        bool checkCaller = false;
        uint amount;
        if(msg.sender == splPromoWallet) {
            amount = splPromAmt;
            checkCaller = true;
        } else if(msg.sender == ursWallet) {
            amount = ursAmt;
            checkCaller = true;
        }  else {
            uint callerIndex = 0;
            for (uint i = 0; i < promotionWallets.length; i++) {
                if (promotionWallets[i] == msg.sender) {
                    checkCaller = true;
                    callerIndex = i;
                    break;
                }
            } 
            amount = promotionWalletsAmount[callerIndex];
        }
        
        require(checkCaller == true, "Invalid caller");
        return amount/1000000;
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
