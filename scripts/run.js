const { utils } = require("ethers");

async function main() {
  const baseTokenURI =
    "https://mmk.mypinata.cloud/ipfs/Qmdvtj2cM5JXGFp88sALnQ3d4Lsf2uwetMwrJoQt8UF7sz/";
  // const baseTokenURI = "ipfs://QmaqFaMfSj7kVrFpeaztYRksz6j4fKcvicwHLhhKxqVZmy/";

  // Get owner/deployer's wallet address
  const [owner] = await hre.ethers.getSigners();

  // Get contract that we want to deploy
  const contractFactory = await hre.ethers.getContractFactory("MaskedMicKillers");

  // Deploy contract with the correct constructor arguments
  const contract = await contractFactory.deploy(baseTokenURI);

  // Wait for this transaction to be mined
  await contract.deployed();

  // Get contract address
  console.log("Contract deployed to:", contract.address);

  // Reserve NFTs
  // txn = await contract.setIsAllow(true);
  // await txn.wait();
  // console.log("Allow is setted successfully");

  // // Mint 3 NFTs by sending 0.03 ether
  // txn = await contract.mintNFTs(1, { value: utils.parseEther("0.025") });
  // await txn.wait();

  // Get all token IDs of the owner
  // let tokens = await contract.tokensOfOwner(owner.address);
  // console.log("Owner has tokens: ", tokens);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
