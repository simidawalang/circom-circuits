pragma circom 2.0.0;

template Multiplier2() {
    signal input a;
    signal input b;

    signal output out;

    out <== a * b;
}

template binaryCheck() {
    signal input in;
    signal output out;

    // CONSTRAINTS:
    // this checks if the input is 0 or 1. 0 and 1 are roots of (x - 0)(x - 1) = 0;
    // therefore, the constraint will take on the form of x(x - 1) = 0
    in * (in - 1) === 0;

    // check that in = out
    out <== in;

}

template AndGate() {
    // AND gates act as binary bit multipliers
    signal input in1;
    signal input in2;

    signal output out;

    component mult = Multiplier2();
    component binCheck[2];
    
    binCheck[0] = binaryCheck();
    binCheck[1] = binaryCheck();

    binCheck[0].in <== in1;
    binCheck[1].in <== in2;

    mult.a <== binCheck[0].out;
    mult.b <== binCheck[1].out;

    out <== mult.out;
}

component main = AndGate();