const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Testing Liquidity Adding", function () {
  it("Should deploy", async function () {
    provider = ethers.provider;
    [owner, idoAdmin, lpTokenReceiver] = await hre.ethers.getSigners();

    const Token = await ethers.getContractFactory("MyToken");
    token = await Token.deploy();
    await token.deployed();

    const IDO = await ethers.getContractFactory("MCFido");
    ido = await IDO.deploy(
      token.address,
      "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D",
      idoAdmin.address,
      lpTokenReceiver.address,
      "0",
      "0",
      "0",
      "0",
      "0"
    );
    await ido.deployed();
  });

  it("Sending Token and ETH to contract", async function () {
    await owner.sendTransaction({
      to: ido.address,
      value: ethers.utils.parseEther("1.0"), // Sends exactly 1.0 ether
    });

    await token.transfer(ido.address, ethers.utils.parseEther("1.0"));
    expect(await token.balanceOf(ido.address)).to.equal(
      ethers.utils.parseEther("1.0")
    );
  });

  it("Adding Liquidity", async function () {
    await ido.addLiquidity();
    expect(await token.balanceOf(ido.address)).to.equal("0");
  });
});
