#!/usr/bin/env bash
# NOTE: mostly derived from https://github.com/conda-forge/py-spy-feedstock/blob/master/recipe/build.sh
set -o xtrace -o nounset -o pipefail -o errexit

export RUST_BACKTRACE=1
export LLVM_SYS_110_PREFIX=$PREFIX

export FEATURES="cranelift singlepass"

export MAKE_OPTS="ENABLE_CRANELIFT=1 WASMER_INSTALL_PREFIX=${PREFIX}"

if [ $(uname) = Darwin ] ; then
  export RUSTFLAGS="-C link-args=-Wl,-rpath,${PREFIX}/lib"
  export MAKE_OPTS="$MAKE_OPTS ENABLE_LLVM=0"
else
  export RUSTFLAGS="-C link-arg=-Wl,-rpath-link,${PREFIX}/lib -L${PREFIX}/lib"
  export MAKE_OPTS="$MAKE_OPTS ENABLE_LLVM=1"
fi

# build statically linked binary with Rust
make $MAKE_OPTS

cargo-bundle-licenses \
  --format yaml \
  --output ${SRC_DIR}/THIRDPARTY.yml

# remove extra build files
rm -f "${PREFIX}/.crates2.json"
rm -f "${PREFIX}/.crates.toml"
