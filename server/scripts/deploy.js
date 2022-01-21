// DEPLOYMENT SCRIPT

const main = async () => {

  // get contract, deploy it, and wait for deployment to finish
  nftContractFactory = await hre.ethers.getContractFactory('MyNFT');
  nftContract = await nftContractFactory.deploy();
  await nftContract.deployed();
  console.log('Contract deployed to:', nftContract.address);

  // call function from contract which mints an NFT
  let txn = await nftContract.makeAnNFT();
  // wait for transaction to be mined
  await txn.wait();
  console.log('minted NFT #1');

  // mint another NFT
  txn = await nftContract.makeAnNFT();
  await txn.wait();
  console.log('minted NFT #2');
};


const runMain = async () => {
  try {
    await main();
    process.exit(0);
  } catch (error) {
    console.log(process.exit(1));
    process.exit(0);
  }
}

runMain();