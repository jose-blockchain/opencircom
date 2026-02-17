"use strict";

// opencircom — circuit library root.
// Use in Circom via: include "opencircom/circuits/..." or add circuits to your include path.
// This file is for JS tooling (e.g. resolving circuit paths).

const path = require("path");

module.exports = {
    circuitsDir: path.join(__dirname, "circuits"),
    circuits: {
        hashing: path.join(__dirname, "circuits", "hashing"),
        merkle: path.join(__dirname, "circuits", "merkle"),
    },
};
