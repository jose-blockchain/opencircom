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

describe("Utils IndexOf (opencircom)", function () {
  let circuit;
  this.timeout(60000);

  before(async () => {
    circuit = await wasm_tester(path.join(__dirname, "circuits", "index_of_test.circom"), {
      output: path.join(__dirname, "..", "build"),
      recompile: false,
    });
  });

  it("IndexOf(4,2): value at index 0", async () => {
    const w = await circuit.calculateWitness(
      { arr: [10, 20, 30, 40], value: 10, index: 0 },
      true
    );
    await circuit.checkConstraints(w);
    assert.equal(w[1].toString(), "0");
  });

  it("IndexOf(4,2): value at index 2", async () => {
    const w = await circuit.calculateWitness(
      { arr: [1, 2, 3, 4], value: 3, index: 2 },
      true
    );
    await circuit.checkConstraints(w);
    assert.equal(w[1].toString(), "2");
  });

  it("IndexOf(4,2): value at index 3", async () => {
    const w = await circuit.calculateWitness(
      { arr: [100, 200, 300, 400], value: 400, index: 3 },
      true
    );
    await circuit.checkConstraints(w);
    assert.equal(w[1].toString(), "3");
  });

  it("IndexOf(4,2): duplicate values, index points to first occurrence", async () => {
    const w = await circuit.calculateWitness(
      { arr: [7, 7, 7, 7], value: 7, index: 1 },
      true
    );
    await circuit.checkConstraints(w);
    assert.equal(w[1].toString(), "1");
  });
});

describe("Utils Min2 / Max2 / AllEqual / CountMatches (opencircom)", function () {
  let circuit;
  this.timeout(60000);

  before(async () => {
    circuit = await wasm_tester(path.join(__dirname, "circuits", "minmax_allequal_count_test.circom"), {
      output: path.join(__dirname, "..", "build"),
      recompile: false,
    });
  });

  it("Min2(16): min(10, 20) = 10", async () => {
    const w = await circuit.calculateWitness(
      { a: 10, b: 20, arr3: [0, 0, 0], arr4: [0, 0, 0, 0], value: 0 },
      true
    );
    await circuit.checkConstraints(w);
    assert.equal(w[1].toString(), "10");
    assert.equal(w[2].toString(), "20");
  });

  it("Min2(16): min(99, 50) = 50", async () => {
    const w = await circuit.calculateWitness(
      { a: 99, b: 50, arr3: [1, 1, 1], arr4: [1, 1, 1, 1], value: 1 },
      true
    );
    await circuit.checkConstraints(w);
    assert.equal(w[1].toString(), "50");
    assert.equal(w[2].toString(), "99");
  });

  it("Min2/Max2: equal values", async () => {
    const w = await circuit.calculateWitness(
      { a: 7, b: 7, arr3: [7, 7, 7], arr4: [7, 7, 7, 7], value: 7 },
      true
    );
    await circuit.checkConstraints(w);
    assert.equal(w[1].toString(), "7");
    assert.equal(w[2].toString(), "7");
  });

  it("AllEqual(3): all same", async () => {
    const w = await circuit.calculateWitness(
      { a: 0, b: 1, arr3: [5, 5, 5], arr4: [0, 0, 0, 0], value: 0 },
      true
    );
    await circuit.checkConstraints(w);
    assert.equal(w[3].toString(), "1");
  });

  it("AllEqual(3): not all same", async () => {
    const w = await circuit.calculateWitness(
      { a: 0, b: 1, arr3: [1, 2, 3], arr4: [0, 0, 0, 0], value: 0 },
      true
    );
    await circuit.checkConstraints(w);
    assert.equal(w[3].toString(), "0");
  });

  it("AllEqual(4): all same", async () => {
    const w = await circuit.calculateWitness(
      { a: 0, b: 1, arr3: [0, 0, 0], arr4: [10, 10, 10, 10], value: 10 },
      true
    );
    await circuit.checkConstraints(w);
    assert.equal(w[4].toString(), "1");
  });

  it("CountMatches(4): zero matches", async () => {
    const w = await circuit.calculateWitness(
      { a: 0, b: 1, arr3: [0, 0, 0], arr4: [1, 2, 3, 4], value: 99 },
      true
    );
    await circuit.checkConstraints(w);
    assert.equal(w[5].toString(), "0");
  });

  it("CountMatches(4): two matches", async () => {
    const w = await circuit.calculateWitness(
      { a: 0, b: 1, arr3: [0, 0, 0], arr4: [10, 20, 10, 30], value: 10 },
      true
    );
    await circuit.checkConstraints(w);
    assert.equal(w[5].toString(), "2");
  });

  it("CountMatches(4): four matches", async () => {
    const w = await circuit.calculateWitness(
      { a: 0, b: 1, arr3: [0, 0, 0], arr4: [7, 7, 7, 7], value: 7 },
      true
    );
    await circuit.checkConstraints(w);
    assert.equal(w[5].toString(), "4");
  });
});

describe("Utils MinN / MaxN (opencircom)", function () {
  let circuit;
  this.timeout(60000);

  before(async () => {
    circuit = await wasm_tester(path.join(__dirname, "circuits", "minn_maxn_test.circom"), {
      output: path.join(__dirname, "..", "build"),
      recompile: false,
    });
  });

  it("MinN(16,4) and MaxN(16,4): ascending array", async () => {
    const w = await circuit.calculateWitness(
      { arr4: [10, 20, 30, 40], arr5: [0, 0, 0, 0, 0] },
      true
    );
    await circuit.checkConstraints(w);
    assert.equal(w[1].toString(), "10");
    assert.equal(w[2].toString(), "40");
  });

  it("MinN(16,4) and MaxN(16,4): descending array", async () => {
    const w = await circuit.calculateWitness(
      { arr4: [100, 80, 60, 40], arr5: [1, 1, 1, 1, 1] },
      true
    );
    await circuit.checkConstraints(w);
    assert.equal(w[1].toString(), "40");
    assert.equal(w[2].toString(), "100");
  });

  it("MinN(16,5) and MaxN(16,5): min/max in middle", async () => {
    const w = await circuit.calculateWitness(
      { arr4: [0, 0, 0, 0], arr5: [50, 10, 99, 25, 5] },
      true
    );
    await circuit.checkConstraints(w);
    assert.equal(w[3].toString(), "5");
    assert.equal(w[4].toString(), "99");
  });

  it("MinN/MaxN: all equal", async () => {
    const w = await circuit.calculateWitness(
      { arr4: [7, 7, 7, 7], arr5: [13, 13, 13, 13, 13] },
      true
    );
    await circuit.checkConstraints(w);
    assert.equal(w[1].toString(), "7");
    assert.equal(w[2].toString(), "7");
    assert.equal(w[3].toString(), "13");
    assert.equal(w[4].toString(), "13");
  });
});

describe("Utils Tally (opencircom)", function () {
  let circuit;
  this.timeout(60000);

  before(async () => {
    circuit = await wasm_tester(path.join(__dirname, "circuits", "tally_test.circom"), {
      output: path.join(__dirname, "..", "build"),
      recompile: false,
    });
  });

  it("Tally(3,5): votes [0,1,2,0,1] -> count [2,2,1]", async () => {
    const w = await circuit.calculateWitness({ votes: [0, 1, 2, 0, 1] }, true);
    await circuit.checkConstraints(w);
    assert.equal(w[1].toString(), "2");
    assert.equal(w[2].toString(), "2");
    assert.equal(w[3].toString(), "1");
  });

  it("Tally(3,5): all choice 0 -> count [5,0,0]", async () => {
    const w = await circuit.calculateWitness({ votes: [0, 0, 0, 0, 0] }, true);
    await circuit.checkConstraints(w);
    assert.equal(w[1].toString(), "5");
    assert.equal(w[2].toString(), "0");
    assert.equal(w[3].toString(), "0");
  });

  it("Tally(3,5): mixed votes -> count [2,2,1]", async () => {
    const w = await circuit.calculateWitness({ votes: [0, 1, 2, 1, 0] }, true);
    await circuit.checkConstraints(w);
    assert.equal(w[1].toString(), "2");
    assert.equal(w[2].toString(), "2");
    assert.equal(w[3].toString(), "1");
  });
});
