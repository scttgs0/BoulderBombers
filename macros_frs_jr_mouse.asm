
frsMouse_off    .macro
                stz MOUSE_PTR_CTRL
                .endmacro

frsMouse_on     .macro
                pha

                lda #1
                sta MOUSE_PTR_CTRL

                pla
                .endmacro
