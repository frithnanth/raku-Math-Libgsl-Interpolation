[![Actions Status](https://github.com/frithnanth/raku-Math-Libgsl-Interpolation/workflows/test/badge.svg)](https://github.com/frithnanth/raku-Math-Libgsl-Interpolation/actions)

![2D spline interpolation](examples/04-raw.png)

NAME
====

Math::Libgsl::Interpolation - An interface to libgsl, the Gnu Scientific Library - Interpolation

SYNOPSIS
========

```raku
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
```

DESCRIPTION
===========

Math::Libgsl::Interpolation is an interface to the interpolation functions of libgsl, the Gnu Scientific Library. This module exports two classes:

  * Math::Libgsl::Interpolation::OneD

  * Math::Libgsl::Interpolation::TwoD

Math::Libgsl::Interpolation::OneD
---------------------------------

### new(Int $type!, Int $size!)

### new(Int :$type!, Int :$size!)

This **multi method** constructor requires two simple or named arguments, the type of interpolation and the size of the array of data points.

### init(Num() @xarray where ([<] @xarray), Num() @yarray --> Math::Libgsl::Interpolation::OneD)

This method initializes the interpolation internal data using the X and Y coordinate arrays. It must be called each time one wants to use the object to evaluate interpolation points on another data set. The X array has to be strictly ordered, with increasing x values. This method returns **self**, so it may be chained.

### min-size(--> UInt)

This method returns the minimum number of points required by the interpolation object.

### name(--> Str)

This method returns the name of the interpolation type.

### find(Num() @xarray, Num() $x --> UInt)

This method performs a lookup action on the data array **@xarray** and returns the index i such that @xarray[i] <= $x < @xarray[i+1].

### reset(--> Math::Libgsl::Interpolation::OneD)

This method reinitializes the internal data structure and deletes the cache. It should be used when switching to a new dataset. This method returns **self**, so it may be chained.

### eval(Num() $x where $!spline.interp.xmin ≤ * ≤ $!spline.interp.xmax --> Num)

This method returns the interpolated value of y for a given point x, which is inside the range of the x data set.

### eval-deriv(Num() $x where $!spline.interp.xmin ≤ * ≤ $!spline.interp.xmax --> Num)

This method returns the derivative of an interpolated function for a given point x, which is inside the range of the x data set.

### eval-deriv2(Num() $x where $!spline.interp.xmin ≤ * ≤ $!spline.interp.xmax --> Num)

This method returns the second derivative of an interpolated function for a given point x, which is inside the range of the x data set.

### eval-integ(Num() $a where $!spline.interp.xmin ≤ *, Num() $b where { $b ≤ $!spline.interp.xmax && $b ≥ $a } --> Num)

This method returns the numerical integral result of an interpolated function over the range [$a, $b], two points inside the x data set.

Math::Libgsl::Interpolation::TwoD
---------------------------------

### new(Int $type!, Int $xsize!, Int $ysize!)

### new(Int :$type!, Int :$xsize!, Int :$ysize!)

This **multi method** constructor requires three simple or named arguments, the type of interpolation and the size of the arrays of the x and y data points.

### init(Num() @xarray where ([<] @xarray), Num() @yarray where ([<] @yarray), Num() @zarray where *.elems == @xarray.elems * @yarray.elems --> Math::Libgsl::Interpolation::TwoD)

This method initializes the interpolation internal data using the X, Y, and Z coordinate arrays. It must be called each time one wants to use the object to evaluate interpolation points on another data set. The X and Y arrays have to be strictly ordered, with increasing values. The Z array, which represents a grid, must have a dimension of size xsize * ysize. The position of grid point (x, y) is given by y * xsize + x. This method returns **self**, so it may be chained.

### min-size(--> UInt)

This method returns the minimum number of points required by the interpolation object.

### name(--> Str)

This method returns the name of the interpolation type.

### eval(Num() $x where $!spline.interp.xmin ≤ * ≤ $!spline.interp.xmax, Num() $y where $!spline.interp.ymin ≤ * ≤ $!spline.interp.ymax --> Num)

This method returns the interpolated value of z for a given point (x, y), which is inside the range of the x and y data sets.

### extrap(Num() $x, Num() $y --> Num)

This method returns the interpolated value of z for a given point (x, y), with no bounds checking, so when the point (x, y) is outside the range, an extrapolation is performed.

### deriv-x(Num() $x where $!spline.interp.xmin ≤ * ≤ $!spline.interp.xmax, Num() $y where $!spline.interp.ymin ≤ * ≤ $!spline.interp.ymax --> Num)

This method returns the interpolated value of ∂z/∂x for a given point (x, y), which is inside the range of the x and y data sets.

### deriv-y(Num() $x where $!spline.interp.xmin ≤ * ≤ $!spline.interp.xmax, Num() $y where $!spline.interp.ymin ≤ * ≤ $!spline.interp.ymax --> Num)

This method returns the interpolated value of ∂z/∂y for a given point (x, y), which is inside the range of the x and y data sets.

### deriv-xx(Num() $x where $!spline.interp.xmin ≤ * ≤ $!spline.interp.xmax, Num() $y where $!spline.interp.ymin ≤ * ≤ $!spline.interp.ymax --> Num)

This method returns the interpolated value of ∂²z/∂²x for a given point (x, y), which is inside the range of the x and y data sets.

### deriv-yy(Num() $x where $!spline.interp.xmin ≤ * ≤ $!spline.interp.xmax, Num() $y where $!spline.interp.ymin ≤ * ≤ $!spline.interp.ymax --> Num)

This method returns the interpolated value of ∂²z/∂²y for a given point (x, y), which is inside the range of the x and y data sets.

### deriv-xy(Num() $x where $!spline.interp.xmin ≤ * ≤ $!spline.interp.xmax, Num() $y where $!spline.interp.ymin ≤ * ≤ $!spline.interp.ymax --> Num)

This method returns the interpolated value of ∂²z/∂x∂y for a given point (x, y), which is inside the range of the x and y data sets.

Accessory subroutines
---------------------

### bsearch(Num() @xarray, Num() $x, UInt $idx-lo = 0, UInt $idx-hi = @xarray.elems - 1 --> UInt)

This sub returns the index i of the array @xarray such that @xarray[i] <= $x < @xarray[i+1]. The index is searched for in the range [$idx-lo, $idx-hi].

### min-size(Int $type --> UInt)

### min-size1d(Int $type --> UInt)

### min-size2d(Int $type --> UInt)

These subs return the minimum number of points required by the interpolation object, without the need to create an object. min-size is an alias for min-size1d.

C Library Documentation
=======================

For more details on libgsl see [https://www.gnu.org/software/gsl/](https://www.gnu.org/software/gsl/). The excellent C Library manual is available here [https://www.gnu.org/software/gsl/doc/html/index.html](https://www.gnu.org/software/gsl/doc/html/index.html), or here [https://www.gnu.org/software/gsl/doc/latex/gsl-ref.pdf](https://www.gnu.org/software/gsl/doc/latex/gsl-ref.pdf) in PDF format.

Prerequisites
=============

This module requires the libgsl library to be installed. Please follow the instructions below based on your platform:

Debian Linux and Ubuntu 20.04
-----------------------------

    sudo apt install libgsl23 libgsl-dev libgslcblas0

That command will install libgslcblas0 as well, since it's used by the GSL.

Ubuntu 18.04
------------

libgsl23 and libgslcblas0 have a missing symbol on Ubuntu 18.04. I solved the issue installing the Debian Buster version of those three libraries:

  * [http://http.us.debian.org/debian/pool/main/g/gsl/libgslcblas0_2.5+dfsg-6_amd64.deb](http://http.us.debian.org/debian/pool/main/g/gsl/libgslcblas0_2.5+dfsg-6_amd64.deb)

  * [http://http.us.debian.org/debian/pool/main/g/gsl/libgsl23_2.5+dfsg-6_amd64.deb](http://http.us.debian.org/debian/pool/main/g/gsl/libgsl23_2.5+dfsg-6_amd64.deb)

  * [http://http.us.debian.org/debian/pool/main/g/gsl/libgsl-dev_2.5+dfsg-6_amd64.deb](http://http.us.debian.org/debian/pool/main/g/gsl/libgsl-dev_2.5+dfsg-6_amd64.deb)

Installation
============

To install it using zef (a module management tool):

    $ zef install Math::Libgsl::Interpolation

AUTHOR
======

Fernando Santagata <nando.santagata@gmail.com>

COPYRIGHT AND LICENSE
=====================

Copyright 2021 Fernando Santagata

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

