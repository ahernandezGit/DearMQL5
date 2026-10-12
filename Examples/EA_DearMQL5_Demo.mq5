//+------------------------------------------------------------------+
//|                                        EA_DearMQL5_Demo.mq5      |
//|                              Copyright 2026, DearMQL5 GUI Engine |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, DearMQL5 GUI Engine"
#property link      "https://www.mql5.com"
#property version   "1.00"

#include "..\UI.mqh"

// State variables for Demo GUI
bool   g_ui_open            = true;
bool   g_auto_trade         = true;
bool   g_news_filter        = true;
bool   g_trailing_active    = false;
double g_risk_pct           = 1.0;
double g_max_slippage_pts   = 20.0;
int    g_daily_loss_limit   = 500;
int    g_current_daily_loss = 160;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   // Enable mouse movement messages on chart
   ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, true);

   // Initialize DearMQL5 Canvas GUI
   if(!UI::Init(0, 0))
     {
      Print("[DearMQL5] Falha ao inicializar o Canvas da GUI.");
      return(INIT_FAILED);
     }

   Print("[DearMQL5] Inicializado com sucesso.");
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   UI::Shutdown();
  }

//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
   // Feed input events into DearMQL5 pipeline
   UI::OnChartEvent(id, lparam, dparam, sparam);

   // Re-render frame immediately on mouse interaction for zero-latency response
   if(id == CHARTEVENT_MOUSE_MOVE || id == CHARTEVENT_CLICK)
     {
      RenderGUI();
     }
  }

//+------------------------------------------------------------------+
//| OnTick function                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   // Update HUD on incoming market ticks
   RenderGUI();
  }

//+------------------------------------------------------------------+
//| Renders the immediate-mode HUD                                   |
//+------------------------------------------------------------------+
void RenderGUI()
  {
   UI::NewFrame();

   if(UI::Begin("PROP FIRM TERMINAL — DearMQL5", g_ui_open, 20, 30, 280, 420))
     {
      // --- Section 1: Prop Firm Account Metrics ---
      double equity  = AccountInfoDouble(ACCOUNT_EQUITY);
      double balance = AccountInfoDouble(ACCOUNT_BALANCE);
      double pnl     = AccountInfoDouble(ACCOUNT_PROFIT);

      UI::Text(StringFormat("Balance: $%.2f", balance));
      UI::SameLine();
      UI::Text(StringFormat("Equity: $%.2f", equity));

      uint pnl_color = (pnl >= 0) ? 0xFF98C379 : 0xFFE06C75;
      UI::TextColored(StringFormat("Floating PnL: $%.2f", pnl), pnl_color);

      // Daily Drawdown Progress Bar
      double dd_fraction = (double)g_current_daily_loss / (double)g_daily_loss_limit;
      string dd_overlay = StringFormat("Daily Loss: $%d / $%d (%.0f%%)", g_current_daily_loss, g_daily_loss_limit, dd_fraction * 100.0);
      UI::ProgressBar(dd_fraction, 0, 16, dd_overlay, true);

      UI::Separator();

      // --- Section 2: Trading Actions ---
      UI::Text("Execução Rápida:");
      if(UI::ButtonColor("BUY MARKET", 0xFF00A389, 126, 26))
        {
         Print(">> BOTÃO CLICADO: BUY MARKET");
        }
      UI::SameLine();
      if(UI::ButtonColor("SELL MARKET", 0xFFD19A66, 126, 26))
        {
         Print(">> BOTÃO CLICADO: SELL MARKET");
        }

      if(UI::ButtonColor("PANIC CLOSE ALL", 0xFFE06C75, 260, 26))
        {
         Print(">> ALERTA: PANIC CLOSE ALL PRESSIONADO!");
        }

      UI::Separator();

      // --- Section 3: Risk Controls ---
      UI::Text("Controles de Risco & Slippage:");
      UI::SliderFloat("Risco %", g_risk_pct, 0.25, 3.0, "%.2f%%");
      UI::SliderFloat("Max Slip", g_max_slippage_pts, 5.0, 50.0, "%.0f pts");

      UI::Toggle("Auto-Trading Ativo", g_auto_trade);
      UI::Toggle("Filtro de Notícias", g_news_filter);
      UI::Toggle("Trailing Stop Dinâmico", g_trailing_active);

      // --- Section 4: Diagnostics Header ---
      if(UI::CollapsingHeader("Diagnóstico do Motor GUI", false))
        {
         UI::Text(StringFormat("Tempo de Render: %.3f ms", UDiagnostics::GetLastFrameMs()));
         UI::Text(StringFormat("Draw Calls: %u", UDiagnostics::GetDrawCallsCount()));
         UI::Text(StringFormat("Mouse: (%d, %d)", UInputState::MouseX(), UInputState::MouseY()));
        }

     }

   UI::End();

   UI::Render();
  }
