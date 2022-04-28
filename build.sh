#!/bin/bash
set -euo pipefail

PROJECT="$1"
shift
BIN="${BIN-}"
PATCH="${PATCH-}"

if [ "$BIN" = "" ]; then
  BIN=$(echo "$PROJECT" | cut -d / -f 5)
fi

git clone "$PROJECT" "$BIN"
cd "$BIN"
if [ "$PATCH" != "" ]; then
  git apply "$PATCH"
fi
source "$HOME/.cargo/env"
# aarch64-unknown-linux-musl or x86_64-unknown-linux-musl
if [ "$(cat /uname-m)" = "x86_64" ]; then
  LINK="mold -run"
else
  LINK=""
fi
RUSTFLAGS="-C target-feature=+crt-static -C strip=symbols" $LINK cargo build --target $(cat /uname-m)-unknown-linux-musl --release "$@"
mkdir -p /rust-bin
mv target/$(cat /uname-m)-unknown-linux-musl/release/"$BIN" /rust-bin/
