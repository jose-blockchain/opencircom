const chai = require("chai");
const path = require("path");
const wasm_tester = require("circom_tester").wasm;

const assert = chai.assert;

describe("Comparators (opencircom)", function () {
    let circuit;
    this.timeout(60000);

    before(async () => {
        circuit = await wasm_tester(path.join(__dirname, "circuits", "comparators_test.circom"), {
            output: path.join(__dirname, "..", "build"),
            recompile: false
        });
    });

    it("LessThan: 5 < 10 => lt=1", async () => {
        const w = await circuit.calculateWitness({ a: 5, b: 10 }, true);
        await circuit.checkConstraints(w);
        assert.equal(w[1].toString(), "1");
        assert.equal(w[2].toString(), "0");
    });

    it("LessThan: 10 < 5 => lt=0", async () => {
        const w = await circuit.calculateWitness({ a: 10, b: 5 }, true);
        await circuit.checkConstraints(w);
        assert.equal(w[1].toString(), "0");
    });

    it("IsEqual: 7 == 7 => eq=1", async () => {
        const w = await circuit.calculateWitness({ a: 7, b: 7 }, true);
        await circuit.checkConstraints(w);
        assert.equal(w[2].toString(), "1");
    });

    it("IsEqual: 3 != 5 => eq=0", async () => {
        const w = await circuit.calculateWitness({ a: 3, b: 5 }, true);
        await circuit.checkConstraints(w);
        assert.equal(w[2].toString(), "0");
    });

    it("LessThan boundary: 0 < 1 => lt=1", async () => {
        const w = await circuit.calculateWitness({ a: 0, b: 1 }, true);
        await circuit.checkConstraints(w);
        assert.equal(w[1].toString(), "1");
    });

    it("LessThan: a === b => lt=0", async () => {
        const w = await circuit.calculateWitness({ a: 100, b: 100 }, true);
        await circuit.checkConstraints(w);
        assert.equal(w[1].toString(), "0");
    });
});
