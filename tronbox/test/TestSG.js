(async function() {
  try {
    const metadata = JSON.parse(await remix.call('fileManager', 'getFile', './tronbox/contracts/artifacts/SmartGenie.json'))
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
    
    // await token.connect(signers[1]).mint(signers[0].address, 1001);
    // await contract.regUser(1, {from: ", value : 50}); 
    // regUserId = await instance.currUserID();
    // await regUserId.wait();

  } catch (e) {
    console.log(e.message)
  }
})();
