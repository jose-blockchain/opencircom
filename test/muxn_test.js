const chai = require("chai");
const path = require("path");
const wasm_tester = require("circom_tester").wasm;

const assert = chai.assert;

describe("MuxN / SelectByIndex (opencircom)", function () {
  let circuit;
  this.timeout(60000);

  before(async () => {
    circuit = await wasm_tester(path.join(__dirname, "circuits", "muxn_test.circom"), {
      output: path.join(__dirname, "..", "build"),
      recompile: false,
    });
  });

  it("SelectByIndex(4): index 0", async () => {
    const w = await circuit.calculateWitness(
      {
        inputs4: [10, 20, 30, 40],
        index4: 0,
        inputs5: [0, 0, 0, 0, 0],
        index5: 0,
      },
      true
    );
    await circuit.checkConstraints(w);
    assert.equal(w[1].toString(), "10");
  });

  it("SelectByIndex(4): index 3", async () => {
    const w = await circuit.calculateWitness(
      {
        inputs4: [10, 20, 30, 40],
        index4: 3,
        inputs5: [0, 0, 0, 0, 0],
        index5: 0,
      },
      true
    );
    await circuit.checkConstraints(w);
    assert.equal(w[1].toString(), "40");
  });

  it("SelectByIndex(4): index 1 and 2", async () => {
    let w = await circuit.calculateWitness(
      { inputs4: [100, 200, 300, 400], index4: 1, inputs5: [0, 0, 0, 0, 0], index5: 0 },
      true
    );
    await circuit.checkConstraints(w);
    assert.equal(w[1].toString(), "200");
    w = await circuit.calculateWitness(
      { inputs4: [100, 200, 300, 400], index4: 2, inputs5: [0, 0, 0, 0, 0], index5: 0 },
      true
    );
    await circuit.checkConstraints(w);
    assert.equal(w[1].toString(), "300");
  });

  it("SelectByIndex(5): indices 0..4", async () => {
    const inputs5 = [11, 22, 33, 44, 55];
    for (let i = 0; i < 5; i++) {
      const w = await circuit.calculateWitness(
        {
          inputs4: [0, 0, 0, 0],
          index4: 0,
          inputs5,
          index5: i,
        },
        true
      );
      await circuit.checkConstraints(w);
      assert.equal(w[2].toString(), String(inputs5[i]));
    }
  });

  it("SelectByIndex(5): index 4", async () => {
    const w = await circuit.calculateWitness(
      {
        inputs4: [0, 0, 0, 0],
        index4: 0,
        inputs5: [1, 2, 3, 4, 99],
        index5: 4,
      },
      true
    );
    await circuit.checkConstraints(w);
    assert.equal(w[2].toString(), "99");
  });
});
