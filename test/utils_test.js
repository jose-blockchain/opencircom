const chai = require("chai");
const path = require("path");
const wasm_tester = require("circom_tester").wasm;

const assert = chai.assert;

describe("Utils PadBits / OneOfN (opencircom)", function () {
  let circuit;
  this.timeout(60000);

  before(async () => {
    circuit = await wasm_tester(path.join(__dirname, "circuits", "utils_test.circom"), {
      output: path.join(__dirname, "..", "build"),
      recompile: false,
    });
  });

  it("PadBits(3,5): first and last output", async () => {
    const w = await circuit.calculateWitness(
      { padIn: [1, 0, 1], arr: [0, 0, 0], value: 0 },
      true
    );
    await circuit.checkConstraints(w);
    assert.equal(w[1].toString(), "1");
    assert.equal(w[2].toString(), "0");
  });

  it("PadBits(3,5): zero-padded tail", async () => {
    const w = await circuit.calculateWitness(
      { padIn: [0, 1, 0], arr: [0, 0, 0], value: 0 },
      true
    );
    await circuit.checkConstraints(w);
    assert.equal(w[2].toString(), "0");
  });

  it("OneOfN(3): value in array", async () => {
    const w = await circuit.calculateWitness(
      { padIn: [0, 0, 0], arr: [10, 20, 30], value: 20 },
      true
    );
    await circuit.checkConstraints(w);
    assert.equal(w[3].toString(), "1");
  });

  it("OneOfN(3): value not in array", async () => {
    const w = await circuit.calculateWitness(
      { padIn: [0, 0, 0], arr: [10, 20, 30], value: 99 },
      true
    );
    await circuit.checkConstraints(w);
    assert.equal(w[3].toString(), "0");
  });

  it("OneOfN(3): value equals first element", async () => {
    const w = await circuit.calculateWitness(
      { padIn: [1, 1, 1], arr: [7, 8, 9], value: 7 },
      true
    );
    await circuit.checkConstraints(w);
    assert.equal(w[3].toString(), "1");
  });

  it("OneOfN(3): duplicate in array, value matches", async () => {
    const w = await circuit.calculateWitness(
      { padIn: [0, 0, 0], arr: [5, 5, 5], value: 5 },
      true
    );
    await circuit.checkConstraints(w);
    assert.equal(w[3].toString(), "1");
  });
});
