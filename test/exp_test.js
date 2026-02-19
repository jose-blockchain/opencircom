const chai = require("chai");
const path = require("path");
const wasm_tester = require("circom_tester").wasm;

const assert = chai.assert;

describe("ExpByBits (opencircom)", function () {
  let circuit;
  this.timeout(60000);

  before(async () => {
    circuit = await wasm_tester(path.join(__dirname, "circuits", "exp_test.circom"), {
      output: path.join(__dirname, "..", "build"),
      recompile: false,
    });
  });

  // exp[0] is MSB, exp[n-1] is LSB (exp bits weight 2^(n-1-i))
  it("2^3 = 8 (exp=3 as MSB-first bits [0,0,1,1])", async () => {
    const w = await circuit.calculateWitness({ base: 2, exp: [0, 0, 1, 1] }, true);
    await circuit.checkConstraints(w);
    assert.equal(w[1].toString(), "8");
  });

  it("5^0 = 1", async () => {
    const w = await circuit.calculateWitness({ base: 5, exp: [0, 0, 0, 0] }, true);
    await circuit.checkConstraints(w);
    assert.equal(w[1].toString(), "1");
  });

  it("3^1 = 3 (exp=1 as [0,0,0,1])", async () => {
    const w = await circuit.calculateWitness({ base: 3, exp: [0, 0, 0, 1] }, true);
    await circuit.checkConstraints(w);
    assert.equal(w[1].toString(), "3");
  });

  it("2^4 = 16 (exp=4 as [0,1,0,0])", async () => {
    const w = await circuit.calculateWitness({ base: 2, exp: [0, 1, 0, 0] }, true);
    await circuit.checkConstraints(w);
    assert.equal(w[1].toString(), "16");
  });
});
