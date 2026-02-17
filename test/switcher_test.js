const chai = require("chai");
const path = require("path");
const wasm_tester = require("circom_tester").wasm;

const assert = chai.assert;

describe("Switcher (opencircom)", function () {
  let circuit;
  this.timeout(60000);

  before(async () => {
    circuit = await wasm_tester(path.join(__dirname, "circuits", "switcher_test.circom"), {
      output: path.join(__dirname, "..", "build"),
      recompile: false,
    });
  });

  it("sel=0: outL=L, outR=R", async () => {
    const w = await circuit.calculateWitness({ sel: 0, L: 100, R: 200 }, true);
    await circuit.checkConstraints(w);
    assert.equal(w[1].toString(), "100");
    assert.equal(w[2].toString(), "200");
  });

  it("sel=1: outL=R, outR=L", async () => {
    const w = await circuit.calculateWitness({ sel: 1, L: 100, R: 200 }, true);
    await circuit.checkConstraints(w);
    assert.equal(w[1].toString(), "200");
    assert.equal(w[2].toString(), "100");
  });

  it("sel=0 with L=R gives same both sides", async () => {
    const w = await circuit.calculateWitness({ sel: 0, L: 42, R: 42 }, true);
    await circuit.checkConstraints(w);
    assert.equal(w[1].toString(), "42");
    assert.equal(w[2].toString(), "42");
  });
});
