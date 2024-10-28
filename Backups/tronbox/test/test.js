const SmartGenie = artifacts.require("SmartGenie");


contract("SmartGenie", (accounts) => {
  var owner_1 = accounts[0];
  var user_2_1 = accounts[1];

  it("While deploy 1st user has created", async () => {
    const referrerB4Bal = await tronWeb.trx.getBalance(owner_1)/1000000;
    const user_2_1B4Bal = await tronWeb.trx.getBalance(user_2_1)/1000000;
    console.log("referrerB4Bal : " + referrerB4Bal + " referrerAfterBal : " + user_2_1B4Bal);
    const txion = await tronWeb.trx.sendTransaction(user_2_1, 10000000);
    console.log("txion details : " + JSON.stringify(txion));

    const referreraftrrBal1 = await tronWeb.trx.getBalance(owner_1)/1000000;
    const user_2_1afterBal1 = await tronWeb.trx.getBalance(user_2_1)/1000000;
    console.log("referrerB4Bal : " + referreraftrrBal1 + " referrerAfterBal1 : " + user_2_1afterBal1);
  });
});
