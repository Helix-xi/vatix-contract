#!/usr/bin/env bash
#
# check-market-wasm-size.sh — #734 wasm32 size budget for the market crate.
#
# Builds vatix-market-contract twice:
#   1) default features
#   2) --features oracle-adapter
# and fails if either optimized wasm exceeds MARKET_WASM32_SIZE_BUDGET (64 KiB).
#
# Usage (from repo root):
#   bash scripts/check-market-wasm-size.sh
#
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

BUDGET="${MARKET_WASM32_SIZE_BUDGET:-65536}"
MANIFEST="contracts/market/Cargo.toml"

log() { printf '[wasm-budget] %s\n' "$*" >&2; }

if ! command -v stellar >/dev/null 2>&1; then
  log "ERROR: stellar CLI not found on PATH"
  exit 127
fi

size_of() {
  local path="$1"
  if [[ ! -f "$path" ]]; then
    log "ERROR: missing wasm artifact: $path"
    exit 1
  fi
  wc -c < "$path" | tr -d ' '
}

build_and_check() {
  local label="$1"
  shift
  log "Building market crate ($label)..."
  stellar contract build --manifest-path "$MANIFEST" "$@"
  local wasm
  wasm="$(find target/wasm32v1-none/release -maxdepth 1 -name 'vatix_market_contract*.wasm' ! -name '*.opt.wasm' | head -n1)"
  if [[ -z "${wasm}" ]]; then
    wasm="$(find target/wasm32v1-none/release -maxdepth 1 -name '*.wasm' ! -name '*.opt.wasm' | head -n1)"
  fi
  local bytes
  bytes="$(size_of "$wasm")"
  log "$label: $wasm ($bytes bytes, budget $BUDGET)"
  if (( bytes > BUDGET )); then
    log "ERROR: $label wasm $bytes exceeds budget $BUDGET (Soroban maxContractSizeBytes)"
    exit 1
  fi
}

build_and_check "default-features"
build_and_check "oracle-adapter" --features oracle-adapter

log "OK: market wasm stays within ${BUDGET} bytes with and without oracle-adapter"
