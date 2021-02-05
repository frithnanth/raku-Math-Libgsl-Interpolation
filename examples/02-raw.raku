#!/usr/bin/env raku

# See "GNU Scientific Library" manual Chapter 30 Interpolation, Paragraph 30.7 (II example)
# Graph produced using GNU plotutils: examples/02-raw.raku | graph -T svg >examples/02-raw.svg

use NativeCall;
use Math::Libgsl::Constants;
use Math::Libgsl::Raw::Interpolation;

my constant \N = 4;
my CArray[num64] $x .= new: 0e0, .1e0, .27e0, .3e0;
my CArray[num64] $y .= new: .15e0, .7e0, -.1e0, .15e0;

my gsl_interp_accel $acc = gsl_interp_accel_alloc;
my gsl_spline $spline = mgsl_spline_alloc(CSPLINE_PERIODIC, N);

put '#m=0,S=5';

for ^N -> $i {
  printf "%g %g\n", $x[$i], $y[$i];
}

put '#m=1,S=0';

gsl_spline_init($spline, $x, $y, N);

for ^100 -> $i {
  my $xi = (1e0 - $i / 100e0) * $x[0] + ($i / 100e0) * $x[N - 1];
  my $yi = gsl_spline_eval($spline, $xi, $acc);
  printf "%g %g\n", $xi, $yi;
}

gsl_spline_free($spline);
gsl_interp_accel_free($acc);
