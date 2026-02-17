const chai = require("chai");
const path = require("path");
const wasm_tester = require("circom_tester").wasm;

const assert = chai.assert;

describe("Comparators extended (IsZero, LessEq, Greater)", function () {
  let circuit;
  this.timeout(60000);

  before(async () => {
    circuit = await wasm_tester(path.join(__dirname, "circuits", "comparators_ext_test.circom"), {
      output: path.join(__dirname, "..", "build"),
      recompile: false,
    });
  });

  it("IsZero: 0 => 1", async () => {
    const w = await circuit.calculateWitness({ a: 0, b: 0, single: 0 }, true);
    await circuit.checkConstraints(w);
    assert.equal(w[6].toString(), "1");
  });

  it("IsZero: 1 => 0", async () => {
    const w = await circuit.calculateWitness({ a: 0, b: 0, single: 1 }, true);
    await circuit.checkConstraints(w);
    assert.equal(w[6].toString(), "0");
  });

  it("LessEqThan: 5 <= 10 => 1", async () => {
    const w = await circuit.calculateWitness({ a: 5, b: 10, single: 0 }, true);
    await circuit.checkConstraints(w);
    assert.equal(w[2].toString(), "1");
  });

  it("LessEqThan: 10 <= 10 => 1", async () => {
    const w = await circuit.calculateWitness({ a: 10, b: 10, single: 0 }, true);
    await circuit.checkConstraints(w);
    assert.equal(w[2].toString(), "1");
  });

  it("LessEqThan: 11 <= 10 => 0", async () => {
    const w = await circuit.calculateWitness({ a: 11, b: 10, single: 0 }, true);
    await circuit.checkConstraints(w);
    assert.equal(w[2].toString(), "0");
  });

  it("GreaterThan: 10 > 5 => 1", async () => {
    const w = await circuit.calculateWitness({ a: 10, b: 5, single: 0 }, true);
    await circuit.checkConstraints(w);
    assert.equal(w[3].toString(), "1");
  });

  it("GreaterThan: 5 > 10 => 0", async () => {
    const w = await circuit.calculateWitness({ a: 5, b: 10, single: 0 }, true);
    await circuit.checkConstraints(w);
    assert.equal(w[3].toString(), "0");
  });

  it("GreaterEqThan: 7 >= 7 => 1", async () => {
    const w = await circuit.calculateWitness({ a: 7, b: 7, single: 0 }, true);
    await circuit.checkConstraints(w);
    assert.equal(w[4].toString(), "1");
  });

  it("GreaterEqThan: 6 >= 7 => 0", async () => {
    const w = await circuit.calculateWitness({ a: 6, b: 7, single: 0 }, true);
    await circuit.checkConstraints(w);
    assert.equal(w[4].toString(), "0");
  });
});
