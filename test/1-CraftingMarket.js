const { ethers, upgrades } = require("hardhat");

let accounts, deployer

describe('#InitMarket', () => {

    it('deploy contracts and set variables', async () => {

        accounts = await hre.ethers.getSigners();
        deployer = accounts[0];

        const MarketFact = await ethers.getContractFactory("RarityCraftingMarket");
        const Market = await upgrades.deployProxy(MarketFact, ["0xce761D788DF608BD21bdd59d6f4B54b2e27F25Bb", 1, 5])
        await Market.deployed();
        console.log("RarityCraftingMarket deployed to:", Market.address);
    })
})