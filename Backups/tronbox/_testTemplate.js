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
const regUser = async function (referrerId, user, regFee, accounts) {
  console.log("\n*************************************************************************************");
  console.log("Registering new user.....");
  var instance, regUserId, userDetails;
  console.log("referrerId : "+ referrerId +  " user : " + user +" regFee : " + regFee);

  return await SmartGenie.deployed().then(async function(sm_instance) {
    instance = sm_instance;
    console.log("Instance: " + await instance.address);
    await instance.regUser(referrerId, {from: user, value : regFee}); 
    regUserId = await instance.currUserID();;
    return [regUserId, user];
  }).then(async function(retValues) {    
    userDetails = await getUserDetails(retValues[1])
    console.log("Registered User Id : " + retValues[0]);
    console.log("Registered User Details : " + retValues[1]);
  }).then(async function() {    
    await getAccountBalances(accounts);
  })
}

/**
 * ACCOUNTS LEVEL
 * LEVEL1 : CONTRACT OWNER (owner_1)
 * LEVEL2 : user_2_1
 * LEVEL3 : user_3_2_1, user_3_2_2, user_3_2_3, user_3_2_4
 * LEVEL3 : user_4_3_1, user_4_3_2, user_4_3_3, user_4_3_4
 */

contract("SmartGenie", async function(accounts) {
  var owner_1 = accounts[0];
  var user_2_1 = accounts[1];
  var user_3_2_1 = accounts[2];  
  var user_3_2_2 = accounts[3];
  var user_3_2_3 = accounts[4];  
  var user_3_2_4 = accounts[5];
  var user_4_3_1 = accounts[6];  
  var user_4_3_2 = accounts[7];
  var user_4_3_3 = accounts[8];  
  var user_4_3_4 = accounts[9];
  var regFee = 150;
  it("Register Level2 user", async function() {
    await getAccountBalances(accounts);
    await regUser(1, user_2_1, regFee, accounts); 
    await regUser(2, user_3_2_1, regFee, accounts); 
    await regUser(2, user_3_2_2, regFee, accounts); 
    await regUser(2, user_3_2_3, regFee, accounts); 
    await regUser(2, user_3_2_4, regFee, accounts); 
    await regUser(3, user_4_3_1, regFee, accounts); 
    await regUser(4, user_4_3_2, regFee, accounts); 
    await regUser(4, user_4_3_3, regFee, accounts); 
    await regUser(4, user_4_3_4, regFee, accounts); 
  });
});

/**
 *  GET ALL ACCOUNTS BALANCE
 */
const getAccountBalances = async function (accounts) {
  console.log("\n---------- Display Account Balance  ----------");
  await getSmartContractBalance();
  console.log("Owner con  account : " +  accounts[0] + " Balance : " + await tronWeb.trx.getBalance(accounts[0])/1000000 + " trx");
  console.log("user_2_1_1 account : " +  accounts[1] + " Balance : " + await tronWeb.trx.getBalance(accounts[1])/1000000 + " trx");
  console.log("user_3_2_1 account : " +  accounts[2] + " Balance : " + await tronWeb.trx.getBalance(accounts[2])/1000000 + " trx");
  console.log("user_3_2_2 account : " +  accounts[3] + " Balance : " + await tronWeb.trx.getBalance(accounts[3])/1000000 + " trx");
  console.log("user_3_2_3 account : " +  accounts[4] + " Balance : " + await tronWeb.trx.getBalance(accounts[4])/1000000 + " trx");
  console.log("user_3_2_4 account : " +  accounts[5] + " Balance : " + await tronWeb.trx.getBalance(accounts[5])/1000000 + " trx");
  console.log("user_4_3_1 account : " +  accounts[6] + " Balance : " + await tronWeb.trx.getBalance(accounts[6])/1000000 + " trx");
  console.log("user_4_3_2 account : " +  accounts[7] + " Balance : " + await tronWeb.trx.getBalance(accounts[7])/1000000 + " trx");
  console.log("user_4_3_3 account : " +  accounts[8] + " Balance : " + await tronWeb.trx.getBalance(accounts[8])/1000000 + " trx");
  console.log("user_4_3_4 account : " +  accounts[9] + " Balance : " + await tronWeb.trx.getBalance(accounts[9])/1000000 + " trx");
}
