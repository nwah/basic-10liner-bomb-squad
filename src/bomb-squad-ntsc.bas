'''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''
''           Bomb Squad            ''
''        Noah Burney 2025         ''
''                                 ''
''  For the Basic 10 Liner compo   ''
''                                 ''
'''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''

'''''''''''''''''''''''''''''''''''''
' Game Data
'
' First, the bomb "database". Each bomb consists of 3-6 wires.
' Letter is wire color, number is cut order. 12 3-wire bombs
' followed by 12 4-wire, 12 5-wire, and 12 6-wire.
'
_bomb_data = 1+&"a0b2d1a2e1d0b2a0f1b2c1f0b0d2f1b2e1a0b2e0c1b0f1d2b2f1e0c2a1b0c1a0e2c0e2f1a1b0f2c3a2b3f0d1a1f3c2b0a2f1e3b0a0f2e3d1b1c0f3d2b1e0d2c3b1f0e2a3c0a3e1b2c1b2a0e3c3b2a1f0c0d2a1b3a0b1f4d2e3a1c0f3b4e2a1f4b0e3d2a4f2d1e3b0b2c0d3f4a1b0c4e2f1d3b3d0a2f1e4b2e0c4d3a1b"
MOVE 1+&"3e2d4c1f0c3a1f2e4b0c1b4d2a0e3c2b4e1f3a0a1e3b5d4c0f2a1e5b4f2c3d0a3f4d1e5b2c0a3f1e0c2b4d5b3a2c5f4d1e0b2c0e3a1d5f4b4c1f3d2e0a5b2e0a5c4f1d3b5f1a2d3e0c4b4f0e3a1d2c5c3b0d4a2f5e1c5b3d1f2a4e0",_bomb_data+249,183

' Human-readable wire color names
DIM _labels(6)
' Unpacked/normalized bomb data
DIM _bombs(384) BYTE ' (1 + 6 + 6) * 48 bombs

''''''''''''''''''''''''''''''''''''''
' Initial graphics setup
'
' PMG colors
SETCOLOR -3,3,6  ' Red blinking light
SETCOLOR -4,0,10 ' Light-gray scissors
SETCOLOR -2,0,0  ' Black cut regions

' Global variables. Here for line-wrapping
_debounce = 0
_stick = 0

' Set background to medium gray
SETCOLOR 4,0,6
' Set text color to dark
SETCOLOR 1,0,0
' Hide cursor
POKE 752,1

''''''''''''''''''''''''''''''''''''''
' DLI colors.
'
' DATA x() BYTE=""$02 is a compact way to initialize bytes. x(0)=$01 is a workaround for
' FastBasic storing the length of the string in the first byte.
'
' Playfield is used for wire colors on top; white page on bottom
DATA _pf_colors() BYTE=""$00$00$00$00$84$00$34$00$34$00$B4$00$00$00$06$0F:_pf_colors(0)=$06
' Background colors are gray at top and white page on bottom
DATA _bg_colors() BYTE=""$06$06$06$06$06$06$06$06$06$06$06$06$06$06$06$0F:_bg_colors(0)=$06

' Shortcut for wire colors: red, red-stripe, green, green-stripe, blue, blue-stripe
_wire_colors = 1+&""$34$34$84$84$B4$B4

' Set up the color DLI
DLI SET Z=_pf_colors INTO $D018, _bg_colors INTO $D01A

' Start the DLI
DLI Z

' Shortcut for display list address and screen memory for graphics 0 text
_dl_addr = DPEEK($230)
_screen_mem = DPEEK(_dl_addr+4)

' DLI on last 8-blank-line instruction
POKE _dl_addr+2, $F0
' DLI on first graphics 0 line
POKE _dl_addr+3, $C2
' DLI on every line of top section to alternate between wire and background
MSET _dl_addr+6, 15, $82


'''''''''''''''''''''''''''''''''
' Title screen
'
' Draw stripes on initial wires
MSET _screen_mem + 360, 40, 70
POS.14,19:?COLOR(128) " BOMB SQUAD "
' --------------
' Squeezing in more global variables for compactness
_ticks_remaining = 0
_tick_timer = 0
' -------------
POS.12,23:?"Noah Burney 2025";


''''''''''''''''''''''''''''''''
' P/M Graphics Setup
'
DATA _scissor() BYTE=""$63$35$1F$08$1F$35$63$80:_scissor(0)=$80
DATA _scissor_closed() BYTE=""$03$35$FE$FE$35$03$00$00:_scissor_closed(0)=$00
PMGRAPHICS 2 ' Use double-line sprites
PMHPOS 0,132 ' Move scissors to middle of screen

PMHPOS 1,195 ' Move blinking light to right of screen
MSET PMADR(1)+22,4,$FF ' Fill a 4px tall rectangle

PMHPOS 2,126 ' Move black strip used for cuts to middle

''''''''''''''''''''''''''''''''''''''
' Wire labels
'
' &"foo" returns memory address of string literal. We read the memory locations
' later when rendering the manual
_labels(0)=&"Red" : _labels(1)=&"Red striped"
_labels(2)=&"Blue" : _labels(3)=&"Blue striped"
_labels(4)=&"Green" : _labels(5)=&"Green striped"

'''''''''''''''''''''''''''''''''''''
' Unpack bomb data to simplify accessing elsewhere.
' In unpacked form, each bomb is represented by 13 bytes:
'   - 1 byte = number of wires
'   - 6 bytes = color of each wire
'   - 6 bytes = cut order of each wire
' Stored in plain text with 2 bytes per wire because it was less
' code to unpack it than a more compressed binary format.
I=0
FOR _num_wires=3 TO 6
    FOR _bomb=0 TO 11
        _bombs(I) = _num_wires
        FOR _wire=0 TO _num_wires-1
            ' Convert wire color from 'a'-'f' to 0-5. 'a' is 97 in ATASCII
            _bombs(I + 1 + _wire) = PEEK(_bomb_data) - 97
            ' Convert cut order form '0'-'5' to 0-5. '0' is 48 in ATASCII
            _bombs(I + 7 + _wire) = PEEK(_bomb_data + 1) - 48
            _bomb_data = _bomb_data + 2
        NEXT _wire
        I = I + 13
    NEXT _bomb
NEXT

'''''''''''''''''''''''''''''''''''''
' Variables for scissor sprite and cut overlay sprite
_pmadr0 = PMADR(0)+25
_pmadr2 = PMADR(2)+25

' Visible page of manual. Outside game loop to leave same page open after explosion.
_pg = 0 

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
' Main play loop. Once per bomb.
DO
    WHILE STRIG(0):WEND ' Wait for trigger press
    @_ChangePage 0      ' Force manual to render
    @_PickBomb          ' Randomly pick a bom
    @_UpdateScore 0     ' Force score to render
    @_DrawBomb          ' Draw wires
    @_ResetTimer        ' Start timer
    @_MoveScissors 0    ' Force scissors to render

    _trigger=0

    ' Continually tick / check for joystick
    REPEAT
        @_tick
        _s = STICK(0)
        _t = STRIG(0)
        ' Allow holding down joystick to move between
        ' pages and/or wires
        IF _debounce
            DEC _debounce
            IF _debounce=0 THEN _s = -1
        ENDIF
        IF _t<>_trigger
            _trigger=_t
            IF _trigger=0 THEN @_CutWire
        ELIF _s<>_stick
            _debounce = 8
            _stick = _s
            IF _stick=11   ' Left
                @_ChangePage -1
            ELIF _stick=7  ' Right
                @_ChangePage 1
            ELIF _stick=14 ' Up
                @_MoveScissors -1
            ELIF _stick=13 ' Down
                @_MoveScissors 1
            ENDIF
        ELSE
            PAUSE
        ENDIF
    ' Break loop when cut wires reaches target number or
    ' is set to 9 indicating incorrect cut
    UNTIL _cut >= _to_cut 

    IF _cut = 9 THEN EXIT ' GAME OVER
LOOP ' End play loop. Continues to next bomb.

LOOP ' End game loop

PROC _UpdateScore _pts
    _score = _score + _pts
    POS.0,0:PRINT _score;"    "
ENDPROC

PROC _ChangePage _diff
    ' This is slightly shorter than adding the page difference
    ' and then having checks for > than max page and < 0
    _pg = (_pg + _diff) MOD 49
    if _pg < 0 then _pg = _pg + 49

    ' Clear bottom 7 lines
    MSET _screen_mem + 680, 280, 0

    ' If not on page 0, i.e. title page
    IF _pg
        _manual_bomb_offset = (_pg-1) * 13
        _manual_num_wires = _bombs(_manual_bomb_offset)

        POS. 2, 17
        PRINT "Bomb ";_pg;" (";_manual_num_wires;" wires)"

        Y = 18
        IF _manual_num_wires < 6 THEN INC Y
        
        FOR W=0 TO _manual_num_wires-1
            POS. 2, Y + W
            ' $() returns a string from a given memory address, so this retrieves
            ' appropriate label given the wire color 0-5
            PRINT $(_labels(_bombs(_manual_bomb_offset+1+W)));
            _order = _bombs(_manual_bomb_offset+7+W)
            POS. 15, Y + W
            ' wire 0 is the one that's not cut, so don't print cut #
            IF _order THEN PRINT " - cut #";_order;
        NEXT W
    ' Page 0, render title page
    ELSE
        POS. 2, 18
        PRINT "BOMB DEFUSAL MANUAL"
    ENDIF
ENDPROC

PROC _PickBomb
    ' Sliding window of 8 possible bottoms, starting from 0 and increasing
    ' with the difficulty to larger bombs
    _bomb_num = _min_bomb + RAND(8)
    _bomb_offset = _bomb_num * 13
    _num_wires = _bombs(_bomb_offset)

    ' Set all wires to black by zeroing out colors used in DLI
    MSET &_pf_colors+1, 13, 0

    _to_cut = _num_wires - 1
    _cut = 0
ENDPROC

PROC _MoveScissors _dir
    _selected_wire = _selected_wire + _dir
    IF _selected_wire < 0 THEN _selected_wire = _num_wires-1
    IF _selected_wire = _num_wires THEN _selected_wire = 0
    ' Clear area that scissors move in. Clearing larger area than necessary
    ' to reduce code size. Also serves to hide scissors between games.
    MSET _pmadr0, 48, 0
    ' Only draw scissors when currently ticking down
    IF _ticks_remaining THEN MOVE &_scissor,_pmadr0+_selected_wire*8,9
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
    ' Draw a black box on top currently selected wire to indicate it's been cut
    MSET _pmadr2+_wire_offset, 10, $FF
    ' Start light buzz sound for cut sound effect
    SOUND 2,5,0,8
    ' Draw closed scissors
    MOVE &_scissor_closed,_pmadr0+_wire_offset,9
    ' Wait 1 frame
    PAUSE
    ' Turn off sound
    SOUND
    ' Wait 3 frames
    PAUSE 3
    ' Restore open scissors sprite
    MOVE &_scissor,_pmadr0+_wire_offset,9
    
    _expected_order = _bombs(_bomb_offset+7+_selected_wire)
    ' Increment # of wires cut so far. We skip wire 0, so first cut
    ' will end up being 1.
    INC _cut
    ' If you skipped ahead, or cut the non-cuttable wire, boom
    IF _expected_order > _cut OR _expected_order=0
        @_Boom
    ' If you cut correct wire
    ELIF _expected_order = _cut
        @_UpdateScore 10
        IF _cut = _to_cut
            @_Defuse
        ENDIF
    ' If you cut a wire that you already cut, ignore, but set
    ' # of wires actually cut back to correct number
    ELSE
        DEC _cut
    ENDIF
ENDPROC

PROC _Boom
    ' Move "cuts" off screen
    PMHPOS 2,0
    ' Turn off background color changes
    DLI
    ' Explosion animation + sound effect
    FOR I=16 TO 1 STEP -1
        ' Start loud noise and taper off
        SOUND 1,100,0,I
        ' Start with bright orange and fade to black
        SETCOLOR 2,2,I
        SETCOLOR 4,2,I
        ' Wait 2 frames per animation step
        PAUSE 2
    NEXT
    ' Turn sound off
    SOUND
    ' Restore default background and playfield colors
    SETCOLOR 2,0,0
    SETCOLOR 4,0,6
    ' Re-enable background color change DLI
    DLI Z
    ' Move "cuts" sprite strip back into position
    PMHPOS 2,126
    ' Set # of cut wires to 9 to indicate game over
    _cut = 9
ENDPROC

PROC _Defuse
    IF _min_bomb < 40
        _min_bomb = _min_bomb + 2
    ENDIF
    INC _defused
    @_UpdateScore 100

    ' Flash light green and play beep
    FOR I=0 TO 2
        PAUSE 3
        SETCOLOR -3,11,6 ' Green
        SOUND 2,30,10,8
        PAUSE 2
        SETCOLOR -3,0,0 ' Black
        SOUND
    NEXT
ENDPROC

PROC _ResetTimer
    ' Set number of "beeps" until bomb explodes. Set to 1 higher than true number
    ' so the initial @_tick will beep
    _ticks_remaining = 26
    ' Gradually decrease total number of ticks after 20th round
    IF _defused > 20
        _ticks_remaining = _ticks_remaining - _defused + 5
        IF _ticks_remaining < 15 THEN _ticks_remaining = 15
    ELSE    
    ENDIF
    ' Set tick timer to 1 so that initial @_tick will go to zero
    _tick_timer = 1
ENDPROC

PROC _tick
    ' Because _tick_timer is initialized to 1, initial decrement sets it to 0
    ' and causes an initial beep
    DEC _tick_timer
    IF _tick_timer = 0

        ' Flash light red and play beep
        SETCOLOR -3,3,6 ' Red
        SOUND 0,120,14,8
        PAUSE 5
        SOUND
        SETCOLOR -3,0,0 ' Black
        
        DEC _ticks_remaining
        ' Start ticks at 2 seconds apart, then gradually speed up to 0.25s.
        _tick_timer = 15
        FOR I=11 TO _ticks_remaining STEP 5
            _tick_timer = _tick_timer + _tick_timer
        NEXT
    ENDIF

    IF _ticks_remaining = 0 THEN @_Boom
ENDPROC