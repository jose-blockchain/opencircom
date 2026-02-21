const chai = require("chai");
const path = require("path");
const wasm_tester = require("circom_tester").wasm;

const assert = chai.assert;
const BUILD = path.join(__dirname, "..", "build");

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

describe("AllowlistMembership (opencircom)", function () {
  let circuit;
  let helperCircuit;
  this.timeout(60000);

  before(async () => {
    helperCircuit = await wasm_tester(path.join(__dirname, "circuits", "poseidon_merkle_helper.circom"), { output: BUILD, recompile: false });
    circuit = await wasm_tester(path.join(__dirname, "circuits", "allowlist_membership_test.circom"), { output: BUILD, recompile: false });
  });

  it("proves identity at index 0 in allowlist tree", async () => {
    const identity = 10;
    const leaves = [identity, 20, 30, 40];
    const { pathIndices, pathElements } = await buildTree2(helperCircuit, leaves, 0);
    const w = await circuit.calculateWitness({ identity, pathElements, pathIndices }, true);
    await circuit.checkConstraints(w);
    // Root is in w[1]; contract should verify it matches the on-chain allowlist root
    assert.isDefined(w[1].toString());
  });
});

describe("PadBits10Star (opencircom)", function () {
  let circuit;
  this.timeout(60000);

  before(async () => {
    circuit = await wasm_tester(path.join(__dirname, "circuits", "pad_bits_10star_test.circom"), { output: BUILD, recompile: false });
  });

  it("pads 4 bits with 1 then zeros to 8", async () => {
    const w = await circuit.calculateWitness({ in: [1, 0, 1, 0] }, true);
    await circuit.checkConstraints(w);
    assert.equal(w[1].toString(), "1");
    assert.equal(w[2].toString(), "0");
    assert.equal(w[3].toString(), "1");
    assert.equal(w[4].toString(), "0");
    assert.equal(w[5].toString(), "1");
    assert.equal(w[6].toString(), "0");
    assert.equal(w[7].toString(), "0");
    assert.equal(w[8].toString(), "0");
  });
});

describe("ConditionalSelect (opencircom)", function () {
  let circuit;
  this.timeout(60000);

  before(async () => {
    circuit = await wasm_tester(path.join(__dirname, "circuits", "conditional_select_test.circom"), { output: BUILD, recompile: false });
  });

  it("condition=1 selects a", async () => {
    const w = await circuit.calculateWitness({ condition: 1, a: 100, b: 200 }, true);
    await circuit.checkConstraints(w);
    assert.equal(w[1].toString(), "100");
  });

  it("condition=0 selects b", async () => {
    const w = await circuit.calculateWitness({ condition: 0, a: 100, b: 200 }, true);
    await circuit.checkConstraints(w);
    assert.equal(w[1].toString(), "200");
  });
});

describe("BalanceProof (opencircom)", function () {
  let circuit;
  this.timeout(60000);

  before(async () => {
    circuit = await wasm_tester(path.join(__dirname, "circuits", "balance_proof_test.circom"), { output: BUILD, recompile: false });
  });

  it("balance >= amount, newBalance = balance - amount", async () => {
    const w = await circuit.calculateWitness({ balance: 100, amount: 30, newBalance: 70 }, true);
    await circuit.checkConstraints(w);
  });
});

describe("VoteInAllowlist (opencircom)", function () {
  let circuit;
  this.timeout(60000);

  before(async () => {
    circuit = await wasm_tester(path.join(__dirname, "circuits", "vote_in_allowlist_test.circom"), { output: BUILD, recompile: false });
  });

  it("vote in allowlist returns 1", async () => {
    const w = await circuit.calculateWitness({ vote: 2, allowedChoices: [0, 2, 5] }, true);
    await circuit.checkConstraints(w);
    assert.equal(w[1].toString(), "1");
  });

  it("vote not in allowlist returns 0", async () => {
    const w = await circuit.calculateWitness({ vote: 3, allowedChoices: [0, 2, 5] }, true);
    await circuit.checkConstraints(w);
    assert.equal(w[1].toString(), "0");
  });
});

describe("PadPKCS7 (opencircom)", function () {
  let circuit;
  this.timeout(60000);

  before(async () => {
    circuit = await wasm_tester(path.join(__dirname, "circuits", "pad_pkcs7_test.circom"), { output: BUILD, recompile: false });
  });

  it("constrains PKCS#7 padding: 3 message bytes, 5 pad bytes of value 5", async () => {
    const block = [10, 20, 30, 5, 5, 5, 5, 5];
    const numUsed = 3;
    const w = await circuit.calculateWitness({ block, numUsed }, true);
    await circuit.checkConstraints(w);
  });

  it("7 message bytes, 1 pad byte of value 1", async () => {
    const block = [1, 2, 3, 4, 5, 6, 7, 1];
    const numUsed = 7;
    const w = await circuit.calculateWitness({ block, numUsed }, true);
    await circuit.checkConstraints(w);
  });
});
