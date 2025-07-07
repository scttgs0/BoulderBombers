
@REM PATH=<path_to_64tass>;%PATH%

if not exist "obj\" md obj

@REM ----------------------------------

64tass.exe  --m65c02 ^
            --flat ^
            --nostart ^
            -D PGX=1 ^
            -o obj\bbombers.pgx ^
            --list=obj\bbombers.lst ^
            --labels=obj\bbombers.lbl ^
            boulderbombers.asm
