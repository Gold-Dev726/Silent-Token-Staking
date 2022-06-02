const { utils } = require("ethers");

async function main() {
    // Get owner/deployer's wallet address
    const [owner] = await hre.ethers.getSigners();

    // Get contract that we want to deploy
    const SimpleTokenFactory = await hre.ethers.getContractFactory("SimpleToken");
    const SlientStakingFactory = await hre.ethers.getContractFactory("SilentStaking");

    // Deploy contract with the correct constructor arguments
    const tokenContract = await SimpleTokenFactory.deploy();
    await tokenContract.deployed();
    const tokenAddress = tokenContract.address;

    const stakingContract = await SlientStakingFactory.deploy(tokenAddress, 10);
    await stakingContract.deployed();
    // Get contract address
    console.log("Token contract deployed to:", tokenContract.address);
    console.log("Staking contract deployed to:", stakingContract.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
