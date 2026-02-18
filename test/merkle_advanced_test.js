const chai = require("chai");
const path = require("path");
const wasm_tester = require("circom_tester").wasm;

const assert = chai.assert;

// Build root and path for a 2-level tree using the same Poseidon as the circuit (no circomlibjs).
async function buildTree2(helperCircuit, leaves, index) {
  const h1 = async (x) => {
    const w = await helperCircuit.calculateWitness({ in1: x, in2_0: 0, in2_1: 0 }, true);
    return w[1].toString();
  };
  const h2 = async (a, b) => {
    const w = await helperCircuit.calculateWitness({ in1: 0, in2_0: a, in2_1: b }, true);
    return w[2].toString();
  };
  const a = await h1(leaves[0]);
  const b = await h1(leaves[1]);
  const c = await h1(leaves[2]);
  const d = await h1(leaves[3]);
  const e = await h2(a, b);
  const f = await h2(c, d);
  const root = await h2(e, f);
  const pathIndices = [index & 1, (index >> 1) & 1];
  let pathElements;
  if (index === 0) pathElements = [b, f];
  else if (index === 1) pathElements = [a, f];
  else if (index === 2) pathElements = [d, e];
  else pathElements = [c, e];
  return { root, pathIndices, pathElements };
}

describe("Sparse Merkle inclusion (opencircom)", function () {
  let circuit;
  let helperCircuit;
  this.timeout(60000);

  before(async () => {
    helperCircuit = await wasm_tester(path.join(__dirname, "circuits", "poseidon_merkle_helper.circom"), {
      output: path.join(__dirname, "..", "build"),
      recompile: false,
    });
    circuit = await wasm_tester(path.join(__dirname, "circuits", "sparse_merkle_inclusion_test.circom"), {
      output: path.join(__dirname, "..", "build"),
      recompile: false,
    });
  });

  it("constraints pass for leaf at index 0", async () => {
    const leaves = [10, 20, 30, 40];
    const { root, pathIndices, pathElements } = await buildTree2(helperCircuit, leaves, 0);
    const w = await circuit.calculateWitness({
      leaf: leaves[0],
      pathElements,
      pathIndices,
    }, true);
    await circuit.checkConstraints(w);
    assert.equal(w[1].toString(), root);
  });

  it("constraints pass for leaf at index 3", async () => {
    const leaves = [1, 2, 3, 4];
    const { root, pathIndices, pathElements } = await buildTree2(helperCircuit, leaves, 3);
    const w = await circuit.calculateWitness({
      leaf: leaves[3],
      pathElements,
      pathIndices,
    }, true);
    await circuit.checkConstraints(w);
    assert.equal(w[1].toString(), root);
  });
});

describe("Sparse Merkle exclusion (opencircom)", function () {
  let circuit;
  let helperCircuit;
  this.timeout(60000);

  before(async () => {
    helperCircuit = await wasm_tester(path.join(__dirname, "circuits", "poseidon_merkle_helper.circom"), {
      output: path.join(__dirname, "..", "build"),
      recompile: false,
    });
    circuit = await wasm_tester(path.join(__dirname, "circuits", "sparse_merkle_exclusion_test.circom"), {
      output: path.join(__dirname, "..", "build"),
      recompile: false,
    });
  });

  it("constraints pass when leaf at key is empty (0)", async () => {
    const leaves = [5, 6, 0, 8];
    const index = 2;
    const { root, pathIndices, pathElements } = await buildTree2(helperCircuit, leaves, index);
    const w = await circuit.calculateWitness({ pathElements, pathIndices }, true);
    await circuit.checkConstraints(w);
    assert.equal(w[1].toString(), root);
  });
});

describe("Incremental Merkle inclusion (opencircom)", function () {
  let circuit;
  let helperCircuit;
  this.timeout(60000);

  before(async () => {
    helperCircuit = await wasm_tester(path.join(__dirname, "circuits", "poseidon_merkle_helper.circom"), {
      output: path.join(__dirname, "..", "build"),
      recompile: false,
    });
    circuit = await wasm_tester(path.join(__dirname, "circuits", "incremental_merkle_test.circom"), {
      output: path.join(__dirname, "..", "build"),
      recompile: false,
    });
  });

  it("constraints pass for index 1 (append-order)", async () => {
    const leaves = [100, 200, 300, 400];
    const index = 1;
    const { root, pathIndices, pathElements } = await buildTree2(helperCircuit, leaves, index);
    const w = await circuit.calculateWitness({
      leaf: leaves[index],
      index,
      pathElements,
    }, true);
    await circuit.checkConstraints(w);
    assert.equal(w[1].toString(), root);
  });
});

describe("Merkle update proof (opencircom)", function () {
  let circuit;
  let helperCircuit;
  this.timeout(60000);

  before(async () => {
    helperCircuit = await wasm_tester(path.join(__dirname, "circuits", "poseidon_merkle_helper.circom"), {
      output: path.join(__dirname, "..", "build"),
      recompile: false,
    });
    circuit = await wasm_tester(path.join(__dirname, "circuits", "merkle_update_test.circom"), {
      output: path.join(__dirname, "..", "build"),
      recompile: false,
    });
  });

  it("constraints pass when one leaf changes at same path", async () => {
    const leavesOld = [1, 2, 3, 4];
    const leavesNew = [1, 2, 99, 4];
    const index = 2;
    const { root: oldRoot, pathIndices, pathElements: pathElementsOld } = await buildTree2(helperCircuit, leavesOld, index);
    const { root: newRoot } = await buildTree2(helperCircuit, leavesNew, index);
    assert.notEqual(oldRoot, newRoot);
    const w = await circuit.calculateWitness({
      oldRoot,
      newRoot,
      oldLeaf: leavesOld[index],
      newLeaf: leavesNew[index],
      pathElements: pathElementsOld,
      pathIndices,
    }, true);
    await circuit.checkConstraints(w);
  });
});
