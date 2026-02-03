#!/usr/bin/env bash
set -euo pipefail

CONTRACT=0x26Ce3c8b879f0ff34fb36d588ff5592443Be3793
OWNER=0x907Da096b8fBD4fF3517B3284Cf0F2Fe1670cc2b
RPC_URL=https://ethereum-sepolia-rpc.publicnode.com

PRIVATE_KEY=$(sed -n "s/^PRIVATE_KEY=//p" .env | tr -d "\r")

/home/raphael/.foundry/bin/cast send "$CONTRACT" "mint(address)" "$OWNER" \
  --rpc-url "$RPC_URL" --private-key "$PRIVATE_KEY"

/home/raphael/.foundry/bin/cast send "$CONTRACT" "mint(address)" "$OWNER" \
  --rpc-url "$RPC_URL" --private-key "$PRIVATE_KEY"

/home/raphael/.foundry/bin/cast send "$CONTRACT" "mint(address)" "$OWNER" \
  --rpc-url "$RPC_URL" --private-key "$PRIVATE_KEY"

/home/raphael/.foundry/bin/cast call "$CONTRACT" "tokenURI(uint256)" 1 \
  --rpc-url "$RPC_URL"

/home/raphael/.foundry/bin/cast call "$CONTRACT" "tokenURI(uint256)" 2 \
  --rpc-url "$RPC_URL"

/home/raphael/.foundry/bin/cast call "$CONTRACT" "tokenURI(uint256)" 3 \
  --rpc-url "$RPC_URL"
