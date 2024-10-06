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
    
}