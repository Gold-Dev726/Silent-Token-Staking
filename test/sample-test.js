const { expect } = require("chai");
const { ethers } = require("hardhat");
const { BN, expectEvent, expectRevert } = require("@openzeppelin/test-helpers");

const SimpleToken = artifacts.require('SimpleToken');
let tokenContract;
let stakingContract;

describe("Greeter", function () {
    let tokenContract;
    before(async function () {
        const SimpleTokenFactory = await ethers.getContractFactory("SimpleToken");
        const SlientStakingFactory = await ethers.getContractFactory("SilentStaking");
        tokenContract = await SimpleTokenFactory.deploy();
        await tokenContract.deployed();
    });

    it("Should return token balance of owner", async function () {
        const [owner, addr1] = await ethers.getSigners();
        expect(await tokenContract.balanceOf(owner.address)).to.equal("200000000000000000000000");
    });
});
