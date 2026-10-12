//+------------------------------------------------------------------+
//|                                                 UProgressBar.mqh |
//|                                  Copyright 2026, DearMQL5 GUI Engine |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, DearMQL5 GUI Engine"
#property link      "https://www.mql5.com"
#property strict

#include "UWidget.mqh"
#include "..\Util\UMath.mqh"

///  Visual progress bar for prop firm drawdown limits and target metrics.
class UProgressBar
  {
public:
   ///  Computes progress bar dimensions.
   static void GetBoundingBox(const int custom_w, const int custom_h,
                              int &out_w, int &out_h)
     {
      SUTheme th = UTheme::Get();
      out_w = (custom_w > 0) ? custom_w : ULayout::GetAvailableWidth();
      out_h = (custom_h > 0) ? custom_h : 14;
     }

   ///  Resolves progress bar color depending on fill percentage.
   static uint GetProgressColor(const double fraction, const bool alert_on_high = false)
     {
      SUTheme th = UTheme::Get();
      if(!alert_on_high)
         return(th.accent);

      // Warning color ramp for Drawdown / Daily Loss
      if(fraction >= 0.85) return(th.danger);
      if(fraction >= 0.60) return(0xFFE5C07B); // Amber / Yellow
      return(th.success);
     }
  };
