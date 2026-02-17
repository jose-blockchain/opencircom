const chai = require("chai");
const path = require("path");
const wasm_tester = require("circom_tester").wasm;

const assert = chai.assert;

describe("MiMC (opencircom)", function () {
  let circuit;
  this.timeout(60000);

  before(async () => {
    circuit = await wasm_tester(path.join(__dirname, "circuits", "mimc_test.circom"), {
      output: path.join(__dirname, "..", "build"),
      recompile: false,
    });
  });

  it("constraints pass for x=0, k=0", async () => {
    const w = await circuit.calculateWitness({ x: 0, k: 0 }, true);
    await circuit.checkConstraints(w);
    assert.isDefined(w[1]);
  });

  it("output is deterministic for same inputs", async () => {
    const w1 = await circuit.calculateWitness({ x: 123, k: 456 }, true);
    const w2 = await circuit.calculateWitness({ x: 123, k: 456 }, true);
    assert.equal(w1[1].toString(), w2[1].toString());
  });

  it("constraints pass for x=1, k=0", async () => {
    const w = await circuit.calculateWitness({ x: 1, k: 0 }, true);
    await circuit.checkConstraints(w);
    assert.isDefined(w[1]);
  });

  it("different (x,k) give different output", async () => {
    const w1 = await circuit.calculateWitness({ x: 0, k: 1 }, true);
    const w2 = await circuit.calculateWitness({ x: 1, k: 0 }, true);
    assert.notEqual(w1[1].toString(), w2[1].toString());
  });
});
