//+------------------------------------------------------------------+
//|                                                      ULayout.mqh |
//|                                  Copyright 2026, DearMQL5 GUI Engine |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, DearMQL5 GUI Engine"
#property link      "https://www.mql5.com"
#property strict

#include "UTheme.mqh"

///  Automatic cursor positioning and layout coordinator for immediate-mode rendering.
class ULayout
  {
private:
   static int     s_window_x;
   static int     s_window_y;
   static int     s_window_w;
   static int     s_window_h;
   static int     s_cursor_x;
   static int     s_cursor_y;
   static int     s_prev_item_x;
   static int     s_prev_item_y;
   static int     s_prev_item_w;
   static int     s_prev_item_h;
   static int     s_indent_level;
   static bool    s_same_line;
   static int     s_same_line_spacing;

public:
   ///  Begins layout for a window boundary.
   static void BeginWindow(const int x, const int y, const int w, const int h, const int title_h)
     {
      SUTheme th = UTheme::Get();
      s_window_x          = x;
      s_window_y          = y;
      s_window_w          = w;
      s_window_h          = h;
      s_cursor_x          = x + th.padding_x;
      s_cursor_y          = y + title_h + th.padding_y;
      s_indent_level      = 0;
      s_same_line         = false;
      s_same_line_spacing = 0;
      s_prev_item_x       = s_cursor_x;
      s_prev_item_y       = s_cursor_y;
      s_prev_item_w       = 0;
      s_prev_item_h       = 0;
     }

   ///  Directs the next widget to be placed on the same horizontal line.
   static void SameLine(const int spacing = -1)
     {
      SUTheme th = UTheme::Get();
      s_same_line         = true;
      s_same_line_spacing = (spacing >= 0) ? spacing : th.item_spacing_x;
     }

   ///  Increases the horizontal indentation for subsequent widgets.
   static void Indent(const int amount = 16)
     {
      s_indent_level += amount;
      s_cursor_x     += amount;
     }

   ///  Restores indentation.
   static void Unindent(const int amount = 16)
     {
      s_indent_level = MathMax(0, s_indent_level - amount);
      s_cursor_x     = MathMax(s_window_x + UTheme::Get().padding_x, s_cursor_x - amount);
     }

   ///  Reserves a bounding box for a widget and advances cursor accordingly.
   static void AllocateSpace(const int w, const int h, int &out_x, int &out_y)
     {
      SUTheme th = UTheme::Get();

      if(s_same_line)
        {
         out_x = s_prev_item_x + s_prev_item_w + s_same_line_spacing;
         out_y = s_prev_item_y;
         s_same_line = false;
        }
      else
        {
         out_x = s_window_x + th.padding_x + s_indent_level;
         out_y = s_cursor_y;
        }

      // Record this item's metrics
      s_prev_item_x = out_x;
      s_prev_item_y = out_y;
      s_prev_item_w = w;
      s_prev_item_h = h;

      // Advance cursor for next item
      s_cursor_x = out_x + w + th.item_spacing_x;
      s_cursor_y = MathMax(s_cursor_y, out_y + h + th.item_spacing_y);
     }

   ///  Returns the available horizontal width for widgets in the current window.
   static int GetAvailableWidth(void)
     {
      SUTheme th = UTheme::Get();
      return(MathMax(20, s_window_w - (th.padding_x * 2) - s_indent_level));
     }

   ///  Returns the current cursor X position.
   static int GetCursorX(void) { return(s_cursor_x); }

   ///  Returns the current cursor Y position.
   static int GetCursorY(void) { return(s_cursor_y); }

   ///  Manually sets cursor X position.
   static void SetCursorX(const int x) { s_cursor_x = x; }

   ///  Manually sets cursor Y position.
   static void SetCursorY(const int y) { s_cursor_y = y; }
  };

int  ULayout::s_window_x          = 0;
int  ULayout::s_window_y          = 0;
int  ULayout::s_window_w          = 0;
int  ULayout::s_window_h          = 0;
int  ULayout::s_cursor_x          = 0;
int  ULayout::s_cursor_y          = 0;
int  ULayout::s_prev_item_x       = 0;
int  ULayout::s_prev_item_y       = 0;
int  ULayout::s_prev_item_w       = 0;
int  ULayout::s_prev_item_h       = 0;
int  ULayout::s_indent_level      = 0;
bool ULayout::s_same_line         = false;
int  ULayout::s_same_line_spacing = 0;
