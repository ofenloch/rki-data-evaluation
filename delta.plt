# plot values and the delta / change of the value with its previous values

# found this on stackoverflow
# https://stackoverflow.com/a/11902907

# create svg plots
set terminal svg size 600,400 dynamic \
   enhanced font 'arial,10' \
   mousing name "array_1" butt dashlength 1.0 \
   jsdir "./js"

delta_v(x) = ( vD = x - old_v, old_v = x, vD )
old_v = NaN


set output './delta.svg'

set title "Compute Deltas"
set style data lines

plot 'delta.dat' using 0:($1) title 'Values' with points, \
     '' using 0:(delta_v($1)) title 'Delta' with linespoints