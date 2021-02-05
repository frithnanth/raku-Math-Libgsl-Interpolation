#!/usr/bin/env raku

# See "GNU Scientific Library" manual Chapter 30 Interpolation, Paragraph 30.7 (I example)
# Graph produced using GNU plotutils: examples/01-oo.raku | graph -T svg >examples/01-oo.svg

use Math::Libgsl::Constants;
use Math::Libgsl::Interpolation;

put '#m=0,S=17';

my Num (@x, @y);
for ^10 -> $i {
  @x[$i] = $i + 0.5 * sin($i);
  @y[$i] = $i + cos($i * $i);
  printf "%g %g\n", @x[$i], @y[$i];
}

put '#m=1,S=0';

my $i = Math::Libgsl::Interpolation::OneD.new(:type(CSPLINE), :size(10)).init(@x, @y);

loop (my Num $xi = @x[0]; $xi < @x[9]; $xi += .01) {
  my $yi = $i.eval: $xi;
  printf "%g %g\n", $xi, $yi;
}
