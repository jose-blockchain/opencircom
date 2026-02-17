const chai = require("chai");
const path = require("path");
const wasm_tester = require("circom_tester").wasm;

const assert = chai.assert;

describe("Nullifier (opencircom)", function () {
  let circuit;
  this.timeout(60000);

  before(async () => {
    circuit = await wasm_tester(path.join(__dirname, "circuits", "nullifier_test.circom"), {
      output: path.join(__dirname, "..", "build"),
      recompile: false,
    });
  });

  it("constraints pass for secret=1, externalNullifier=2", async () => {
    const w = await circuit.calculateWitness({ secret: 1, externalNullifier: 2 }, true);
    await circuit.checkConstraints(w);
    assert.isDefined(w[1]);
  });

  it("output is deterministic for same inputs", async () => {
    const w1 = await circuit.calculateWitness({ secret: 123, externalNullifier: 456 }, true);
    const w2 = await circuit.calculateWitness({ secret: 123, externalNullifier: 456 }, true);
    assert.equal(w1[1].toString(), w2[1].toString());
  });

  it("different secret gives different nullifier", async () => {
    const w1 = await circuit.calculateWitness({ secret: 1, externalNullifier: 10 }, true);
    const w2 = await circuit.calculateWitness({ secret: 2, externalNullifier: 10 }, true);
    assert.notEqual(w1[1].toString(), w2[1].toString());
  });

  it("different externalNullifier gives different nullifier", async () => {
    const w1 = await circuit.calculateWitness({ secret: 5, externalNullifier: 1 }, true);
    const w2 = await circuit.calculateWitness({ secret: 5, externalNullifier: 2 }, true);
    assert.notEqual(w1[1].toString(), w2[1].toString());
  });
});
