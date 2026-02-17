const chai = require("chai");
const path = require("path");
const wasm_tester = require("circom_tester").wasm;

const assert = chai.assert;

describe("Poseidon (opencircom)", function () {
    let circuit;
    this.timeout(60000);

    before(async () => {
        circuit = await wasm_tester(path.join(__dirname, "circuits", "poseidon_test.circom"), {
            output: path.join(__dirname, "..", "build"),
            recompile: false
        });
    });

    it("constraints pass for input [1, 2, 3]", async () => {
        const w = await circuit.calculateWitness({ in: [1, 2, 3] }, true);
        await circuit.checkConstraints(w);
        assert.isDefined(w[1]);
    });

    it("constraints pass for input [0, 0, 0]", async () => {
        const w = await circuit.calculateWitness({ in: [0, 0, 0] }, true);
        await circuit.checkConstraints(w);
    });

    it("output is deterministic", async () => {
        const w1 = await circuit.calculateWitness({ in: [42, 43, 44] }, true);
        const w2 = await circuit.calculateWitness({ in: [42, 43, 44] }, true);
        assert.equal(w1[1].toString(), w2[1].toString());
    });

    it("constraints pass for single non-zero value", async () => {
        const w = await circuit.calculateWitness({ in: [999, 0, 0] }, true);
        await circuit.checkConstraints(w);
        assert.isDefined(w[1]);
    });

    it("different inputs give different output", async () => {
        const w1 = await circuit.calculateWitness({ in: [1, 0, 0] }, true);
        const w2 = await circuit.calculateWitness({ in: [0, 1, 0] }, true);
        assert.notEqual(w1[1].toString(), w2[1].toString());
    });

    it("constraints pass for large field-like values", async () => {
        const big = "123456789012345678901234567890";
        const w = await circuit.calculateWitness({ in: [big, 1, 2] }, true);
        await circuit.checkConstraints(w);
        assert.isDefined(w[1]);
    });
});
