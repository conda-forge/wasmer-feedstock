# TODO: test engines?
# TODO: test compile?
# TODO: test exe?
# - WASMER_DIR=$PREFIX wasmer create-exe --{{ backend }} {{ test_wasm }} -o ./hello-{{ backend }}
# - ./hello-{{ backend }}
# - ./hello-{{ backend }} | grep '{{ test_text }}'

import os
import sys
from subprocess import check_output, call

import pytest

IS_LINUX = "linux" in sys.platform
COWSAY_WASM = os.environ["COWSAY_WASM"]
TEST_TEXT = "{PKG_NAME} {PKG_VERSION}".format(**os.environ)


@pytest.fixture(params=["singlepass", "cranelift", "llvm"])
def a_backend(request) -> str:
    if request.param == "llvm" and not IS_LINUX:
        pytest.skip(f"not testing on {sys.platform}")
    return request.param


def test_wasmer_run(a_backend: str) -> None:
    args = ["wasmer", "run", f"--{a_backend}", COWSAY_WASM, TEST_TEXT]
    result = check_output(args, encoding="utf-8")
    print(result)
    assert TEST_TEXT in result


def test_wasmer_validate(a_backend: str) -> None:
    rc = call(["wasmer", "validate", f"--{a_backend}", COWSAY_WASM])
    assert not rc


def test_wasmer_version() -> None:
    result = check_output(["wasmer", "--version"], encoding="utf-8")
    assert os.environ["PKG_VERSION"] in result


if __name__ == "__main__":
    sys.exit(pytest.main(["-vv", "--color=yes", "--tb=long", __file__]))
