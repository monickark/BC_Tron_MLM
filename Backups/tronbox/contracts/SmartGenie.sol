pragma solidity 0.5.12;

contract SmartGenie {
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
        
    }
    
    
    mapping(uint => uint) public LEVEL_PRICE;
    mapping (address => UserStruct) public users;
    mapping (uint => address) public userList;
    
    uint public currUserID = 0;
    uint256 public promAmt = 0;
    uint256 public ursAmt = 0;
    uint256 public regFee = 500 trx;
    
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
    function regUser(uint _referrerID) public payable returns (address, bool, uint256, uint256){
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
            joined:now
        });
        users[msg.sender] = userStruct;
        
        // Add new user to existing userlist
        userList[currUserID] = msg.sender;
        
        // push the caller to referral under referrerid
        users[userList[_referrerID]].referral.push(msg.sender);
        
        // update split wallet balances
        ursAmt += LEVEL_PRICE[1];
        promAmt += LEVEL_PRICE[1];
        address payer_;
        bool sent_;
        uint256 amt_;
        uint256 level_;
        
        //  A particular users joined 2 referalls, for the 2nd referall transfer amount to contract
        uint referrerReferralLength = users[userList[_referrerID]].referral.length;
        if(referrerReferralLength != 2) {
            // Payment for the level
           (payer_, sent_, amt_, level_) =  payForLevel(1, msg.sender);
        } 
         
        // registration done. Emit event
        emit regLevelEvent(msg.sender, userList[_referrerID], now);
        
        return (payer_, sent_, amt_, level_);

    }
    
    
   
    // Payment function for a level
    function payForLevel(uint _level, address _user) internal returns (address, bool, uint256, uint256){
        address payer;
        bool sent = false;
        uint256 level;
        uint256 length = users[userList[users[_user].referrerID]].referral.length;
        if(_level == 1) {
            level = _level;
             // For users referrer level 1 pay reg amount to referrer
             if( length == 1 || length % 4 == 0) {
                 payer = userList[users[_user].referrerID];

             } 
             // For users referrer level 3 pay next level active to second upline
             else if (length == 3) {
               payer = getSecondUpline(userList[users[_user].referrerID]);
               if(payer == address(0)) {
                   payer = getSecondUpline(msg.sender);
               }
               level = _level+1;
             } else {
               payer = users[userList[users[_user].referrerID]];
               if(payer == address(0)) {
                   payer = getSecondUpline(msg.sender);
               }
               level = _level+1;
             }
             }
            
              sent = address(uint160(payer)).send(LEVEL_PRICE[level]);
    
                if (sent) {
                    emit getMoneyForLevelEvent(payer, msg.sender, level, now);
                }
                
                return (payer, sent, LEVEL_PRICE[level], level);
        }
        
    }
    // Transfer Promotion Value
    function transferPromotion(uint256 _amount) public returns (bool) {
        require(msg.sender == promotionWallet, "Invalid caller");
        require(_amount <= promAmt, "Invalid Amount");
         bool sent = false;
           sent = address(uint160(promotionWallet)).send(_amount);
           return sent;
    }
     
      // Transfer URS Value
    function transferURS(uint256 _amount) public returns (bool) {
        require(msg.sender == ursWallet, "Invalid caller");
        require(_amount <= ursAmt, "Invalid Amount");
         bool sent = false;
           sent = address(uint160(ursWallet)).send(_amount);
           return sent;
    }
    
    
    // Get smartcontract balance
    function getContractBalance() public view returns(uint256) {
        return address(this).balance;
    }
    
    // Get referrals list of a user
    function getUserReferral(address _user) public view returns(address[] memory) {
        return users[_user].referral;
    }
    
    // Get referrals length of user
    function getUserReferralLength(address _user) public view returns(uint256) {
        return users[userList[users[_user].referrerID]].referral.length;
    }
    
    // Get referrals length of the users's referrer
    function getUserReferrersReferralLength(address _user) public view returns(uint256) {
        return users[userList[users[_user].referrerID]].referral.length;
    }
    
    // Get ETH Address
    function getETHAddress(address _user) public pure returns(address) {
        return _user;
    }
    
    // Get second upline referrer
    function getSecondUpline(address _user) public view returns(address) {
        address referrer = userList[users[_user].referrerID];
        address payer = userList[users[referrer].referrerID];
        return payer;
    }
    
}