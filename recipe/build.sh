#!/usr/bin/env bash
# NOTE: mostly derived from https://github.com/conda-forge/py-spy-feedstock/blob/master/recipe/build.sh
set -o xtrace -o nounset -o pipefail -o errexit

export RUST_BACKTRACE=1

if [ $(uname) = Darwin ] ; then
  export RUSTFLAGS="-C link-args=-Wl,-rpath,${PREFIX}/lib"
else
  export RUSTFLAGS="-C link-arg=-Wl,-rpath-link,${PREFIX}/lib -L${PREFIX}/lib"
fi

# see https://github.com/wasmerio/wasmer/blob/master/PACKAGING.md
export WASMER_INSTALL_PREFIX=$PREFIX
export ENABLE_CRANELIFT=1
export ENABLE_LLVM=1
export ENABLE_SINGLEPASS=1
export DESTDIR=$PREFIX

make
make install

# dump licenses
cargo-bundle-licenses \
  --format yaml \
  --output ${SRC_DIR}/THIRDPARTY.yml

# remove extra build files
rm -f "${PREFIX}/.crates2.json"
rm -f "${PREFIX}/.crates.toml"
