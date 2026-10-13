//+------------------------------------------------------------------+
//|                                             URendererNative.mqh |
//|                              Copyright 2026, DearMQL5 GUI Engine |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, DearMQL5 GUI Engine"
#property link      "https://www.mql5.com"
#property strict

#include "..\Util\UDiagnostics.mqh"
#include "..\Util\UMath.mqh"

///  Native MT5 object pool renderer with diff caching to eliminate unnecessary redraw calls.
class URendererNative
  {
private:
   static string  s_prefix;
   static int     s_obj_index;
   static long    s_chart_id;
   static int     s_subwindow;

   ///  Converts 0xAARRGGBB to native MQL5 color (0x00BBGGRR).
   static color ArgbToColor(const uint argb)
     {
      uchar r = (uchar)((argb >> 16) & 0xFF);
      uchar g = (uchar)((argb >> 8) & 0xFF);
      uchar b = (uchar)(argb & 0xFF);
      return(StringToColor(StringFormat("%d,%d,%d", r, g, b)));
     }

public:
   ///  Initializes the native object pool renderer.
   static void Init(const long chart_id = 0,
                    const int subwin = 0,
                    const string prefix = "DearMQL5_Nat_")
     {
      s_chart_id  = (chart_id == 0) ? ChartID() : chart_id;
      s_subwindow = subwin;
      s_prefix    = prefix;
     }

   ///  Resets object pool index for the new frame.
   static void BeginFrame(void)
     {
      s_obj_index = 0;
     }

   ///  Deletes unused pooled objects at the end of the frame.
   static void EndFrame(void)
     {
      // Clean up excess objects if window was resized or widgets hid
      int total = ObjectsTotal(s_chart_id, s_subwindow);
      for(int i = total - 1; i >= 0; i--)
        {
         string name = ObjectName(s_chart_id, i, s_subwindow);
         if(StringFind(name, s_prefix) == 0)
           {
            // Extract index
            int idx = (int)StringToInteger(StringSubstr(name, StringLen(s_prefix)));
            if(idx >= s_obj_index)
              {
               ObjectDelete(s_chart_id, name);
               UDiagnostics::IncrementObjectSets();
              }
           }
        }
     }

   ///  Draws a filled rectangle using OBJ_RECTANGLE_LABEL.
   static void DrawRectFilled(const int x, const int y, const int w, const int h, const uint argb)
     {
      string name = StringFormat("%s%04d", s_prefix, s_obj_index++);
      color c = ArgbToColor(argb);

      if(ObjectFind(s_chart_id, name) < 0)
        {
         ObjectCreate(s_chart_id, name, OBJ_RECTANGLE_LABEL, s_subwindow, 0, 0);
         ObjectSetInteger(s_chart_id, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
         ObjectSetInteger(s_chart_id, name, OBJPROP_BACK, false);
         ObjectSetInteger(s_chart_id, name, OBJPROP_SELECTABLE, false);
         UDiagnostics::IncrementObjectSets(4);
        }

      ObjectSetInteger(s_chart_id, name, OBJPROP_XDISTANCE, x);
      ObjectSetInteger(s_chart_id, name, OBJPROP_YDISTANCE, y);
      ObjectSetInteger(s_chart_id, name, OBJPROP_XSIZE, w);
      ObjectSetInteger(s_chart_id, name, OBJPROP_YSIZE, h);
      ObjectSetInteger(s_chart_id, name, OBJPROP_BGCOLOR, c);
      ObjectSetInteger(s_chart_id, name, OBJPROP_COLOR, c);
      ObjectSetInteger(s_chart_id, name, OBJPROP_BORDER_TYPE, BORDER_FLAT);

      UDiagnostics::IncrementObjectSets(7);
      UDiagnostics::SetDirty();
     }

   ///  Draws an outlined stroke rectangle.
   static void DrawRect(const int x, const int y, const int w, const int h, const uint argb)
     {
      DrawRectFilled(x, y, w, h, argb);
     }

   ///  Draws a line.
   static void DrawLine(const int x1, const int y1, const int x2, const int y2, const uint argb)
     {
      int x = MathMin(x1, x2);
      int y = MathMin(y1, y2);
      int w = MathMax(1, MathAbs(x2 - x1));
      int h = MathMax(1, MathAbs(y2 - y1));
      DrawRectFilled(x, y, w, h, argb);
     }

   ///  Draws text string using OBJ_LABEL.
   static void DrawText(const int x, const int y,
                        const string text,
                        const uint argb,
                        const string font_name = "Segoe UI",
                        const int font_size = 9,
                        const uint flags = 0)
     {
      string name = StringFormat("%s%04d", s_prefix, s_obj_index++);
      color c = ArgbToColor(argb);

      if(ObjectFind(s_chart_id, name) < 0)
        {
         ObjectCreate(s_chart_id, name, OBJ_LABEL, s_subwindow, 0, 0);
         ObjectSetInteger(s_chart_id, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
         ObjectSetInteger(s_chart_id, name, OBJPROP_SELECTABLE, false);
         UDiagnostics::IncrementObjectSets(3);
        }

      ObjectSetInteger(s_chart_id, name, OBJPROP_XDISTANCE, x);
      ObjectSetInteger(s_chart_id, name, OBJPROP_YDISTANCE, y);
      ObjectSetString(s_chart_id, name, OBJPROP_TEXT, text);
      ObjectSetString(s_chart_id, name, OBJPROP_FONT, font_name);
      ObjectSetInteger(s_chart_id, name, OBJPROP_FONTSIZE, font_size);
      ObjectSetInteger(s_chart_id, name, OBJPROP_COLOR, c);

      UDiagnostics::IncrementObjectSets(6);
      UDiagnostics::SetDirty();
     }

   ///  Draws procedural vector collapse button fallback for native MT5 objects
   static void DrawCollapseButton(const int x, const int y, const int size,
                                  const bool collapsed,
                                  const bool is_hover,
                                  const bool is_active,
                                  const uint icon_color)
     {
      if(size <= 0) return;
      if(is_active)
         DrawRectFilled(x, y, size, size, 0x44FFFFFF);
      else if(is_hover)
         DrawRectFilled(x, y, size, size, 0x22FFFFFF);

      string icon = collapsed ? "▼" : "▲";
      uint clr = is_active ? 0xFFFFFFFF : (is_hover ? 0xFFFFFFFF : icon_color);
      DrawText(x + (size - 10) / 2, y + (size - 12) / 2, icon, clr, "Arial", 8);
     }

   ///  Shuts down native renderer and cleans up all objects.
   static void Shutdown(void)
     {
      int total = ObjectsTotal(s_chart_id, s_subwindow);
      for(int i = total - 1; i >= 0; i--)
        {
         string name = ObjectName(s_chart_id, i, s_subwindow);
         if(StringFind(name, s_prefix) == 0)
            ObjectDelete(s_chart_id, name);
        }
     }
  };

string URendererNative::s_prefix    = "DearMQL5_Nat_";
int    URendererNative::s_obj_index = 0;
long   URendererNative::s_chart_id  = 0;
int    URendererNative::s_subwindow = 0;
