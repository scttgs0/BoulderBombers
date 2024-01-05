
mkdir -p obj/

# -------------------------------------

64tass  --m65xx \
        --atari-xex \
        -o obj/boulderbombers.xex \
        --list=obj/boulderbombers.lst \
        --labels=obj/boulderbombers.lbl \
        boulderbombers.asm
