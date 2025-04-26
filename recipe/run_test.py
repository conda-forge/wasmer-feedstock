# TODO: test engines?
# TODO: test compile?
# TODO: test exe?
# - WASMER_DIR=$PREFIX wasmer create-exe --{{ backend }} {{ test_wasm }} -o ./hello-{{ backend }}
# - ./hello-{{ backend }}
# - ./hello-{{ backend }} | grep '{{ test_text }}'

import sys
from subprocess import check_output, call

import pytest

TEST_WASM = "tests/wasi-wast/wasi/snapshot1/hello.wasm"

TEST_TEXT = b"Hello, world!"


@pytest.fixture(
    params=["cranelift", *(["llvm"] if "linux" in sys.platform else [])]
)
def a_backend(request) -> str:
    return request.param


def test_wasmer_run(a_backend: str) -> None:
    result = check_output(["wasmer", "run", f"--{a_backend}", TEST_WASM])
    assert TEST_TEXT in result


def test_wasmer_validate(a_backend: str) -> None:
    rc = call(["wasmer", "validate", f"--{a_backend}", TEST_WASM])
    assert not rc


if __name__ == "__main__":
    sys.exit(pytest.main(["-vv", "--color=yes", "--tb=long", __file__]))
