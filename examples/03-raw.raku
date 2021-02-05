#!/usr/bin/env raku

# See "GNU Scientific Library" manual Chapter 30 Interpolation, Paragraph 30.7 (III example)
# NOTE slightly modified in order to output two files to feed into gnuplot

use NativeCall;
use Math::Libgsl::Constants;
use Math::Libgsl::Raw::Interpolation;

my constant \N = 9;
my CArray[num64] $x .= new: 7.99e0, 8.09e0, 8.19e0, 8.7e0, 9.2e0, 10e0, 12e0, 15e0, 20e0;
my CArray[num64] $y .= new: 0e0, 2.76429e-5, 4.37498e-2, 0.169183e0, 0.469428e0, 0.943740e0, 0.998636e0, 0.999919e0, 0.999994e0;

my gsl_interp_accel $acc = gsl_interp_accel_alloc;
my gsl_spline $spline-cubic = mgsl_spline_alloc(CSPLINE, N);
my gsl_spline $spline-akima = mgsl_spline_alloc(AKIMA, N);
my gsl_spline $spline-steffen = mgsl_spline_alloc(STEFFEN, N);

gsl_spline_init($spline-cubic, $x, $y, N);
gsl_spline_init($spline-akima, $x, $y, N);
gsl_spline_init($spline-steffen, $x, $y, N);

my $fp = open 'examples/03-raw1.dat', :w;
for ^N -> $i {
  $fp.printf: "%g %g\n", $x[$i], $y[$i];
}
$fp.close;

$fp = open 'examples/03-raw2.dat', :w;
for ^100 -> $i {
  my $xi = (1e0 - $i / 100e0) * $x[0] + ($i / 100e0) * $x[N - 1];
  my $yi-cubic = gsl_spline_eval($spline-cubic, $xi, $acc);
  my $yi-akima = gsl_spline_eval($spline-akima, $xi, $acc);
  my $yi-steffen = gsl_spline_eval($spline-steffen, $xi, $acc);
  $fp.printf: "%g %g %g %g\n", $xi, $yi-cubic, $yi-akima, $yi-steffen;
}
$fp.close;

gsl_spline_free($spline-cubic);
gsl_spline_free($spline-akima);
gsl_spline_free($spline-steffen);
gsl_interp_accel_free($acc);
