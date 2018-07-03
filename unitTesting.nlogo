__includes [ "teleoTurtles.nls" ]

;;; Initial Version of TeleoTurtles

breed [robots robot]
breed [cans can]
breed [depots depot]
breed [spots spot]

robots-own [teleor-store]
globals [ffo testss]

to setup
  ca
  reset-ticks
  setupEnv
  create-robots 2 [
    set size 2
    set color red
   ;; tr-init
    tr-code-of-robots
  ]
end

to create-some-robots [N posx posy]
  create-robots N [
    setxy posx posy
    set size 2
    set color red
   ;; tr-init
    tr-code-of-robots
  ]

end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
to run-tests
  ca
  set number-of-cans 1
  setupTestCase1
  run-test1
  setupTestCase1
  run-test2
  setupTestCase1
  run-test3
  setupTestCase45
  run-test4
  setupTestCase45
  run-test5
  setupTestCase6
  run-test6
  setupTestCase78
  run-test7
  setupTestCase78
  run-test8
end


;;; Test Case 1
;;; Checks

to setupTestCase1
   clear-test
   reset-ticks
   create-some-robots 1 0 0
   ask robots [set heading 90 ]
   set view-angle  5 ;;; better centering
   create-depots 1
    [ set shape "circle"
      set color  green
      set size 2
      move-to patch 5 8
    ]
   create-cans number-of-cans
    [ set shape "box"
      set color  yellow
      move-to patch 5 0
    ]
end

to run-test1
 loop [
  ask robots [execute-rules]
  ask cans [cans-code]
  if count cans = 0
     and count spots = 1
     and [count depots-here = 1] of one-of robots
     [test-show 1 "Success" stop]
  tick
 ]
end


;; Check wait repeat

to run-test2
  loop [
  ifelse ticks < 140
    [ask depots [set color red] ]
    [ask depots [set color green]]
  ask robots [execute-rules]
  ask cans [cans-code]
  if count cans = 0
     and count spots = 1
     and [count depots-here = 1] of one-of robots
  [ test-show 2 "Success " stop]
  tick
  ]
end


;;; Wait repeat failure
to run-test3
  loop [
  ifelse ticks < 200
    [ask depots [set color red] ]
    [ask depots [set color green]]
  ask robots [execute-rules]
  ask cans [cans-code]

  if count cans = 0
     and count spots = 1
     and [count depots-here = 1] of one-of robots
  [ test-show 3 "Success " stop]
  tick
  ]
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to setupTestCase45
   clear-test
   reset-ticks
   create-some-robots 1 -15 0
   ask robots [set heading 90 ]
   set view-angle  10 ;;; wider
   create-depots 1
    [ set shape "circle"
      set color  green
      set size 2
      move-to patch 15 15
      set heading 180
    ]
   create-cans number-of-cans
    [ set shape "box"
      set color  yellow
      move-to patch -15 10
    ]
end

;;test 4 testing reactive
to run-test4
  loop [
  ifelse ticks < 200
    [ask depots [set color red] ]
    [ask depots [set color green]]
  ask robots [execute-rules]
  ask cans [cans-code]
  ask depots [ifelse can-move? 1 [fd 0.1] [rt 180 fd 0.1] ]
  if count cans = 0
     and [count depots-here = 1] of one-of robots
     [ test-show 4 "Success " stop]
  tick
  ]
end

;;; test 5 reactive
to run-test5
  loop [
  ifelse ticks < 200
    [ask depots [set color red] ]
    [ask depots [set color green]]
  ask robots [execute-rules]
  ask cans [cans-code]
  ask depots [ifelse can-move? 1 [fd 0.15] [rt 90 fd 0.15] ]
  if count cans = 0
     and [count depots-here = 1] of one-of robots
     [test-show 5 "Success" stop]
  tick
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to setupTestCase6
   clear-test
   reset-ticks
   create-some-robots 1 0 0
   ask robots [set color yellow set heading 90]
end

to run-test6
  repeat 350 [
     ask robots [execute-rules]
     tick ]
  ifelse count patches with [any? spots-here] = 8
     [test-show 6 "Success"]
     [test-show 6 "Failed" ]

end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Test Case 7 Single Proccedure Call
to setupTestCase78
   clear-test
   reset-ticks
   create-some-robots 1 0 0
   ask robots [set color blue set heading 90]
end

to run-test7
  repeat 72 [
     ask robots [execute-rules]
     tick ]
  ifelse [count spots-here] of one-of robots = 1
     [test-show 7 "Success"]
     [test-show 7 "Failed" ]

end


;; Continuing with a change in percepts
to run-test8
  repeat 144 [
     ask robots [execute-rules]
     if ticks = 50 [create-depots 1 [
       set shape "circle"
       set color  green
       set size 2 setxy 5 5]]
     tick ]
  ifelse [count spots-here] of one-of robots = 1
     [test-show 8 "Success"]
     [test-show 8 "Failed" ]

end


to-report tr#taskify [cmd]
  report runresult (word "[[] -> " cmd "]")
end


;;;;;;; Procedure that prints test results.
to test-show [num Status]
  output-print (word "Test " num " " Status)
end

;;; Clears environment between tests
to clear-test
  clear-globals
  clear-ticks
  clear-turtles
  clear-patches
  clear-drawing
  clear-all-plots
end


to run-exp
  ask cans [cans-code]
  ask robots [execute-rules]
  if (ticks mod Freq = 0 and count cans < number-of-cans) [create-cans 1 [place-can]]
  ask depots [ifelse ticks mod Depot-freq < (Depot-freq / 2) [set color green] [set color red]];;if not any? cans [stop]
  tick
end



to setupEnv
  create-depots number-of-depots
    [ set shape "circle"
      set color  green
      set size 2
      move-to one-of patches with [not any? turtles in-radius 4]
    ]
   create-cans number-of-cans
    [ place-can
    ]
end


to place-can
   set shape "box"
   set color  yellow
   move-to one-of patches with [not any? (turtle-set cans robots depots) in-radius 4]
end


to tr-code-of-robots
  tr-init
  percepts ["holding" "at-depot" "see-depot" "see-can" "touching" "can-move-ahead" "yellow" "blue"]
  durative-actions ["move-forward" "rotate"]
  discrete-actions ["ungrasp" "grasp" "blink"]
   procedure "default"
    # "holding" & "at-depot" --> "ungrasp" wait-repeat 2 10  ++ [[] -> show "At-deport - ungrasp"] .
    # "holding" & "see-depot" --> ["blink" "move-forward"]  .
    # "holding" --> "rotate" .
    # "see-can" & "touching" --> "grasp" .
    # "see-can" & "can-move-ahead" --> "move-forward".
    # "see-can"  --> "rotate" .
    # "yellow" --> "blink" : ["blink" "move-forward"] for 10 : "rotate" for 18 : "blink" : "move-forward" for 10 .
    # "blue" --> "moving" .
    # "true" --> ["rotate"  "move-forward"] ++ [ [] -> show "seeking"] .
   end-procedure

   procedure "moving"
   # "true" --> ["rotate" "move-forward" "blink"] .
   end-procedure

   ;;; Set the goal for the agent.
   set-goal "default"
end


to-report proc-dsa
  report (list "dsa" [[x y ] ->
    ifelse (x > 0) [show x + y] [ show "low"]])
end




; action "dsa" [[x y] -> fd 2 rt x lt y]
; action "foo" [ [] -> fd 1]


to-report action [Name Code]
  report (list Name Code)
end




;;; User defined Perception
;;; This has to be supplied by the user, in order to update the percepts.
;;; All info (yes/no)
to update-percepts
 ifelse any? depots in-cone view-distance view-angle
   [add-percept "see-depot"]
   [no-percept "see-depot"]
 ifelse any? depots in-radius 0.5 [add-percept "at-depot"]  [no-percept "at-depot"]
 ifelse any? free-cans in-cone view-distance view-angle [add-percept "see-can"] [no-percept "see-can"]
 ifelse any? free-cans in-radius 1 [add-percept "touching"] [no-percept "touching"]
 ifelse any? my-out-links [add-percept "holding"] [no-percept "holding"]
 ifelse can-move? 0.2 [add-percept "can-move-ahead"] [no-percept "can-move-ahead"]
 ifelse color = yellow [add-percept "yellow"] [no-percept "yellow"]
 ifelse color = blue [add-percept "blue"] [no-percept "blue"]
end


;; Code executed by the cans.
;; This makes cans disappear when dropped in a depot.
to cans-code
  if any? depots in-radius 1 and not any? my-in-links [die]
end

to-report free-cans
  report cans with [not any? my-in-links]
end



;;; Agent Actions
;;; Randomness to check wait-repeat
;;; If the depot is green, then grasp
to ungrasp
  if [color = green] of one-of depots in-radius 0.5
   [ask my-out-links [die]]
end

;;; Crearting a link to simulate the grasp move.
to grasp
  move-to one-of cans in-radius 1
  create-link-to one-of cans-here [tie]
end

;;; Moving forward.
to move-forward
  fd 0.2
end

;; Hatching spots so we can count them for testing.
to blink
  hatch-spots 1 [set shape "circle" set size 0.4 set color yellow]
end

;;; Usual rotate action.
to rotate
  rt 5
end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
647
448
-1
-1
13.0
1
10
1
1
1
0
0
0
1
-16
16
-16
16
0
0
1
ticks
30.0

BUTTON
18
20
197
53
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
13
453
203
486
view-distance
view-distance
0
50
50.0
1
1
NIL
HORIZONTAL

SLIDER
13
489
204
522
view-angle
view-angle
5
60
10.0
1
1
NIL
HORIZONTAL

BUTTON
19
60
105
93
NIL
run-exp\n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
112
59
198
92
NIL
run-exp\n
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
20
431
170
449
Robot View Area
12
0.0
1

SLIDER
18
129
201
162
number-of-cans
number-of-cans
0
40
3.0
1
1
NIL
HORIZONTAL

SLIDER
15
191
201
224
number-of-depots
number-of-depots
1
100
3.0
1
1
NIL
HORIZONTAL

SLIDER
22
283
207
316
Freq
Freq
100
10000
100.0
100
1
NIL
HORIZONTAL

TEXTBOX
25
251
175
279
Deternines the frequency (ticks) that cans appear.
11
0.0
1

TEXTBOX
20
112
170
130
Initial Number of Cans
12
0.0
1

SLIDER
22
323
207
356
Depot-freq
Depot-freq
10
200
50.0
10
1
NIL
HORIZONTAL

BUTTON
281
541
421
574
NIL
run-test1
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
16
560
156
593
NIL
run-tests\n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
385
502
483
535
NIL
run-test6
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
426
541
524
574
NIL
run-test2
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
283
503
381
536
NIL
run-test8\n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

OUTPUT
676
16
916
306
12

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.3
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
