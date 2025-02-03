POKE 752,1 ' Hide cursor

SETCOLOR 4,0,2
SETCOLOR 1,0,0
SETCOLOR -4,0,10

BG=$E2
' DATA H() BYTE=""$00$34$00$74$00$B4$00$E2$0F:h(0)=$00
DATA H() BYTE=""$00$34$00$84$00$B4$00$02$0F:h(0)=$00
DATA Q() BYTE=""$02$02$02$02$02$02$02$02$0F:Q(0)=$02
' DATA H() BYTE=""$00$34$00$72$00$B4$00$02$04$0D:h(0)=$00
' DATA Q() BYTE=""$04$04$04$04$04$04$04$04$04$0D:Q(0)=$04

' Set up the DLI
DLISET Z=H INTO $D018, Q INTO $D01A

' Start the DLI
DLI Z

POKE DPEEK($230)+2,$F0
POKE DPEEK($230)+6,$82
MSET DPEEK($230)+13,6,$82
MSET DPEEK($230)+20,2,$82


DATA _scissor() BYTE=$80,$63,$35,$1F,$08,$1F,$35,$63,$80
PMGRAPHICS 2
PMHPOS 0,140
MOVE &_scissor,PMADR(0)+40,9


PROC Wires
    FOR Y=8 TO 14
        ' POS. 0,Y:PRINT " "$06" "$06" "$06" "$06" "$06" "$06" "$06" "$06" ";
        POS. 0,Y:PRINT ""$16$06$06$06$06$06$06$06$06$06$06$06$06$06$06$06$06$06$06$06$06$06$06$06$06$06$06$06$06$06$06$06$06$06$06$06$06$06$06$02;
        ' POS. 0,Y:PRINT ""$08$88$08$88$08$88$08$88$08$88$08$88$08$88$08$88$08$88$08$88$08$88$08$88$08$88$08$88;
    NEXT
ENDPROC

PROC Book
    POS. 2,16:PRINT "BOMB DEFUSAL MANUAL";
ENDPROC

PROC Countdown
    ' POS. 0,0:PRINT COLOR(128) "                                        ";
    ' POS. 0,1:PRINT COLOR(128) " 20                                     ";
    ' POS. 1,1:PRINT COLOR(128) "20";

    delay = 150
    FOR C = 0 TO 10
        SOUND 0,120,14,8
        SOUND 1
        FOR D = 0 TO 10: PAUSE : NEXT
        SOUND
        FOR D = 0 TO delay: PAUSE : NEXT
        IF C = 5 THEN delay = 25
    NEXT
ENDPROC

PROC Explode
    DLI
    FOR I=16 TO 1 STEP -1
        SOUND 1,100,0,I
        SETCOLOR 2,2,I
        SETCOLOR 4,2,I
        PAUSE:PAUSE
    NEXT
    SOUND
    SETCOLOR 2,0,0
    SETCOLOR 4,0,2
    FOR I=0 TO 13:PAUSE:NEXT
    DLI Z
ENDPROC

@Book
@Wires

DO
    GET K
    @Countdown
    @Explode
LOOP