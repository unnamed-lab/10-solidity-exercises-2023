const { expect } = require("chai");
const hre = require("hardhat");

describe("Basic Messaging Contract", () => {
    let basicContract;
    let owner;
    let msgContract;

    beforeEach(async function() {
        basicContract = await ethers.getContractFactory("BasicMessage");
        owner = hre.ethers.getSigner();
        msgContract = await basicContract.deploy();
    });

    describe("Deployment", () => {
      it("View Message From Smart Contract", async function () {
        expect(await msgContract.viewMessage());
      });
      it("Send Message To Smart Contract", async () => {
          expect(await msgContract.sendMessage("Hello World!"));
      });
    });
});

describe("Advanced Messaging Contract", () => {
    let advancedContract;
    let owner;
    let msgContract;

    beforeEach(async function() {
        advancedContract = await ethers.getContractFactory("AdvancedMessage");
        owner = (await hre.ethers.getSigner()).address;
        msgContract = await advancedContract.deploy();
    });

    describe("Deployment", () => {
        it("Send Message To Smart Contract", async () => {
          expect(await msgContract.sendMessage("Hello World!"));
        });
        it("View Message From Smart Contract", async () => {
          expect(await msgContract.messageInbox(owner, 0));
        });
    });
});