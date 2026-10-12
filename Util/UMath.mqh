//+------------------------------------------------------------------+
//|                                                        UMath.mqh |
//|                                  Copyright 2026, DearMQL5 GUI Engine |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, DearMQL5 GUI Engine"
#property link      "https://www.mql5.com"
#property strict

///  Fast math and geometry utilities for immediate-mode GUI operations.
class UMath
  {
public:
   ///  Clamps an integer value within [min_val, max_val].
   static int Clamp(const int val, const int min_val, const int max_val)
     {
      if(val < min_val) return(min_val);
      if(val > max_val) return(max_val);
      return(val);
     }

   ///  Clamps a double value within [min_val, max_val].
   static double Clamp(const double val, const double min_val, const double max_val)
     {
      if(val < min_val) return(min_val);
      if(val > max_val) return(max_val);
      return(val);
     }

   ///  Linear interpolation between a and b by factor t [0.0, 1.0].
   static double Lerp(const double a, const double b, const double t)
     {
      return(a + (b - a) * Clamp(t, 0.0, 1.0));
     }

   ///  Smoothstep interpolation with Hermite smoothing.
   static double SmoothStep(const double edge0, const double edge1, const double x)
     {
      double t = Clamp((x - edge0) / (edge1 - edge0), 0.0, 1.0);
      return(t * t * (3.0 - 2.0 * t));
     }

   ///  Checks if a 2D point (px, py) is inside a rectangle.
   static bool PointInRect(const int px, const int py,
                           const int rx, const int ry,
                           const int rw, const int rh)
     {
      return(px >= rx && px < (rx + rw) && py >= ry && py < (ry + rh));
     }
  };
