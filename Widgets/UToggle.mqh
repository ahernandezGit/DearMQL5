//+------------------------------------------------------------------+
//|                                                      UToggle.mqh |
//|                                  Copyright 2026, DearMQL5 GUI Engine |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, DearMQL5 GUI Engine"
#property link      "https://www.mql5.com"
#property strict

#include "UWidget.mqh"
#include "..\Render\UFont.mqh"

///  Toggle switch widget for boolean flags.
class UToggle
  {
public:
   ///  Computes toggle switch dimensions including label.
   static void GetBoundingBox(const string label, int &out_w, int &out_h)
     {
      SUTheme th = UTheme::Get();
      int switch_w = 34;
      int text_w = (StringLen(label) > 0) ? UFont::MeasureTextWidth(label, th.font_size, th.font_name) + th.item_spacing_x : 0;
      out_w = switch_w + text_w;
      out_h = th.widget_height;
     }
  };
