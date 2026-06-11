#!/usr/bin/env bash
#
# pubnub-go/mayhem/build.sh — build pubnub/go's go-fuzz libFuzzer target as a sanitized binary,
# replicating the old mayhemheroes integration (go-fuzz-build -libfuzzer + clang link).
#
# Harness: mayhem/fuzzPubnub.go — legacy `func Fuzz(data []byte) int` in package fuzzPubnub.
# Fuzzes pubnub token/permission parsing (GetPermissions, ParseToken, TokenManager.StoreToken).
#
# Produces:
#   /mayhem/pubnub-go — libFuzzer ELF (target name preserved from old Mayhemfile)
set -euo pipefail

[ -n "${SOURCE_DATE_EPOCH:-}" ] || unset SOURCE_DATE_EPOCH

: "${CC:=clang}" ; : "${CXX:=clang++}" ; : "${LIB_FUZZING_ENGINE:=-fsanitize=fuzzer}"
# OSS-Fuzz / go-fuzz Go path is ASAN-only for the libFuzzer link; keep ASan regardless of base default.
: "${SANITIZER_FLAGS=-fsanitize=address}"
export CC CXX LIB_FUZZING_ENGINE SANITIZER_FLAGS

export GOFLAGS="${GOFLAGS:--mod=mod}"
export GOTOOLCHAIN="${GOTOOLCHAIN:-local}"
export GOPATH="${GOPATH:-/home/mayhem/go}"
export GOCACHE="${GOCACHE:-/home/mayhem/.cache/go-build}"
export GOMODCACHE="${GOMODCACHE:-/root/go/pkg/mod}"
mkdir -p "$GOPATH" "$GOCACHE"
export PATH="/usr/local/go/bin:/root/go/bin:$GOPATH/bin:$PATH"

cd "$SRC"
go version

go mod tidy 2>&1 | tail -2 || true
go get github.com/dvyukov/go-fuzz/go-fuzz-dep 2>&1 | tail -2 || true

mkdir -p "$SRC/mayhem-build"

echo "=== building pubnub-go (fuzzPubnub.Fuzz, go-fuzz-build -libfuzzer) ==="
(
  cd "$SRC/mayhem"
  go-fuzz-build -libfuzzer -o "$SRC/mayhem-build/fuzzPubnub.a"
)
$CXX $SANITIZER_FLAGS $LIB_FUZZING_ENGINE "$SRC/mayhem-build/fuzzPubnub.a" -o /mayhem/pubnub-go
echo "built /mayhem/pubnub-go"

echo "build.sh complete:"
ls -la /mayhem/pubnub-go
