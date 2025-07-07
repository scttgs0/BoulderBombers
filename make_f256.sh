
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
