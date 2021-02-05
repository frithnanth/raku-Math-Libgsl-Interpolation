#!/usr/bin/env raku

# See "GNU Scientific Library" manual Chapter 30 Interpolation, Paragraph 30.7 (II example)
# Graph produced using GNU plotutils: examples/02-oo.raku | graph -T svg >examples/02-oo.svg

use Math::Libgsl::Constants;
use Math::Libgsl::Interpolation;

my constant \N = 4;
my Num @x = 0e0, .1e0, .27e0, .3e0;
my Num @y = .15e0, .7e0, -.1e0, .15e0;

put '#m=0,S=5';

for ^N -> $i {
  printf "%g %g\n", @x[$i], @y[$i];
}

put '#m=1,S=0';

my $s = Math::Libgsl::Interpolation::OneD.new(:type(CSPLINE_PERIODIC), :size(N)).init(@x, @y);

for ^100 -> $i {
  my Num $xi = (1 - $i / 100) * @x[0] + ($i / 100) * @x[N - 1];
  my Num $yi = $s.eval: $xi;
  printf "%g %g\n", $xi, $yi;
}
