const chai = require("chai");
const path = require("path");
const wasm_tester = require("circom_tester").wasm;

const assert = chai.assert;

describe("Mux (opencircom)", function () {
  let circuit;
  this.timeout(60000);

  before(async () => {
    circuit = await wasm_tester(path.join(__dirname, "circuits", "mux_test.circom"), {
      output: path.join(__dirname, "..", "build"),
      recompile: false,
    });
  });

  it("Mux1: s=0 => out=c[0]", async () => {
    const w = await circuit.calculateWitness({
      c1: [10, 20],
      s1: 0,
      c2: [0, 0, 0, 0],
      s2: [0, 0],
    }, true);
    await circuit.checkConstraints(w);
    assert.equal(w[1].toString(), "10");
  });

  it("Mux1: s=1 => out=c[1]", async () => {
    const w = await circuit.calculateWitness({
      c1: [10, 20],
      s1: 1,
      c2: [0, 0, 0, 0],
      s2: [0, 0],
    }, true);
    await circuit.checkConstraints(w);
    assert.equal(w[1].toString(), "20");
  });

  it("Mux2: s=[0,0] => out=c[0]", async () => {
    const w = await circuit.calculateWitness({
      c1: [0, 0],
      s1: 0,
      c2: [100, 200, 300, 400],
      s2: [0, 0],
    }, true);
    await circuit.checkConstraints(w);
    assert.equal(w[2].toString(), "100");
  });

  it("Mux2: s=[1,1] => out=c[3]", async () => {
    const w = await circuit.calculateWitness({
      c1: [0, 0],
      s1: 0,
      c2: [100, 200, 300, 400],
      s2: [1, 1],
    }, true);
    await circuit.checkConstraints(w);
    assert.equal(w[2].toString(), "400");
  });
});
