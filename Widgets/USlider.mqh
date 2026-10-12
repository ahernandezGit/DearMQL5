//+------------------------------------------------------------------+
//|                                                      USlider.mqh |
//|                                  Copyright 2026, DearMQL5 GUI Engine |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, DearMQL5 GUI Engine"
#property link      "https://www.mql5.com"
#property strict

#include "UWidget.mqh"
#include "..\Render\UFont.mqh"
#include "..\Util\UMath.mqh"

///  Horizontal draggable slider for numeric parameter adjustment.
class USlider
  {
public:
   ///  Computes slider dimensions including trailing label.
   static void GetBoundingBox(const string label, const int custom_w,
                              int &out_w, int &out_h)
     {
      SUTheme th = UTheme::Get();
      out_w = (custom_w > 0) ? custom_w : ULayout::GetAvailableWidth();
      out_h = th.widget_height;
     }

   ///  Updates slider value based on mouse dragging position across the track.
   static bool ProcessDrag(const int x, const int w,
                           const double min_val, const double max_val,
                           double &io_val)
     {
      int mx = UInputState::MouseX();
      double fraction = (double)(mx - x) / (double)w;
      fraction = UMath::Clamp(fraction, 0.0, 1.0);

      double new_val = min_val + fraction * (max_val - min_val);
      if(new_val != io_val)
        {
         io_val = new_val;
         return(true);
        }
      return(false);
     }
  };
