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
    event activateLevelEvent(address indexed _user, uint _level, uint _time);
    event recycleLevelEvent(address indexed _user, uint _level, uint _time);
    event getMoneyForLevelEvent(address indexed _user, address indexed _referral, uint _level, uint _time);
    event lostMoneyForLevelEvent(address indexed _user, address indexed _referral, uint _level, uint _time);
    
    event holdactLevelEvent(address indexed _user, uint _level, uint _time);
    
    constructor() public {
        ownerWallet = msg.sender;

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

        for(uint i = 1; i <= 10; i++) {
            users[ownerWallet].levelExpired[i] = 55555555555;
        }
    }
    
    
    
    function () external payable {
        uint level;

        if(msg.value == LEVEL_PRICE[1]) level = 1;
        else if(msg.value == LEVEL_PRICE[2]) level = 2;
        else if(msg.value == LEVEL_PRICE[3]) level = 3;
        else if(msg.value == LEVEL_PRICE[4]) level = 4;
        else if(msg.value == LEVEL_PRICE[5]) level = 5;
        else if(msg.value == LEVEL_PRICE[6]) level = 6;
        else if(msg.value == LEVEL_PRICE[7]) level = 7;
        else if(msg.value == LEVEL_PRICE[8]) level = 8;
        else if(msg.value == LEVEL_PRICE[9]) level = 9;
        else if(msg.value == LEVEL_PRICE[10]) level = 10;
        else revert('Incorrect Value send');

        if(users[msg.sender].isExist) buyLevel(level);
        else if(level == 1) {
            uint refId = 0;
            address referrer = bytesToAddress(msg.data);

            if(users[referrer].isExist) refId = users[referrer].id;
            else revert('Incorrect referrer');

            regUser(refId);
        }
        else revert('Please buy first level for 300 TRX');
    }
    
    
    function regUser(uint _referrerID) public payable {
      
        require(!users[msg.sender].isExist, 'User exist');
        require(_referrerID > 0 && _referrerID <= currUserID, 'Incorrect referrer Id');
        require(msg.value == LEVEL_PRICE[1], 'Incorrect Value');


        UserStruct memory userStruct;
        currUserID++;

        userStruct = UserStruct({
            isExist: true,
            id: currUserID,
            referrerID: _referrerID,
            referral: new address[](0),
            joined:now
        });

        users[msg.sender] = userStruct;
        userList[currUserID] = msg.sender;

        users[userList[_referrerID]].referral.push(msg.sender);

        payForLevel(1, msg.sender);

        emit regLevelEvent(msg.sender, userList[_referrerID], now);
    }
    
    
    function buyLevel(uint _level) public payable {
        require(users[msg.sender].isExist, 'User not exist'); 
        require(_level > 0 && _level <= 10, 'Incorrect level');

        if(_level == 1) {
            require(msg.value == LEVEL_PRICE[1], 'Incorrect Value');
      
        }
        else {
            require(msg.value == LEVEL_PRICE[_level], 'Incorrect Value');

            for(uint l =_level - 1; l > 0; l--) require(users[msg.sender].levelExpired[l] >= now, 'Buy the previous level');

        }

        payForLevel(_level, msg.sender);

    }
    
    
    
    
    
    
    
    
    function payForLevel(uint _level, address _user) internal {
        address referer;
        address referer1;
        address referer2;
        address referer3;
        address referer4;

        if(_level == 1 || _level == 6) {
            referer = userList[users[_user].referrerID];
        }
        else if(_level == 2 || _level == 7) {
            referer1 = userList[users[_user].referrerID];
            referer = userList[users[referer1].referrerID];
        }
        else if(_level == 3 || _level == 8) {
            referer1 = userList[users[_user].referrerID];
            referer2 = userList[users[referer1].referrerID];
            referer = userList[users[referer2].referrerID];
        }
        else if(_level == 4 || _level == 9) {
            referer1 = userList[users[_user].referrerID];
            referer2 = userList[users[referer1].referrerID];
            referer3 = userList[users[referer2].referrerID];
            referer = userList[users[referer3].referrerID];
        }
        else if(_level == 5 || _level == 10) {
            referer1 = userList[users[_user].referrerID];
            referer2 = userList[users[referer1].referrerID];
            referer3 = userList[users[referer2].referrerID];
            referer4 = userList[users[referer3].referrerID];
            referer = userList[users[referer4].referrerID];
        }

        if(!users[referer].isExist) referer = userList[1];

        bool sent = false;
        if(users[referer].levelExpired[_level] >= now) {
            sent = address(uint160(referer)).send(LEVEL_PRICE[_level]);

            if (sent) {
                emit getMoneyForLevelEvent(referer, msg.sender, _level, now);
            }
        }
        if(!sent) {
            emit lostMoneyForLevelEvent(referer, msg.sender, _level, now);

            payForLevel(_level, referer);
        }
    }
    
    
    
    function findFreeReferrer(address _user) public view returns(address) {
        
        address[] memory referrals = new address[](126);
        referrals[0] = users[_user].referral[0];
        referrals[1] = users[_user].referral[1];

        
        for(uint i = 0; i < 126; i++) {
                    if(i < 62) {
                    referrals[(i+1)*2] = users[referrals[i]].referral[0];
                    referrals[(i+1)*2+1] = users[referrals[i]].referral[1];
                }
            }

        }




    function viewUserReferral(address _user) public view returns(address[] memory) {
        return users[_user].referral;
    }

    function viewUserLevelExpired(address _user, uint _level) public view returns(uint) {
        return users[_user].levelExpired[_level];
    }

    function bytesToAddress(bytes memory bys) private pure returns (address addr) {
        assembly {
            addr := mload(add(bys, 20))
        }
    }
    
    

    
    }