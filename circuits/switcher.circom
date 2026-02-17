pragma circom 2.0.0;

// If sel==0: outL=L, outR=R. If sel==1: outL=R, outR=L.
template Switcher() {
    signal input sel;
    signal input L;
    signal input R;
    signal output outL;
    signal output outR;
    signal aux;
    aux <== (R - L) * sel;
    outL <== aux + L;
    outR <== -aux + R;
}
