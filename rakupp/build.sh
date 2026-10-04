#!/usr/bin/env bash
# Build a standalone jmp with Raku++ (rakupp): fetch Terminal::UI, apply the
# patches Raku++ 4.0.1 needs, install the dependencies into the Raku++ store
# (~/.raku, shared with zef), then compile bin/jmp with --aot --standalone.
#
# Usage: rakupp/build.sh [output]      (default: build/jmp)
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
out="${1:-$repo_root/build/jmp}"
tui_url='https://360.zef.pm/T/ER/TERMINAL_UI/97be0392703c0ef562b9092d0a52c2623157131c.tar.gz'   # Terminal::UI 0.1.14

command -v rakupp >/dev/null || { echo "rakupp not found on PATH: https://github.com/ash/rakupp" >&2; exit 1; }
echo "using $(rakupp --version | head -1)"

# dependencies that need no patch; --no-test where a module's own suite
# trips on a Raku++ difference that does not affect jmp
rakupp install -q JSON::Tiny OO::Monitors Terminal::ANSI
rakupp install -q --no-test Log::Async Terminal::ANSIParser

# Terminal::UI, patched for Raku++
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
curl -sSL "$tui_url" | tar xz -C "$work" --strip-components=1
python3 "$repo_root/rakupp/patch-terminal-ui.py" "$work"
( cd "$work" && rakupp install -q --no-test --force . )

# compile: static libstdc++ so the Linux file needs only libc and libm
mkdir -p "$(dirname "$out")"
case "$(uname -s)" in
    Linux)  export CXX="${CXX:-c++ -static-libstdc++ -static-libgcc}" ;;
    Darwin) export CXX="${CXX:-c++ -arch arm64 -arch x86_64 -mmacosx-version-min=11.0}" ;;
esac
rakupp -I "$repo_root/lib" --aot --standalone "$repo_root/bin/jmp" -o "$out"
"$out" version
