# API

## `start/3`

Boot hook. Derives the node wallet address, chooses the beneficiary, creates the
local ledger process, clears stale ledger local-name state, and installs the
runtime profile hooks.

## `request/3`

Allows configured non-chargeable routes through p4 while forwarding chargeable
requests to the p4 processor.

## `response/3`

Runs p4 response charging for chargeable requests.

Configuration copied into generated pricing hooks:

- `arweave-byte-price`
- `bundler-premium` / `bundler_premium`
- `bundler-free-byte-limit` / `bundler_free_byte_limit`

Expected sibling device names in the node profile:

- `ao-payment@1.0`
- `arweave-byte-pricing@1.0`
- `bundler-settlement@1.0`
- `lapee-bundler-gc@1.0`
- `pricing-router@1.0`
- `simple-oracle@1.0`
