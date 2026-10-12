//+------------------------------------------------------------------+
//|                                                  UInputState.mqh |
//|                                  Copyright 2026, DearMQL5 GUI Engine |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, DearMQL5 GUI Engine"
#property link      "https://www.mql5.com"
#property strict

///  Aggregates mouse and keyboard input state from OnChartEvent.
class UInputState
  {
private:
   static int     s_mouse_x;
   static int     s_mouse_y;
   static int     s_prev_mouse_x;
   static int     s_prev_mouse_y;
   static int     s_delta_x;
   static int     s_delta_y;
   static bool    s_mouse_down;
   static bool    s_prev_mouse_down;
   static bool    s_mouse_clicked;
   static bool    s_mouse_released;
   static ulong   s_hot_id;
   static ulong   s_active_id;
   static ulong   s_prev_active_id;
   static ulong   s_focused_id;
   static ulong   s_drag_owner_id;
   static bool    s_chart_scroll_disabled;
   static long    s_chart_id;

public:
   ///  Updates mouse position and button state from CHARTEVENT_MOUSE_MOVE.
   static void OnMouseMove(const int x, const int y, const uint flags)
     {
      s_mouse_x    = x;
      s_mouse_y    = y;
      s_mouse_down = ((flags & 1) != 0); // Left mouse button bit
     }

   ///  Sets target chart ID for chart property controls.
   static void SetChartId(const long cid) { s_chart_id = cid; }

   ///  Advances input state at the beginning of each frame.
   static void NewFrame(void)
     {
      s_mouse_clicked  = (s_mouse_down && !s_prev_mouse_down);
      s_mouse_released = (!s_mouse_down && s_prev_mouse_down);

      // Compute frame mouse movement delta BEFORE updating prev coordinates
      s_delta_x = s_mouse_x - s_prev_mouse_x;
      s_delta_y = s_mouse_y - s_prev_mouse_y;

      s_prev_mouse_x    = s_mouse_x;
      s_prev_mouse_y    = s_mouse_y;
      s_prev_mouse_down = s_mouse_down;

      // Retain active id into prev_active for widgets to catch release events
      s_prev_active_id  = s_active_id;

      // Reset hot candidate for next frame's hit tests
      s_hot_id = 0;
     }

   ///  Finalizes input state at the end of each frame.
   static void EndFrame(void)
     {
      // Release active capture once frame finishes if button was released or not down
      if(s_mouse_released || !s_mouse_down)
        {
         s_active_id = 0;
        }
     }

   ///  Manually releases active widget capture.
   static void ReleaseActive(void)
     {
      s_active_id = 0;
     }

   ///  Returns current mouse X coordinate in chart pixels.
   static int MouseX(void) { return(s_mouse_x); }

   ///  Returns current mouse Y coordinate in chart pixels.
   static int MouseY(void) { return(s_mouse_y); }

   ///  Returns mouse movement delta X since previous frame.
   static int DeltaX(void) { return(s_delta_x); }

   ///  Returns mouse movement delta Y since previous frame.
   static int DeltaY(void) { return(s_delta_y); }

   ///  Returns whether left mouse button is currently held down.
   static bool IsMouseDown(void) { return(s_mouse_down); }

   ///  Returns true only on the single frame when left button was pressed down.
   static bool IsMouseClicked(void) { return(s_mouse_clicked); }

   ///  Returns true only on the single frame when left button was released.
   static bool IsMouseReleased(void) { return(s_mouse_released); }

   ///  Sets the widget ID currently under the cursor (hot).
   static void SetHot(const ulong id) { s_hot_id = id; }

   ///  Returns the ID of the widget under the cursor.
   static ulong GetHot(void) { return(s_hot_id); }

   ///  Sets the widget ID currently capturing user interaction (active).
   static void SetActive(const ulong id) { s_active_id = id; }

   ///  Returns the widget ID currently active.
   static ulong GetActive(void) { return(s_active_id); }

   ///  Returns the widget ID that was active in the previous frame.
   static ulong GetPrevActive(void) { return(s_prev_active_id); }

   ///  Sets the widget ID currently holding keyboard focus.
   static void SetFocused(const ulong id) { s_focused_id = id; }

   ///  Returns the widget ID holding keyboard focus.
   static ulong GetFocused(void) { return(s_focused_id); }

   ///  Sets the ID of the window/hub currently owning drag.
   static void SetDragOwner(const ulong id) { s_drag_owner_id = id; }

   ///  Returns the ID of the window/hub currently owning drag.
   static ulong GetDragOwner(void) { return(s_drag_owner_id); }

   ///  Disables chart mouse scrolling while dragging a HUD to avoid fighting MT5.
   static void DisableChartScroll(const long chart_id = 0)
     {
      long cid = (chart_id == 0) ? (s_chart_id == 0 ? ChartID() : s_chart_id) : chart_id;
      if(!s_chart_scroll_disabled)
        {
         ChartSetInteger(cid, CHART_MOUSE_SCROLL, false);
         s_chart_scroll_disabled = true;
        }
     }

   ///  Re-enables chart mouse scrolling after dragging completes.
   static void EnableChartScroll(const long chart_id = 0)
     {
      long cid = (chart_id == 0) ? (s_chart_id == 0 ? ChartID() : s_chart_id) : chart_id;
      if(s_chart_scroll_disabled)
        {
         ChartSetInteger(cid, CHART_MOUSE_SCROLL, true);
         s_chart_scroll_disabled = false;
        }
     }
  };

int   UInputState::s_mouse_x                = 0;
int   UInputState::s_mouse_y                = 0;
int   UInputState::s_prev_mouse_x           = 0;
int   UInputState::s_prev_mouse_y           = 0;
int   UInputState::s_delta_x                = 0;
int   UInputState::s_delta_y                = 0;
bool  UInputState::s_mouse_down             = false;
bool  UInputState::s_prev_mouse_down        = false;
bool  UInputState::s_mouse_clicked          = false;
bool  UInputState::s_mouse_released         = false;
ulong UInputState::s_hot_id                 = 0;
ulong UInputState::s_active_id              = 0;
ulong UInputState::s_prev_active_id         = 0;
ulong UInputState::s_focused_id             = 0;
ulong UInputState::s_drag_owner_id          = 0;
bool  UInputState::s_chart_scroll_disabled  = false;
long  UInputState::s_chart_id               = 0;
