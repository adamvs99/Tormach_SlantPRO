%
;   program:   WarningsTest
;              Zero Z: 0
;
;             CAM: Fusion 360 CAM 2.0.1791
;        Document: Warnings Test v8
;  Post Processor: Tormach 15LSlantPRO-1.1.10
;
;  ***LOCKED***  : Friday, January 22, 2016 4:58:14 PM
; 
;
;
;    **** PUT LATHE INTO GANG TOOL MODE ***
;
; Tool / Op list ..............................................................................
; -- tool: 21  M4 #3 (.250) Center drill           Z : -0.12                     CT: 00:00:02
;           op: GANG:M4:center drill
; -- tool: 22 YG-1 .272 [#I] CoHSS stub drill      Z : -0.902                    CT: 00:00:21
;           op: GANG: tap drill small hole
; -- tool: 23 YG-1 .375 CoHSS stub drill           Z : -0.3998                   CT: 00:00:14
;           op: GANG: tap dill large hole
; -- tool: 11 US Shop Tools Mini Boring Bar .208   Z : -0.4174    X : -0.008     CT: 00:00:20
;           op: QCTP:inner bore
; -- tool: 23 Sowa 5/16-24 H3 HSS-PM               Z : -0.9003                   CT: 00:00:01
;           op: GANG:tap LH 5/16-24
; -- tool: 24 YG-1 1/2-13 LH P-HSS spiral tap      Z : -0.4798                   CT: 00:00:04
;           op: GANG:tap LH 1/2-13 (2)
; 
; Approximate tool change time:  ................  :  00:00:57
; total cycle time ( with approx tool change time ):  00:01:58
;
;  **** WARNINGS *************************************** 
;   *** WARNING : Tool: 21 M4 detected on center drill
;   *** WARNING : Tool: 11 may retract through part
;   *** WARNING : Tool: 23 - pitch it too large
G7
G18
G20
G54
G40
G90

G30
M0

; ==============================================================
; Tool: 21  M4 #3 (.250) Center drill M4 #3 (.250) Center drill
; Time: 00:00:02
;    Z: -0.12
;   Op: GANG:M4:center drill
T2121
G97 S1800 M4
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
; Tool: 22 YG-1 .272 [#I] CoHSS stub drill .272 [#I] CoHSS stub drill
; Time: 00:00:21
;    Z: -0.902
;   Op: GANG: tap drill small hole
T2222
G97 S1600 M3
G0 X0.
Z0.66 M8
G0 Z0.36
Z0.26
Z0.09
G94 G1 Z-0.09 F3.5
G0 Z0.26
Z-0.01
G1 Z-0.185 F3.5
G0 Z0.26
Z-0.105
G1 Z-0.275 F3.5
G0 Z0.26
Z-0.195
G1 Z-0.36 F3.5
G0 Z0.26
Z-0.28
G1 Z-0.44 F3.5
G0 Z0.26
Z-0.36
G1 Z-0.515 F3.5
G0 Z0.26
Z-0.435
G1 Z-0.59 F3.5
G0 Z0.26
Z-0.51
G1 Z-0.665 F3.5
G0 Z0.26
Z-0.585
G1 Z-0.74 F3.5
G0 Z0.26
Z-0.66
G1 Z-0.815 F3.5
G0 Z0.26
Z-0.735
G1 Z-0.89 F3.5
G0 Z0.26
Z-0.81
G1 Z-0.902 F3.5
G0 Z0.36
Z0.66
M9
M5

; ...pull back to safe Z...
Z2.

; ==============================================================
; Tool: 23 YG-1 .375 CoHSS stub drill .375 CoHSS stub drill
; Time: 00:00:14
;    Z: -0.3998
;   Op: GANG: tap dill large hole
T2323
G97 S1400 M3
G0 X0.
Z0.66 M8
G0 Z0.36
Z0.26
Z0.09
G94 G1 Z-0.09 F3.
G0 Z0.26
Z-0.01
G1 Z-0.185 F3.
G0 Z0.26
Z-0.105
G1 Z-0.275 F3.
G0 Z0.26
Z-0.195
G1 Z-0.36 F3.
G0 Z0.26
Z-0.28
G1 Z-0.3998 F3.
G0 Z0.36
Z0.66
M9
M5

G30
M0

; ==============================================================
; Tool: 11 US Shop Tools Mini Boring Bar .208 CV7 TiN : HiTemp Alloy SST
; Time: 00:00:20
;    Z: -0.4174
;   Op: QCTP:inner bore
T1111
G96 S280 D1600 M3
G0 X-0.008
Z0.1969 M8
G0 Z0.0099
X-0.3582
G95 G1 X-0.3588 F0.01
X-0.38 Z-0.0007
Z-0.412 F0.004
X-0.365 Z-0.4165
X-0.3438 Z-0.4059 F0.01
G0 Z0.0102
X-0.3688
G1 X-0.39 Z-0.0004 F0.01
Z-0.409 F0.004
X-0.375 Z-0.4135
X-0.3538 Z-0.4029 F0.01
G0 Z0.0102
X-0.3788
G1 X-0.4 Z-0.0004 F0.01
Z-0.406 F0.004
X-0.385 Z-0.4105
X-0.3638 Z-0.3999 F0.01
G0 Z0.0102
X-0.3888
G1 X-0.41 Z-0.0004 F0.01
Z-0.403 F0.004
X-0.395 Z-0.4075
X-0.3738 Z-0.3969 F0.01
G0 Z0.0102
X-0.3947
G1 X-0.416 Z-0.0004 F0.01
Z-0.4012 F0.004
X-0.405 Z-0.4045
X-0.3838 Z-0.3939 F0.01
G0 Z0.0102
X-0.3999
G1 X-0.4211 Z-0.0004 F0.01
G3 X-0.4187 Z-0.004 I-0.0048 K-0.0036 F0.004
G1 Z-0.4004
X-0.411 Z-0.4027
X-0.3897 Z-0.3921 F0.01
G0 Z0.0102
X-0.4055
G1 X-0.4061 F0.01
X-0.4273 Z-0.0004
G3 X-0.4227 Z-0.004 I-0.0017 K-0.0036 F0.004
G1 Z-0.4015
X-0.37 Z-0.4174
X-0.3488 Z-0.4068 F0.01
G0 Z0.0102
X-0.4055
G1 X-0.406 F0.01
X-0.4272 Z-0.0004
G3 X-0.4265 Z-0.0006 I-0.0017 K-0.0036 F0.004
G1 X-0.4053 Z0.01 F0.01
X-0.4051
G0 X-0.4043
Z0.0097
G1 X-0.4255 Z-0.0009 F0.01
G3 X-0.4249 Z-0.0012 I-0.0026 K-0.0031 F0.004
G1 X-0.4037 Z0.0094 F0.01
G0 X-0.4029
Z0.0089
G1 X-0.4241 Z-0.0017 F0.01
G3 X-0.4237 Z-0.0021 I-0.0033 K-0.0023 F0.004
G1 X-0.4025 Z0.0086 F0.01
X-0.4022
G0 X-0.4019
Z0.0079
G1 X-0.4232 Z-0.0027 F0.01
X-0.423 Z-0.003 F0.004
X-0.4017 Z0.0076 F0.01
X-0.4015
G0 Z0.0066
G1 X-0.4227 Z-0.004 F0.01
Z-0.4015 F0.004
X-0.37 Z-0.4174
X-0.3488 Z-0.4068 F0.01
X-0.3471
G0 X-0.2633
M9
M5

G30
M0

; ==============================================================
; Tool: 23 Sowa 5/16-24 H3 HSS-PM 
; Time: 00:00:01
;    Z: -0.9003
;   Op: GANG:tap LH 5/16-24
T2323
G97 S450 M3
G0 X0.
Z0.4547 M8
G33.1 Z-0.9003 K0.417
G0 Z0.4547
M9
M5

; ...pull back to safe Z...
Z2.

; ==============================================================
; Tool: 24 YG-1 1/2-13 LH P-HSS spiral tap 1/2-13 LH P-HSS spiral tap
; Time: 00:00:04
;    Z: -0.4798
;   Op: GANG:tap LH 1/2-13 (2)
T2424
G97 S450 M4
G0 X0.
Z0.9 M8
G33.1 Z-0.4798 K0.0769
G0 Z0.9
M9
M5

G30
M0

M30
%
