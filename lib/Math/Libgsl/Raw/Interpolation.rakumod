use v6;

unit module Math::Libgsl::Raw::Interpolation:ver<0.1.0>:auth<zef:FRITH>;

use NativeCall;

constant GSLHELPER  = %?RESOURCES<libraries/gslhelper>;

sub LIB {
  run('/sbin/ldconfig', '-p', :chomp, :out)
    .out
    .slurp(:close)
    .split("\n")
    .grep(/^ \s+ libgsl\.so\. \d+ /)
    .sort
    .head
    .comb(/\S+/)
    .head;
}

class gsl_interp_type is repr('CStruct') is export {
  has Str     $.name;
  has uint32  $.min_size;
  has Pointer $.alloc;
  has Pointer $.init;
  has Pointer $.eval;
  has Pointer $.eval_deriv;
  has Pointer $.eval_deriv2;
  has Pointer $.eval_integ;
  has Pointer $.free;
}

class gsl_interp is repr('CStruct') is export {
  has gsl_interp_type $.type;
  has num64           $.xmin;
  has num64           $.xmax;
  has size_t          $.size;
  has Pointer         $.state;
}

class gsl_interp_accel is repr('CStruct') is export {
  has size_t $.cache;
  has size_t $.miss_count;
  has size_t $.hit_count;
}

class gsl_spline is repr('CStruct') is export {
  has gsl_interp     $.interp;
  has Pointer[num64] $.x;
  has Pointer[num64] $.y;
  has size_t         $.size;
}

class gsl_interp2d_type is repr('CStruct') is export {
  has Str     $.name;
  has uint32  $.min_size;
  has Pointer $.alloc;
  has Pointer $.init;
  has Pointer $.eval;
  has Pointer $.eval_deriv_x;
  has Pointer $.eval_deriv_y;
  has Pointer $.eval_deriv_xx;
  has Pointer $.eval_deriv_xy;
  has Pointer $.eval_deriv_yy;
  has Pointer $.free;
}

class gsl_interp2d is repr('CStruct') is export {
  has gsl_interp2d_type $.type;
  has num64             $.xmin;
  has num64             $.xmax;
  has num64             $.ymin;
  has num64             $.ymax;
  has size_t            $.xsize;
  has size_t            $.ysize;
  has Pointer           $.state;
}

class gsl_spline2d is repr('CStruct') is export {
  HAS gsl_interp2d   $.interp;
  has CArray[num64]  $.xarr;
  has CArray[num64]  $.yarr;
  has CArray[num64]  $.zarr;
}

# 1D Interpolation Functions
sub mgsl_interp_alloc(int32 $type, size_t $size --> gsl_interp) is native(GSLHELPER) is export { * }
sub gsl_interp_init(gsl_interp $interp, CArray[num64] $xa, CArray[num64] $ya, size_t $size --> int32) is native(LIB) is export { * }
sub gsl_interp_free(gsl_interp $interp) is native(LIB) is export { * }
sub gsl_interp_name(gsl_interp  $interp --> Str) is native(LIB) is export { * }
sub gsl_interp_min_size(gsl_interp $interp --> uint32) is native(LIB) is export { * }
sub mgsl_interp_type_min_size(int32 $type --> uint32) is native(GSLHELPER) is export { * }
# 1D Index Look-up and Acceleration
sub gsl_interp_bsearch(CArray[num64] $x_array, num64 $x, size_t $index_lo, size_t $index_hi --> size_t) is native(LIB) is export { * }
sub gsl_interp_accel_alloc(--> gsl_interp_accel) is native(LIB) is export { * }
sub gsl_interp_accel_find(gsl_interp_accel $a, CArray[num64] $x_array, size_t $size, num64 $x --> size_t) is native(LIB) is export { * }
sub gsl_interp_accel_reset(gsl_interp_accel $acc --> int32) is native(LIB) is export { * }
sub gsl_interp_accel_free(gsl_interp_accel $acc) is native(LIB) is export { * }
# 1D Evaluation of Interpolating Functions
sub gsl_interp_eval(gsl_interp $interp, CArray[num64] $xa, CArray[num64] $ya, num64 $x, gsl_interp_accel $acc --> num64) is native(LIB) is export { * }
sub gsl_interp_eval_e(gsl_interp $interp, CArray[num64] $xa, CArray[num64] $ya, num64 $x, gsl_interp_accel $acc, num64 $y is rw --> int32) is native(LIB) is export { * }
sub gsl_interp_eval_deriv(gsl_interp $interp, CArray[num64] $xa, CArray[num64] $ya, num64 $x, gsl_interp_accel $acc --> num64) is native(LIB) is export { * }
sub gsl_interp_eval_deriv_e(gsl_interp $interp, CArray[num64] $xa, CArray[num64] $ya, num64 $x, gsl_interp_accel $acc, num64 $d is rw --> int32) is native(LIB) is export { * }
sub gsl_interp_eval_deriv2(gsl_interp $interp, CArray[num64] $xa, CArray[num64] $ya, num64 $x, gsl_interp_accel $acc --> num64) is native(LIB) is export { * }
sub gsl_interp_eval_deriv2_e(gsl_interp $interp, CArray[num64] $xa, CArray[num64] $ya, num64 $x, gsl_interp_accel $acc, num64 $d is rw --> int32) is native(LIB) is export { * }
sub gsl_interp_eval_integ(gsl_interp $interp, CArray[num64] $xa, CArray[num64] $ya, num64 $a, num64 $b, gsl_interp_accel $acc --> num64) is native(LIB) is export { * }
sub gsl_interp_eval_integ_e(gsl_interp $interp, CArray[num64] $xa, CArray[num64] $ya, num64 $a, num64 $b, gsl_interp_accel $acc, num64 $result is rw --> int32) is native(LIB) is export { * }
# 1D Higher-level Interface
sub mgsl_spline_alloc(int32 $type, size_t $size --> gsl_spline) is native(GSLHELPER) is export { * }
sub gsl_spline_init(gsl_spline $spline, CArray[num64] $xa, CArray[num64] $ya, size_t $size --> int32) is native(LIB) is export { * }
sub gsl_spline_free(gsl_spline $spline) is native(LIB) is export { * }
sub gsl_spline_name(gsl_spline  $spline --> Str) is native(LIB) is export { * }
sub gsl_spline_min_size(gsl_spline $spline --> uint32) is native(LIB) is export { * }
sub gsl_spline_eval(gsl_spline $spline, num64 $x, gsl_interp_accel $acc --> num64) is native(LIB) is export { * }
sub gsl_spline_eval_e(gsl_spline $spline, num64 $x, gsl_interp_accel $acc, num64 $y is rw --> int32) is native(LIB) is export { * }
sub gsl_spline_eval_deriv(gsl_spline $spline, num64 $x, gsl_interp_accel $acc --> num64) is native(LIB) is export { * }
sub gsl_spline_eval_deriv_e(gsl_spline $spline, num64 $x, gsl_interp_accel $acc, num64 $d is rw --> int32) is native(LIB) is export { * }
sub gsl_spline_eval_deriv2(gsl_spline $spline, num64 $x, gsl_interp_accel $acc --> num64) is native(LIB) is export { * }
sub gsl_spline_eval_deriv2_e(gsl_spline $spline, num64 $x, gsl_interp_accel $acc, num64 $d is rw --> int32) is native(LIB) is export { * }
sub gsl_spline_eval_integ(gsl_spline $spline, num64 $a, num64 $b, gsl_interp_accel $acc --> num64) is native(LIB) is export { * }
sub gsl_spline_eval_integ_e(gsl_spline $spline, num64 $a, num64 $b, gsl_interp_accel $acc, num64 $result is rw --> int32) is native(LIB) is export { * }
# 2D Interpolation Functions
sub mgsl_interp2d_alloc(int32 $type, size_t $xsize, size_t $ysize --> gsl_interp2d) is native(GSLHELPER) is export { * }
sub gsl_interp2d_init(gsl_interp2d $interp2d, CArray[num64] $xa, CArray[num64] $ya, CArray[num64] $za,
    size_t $xsize, size_t $ysize --> int32) is native(LIB) is export { * }
sub gsl_interp2d_free(gsl_interp2d $interp2d) is native(LIB) is export { * }
sub gsl_interp2d_name(gsl_interp2d  $interp2d --> Str) is native(LIB) is export { * }
sub gsl_interp2d_min_size(gsl_interp2d $interp2d --> uint32) is native(LIB) is export { * }
sub mgsl_interp2d_type_min_size(int32 $type --> uint32) is native(GSLHELPER) is export { * }
# 2D Interpolation Grids
sub gsl_interp2d_set(gsl_interp2d $interp, CArray[num64] $za, size_t $i, size_t $j, num64 $z --> int32) is native(LIB) is export { * }
sub gsl_interp2d_get(gsl_interp2d $interp, CArray[num64] $za, size_t $i, size_t $j --> num64) is native(LIB) is export { * }
sub gsl_interp2d_idx(gsl_interp2d $interp, size_t $i, size_t $j --> size_t) is native(LIB) is export { * }
# 2D Evaluation of Interpolating Functions
sub gsl_interp2d_eval(gsl_interp2d $interp, CArray[num64] $xa, CArray[num64] $ya, CArray[num64] $za, num64 $x,
    num64 $y, gsl_interp_accel $xacc, gsl_interp_accel $yacc --> num64) is native(LIB) is export { * }
sub gsl_interp2d_eval_e(gsl_interp2d $interp, CArray[num64] $xa, CArray[num64] $ya, CArray[num64] $za, num64 $x,
    num64 $y, gsl_interp_accel $xacc, gsl_interp_accel $yacc, num64 $z is rw --> int32) is native(LIB) is export { * }
sub gsl_interp2d_eval_extrap(gsl_interp2d $interp, CArray[num64] $xa, CArray[num64] $ya, CArray[num64] $za,
    num64 $x, num64 $y, gsl_interp_accel $xacc, gsl_interp_accel $yacc --> num64) is native(LIB) is export { * }
sub gsl_interp2d_eval_extrap_e(gsl_interp2d $interp, CArray[num64] $xa, CArray[num64] $ya, CArray[num64] $za, num64 $x,
    num64 $y, gsl_interp_accel $xacc, gsl_interp_accel $yacc, num64 $z is rw --> int32) is native(LIB) is export { * }
sub gsl_interp2d_eval_deriv_x(gsl_interp2d $interp, CArray[num64] $xa, CArray[num64] $ya, CArray[num64] $za,
    num64 $x, num64 $y, gsl_interp_accel $xacc, gsl_interp_accel $yacc --> num64) is native(LIB) is export { * }
sub gsl_interp2d_eval_deriv_x_e(gsl_interp2d $interp, CArray[num64] $xa, CArray[num64] $ya, CArray[num64] $za, num64 $x,
    num64 $y, gsl_interp_accel $xacc, gsl_interp_accel $yacc, num64 $d is rw --> int32) is native(LIB) is export { * }
sub gsl_interp2d_eval_deriv_y(gsl_interp2d $interp, CArray[num64] $xa, CArray[num64] $ya, CArray[num64] $za,
    num64 $x, num64 $y, gsl_interp_accel $xacc, gsl_interp_accel $yacc --> num64) is native(LIB) is export { * }
sub gsl_interp2d_eval_deriv_y_e(gsl_interp2d $interp, CArray[num64] $xa, CArray[num64] $ya, CArray[num64] $za, num64 $x,
    num64 $y, gsl_interp_accel $xacc, gsl_interp_accel $yacc, num64 $d is rw --> int32) is native(LIB) is export { * }
sub gsl_interp2d_eval_deriv_xx(gsl_interp2d $interp, CArray[num64] $xa, CArray[num64] $ya, CArray[num64] $za,
    num64 $x, num64 $y, gsl_interp_accel $xacc, gsl_interp_accel $yacc --> num64) is native(LIB) is export { * }
sub gsl_interp2d_eval_deriv_xx_e(gsl_interp2d $interp, CArray[num64] $xa, CArray[num64] $ya, CArray[num64] $za,
    num64 $x, num64 $y, gsl_interp_accel $xacc, gsl_interp_accel $yacc, num64 $d is rw --> int32)
    is native(LIB) is export { * }
sub gsl_interp2d_eval_deriv_yy(gsl_interp2d $interp, CArray[num64] $xa, CArray[num64] $ya, CArray[num64] $za,
    num64 $x, num64 $y, gsl_interp_accel $xacc, gsl_interp_accel $yacc --> num64) is native(LIB) is export { * }
sub gsl_interp2d_eval_deriv_yy_e(gsl_interp2d $interp, CArray[num64] $xa, CArray[num64] $ya, CArray[num64] $za,
    num64 $x, num64 $y, gsl_interp_accel $xacc, gsl_interp_accel $yacc, num64 $d is rw --> int32)
    is native(LIB) is export { * }
sub gsl_interp2d_eval_deriv_xy(gsl_interp2d $interp, CArray[num64] $xa, CArray[num64] $ya, CArray[num64] $za,
    num64 $x, num64 $y, gsl_interp_accel $xacc, gsl_interp_accel $yacc --> num64) is native(LIB) is export { * }
sub gsl_interp2d_eval_deriv_xy_e(gsl_interp2d $interp, CArray[num64] $xa, CArray[num64] $ya, CArray[num64] $za,
    num64 $x, num64 $y, gsl_interp_accel $xacc, gsl_interp_accel $yacc, num64 $d is rw --> int32)
    is native(LIB) is export { * }
# 2D Higher-level Interface
sub mgsl_spline2d_alloc(int32 $type, size_t $xsize, size_t $ysize --> gsl_spline2d) is native(GSLHELPER) is export { * }
sub gsl_spline2d_init(gsl_spline2d $spline, CArray[num64] $xa, CArray[num64] $ya, CArray[num64] $za,
    size_t $xsize, size_t $ysize --> int32) is native(LIB) is export { * }
sub gsl_spline2d_free(gsl_spline2d $spline) is native(LIB) is export { * }
sub gsl_spline2d_name(gsl_spline2d $spline --> Str) is native(LIB) is export { * }
sub gsl_spline2d_min_size(gsl_spline2d $spline --> uint32) is native(LIB) is export { * }
sub gsl_spline2d_eval(gsl_spline2d $spline, num64 $x, num64 $y, gsl_interp_accel $xacc,
    gsl_interp_accel $yacc --> num64) is native(LIB) is export { * }
sub gsl_spline2d_eval_e(gsl_spline2d $spline, num64 $x, num64 $y, gsl_interp_accel $xacc, gsl_interp_accel $yacc,
    num64 $z is rw --> int32) is native(LIB) is export { * }
sub gsl_spline2d_eval_deriv_x(gsl_spline2d $spline, num64 $x, num64 $y, gsl_interp_accel $xacc,
    gsl_interp_accel $yacc --> num64) is native(LIB) is export { * }
sub gsl_spline2d_eval_deriv_x_e(gsl_spline2d $spline, num64 $x, num64 $y, gsl_interp_accel $xacc,
    gsl_interp_accel $yacc, num64 $z is rw --> int32) is native(LIB) is export { * }
sub gsl_spline2d_eval_deriv_y(gsl_spline2d $spline, num64 $x, num64 $y, gsl_interp_accel $xacc,
    gsl_interp_accel $yacc --> num64) is native(LIB) is export { * }
sub gsl_spline2d_eval_deriv_y_e(gsl_spline2d $spline, num64 $x, num64 $y, gsl_interp_accel $xacc,
    gsl_interp_accel $yacc, num64 $z is rw --> int32) is native(LIB) is export { * }
sub gsl_spline2d_eval_deriv_xx(gsl_spline2d $spline, num64 $x, num64 $y, gsl_interp_accel $xacc,
    gsl_interp_accel $yacc --> num64) is native(LIB) is export { * }
sub gsl_spline2d_eval_deriv_xx_e(gsl_spline2d $spline, num64 $x, num64 $y, gsl_interp_accel $xacc,
    gsl_interp_accel $yacc, num64 $z is rw --> int32) is native(LIB) is export { * }
sub gsl_spline2d_eval_deriv_yy(gsl_spline2d $spline, num64 $x, num64 $y, gsl_interp_accel $xacc,
    gsl_interp_accel $yacc --> num64) is native(LIB) is export { * }
sub gsl_spline2d_eval_deriv_yy_e(gsl_spline2d $spline, num64 $x, num64 $y, gsl_interp_accel $xacc,
    gsl_interp_accel $yacc, num64 $z is rw --> int32) is native(LIB) is export { * }
sub gsl_spline2d_eval_deriv_xy(gsl_spline2d $spline, num64 $x, num64 $y, gsl_interp_accel $xacc,
    gsl_interp_accel $yacc --> num64) is native(LIB) is export { * }
sub gsl_spline2d_eval_deriv_xy_e(gsl_spline2d $spline, num64 $x, num64 $y, gsl_interp_accel $xacc,
    gsl_interp_accel $yacc, num64 $z is rw --> int32) is native(LIB) is export { * }
sub gsl_spline2d_set(gsl_spline2d $spline, CArray[num64] $za, size_t $i, size_t $j, num64 $z --> int32) is native(LIB) is export { * }
sub gsl_spline2d_get(gsl_spline2d $spline, CArray[num64] $za, size_t $i, size_t $j --> num64) is native(LIB) is export { * }
