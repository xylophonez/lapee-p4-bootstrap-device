#!/usr/bin/env bash
set -euo pipefail

# Supply the exact package store/spec/implementation emitted by device package.
# HB_PRELOADED_STORE must contain the matching runtime's native devices.
# ERL_LIBS may select an existing build; otherwise use this repo's normal build.
# Usage (after packaging; use the IDs emitted by that build):
# BOOTSTRAP_PACKAGE_STORE=/absolute/path/to/store \
# BOOTSTRAP_SPEC_ID=<spec-id> BOOTSTRAP_IMPL_ID=<implementation-id> \
# HB_PRELOADED_STORE=/absolute/path/to/native-preloaded-store \
# ERL_LIBS=/absolute/path/to/build/lib bash scripts/check-packaged-assets.sh
# Requires matching OTP/erlc on PATH, Linux unshare user/network namespaces,
# and iproute2. Pinned Lua hashes intentionally change only with reviewed assets.
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
: "${BOOTSTRAP_PACKAGE_STORE:?Set the absolute package LMDB store path}"
: "${BOOTSTRAP_SPEC_ID:?Set the bootstrap specification ID}"
: "${BOOTSTRAP_IMPL_ID:?Set the bootstrap implementation ID}"
: "${HB_PRELOADED_STORE:?Set the absolute native preloaded store path}"
for ASSET_DIR in "$BOOTSTRAP_PACKAGE_STORE" "$HB_PRELOADED_STORE"; do
    case "$ASSET_DIR" in
        /*) ;;
        *) echo "Expected an absolute store path: $ASSET_DIR" >&2; exit 2 ;;
    esac
    test -d "$ASSET_DIR"
done
export ERL_LIBS="${ERL_LIBS:-$ROOT/_build/default/lib}"
export HB_PORT=0
TEST_DIR="$(mktemp -d)"
trap 'rm -rf "$TEST_DIR"' EXIT
mkdir "$TEST_DIR/ebin"
erlc -o "$TEST_DIR/ebin" "$ROOT/scripts/check_packaged_assets.erl"
cd "$TEST_DIR"
# No external network, publication or funds can be reached by this guard.
# Graceful shutdown lets native store/application processes finish before exit.
unshare -Urn sh -c 'ip link set lo up; exec erl +S 4 -noshell -pa ebin -eval '\''try check_packaged_assets:run(), init:stop(0) catch C:R:S -> io:format("FAILED ~p ~p ~p~n", [C,R,S]), init:stop(1) end.'\'''
