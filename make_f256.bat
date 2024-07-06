
@REM PATH=<path_to_64tass>;%PATH%

if not exist "obj\" md obj

@REM ----------------------------------

64tass.exe  --m65c02 ^
            --flat ^
            --nostart ^
            -o obj\bbombers.bin ^
            --list=obj\bbombers.lst ^
            --labels=obj\bbombers.lbl ^
            boulderbombers.asm
