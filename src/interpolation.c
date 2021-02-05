#include <gsl/gsl_interp.h>
#include <gsl/gsl_spline.h>
#include <gsl/gsl_interp2d.h>
#include <gsl/gsl_spline2d.h>

const gsl_interp_type   *types[7];
const gsl_interp2d_type *types2d[2];

void init(void)
{
  types[0]   = gsl_interp_linear;
  types[1]   = gsl_interp_polynomial;
  types[2]   = gsl_interp_cspline;
  types[3]   = gsl_interp_cspline_periodic;
  types[4]   = gsl_interp_akima;
  types[5]   = gsl_interp_akima_periodic;
  types[6]   = gsl_interp_steffen;
  types2d[0] = gsl_interp2d_bilinear;
  types2d[1] = gsl_interp2d_bicubic;
}

/* 1D */
gsl_interp *mgsl_interp_alloc(int type, size_t size)
{
  if(types[0] == NULL) init();
  return gsl_interp_alloc(types[type], size);
}

unsigned int mgsl_interp_type_min_size(int type)
{
  if(types[0] == NULL) init();
  return gsl_interp_type_min_size(types[type]);
}

gsl_spline *mgsl_spline_alloc(int type, size_t size)
{
  if(types[0] == NULL) init();
  return gsl_spline_alloc(types[type], size);
}

/* 2D */
gsl_interp2d *mgsl_interp2d_alloc(int type, size_t xsize, size_t ysize)
{
  if(types[0] == NULL) init();
  return gsl_interp2d_alloc(types2d[type], xsize, ysize);
}

unsigned int mgsl_interp2d_type_min_size(int type)
{
  if(types[0] == NULL) init();
  return gsl_interp2d_type_min_size(types2d[type]);
}

gsl_spline2d *mgsl_spline2d_alloc(int type, size_t xsize, size_t ysize)
{
  if(types[0] == NULL) init();
  return gsl_spline2d_alloc(types2d[type], xsize, ysize);
}
