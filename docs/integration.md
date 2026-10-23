# Integration

Use `lapee-p4-bootstrap@1.11` as a start hook on HyperBEAM RC4
`ad415bdaaf887fb76c0a8b4f54d91fab3f9fccd8`. Configure trusted implementation
pins using ordinary node configuration. Default sibling names are
`ao-payment@1.11`, `arweave-byte-pricing@1.11`, `lapee-bundler-gc@1.11`,
`pricing-router@1.0` and `simple-oracle@1.0`. Explicit name resolvers and the
existing `p4-ledger-device`/recharging fallback selection remain available.

Provide `bundler-beneficiary` from the user's configuration UI: a canonical,
nonzero external address distinct from the node wallet. Startup derives the
internal P4 recipient, deposit address and ledger admin from the node wallet;
external withdrawals use the configured beneficiary.

Startup prepends native P4 to inherited request handlers, appends its response
processor and GC completion hook, and retains other hooks. Existing operator
`p4-non-chargable-routes` are preserved; otherwise profile defaults are used.
Both P4 and AO payment use `/~node-process@1.0/ledger`.

Existing `ao-payment-submit-url`, `ao-payment-mainnet-url`, `ao-payment-node`
and `ao-payment-auto-withdraw` values are preserved. Their established defaults
apply only when absent. Pricing and fallback-ledger settings are copied into
the generated processor. No new profile lock or policy namespace is added.

The archive includes exact RC4 token Lua under `src/priv/`. Use
`scripts/check-packaged-assets.sh` after producing a local signed package store
to verify actual archive resources and startup with stale fallback traps.
Publishing signed device artifacts remains a separate action from Git pushes.
