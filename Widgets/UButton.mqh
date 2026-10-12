//+------------------------------------------------------------------+
//|                                                      UButton.mqh |
//|                                  Copyright 2026, DearMQL5 GUI Engine |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, DearMQL5 GUI Engine"
#property link      "https://www.mql5.com"
#property strict

#include "UWidget.mqh"
#include "..\Render\UFont.mqh"

///  Clickable button widget with hover, active feedback and auto-sizing.
class UButton
  {
public:
   ///  Computes button dimensions based on label and padding.
   static void GetBoundingBox(const string label, const int custom_w, const int custom_h,
                              int &out_w, int &out_h)
     {
      SUTheme th = UTheme::Get();
      if(custom_w > 0)
         out_w = custom_w;
      else
         out_w = UFont::MeasureTextWidth(label, th.font_size, th.font_name) + (th.padding_x * 2);

      out_h = (custom_h > 0) ? custom_h : th.widget_height;
     }

   ///  Resolves button background color based on interaction state.
   static uint GetStateColor(const bool hovered, const bool active, const uint base_color = 0)
     {
      SUTheme th = UTheme::Get();
      if(base_color != 0)
        {
         if(active)  return(base_color);
         if(hovered) return(base_color | 0x202020);
         return(base_color);
        }

      if(active)  return(th.button_active);
      if(hovered) return(th.button_hover);
      return(th.button_bg);
     }
  };
