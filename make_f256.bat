
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


@REM 64tass  --m65c02 ^
@REM         --flat ^
@REM         --nostart ^
@REM         -D PGX=0 ^
@REM         -o obj\bbombers.bin ^
@REM         --list=obj\bbombersB.lst ^
@REM         --labels=obj\bbombersB.lbl ^
@REM         boulderbombers.asm
