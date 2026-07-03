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

## Top-Up Routes

When the profile uses `recharging-ledger@1.0` as the P4 ledger, paid fallback
ledgers are configured with `recharging-ledger-fallbacks`:

```json
{
  "p4-ledger-device": "recharging-ledger@1.0",
  "recharging-ledger-fallbacks": [
    {
      "device": "ao-payment@1.0",
      "ledger-path": "/ledger~node-process@1.0",
      "auto-withdraw": true,
      "withdraw-token": "0syT13r0s0tgPmIed95bJnuSqaD29HQNN8D3ElLSrsc",
      "withdraw-recipient": "<bundler-beneficiary>"
    }
  ]
}
```

At boot, the bootstrap device computes a stable ID for each fallback message and
stores the route map in `lapee-topup-routes`. This ID is a top-up route key for
that fallback config. It is not the local ledger process ID.

Clients should discover the available routes from the node:

```text
GET /~meta@1.0/info/lapee-topup-routes?accept=application/json&require-codec=application/json
```

Then call the bootstrap top-up endpoint with the selected route key:

```text
POST /~lapee-p4-bootstrap@1.0/topup?topup-route=<route-id>
```

The client should not calculate the route ID itself. With one fallback, use the
only route. With multiple fallbacks, inspect the route value and choose the
payment device the client supports. `ao-payment@1.0` routes are forwarded to
`ingest`; other fallback devices default to `topup`.

## Published Device

```bash
device publish: lapee-p4-bootstrap@1.0 

spec=xC0kc--Ata4MPzJDyKqLSfWGal5OC2NiAtw0y9ZNf7Q 

impl=mR2aqX5udR7HiOexS3KDbURu59q7sjcJdYOXrxZkk0I 

signer=vZY2XY1RD9HIfWi8ift-1_DnHLDadZMWrufSh-_rKF0
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
