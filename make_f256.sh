
mkdir -p obj/

# -------------------------------------

64tass  --m65c02 \
        --flat \
        --nostart \
        -D PGX=1 \
        -o obj/bbombers.pgx \
        --list=obj/bbombers.lst \
        --labels=obj/bbombers.lbl \
        boulderbombers.asm


64tass  --m65c02 \
        --flat \
        --nostart \
        -D PGX=0 \
        -o obj/bbombers.bin \
        --list=obj/bbombersB.lst \
        --labels=obj/bbombersB.lbl \
        boulderbombers.asm
