md modelsim

REM vsim -c -do "do ../msim_compil.tcl; quit -f"

REM if exist modelsim\ (
cd modelsim
modelsim -do "source ../msim_compil.tcl"
echo Starting Modelsim
REM ) else (
  REM echo Start msim_compil first
REM )


pause