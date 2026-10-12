//+------------------------------------------------------------------+
//|                                                           UI.mqh |
//|                              Copyright 2026, DearMQL5 GUI Engine |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, DearMQL5 GUI Engine"
#property link      "https://www.mql5.com"
#property strict

// Backend selection: Default is high-performance CCanvas (isolated Per-Hub OBJ_BITMAP_LABEL)
// Define UI_BACKEND_NATIVE prior to including UI.mqh if native MT5 object pool is preferred
#ifndef UI_BACKEND_NATIVE
   #define UI_BACKEND_CANVAS
#endif

// Core Subsystems
#include "Util\UMath.mqh"
#include "Util\UDiagnostics.mqh"
#include "Core\UTheme.mqh"
#include "Core\UIdStack.mqh"
#include "Core\UState.mqh"
#include "Core\UInputState.mqh"
#include "Core\UEventQueue.mqh"
#include "Core\ULayout.mqh"
#include "Render\UFont.mqh"

#ifdef UI_BACKEND_CANVAS
   #include "Render\URendererCanvas.mqh"
#else
   #include "Render\URendererNative.mqh"
#endif

// Widgets & Windows
#include "Widgets\UWidget.mqh"
#include "Widgets\ULabel.mqh"
#include "Widgets\USeparator.mqh"
#include "Widgets\UButton.mqh"
#include "Widgets\UToggle.mqh"
#include "Widgets\USlider.mqh"
#include "Widgets\UProgressBar.mqh"
#include "Widgets\UHeader.mqh"
#include "Windows\UWindow.mqh"
#include "Windows\UWindowManager.mqh"

///  Primary public facade for DearMQL5 immediate-mode GUI operations in MQL5.
class UI
  {
public:
   //+------------------------------------------------------------------+
   //| Lifecycle & System Control                                       |
   //+------------------------------------------------------------------+

   ///  Initializes the GUI engine on the target chart and subwindow.
   static bool Init(const long chart_id = 0, const int subwindow = 0)
     {
      UInputState::SetChartId((chart_id == 0) ? ChartID() : chart_id);
      #ifdef UI_BACKEND_CANVAS
         return(URendererCanvas::Init(chart_id, subwindow));
      #else
         URendererNative::Init(chart_id, subwindow);
         return(true);
      #endif
     }

   ///  Shuts down the GUI engine and cleans up all graphics resources.
   static void Shutdown(void)
     {
      UInputState::EnableChartScroll();
      #ifdef UI_BACKEND_CANVAS
         URendererCanvas::Shutdown();
      #else
         URendererNative::Shutdown();
      #endif
     }

   ///  Feeds OnChartEvent events directly into DearMQL5 input pipeline.
   static void OnChartEvent(const int id,
                            const long &lparam,
                            const double &dparam,
                            const string &sparam)
     {
      if(id == CHARTEVENT_MOUSE_MOVE)
        {
         UInputState::OnMouseMove((int)lparam, (int)dparam, (uint)StringToInteger(sparam));
        }
     }

   ///  Begins a new GUI frame. Must be called before any windows or widgets.
   static void NewFrame(void)
     {
      UDiagnostics::BeginFrame();
      UIdStack::Reset();
      UWindow::ResetScope();
      UInputState::NewFrame();
      UState::NextFrame();

      #ifdef UI_BACKEND_CANVAS
         URendererCanvas::BeginFrame();
      #else
         URendererNative::BeginFrame();
      #endif
     }

   ///  Finalizes and renders the current GUI frame to chart.
   static void Render(void)
     {
      #ifdef UI_BACKEND_CANVAS
         URendererCanvas::EndFrame();
      #else
         URendererNative::EndFrame();
      #endif
      UInputState::EndFrame();
      UDiagnostics::EndFrame();
     }

   //+------------------------------------------------------------------+
   //| Windows Containers                                               |
   //+------------------------------------------------------------------+

   ///  Begins an immediate-mode window. Returns true if window body is visible.
   static bool Begin(const string title,
                     bool &io_open,
                     const int default_x = 20,
                     const int default_y = 40,
                     const int default_w = 260,
                     const int default_h = 320,
                     const uint flags = U_WINDOW_NONE)
     {
      int x = 0, y = 0, w = 0, h = 0;
      bool collapsed = false;
      bool visible = UWindow::Begin(title, io_open, default_x, default_y, default_w, default_h, flags, x, y, w, h, collapsed);

      SUTheme th = UTheme::Get();
      ulong win_id = UIdStack::GetId(title);

      #ifdef UI_BACKEND_CANVAS
         URendererCanvas::BeginWindowSurface(win_id, title, x, y, w, h);

         // Draw Window Shadow & Outer Border
         URendererCanvas::DrawRectFilled(x, y, w, h, th.window_bg);
         URendererCanvas::DrawRect(x, y, w, h, th.window_border);

         // Draw Titlebar
         if((flags & U_WINDOW_NO_TITLEBAR) == 0)
           {
            URendererCanvas::DrawRectFilled(x, y, w, th.window_title_height, th.window_titlebar);
            URendererCanvas::DrawLine(x, y + th.window_title_height, x + w, y + th.window_title_height, th.window_border);

            // Title Text
            URendererCanvas::DrawText(x + th.padding_x, y + 4, title, th.text, th.font_name, th.font_size, 0);

            // Collapse icon
            if((flags & U_WINDOW_NO_COLLAPSE) == 0)
              {
               string icon = collapsed ? "[+]" : "[-]";
               URendererCanvas::DrawText(x + w - 24, y + 4, icon, th.text_dim, th.font_name, th.font_size, 0);
              }
           }
      #else
         URendererNative::DrawRectFilled(x, y, w, h, th.window_bg);
         if((flags & U_WINDOW_NO_TITLEBAR) == 0)
           {
            URendererNative::DrawRectFilled(x, y, w, th.window_title_height, th.window_titlebar);
            URendererNative::DrawText(x + th.padding_x, y + 4, title, th.text, th.font_name, th.font_size);
           }
      #endif

      return(visible);
     }

   ///  Ends the current window scope.
   static void End(void)
     {
      UWindow::End();
      #ifdef UI_BACKEND_CANVAS
         URendererCanvas::EndWindowSurface();
      #endif
     }

   //+------------------------------------------------------------------+
   //| Layout Controls                                                  |
   //+------------------------------------------------------------------+

   ///  Directs the next widget to be placed on the same line horizontally.
   static void SameLine(const int spacing = -1)
     {
      ULayout::SameLine(spacing);
     }

   ///  Indents subsequent widgets to the right.
   static void Indent(const int amount = 16)
     {
      ULayout::Indent(amount);
     }

   ///  Restores indentation to the left.
   static void Unindent(const int amount = 16)
     {
      ULayout::Unindent(amount);
     }

   ///  Draws a horizontal divider line.
   static void Separator(void)
     {
      int x, y, w, h;
      USeparator::GetBoundingBox(w, h);
      ULayout::AllocateSpace(w, h, x, y);

      SUTheme th = UTheme::Get();
      #ifdef UI_BACKEND_CANVAS
         URendererCanvas::DrawLine(x, y + 2, x + w, y + 2, th.separator);
      #else
         URendererNative::DrawLine(x, y + 2, x + w, y + 2, th.separator);
      #endif
     }

   //+------------------------------------------------------------------+
   //| Text & Metric Widgets                                            |
   //+------------------------------------------------------------------+

   ///  Renders plain text.
   static void Text(const string text)
     {
      TextColored(text, UTheme::Get().text);
     }

   ///  Renders colored text (e.g. green for profit, red for drawdown).
   static void TextColored(const string text, const uint argb)
     {
      int x = 0, y = 0, w = 0, h = 0;
      ULabel::GetBoundingBox(text, w, h);
      ULayout::AllocateSpace(w, h, x, y);

      SUTheme th = UTheme::Get();
      #ifdef UI_BACKEND_CANVAS
         URendererCanvas::DrawText(x, y + 2, text, argb, th.font_name, th.font_size, 0);
      #else
         URendererNative::DrawText(x, y + 2, text, argb, th.font_name, th.font_size);
      #endif
     }

   //+------------------------------------------------------------------+
   //| Interactive Button Widgets                                       |
   //+------------------------------------------------------------------+

   ///  Renders a clickable button. Returns true on the frame it was clicked.
   static bool Button(const string label, const int custom_w = 0, const int custom_h = 0)
     {
      return(ButtonColor(label, 0, custom_w, custom_h));
     }

   ///  Renders a colored button (e.g. accent for Buy, danger for Panic Close).
   static bool ButtonColor(const string label, const uint bg_color, const int custom_w = 0, const int custom_h = 0)
     {
      ulong id = UIdStack::GetId(label);

      int x = 0, y = 0, w = 0, h = 0;
      UButton::GetBoundingBox(label, custom_w, custom_h, w, h);
      ULayout::AllocateSpace(w, h, x, y);

      bool hovered = false, clicked = false, active = false;
      UWidget::Behavior(id, x, y, w, h, hovered, clicked, active);

      uint btn_color = UButton::GetStateColor(hovered, active, bg_color);
      SUTheme th = UTheme::Get();

      #ifdef UI_BACKEND_CANVAS
         URendererCanvas::DrawRectFilled(x, y, w, h, btn_color);
         URendererCanvas::DrawRect(x, y, w, h, th.window_border);

         // Center text inside button
         int tw = UFont::MeasureTextWidth(label, th.font_size, th.font_name);
         int tx = x + (w - tw) / 2;
         int ty = y + (h - UFont::MeasureTextHeight(th.font_size)) / 2;
         URendererCanvas::DrawText(tx, ty, label, th.text, th.font_name, th.font_size, 0);
      #else
         URendererNative::DrawRectFilled(x, y, w, h, btn_color);
         URendererNative::DrawText(x + th.padding_x, y + 4, label, th.text, th.font_name, th.font_size);
      #endif

      if(clicked)
         UEventQueue::Push(U_EVENT_CLICK, id, 0.0, label);

      return(clicked);
     }

   //+------------------------------------------------------------------+
   //| Toggle Switch Widgets                                            |
   //+------------------------------------------------------------------+

   ///  Renders an ON/OFF toggle switch. Returns true if state changed.
   static bool Toggle(const string label, bool &io_value)
     {
      ulong id = UIdStack::GetId(label);

      int x = 0, y = 0, w = 0, h = 0;
      UToggle::GetBoundingBox(label, w, h);
      ULayout::AllocateSpace(w, h, x, y);

      bool hovered = false, clicked = false, active = false;
      UWidget::Behavior(id, x, y, w, h, hovered, clicked, active);

      if(clicked)
        {
         io_value = !io_value;
         UEventQueue::Push(U_EVENT_VALUE_CHANGE, id, io_value ? 1.0 : 0.0, label);
        }

      SUTheme th = UTheme::Get();
      int sw_w = 34;
      int sw_h = 16;
      int sw_y = y + (h - sw_h) / 2;

      uint track_color = io_value ? th.accent : th.widget_bg;
      int knob_x = io_value ? (x + sw_w - sw_h) : x;

      #ifdef UI_BACKEND_CANVAS
         URendererCanvas::DrawRectFilled(x, sw_y, sw_w, sw_h, track_color);
         URendererCanvas::DrawRectFilled(knob_x, sw_y, sw_h, sw_h, th.text);
         if(StringLen(label) > 0)
            URendererCanvas::DrawText(x + sw_w + th.item_spacing_x, y + 2, label, th.text, th.font_name, th.font_size, 0);
      #else
         URendererNative::DrawRectFilled(x, sw_y, sw_w, sw_h, track_color);
         URendererNative::DrawRectFilled(knob_x, sw_y, sw_h, sw_h, th.text);
         if(StringLen(label) > 0)
            URendererNative::DrawText(x + sw_w + th.item_spacing_x, y + 2, label, th.text, th.font_name, th.font_size);
      #endif

      return(clicked);
     }

   //+------------------------------------------------------------------+
   //| Slider Widgets                                                   |
   //+------------------------------------------------------------------+

   ///  Draggable horizontal slider for float/double parameters.
   static bool SliderFloat(const string label,
                           double &io_value,
                           const double min_val,
                           const double max_val,
                           const string format = "%.2f",
                           const int custom_w = 0)
     {
      ulong id = UIdStack::GetId(label);

      int x = 0, y = 0, w = 0, h = 0;
      USlider::GetBoundingBox(label, custom_w, w, h);
      ULayout::AllocateSpace(w, h, x, y);

      bool hovered = false, clicked = false, active = false;
      UWidget::Behavior(id, x, y, w, h, hovered, clicked, active);

      bool changed = false;
      if(active && UInputState::IsMouseDown())
        {
         changed = USlider::ProcessDrag(x, w, min_val, max_val, io_value);
         if(changed)
            UEventQueue::Push(U_EVENT_VALUE_CHANGE, id, io_value, label);
        }

      SUTheme th = UTheme::Get();
      double fraction = (max_val > min_val) ? ((io_value - min_val) / (max_val - min_val)) : 0.0;
      fraction = UMath::Clamp(fraction, 0.0, 1.0);
      int fill_w = (int)(w * fraction);

      string display_text = StringFormat("%s: " + format, label, io_value);

      #ifdef UI_BACKEND_CANVAS
         // Track background
         URendererCanvas::DrawRectFilled(x, y, w, h, th.widget_bg);
         // Active fill
         if(fill_w > 0)
            URendererCanvas::DrawRectFilled(x, y, fill_w, h, th.accent);
         // Border
         URendererCanvas::DrawRect(x, y, w, h, th.window_border);
         // Value text centered
         URendererCanvas::DrawText(x + th.padding_x, y + 2, display_text, th.text, th.font_name, th.font_size, 0);
      #else
         URendererNative::DrawRectFilled(x, y, w, h, th.widget_bg);
         if(fill_w > 0)
            URendererNative::DrawRectFilled(x, y, fill_w, h, th.accent);
         URendererNative::DrawText(x + th.padding_x, y + 2, display_text, th.text, th.font_name, th.font_size);
      #endif

      return(changed);
     }

   ///  Draggable horizontal slider for integer parameters.
   static bool SliderInt(const string label, int &io_value, const int min_val, const int max_val, const int custom_w = 0)
     {
      double dval = (double)io_value;
      bool changed = SliderFloat(label, dval, (double)min_val, (double)max_val, "%.0f", custom_w);
      if(changed)
         io_value = (int)MathRound(dval);
      return(changed);
     }

   //+------------------------------------------------------------------+
   //| Progress & Status Widgets                                        |
   //+------------------------------------------------------------------+

   ///  Visual progress bar with optional high-value alert color ramp (for Prop Firm limits).
   static void ProgressBar(const double fraction,
                           const int custom_w = 0,
                           const int custom_h = 0,
                           const string overlay_text = "",
                           const bool alert_on_high = false)
     {
      int x = 0, y = 0, w = 0, h = 0;
      UProgressBar::GetBoundingBox(custom_w, custom_h, w, h);
      ULayout::AllocateSpace(w, h, x, y);

      SUTheme th = UTheme::Get();
      double clamped_frac = UMath::Clamp(fraction, 0.0, 1.0);
      int fill_w = (int)(w * clamped_frac);
      uint fill_color = UProgressBar::GetProgressColor(clamped_frac, alert_on_high);

      #ifdef UI_BACKEND_CANVAS
         // Track
         URendererCanvas::DrawRectFilled(x, y, w, h, th.widget_bg);
         // Fill
         if(fill_w > 0)
            URendererCanvas::DrawRectFilled(x, y, fill_w, h, fill_color);
         URendererCanvas::DrawRect(x, y, w, h, th.window_border);

         // Overlay text if present
         if(StringLen(overlay_text) > 0)
           {
            int tw = UFont::MeasureTextWidth(overlay_text, th.font_size - 1, th.font_name);
            int tx = x + (w - tw) / 2;
            int ty = y + (h - UFont::MeasureTextHeight(th.font_size - 1)) / 2;
            URendererCanvas::DrawText(tx, ty, overlay_text, th.text, th.font_name, th.font_size - 1, 0);
           }
      #else
         URendererNative::DrawRectFilled(x, y, w, h, th.widget_bg);
         if(fill_w > 0)
            URendererNative::DrawRectFilled(x, y, fill_w, h, fill_color);
         if(StringLen(overlay_text) > 0)
            URendererNative::DrawText(x + th.padding_x, y + 1, overlay_text, th.text, th.font_name, th.font_size - 1);
      #endif
     }

   //+------------------------------------------------------------------+
   //| Collapsing Section Header                                        |
   //+------------------------------------------------------------------+

   ///  Collapsible section header. Returns true if section contents should be drawn.
   static bool CollapsingHeader(const string label, const bool default_open = true)
     {
      ulong id = UIdStack::GetId(label);

      int x = 0, y = 0, w = 0, h = 0;
      UHeader::GetBoundingBox(w, h);
      ULayout::AllocateSpace(w, h, x, y);

      bool hovered = false, clicked = false, active = false;
      UWidget::Behavior(id, x, y, w, h, hovered, clicked, active);

      bool is_open = UHeader::ProcessHeader(id, clicked, default_open);

      SUTheme th = UTheme::Get();
      uint bg = hovered ? th.widget_hover : th.widget_bg;
      string icon = is_open ? "[-] " : "[+] ";
      string full_title = icon + label;

      #ifdef UI_BACKEND_CANVAS
         URendererCanvas::DrawRectFilled(x, y, w, h, bg);
         URendererCanvas::DrawRect(x, y, w, h, th.window_border);
         URendererCanvas::DrawText(x + th.padding_x, y + 3, full_title, th.text, th.font_name, th.font_size, 0);
      #else
         URendererNative::DrawRectFilled(x, y, w, h, bg);
         URendererNative::DrawText(x + th.padding_x, y + 3, full_title, th.text, th.font_name, th.font_size);
      #endif

      return(is_open);
     }
  };
