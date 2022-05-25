#!/bin/bash

cd contracts/circuits

if [ -d ./AndGate ]; then
    echo "AndGate directory already exists."
else
    mkdir AndGate
fi

if [ -f ./powersOfTau28_hez_final_10.ptau ]; then
    echo "powersOfTau28_hez_final_10.ptau already exists. Skipping."
else
    echo 'Downloading powersOfTau28_hez_final_10.ptau'
    wget https://hermez.s3-eu-west-1.amazonaws.com/powersOfTau28_hez_final_10.ptau
fi

echo "Compiling AndGate.circom..."
circom AndGate.circom --r1cs --wasm --sym -o AndGate

echo "Circuit Info:"
snarkjs r1cs info AndGate/AndGate.r1cs

echo "Circuit Constraints:"
snarkjs r1cs print AndGate/AndGate.r1cs AndGate/AndGate.sym

echo "Generating witness..."
# generate the witness using the wasm file and a json file for input,
# then store the witness with the name at the end
snarkjs wtns calculate AndGate/AndGate_js/AndGate.wasm inputs/and-gate.json AndGate/witness.wtns

echo "Setup using Groth16..."
snarkjs groth16 setup AndGate/AndGate.r1cs powersOfTau28_hez_final_10.ptau AndGate/circuit_0000.zkey

# Contribute zkey to ceremony
snarkjs zkey contribute AndGate/circuit_0000.zkey AndGate/circuit_final.zkey --name="!st contributor" -v -e="random text"
snarkjs zkey export verificationkey AndGate/circuit_final.zkey AndGate/verification_key.json

# Generate solidity contract
snarkjs zkey export solidityverifier AndGate/circuit_final.zkey ../AndGateVerifier.sol
echo "Done!"

cd ../..