//+------------------------------------------------------------------+
//|                                                       UState.mqh |
//|                                  Copyright 2026, DearMQL5 GUI Engine |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, DearMQL5 GUI Engine"
#property link      "https://www.mql5.com"
#property strict

///  Retained state entry for a single widget or window instance.
struct SUStateEntry
  {
   ulong    id;          ///< Unique FNV-1a hash key
   double   float_val;   ///< Floating point value (sliders, scroll)
   long     int_val;     ///< Integer / boolean flag value (toggles, collapses)
   string   str_val;     ///< String content (edit boxes)
   ulong    last_frame;  ///< Frame counter when last touched (for garbage collection)
  };

///  High-performance retained state map in pure MQL5 (zero external dependencies).
class UState
  {
private:
   static SUStateEntry s_entries[];
   static int          s_count;
   static ulong        s_frame_counter;

   ///  Binary search or linear scan for state key.
   static int FindIndex(const ulong id)
     {
      for(int i = 0; i < s_count; i++)
        {
         if(s_entries[i].id == id)
            return(i);
        }
      return(-1);
     }

   ///  Inserts or gets a state entry index for the given key.
   static int GetOrCreate(const ulong id)
     {
      int idx = FindIndex(id);
      if(idx >= 0)
        {
         s_entries[idx].last_frame = s_frame_counter;
         return(idx);
        }

      if(s_count >= ArraySize(s_entries))
         ArrayResize(s_entries, (s_count == 0) ? 64 : s_count * 2);

      int new_idx = s_count++;
      s_entries[new_idx].id         = id;
      s_entries[new_idx].float_val  = 0.0;
      s_entries[new_idx].int_val    = 0;
      s_entries[new_idx].str_val    = "";
      s_entries[new_idx].last_frame = s_frame_counter;
      return(new_idx);
     }

public:
   ///  Increments the global frame counter.
   static void NextFrame(void)
     {
      s_frame_counter++;
     }

   ///  Gets or initializes an integer/boolean state value.
   static long GetInt(const ulong id, const long default_val = 0)
     {
      int idx = FindIndex(id);
      if(idx < 0)
        {
         idx = GetOrCreate(id);
         s_entries[idx].int_val = default_val;
         return(default_val);
        }
      return(s_entries[idx].int_val);
     }

   ///  Sets an integer/boolean state value.
   static void SetInt(const ulong id, const long val)
     {
      int idx = GetOrCreate(id);
      s_entries[idx].int_val = val;
     }

   ///  Gets or initializes a floating point state value.
   static double GetFloat(const ulong id, const double default_val = 0.0)
     {
      int idx = FindIndex(id);
      if(idx < 0)
        {
         idx = GetOrCreate(id);
         s_entries[idx].float_val = default_val;
         return(default_val);
        }
      return(s_entries[idx].float_val);
     }

   ///  Sets a floating point state value.
   static void SetFloat(const ulong id, const double val)
     {
      int idx = GetOrCreate(id);
      s_entries[idx].float_val = val;
     }

   ///  Gets or initializes a string state value.
   static string GetString(const ulong id, const string default_val = "")
     {
      int idx = FindIndex(id);
      if(idx < 0)
        {
         idx = GetOrCreate(id);
         s_entries[idx].str_val = default_val;
         return(default_val);
        }
      return(s_entries[idx].str_val);
     }

   ///  Sets a string state value.
   static void SetString(const ulong id, const string val)
     {
      int idx = GetOrCreate(id);
      s_entries[idx].str_val = val;
     }
  };

SUStateEntry UState::s_entries[];
int          UState::s_count         = 0;
ulong        UState::s_frame_counter = 0;
