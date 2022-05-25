#!/bin/bash
cd contracts/circuits

if [ -d ./Multiplier ]; then
    echo "Multiplier directory already exists."
else 
    mkdir Multiplier
fi

if [ -f ./powersOfTau28_hez_final_10.ptau ]; then
    echo "powersOfTau28_hez_final_10.ptau already exists. Skipping."
else
    echo 'Downloading powersOfTau28_hez_final_10.ptau'
    wget https://hermez.s3-eu-west-1.amazonaws.com/powersOfTau28_hez_final_10.ptau
fi

echo "Compiling Multiplier.circom"
circom Multiplier.circom --r1cs --wasm --sym -o Multiplier

echo "Circuit Info:"
snarkjs r1cs info Multiplier/Multiplier.r1cs

echo "Circuit Constraints:"
snarkjs r1cs print Multiplier/Multiplier.r1cs Multiplier/Multiplier.sym

# Witness: all the signals that match the constraints of the circuit,
# calculated before the proof is generated.
echo "Generating witness"
snarkjs wtns calculate Multiplier/Multiplier_js/Multiplier.wasm inputs/multiplier.json Multiplier/witness.wtns

echo "Setup using Groth16..."
snarkjs groth16 setup Multiplier/Multiplier.r1cs powersOfTau28_hez_final_10.ptau Multiplier/circuit_0000.zkey

# Contribute zkey to ceremony
snarkjs zkey contribute Multiplier/circuit_0000.zkey Multiplier/circuit_final.zkey --name="!st contributor" -v -e="random text"
snarkjs zkey export verificationkey Multiplier/circuit_final.zkey Multiplier/verification_key.json

# Generate solidity contract
snarkjs zkey export solidityverifier Multiplier/circuit_final.zkey ../MultiplierVerifier.sol
echo "Done!"

cd ../..