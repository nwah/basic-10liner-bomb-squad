' Available Bombs
'
' Format:
'   a = red, b = red striped, c = blue, d = blue striped, e = green, f = green striped
'
' Counts:
'   15 x 3-wire bombs 
'   15 x 4-wire bombs
'   15 x 5-wire bombs
'   15 x 6-wire bombs
'
' _bombs = 1+&"aebaecafbafdbadbcdbedcaecbfcdacdfdacdafdecdefabdcabefacebacfbaedfbacebcafbedcbfedcbafcefdcfbacfbecfeadaefabdfcacfdbaedcfaefcbaefdcbcafebdefabfcadbfcedbfdacbfdcacabdecbfdecebfdcfeadacebdfacfedbafdbecbacdefbaefcdbcfedabdeafcbdefcabdfcaebfcadecadfebcaefdbcfa"
' MOVE 1+&"abedbecfadecbaf",_bombs+255,30

' _bombs = 1+&"a2b1e0b1a2e0b2a0f1b0f1a2c2b1a0c1b0d2c2f0a1c0f1d2d2a1c0d1b2c0d1c2a0d2c1b0d0c1f2d0e1b2d1e2c0a0b2c3f1a0b2d1e3a0c1f3e2a0d3f1c2a0d2f3e1a1f3b2c0b1c2e3f0b1d2a3f0b1d0f2c3c3a0e2b1c3b1f0e2c0d1e2f3c2e3b0a1c3f0e1d2d1a3e2f0a2d4e3b0f1a3e1b4c2d0a2e0c4f3d1"
' MOVE 1+&"a1e0f2b4d3a4f2b3d0c1a4f1d2e0b3a3f0e2d1c4b1d4a2f3e0b0d2e1a3f4b1d0e4f3a2b4e3f1c0a2b3f1e2d4a0c0b2d3e1f4c1d2f4b3a0d2a1c4b3e0a0b3f1c2d4e5a4d0e2b3c1f5a0d5f2c4b1e3a4e5f3c1d2b0b2a4e3c0f5d1b3a4f1e0d5c2b2d5f4e1c0a3b2f5d3c4e1a0b5f0e3c2a1d4",_bombs+240,228
' MOVE 1+&"c3d0e5a2f4b1c4e0b2a5d1f3c3e0f5a1d2b4d5b3e4a0c1f2d1b0f3c2a4e5d2c3f0e5a4b1",_bombs+468,72

' Counts:
'   12 x 3-wire bombs 
'   12 x 4-wire bombs
'   12 x 5-wire bombs
'   12 x 6-wire bombs

SETCOLOR 4,0,2
POS.0,0:?COLOR(128)"12"

_bomb_data = 1+&"a0b2d1a2e1d0b2a0f1b2c1f0b0d2f1b2e1a0b2e0c1b0f1d2b2f1e0c2a1b0c1a0e2c0e2f1a1b0f2c3a2b3f0d1a1f3c2b0a2f1e3b0a0f2e3d1b1c0f3d2b1e0d2c3b1f0e2a3c0a3e1b2c1b2a0e3c3b2a1f0c0d2a1b3a0b1f4d2e3a1c0f3b4e2a1f4b0e3d2a4f2d1e3b0b2c0d3f4a1b0c4e2f1d3b3d0a2f1e4b2e0"
MOVE 1+&"c4d3a1b3e2d4c1f0c3a1f2e4b0c1b4d2a0e3c2b4e1f3a0a1e3b5d4c0f2a1e5b4f2c3d0a3f4d1e5b2c0a3f1e0c2b4d5b3a2c5f4d1e0b2c0e3a1d5f4b4c1f3d2e0a5b2e0a5c4f1d3b5f1a2d3e0c4b4f0e3a1d2c5c3b0d4a2f5e1c5b3d1f2a4e0",_bomb_data+242,190
DIM _bombs((1 + 6 + 6) * 48) BYTE

POKE 752,1 ' Hide cursor

I=0
FOR _num_wires=3 TO 6
    FOR _bomb=0 TO 11
        _bombs(I) = _num_wires
        FOR _wire=0 TO _num_wires-1
            _bombs(I + 1 + _wire) = PEEK(_bomb_data) - 97
            _bombs(I + 1 + 6 + _wire) = PEEK(_bomb_data + 1) - 48
            _bomb_data = _bomb_data + 2
        NEXT _wire
        I = I + 13
    NEXT _bomb
NEXT _num_wires

DIM _labels(6) WORD:_labels(0)=&"Red":_labels(1)=&"Red striped":_labels(2)=&"Blue":_labels(3)=&"Blue striped":_labels(4)=&"Green":_labels(5)=&"Green striped"

_pg = 0
_selected_wire = 0
_bomb_offset = 0
_cut = 0
_to_cut = 0
_min_bomb = 0
_ticks_remaining = 0
_tick_timer = 0

PROC _ChangePage diff
    _pg = _pg + diff
    if _pg < 0 then _pg = 47
    if _pg = 48 then _pg = 0

    _manual_bomb_offset = _pg * 13
    _manual_num_wires = _bombs(_manual_bomb_offset)

    POS. 2, 16
    PRINT "Bomb #";_pg;"; ";_manual_num_wires;" wires"
    
    POS. 2, 17
    FOR W=0 TO 5
        IF W < _manual_num_wires
            PRINT $(_labels(_bombs(_manual_bomb_offset+1+W))),_bombs(_manual_bomb_offset+7+W);"            "
        ELSE
            PRINT "             "
        ENDIF
    NEXT W
ENDPROC

PROC _PickBomb
    _to_cut = 2
    _cut = 0
    _bomb_num = _min_bomb + RAND(8)
    ' _num_wires = 2 + _bomb_num / 12
    _bomb_offset = _bomb_num * 13
    _num_wires = _bombs(_bomb_offset)
ENDPROC

PROC _MoveScissors _dir
    POS. 18, 4+_selected_wire*2 : ? " "
    _selected_wire = _selected_wire + _dir
    IF _selected_wire < 0 THEN _selected_wire = _num_wires-1
    IF _selected_wire = _num_wires THEN _selected_wire = 0
    POS. 18, 4+_selected_wire*2 : ? "<"
ENDPROC

PROC _DrawBomb
    POS.0,0: ?_cut,_to_cut,_num_wires,_bomb_num;
    FOR W=0 TO 5
        POS. 2, 4 + W*2
        ' PRINT $(_labels(_bombs(_bomb_offset+1+W)));" ";_bombs(_bomb_offset+7+W);"            ";
        IF W < _num_wires
            PRINT $(_labels(_bombs(_bomb_offset+1+W)));"            ";
        ELSE
            PRINT "                     ";
        ENDIF
    NEXT
ENDPROC

PROC _CutWire
    _expected_order = _bombs(_bomb_offset+7+_selected_wire)
    IF _cut <> _expected_order
        @_Boom
    ELSE
        INC _cut
        POS.0,0: ?_cut,_to_cut,_num_wires,_bomb_num;
        POS. 2, 4 + _selected_wire*2 : ? "/";
        IF _cut = _to_cut
            @_Defuse
        ENDIF
    ENDIF
ENDPROC

PROC _Boom
    CLS
    PRINT "BOOM"
    FOR I=16 TO 1 STEP -1
        SOUND 1,100,0,I
        PAUSE 2
    NEXT
    SOUND
    _cut = 99
    GET K
ENDPROC

PROC _Defuse
    INC _defused
    
    POS. 24,0:?"Heyo! ";_defused;
    
    if _min_bomb < 36 then _min_bomb = _min_bomb + 2
ENDPROC

PROC _ResetTimer
    _ticks_remaining = 26
    _tick_timer = 1
ENDPROC

PROC _tick
    DEC _tick_timer
    IF _tick_timer = 0

        SOUND 0,120,14,8
        PAUSE 10
        SOUND

        POS. 38,12:?_ticks_remaining;" ";
        
        DEC _ticks_remaining
        IF _ticks_remaining > 20
            _tick_timer = 120
        ELIF _ticks_remaining > 15
            _tick_timer = 60
        ELIF _ticks_remaining > 10
            _tick_timer = 30
        ELSE
            _tick_timer = 15
        ENDIF
    ENDIF

    IF _ticks_remaining = 0 THEN @_Boom
ENDPROC

' NEW GAME
DO

_defused = 0
_min_bomb = 0
_pg = 0
_selected_wire = 0
_stick = 0

@_ChangePage 0
@_MoveScissors 0

' Main play loop
DO
    @_PickBomb
    REPEAT:UNTIL STRIG(0)=0  
    @_DrawBomb
    @_ResetTimer

    _trigger=0
    REPEAT
        IF STRIG(0)<>_trigger
            _trigger=STRIG(0)
            IF _trigger=0 THEN @_CutWire
        ELIF STICK(0)<>_stick
            _stick = STICK(0)
            IF _stick=11
                @_ChangePage -1
            ELIF _stick=7
                @_ChangePage 1
            ELIF _stick=14
                @_MoveScissors -1
            ELIF _stick=13
                @_MoveScissors 1
            ENDIF
        ENDIF

        @_tick

        PAUSE
    UNTIL _cut >= _to_cut

    IF _cut = 99 THEN EXIT ' GAME OVER
LOOP

LOOP