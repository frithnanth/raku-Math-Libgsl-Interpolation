#!/usr/bin/env raku

# See "GNU Scientific Library" manual Chapter 30 Interpolation, Paragraph 30.14

use Math::Libgsl::Constants;
use Math::Libgsl::Interpolation;

my constant N = 100;
my Num @xa = 0e0, 1e0;
my Num @ya = 0e0, 1e0;
my Num @za;
my $nx = @xa.elems;
my $ny = @ya.elems;

my $spline = Math::Libgsl::Interpolation::TwoD.new(:type(BILINEAR), :xsize($nx), :ysize($ny));

# set z grid values
@za[$spline.zidx(0, 0)] = 0e0;
@za[$spline.zidx(0, 1)] = 1e0;
@za[$spline.zidx(1, 1)] = .5e0;
@za[$spline.zidx(1, 0)] = 1e0;

$spline.init: @xa, @ya, @za;

# interpolate N values in x and y and print out grid for plotting

for ^N -> $i {
  my Num $xi = $i / (N - 1e0);
  for ^N -> $j {
    my Num $yj  = $j / (N - 1e0);
    my Num $zij = $spline.eval: $xi, $yj;
    printf "%f ", $zij;
  }
  printf "\n";
}
