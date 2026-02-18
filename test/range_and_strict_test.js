const chai = require("chai");
const path = require("path");
const wasm_tester = require("circom_tester").wasm;

const assert = chai.assert;

const BUILD = path.join(__dirname, "..", "build");

describe("StrictNum2Bits (opencircom)", function () {
  let circuit;
  this.timeout(60000);

  before(async () => {
    circuit = await wasm_tester(path.join(__dirname, "circuits", "strict_num2bits_test.circom"), {
      output: BUILD,
      recompile: false,
    });
  });

  it("enforces in in [0, 255] and outputs bits for 0", async () => {
    const w = await circuit.calculateWitness({ in: 0 }, true);
    await circuit.checkConstraints(w);
    for (let i = 0; i < 8; i++) assert.equal(w[1 + i].toString(), "0");
  });

  it("enforces in in [0, 255] and outputs bits for 255", async () => {
    const w = await circuit.calculateWitness({ in: 255 }, true);
    await circuit.checkConstraints(w);
    for (let i = 0; i < 8; i++) assert.equal(w[1 + i].toString(), "1");
  });

  it("enforces in in [0, 255] for 42", async () => {
    const w = await circuit.calculateWitness({ in: 42 }, true);
    await circuit.checkConstraints(w);
    assert.equal(w[1].toString(), "0");
    assert.equal(w[2].toString(), "1");
    assert.equal(w[3].toString(), "0");
    assert.equal(w[4].toString(), "1");
    assert.equal(w[5].toString(), "0");
    assert.equal(w[6].toString(), "1");
    assert.equal(w[7].toString(), "0");
    assert.equal(w[8].toString(), "0");
  });
});

describe("RangeProof (opencircom)", function () {
  let circuit;
  this.timeout(60000);

  before(async () => {
    circuit = await wasm_tester(path.join(__dirname, "circuits", "range_proof_test.circom"), {
      output: BUILD,
      recompile: false,
    });
  });

  it("accepts x in [a, b] (a <= x <= b)", async () => {
    const w = await circuit.calculateWitness({ x: 100, a: 10, b: 200 }, true);
    await circuit.checkConstraints(w);
    assert.equal(w[1].toString(), "1");
  });

  it("accepts x = a (lower bound)", async () => {
    const w = await circuit.calculateWitness({ x: 50, a: 50, b: 100 }, true);
    await circuit.checkConstraints(w);
    assert.equal(w[1].toString(), "1");
  });

  it("accepts x = b (upper bound)", async () => {
    const w = await circuit.calculateWitness({ x: 100, a: 50, b: 100 }, true);
    await circuit.checkConstraints(w);
    assert.equal(w[1].toString(), "1");
  });

  it("accepts single-point range [7, 7]", async () => {
    const w = await circuit.calculateWitness({ x: 7, a: 7, b: 7 }, true);
    await circuit.checkConstraints(w);
    assert.equal(w[1].toString(), "1");
  });
});
