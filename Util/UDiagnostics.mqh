//+------------------------------------------------------------------+
//|                                                 UDiagnostics.mqh |
//|                                  Copyright 2026, DearMQL5 GUI Engine |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, DearMQL5 GUI Engine"
#property link      "https://www.mql5.com"
#property strict

///  Diagnostics and performance profiler for DearMQL5 frames.
class UDiagnostics
  {
private:
   static ulong   s_frame_start_msc;
   static double  s_last_frame_ms;
   static uint    s_object_set_count;
   static uint    s_draw_calls_count;
   static bool    s_dirty_frame;

public:
   ///  Marks the beginning of a GUI frame for timing.
   static void BeginFrame(void)
     {
      s_frame_start_msc  = GetMicrosecondCount();
      s_object_set_count = 0;
      s_draw_calls_count = 0;
      s_dirty_frame      = false;
     }

   ///  Marks the end of a GUI frame and computes elapsed microseconds/milliseconds.
   static void EndFrame(void)
     {
      ulong elapsed_msc = GetMicrosecondCount() - s_frame_start_msc;
      s_last_frame_ms   = (double)elapsed_msc / 1000.0;
     }

   ///  Increments the counter of native MT5 object modifications.
   static void IncrementObjectSets(const uint count = 1)
     {
      s_object_set_count += count;
     }

   ///  Increments the counter of canvas draw calls.
   static void IncrementDrawCalls(const uint count = 1)
     {
      s_draw_calls_count += count;
     }

   ///  Marks this frame as dirty, requiring a render/canvas flush.
   static void SetDirty(void)
     {
      s_dirty_frame = true;
     }

   ///  Returns whether this frame had visual changes.
   static bool IsDirty(void)
     {
      return(s_dirty_frame);
     }

   ///  Returns the elapsed time of the last frame in milliseconds.
   static double GetLastFrameMs(void)
     {
      return(s_last_frame_ms);
     }

   ///  Returns the number of ObjectSet calls performed in the last frame.
   static uint GetObjectSetCount(void)
     {
      return(s_object_set_count);
     }

   ///  Returns the number of draw calls performed in the last frame.
   static uint GetDrawCallsCount(void)
     {
      return(s_draw_calls_count);
     }
  };

// Static members initialization
ulong  UDiagnostics::s_frame_start_msc  = 0;
double UDiagnostics::s_last_frame_ms    = 0.0;
uint   UDiagnostics::s_object_set_count = 0;
uint   UDiagnostics::s_draw_calls_count = 0;
bool   UDiagnostics::s_dirty_frame      = false;
