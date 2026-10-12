//+------------------------------------------------------------------+
//|                                                        UFont.mqh |
//|                                  Copyright 2026, DearMQL5 GUI Engine |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, DearMQL5 GUI Engine"
#property link      "https://www.mql5.com"
#property strict

///  Font measurement and metrics caching helper.
class UFont
  {
public:
   ///  Estimates the pixel width of a text string under a given font and point size.
   static int MeasureTextWidth(const string text, const int font_size = 9, const string font_name = "Segoe UI")
     {
      int len = StringLen(text);
      if(len == 0) return(0);

      // Average character width heuristic for Segoe UI / proportional sans-serif:
      // ~0.58 * font_size * 1.33 px per point
      double char_width = (double)font_size * 0.72;
      return((int)MathCeil(len * char_width));
     }

   ///  Estimates the line height of text under a given font and point size.
   static int MeasureTextHeight(const int font_size = 9)
     {
      return((int)MathCeil(font_size * 1.5));
     }
  };
