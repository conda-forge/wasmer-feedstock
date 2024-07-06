#!/usr/bin/env bash
# NOTE: mostly derived from https://github.com/conda-forge/py-spy-feedstock/blob/master/recipe/build.sh
set -o xtrace -o nounset -o pipefail -o errexit

export RUST_BACKTRACE=1
export LLVM_SYS_110_PREFIX=$PREFIX

export FEATURES="cranelift singlepass"

if [ $(uname) = Darwin ] ; then
  export RUSTFLAGS="-C link-args=-Wl,-rpath,${PREFIX}/lib"
else
  export FEATURES="$FEATURES llvm"
  export RUSTFLAGS="-C link-arg=-Wl,-rpath-link,${PREFIX}/lib -L${PREFIX}/lib"
fi

cd lib/cli

# build statically linked binary with Rust
cargo install \
  --locked \
  --root "$PREFIX" \
  --features "$FEATURES" \
  --jobs "$CPU_COUNT" \
  --path .

cargo-bundle-licenses \
  --format yaml \
  --output ${SRC_DIR}/THIRDPARTY.yml

# remove extra build files
rm -f "${PREFIX}/.crates2.json"
rm -f "${PREFIX}/.crates.toml"
