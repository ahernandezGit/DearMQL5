//+------------------------------------------------------------------+
//|                                             URendererCanvas.mqh |
//|                              Copyright 2026, DearMQL5 GUI Engine |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, DearMQL5 GUI Engine"
#property link      "https://www.mql5.com"
#property strict

#include <Canvas\Canvas.mqh>
#include "..\Util\UDiagnostics.mqh"
#include "..\Util\UMath.mqh"

//+------------------------------------------------------------------+
//| CUWindowSurface: Dedicated Canvas resource for an isolated HUD  |
//+------------------------------------------------------------------+
class CUWindowSurface
  {
private:
   CCanvas  m_canvas;
   ulong    m_win_id;
   string   m_title;
   string   m_obj_name;
   long     m_chart_id;
   int      m_subwindow;
   int      m_x;
   int      m_y;
   int      m_width;
   int      m_height;
   bool     m_is_created;
   bool     m_is_dirty;

public:
   CUWindowSurface(void)
     : m_win_id(0), m_title(""), m_obj_name(""), m_chart_id(0), m_subwindow(0),
       m_x(0), m_y(0), m_width(0), m_height(0), m_is_created(false), m_is_dirty(false)
     {
     }

   ~CUWindowSurface(void)
     {
      Destroy();
     }

   ulong GetWinId(void) const { return(m_win_id); }
   int   GetX(void) const { return(m_x); }
   int   GetY(void) const { return(m_y); }
   int   GetWidth(void) const { return(m_width); }
   int   GetHeight(void) const { return(m_height); }
   bool  IsDirty(void) const { return(m_is_dirty); }
   void  SetDirty(void) { m_is_dirty = true; }

   bool Configure(const ulong win_id, const string title, const long chart_id, const int subwin,
                  const int x, const int y, const int w, const int h)
     {
      m_win_id    = win_id;
      m_title     = title;
      m_chart_id  = (chart_id == 0) ? ChartID() : chart_id;
      m_subwindow = subwin;
      m_x         = x;
      m_y         = y;
      m_width     = (w > 0) ? w : 260;
      m_height    = (h > 0) ? h : 320;

      if(m_obj_name == "")
         m_obj_name = StringFormat("DearMQL5_Hub_%I64u_%I64d", win_id, m_chart_id);

      return(EnsureCanvas());
     }

   bool EnsureCanvas(void)
     {
      if(m_is_created)
        {
         if(m_width != m_canvas.Width() || m_height != m_canvas.Height())
           {
            m_canvas.Resize(m_width, m_height);
            ObjectSetInteger(m_chart_id, m_obj_name, OBJPROP_XSIZE, m_width);
            ObjectSetInteger(m_chart_id, m_obj_name, OBJPROP_YSIZE, m_height);
            m_is_dirty = true;
           }
         return(true);
        }

      if(ObjectFind(m_chart_id, m_obj_name) >= 0)
         ObjectDelete(m_chart_id, m_obj_name);

      if(!m_canvas.CreateBitmapLabel(m_chart_id, m_subwindow, m_obj_name, m_x, m_y, m_width, m_height, COLOR_FORMAT_ARGB_NORMALIZE))
         return(false);

      ObjectSetInteger(m_chart_id, m_obj_name, OBJPROP_XSIZE, m_width);
      ObjectSetInteger(m_chart_id, m_obj_name, OBJPROP_YSIZE, m_height);
      ObjectSetInteger(m_chart_id, m_obj_name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(m_chart_id, m_obj_name, OBJPROP_SELECTED, false);
      ObjectSetInteger(m_chart_id, m_obj_name, OBJPROP_ZORDER, 50);

      m_is_created = true;
      m_is_dirty   = true;
      return(true);
     }

   void SetPosition(const int new_x, const int new_y)
     {
      m_x = new_x;
      m_y = new_y;
      if(m_is_created)
        {
         ObjectSetInteger(m_chart_id, m_obj_name, OBJPROP_XDISTANCE, m_x);
         ObjectSetInteger(m_chart_id, m_obj_name, OBJPROP_YDISTANCE, m_y);
        }
     }

   void SetSize(const int new_w, const int new_h)
     {
      if(new_w > 0 && new_h > 0 && (m_width != new_w || m_height != new_h))
        {
         m_width  = new_w;
         m_height = new_h;
         if(m_is_created)
           {
            m_canvas.Resize(m_width, m_height);
            ObjectSetInteger(m_chart_id, m_obj_name, OBJPROP_XSIZE, m_width);
            ObjectSetInteger(m_chart_id, m_obj_name, OBJPROP_YSIZE, m_height);
            m_is_dirty = true;
           }
        }
     }

   void BringToFront(void)
     {
      if(m_is_created)
         ObjectSetInteger(m_chart_id, m_obj_name, OBJPROP_ZORDER, 100);
     }

   void SetNormalZOrder(void)
     {
      if(m_is_created)
         ObjectSetInteger(m_chart_id, m_obj_name, OBJPROP_ZORDER, 50);
     }

   void Erase(const uint argb = 0x00000000)
     {
      if(m_is_created)
         m_canvas.Erase(argb);
     }

   void Update(void)
     {
      if(m_is_created && m_is_dirty)
        {
         m_canvas.Update();
         m_is_dirty = false;
        }
     }

   void Destroy(void)
     {
      if(m_is_created)
        {
         m_canvas.Destroy();
         ObjectDelete(m_chart_id, m_obj_name);
         m_is_created = false;
        }
     }

   void FillRectangle(const int x1, const int y1, const int x2, const int y2, const uint clr)
     {
      if(m_is_created)
        {
         m_canvas.FillRectangle(x1, y1, x2, y2, clr);
         m_is_dirty = true;
        }
     }

   void Rectangle(const int x1, const int y1, const int x2, const int y2, const uint clr)
     {
      if(m_is_created)
        {
         m_canvas.Rectangle(x1, y1, x2, y2, clr);
         m_is_dirty = true;
        }
     }

   void Line(const int x1, const int y1, const int x2, const int y2, const uint clr)
     {
      if(m_is_created)
        {
         m_canvas.Line(x1, y1, x2, y2, clr);
         m_is_dirty = true;
        }
     }

   void TextOut(const int x, const int y, const string text, const uint clr,
                const string font_name, const int font_size, const uint flags)
     {
      if(m_is_created && StringLen(text) > 0)
        {
         m_canvas.FontSet(font_name, -font_size * 10);
         m_canvas.TextOut(x, y, text, clr, flags);
         m_is_dirty = true;
        }
     }

   void LineAA(const int x1, const int y1, const int x2, const int y2, const uint clr)
     {
      if(m_is_created)
        {
         m_canvas.LineAA(x1, y1, x2, y2, clr);
         m_is_dirty = true;
        }
     }

   void FillTriangle(const int x1, const int y1, const int x2, const int y2, const int x3, const int y3, const uint clr)
     {
      if(m_is_created)
        {
         m_canvas.FillTriangle(x1, y1, x2, y2, x3, y3, clr);
         m_is_dirty = true;
        }
     }

   void FillCircle(const int x, const int y, const int r, const uint clr)
     {
      if(m_is_created && r > 0)
        {
         m_canvas.FillCircle(x, y, r, clr);
         m_is_dirty = true;
        }
     }
  };

///  Hardware-accelerated immediate-mode renderer managing per-hub CCanvas surfaces.
class URendererCanvas
  {
private:
   static CUWindowSurface* s_surfaces[];
   static int              s_surface_count;
   static CUWindowSurface* s_cur_surface;
   static long             s_chart_id;
   static int              s_subwindow;
   static bool             s_clip_active;
   static int              s_clip_x, s_clip_y, s_clip_w, s_clip_h;

   static CUWindowSurface* FindSurface(const ulong win_id)
     {
      for(int i = 0; i < s_surface_count; i++)
        {
         if(CheckPointer(s_surfaces[i]) != POINTER_INVALID && s_surfaces[i].GetWinId() == win_id)
            return(s_surfaces[i]);
        }
      return(NULL);
     }

   static CUWindowSurface* GetOrCreateSurface(const ulong win_id, const string title,
                                             const long chart_id, const int subwin,
                                             const int x, const int y, const int w, const int h)
     {
      CUWindowSurface* surf = FindSurface(win_id);
      if(surf != NULL)
        {
         surf.Configure(win_id, title, chart_id, subwin, x, y, w, h);
         return(surf);
        }

      surf = new CUWindowSurface();
      surf.Configure(win_id, title, chart_id, subwin, x, y, w, h);

      int size = ArraySize(s_surfaces);
      if(s_surface_count >= size)
         ArrayResize(s_surfaces, (size == 0) ? 4 : size * 2);

      s_surfaces[s_surface_count++] = surf;
      return(surf);
     }

public:
   static bool Init(const long chart_id = 0, const int subwin = 0)
     {
      s_chart_id  = (chart_id == 0) ? ChartID() : chart_id;
      s_subwindow = subwin;
      return(true);
     }

   static void Shutdown(void)
     {
      for(int i = 0; i < s_surface_count; i++)
        {
         if(CheckPointer(s_surfaces[i]) != POINTER_INVALID)
           {
            s_surfaces[i].Destroy();
            delete s_surfaces[i];
           }
        }
      ArrayFree(s_surfaces);
      s_surface_count = 0;
      s_cur_surface   = NULL;
     }

   static void BeginFrame(void)
     {
      s_clip_active = false;
     }

   static void EndFrame(void)
     {
      for(int i = 0; i < s_surface_count; i++)
        {
         if(CheckPointer(s_surfaces[i]) != POINTER_INVALID)
           {
            s_surfaces[i].Update();
           }
        }
      s_cur_surface = NULL;
     }

   static bool BeginWindowSurface(const ulong win_id, const string title,
                                 const int x, const int y, const int w, const int h,
                                 const long chart_id = 0, const int subwin = 0)
     {
      long cid = (chart_id == 0) ? s_chart_id : chart_id;
      int  sw  = (subwin >= 0)  ? subwin : s_subwindow;

      s_cur_surface = GetOrCreateSurface(win_id, title, cid, sw, x, y, w, h);
      if(s_cur_surface != NULL)
        {
         s_cur_surface.SetPosition(x, y);
         s_cur_surface.SetSize(w, h);
         s_cur_surface.Erase(0x00000000);
         return(true);
        }
      return(false);
     }

   static void EndWindowSurface(void)
     {
      s_cur_surface = NULL;
     }

   static void SetWindowPosition(const ulong win_id, const int x, const int y)
     {
      CUWindowSurface* surf = FindSurface(win_id);
      if(surf != NULL)
        {
         surf.SetPosition(x, y);
         ChartRedraw(s_chart_id);
        }
     }

   static void BringWindowToFront(const ulong win_id)
     {
      CUWindowSurface* surf = FindSurface(win_id);
      if(surf != NULL)
         surf.BringToFront();
     }

   static void ResetWindowZOrder(const ulong win_id)
     {
      CUWindowSurface* surf = FindSurface(win_id);
      if(surf != NULL)
         surf.SetNormalZOrder();
     }

   static void DrawRectFilled(const int x, const int y, const int w, const int h, const uint argb)
     {
      if(s_cur_surface == NULL || w <= 0 || h <= 0) return;
      int lx = x - s_cur_surface.GetX();
      int ly = y - s_cur_surface.GetY();
      s_cur_surface.FillRectangle(lx, ly, lx + w, ly + h, argb);
      UDiagnostics::IncrementDrawCalls();
      UDiagnostics::SetDirty();
     }

   static void DrawRect(const int x, const int y, const int w, const int h, const uint argb)
     {
      if(s_cur_surface == NULL || w <= 0 || h <= 0) return;
      int lx = x - s_cur_surface.GetX();
      int ly = y - s_cur_surface.GetY();
      s_cur_surface.Rectangle(lx, ly, lx + w, ly + h, argb);
      UDiagnostics::IncrementDrawCalls();
      UDiagnostics::SetDirty();
     }

   static void DrawLine(const int x1, const int y1, const int x2, const int y2, const uint argb)
     {
      if(s_cur_surface == NULL) return;
      int lx1 = x1 - s_cur_surface.GetX();
      int ly1 = y1 - s_cur_surface.GetY();
      int lx2 = x2 - s_cur_surface.GetX();
      int ly2 = y2 - s_cur_surface.GetY();
      s_cur_surface.Line(lx1, ly1, lx2, ly2, argb);
      UDiagnostics::IncrementDrawCalls();
      UDiagnostics::SetDirty();
     }

   static void DrawText(const int x, const int y,
                        const string text,
                        const uint argb,
                        const string font_name = "Segoe UI",
                        const int font_size = 9,
                        const uint flags = 0)
     {
      if(s_cur_surface == NULL || StringLen(text) == 0) return;
      int lx = x - s_cur_surface.GetX();
      int ly = y - s_cur_surface.GetY();
      s_cur_surface.TextOut(lx, ly, text, argb, font_name, font_size, flags);
      UDiagnostics::IncrementDrawCalls();
      UDiagnostics::SetDirty();
     }

   static void DrawLineAA(const int x1, const int y1, const int x2, const int y2, const uint argb)
     {
      if(s_cur_surface == NULL) return;
      int lx1 = x1 - s_cur_surface.GetX();
      int ly1 = y1 - s_cur_surface.GetY();
      int lx2 = x2 - s_cur_surface.GetX();
      int ly2 = y2 - s_cur_surface.GetY();
      s_cur_surface.LineAA(lx1, ly1, lx2, ly2, argb);
      UDiagnostics::IncrementDrawCalls();
      UDiagnostics::SetDirty();
     }

   static void DrawTriangleFilled(const int x1, const int y1, const int x2, const int y2, const int x3, const int y3, const uint argb)
     {
      if(s_cur_surface == NULL) return;
      int sx = s_cur_surface.GetX();
      int sy = s_cur_surface.GetY();
      s_cur_surface.FillTriangle(x1 - sx, y1 - sy, x2 - sx, y2 - sy, x3 - sx, y3 - sy, argb);
      UDiagnostics::IncrementDrawCalls();
      UDiagnostics::SetDirty();
     }

   static void DrawCircleFilled(const int x, const int y, const int r, const uint argb)
     {
      if(s_cur_surface == NULL || r <= 0) return;
      int lx = x - s_cur_surface.GetX();
      int ly = y - s_cur_surface.GetY();
      s_cur_surface.FillCircle(lx, ly, r, argb);
      UDiagnostics::IncrementDrawCalls();
      UDiagnostics::SetDirty();
     }

   ///  Draws procedural vector collapse button (Chevron with hover/active pill container)
   static void DrawCollapseButton(const int x, const int y, const int size,
                                  const bool collapsed,
                                  const bool is_hover,
                                  const bool is_active,
                                  const uint icon_color,
                                  const uint hover_color = 0x22FFFFFF,
                                  const uint active_color = 0x44FFFFFF)
     {
      if(s_cur_surface == NULL || size <= 0) return;

      // 1. Interactive Button Background Pill
      if(is_active)
        {
         DrawRectFilled(x, y, size, size, active_color);
         DrawRect(x, y, size, size, 0x66FFFFFF);
        }
      else if(is_hover)
        {
         DrawRectFilled(x, y, size, size, hover_color);
         DrawRect(x, y, size, size, 0x33FFFFFF);
        }

      // 2. Vector Chevron Geometry
      int cx = x + size / 2;
      int cy = y + size / 2;
      int span = MathMax(3, (size - 8) / 2); // ~5px for size 18
      int d    = MathMax(2, span / 2);       // ~2px

      uint clr = is_active ? 0xFFFFFFFF : (is_hover ? 0xFFFFFFFF : icon_color);

      if(!collapsed)
        {
         // Open Window -> Chevron pointing UP (click to collapse up)
         DrawLineAA(cx - span, cy + d,     cx, cy - d,     clr);
         DrawLineAA(cx, cy - d,             cx + span, cy + d, clr);
         DrawLineAA(cx - span, cy + d + 1, cx, cy - d + 1, clr);
         DrawLineAA(cx, cy - d + 1,         cx + span, cy + d + 1, clr);
        }
      else
        {
         // Collapsed Window -> Chevron pointing DOWN (click to expand down)
         DrawLineAA(cx - span, cy - d,     cx, cy + d,     clr);
         DrawLineAA(cx, cy + d,             cx + span, cy - d, clr);
         DrawLineAA(cx - span, cy - d - 1, cx, cy + d - 1, clr);
         DrawLineAA(cx, cy + d - 1,         cx + span, cy - d - 1, clr);
        }
     }

   static void PushClipRect(const int x, const int y, const int w, const int h)
     {
      s_clip_active = true;
      s_clip_x = x;
      s_clip_y = y;
      s_clip_w = w;
      s_clip_h = h;
     }

   static void PopClipRect(void)
     {
      s_clip_active = false;
     }
  };

CUWindowSurface* URendererCanvas::s_surfaces[];
int              URendererCanvas::s_surface_count = 0;
CUWindowSurface* URendererCanvas::s_cur_surface   = NULL;
long             URendererCanvas::s_chart_id      = 0;
int              URendererCanvas::s_subwindow     = 0;
bool             URendererCanvas::s_clip_active   = false;
int              URendererCanvas::s_clip_x        = 0;
int              URendererCanvas::s_clip_y        = 0;
int              URendererCanvas::s_clip_w        = 0;
int              URendererCanvas::s_clip_h        = 0;
