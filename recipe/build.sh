#!/usr/bin/env bash
# NOTE: mostly derived from https://github.com/conda-forge/py-spy-feedstock/blob/master/recipe/build.sh
set -o xtrace -o nounset -o pipefail -o errexit

export RUST_BACKTRACE=1

export FEATURES="cranelift singlepass"

if [[ "$(uname)" == "Darwin" ]]; then
  export RUSTFLAGS="-C link-args=-Wl,-rpath,${PREFIX}/lib"
  # Fix headerpad-max-install-error
  # install_name_tool: changing install names or rpaths can't be redone for
  #  (for architecture x86_64) because larger updated load commands do not fit (the program must be relinked, and you may need to use -headerpad or -headerpad_max_install_names)
  export SONAME="-Wl,-install_name,@rpath/"
  export LDFLAGS="${LDFLAGS} -headerpad_max_install_names"
else
  export LLVM_ENABLE=1
  export LLVM_SYS_180_PREFIX=$PREFIX
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
