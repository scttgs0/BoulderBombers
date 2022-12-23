
m8i8            .macro
                sep #$30
                .as
                .xs
                .endmacro

m8i16           .macro
                sep #$20
                .as
                rep #$10
                .xl
                .endmacro

m16i8           .macro
                rep #$20
                .al
                sep #$10
                .xs
                .endmacro

m16i16          .macro
                rep #$30
                .al
                .xl
                .endmacro

m8              .macro
                sep #$20
                .as
                .endmacro

m16             .macro
                rep #$20
                .al
                .endmacro

i8              .macro
                sep #$10
                .xs
                .endmacro

i16             .macro
                rep #$10
                .xl
                .endmacro

setdp           .macro
                php

                .m16
                pha

                lda @w #\1
                tcd
                .dpage \1

                pla

                .m8
                plp
                .endmacro

setbank         .macro
                php

                .m8
                pha

                lda #\1
                pha
                plb
                .databank \1

                pla
                plp
                .endmacro

mult7           .macro
                sta zpTemp1             ; *1
                asl A
                sta zpTemp2             ; *2

                asl A                   ; *4
                clc
                adc zpTemp2             ; *6
                clc
                adc zpTemp1             ; *7
                .endmacro
