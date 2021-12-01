:: NOTE: mostly derived from
:: https://github.com/conda-forge/py-spy-feedstock/blob/master/recipe/bld.bat
@echo on

:: see https://github.com/wasmerio/wasmer/blob/master/PACKAGING.md
set WASMER_INSTALL_PREFIX=%PREFIX%
set ENABLE_CRANELIFT=1
set ENABLE_LLVM=1
set ENABLE_SINGLEPASS=1
set DESTDIR=%PREFIX%

:: build
make || goto :error
make install || goto :error

:: make script wrapper?
:: set WASMER_BIN=%PREFIX%\bin\wasmer.exe
::
:: :: move to scripts
:: dir %WASMER_BIN%
:: md %SCRIPTS% || echo "%SCRIPTS% already exists"
:: move %WASMER_BIN% %SCRIPTS% || goto :error

:: dump licenses
cargo-bundle-licenses ^
    --format yaml ^
    --output %SRC_DIR%\THIRDPARTY.yml ^
    || goto :error

:: remove extra build files
del /F /Q "%PREFIX%\.crates2.json"
del /F /Q "%PREFIX%\.crates.toml"

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit /b %errorlevel%
