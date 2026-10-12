//+------------------------------------------------------------------+
//|                                                       ULabel.mqh |
//|                                  Copyright 2026, DearMQL5 GUI Engine |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, DearMQL5 GUI Engine"
#property link      "https://www.mql5.com"
#property strict

#include "..\Core\UTheme.mqh"
#include "..\Core\ULayout.mqh"
#include "..\Render\UFont.mqh"

///  Text rendering widgets for labels, metrics and status indicators.
class ULabel
  {
public:
   ///  Computes layout bounding box for a text string.
   static void GetBoundingBox(const string text, int &out_w, int &out_h)
     {
      SUTheme th = UTheme::Get();
      out_w = UFont::MeasureTextWidth(text, th.font_size, th.font_name);
      out_h = th.widget_height;
     }
  };
