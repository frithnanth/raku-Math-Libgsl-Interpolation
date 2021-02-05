#!/usr/bin/env raku

# See "GNU Scientific Library" manual Chapter 30 Interpolation, Paragraph 30.7 (III example)

use Math::Libgsl::Constants;
use Math::Libgsl::Interpolation;

my constant \N = 9;
my num64 @x = 7.99e0, 8.09e0, 8.19e0, 8.7e0, 9.2e0, 10e0, 12e0, 15e0, 20e0;
my num64 @y = 0e0, 2.76429e-5, 4.37498e-2, 0.169183e0, 0.469428e0, 0.943740e0, 0.998636e0, 0.999919e0, 0.999994e0;

my $cubic = Math::Libgsl::Interpolation::OneD.new(:type(CSPLINE), :size(N)).init(@x, @y);
my $akima = Math::Libgsl::Interpolation::OneD.new(:type(AKIMA), :size(N)).init(@x, @y);
my $steffen = Math::Libgsl::Interpolation::OneD.new(:type(STEFFEN), :size(N)).init(@x, @y);

my $fp = open 'examples/03-oo1.dat', :w;
for ^N -> $i {
  $fp.printf: "%g %g\n", @x[$i], @y[$i];
}
$fp.close;

$fp = open 'examples/03-oo2.dat', :w;
for ^100 -> $i {
  my Num $xi = (1 - $i / 100) * @x[0] + ($i / 100) * @x[N - 1];
  my Num $yi-cubic = $cubic.eval: $xi;
  my Num $yi-akima = $akima.eval: $xi;
  my Num $yi-steffen = $steffen.eval: $xi;
  $fp.printf: "%g %g %g %g\n", $xi, $yi-cubic, $yi-akima, $yi-steffen;
}
$fp.close;
