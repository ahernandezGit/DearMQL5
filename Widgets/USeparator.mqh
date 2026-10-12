//+------------------------------------------------------------------+
//|                                                    USeparator.mqh |
//|                                  Copyright 2026, DearMQL5 GUI Engine |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, DearMQL5 GUI Engine"
#property link      "https://www.mql5.com"
#property strict

#include "..\Core\UTheme.mqh"
#include "..\Core\ULayout.mqh"

///  Horizontal line separator widget.
class USeparator
  {
public:
   ///  Allocates space for a horizontal divider.
   static void GetBoundingBox(int &out_w, int &out_h)
     {
      out_w = ULayout::GetAvailableWidth();
      out_h = 4;
     }
  };
