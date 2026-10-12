//+------------------------------------------------------------------+
//|                                                      UHeader.mqh |
//|                                  Copyright 2026, DearMQL5 GUI Engine |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, DearMQL5 GUI Engine"
#property link      "https://www.mql5.com"
#property strict

#include "UWidget.mqh"
#include "..\Core\UState.mqh"

///  Collapsible header widget for grouping settings and dashboard sections.
class UHeader
  {
public:
   ///  Computes header dimensions spanning full available width.
   static void GetBoundingBox(int &out_w, int &out_h)
     {
      SUTheme th = UTheme::Get();
      out_w = ULayout::GetAvailableWidth();
      out_h = th.widget_height + 2;
     }

   ///  Gets or toggles the collapsed/expanded state.
   static bool ProcessHeader(const ulong id, const bool clicked, const bool default_open = true)
     {
      long state = UState::GetInt(id, default_open ? 1 : 0);
      if(clicked)
        {
         state = (state == 0) ? 1 : 0;
         UState::SetInt(id, state);
        }
      return(state != 0);
     }
  };
