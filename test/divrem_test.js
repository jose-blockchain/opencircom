const chai = require("chai");
const path = require("path");
const wasm_tester = require("circom_tester").wasm;

const assert = chai.assert;

describe("DivRem (opencircom)", function () {
  let circuit;
  this.timeout(60000);

  before(async () => {
    circuit = await wasm_tester(path.join(__dirname, "circuits", "divrem_test.circom"), {
      output: path.join(__dirname, "..", "build"),
      recompile: false,
    });
  });

  it("7 / 2 = 3 rem 1", async () => {
    const w = await circuit.calculateWitness({ a: 7, b: 2, q: 3, r: 1 }, true);
    await circuit.checkConstraints(w);
    assert.equal(w[1].toString(), "3");
    assert.equal(w[2].toString(), "1");
  });

  it("6 / 3 = 2 rem 0", async () => {
    const w = await circuit.calculateWitness({ a: 6, b: 3, q: 2, r: 0 }, true);
    await circuit.checkConstraints(w);
    assert.equal(w[1].toString(), "2");
    assert.equal(w[2].toString(), "0");
  });

  it("0 / 1 = 0 rem 0", async () => {
    const w = await circuit.calculateWitness({ a: 0, b: 1, q: 0, r: 0 }, true);
    await circuit.checkConstraints(w);
    assert.equal(w[1].toString(), "0");
    assert.equal(w[2].toString(), "0");
  });

  it("5 / 5 = 1 rem 0", async () => {
    const w = await circuit.calculateWitness({ a: 5, b: 5, q: 1, r: 0 }, true);
    await circuit.checkConstraints(w);
    assert.equal(w[1].toString(), "1");
    assert.equal(w[2].toString(), "0");
  });

  it("100 / 7 = 14 rem 2", async () => {
    const w = await circuit.calculateWitness({ a: 100, b: 7, q: 14, r: 2 }, true);
    await circuit.checkConstraints(w);
    assert.equal(w[1].toString(), "14");
    assert.equal(w[2].toString(), "2");
  });
});
