__includes [ "./tr/teleoTurtles.nls" ]

;;; Initial Version of TeleoTurtles Example
;;; Ilias Sakellariou
;;; 2018 Jul Ported to NetLogo 6.
;;; 2022 Newer Version

breed [robots robot]
breed [cans can]
breed [depots depot]

;;; All agents that need to use Turtles TR must have a turtles-own variable
;;; teleor-store.
robots-own [teleor-store]

globals [collected-cans]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Experiment Setup

;;; Classic setup for robots collecting cans.
to setup
  ca
  reset-ticks
  setupEnv
  create-robots 1 [
    set size 2
    set color red
    ;; This call is to a procedure defining the code of TR turles.
    tr-code-of-robots
  ]
end

;;; Procedure to set up the rest of the environment, i.e. depots and cans.
to setupEnv
  create-depots number-of-depots
    [ set shape "depot"
      set color  green
      set size 2
      move-to one-of patches with [not any? turtles in-radius 4]
    ]
   create-cans number-of-cans
    [ place-can
    ]
end

;; place cans somewhere that there are no other turtles.
to place-can
   set shape "box"
   set color  yellow
   move-to one-of patches with [not any? turtles in-radius 4]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Executing the Simulation
;;; top level Procedure to execute the Simulation.
to run-exp
  ask cans [cans-code]
  ;; Depots code. Simply changes the state of the Depot with a specified frequency
  ;; and move slowly the depot in space.
  ask depots [
     ifelse ticks mod Depot-freq < (Depot-freq / 2) [set color green] [set color red]
     ifelse can-move? 1
       [fd 0.01]
       [rt random 45 lt random 45]
    ]
  ;; Asking robots to execute the TR specification.
  ask robots [execute-rules]
  ;; Continuesly populating the environment with cans.
  if (ticks mod Freq = 0 and count cans < number-of-cans) [create-cans 1 [place-can]]
  tick
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Code to execute

;;; Code executed by cans. (if the latter are in a depot, they simpy die)
to cans-code
  if any? depots in-radius 1 and not any? my-in-links
     [set collected-cans collected-cans + 1
      die
      ]
end

;;; TR implementation of Robots
;;; Please see manual for a detailed description
to tr-code-of-robots
  tr-init
  belief-update-function [[] -> update-robot-beliefs]
  beliefs ["holding" "at-depot" "see-depot" "see-can" "touching" "can-move-ahead"]
  durative-actions ["move-forward" "rotate"]
  discrete-actions ["ungrasp" "grasp" "blink"]
  procedure "clean-cans"
    # "holding" & "at-depot" --> "ungrasp" wait-repeat 2 10  ++ [[]-> show "At-deport - Delivered" set color red] .
    # "holding" & "see-depot" & "can-move-ahead" --> ["blink" "move-forward"]  .
    # "holding" --> "wander" .
    # "touching" --> "grasp" .
    # "see-can" & "can-move-ahead" --> "move-forward" .
    # "true" --> "wander" .
  end-procedure

  procedure "wander"
   # "can-move-ahead" --> "move-forward" for 2 : "rotate" for 1 .
   # "true" --> "rotate".
  end-procedure
  ;; setting the top level goal.
  set-goal "clean-cans"
end


;;; User defined Perception
;;; This is the implementation of the belief update function,
;;; Provided by the modeler and declated in the tr-code-of-robots (see above).
to update-robot-beliefs
 ifelse any? depots in-cone view-distance view-angle
   [add-belief "see-depot"]
   [no-belief "see-depot"]
 ifelse any? depots-here  [add-belief "at-depot"]  [no-belief "at-depot"]
 ifelse any? cans in-cone view-distance view-angle [add-belief "see-can"] [no-belief "see-can"]
 ifelse any? cans in-radius 1 [add-belief "touching"] [no-belief "touching"]
 ifelse any? my-out-links [add-belief "holding"] [no-belief "holding"]
 ifelse can-move? 0.2 [add-belief "can-move-ahead"] [no-belief "can-move-ahead"]
end


;;; Actions
;;; Model introduces randomness to check wait-repeat command
;;; If the depot is green, then the action to ungrasp is a success.
;;; If not, then the action simply does not change the environment (i.e. the can is still on the robot).
to ungrasp
  if [color = green] of one-of depots-here
   [ask my-out-links [die] ]
end

;;; Grasping is creating a link between the turtle (robot) and the can.
to grasp
  move-to one-of cans in-radius 1
  create-link-to one-of cans-here [tie]
end

;;; Simply moving forward
to move-forward
  fd 0.2
end

;;; Just an action to demonstrate sequence.
to blink
  set color green
  ;;show (word ticks " blink")
end

;;; Simply rotating.
to rotate
  rt random 8
  ;lt random 8
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
1
1
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
12
333
202
366
view-distance
view-distance
0
50
20.0
1
1
NIL
HORIZONTAL

SLIDER
12
369
203
402
view-angle
view-angle
10
60
25.0
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
19
311
169
329
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
1
40
9.0
1
1
NIL
HORIZONTAL

SLIDER
16
166
202
199
number-of-depots
number-of-depots
1
100
2.0
1
1
NIL
HORIZONTAL

SLIDER
20
237
205
270
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
23
205
173
233
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
20
277
205
310
Depot-freq
Depot-freq
10
200
10.0
10
1
NIL
HORIZONTAL

MONITOR
12
422
199
467
Collected Cans
collected-cans
17
1
11

@#$#@#$#@
## WHAT IS IT?

This is a simple model of a robot collecting cans, to demonstrate the application of TRTurtles in coding the behaviour of agents. TR-Turtles introduces teleoreactive rules 

## HOW IT WORKS

The robot scans the area (defined by the view-distance and view-angle sliders to "see" any cans. Once a can is found, moves towards the can, collects it and brings it to a depot (action ungrasp).

Cans are continuesly generated in the environment with a frequency determined by the Freq slider. 

However depots switch between two states, that of accepting cans (green) and that of not accepting (red) and move (slowly) as well. The switch betweem the two states is controlled by the depot-freq slider. Thus, the agent must persist (rule wait-repeat) in order to successfully deposit the can.  

## HOW TO USE IT

Simply run setup (button) and the choose between run-exp (single step) and run-exp (continous) buttons in the GUI of the model.

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

You can add new percepts and actions, by augmenting the TR agent definition in the corresponding procedures in the code tab. 

## NETLOGO FEATURES

The necessary meta-interpreter can be found in the files teleo*.nls in the tr directory.

## CREDITS AND REFERENCES

Work reported in the following paper that describes the TR Turtles language. 

Apostolidis-Afentoulis, V. and Sakellariou, I.
Teleo-Reactive Agents in a Simulation Platform.
In Proceedings of the 15th International Conference on Agents and Artificial Intelligence (ICAART 2023)
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

depot
false
0
Circle -7500403 false true 0 0 298
Circle -7500403 false true 15 15 270
Circle -7500403 false true 29 29 242
Circle -7500403 true true 135 135 30
Rectangle -7500403 true true 15 30 30 30
Rectangle -7500403 true true 0 0 30 30
Rectangle -7500403 true true 0 270 30 300
Rectangle -7500403 true true 270 270 300 300
Rectangle -7500403 true true 270 0 300 30

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
NetLogo 6.3.0
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
