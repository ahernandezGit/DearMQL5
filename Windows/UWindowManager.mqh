//+------------------------------------------------------------------+
//|                                              UWindowManager.mqh |
//|                              Copyright 2026, DearMQL5 GUI Engine |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, DearMQL5 GUI Engine"
#property link      "https://www.mql5.com"
#property strict

///  Multi-window coordinator with z-ordering and persistent chart state.
class UWindowManager
  {
public:
   ///  Saves window coordinates to GlobalVariables so layout survives timeframe switches.
   static void SaveWindowPosition(const string win_title, const int x, const int y)
     {
      string gv_x = StringFormat("DearMQL5_%s_X", win_title);
      string gv_y = StringFormat("DearMQL5_%s_Y", win_title);
      GlobalVariableSet(gv_x, x);
      GlobalVariableSet(gv_y, y);
     }

   ///  Restores window coordinates from GlobalVariables.
   static bool RestoreWindowPosition(const string win_title, int &out_x, int &out_y)
     {
      string gv_x = StringFormat("DearMQL5_%s_X", win_title);
      string gv_y = StringFormat("DearMQL5_%s_Y", win_title);
      if(GlobalVariableCheck(gv_x) && GlobalVariableCheck(gv_y))
        {
         out_x = (int)GlobalVariableGet(gv_x);
         out_y = (int)GlobalVariableGet(gv_y);
         return(true);
        }
      return(false);
     }
  };
