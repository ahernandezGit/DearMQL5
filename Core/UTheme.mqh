//+------------------------------------------------------------------+
//|                                                       UTheme.mqh |
//|                                  Copyright 2026, DearMQL5 GUI Engine |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, DearMQL5 GUI Engine"
#property link      "https://www.mql5.com"
#property strict

///  Visual style parameters, ARGB color palette, and layout metrics.
struct SUTheme
  {
   // Colors (ARGB: 0xAARRGGBB)
   uint     window_bg;              ///< Window body background color
   uint     window_titlebar;        ///< Window title bar background
   uint     window_titlebar_active; ///< Title bar background when focused
   uint     window_border;          ///< Window outer border outline
   uint     text;                   ///< Primary foreground text color
   uint     text_dim;               ///< Secondary muted text color
   uint     widget_bg;              ///< Normal widget background (edit, slider track)
   uint     widget_hover;           ///< Widget background when mouse is hovering
   uint     widget_active;          ///< Widget background when clicked/pressed
   uint     button_bg;              ///< Normal button background
   uint     button_hover;           ///< Button hovered background
   uint     button_active;          ///< Button pressed background
   uint     accent;                 ///< Institutional accent color (emerald / cyan)
   uint     accent_hover;           ///< Accent color when hovered
   uint     danger;                 ///< Danger / panic button color (red)
   uint     success;                ///< Success / profitable metric color (green)
   uint     separator;              ///< Horizontal divider color

   // Layout Spacing & Metrics
   int      padding_x;              ///< Horizontal internal padding inside widgets/windows
   int      padding_y;              ///< Vertical internal padding inside widgets/windows
   int      item_spacing_x;         ///< Horizontal gap between adjacent widgets on SameLine
   int      item_spacing_y;         ///< Vertical gap between rows
   int      window_title_height;    ///< Height of window title bar
   int      widget_height;          ///< Standard height of single-line interactive widgets
   int      corner_radius;          ///< Corner rounding radius (0 = sharp square)
   string   font_name;              ///< Primary typography face (e.g. "Segoe UI", "Arial")
   int      font_size;              ///< Primary font size in points

   ///  Applies default professional institutional Dark Theme.
   void SetDarkDefaults(void)
     {
      window_bg              = 0xF0181A1F; // Very dark slate grey (94% opacity)
      window_titlebar        = 0xFF21252B; // Medium slate
      window_titlebar_active = 0xFF2C313C; // Focused slate
      window_border          = 0xFF3E4451; // Subtle grey border
      text                   = 0xFFECEFF4; // Clean crisp off-white
      text_dim               = 0xFF8A93A4; // Dim grey for labels
      widget_bg              = 0xFF282C34; // Input background
      widget_hover           = 0xFF353B45; // Hovered state
      widget_active          = 0xFF4B5263; // Pressed state
      button_bg              = 0xFF2D3748; // Cool slate button
      button_hover           = 0xFF3D4D66; // Hovered button
      button_active          = 0xFF4A5D7C; // Clicked button
      accent                 = 0xFF00A389; // Institutional cyan/emerald
      accent_hover           = 0xFF00C2A3; // Vibrant cyan
      danger                 = 0xFFE06C75; // Coral red
      success                = 0xFF98C379; // Soft forest green
      separator              = 0xFF3E4451; // Clean separator

      padding_x              = 8;
      padding_y              = 6;
      item_spacing_x         = 8;
      item_spacing_y         = 6;
      window_title_height    = 24;
      widget_height          = 22;
      corner_radius          = 3;
      font_name              = "Segoe UI";
      font_size              = 9;
     }
  };

///  Global theme access and style stack manager.
class UTheme
  {
private:
   static SUTheme s_current;

public:
   ///  Returns the active global theme configuration.
   static SUTheme Get(void)
     {
      if(s_current.widget_height == 0)
         s_current.SetDarkDefaults();
      return(s_current);
     }

   ///  Overrides the active global theme.
   static void Set(const SUTheme &theme)
     {
      s_current = theme;
     }
  };

SUTheme UTheme::s_current;
