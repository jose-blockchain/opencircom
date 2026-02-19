const chai = require("chai");
const path = require("path");
const wasm_tester = require("circom_tester").wasm;

const assert = chai.assert;

describe("AssertNotEqual (opencircom)", function () {
  let circuit;
  this.timeout(60000);

  before(async () => {
    circuit = await wasm_tester(path.join(__dirname, "circuits", "assert_not_equal_test.circom"), {
      output: path.join(__dirname, "..", "build"),
      recompile: false,
    });
  });

  it("passes when a !== b", async () => {
    const w = await circuit.calculateWitness({ a: 3, b: 5 }, true);
    await circuit.checkConstraints(w);
    assert.equal(w[1].toString(), "1");
  });

  it("passes for distinct values", async () => {
    const w = await circuit.calculateWitness({ a: 0, b: 1 }, true);
    await circuit.checkConstraints(w);
    assert.equal(w[1].toString(), "1");
  });

  it("fails when a === b", async () => {
    let failed = false;
    try {
      await circuit.calculateWitness({ a: 7, b: 7 }, true);
    } catch (_) {
      failed = true;
    }
    assert.isTrue(failed);
  });
});
