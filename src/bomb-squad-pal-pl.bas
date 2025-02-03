'''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''
''           Bomb Squad            ''
''         Polish Version          ''
''        Noah Burney 2025         ''
''                                 ''
''  For the Basic 10 Liner compo   ''
''                                 ''
'''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''

_bomb_data = 1+&"a0b2d1a2e1d0b2a0f1b2c1f0b0d2f1b2e1a0b2e0c1b0f1d2b2f1e0c2a1b0c1a0e2c0e2f1a1b0f2c3a2b3f0d1a1f3c2b0a2f1e3b0a0f2e3d1b1c0f3d2b1e0d2c3b1f0e2a3c0a3e1b2c1b2a0e3c3b2a1f0c0d2a1b3a0b1f4d2e3a1c0f3b4e2a1f4b0e3d2a4f2d1e3b0b2c0d3f4a1b0c4e2f1d3b3d0a2f1e4b2e0c4d3a1b"
MOVE 1+&"3e2d4c1f0c3a1f2e4b0c1b4d2a0e3c2b4e1f3a0a1e3b5d4c0f2a1e5b4f2c3d0a3f4d1e5b2c0a3f1e0c2b4d5b3a2c5f4d1e0b2c0e3a1d5f4b4c1f3d2e0a5b2e0a5c4f1d3b5f1a2d3e0c4b4f0e3a1d2c5c3b0d4a2f5e1c5b3d1f2a4e0",_bomb_data+249,183
DIM _labels(6)
DIM _bombs(384) BYTE ' (1 + 6 + 6) * 48

SETCOLOR -3,3,6 ' Red
SETCOLOR -4,0,10
SETCOLOR -2,0,0
' Sprinkling global variable declarations in for compactness
_debounce = 0
_stick = 0
SETCOLOR 4,0,6
SETCOLOR 1,0,0

POKE 752,1 ' Hide cursor

DATA _pf_colors() BYTE=""$00$00$00$00$84$00$34$00$34$00$B4$00$00$00$06$0F:_pf_colors(0)=$06
DATA _bg_colors() BYTE=""$06$06$06$06$06$06$06$06$06$06$06$06$06$06$06$0F:_bg_colors(0)=$06
_wire_colors = 1+&""$34$34$84$84$B4$B4

' Set up the DLI
DLI SET Z=_pf_colors INTO $D018, _bg_colors INTO $D01A

' Start the DLI
DLI Z

_dl_addr = DPEEK($230)
_screen_mem = DPEEK(_dl_addr+4)

POKE _dl_addr+2, $F0
POKE _dl_addr+3, $C2
MSET _dl_addr+6, 15, $82

' Draw stripes on initial wires
' MSET _screen_mem + 360, 40, 70
MSET _screen_mem + 360, 40, 15
POS.15,19:?COLOR(128) "BOMB SQUAD"

' International character set
' POKE 756,204

' Squeezing in more global variables for compactness
_ticks_remaining = 0
_tick_timer = 0

POS.12,23:?"Noah Burney 2025";

DATA _scissor() BYTE=""$63$35$1F$08$1F$35$63$80:_scissor(0)=$80
DATA _scissor_closed() BYTE=""$03$35$FE$FE$35$03$00$00:_scissor_closed(0)=$00
PMGRAPHICS 2
PMHPOS 0,132

PMHPOS 1,195
MSET PMADR(1)+22,4,$FF

PMHPOS 2,126

_labels(1)=&"czerw. w paski"
_labels(3)=&"nieb. w paski"
_labels(5)=&"ziel. w paski"
_labels(0)=&"czerwony"

'''''''''''''''''''''''''''''''''''''
' Variables for scissor sprite and cut overlay sprite
_pmadr0 = PMADR(0)+25
_pmadr2 = PMADR(2)+25

' Visible page of manual. Outside loop to leave same page open after explosion.
_pg = 0 


_labels(2)=&"niebieski"
_labels(4)=&"zielony"

'''''''''''''''''''''''''''''''''''''
' Unpack bomb data to simplify accessing elsewhere.
' In unpacked form, each bomb is represented by 13 bytes:
'   - 1 byte = number of wires
'   - 6 bytes = color of each wire
'   - 6 bytes = cut order of each wire
'
I=0
FOR _num_wires=3 TO 6
    FOR _bomb=0 TO 11
        _bombs(I) = _num_wires
        FOR _wire=0 TO _num_wires-1
            _bombs(I + 1 + _wire) = PEEK(_bomb_data) - 97
            _bombs(I + 7 + _wire) = PEEK(_bomb_data + 1) - 48
            _bomb_data = _bomb_data + 2
        NEXT _wire
        I = I + 13
    NEXT _bomb
NEXT


'''''''''''''''''''''''''''''''''''''
' NEW GAME
DO

_score = 0
_defused = 0
_min_bomb = 0
_bomb_offset = 0
_cut = 0
_to_cut = 0
_selected_wire = 0

'''''''''''''''''''''''''''''''''''''
' Main play loop
DO
    WHILE STRIG(0):WEND
    @_ChangePage 0
    @_PickBomb
    @_UpdateScore 0
    @_DrawBomb
    @_ResetTimer
    @_MoveScissors 0

    _trigger=0
    REPEAT
        @_tick
        _s = STICK(0)
        _t = STRIG(0)
        IF _t<>_trigger
            _trigger=_t
            IF _trigger=0 THEN @_CutWire
        ELIF _s<>_stick
            _debounce = 8
            _stick = _s
            IF _stick=11
                @_ChangePage -1
            ELIF _stick=7
                @_ChangePage 1
            ELIF _stick=14
                @_MoveScissors -1
            ELIF _stick=13
                @_MoveScissors 1
            ENDIF
        ELSE
            PAUSE
        ENDIF
        IF _debounce
            DEC _debounce
            IF _debounce=0 THEN _stick = -1
        ENDIF
    UNTIL _cut >= _to_cut

    IF _cut = 9 THEN EXIT ' GAME OVER
LOOP

LOOP

PROC _UpdateScore _pts
    _score = _score + _pts
    POS.0,0:PRINT _score;"    "
ENDPROC

PROC _ChangePage _diff
    _pg = (_pg + _diff) MOD 49
    if _pg < 0 then _pg = _pg + 49

    POS. 2, 17
    Y = 18

    ' Clear bottom 7 lines
    MSET _screen_mem + 680, 280, 0

    IF _pg
        _manual_bomb_offset = (_pg-1) * 13
        _manual_num_wires = _bombs(_manual_bomb_offset)

        
        PRINT "Nr ";_pg;" (";_manual_num_wires;" przewody)"

        IF _manual_num_wires < 6 THEN INC Y
        
        FOR W=0 TO _manual_num_wires-1
            POS. 2, Y + W
            PRINT $(_labels(_bombs(_manual_bomb_offset+1+W)));
            _order = _bombs(_manual_bomb_offset+7+W)
            POS. 17, Y + W
            IF _order THEN PRINT "- utnij ";_order;
        NEXT W
    ELSE
        ' PRINT "BOMB DEFUSAL MANUAL"
        PRINT "PRZEWODNIK PO BOMBACH"
    ENDIF
ENDPROC

PROC _ResetTimer
    _ticks_remaining = 26
    IF _defused > 20
        _ticks_remaining = _ticks_remaining - _defused + 5
        IF _ticks_remaining < 15 THEN _ticks_remaining = 15
    ELSE    
    ENDIF
    _tick_timer = 1
ENDPROC

PROC _MoveScissors _dir
    _selected_wire = _selected_wire + _dir
    IF _selected_wire < 0 THEN _selected_wire = _num_wires-1
    IF _selected_wire = _num_wires THEN _selected_wire = 0
    MSET _pmadr0, 48, 0
    IF _ticks_remaining THEN MOVE &_scissor,_pmadr0+_selected_wire*8,9
ENDPROC

PROC _PickBomb
    _bomb_num = _min_bomb + RAND(8)
    _bomb_offset = _bomb_num * 13
    _num_wires = _bombs(_bomb_offset)

    ' Set all wires to black by zeroing out colors used in DLI
    MSET &_pf_colors+1, 13, 0

    _to_cut = _num_wires - 1
    _cut = 0
ENDPROC

PROC _Defuse
    IF _min_bomb < 40
        _min_bomb = _min_bomb + 2
    ENDIF
    INC _defused
    @_UpdateScore 100
    FOR I=0 TO 2
        PAUSE 3
        SETCOLOR -3,11,6 ' Green
        SOUND 2,30,10,8
        PAUSE 2
        SETCOLOR -3,0,0 ' Black
        SOUND
    NEXT
ENDPROC

PROC _DrawBomb
    ' Clear 12 bomb lines of text
    MSET _screen_mem + 40, 480, 0
    ' Clear cuts by zeroing out sprite 2
    MSET _pmadr2, 48, 0
    
    FOR W=0 TO _num_wires-1
        _bomb = _bombs(_bomb_offset+1+W)
        POKE &_pf_colors+3+2*W, PEEK(_wire_colors + _bomb)
        ' Add stripes to odd number bombs by filling line with / character
        IF _bomb & 1 THEN MSET _screen_mem + 120 + W * 80, 40, 70
    NEXT
ENDPROC

PROC _CutWire
    _wire_offset = _selected_wire*8
    MSET _pmadr2+_wire_offset, 10, $FF
    SOUND 2,5,0,8
    MOVE &_scissor_closed,_pmadr0+_wire_offset,9
    PAUSE 3
    SOUND
    MOVE &_scissor,_pmadr0+_wire_offset,9
    
    _expected_order = _bombs(_bomb_offset+7+_selected_wire)
    INC _cut
    IF _expected_order > _cut OR _expected_order=0
        @_Boom
    ELIF _expected_order = _cut
        @_UpdateScore 10
        IF _cut = _to_cut
            @_Defuse
        ENDIF
    ELSE
        DEC _cut
    ENDIF
ENDPROC

PROC _Boom
    PMHPOS 2,0
    DLI
    FOR I=16 TO 1 STEP -1
        SOUND 1,100,0,I
        SETCOLOR 2,2,I
        SETCOLOR 4,2,I
        PAUSE 2
    NEXT
    SOUND
    SETCOLOR 2,0,0
    SETCOLOR 4,0,6
    DLI Z
    PMHPOS 2,126
    _cut = 9
ENDPROC

PROC _tick
    DEC _tick_timer
    IF _tick_timer = 0

        SETCOLOR -3,3,6 ' Red
        SOUND 0,120,14,8
        PAUSE 5
        SOUND
        SETCOLOR -3,0,0 ' Black
        
        DEC _ticks_remaining
        _tick_timer = 13
        FOR I=11 TO _ticks_remaining STEP 5
            _tick_timer = _tick_timer + _tick_timer
        NEXT
    ENDIF

    IF _ticks_remaining = 0 THEN @_Boom
ENDPROC