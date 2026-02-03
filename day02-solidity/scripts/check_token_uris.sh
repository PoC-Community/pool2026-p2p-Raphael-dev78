#!/usr/bin/env bash
set -euo pipefail

RPC_URL=https://ethereum-sepolia-rpc.publicnode.com
CONTRACT=0x26Ce3c8b879f0ff34fb36d588ff5592443Be3793

for id in 1 2 3; do
  raw=$(/home/raphael/.foundry/bin/cast call "$CONTRACT" "tokenURI(uint256)" "$id" --rpc-url "$RPC_URL")
  echo "raw($id)=$raw"
  /home/raphael/.foundry/bin/cast abi-decode "f()(string)" "$raw"
done
