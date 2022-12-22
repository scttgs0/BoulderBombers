
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
