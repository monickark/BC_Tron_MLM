pragma solidity 0.5.12;

contract Tronsport {
    
    struct UserStruct {
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
    }

    struct paymentStruct {
        uint256 payerId;
        uint256 amount;
    }
    
    address public ownerWallet;
    uint256 INCOME_LIMIT = 20;
    uint256 SECOND_INCOME_LIMIT = 100;
    uint256 public currUserID = 0;
    mapping(uint256 => uint256) public LEVEL_PRICE;
    mapping(address => UserStruct) public users;
    mapping(uint256 => address) public userList;
    mapping(address => mapping(uint256 => paymentStruct[]))public payments;

    event regLevelEvent(
        address indexed _user,
        address _referrer,
        uint256 _time
    );
    event buyLevelEvent(address indexed _user, uint256 _level, uint256 _time);

    constructor() public {
        ownerWallet = msg.sender;

        LEVEL_PRICE[1] = 200 trx;
        LEVEL_PRICE[2] = 1000 trx;
        LEVEL_PRICE[3] = 5000 trx;

        UserStruct memory userStruct;
        currUserID++;

        userStruct = UserStruct({
            earning: 0,
            isExist: true,
            id: currUserID,
            referrerID: 0,
            referral: new address[](0),
            indirectReferral: new address[](0),
            indirectReferralCount: 0,
            indirectReferralLength: 0,
            directReferralCount: 0
        });

        users[ownerWallet] = userStruct;
        userList[currUserID] = ownerWallet;

    }
	
   function regUser(uint256 _referrerID) public payable {
        require(!users[msg.sender].isExist, "User exist");
        require(
            _referrerID > 0 && _referrerID <= currUserID,
            "Incorrect referrer Id"
        );
        require(msg.value == LEVEL_PRICE[1], "Incorrect Value");

        uint256 activeReferrerId = findActiveReferrer(_referrerID, false);
        uint256 referalCount = users[userList[_referrerID]]
            .directReferralCount +
            users[userList[_referrerID]].indirectReferralCount;

        if (
            activeReferrerId == _referrerID ||
            (isUserActive(userList[_referrerID]) &&
                endsWith2or4(referalCount + 1) == true)
        ) {
            users[userList[_referrerID]].directReferralCount += 1;
        } else if (
            isUserActive(userList[_referrerID]) &&
            ((payments[userList[_referrerID]][1].length >= INCOME_LIMIT &&
                users[userList[_referrerID]].directReferralCount < 3) ||
                (payments[userList[_referrerID]][1].length >=
                    SECOND_INCOME_LIMIT &&
                    users[userList[_referrerID]].directReferralCount < 5))
        ) {
            users[userList[_referrerID]].directReferralCount += 1;
        }

        currUserID++;
        users[msg.sender] = UserStruct({
            earning: 0,
            isExist: true,
            id: currUserID,
            referrerID: activeReferrerId,
            referral: new address[](0),
            indirectReferral: new address[](0),
            directReferralCount: 0,
            indirectReferralCount: 0,
            indirectReferralLength: 0
        });
        userList[currUserID] = msg.sender;

        if (activeReferrerId == _referrerID) {
            users[userList[activeReferrerId]].referral.push(msg.sender);
            users[userList[activeReferrerId]].referralMap[msg.sender] = users[
                userList[activeReferrerId]
            ].referral.length;
        } else {
            if (activeReferrerId == 0) {
                activeReferrerId = 1;
            }

            users[userList[activeReferrerId]].indirectReferral.push(msg.sender);
            users[userList[activeReferrerId]].indirectReferralLength += 1;
            users[userList[activeReferrerId]].indirectReferralCount += 1;

            users[userList[activeReferrerId]].indirectReferralMap[
                msg.sender
            ] = users[userList[activeReferrerId]].indirectReferralLength;

        }
        
        users[userList[activeReferrerId]].earning += LEVEL_PRICE[1];
                payments[userList[activeReferrerId]][1].push(
                    paymentStruct({
                        payerId: users[msg.sender].id,
                        amount: LEVEL_PRICE[1]
                    })
                );
        
        uint256 level1IncomeCount = payments[userList[activeReferrerId]][1].length;
        if (level1IncomeCount >= 11 && level1IncomeCount <= 14) {
        
        } else if (level1IncomeCount == 15) {
            buyLevel(2);
        } else {
            address(uint160(userList[activeReferrerId])).transfer(LEVEL_PRICE[1]);
        }

        emit regLevelEvent(msg.sender, userList[activeReferrerId], now);
    }

    // BUYING LEVEL FUNCTION
    function buyLevel(uint256 _level) internal {
        
        uint256 _referrerID = users[msg.sender].referrerID;
        if (_referrerID == 0) {
            _referrerID = 1;
        }

        uint256 activeReferrerId = findActiveReferrer(
            _referrerID,
            true
        );
            if (_level == 2) {
                require(users[userList[_referrerID]].directReferralCount >=
                        3,
                    "Upgrade can be done only after minimum direct referal should be 3"
                );
            } 


        if (activeReferrerId != _referrerID) {

            uint256 index = users[userList[_referrerID]].referralMap[
                msg.sender
            ];

            if (index != 0) {
                index -= 1;
                uint256 length = users[userList[_referrerID]].referral.length;
                address lastEle = users[userList[_referrerID]].referral[
                    length - 1
                ];
                users[userList[_referrerID]].referral[index] = lastEle;
                users[userList[_referrerID]].referral.pop();

                delete users[userList[_referrerID]].referralMap[msg.sender];
                if (users[userList[_referrerID]].referral.length != 0) {
                    users[userList[_referrerID]].referralMap[lastEle] =
                        index +
                        1;
                }
            } else {

                index = users[userList[_referrerID]].indirectReferralMap[
                    msg.sender
                ];
                if (index != 0) {
                    index -= 1;
                    uint256 length = users[userList[_referrerID]]
                        .indirectReferralLength;

                    address lastEle = users[userList[_referrerID]]
                        .indirectReferral[length - 1];
                    users[userList[_referrerID]].indirectReferral[
                        index
                    ] = lastEle;
                    users[userList[_referrerID]].indirectReferral.pop();
                    users[userList[_referrerID]].indirectReferralLength -= 1;
                    users[userList[_referrerID]].indirectReferralCount -= 1;

                    delete users[userList[_referrerID]].indirectReferralMap[
                        msg.sender
                    ];
                    if (
                        users[userList[_referrerID]].indirectReferralLength != 0
                    ) {
                        users[userList[_referrerID]].indirectReferralMap[
                            lastEle
                        ] = index + 1;
                    }
                }
            }

            users[msg.sender].referrerID = activeReferrerId;
            users[userList[activeReferrerId]].indirectReferral.push(msg.sender);
            users[userList[activeReferrerId]].indirectReferralLength += 1;
            users[userList[activeReferrerId]].indirectReferralCount += 1;
        }
        
         users[userList[activeReferrerId]].earning += LEVEL_PRICE[_level];
                payments[userList[activeReferrerId]][_level].push(
                    paymentStruct({
                        payerId: users[msg.sender].id,
                        amount: LEVEL_PRICE[_level]
                    })
                );
        
        address(uint160(userList[activeReferrerId])).transfer(LEVEL_PRICE[_level]);

        emit buyLevelEvent(msg.sender, _level, now);
    }

    function findFreeReferrer(address _user) public view returns (address) {
        if (users[_user].referral.length <2)  {
            return _user;
        }

        address[] memory referrals = new address[](16);
        referrals[0] = users[_user].referral[0];
        referrals[1] = users[_user].referral[1];

        address freeReferrer;
        bool noFreeReferrer = true;

        for (uint256 i = 0; i < 16; i++) {
            // if (
            //   // users[referrals[i]].referral.length == REFERRER_EACH_LEVEL_LIMIT
            // ) 
            
               if (i < 8) {
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
                    (payments[userList[tempreferrerId]][1].length >=
                        INCOME_LIMIT &&
                        users[userList[tempreferrerId]].directReferralCount <
                        3) ||
                    (payments[userList[tempreferrerId]][1].length >=
                        SECOND_INCOME_LIMIT &&
                        users[userList[tempreferrerId]].directReferralCount < 5)
                ) {
                    tempreferrerId = users[userList[tempreferrerId]].referrerID;
                } else if (
                    upgrading == false &&
                    tempreferrerId != 1 &&
                    endsWith2or4(
                        users[userList[tempreferrerId]].indirectReferralCount +
                            users[userList[tempreferrerId]]
                                .directReferralCount +
                            1
                    ) ==
                    true
                ) {
                    if (checkSpon_Spons == true) {
                        users[userList[tempreferrerId]]
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


    function isUserActive(address _user)
        public
        view
        returns (bool)
    {
        if (!users[_user].isExist) {
            return false;
        }

        // if (users[_user].levelExpired[_level] == 0) {
        //     return false;
        // }

        // if (users[_user].levelExpired[_level] < now) {
        //     return false;
        // }

        return true;
    }


    function viewUserReferral(address _user)
        public
        view
        returns (address[] memory)
    {
        return users[_user].referral;
    }


    function viewUserIndirectReferral(address _user, uint256 index)
        public
        view
        returns (address)
    {
        return users[_user].indirectReferral[index];
    }


    // function viewUserLevelExpired(address _user, uint256 _level)
    //     public
    //     view
    //     returns (uint256)
    // {
    //     return users[_user].levelExpired[_level];
    // }


    function getUserCurrentLevel(address _user) public view returns (uint256) {
        uint256 level = 0;

        if (!users[_user].isExist) {
            return level;
        }

        // for (uint256 l = 3; l > 0; l--) {
        //     // if (
        //     //     users[_user].levelExpired[l] != 0 &&
        //     //     users[_user].levelExpired[l] >= now
        //     // ) 
        //     {
        //         level = l;
        //         break;
        //     }
        // }

        return level;
    }


    // function getUserLevelsData(address _user)
    //     public
    //     view
    //     returns (
    //         uint256,
    //         uint256,
    //         uint256,
    //         bool,
    //         bool,
    //         bool
    //     )
    // {
    //     uint256 level1 = users[_user].levelExpired[1];
    //     uint256 level2 = users[_user].levelExpired[2];
    //     uint256 level3 = users[_user].levelExpired[3];
    //     uint256 joinedTime = users[_user].joined;
    //     uint256 level2purchaseTime = users[_user].level2PurchaseDate;
    //     uint256 directCount = users[_user].directReferralCount;

    //     bool canActivate2 = (now - joinedTime) > 61 days &&
    //         directCount >= 5 &&
    //         now < level1;
    //     bool canActivate3 = (now - level2purchaseTime) >
    //         61 days &&
    //         directCount >= 10 &&
    //         now < level1 &&
    //         now < level2;
    //     bool canExtend3 = now < level1 && now < level2;

    //     return (level1, level2, level3, canActivate2, canActivate3, canExtend3);
    // }

    // function lostProfitSize(address _user) public view returns (uint256) {
    //     return lostProfit[_user].length;
    // }

    function paymentsLength(address _user, uint256 _level) public view returns (uint256) {
        return payments[_user][_level].length;
    }

    function bytesToAddress(bytes memory bys)
        private
        pure
        returns (address addr)
    {
        assembly {
            addr := mload(add(bys, 20))
        }
    }

    function endsWith2or4(uint256 num) internal pure returns (bool) {
        uint256 lastDigit = num % 10; // Get the last digit of the number
        return lastDigit == 2 || lastDigit == 4; // Check if the last digit is 2 or 4
    }
}