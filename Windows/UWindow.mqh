//+------------------------------------------------------------------+
//|                                                      UWindow.mqh |
//|                                  Copyright 2026, DearMQL5 GUI Engine |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, DearMQL5 GUI Engine"
#property link      "https://www.mql5.com"
#property strict

#include "..\Core\UTheme.mqh"
#include "..\Core\UInputState.mqh"
#include "..\Core\UState.mqh"
#include "..\Core\UIdStack.mqh"
#include "..\Core\ULayout.mqh"
#include "..\Util\UMath.mqh"
#include "UWindowManager.mqh"
#include "..\Widgets\UWidget.mqh"

#ifdef UI_BACKEND_CANVAS
   #include "..\Render\URendererCanvas.mqh"
#endif

// Window flags bitmask
enum ENUM_U_WINDOW_FLAGS
  {
   U_WINDOW_NONE            = 0,
   U_WINDOW_NO_TITLEBAR     = 1 << 0,
   U_WINDOW_NO_MOVE         = 1 << 1,
   U_WINDOW_NO_COLLAPSE     = 1 << 2,
   U_WINDOW_NO_CLOSE        = 1 << 3,
   U_WINDOW_AUTO_RESIZE     = 1 << 4
  };

///  Immediate-mode window container supporting dragging, collapsing, and clipping.
class UWindow
  {
private:
   static ulong  s_current_win_id;
   static ulong  s_dragging_win_id;
   static ulong  s_candidate_drag_win_id;
   static int    s_anchor_mouse_x;
   static int    s_anchor_mouse_y;
   static int    s_anchor_win_x;
   static int    s_anchor_win_y;
   static string s_current_title;

public:
   ///  Processes window lifecycle and returns whether the window body should be drawn.
   static bool Begin(const string title,
                     bool &io_open,
                     int default_x, int default_y,
                     int default_w, int default_h,
                     const uint flags,
                     int &out_x, int &out_y,
                     int &out_w, int &out_h,
                     bool &out_collapsed)
     {
      if(!io_open) return(false);

      ulong win_id = UIdStack::GetId(title);
      UIdStack::Push(title);
      s_current_win_id = win_id;
      s_current_title  = title;

      SUTheme th = UTheme::Get();

      // Retrieve persistent position and dimensions from retained state
      // If uninitialized in UState, try restoring from GlobalVariables via UWindowManager
      if(UState::GetInt(win_id + 1, -999999) == -999999)
        {
         int saved_gx = 0, saved_gy = 0;
         if(UWindowManager::RestoreWindowPosition(title, saved_gx, saved_gy))
           {
            UState::SetInt(win_id + 1, saved_gx);
            UState::SetInt(win_id + 2, saved_gy);
           }
         else
           {
            UState::SetInt(win_id + 1, default_x);
            UState::SetInt(win_id + 2, default_y);
           }
        }

      int x = (int)UState::GetInt(win_id + 1, default_x);
      int y = (int)UState::GetInt(win_id + 2, default_y);
      int w = default_w;
      int h = default_h;
      UState::SetInt(win_id + 3, w);
      UState::SetInt(win_id + 4, h);
      bool collapsed = (UState::GetInt(win_id + 5, 0) != 0);

      int title_h = ((flags & U_WINDOW_NO_TITLEBAR) != 0) ? 0 : th.window_title_height;
      int cur_h   = collapsed ? title_h : h;

      // 1. Process Collapse button in titlebar FIRST to prevent drag collision
      bool mouse_on_col_btn = false;
      if(title_h > 0 && (flags & U_WINDOW_NO_COLLAPSE) == 0)
        {
         ulong col_id   = win_id + 20;
         int btn_size   = title_h - 6;
         int btn_x      = x + w - btn_size - 6;
         int btn_y      = y + 3;

         mouse_on_col_btn = UMath::PointInRect(UInputState::MouseX(), UInputState::MouseY(),
                                               btn_x, btn_y, btn_size, btn_size);

         bool c_hov = false, c_clk = false, c_act = false;
         UWidget::Behavior(col_id, btn_x, btn_y, btn_size, btn_size, c_hov, c_clk, c_act);
         UState::SetInt(win_id + 6, c_hov ? 1 : 0);
         UState::SetInt(win_id + 7, c_act ? 1 : 0);
         if(c_clk)
           {
            collapsed = !collapsed;
            UState::SetInt(win_id + 5, collapsed ? 1 : 0);
            cur_h = collapsed ? title_h : h;
           }
        }
      else
        {
         UState::SetInt(win_id + 6, 0);
         UState::SetInt(win_id + 7, 0);
        }

      // 2. Active Dragging Engine (Absolute Anchor Drag)
      if(s_dragging_win_id == win_id)
        {
         if(UInputState::IsMouseDown())
           {
            int dx = UInputState::MouseX() - s_anchor_mouse_x;
            int dy = UInputState::MouseY() - s_anchor_mouse_y;
            int new_x = s_anchor_win_x + dx;
            int new_y = s_anchor_win_y + dy;

            // Clamp to chart boundaries
            int chart_w = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
            int chart_h = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
            x = UMath::Clamp(new_x, 0, MathMax(0, chart_w - 40));
            y = UMath::Clamp(new_y, 0, MathMax(0, chart_h - title_h));

            UState::SetInt(win_id + 1, x);
            UState::SetInt(win_id + 2, y);

            #ifdef UI_BACKEND_CANVAS
               URendererCanvas::SetWindowPosition(win_id, x, y);
            #endif
           }
         else
           {
            // Drag ended on mouse release
            s_dragging_win_id = 0;
            UInputState::SetDragOwner(0);
            UInputState::EnableChartScroll();
            UWindowManager::SaveWindowPosition(title, x, y);
           }
        }
      else if((flags & U_WINDOW_NO_MOVE) == 0 && s_dragging_win_id == 0 && UInputState::GetDragOwner() == 0)
        {
         // 3. Initiate Drag Detection on Mouse Click anywhere over widget/hub
         bool mouse_in_window = UMath::PointInRect(UInputState::MouseX(), UInputState::MouseY(), x, y, w, cur_h);
         if(UInputState::IsMouseClicked() && mouse_in_window && !mouse_on_col_btn)
           {
            s_candidate_drag_win_id = win_id;
            s_anchor_mouse_x = UInputState::MouseX();
            s_anchor_mouse_y = UInputState::MouseY();
            s_anchor_win_x   = x;
            s_anchor_win_y   = y;
           }
        }

      out_x = x;
      out_y = y;
      out_w = w;
      out_h = cur_h;
      out_collapsed = collapsed;

      // Initialize layout within window boundary
      ULayout::BeginWindow(x, y, w, h, title_h);

      return(!collapsed);
     }

   ///  Convenient Begin overload when layout coordinates are not requested by caller.
   static bool Begin(const string title,
                     bool &io_open,
                     const int default_x, const int default_y,
                     const int default_w, const int default_h,
                     const uint flags = U_WINDOW_NONE)
     {
      int ox, oy, ow, oh;
      bool oc;
      return(Begin(title, io_open, default_x, default_y, default_w, default_h, flags, ox, oy, ow, oh, oc));
     }

   ///  Ends window scope and resolves candidate window drag.
   static void End(void)
     {
      // If this window was candidate for drag, check if any interactive child widget consumed the click
      if(s_candidate_drag_win_id == s_current_win_id && s_current_win_id != 0)
        {
         ulong active = UInputState::GetActive();
         if(active == 0 || active == s_current_win_id)
           {
            s_dragging_win_id = s_candidate_drag_win_id;
            UInputState::SetDragOwner(s_dragging_win_id);
            UInputState::SetActive(s_dragging_win_id);
            UInputState::DisableChartScroll();

            #ifdef UI_BACKEND_CANVAS
               URendererCanvas::BringWindowToFront(s_dragging_win_id);
            #endif
           }
         s_candidate_drag_win_id = 0;
        }

      s_current_win_id = 0;
      s_current_title  = "";
      UIdStack::Pop();
     }

   ///  Resets window scope cleanly if caller skipped End() or window collapsed.
   static void ResetScope(void)
     {
      if(s_current_win_id != 0)
        {
         s_current_win_id        = 0;
         s_candidate_drag_win_id = 0;
         s_current_title         = "";
         UIdStack::Reset();
        }
     }

   ///  Checks if collapse button of given window is currently hovered.
   static bool IsCollapseHovered(const ulong win_id)
     {
      return(UState::GetInt(win_id + 6, 0) != 0);
     }

   ///  Checks if collapse button of given window is currently active (pressed).
   static bool IsCollapseActive(const ulong win_id)
     {
      return(UState::GetInt(win_id + 7, 0) != 0);
     }

   ///  Checks if the given window is currently collapsed.
   static bool IsWindowCollapsed(const ulong win_id)
     {
      return(UState::GetInt(win_id + 5, 0) != 0);
     }

   ///  Programmatically sets the collapse state of the window.
   static void SetWindowCollapsed(const ulong win_id, const bool collapsed)
     {
      UState::SetInt(win_id + 5, collapsed ? 1 : 0);
     }
  };

ulong  UWindow::s_current_win_id        = 0;
ulong  UWindow::s_dragging_win_id       = 0;
ulong  UWindow::s_candidate_drag_win_id = 0;
int    UWindow::s_anchor_mouse_x        = 0;
int    UWindow::s_anchor_mouse_y        = 0;
int    UWindow::s_anchor_win_x          = 0;
int    UWindow::s_anchor_win_y          = 0;
string UWindow::s_current_title         = "";
