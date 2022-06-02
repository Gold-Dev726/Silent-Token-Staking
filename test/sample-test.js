const { expect } = require("chai");
const { ethers } = require("hardhat");
const { BN, expectEvent, expectRevert } = require("@openzeppelin/test-helpers");

let tokenContract;
let stakingContract;

describe("Staking Test", function () {
    let tokenContract;
    let stakingContract;
    let owner;
    before(async function () {
        const SimpleTokenFactory = await ethers.getContractFactory("SimpleToken");
        const SlientStakingFactory = await ethers.getContractFactory("SilentStaking");

        tokenContract = await SimpleTokenFactory.deploy();
        await tokenContract.deployed();

        stakingContract = await SlientStakingFactory.deploy(tokenContract.address, 10);
        await stakingContract.deployed();

        [owner, addr1, addr2] = await ethers.getSigners();
    });

    it("Should return token balance of owner", async function () {
        expect(await tokenContract.balanceOf(owner.address)).to.equal("200000000000000000000000");
    });

    it("Should return token address to be staken", async function () {
        expect(await stakingContract.erc20()).to.equal(tokenContract.address);
    });

    it("Should return daily rewards", async function () {
        expect(await stakingContract.dailyRewards()).to.equal(10);
    });

    it("staking should work with tier", async function () {
        await tokenContract.approve(stakingContract.address, "20000000000000000000000");
        await stakingContract.stake(1);
        expect(await tokenContract.balanceOf(stakingContract.address)).to.equal("500000000000000000000");
    });

    it("tier must be bigger than 0", async function () {
        await expect(await stakingContract.stake(0)).to.be.revertedWith("Invalid tier");
    });
});
