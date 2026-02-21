pragma circom 2.0.0;

include "../../circuits/utils.circom";

template BalanceProofTest() {
    signal input balance;
    signal input amount;
    signal input newBalance;
    component bp = BalanceProof(16);
    bp.balance <== balance;
    bp.amount <== amount;
    bp.newBalance <== newBalance;
}

component main = BalanceProofTest();
