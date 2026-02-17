const chai = require("chai");
const path = require("path");
const wasm_tester = require("circom_tester").wasm;

const assert = chai.assert;

describe("Merkle (opencircom)", function () {
  let circuit;
  this.timeout(60000);

  before(async () => {
    circuit = await wasm_tester(path.join(__dirname, "circuits", "merkle_test.circom"), {
      output: path.join(__dirname, "..", "build"),
      recompile: false,
    });
  });

  it("constraints pass for valid 2-level path (left then right)", async () => {
    const leaf = 1;
    const pathElements = [2, 3];
    const pathIndices = [0, 1];
    const w = await circuit.calculateWitness({ leaf, pathElements, pathIndices }, true);
    await circuit.checkConstraints(w);
    assert.isDefined(w[1]);
  });

  it("constraints pass for valid 2-level path (right then left)", async () => {
    const leaf = 2;
    const pathElements = [1, 3];
    const pathIndices = [1, 0];
    const w = await circuit.calculateWitness({ leaf, pathElements, pathIndices }, true);
    await circuit.checkConstraints(w);
  });

  it("root is deterministic for same leaf and path", async () => {
    const leaf = 5;
    const pathElements = [10, 20];
    const pathIndices = [0, 1];
    const w1 = await circuit.calculateWitness({ leaf, pathElements, pathIndices }, true);
    const w2 = await circuit.calculateWitness({ leaf, pathElements, pathIndices }, true);
    assert.equal(w1[1].toString(), w2[1].toString());
  });

  it("constraints pass for pathIndices [1, 0]", async () => {
    const w = await circuit.calculateWitness({
      leaf: 99,
      pathElements: [88, 77],
      pathIndices: [1, 0],
    }, true);
    await circuit.checkConstraints(w);
    assert.isDefined(w[1]);
  });

  it("constraints pass for pathIndices [0, 0]", async () => {
    const w = await circuit.calculateWitness({
      leaf: 1,
      pathElements: [2, 3],
      pathIndices: [0, 0],
    }, true);
    await circuit.checkConstraints(w);
    assert.isDefined(w[1]);
  });

  it("different paths give different roots", async () => {
    const w1 = await circuit.calculateWitness({
      leaf: 1,
      pathElements: [2, 3],
      pathIndices: [0, 1],
    }, true);
    const w2 = await circuit.calculateWitness({
      leaf: 1,
      pathElements: [9, 8],
      pathIndices: [0, 1],
    }, true);
    assert.notEqual(w1[1].toString(), w2[1].toString());
  });
});
