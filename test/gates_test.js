const chai = require("chai");
const path = require("path");
const wasm_tester = require("circom_tester").wasm;

const assert = chai.assert;

describe("Gates (opencircom)", function () {
  let circuit;
  this.timeout(60000);

  before(async () => {
    circuit = await wasm_tester(path.join(__dirname, "circuits", "gates_test.circom"), {
      output: path.join(__dirname, "..", "build"),
      recompile: false,
    });
  });

  it("XOR: 0,0 => 0; 1,1 => 0; 0,1 => 1", async () => {
    const w00 = await circuit.calculateWitness({ a: 0, b: 0 }, true);
    await circuit.checkConstraints(w00);
    assert.equal(w00[1].toString(), "0");
    const w11 = await circuit.calculateWitness({ a: 1, b: 1 }, true);
    assert.equal(w11[1].toString(), "0");
    const w01 = await circuit.calculateWitness({ a: 0, b: 1 }, true);
    assert.equal(w01[1].toString(), "1");
  });

  it("AND: 1,1 => 1; 0,1 => 0", async () => {
    const w11 = await circuit.calculateWitness({ a: 1, b: 1 }, true);
    await circuit.checkConstraints(w11);
    assert.equal(w11[2].toString(), "1");
    const w01 = await circuit.calculateWitness({ a: 0, b: 1 }, true);
    assert.equal(w01[2].toString(), "0");
  });

  it("OR: 0,0 => 0; 1,0 => 1", async () => {
    const w00 = await circuit.calculateWitness({ a: 0, b: 0 }, true);
    assert.equal(w00[3].toString(), "0");
    const w10 = await circuit.calculateWitness({ a: 1, b: 0 }, true);
    assert.equal(w10[3].toString(), "1");
  });

  it("NOT: 0 => 1, 1 => 0", async () => {
    const w0 = await circuit.calculateWitness({ a: 0, b: 0 }, true);
    assert.equal(w0[4].toString(), "1");
    const w1 = await circuit.calculateWitness({ a: 1, b: 0 }, true);
    assert.equal(w1[4].toString(), "0");
  });

  it("XOR 1,0 => 1", async () => {
    const w = await circuit.calculateWitness({ a: 1, b: 0 }, true);
    await circuit.checkConstraints(w);
    assert.equal(w[1].toString(), "1");
  });

  it("AND 0,0 => 0", async () => {
    const w = await circuit.calculateWitness({ a: 0, b: 0 }, true);
    assert.equal(w[2].toString(), "0");
  });

  it("OR 1,1 => 1", async () => {
    const w = await circuit.calculateWitness({ a: 1, b: 1 }, true);
    assert.equal(w[3].toString(), "1");
  });
});
