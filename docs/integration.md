# Integration

Set this device as the node `on.start.device` in a profile that resolves the
sibling device names. It generates the live `on.request`, `on.response`, and
`on.bundled-message-complete` hooks at boot.

Profile requirements:

- `name-resolvers` entries for all sibling devices.
- `bundler-beneficiary` if withdrawals should go to a non-operator address.
- `load-remote-devices=true` and a trusted publisher when loading from Forge.

The device includes its ledger Lua scripts under `src/priv/`.
