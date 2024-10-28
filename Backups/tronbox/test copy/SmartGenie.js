const SmartGenie = artifacts.require("SmartGenie");


contract("SmartGenie", (accounts) => {
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

  it("While deploy 1st user has created", async () => {
    const smartGenieInstance = await SmartGenie.deployed();
    const currUserID = await smartGenieInstance.currUserID();
    console.log("currUserID : " + currUserID);
    console.log("owner balance : " + await tronWeb.trx.getBalance(owner_1)/1000000);
    assert.equal(currUserID, 1, "No user has created while deployment");
  });

  it("1st user of level 2 is joining using contract owner is as referrer", async () => {
    const smartGenieInstance = await SmartGenie.deployed();
    const referrerB4Bal = await tronWeb.trx.getBalance(owner_1)/1000000;
    const payerB4Bal = await tronWeb.trx.getBalance(user_2_1)/1000000;
    const [add, status, , ] = await smartGenieInstance.regUser(1, {from : user_2_1, value: 150});
    console.log("txion status : " + status);
    const referrerAfterBal = await tronWeb.trx.getBalance(owner_1)/1000000;
    const payerAfter4Bal = await tronWeb.trx.getBalance(user_2_1)/1000000;
    console.log("referrerB4Bal : " + referrerB4Bal + " referrerAfterBal : " + referrerAfterBal);
    console.log("payerB4Bal : " + payerB4Bal + " payerAfter4Bal : " + payerAfter4Bal);

    const currUserID = await smartGenieInstance.currUserID();
    console.log("currUserID : " + currUserID);

    assert.equal(referrerAfterBal - referrerB4Bal, 150, "Reg fee transferred to referrer");
  });

});
