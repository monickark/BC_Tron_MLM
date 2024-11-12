var SmartGenie = artifacts.require("./SmartGenie.sol");

/**
 * 
 * GETTING PUBLIC PARAMS
 */
const getUserDetails = function (address) {
  console.log("   Retrieving user details for address : " + address);
  return SmartGenie.deployed().then(async function(sm_instance) {
      var userDetails = await sm_instance.users(address);
        return userDetails;
      }).then(async function(retValues) {    
        console.log("   User Details : " + retValues);
      })
}

const getRegFee = function () {
  console.log("\n---------- Display Reg Fee  ----------");
  return SmartGenie.deployed().then(async function(sm_instance) {
      return await sm_instance.regFee();
      }).then(async function(retValues) {    
        console.log("Reg Fee : " + retValues);
      })
}

/**
 * CALLING VIEW FUNCTIONS
 */
const getSmartContractBalance = async function () {
  return await SmartGenie.deployed().then(async function(sm_instance) {
    console.log("contract address: " + await sm_instance.address);
      return await sm_instance.getContractBalance();
      }).then(async function(retValues) {    
        console.log("Smart Contract Balance : " + await retValues/1000000 + " trx"); 
      })
}


/**
 * CALLING CONTRACT FUNCTIONS
 */
const regUser = async function (referrerId, user, regFee) {
  console.log("\n*************************************************************************************");
  console.log("Registering new user.....");
  var instance, regUserId;
  console.log("referrerId : "+ referrerId +  " user : " + user +" regFee : " + regFee);

  return SmartGenie.deployed().then(async function(sm_instance) {
    instance = sm_instance;
    console.log("Instance: " + await instance.address);
    await instance.regUser(referrerId, {from: user, value : regFee}); 
    regUserId = await instance.currUserID();;
    return [regUserId, user];
  }).then(async function(retValues) {    
    userDetails = await getUserDetails(retValues[1])
    console.log("Registered User Id : " + retValues[0]);
    console.log("Registered User Details : " + retValues[1]);
  })
}

/**
 * ACCOUNTS LEVEL
 * LEVEL1 : CONTRACT OWNER (user_2)
 * LEVEL2 : user_2
 * LEVEL3 : user_3, user_4, user_5, user_6
 * LEVEL3 : user_7, user_8, user_9, user_10
 */

contract("SmartGenie", async function(accounts) {
  var user_1 = accounts[0];
  var user_2 = accounts[1];
  var user_3 = accounts[2];  
  var user_4 = accounts[3];
  var user_5 = accounts[4];  
  var user_6 = accounts[5];
  var user_7 = accounts[6];  
  var user_8 = accounts[7];
  var user_9 = accounts[8];  
  var user_10 = accounts[9];
  var regFee = 500000000;
  it("Register Level2 user", async function() {
    await getAccountBalances(accounts);
    await regUser(1, user_2, regFee, accounts); 
    await regUser(2, user_3, regFee, accounts); 
    await regUser(3, user_4, regFee, accounts); 
    await regUser(4, user_5, regFee, accounts); 
    await regUser(5, user_6, regFee, accounts); 
    await regUser(6, user_7, regFee, accounts); 
    await regUser(7, user_8, regFee, accounts); 
    await regUser(2, user_9, regFee, accounts); 
    await regUser(2, user_10, regFee, accounts); 
    setTimeout(getAccountBalances, 50000, accounts);
  });
});

/**
 *  GET ALL ACCOUNTS BALANCE
 */
const getAccountBalances = async function (accounts) {
  console.log("\n---------- Display Account Balance  ----------");
  // await getSmartContractBalance();
  console.log("user_1 account : " +  accounts[0] + " Balance : " + await tronWeb.trx.getBalance(accounts[0])/1000000 + " trx");
  console.log("user_2 account : " +  accounts[1] + " Balance : " + await tronWeb.trx.getBalance(accounts[1])/1000000 + " trx");
  console.log("user_3 account : " +  accounts[2] + " Balance : " + await tronWeb.trx.getBalance(accounts[2])/1000000 + " trx");
  console.log("user_4 account : " +  accounts[3] + " Balance : " + await tronWeb.trx.getBalance(accounts[3])/1000000 + " trx");
  console.log("user_5 account : " +  accounts[4] + " Balance : " + await tronWeb.trx.getBalance(accounts[4])/1000000 + " trx");
  console.log("user_6 account : " +  accounts[5] + " Balance : " + await tronWeb.trx.getBalance(accounts[5])/1000000 + " trx");
  console.log("user_7 account : " +  accounts[6] + " Balance : " + await tronWeb.trx.getBalance(accounts[6])/1000000 + " trx");
  console.log("user_8 account : " +  accounts[7] + " Balance : " + await tronWeb.trx.getBalance(accounts[7])/1000000 + " trx");
  console.log("user_9 account : " +  accounts[8] + " Balance : " + await tronWeb.trx.getBalance(accounts[8])/1000000 + " trx");
  console.log("user_10 account : " +  accounts[9] + " Balance : " + await tronWeb.trx.getBalance(accounts[9])/1000000 + " trx");
}
