//+------------------------------------------------------------------+
//|                                                      UWidget.mqh |
//|                                  Copyright 2026, DearMQL5 GUI Engine |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, DearMQL5 GUI Engine"
#property link      "https://www.mql5.com"
#property strict

#include "..\Core\UTheme.mqh"
#include "..\Core\UInputState.mqh"
#include "..\Core\UIdStack.mqh"
#include "..\Core\ULayout.mqh"
#include "..\Util\UMath.mqh"

///  Base helper for immediate-mode widget bounding, hit-testing and hot/active state.
class UWidget
  {
public:
   ///  Tests interaction state for a given rectangular boundary and ID.
   static void Behavior(const ulong id,
                        const int x, const int y, const int w, const int h,
                        bool &out_hovered, bool &out_clicked, bool &out_active)
     {
      int mx = UInputState::MouseX();
      int my = UInputState::MouseY();

      bool in_rect = UMath::PointInRect(mx, my, x, y, w, h);

      // Only allow setting hot if no other widget is currently active (captured)
      ulong active = UInputState::GetActive();
      if(in_rect && (active == 0 || active == id))
         UInputState::SetHot(id);

      out_hovered = (UInputState::GetHot() == id);

      if(out_hovered && UInputState::IsMouseClicked())
        {
         UInputState::SetActive(id);
         UInputState::SetFocused(id);
        }

      // Widget is active if currently active or was active when released in this frame
      out_active = (UInputState::GetActive() == id || UInputState::GetPrevActive() == id);
      out_clicked = (out_hovered && UInputState::IsMouseReleased() && out_active);

      if(out_clicked)
        {
         UInputState::ReleaseActive();
        }
     }
  };
