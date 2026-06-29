# Lapee P4 Bootstrap Device

Standalone HyperBEAM Forge package for `lapee-p4-bootstrap@1.0`.

LapEE start hook that assembles the AO-payment p4 bundler profile.

It derives live wallet values, spawns the local AO payment ledger process, installs p4 request/response hooks, wires bundle-completion settlement and GC, and keeps pricing config in the generated hook messages.

## Compatibility

- HyperBEAM pin: `4177b91993b2f590f4906bc9ca548724f8408875`
- Device name: `lapee-p4-bootstrap@1.0`

## Build

```sh
rebar3 compile
rebar3 device package
rebar3 device verify
```

## Test

```sh
scripts/pre-push-test.sh
```

Install the local pre-push hook with:

```sh
scripts/install-git-hooks.sh
```

## Docs

- `docs/api.md`
- `docs/integration.md`
- `docs/generated.md`

Regenerate EDoc HTML with:

```sh
scripts/generate-docs.sh
```

## Publish

After tests pass, publish the Forge package artifacts generated under
`_build/device-packages/` with your normal ANS-104 item pipeline. Then pin the
published spec ID in your node's `name-resolvers` and trust the publisher
address in `trusted-device-signers`.
