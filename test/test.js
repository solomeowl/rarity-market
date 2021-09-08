const { ethers, upgrades, network } = require("hardhat");
const { expect } = require("chai");

let basscubeToken, vesting, accounts, deployer

describe('#InitSharing', () => {

    it('deploy contracts and set variables', async () => {

        accounts = await hre.ethers.getSigners();
        deployer = accounts[0];

        console.log(deployer.address);
    })
})
