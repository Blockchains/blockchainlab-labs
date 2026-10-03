const { expect } = require("chai");
const { ethers } = require("hardhat");
describe("Lab H1 — Counter (Hardhat)", function () {
  let c, owner;
  beforeEach(async () => { [owner] = await ethers.getSigners(); c = await (await ethers.getContractFactory("Counter")).deploy(); });
  it("increments and emits", async () => {
    const tx = await c.inc(); const rc = await tx.wait();
    const ev = c.interface.parseLog(rc.logs[0]);
    expect(ev.name).to.equal("Incremented"); expect(ev.args.by).to.equal(owner.address); expect(ev.args.newCount).to.equal(1n);
    expect(await c.count()).to.equal(1n);
  });
  it("reverts with the custom error at zero", async () => {
    let err; try { await c.dec(); } catch (e) { err = e; }
    expect(c.interface.parseError(err.data).name).to.equal("Underflow");
  });
});
