pragma circom 2.0.0;

include "../../circuits/arithmetic.circom";

template ArithmeticTest() {
    signal input arr3[3];
    signal input a2[2];
    signal input b2[2];
    signal output sum3;
    signal output sum1;
    signal output inner2;
    component s3 = Sum(3);
    component s1 = Sum(1);
    component ip2 = InnerProduct(2);
    s3.in[0] <== arr3[0];
    s3.in[1] <== arr3[1];
    s3.in[2] <== arr3[2];
    s1.in[0] <== arr3[0];
    ip2.a[0] <== a2[0];
    ip2.a[1] <== a2[1];
    ip2.b[0] <== b2[0];
    ip2.b[1] <== b2[1];
    sum3 <== s3.out;
    sum1 <== s1.out;
    inner2 <== ip2.out;
}

component main = ArithmeticTest();
