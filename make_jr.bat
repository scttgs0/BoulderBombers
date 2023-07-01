
@REM PATH=<path_to_64tass>;%PATH%

64tass.exe  --m65c02 ^
            --flat ^
            --nostart ^
            -o bbombJR.bin ^
            --list=bbombJR.lst ^
            --labels=bbombJR.lbl ^
            boulderbombers.asm
