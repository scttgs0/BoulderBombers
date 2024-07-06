
mkdir -p obj/

# -------------------------------------

64tass  --m65c02 \
        --flat \
        --nostart \
        -o obj/bbombers.pgx \
        --list=obj/bbombers.lst \
        --labels=obj/bbombers.lbl \
        boulderbombers.asm
