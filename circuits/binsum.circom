pragma circom 2.0.0;

// Binary sum of ops operands of n bits each. Output is nout bits (binary).
// nout = ceil(log2((2^n - 1) * ops)).

function nbits(a) {
    var n = 1;
    var r = 0;
    while (n - 1 < a) {
        r++;
        n *= 2;
    }
    return r;
}

template BinSum(n, ops) {
    var nout = nbits(((1 << n) - 1) * ops);
    signal input in[ops][n];
    signal output out[nout];
    var lin = 0;
    var lout = 0;
    var e2 = 1;
    for (var k = 0; k < n; k++) {
        for (var j = 0; j < ops; j++) {
            lin += in[j][k] * e2;
        }
        e2 = e2 + e2;
    }
    e2 = 1;
    for (var k = 0; k < nout; k++) {
        out[k] <-- (lin >> k) & 1;
        out[k] * (out[k] - 1) === 0;
        lout += out[k] * e2;
        e2 = e2 + e2;
    }
    lin === lout;
}
