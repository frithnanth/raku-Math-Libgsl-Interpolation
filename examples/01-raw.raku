#!/usr/bin/env raku

# See "GNU Scientific Library" manual Chapter 30 Interpolation, Paragraph 30.7 (I example)
# Graph produced using GNU plotutils: examples/01-raw.raku | graph -T svg >examples/01-raw.svg

use NativeCall;
use Math::Libgsl::Constants;
use Math::Libgsl::Raw::Interpolation;

my $x = CArray[num64].allocate(10);
my $y = CArray[num64].allocate(10);

put '#m=0,S=17';

for ^10 -> $i {
  $x[$i] = $i + 0.5e0 * sin($i);
  $y[$i] = $i + cos($i * $i);
  printf "%g %g\n", $x[$i], $y[$i];
}

put '#m=1,S=0';

my gsl_interp_accel $acc = gsl_interp_accel_alloc;
my gsl_spline $spline = mgsl_spline_alloc(CSPLINE, 10);
gsl_spline_init($spline, $x, $y, 10);

loop (my Num $xi = $x[0]; $xi < $x[9]; $xi += .01) {
  my $yi = gsl_spline_eval($spline, $xi, $acc);
  printf "%g %g\n", $xi, $yi;
}

gsl_spline_free($spline);
gsl_interp_accel_free($acc);
