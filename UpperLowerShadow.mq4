//+------------------------------------------------------------------+
//|                                             UpperLowerShadow.mq4 |
//|                                    Copyright 2018, Yosuke Adachi |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Yosuke Adachi"
#property link      ""
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Magenta
#property indicator_color2 Aqua

//インジケーターバッファーの宣言
double Arrow_Up[];
double Arrow_Down[];
double Real_Body[];
double Upper_Shadow[];
double Lower_Shadow[];

//変数の宣言
extern int Magnification = 3;

double Pips = 0;

//関数の定義
double AdjustPoint(string Currency) {
  int Symbol_Digits = (int)MarketInfo(Symbol(),MODE_DIGITS);
  double Calculated_Point = 0.0;
  if((Symbol_Digits == 2) || (Symbol_Digits == 3)) {
    Calculated_Point = 0.01;
  } else if((Symbol_Digits == 4) || (Symbol_Digits == 5)) {
    Calculated_Point = 0.001;
  }
  return Calculated_Point;
}

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(){
  //--- additional buffers
  IndicatorBuffers(5);
  //---- indicator buffers
  SetIndexBuffer(0,Arrow_Up);
  SetIndexBuffer(1,Arrow_Down);
  SetIndexBuffer(2,Real_Body);
  SetIndexBuffer(3,Upper_Shadow);
  SetIndexBuffer(4,Lower_Shadow);

  SetIndexLabel(0,NULL);
  SetIndexLabel(1,NULL);

  SetIndexStyle(0,DRAW_ARROW);
  SetIndexArrow(0,233);
  SetIndexStyle(1,DRAW_ARROW);
  SetIndexArrow(1,234);

  Pips = AdjustPoint(Symbol());
  printf("Pips:%f",Pips);

  return(INIT_SUCCEEDED);
}
  
  
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason){
}
  
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[]) {
                
  int limit = Bars - IndicatorCounted();
  // limit = 10;
  // printf("limit:%d", limit);

  int i = 0;
  //実体の計算
  for(i = limit - 1; i >= 0; i--) {
    Real_Body[i] = MathAbs(Open[i] - Close[i]);
  }

  //上ヒゲの計算
  for(i = limit - 1; i >= 0; i--) {
    Upper_Shadow[i] = MathMin(High[i] - Open[i], High[i] - Close[i]);
  }

  //下ヒゲの計算
  for(i = limit - 1; i >= 0; i--) {
    Lower_Shadow[i] = MathMin(Open[i] - Low[i], Close[i] - Low[i]);
  }

  //矢印の設定
  for(i = limit - 1; i >= 0; i--) {
    // printf("%d",i);
    // printf("Real_Body[i] * Magnification:%f",Real_Body[i] * Magnification);
    //上矢印の設定
    // printf("Lower_Shadow[i]:%f",Lower_Shadow[i]);
    if(Real_Body[i] * Magnification <= Lower_Shadow[i] &&
    Upper_Shadow[i] * Magnification <= Lower_Shadow[i]) {
      //  printf("!!!!^%d^!!!!",i);
       Arrow_Up[i] = Low[i] - Pips;
     }

    //下矢印の設定
    // printf("Upper_Shadow[i]:%f",Upper_Shadow[i]);
    if(Real_Body[i] * Magnification <= Upper_Shadow[i] && 
    Lower_Shadow[i] * Magnification <= Upper_Shadow[i]) {
      //  printf("!!!!_%d_!!!!",i);
      Arrow_Down[i] = High[i] + Pips;
    }
  }

  return(0);
}



//+------------------------------------------------------------------+
