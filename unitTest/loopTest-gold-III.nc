%
;   program:   loopTest
;              Zero Z: +.01
;
;             CAM: Fusion 360 CAM 2.0.1791
;        Document: Looping test part v5
;  Post Processor: Tormach 15LSlantPRO-1.1.10
;
;  ***LOCKED***  : Friday, January 22, 2016 5:41:45 PM
; 
;
;
;    **** PUT LATHE INTO GANG TOOL MODE ***
;
; Tool / Op list ..............................................................................
; -- tool: 1 Dorian MWLNR16-3C               Z : -0.7063                   CT: 00:00:12
;           op: face
;           op: profile
; -- tool: 21  #3 (.250) Center drill        Z : -0.12                     CT: 00:00:02
;           op: GANG:center drill
; -- tool: 22  .1495 [#25] CoHSS drill       Z : -0.6999                   CT: 00:00:20
;           op: GANG: drill through
; -- tool: 23 Vermont 10-32 2FL Spiral Tap   Z : -0.45                     CT: 00:00:07
;           op: GANG:tap 5/16-24
; -- tool: 18 Iscar DGRT-1616-2              Z : -0.712                    CT: 00:00:20
;           op: Part1
; -- tool: 26 Stock Transfer                 Z : -0.4                      CT: 00:00:13
;           op: Bar Puller
; 
; Approximate tool change time:  ................  :  00:01:42
; total cycle time ( with approx tool change time ):  00:02:56
;
G7
G18
G20
G54
G40
G90

G30
M0

;Loop Head..
o0100 REPEAT [32]

; ==============================================================
; Tool: 1 Dorian MWLNR16-3C Trigon face/turn - Steel, SST
; Time: 00:00:12
;    Z: -0.7063
;   Op: face
T0101
G96 S280 D1600 M3
G0 X-1.1125
Z0.2069 M8
G0 Z0.0606
G95 G1 X-0.4456 F0.004
X-0.3325 Z0.004
X0.0625 F0.005
X-0.0506 Z0.0606 F0.004
G0 X-1.1125
Z0.2069

; ..   ..   ..   ..   ..   ..   ..   ..   ..   ..   ..   ..   ..
;   Op: profile
; Time: 00:00:07
;    Z: -0.7063
G96 S280 D1600 M3
G0 X-0.4125 Z0.2069
X-0.4273
Z0.0568
G95 G1 X-0.3142 Z0.0003 F0.004
Z-0.0036 F0.005
G2 X-0.33 Z-0.0363 I0.0633 K-0.0326
G1 Z-0.7063
X-0.3317
X-0.4448 Z-0.6497 F0.004
G0 Z0.0609
X-0.4194
G1 X-0.4178 F0.005
X-0.3047 Z0.0043 F0.004
G2 X-0.3242 Z-0.0161 I0.0586 K-0.0406 F0.005
G1 X-0.4373 Z0.0404 F0.004
G0 Z0.0566
X-0.314
G1 X-0.1506 F0.005
X-0.0375 Z0. F0.004
X-0.1775 F0.005
G2 X-0.2217 Z-0.0092 I0. K-0.0312
G1 X-0.2317 Z-0.0142
G2 X-0.25 Z-0.0363 I0.0221 K-0.0221
G1 Z-0.7063
X-0.3631 Z-0.6497 F0.004
X-0.41 F0.005
G0 X-0.4125
Z0.2069
M9
M5

G30
M0

; ==============================================================
; Tool: 21  #3 (.250) Center drill 
; Time: 00:00:02
;    Z: -0.12
;   Op: GANG:center drill
T2121
G97 S1800 M3
G0 X0.
Z0.32 M8
G0 Z0.22
Z0.1
G94 G1 Z-0.03 F13.3333
G0 Z0.01
G1 Z-0.075 F13.3333
G0 Z-0.035
G1 Z-0.115 F13.3333
G0 Z-0.075
G1 Z-0.12 F13.3333
G0 Z0.32
M9
M5

; ...pull back to safe Z...
Z2.

; ==============================================================
; Tool: 22  .1495 [#25] CoHSS drill .1495 [#25] CoHSS drill
; Time: 00:00:20
;    Z: -0.6999
;   Op: GANG: drill through
T2222
G97 S1800 M3
G0 X0.
Z0.61 M8
G0 Z0.31
Z0.21
Z0.09
G94 G1 Z-0.07 F2.88
G0 Z0.21
Z0.01
G1 Z-0.145 F2.88
G0 Z0.21
Z-0.065
G1 Z-0.215 F2.88
G0 Z0.21
Z-0.135
G1 Z-0.28 F2.88
G0 Z0.21
Z-0.2
G1 Z-0.34 F2.88
G0 Z0.21
Z-0.26
G1 Z-0.4 F2.88
G0 Z0.21
Z-0.32
G1 Z-0.46 F2.88
G0 Z0.21
Z-0.38
G1 Z-0.52 F2.88
G0 Z0.21
Z-0.44
G1 Z-0.58 F2.88
G0 Z0.21
Z-0.5
G1 Z-0.64 F2.88
G0 Z0.21
Z-0.56
G1 Z-0.6999 F2.88
G0 Z0.31
Z0.61
M9
M5

; ...pull back to safe Z...
Z2.

; ==============================================================
; Tool: 23 Vermont 10-32 2FL Spiral Tap 10-32 2FL Spiral Tap
; Time: 00:00:07
;    Z: -0.45
;   Op: GANG:tap 5/16-24
T2323
G97 S450 M3
G0 X0.
Z0.65 M8
G33.1 Z-0.45 K0.0312
G0 Z0.65
M9
M5

G30
M0

; ==============================================================
; Tool: 18 Iscar DGRT-1616-2 steel
; Time: 00:00:20
;    Z: -0.712
;   Op: Part1
T1818
G96 S240 D1600 M3
G0 X-1.1125
Z0.2069 M8
G0 Z-0.712
G95 G1 X0.0024 F0.002
X-1.1125
G0 Z0.2069
M9
M5

G30
M0

; ==============================================================
; Tool: 26   
; Time: 00:00:13
;    Z: -0.4
;   Op: Bar Puller
T2626
G94
G0 X0.
G0 Z-0.25
G1 Z-0.4 F5
M64 P2
G4 P1
G1 Z-0.1
M65 P2
G4 P1
G0 Z1.


G30
M0

o0100 endrepeat

M30
%
