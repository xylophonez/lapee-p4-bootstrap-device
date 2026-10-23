# API

## `start/3`

Boot hook. Derives the node wallet address, validates the explicit external beneficiary, creates the
local ledger process, clears stale ledger local-name state, and installs the
runtime profile hooks.

The installed hooks use native `p4@1.0` directly and retain inherited handlers.
The following two exports remain compatibility wrappers for older callers.

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

- `ao-payment@1.11`
- `arweave-byte-pricing@1.11`
- `lapee-bundler-gc@1.11`
- `pricing-router@1.0`
- `simple-oracle@1.0`
