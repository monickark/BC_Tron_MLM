(async function() {
  try {
    const metadata = JSON.parse(await remix.call('fileManager', 'getFile', 'contracts/artifacts/SmartGenie.json'))
    // the variable web3Provider is a remix global variable object
    const signer = (new ethers.providers.Web3Provider(web3Provider)).getSigner()
    // Create an instance of a Contract Factory
    let factory = new ethers.ContractFactory(metadata.abi, metadata.data.bytecode.object, signer);
    // Notice we pass the constructor's parameters here
    let contract = await factory.deploy('0xdD870fA1b7C4700F2BD7f44238821C26f7392148', 
      '0xdD870fA1b7C4700F2BD7f44238821C26f7392148', "0xdD870fA1b7C4700F2BD7f44238821C26f7392148",
      "0xdD870fA1b7C4700F2BD7f44238821C26f7392148", "0xdD870fA1b7C4700F2BD7f44238821C26f7392148",
      "0xdD870fA1b7C4700F2BD7f44238821C26f7392148", "0xdD870fA1b7C4700F2BD7f44238821C26f7392148");
    // The address the Contract WILL have once mined
    console.log(contract.address);
    // The transaction that was sent to the network to deploy the Contract
    console.log(contract.deployTransaction.hash);
    // The contract is NOT deployed yet; we must wait until it is mined
    await contract.deployed()
    // Done! The contract is deployed.
    console.log('contract deployed')
    console.log(contract.getContractBalance());
  } catch (e) {
    console.log(e.message)
  }
})();

const regUser = async function (contract, referrerId, user, regFee) {
console.log("\n*************************************************************************************");
console.log("Registering new user.....");
var instance, regUserId;
console.log("referrerId : "+ referrerId +  " user : " + user +" regFee : " + regFee);

return SmartGenie.deployed().then(async function(sm_instance) {
  instance = sm_instance;
  console.log("Instance: " + await instance.address);
  await instance.regUser(referrerId, {from: user, value : regFee}); 
  regUserId = await instance.currUserID();
  await regUserId.wait();
  return [regUserId, user];
}).then(async function(retValues) {    
  const userDetails = await getUserDetails(retValues[1])
  userDetails.wait();
  console.log("Registered User Id : " + userDetails[0]);
  console.log("Registered User Details : " + userDetails[1]);
})
}
