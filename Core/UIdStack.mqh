//+------------------------------------------------------------------+
//|                                                     UIdStack.mqh |
//|                                  Copyright 2026, DearMQL5 GUI Engine |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, DearMQL5 GUI Engine"
#property link      "https://www.mql5.com"
#property strict

///  Hierarchical ID hashing stack for state retention and unambiguous widget identity.
class UIdStack
  {
private:
   static ulong   s_stack[];
   static int     s_stack_size;

   ///  64-bit FNV-1a string hashing algorithm.
   static ulong HashString(const string str, const ulong seed = 0xcbf29ce484222325)
     {
      ulong hash = seed;
      int len = StringLen(str);
      for(int i = 0; i < len; i++)
        {
         hash ^= (ulong)StringGetCharacter(str, i);
         hash *= 0x100000001b3;
        }
      return(hash);
     }

public:
   ///  Resets the ID stack to baseline at the beginning of each frame.
   static void Reset(void)
     {
      s_stack_size = 0;
      if(ArraySize(s_stack) < 16)
         ArrayResize(s_stack, 16);
     }

   ///  Pushes a string namespace onto the ID stack.
   static void Push(const string str_id)
     {
      ulong parent_hash = (s_stack_size > 0) ? s_stack[s_stack_size - 1] : 0xcbf29ce484222325;
      ulong current_hash = HashString(str_id, parent_hash);

      if(s_stack_size >= ArraySize(s_stack))
         ArrayResize(s_stack, s_stack_size + 16);

      s_stack[s_stack_size++] = current_hash;
     }

   ///  Pushes an integer index onto the ID stack.
   static void PushInt(const int int_id)
     {
      Push(IntegerToString(int_id));
     }

   ///  Pops the topmost namespace from the ID stack.
   static void Pop(void)
     {
      if(s_stack_size > 0)
         s_stack_size--;
     }

   ///  Computes the qualified unique ID hash for a widget label within current scope.
   static ulong GetId(const string label)
     {
      ulong parent_hash = (s_stack_size > 0) ? s_stack[s_stack_size - 1] : 0xcbf29ce484222325;
      return(HashString(label, parent_hash));
     }
  };

ulong UIdStack::s_stack[];
int   UIdStack::s_stack_size = 0;
