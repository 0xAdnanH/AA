const { expect } = require("chai");
const { ethers } = require("hardhat");

let owner;
let contract;
let addr1;
let addr2;
let testContract;
before(async () => {
  [owner, addr1, addr2] = await ethers.getSigners();
  const contractFacory = await ethers.getContractFactory("account");
  const testFactory = await ethers.getContractFactory("testContract");
  testContract = await testFactory.deploy();

  contract = await contractFacory.connect(owner).deploy();
});
describe("execute function test", async () => {
  const valueToSend = 500000;
  const dataToSend = "0x11";
  it("should low level call successfully", async () => {
    await expect(
      contract
        .connect(owner)
        .execute(0, addr1, valueToSend, dataToSend, { value: valueToSend })
    )
      .to.emit(contract, "Executed")
      .withArgs(0, addr1.address, valueToSend, dataToSend);
  });

  it("testing operationtype 1", async () => {
    const operationType = 1;
    const valueToSend = 0;
    const dataToSend =
      "0x6080604052348015600f57600080fd5b50603f80601d6000396000f3fe6080604052600080fdfea2646970667358221220fb4361c8e2bc9cc551ae4994b235565660d2eba335297a955d1921884435cc8e64736f6c63430008130033";
    const target = addr1;
    await contract
      .connect(owner)
      .execute(operationType, target.address, valueToSend, dataToSend);
  });
});

describe("Signature Test", () => {
  it("should return 0x1626ba7e the signature of the function", async () => {
    const HashMessage = ethers.hashMessage("Hello World");

    const signature = await owner.signMessage("Hello World");
    const result = await contract.isValidSignature(HashMessage, signature);
    expect(result).to.be.equal("0x1626ba7e");
  });
  it("should return 0xffffffff when signing with non owner address", async () => {
    const HashMessage = ethers.hashMessage("Hello World");

    const signature = await addr2.signMessage("Hello World");
    const result = await contract.isValidSignature(HashMessage, signature);
    expect(result).to.be.equal("0xffffffff");
  });
});
describe("setData && getData Test", () => {
  it("should retrieve data successfully", async () => {
    const datakey = ethers.hashMessage("key");
    const dataValue = "0x1122";
    await contract.connect(owner).setData(datakey, dataValue);
    const result = await contract.getData(datakey);
    expect(result).to.equal(dataValue);
  });
});
