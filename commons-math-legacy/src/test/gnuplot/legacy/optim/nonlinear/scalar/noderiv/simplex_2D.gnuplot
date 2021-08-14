#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

#
# "Gnuplot" script to display the behaviour of simplex-based optimizers.
#
# Required argument:
#   file -> input file (cf. "SimplexOptimizerTest").
# Optional argument:
#   showSpx -> Number of simplexes to show.
#

set term x11

showSpx = exists("showSpx") ? showSpx : 5

stats file nooutput
numOptim = STATS_blocks
evalColIndex = 1
objColIndex = 2
xColIndex = 3
yColIndex = 4

set size 1, 1
set origin 0, 0

lastOptim = numOptim - 1
do for [iOptim = 1:lastOptim] {
  # Evaluations range.
  stats file u evalColIndex nooutput
  numEval = STATS_max

  # Objective function range.
  stats file index iOptim u objColIndex nooutput
  numSpx = STATS_blank
  minObj = STATS_min
  maxObj = STATS_max

  # x-coordinate range.
  stats file index iOptim u xColIndex nooutput
  xMin = STATS_min
  xMax = STATS_max

  # y-coordinate range.
  stats file index iOptim u yColIndex nooutput
  yMin = STATS_min
  yMax = STATS_max

  lastSpx = numSpx - 1
  do for [iSpx = 0:lastSpx] {
    set multiplot

    # Number of evaluations.
    set size 1, 0.15
    set origin 0, 0.85
    unset xtics

    plot \
       file index iOptim \
         every ::0::0 \
         u 0:1 \
         w p ps 0.5 lc "black" title "N_{eval}", \
       '' index iOptim \
         every ::0::0:iSpx \
         u 0:1 \
         w lp pt 1 lc "black" lw 2 notitle

    # Objective function.
    set size 1, 0.15
    set origin 0, 0.7

    plot \
       file index iOptim \
         every ::0::2 \
         u 0:(log($2)) \
         w l lc "black" title "log_{10}f", \
       '' index iOptim \
         every ::0::2:iSpx \
         u 0:(log($2)) \
         w lp pt 1 lc "black" lw 2 notitle

    # Simplex.
    set size 1, 0.7
    set origin 0, 0
    set xtics

    unset log y
    plot [xMin:xMax][yMin:yMax] \
      file index iOptim \
        every :::(iSpx - showSpx < 0 ? 0 : iSpx - showSpx)::iSpx \
        u xColIndex:yColIndex \
        w l notitle, \
      '' index "Optimum" u 1:2 ps 5 pt 4 notitle

    unset multiplot
    pause 0.1
  }

  pause 1
}

pause -1
