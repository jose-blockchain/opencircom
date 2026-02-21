const chai = require("chai");
const path = require("path");
const wasm_tester = require("circom_tester").wasm;

const assert = chai.assert;
const BUILD = path.join(__dirname, "..", "build");

describe("Utf8Validation (opencircom)", function () {
  let circuit;
  this.timeout(60000);

  before(async () => {
    circuit = await wasm_tester(path.join(__dirname, "circuits", "utf8_validation_test.circom"), {
      output: BUILD,
      recompile: false,
    });
  });

  it("accepts 4 ASCII bytes", async () => {
    const bytes = [65, 66, 67, 68];
    const w = await circuit.calculateWitness({ bytes }, true);
    await circuit.checkConstraints(w);
  });

  it("accepts 1 ASCII + 2-byte UTF-8 + null", async () => {
    const bytes = [65, 0xC2, 0xA2, 0];
    const w = await circuit.calculateWitness({ bytes }, true);
    await circuit.checkConstraints(w);
  });

  it("accepts all zeros", async () => {
    const bytes = [0, 0, 0, 0];
    const w = await circuit.calculateWitness({ bytes }, true);
    await circuit.checkConstraints(w);
  });

  it("fails when continuation byte without lead", async () => {
    const bytes = [0x80, 0, 0, 0];
    let failed = false;
    try {
      await circuit.calculateWitness({ bytes }, true);
    } catch (_) {
      failed = true;
    }
    assert.isTrue(failed);
  });
});

describe("FixedStringMatch (opencircom)", function () {
  let circuit;
  this.timeout(60000);

  before(async () => {
    circuit = await wasm_tester(path.join(__dirname, "circuits", "fixed_string_match_test.circom"), {
      output: BUILD,
      recompile: false,
    });
  });

  it("returns 1 when bytes equal expected", async () => {
    const bytes = [72, 105, 33, 0];
    const expected = [72, 105, 33, 0];
    const w = await circuit.calculateWitness({ bytes, expected }, true);
    await circuit.checkConstraints(w);
    assert.equal(w[1].toString(), "1");
  });

  it("returns 0 when one byte differs", async () => {
    const bytes = [72, 105, 33, 0];
    const expected = [72, 105, 32, 0];
    const w = await circuit.calculateWitness({ bytes, expected }, true);
    await circuit.checkConstraints(w);
    assert.equal(w[1].toString(), "0");
  });

  it("returns 1 when all match (digits)", async () => {
    const bytes = [49, 50, 51, 52];
    const expected = [49, 50, 51, 52];
    const w = await circuit.calculateWitness({ bytes, expected }, true);
    await circuit.checkConstraints(w);
    assert.equal(w[1].toString(), "1");
  });
});

describe("BytesAllInRange (opencircom)", function () {
  let circuit;
  this.timeout(60000);

  before(async () => {
    circuit = await wasm_tester(path.join(__dirname, "circuits", "bytes_all_in_range_test.circom"), {
      output: BUILD,
      recompile: false,
    });
  });

  it("returns 1 when all bytes in [48,57] (digits)", async () => {
    const bytes = [48, 57, 51, 52];
    const w = await circuit.calculateWitness({ bytes }, true);
    await circuit.checkConstraints(w);
    assert.equal(w[1].toString(), "1");
  });

  it("returns 0 when one byte out of range", async () => {
    const bytes = [48, 58, 51, 52];
    const w = await circuit.calculateWitness({ bytes }, true);
    await circuit.checkConstraints(w);
    assert.equal(w[1].toString(), "0");
  });
});
