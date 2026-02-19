const chai = require("chai");
const path = require("path");
const wasm_tester = require("circom_tester").wasm;

const assert = chai.assert;

describe("Arithmetic (opencircom)", function () {
  let circuit;
  this.timeout(60000);

  before(async () => {
    circuit = await wasm_tester(path.join(__dirname, "circuits", "arithmetic_test.circom"), {
      output: path.join(__dirname, "..", "build"),
      recompile: false,
    });
  });

  it("Sum(1): single element", async () => {
    const w = await circuit.calculateWitness({ arr3: [99, 0, 0], a2: [0, 0], b2: [0, 0] }, true);
    await circuit.checkConstraints(w);
    assert.equal(w[1].toString(), "99");
  });

  it("Sum(3): three elements", async () => {
    const w = await circuit.calculateWitness({ arr3: [1, 2, 3], a2: [0, 0], b2: [0, 0] }, true);
    await circuit.checkConstraints(w);
    assert.equal(w[1].toString(), "6");
  });

  it("Sum(3): zeros", async () => {
    const w = await circuit.calculateWitness({ arr3: [0, 0, 0], a2: [0, 0], b2: [0, 0] }, true);
    await circuit.checkConstraints(w);
    assert.equal(w[1].toString(), "0");
  });

  it("InnerProduct(2): dot product", async () => {
    const w = await circuit.calculateWitness({ arr3: [0, 0, 0], a2: [3, 4], b2: [5, 6] }, true);
    await circuit.checkConstraints(w);
    assert.equal(w[3].toString(), "39");
  });

  it("InnerProduct(2): zeros", async () => {
    const w = await circuit.calculateWitness({ arr3: [1, 1, 1], a2: [0, 0], b2: [100, 200] }, true);
    await circuit.checkConstraints(w);
    assert.equal(w[3].toString(), "0");
  });

  it("Sum(1) output equals first element", async () => {
    const w = await circuit.calculateWitness({ arr3: [42, 1, 1], a2: [1, 1], b2: [1, 1] }, true);
    await circuit.checkConstraints(w);
    assert.equal(w[2].toString(), "42");
  });
});
