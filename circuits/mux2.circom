pragma circom 2.0.0;

template MultiMux2(n) {
    signal input c[n][4];
    signal input s[2];
    signal output out[n];
    signal a10[n];
    signal a1[n];
    signal a0[n];
    signal a[n];
    signal s10;
    s10 <== s[1] * s[0];
    for (var i = 0; i < n; i++) {
        a10[i] <== (c[i][3] - c[i][2] - c[i][1] + c[i][0]) * s10;
        a1[i] <== (c[i][2] - c[i][0]) * s[1];
        a0[i] <== (c[i][1] - c[i][0]) * s[0];
        a[i] <== c[i][0];
        out[i] <== a10[i] + a1[i] + a0[i] + a[i];
    }
}

template Mux2() {
    signal input c[4];
    signal input s[2];
    signal output out;
    component mux = MultiMux2(1);
    for (var i = 0; i < 4; i++) {
        mux.c[0][i] <== c[i];
    }
    for (var i = 0; i < 2; i++) {
        s[i] ==> mux.s[i];
    }
    mux.out[0] ==> out;
}
