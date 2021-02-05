#!/usr/bin/env raku

# See "GNU Scientific Library" manual Chapter 30 Interpolation, Paragraph 30.14
# NOTE this program is run from examples/04-raw.gnuplot : no need to run it by hand

use NativeCall;
use Math::Libgsl::Constants;
use Math::Libgsl::Raw::Interpolation;

my constant N = 100;
my CArray[num64] $xa .= new: 0e0, 1e0;
my CArray[num64] $ya .= new: 0e0, 1e0;
my $nx = $xa.elems;
my $ny = $ya.elems;
my $za = CArray[num64].allocate($nx * $ny);

my gsl_spline2d $spline = mgsl_spline2d_alloc(BILINEAR, $nx, $ny);
my gsl_interp_accel $xacc = gsl_interp_accel_alloc;
my gsl_interp_accel $yacc = gsl_interp_accel_alloc;

# set z grid values
gsl_spline2d_set($spline, $za, 0, 0, 0e0);
gsl_spline2d_set($spline, $za, 0, 1, 1e0);
gsl_spline2d_set($spline, $za, 1, 1, .5e0);
gsl_spline2d_set($spline, $za, 1, 0, 1e0);

gsl_spline2d_init($spline, $xa, $ya, $za, $nx, $ny);

# interpolate N values in x and y and print out grid for plotting

for ^N -> $i {
  my num64 $xi = $i / (N - 1e0);
  for ^N -> $j {
    my num64 $yj  = $j / (N - 1e0);
    my num64 $zij = gsl_spline2d_eval($spline, $xi, $yj, $xacc, $yacc);
    printf "%f ", $zij;  # NOTE format adjusted to use with Gnuplot
  }
  printf "\n";
}

gsl_spline2d_free($spline);
gsl_interp_accel_free($xacc);
gsl_interp_accel_free($yacc);
