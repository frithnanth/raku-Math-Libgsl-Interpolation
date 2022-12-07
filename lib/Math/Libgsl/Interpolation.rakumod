unit class Math::Libgsl::Interpolation:ver<0.0.3>:auth<zef:FRITH>;

use NativeCall;
use Math::Libgsl::Constants;
use Math::Libgsl::Exception;
use Math::Libgsl::Raw::Interpolation;

sub bsearch(Num() @xarray, Num() $x, UInt $idx-lo = 0, UInt $idx-hi = @xarray.elems - 1 --> UInt) is export {
  my CArray[num64] $cxa .= new: @xarray;
  gsl_interp_bsearch($cxa, $x, $idx-lo, $idx-hi);
}
sub min-size(Int $type --> UInt) is export { mgsl_interp_type_min_size($type) }
our &min-size1d is export = &min-size;
sub min-size2d(Int $type --> UInt) is export { mgsl_interp2d_type_min_size($type) }

class OneD {
  has gsl_interp_accel $.accel;
  has gsl_spline       $.spline;

  multi method new(Int  $type!, Int $size!)             { self.bless(:$type, :$size) }
  multi method new(Int :$type!, Int :$size!)            { self.bless(:$type, :$size) }

  submethod BUILD(Int :$type!, Int :$size!) {
    $!accel  = gsl_interp_accel_alloc;
    $!spline = mgsl_spline_alloc($type, $size);
  }
  submethod DESTROY {
    gsl_interp_accel_free($!accel);
    gsl_spline_free($!spline);
  }
  method init(Num() @xarray where ([<] @xarray),
              Num() @yarray
              --> Math::Libgsl::Interpolation::OneD) {
    my CArray[num64] $xarr .= new: @xarray;
    my CArray[num64] $yarr .= new: @yarray;
    my $ret = gsl_spline_init($!spline, $xarr, $yarr, @xarray.elems);
    fail X::Libgsl.new: errno => GSL_FAILURE, error => 'Error initializing the interpolation' if $ret != GSL_SUCCESS;
    self;
  }
  method min-size(--> UInt) { gsl_spline_min_size($!spline) }
  method name(--> Str) { gsl_spline_name($!spline) }
  method find(Num() @xarray, Num() $x --> UInt) {
    my CArray[num64] $xarr .= new: @xarray;
    gsl_interp_accel_find($!accel, $xarr, @xarray.elems, $x);
  }
  method reset(--> Math::Libgsl::Interpolation::OneD) {
    my $ret = gsl_interp_accel_reset($!accel);
    fail X::Libgsl.new: errno => GSL_FAILURE, error => 'Error resetting the acceleration object' if $ret != GSL_SUCCESS;
    self;
  }
  method eval(Num() $x where $!spline.interp.xmin ≤ * ≤ $!spline.interp.xmax --> Num) {
    my num64 $y;
    my $ret = gsl_spline_eval_e($!spline, $x, $!accel, $y);
    fail X::Libgsl.new: errno => GSL_FAILURE, error => 'Error evaluating the interpolation' if $ret != GSL_SUCCESS;
    return $y;
  }
  method eval-deriv(Num() $x where $!spline.interp.xmin ≤ * ≤ $!spline.interp.xmax --> Num) {
    my num64 $y;
    my $ret = gsl_spline_eval_deriv_e($!spline, $x, $!accel, $y);
    fail X::Libgsl.new: errno => GSL_FAILURE, error => 'Error evaluating the derivative of the interpolation' if $ret != GSL_SUCCESS;
    return $y;
  }
  method eval-deriv2(Num() $x where $!spline.interp.xmin ≤ * ≤ $!spline.interp.xmax --> Num) {
    my num64 $y;
    my $ret = gsl_spline_eval_deriv2_e($!spline, $x, $!accel, $y);
    fail X::Libgsl.new: errno => GSL_FAILURE, error => 'Error evaluating the second derivative of the interpolation' if $ret != GSL_SUCCESS;
    return $y;
  }
  method eval-integ(Num() $a where $!spline.interp.xmin ≤ *,
                          Num() $b where { $b ≤ $!spline.interp.xmax && $b ≥ $a }
                          --> Num) {
    my num64 $y;
    my $ret = gsl_spline_eval_integ_e($!spline, $a, $b, $!accel, $y);
    fail X::Libgsl.new: errno => GSL_FAILURE, error => 'Error evaluating the integral of the interpolation' if $ret != GSL_SUCCESS;
    return $y;
  }
}

class TwoD {
  has gsl_interp_accel $.xacc;
  has gsl_interp_accel $.yacc;
  has gsl_spline2d     $.spline;

  multi method new(Int $type!,  Int $xsize!,  Int $ysize!) {
    self.bless(:$type, :$xsize, :$ysize)
  }
  multi method new(Int :$type!, Int :$xsize!, Int :$ysize!) {
    self.bless(:$type, :$xsize, :$ysize)
  }

  submethod BUILD(Int :$type!, Int :$xsize!, Int :$ysize!) {
    $!xacc   = gsl_interp_accel_alloc;
    $!yacc   = gsl_interp_accel_alloc;
    $!spline = mgsl_spline2d_alloc($type, $xsize, $ysize);
  }
  submethod DESTROY {
    gsl_interp_accel_free($!xacc);
    gsl_interp_accel_free($!yacc);
    gsl_spline2d_free($!spline);
  }
  method init(Num() @xarray where ([<] @xarray),
              Num() @yarray where ([<] @yarray),
              Num() @zarray where *.elems == @xarray.elems * @yarray.elems
              --> Math::Libgsl::Interpolation::TwoD) {
    my CArray[num64] $xarr .= new: @xarray;
    my CArray[num64] $yarr .= new: @yarray;
    my CArray[num64] $zarr .= new: @zarray;
    my $ret = gsl_spline2d_init($!spline, $xarr, $yarr, $zarr, @xarray.elems, @yarray.elems);
    fail X::Libgsl.new: errno => GSL_FAILURE, error => 'Error initializing the interpolation' if $ret != GSL_SUCCESS;
    self;
  }
  method zidx(UInt $x, UInt $y --> UInt) { gsl_interp2d_idx($!spline.interp, $x, $y) }
  method min-size(--> UInt) { gsl_spline2d_min_size($!spline) }
  method name(--> Str) { gsl_spline2d_name($!spline) }
  method eval(Num() $x where $!spline.interp.xmin ≤ * ≤ $!spline.interp.xmax,
              Num() $y where $!spline.interp.ymin ≤ * ≤ $!spline.interp.ymax
              --> Num) {
    my num64 $z;
    my $ret = gsl_spline2d_eval_e($!spline, $x, $y, $!xacc, $!yacc, $z);
    fail X::Libgsl.new: errno => GSL_FAILURE, error => 'Error evaluating the interpolation' if $ret != GSL_SUCCESS;
    return $z;
  }
  method extrap(Num() $x, Num() $y --> Num) {
    fail X::Libgsl.new: errno => GSL_FAILURE, error => "Error in extrap: version < v2.6" if $gsl-version < v2.6;
    my num64 $z;
    my $ret = gsl_interp2d_eval_extrap_e($!spline.interp, $!spline.xarr, $!spline.yarr, $!spline.zarr, $x, $y, $!xacc, $!yacc, $z);
    fail X::Libgsl.new: errno => GSL_FAILURE, error => 'Error evaluating the extrapolation' if $ret != GSL_SUCCESS;
    return $z;
  }
  method deriv-x(Num() $x where $!spline.interp.xmin ≤ * ≤ $!spline.interp.xmax,
                 Num() $y where $!spline.interp.ymin ≤ * ≤ $!spline.interp.ymax
                 --> Num) {
    my num64 $z;
    my $ret = gsl_spline2d_eval_deriv_x_e($!spline, $x, $y, $!xacc, $!yacc, $z);
    fail X::Libgsl.new: errno => GSL_FAILURE, error => 'Error evaluating the x-derivative of the interpolation' if $ret != GSL_SUCCESS;
    return $z;
  }
  method deriv-y(Num() $x where $!spline.interp.xmin ≤ * ≤ $!spline.interp.xmax,
                 Num() $y where $!spline.interp.ymin ≤ * ≤ $!spline.interp.ymax
                 --> Num) {
    my num64 $z;
    my $ret = gsl_spline2d_eval_deriv_y_e($!spline, $x, $y, $!xacc, $!yacc, $z);
    fail X::Libgsl.new: errno => GSL_FAILURE, error => 'Error evaluating the y-derivative of the interpolation' if $ret != GSL_SUCCESS;
    return $z;
  }
  method deriv-xx(Num() $x where $!spline.interp.xmin ≤ * ≤ $!spline.interp.xmax,
                  Num() $y where $!spline.interp.ymin ≤ * ≤ $!spline.interp.ymax
                  --> Num) {
    my num64 $z;
    my $ret = gsl_spline2d_eval_deriv_xx_e($!spline, $x, $y, $!xacc, $!yacc, $z);
    fail X::Libgsl.new: errno => GSL_FAILURE, error => 'Error evaluating the xx-derivative of the interpolation' if $ret != GSL_SUCCESS;
    return $z;
  }
  method deriv-yy(Num() $x where $!spline.interp.xmin ≤ * ≤ $!spline.interp.xmax,
                  Num() $y where $!spline.interp.ymin ≤ * ≤ $!spline.interp.ymax
                  --> Num) {
    my num64 $z;
    my $ret = gsl_spline2d_eval_deriv_yy_e($!spline, $x, $y, $!xacc, $!yacc, $z);
    fail X::Libgsl.new: errno => GSL_FAILURE, error => 'Error evaluating the yy-derivative of the interpolation' if $ret != GSL_SUCCESS;
    return $z;
  }
  method deriv-xy(Num() $x where $!spline.interp.xmin ≤ * ≤ $!spline.interp.xmax,
                  Num() $y where $!spline.interp.ymin ≤ * ≤ $!spline.interp.ymax
                  --> Num) {
    my num64 $z;
    my $ret = gsl_spline2d_eval_deriv_xy_e($!spline, $x, $y, $!xacc, $!yacc, $z);
    fail X::Libgsl.new: errno => GSL_FAILURE, error => 'Error evaluating the xy-derivative of the interpolation' if $ret != GSL_SUCCESS;
    return $z;
  }
}

=begin pod

=head1 NAME

Math::Libgsl::Interpolation - An interface to libgsl, the Gnu Scientific Library - Interpolation

=head1 SYNOPSIS

=begin code :lang<raku>

use Math::Libgsl::Constants;
use Math::Libgsl::Interpolation;

my constant \N = 4;
my Num @x = 0e0, .1e0, .27e0, .3e0;
my Num @y = .15e0, .7e0, -.1e0, .15e0;

my $s = Math::Libgsl::Interpolation::OneD.new(:type(CSPLINE_PERIODIC), :size(N), :spline).init(@x, @y);

for ^100 -> $i {
  my Num $xi = (1 - $i / 100) * @x[0] + ($i / 100) * @x[N - 1];
  my Num $yi = $s.eval: $xi;
  printf "%g %g\n", $xi, $yi;
}

=end code

=head1 DESCRIPTION

Math::Libgsl::Interpolation is an interface to the interpolation functions of libgsl, the Gnu Scientific Library.
This module exports two classes:

=item Math::Libgsl::Interpolation::OneD
=item Math::Libgsl::Interpolation::TwoD

=head2 Math::Libgsl::Interpolation::OneD

=head3 new(Int  $type!, Int $size!)
=head3 new(Int :$type!, Int :$size!)

This B<multi method> constructor requires two simple or named arguments, the type of interpolation and the size of the array of data points.

=head3 init(Num() @xarray where ([<] @xarray), Num() @yarray --> Math::Libgsl::Interpolation::OneD)

This method initializes the interpolation internal data using the X and Y coordinate arrays.
It must be called each time one wants to use the object to evaluate interpolation points on another data set.
The X array has to be strictly ordered, with increasing x values.
This method returns B<self>, so it may be chained.

=head3 min-size(--> UInt)

This method returns the minimum number of points required by the interpolation object.

=head3 name(--> Str)

This method returns the name of the interpolation type.

=head3 find(Num() @xarray, Num() $x --> UInt)

This method performs a lookup action on the data array B<@xarray> and returns the index i such that @xarray[i] <= $x < @xarray[i+1].

=head3 reset(--> Math::Libgsl::Interpolation::OneD)

This method reinitializes the internal data structure and deletes the cache. It should be used when switching to a new dataset.
This method returns B<self>, so it may be chained.

=head3 eval(Num() $x where $!spline.interp.xmin ≤ * ≤ $!spline.interp.xmax --> Num)

This method returns the interpolated value of y for a given point x, which is inside the range of the x data set.

=head3 eval-deriv(Num() $x where $!spline.interp.xmin ≤ * ≤ $!spline.interp.xmax --> Num)

This method returns the derivative of an interpolated function for a given point x, which is inside the range of the x data set.

=head3 eval-deriv2(Num() $x where $!spline.interp.xmin ≤ * ≤ $!spline.interp.xmax --> Num)

This method returns the second derivative of an interpolated function for a given point x, which is inside the range of the x data set.

=head3 eval-integ(Num() $a where $!spline.interp.xmin ≤ *, Num() $b where { $b ≤ $!spline.interp.xmax && $b ≥ $a } --> Num)

This method returns the numerical integral result of an interpolated function over the range [$a, $b], two points inside the x data set.

=head2 Math::Libgsl::Interpolation::TwoD

=head3 new(Int  $type!, Int $xsize!,  Int $ysize!)
=head3 new(Int :$type!, Int :$xsize!, Int :$ysize!)

This B<multi method> constructor requires three simple or named arguments, the type of interpolation and the size of the arrays of the x and y data points.

=head3 init(Num() @xarray where ([<] @xarray), Num() @yarray where ([<] @yarray), Num() @zarray where *.elems == @xarray.elems * @yarray.elems --> Math::Libgsl::Interpolation::TwoD)

This method initializes the interpolation internal data using the X, Y, and Z coordinate arrays.
It must be called each time one wants to use the object to evaluate interpolation points on another data set.
The X and Y arrays have to be strictly ordered, with increasing values.
The Z array, which represents a grid, must have a dimension of size xsize * ysize. The position of grid point (x, y) is given by y * xsize + x (see also the zidx method).
This method returns B<self>, so it may be chained.

=head3 zidx(UInt $x, UInt $y --> UInt)

This method returns the index of the Z array element corresponding to grid coordinates (x, y).

=head3 min-size(--> UInt)

This method returns the minimum number of points required by the interpolation object.

=head3 name(--> Str)

This method returns the name of the interpolation type.

=head3 eval(Num() $x where $!spline.interp.xmin ≤ * ≤ $!spline.interp.xmax, Num() $y where $!spline.interp.ymin ≤ * ≤ $!spline.interp.ymax --> Num)

This method returns the interpolated value of z for a given point (x, y), which is inside the range of the x and y data sets.

=head3 extrap(Num() $x, Num() $y --> Num)

This method returns the interpolated value of z for a given point (x, y), with no bounds checking, so when the point (x, y) is outside the range, an extrapolation is performed.

=head3 deriv-x(Num() $x where $!spline.interp.xmin ≤ * ≤ $!spline.interp.xmax, Num() $y where $!spline.interp.ymin ≤ * ≤ $!spline.interp.ymax --> Num)

This method returns the interpolated value of ∂z/∂x for a given point (x, y), which is inside the range of the x and y data sets.

=head3 deriv-y(Num() $x where $!spline.interp.xmin ≤ * ≤ $!spline.interp.xmax, Num() $y where $!spline.interp.ymin ≤ * ≤ $!spline.interp.ymax --> Num)

This method returns the interpolated value of ∂z/∂y for a given point (x, y), which is inside the range of the x and y data sets.

=head3 deriv-xx(Num() $x where $!spline.interp.xmin ≤ * ≤ $!spline.interp.xmax, Num() $y where $!spline.interp.ymin ≤ * ≤ $!spline.interp.ymax --> Num)

This method returns the interpolated value of ∂²z/∂²x for a given point (x, y), which is inside the range of the x and y data sets.

=head3 deriv-yy(Num() $x where $!spline.interp.xmin ≤ * ≤ $!spline.interp.xmax, Num() $y where $!spline.interp.ymin ≤ * ≤ $!spline.interp.ymax --> Num)

This method returns the interpolated value of ∂²z/∂²y for a given point (x, y), which is inside the range of the x and y data sets.

=head3 deriv-xy(Num() $x where $!spline.interp.xmin ≤ * ≤ $!spline.interp.xmax, Num() $y where $!spline.interp.ymin ≤ * ≤ $!spline.interp.ymax --> Num)

This method returns the interpolated value of ∂²z/∂x∂y for a given point (x, y), which is inside the range of the x and y data sets.

=head2 Accessory subroutines

=head3 bsearch(Num() @xarray, Num() $x, UInt $idx-lo = 0, UInt $idx-hi = @xarray.elems - 1 --> UInt)

This sub returns the index i of the array @xarray such that @xarray[i] <= $x < @xarray[i+1].
The index is searched for in the range [$idx-lo, $idx-hi].

=head3 min-size(Int $type --> UInt)
=head3 min-size1d(Int $type --> UInt)
=head3 min-size2d(Int $type --> UInt)

These subs return the minimum number of points required by the interpolation object, without the need to create an object.
min-size is an alias for min-size1d.

=head1 C Library Documentation

For more details on libgsl see L<https://www.gnu.org/software/gsl/>.
The excellent C Library manual is available here L<https://www.gnu.org/software/gsl/doc/html/index.html>, or here L<https://www.gnu.org/software/gsl/doc/latex/gsl-ref.pdf> in PDF format.

=head1 Prerequisites

This module requires the libgsl library to be installed. Please follow the instructions below based on your platform:

=head2 Debian Linux and Ubuntu 20.04+

=begin code
sudo apt install libgsl23 libgsl-dev libgslcblas0
=end code

That command will install libgslcblas0 as well, since it's used by the GSL.

=head2 Ubuntu 18.04

libgsl23 and libgslcblas0 have a missing symbol on Ubuntu 18.04.
I solved the issue installing the Debian Buster version of those three libraries:

=item L<http://http.us.debian.org/debian/pool/main/g/gsl/libgslcblas0_2.5+dfsg-6_amd64.deb>
=item L<http://http.us.debian.org/debian/pool/main/g/gsl/libgsl23_2.5+dfsg-6_amd64.deb>
=item L<http://http.us.debian.org/debian/pool/main/g/gsl/libgsl-dev_2.5+dfsg-6_amd64.deb>

=head1 Installation

To install it using zef (a module management tool):

=begin code
$ zef install Math::Libgsl::Interpolation
=end code

=head1 AUTHOR

Fernando Santagata <nando.santagata@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2021 Fernando Santagata

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
