const chai = require("chai");
const path = require("path");
const wasm_tester = require("circom_tester").wasm;

const assert = chai.assert;

describe("Bitify (opencircom)", function () {
  let circuit;
  this.timeout(60000);

  before(async () => {
    circuit = await wasm_tester(path.join(__dirname, "circuits", "bitify_test.circom"), {
      output: path.join(__dirname, "..", "build"),
      recompile: false,
    });
  });

  it("Num2Bits(8) and Bits2Num round-trip for 0", async () => {
    const w = await circuit.calculateWitness({ in: 0 }, true);
    await circuit.checkConstraints(w);
    for (let i = 0; i < 8; i++) assert.equal(w[1 + i].toString(), "0");
    assert.equal(w[9].toString(), "0");
  });

  it("Num2Bits(8) and Bits2Num round-trip for 255", async () => {
    const w = await circuit.calculateWitness({ in: 255 }, true);
    await circuit.checkConstraints(w);
    for (let i = 0; i < 8; i++) assert.equal(w[1 + i].toString(), "1");
    assert.equal(w[9].toString(), "255");
  });

  it("Num2Bits(8) for 42 gives correct bits and reconstructed value", async () => {
    const w = await circuit.calculateWitness({ in: 42 }, true);
    await circuit.checkConstraints(w);
    assert.equal(w[9].toString(), "42");
  });

  it("round-trip for 1", async () => {
    const w = await circuit.calculateWitness({ in: 1 }, true);
    await circuit.checkConstraints(w);
    assert.equal(w[1].toString(), "1");
    for (let i = 1; i < 8; i++) assert.equal(w[1 + i].toString(), "0");
    assert.equal(w[9].toString(), "1");
  });

  it("round-trip for 128", async () => {
    const w = await circuit.calculateWitness({ in: 128 }, true);
    await circuit.checkConstraints(w);
    assert.equal(w[8].toString(), "1");
    assert.equal(w[9].toString(), "128");
  });

  it("round-trip for 127", async () => {
    const w = await circuit.calculateWitness({ in: 127 }, true);
    await circuit.checkConstraints(w);
    for (let i = 0; i < 7; i++) assert.equal(w[1 + i].toString(), "1");
    assert.equal(w[8].toString(), "0");
    assert.equal(w[9].toString(), "127");
  });
});
