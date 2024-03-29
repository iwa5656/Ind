//+------------------------------------------------------------------+
//|                                                   iUniMA_MTF.mq5 |
//|                                           Copyright ｩ 2010, AK20 |
//|                                             traderak20@gmail.com |
//|                                                                  |
//|                                                        Based on: |
//|                                            iUniMA.mq5 by Integer |
//|                                        MetaQuotes Software Corp. |
//|                                                 http://dmffx.com |
//+------------------------------------------------------------------+
#property copyright   "2010, traderak20@gmail.com"
#property description "iUniMA, Multi-timeframe of version the Universal Moving Average"

/*--------------------------------------------------------------------
2010 09 26: v03   Improved display of values on timeframes smaller than the chart's timeframe
                     Set buffers to EMPTY_VALUE instead of 0 after: if(convertedTime<tempTimeArray_TF2[0])
                  Code optimization
                     Removed PLOT_DRAW_BEGIN from OnInit() - inherited from single time frame indicator
                     Moved ArraySetAsSeries of buffers and arrays into OnInit()
----------------------------------------------------------------------*/

#ifdef delllss
#property indicator_chart_window

#property indicator_buffers 1
#property indicator_plots   1

//--- indicator plots
#property indicator_type1   DRAW_LINE
#property indicator_color1  Red
#property indicator_width1  1
#property indicator_label1  "MA_TF2"
#property indicator_style1  STYLE_SOLID
#endif //delll
//--- enum variables
enum maswitch1
  {
   Simple=(int)MODE_SMA,
   Exponential=ENUM_MA_METHOD::MODE_EMA,
   Smoothed=ENUM_MA_METHOD::MODE_SMMA,
   LinearWeighted=ENUM_MA_METHOD::MODE_LWMA,
   AMA=IND_AMA,
   DEMA=IND_DEMA,
   FRAMA=IND_FRAMA,
   TEMA=IND_TEMA,
   VIDYA=IND_VIDYA
  };


//define
int Lib_iunima_mtf_ru_prev_calculated;
#define NUM_OF_iunima_mtf_ru 5
ENUM_TIMEFRAMES      InpTimeFrame_[NUM_OF_iunima_mtf_ru]={PERIOD_M1,PERIOD_M5,PERIOD_H1,PERIOD_H4,PERIOD_D1};
string                  InpTimeFrameName[]={"PERIOD_M1","PERIOD_M5","PERIOD_H1","PERIOD_H4","PERIOD_D1"};
maswitch1             InpAppliedMA_[NUM_OF_iunima_mtf_ru];                             // Applied MA method for signal line
int                  InpMaPeriod_[NUM_OF_iunima_mtf_ru];                                    // MA Period
int                  InpAmaFast_[NUM_OF_iunima_mtf_ru];                                      // Fast AMA period
int                  InpAmaSlow_[NUM_OF_iunima_mtf_ru];                                     // Slow AMA period
int                  InpCmoPeriod_[NUM_OF_iunima_mtf_ru];                                    // CMO period for VIDYA
ENUM_APPLIED_PRICE   InpAppliedPrice_[NUM_OF_iunima_mtf_ru];                       // Applied price

//No.1-1
void init_ima_mtf_ru(int offset_buffer,int typeno){// offset_buffer Startのバッファ番号(idx）
	ENUM_TIMEFRAMES current_time_frame = Period();
	for(int i=0;i<ArraySize(InpTimeFrame_);i++){
		if(InpTimeFrame_[i]<current_time_frame){//タイムフレームより小さいなら処理しないようにテーブルを無効０にする。受け手で0の場合は処理しない
			InpTimeFrame_[i]=-1;
		}
	}


    Lib_iunima_mtf_ru_prev_calculated = 0;
    for(int i=0;i<NUM_OF_iunima_mtf_ru;i++){
        InpAppliedMA_[i] = (maswitch1)MODE_SMA;
        InpMaPeriod_[i]=20;                                    // MA Period
        InpAmaFast_[i]=2;                                      // Fast AMA period
        InpAmaSlow_[i]=30;                                     // Slow AMA period
        InpCmoPeriod_[i]=9;                                    // CMO period for VIDYA
        
        PlotIndexSetInteger(i+typeno,PLOT_LINE_COLOR,(ENUM_TIMEFRAMES)GetTimeColor(InpTimeFrame_[i]));
        PlotIndexSetInteger(i+typeno,PLOT_DRAW_TYPE,DRAW_LINE);
        PlotIndexSetInteger(i+typeno,PLOT_LINE_WIDTH,1);
        PlotIndexSetInteger(i+typeno,PLOT_LINE_STYLE,STYLE_SOLID);
        PlotIndexSetString(i+typeno,PLOT_LABEL,"MA_TF2_"+IntegerToString(i));

    }
    //InpTimeFrame_[]
    
     
}
//No.1
void OnInit_iunima_mtf_ru(int offset_buffer,int typeno){// offset_buffer Startのバッファ番号(idx）,typeno N->N-1
    init_ima_mtf_ru(offset_buffer,typeno);
    int i=0;
    OnInit_iunima_mtf_ru_(i+offset_buffer,i+typeno,ExtMaBuffer_TF2_0,ExtMaArray_TF2_0,            PeriodSeconds_TF1_[i],PeriodSeconds_TF2_[i],PeriodRatio_[i],ExtMaHandle_TF2_[i],InpTimeFrame_[i],            InpAppliedMA_[i],            InpMaPeriod_[i],            InpAmaFast_[i],            InpAmaSlow_[i],            InpCmoPeriod_[i],            InpAppliedPrice_[i]     ,InpTimeFrameName[i]);
    i++;
    OnInit_iunima_mtf_ru_(i+offset_buffer,i+typeno,ExtMaBuffer_TF2_1,ExtMaArray_TF2_1,            PeriodSeconds_TF1_[i],PeriodSeconds_TF2_[i],PeriodRatio_[i],ExtMaHandle_TF2_[i],InpTimeFrame_[i],            InpAppliedMA_[i],            InpMaPeriod_[i],            InpAmaFast_[i],            InpAmaSlow_[i],            InpCmoPeriod_[i],            InpAppliedPrice_[i]     ,InpTimeFrameName[i]);
    i++;
    OnInit_iunima_mtf_ru_(i+offset_buffer,i+typeno,ExtMaBuffer_TF2_2,ExtMaArray_TF2_2,            PeriodSeconds_TF1_[i],PeriodSeconds_TF2_[i],PeriodRatio_[i],ExtMaHandle_TF2_[i],InpTimeFrame_[i],            InpAppliedMA_[i],            InpMaPeriod_[i],            InpAmaFast_[i],            InpAmaSlow_[i],            InpCmoPeriod_[i],            InpAppliedPrice_[i]     ,InpTimeFrameName[i]);
    i++;
    OnInit_iunima_mtf_ru_(i+offset_buffer,i+typeno,ExtMaBuffer_TF2_3,ExtMaArray_TF2_3,            PeriodSeconds_TF1_[i],PeriodSeconds_TF2_[i],PeriodRatio_[i],ExtMaHandle_TF2_[i],InpTimeFrame_[i],            InpAppliedMA_[i],            InpMaPeriod_[i],            InpAmaFast_[i],            InpAmaSlow_[i],            InpCmoPeriod_[i],            InpAppliedPrice_[i]     ,InpTimeFrameName[i]);
    i++;
    OnInit_iunima_mtf_ru_(i+offset_buffer,i+typeno,ExtMaBuffer_TF2_4,ExtMaArray_TF2_4,            PeriodSeconds_TF1_[i],PeriodSeconds_TF2_[i],PeriodRatio_[i],ExtMaHandle_TF2_[i],InpTimeFrame_[i],            InpAppliedMA_[i],            InpMaPeriod_[i],            InpAmaFast_[i],            InpAmaSlow_[i],            InpCmoPeriod_[i],            InpAppliedPrice_[i]     ,InpTimeFrameName[i]);
    i++;
 
}  
//--- input parameters
#ifdef ddddd
ENUM_TIMEFRAMES      InpTimeFrame_2=PERIOD_H1;                          // Timeframe 2 (TF2) period
maswitch1             InpAppliedMA=MODE_SMA;                             // Applied MA method for signal line
int                  InpMaPeriod=14;                                    // MA Period
int                  InpAmaFast=2;                                      // Fast AMA period
int                  InpAmaSlow=30;                                     // Slow AMA period
int                  InpCmoPeriod=9;                                    // CMO period for VIDYA
ENUM_APPLIED_PRICE   InpAppliedPrice=PRICE_CLOSE;                       // Applied price
#endif //ddddd

double                     ExtMaBuffer_TF2_0[];
double                     ExtMaBuffer_TF2_1[];
double                     ExtMaBuffer_TF2_2[];
double                     ExtMaBuffer_TF2_3[];
double                     ExtMaBuffer_TF2_4[];
double                     ExtMaBuffer_TF2_5[];

double                     ExtMaArray_TF2_0[];             
double                     ExtMaArray_TF2_1[];             
double                     ExtMaArray_TF2_2[];             
double                     ExtMaArray_TF2_3[];             
double                     ExtMaArray_TF2_4[];             
double                     ExtMaArray_TF2_5[];             
//--- variables
int                        PeriodRatio_[NUM_OF_iunima_mtf_ru];                // ratio between timeframe 1 (TF1) and timeframe 2 (TF2)
int                        PeriodSeconds_TF1_[NUM_OF_iunima_mtf_ru];            // TF1 period in seconds
int                        PeriodSeconds_TF2_[NUM_OF_iunima_mtf_ru];            // TF2 period in seconds
int                        ExtMaHandle_TF2_[NUM_OF_iunima_mtf_ru];              // ma handle TF2
bool                       ShowErrorMessages_[NUM_OF_iunima_mtf_ru];       // turn on/off error messages for debugging




//+------------------------------------------------------------------+
//| Abbreviate applied price to single character                     |
//+------------------------------------------------------------------+
string fNamePriceShort(ENUM_APPLIED_PRICE aPrice)
  {
   switch(aPrice)
     {
      case PRICE_CLOSE:
         return("C");
      case PRICE_HIGH:
         return("H");
      case PRICE_LOW:
         return("L");
      case PRICE_MEDIAN:
         return("M");
      case PRICE_OPEN:
         return("O");
      case PRICE_TYPICAL:
         return("T");
      case PRICE_WEIGHTED:
         return("W");
      default:
         return("");
     }
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
//★



void OnInit_iunima_mtf_ru_(int buffno,int typeno,
 double &ExtMaBuffer_TF2[],double &ExtMaArray_TF2[],int &PeriodSeconds_TF1,int &PeriodSeconds_TF2,
 int &PeriodRatio,int &ExtMaHandle_TF2,
 ENUM_TIMEFRAMES      InpTimeFrame_2,
maswitch1             InpAppliedMA,
int                  InpMaPeriod,
int                  InpAmaFast,
int                  InpAmaSlow,
int                  InpCmoPeriod,
ENUM_APPLIED_PRICE   InpAppliedPrice,
string name
 )
  {
	if(InpTimeFrame_2 == -1){ return;}//add 20200509 
//--- indicator buffers mapping
   SetIndexBuffer(buffno,ExtMaBuffer_TF2,INDICATOR_DATA);
   PlotIndexSetDouble(buffno,PLOT_EMPTY_VALUE,0);
   ArrayInitialize(ExtMaBuffer_TF2,0);

//--- set buffers as series, most recent entry at index [0]
   ArraySetAsSeries(ExtMaBuffer_TF2,true);
//--- set arrays as series, most recent entry at index [0]
   ArraySetAsSeries(ExtMaArray_TF2,true);

//--- set accuracy
   IndicatorSetInteger(INDICATOR_DIGITS,Digits()-1);

//--- calculate at which bar to start drawing indicators
   PeriodSeconds_TF1=PeriodSeconds();
   PeriodSeconds_TF2=PeriodSeconds(InpTimeFrame_2);

   if(PeriodSeconds_TF1<PeriodSeconds_TF2)
      PeriodRatio=PeriodSeconds_TF2/PeriodSeconds_TF1;

////--- name for indicator
   //IndicatorSetString(INDICATOR_SHORTNAME,"MTF_MA("+string(InpMaPeriod)+")"+name);
//
//--- name for plots
   string Label;

   switch(InpAppliedMA)
     {
      case Simple:
         Label="SMA("+string(InpMaPeriod)+","+fNamePriceShort(InpAppliedPrice)+")"+name;
         break;
      case Exponential:
         Label="EMA("+string(InpMaPeriod)+","+fNamePriceShort(InpAppliedPrice)+")";
         break;
      case Smoothed:
         Label="SMMA("+string(InpMaPeriod)+","+fNamePriceShort(InpAppliedPrice)+")";
         break;
      case LinearWeighted:
         Label="LWMA("+string(InpMaPeriod)+","+fNamePriceShort(InpAppliedPrice)+")";
         break;
      case AMA:
         Label="AMA("+string(InpMaPeriod)+","+string(InpAmaFast)+","+string(InpAmaSlow)+","+fNamePriceShort(InpAppliedPrice)+")";
         break;
      case DEMA:
         Label="DEMA("+string(InpMaPeriod)+","+fNamePriceShort(InpAppliedPrice)+")";
         break;
      case FRAMA:
         Label="FRAM("+string(InpMaPeriod)+","+fNamePriceShort(InpAppliedPrice)+")";
         break;
      case TEMA:
         Label="TEMA("+string(InpMaPeriod)+","+fNamePriceShort(InpAppliedPrice)+")";
         break;
      case VIDYA:
         Label="VIDYA("+string(InpMaPeriod)+","+string(InpCmoPeriod)+","+fNamePriceShort(InpAppliedPrice)+")";
         break;
     }

   PlotIndexSetString(typeno,PLOT_LABEL,Label);

//--- get MA handle
   switch(InpAppliedMA)
     {
      case Simple:
         ExtMaHandle_TF2=iMA(NULL,InpTimeFrame_2,InpMaPeriod,0,MODE_SMA,InpAppliedPrice);
         break;
      case Exponential:
         ExtMaHandle_TF2=iMA(NULL,InpTimeFrame_2,InpMaPeriod,0,MODE_EMA,InpAppliedPrice);
         break;
      case Smoothed:
         ExtMaHandle_TF2=iMA(NULL,InpTimeFrame_2,InpMaPeriod,0,MODE_SMMA,InpAppliedPrice);
         break;
      case LinearWeighted:
         ExtMaHandle_TF2=iMA(NULL,InpTimeFrame_2,InpMaPeriod,0,MODE_LWMA,InpAppliedPrice);
         break;
      case AMA:
         ExtMaHandle_TF2=iAMA(NULL,InpTimeFrame_2,InpMaPeriod,InpAmaFast,InpAmaSlow,0,InpAppliedPrice);
         break;
      case DEMA:
         ExtMaHandle_TF2=iDEMA(NULL,InpTimeFrame_2,InpMaPeriod,0,InpAppliedPrice);
         break;
      case FRAMA:
         ExtMaHandle_TF2=iFrAMA(NULL,InpTimeFrame_2,InpMaPeriod,0,InpAppliedPrice);
         break;
      case TEMA:
         ExtMaHandle_TF2=iTEMA(NULL,InpTimeFrame_2,InpMaPeriod,0,InpAppliedPrice);
         break;
      case VIDYA:
         ExtMaHandle_TF2=iVIDyA(NULL,InpTimeFrame_2,InpCmoPeriod,InpMaPeriod,0,InpAppliedPrice);
         break;
     }

//--- initialization done
  }
//+------------------------------------------------------------------+
//| Universal Moving Average                                         |
//+------------------------------------------------------------------+
int OnCalculate_iunima_mtf_ru(const int rates_total,
                const int prev_calculated,
                const datetime &Time[],
                const double &Open[],
                const double &High[],
                const double &Low[],
                const double &Close[],
                const long &TickVolume[],
                const long &Volume[],
                const int &Spread[]){
    int i=0;int ret[NUM_OF_iunima_mtf_ru];                
    ret[i]=OnCalculate_iunima_mtf_ru_(rates_total,prev_calculated,Time,Open,High,Low,Close,TickVolume,Volume,Spread,
                ExtMaHandle_TF2_[i],
                ShowErrorMessages_[i],
                ExtMaBuffer_TF2_0,ExtMaArray_TF2_0,PeriodSeconds_TF1_[i],PeriodSeconds_TF2_[i]
                ,InpTimeFrame_[i]
                ,InpMaPeriod_[i]
                ,InpAppliedPrice_[i]);
    i++;
    
 //#ifdef zzz   
    ret[i]=OnCalculate_iunima_mtf_ru_(rates_total,prev_calculated,Time,Open,High,Low,Close,TickVolume,Volume,Spread,
                ExtMaHandle_TF2_[i],
                ShowErrorMessages_[i],
                ExtMaBuffer_TF2_1,ExtMaArray_TF2_1,PeriodSeconds_TF1_[i],PeriodSeconds_TF2_[i]
                ,InpTimeFrame_[i]
                ,InpMaPeriod_[i]
                ,InpAppliedPrice_[i]);
    i++;
    ret[i]=OnCalculate_iunima_mtf_ru_(rates_total,prev_calculated,Time,Open,High,Low,Close,TickVolume,Volume,Spread,
                ExtMaHandle_TF2_[i],
                ShowErrorMessages_[i],
                ExtMaBuffer_TF2_2,ExtMaArray_TF2_2,PeriodSeconds_TF1_[i],PeriodSeconds_TF2_[i]
                ,InpTimeFrame_[i]
                ,InpMaPeriod_[i]
                ,InpAppliedPrice_[i]);
    i++;
    ret[i]=OnCalculate_iunima_mtf_ru_(rates_total,prev_calculated,Time,Open,High,Low,Close,TickVolume,Volume,Spread,
                ExtMaHandle_TF2_[i],
                ShowErrorMessages_[i],
                ExtMaBuffer_TF2_3,ExtMaArray_TF2_3,PeriodSeconds_TF1_[i],PeriodSeconds_TF2_[i]
                ,InpTimeFrame_[i]
                ,InpMaPeriod_[i]
                ,InpAppliedPrice_[i]);
    i++;
    ret[i]=OnCalculate_iunima_mtf_ru_(rates_total,prev_calculated,Time,Open,High,Low,Close,TickVolume,Volume,Spread,
                ExtMaHandle_TF2_[i],
                ShowErrorMessages_[i],
                ExtMaBuffer_TF2_4,ExtMaArray_TF2_4,PeriodSeconds_TF1_[i],PeriodSeconds_TF2_[i]
                ,InpTimeFrame_[i]
                ,InpMaPeriod_[i]
                ,InpAppliedPrice_[i]);
    
    for(i=0;i< NUM_OF_iunima_mtf_ru ;i++){
        if(ret[i]==0){
            return(prev_calculated);
        }
    }
//#endif
//if(ret[0]==0)return(prev_calculated);
    return(rates_total);

}



int OnCalculate_iunima_mtf_ru_(const int rates_total,
                const int prev_calculated,
                const datetime &Time[],
                const double &Open[],
                const double &High[],
                const double &Low[],
                const double &Close[],
                const long &TickVolume[],
                const long &Volume[],
                const int &Spread[],
                int &ExtMaHandle_TF2,
                bool &ShowErrorMessages,
                double &ExtMaBuffer_TF2[],double &ExtMaArray_TF2[],int &PeriodSeconds_TF1,int &PeriodSeconds_TF2                
                ,ENUM_TIMEFRAMES      InpTimeFrame_2
                ,int                  InpMaPeriod
                ,ENUM_APPLIED_PRICE   InpAppliedPrice
                )
  {
	if(InpTimeFrame_2 == -1){ return rates_total;}//add 20200509 


  //debug zzz
  double dd=Close[0];
//--- set arrays as series, most recent entry at index [0]
   ArraySetAsSeries(Time,true);
//--- check for data
   int bars_TF2=Bars(NULL,InpTimeFrame_2);
   if(bars_TF2<InpMaPeriod)
      return(prev_calculated);

//--- not all data may be calculated
   int calculated_TF2;

   calculated_TF2=BarsCalculated(ExtMaHandle_TF2);
   if(calculated_TF2<bars_TF2)
     {
//#ifdef zzzzz  
      if(ShowErrorMessages) Print("Not all data of ExtMaHandle_TF2 has been calculated (",calculated_TF2," bars). Error",GetLastError());
//zzz      return(0);
            return (prev_calculated);
//#endif// zzzzz
     }
//--- set limit for which bars need to be (re)calculated
   int limit;
   if(prev_calculated==0 || prev_calculated<0 || prev_calculated>rates_total)
      limit=rates_total-1;
   else
      limit=rates_total-prev_calculated;

//--- create variable required to convert between TF1 and TF2
   datetime convertedTime=0;

//--- loop through TF1 bars to set buffer TF1 values
   for(int i=limit;i>=0;i--)
     {
//#ifdef zzzz
      //--- convert time TF1 to nearest earlier time TF2 for a bar opened on TF2 which is to close during the current TF1 bar
      //--- use this for calculations with PRICE_CLOSE, PRICE_HIGH, PRICE_LOW, PRICE_MEDIAN, PRICE_TYPICAL, PRICE_WEIGHTED
      if(InpAppliedPrice!=PRICE_OPEN)
         convertedTime=Time[i]+PeriodSeconds_TF1-PeriodSeconds_TF2;
      //--- convert time TF1 to nearest earlier time TF2 for a bar opened on TF2 at the same time or before the current TF1 bar
      //--- use this for calculations with PRICE_OPEN
      if(InpAppliedPrice==PRICE_OPEN)
         convertedTime=Time[i];

      //--- check if TF2 data is available at convertedTime
      datetime tempTimeArray_TF2[];
      int cret=
      CopyTime(NULL,InpTimeFrame_2,calculated_TF2-1,1,tempTimeArray_TF2);
      
      if( cret !=1 ){
        return prev_calculated;
      }
      //--- no TF2 data available
      if(convertedTime<tempTimeArray_TF2[0])
        {
         ExtMaBuffer_TF2[i]=EMPTY_VALUE;
         //ExtMaBuffer_TF2[i]=Close[i];//debug zzz
         continue;
        }
      //--- get ma buffer values of TF2
      if(CopyBuffer(ExtMaHandle_TF2,0,convertedTime,1,ExtMaArray_TF2)<=0)
        {
         if(ShowErrorMessages) Print("Getting MA TF2 failed! Error",GetLastError());
         return(prev_calculated);
        }
      //--- set ma TF2 buffer on TF1
      else{
         ExtMaBuffer_TF2[i]=ExtMaArray_TF2[0];
        //#ifdef delll
         if(dd < Close[0]+Close[0]*0.1){
            dd = Close[0]-Close[0]*0.1;
         }else{
            dd = dd +Close[0]*0.01*(rates_total%10);
         }
        //#endif //delll  
         ExtMaBuffer_TF2[rates_total-1-i]=ExtMaArray_TF2[0];// debug zzz
        
      }
//#endif //zzzz
     }//for
//--- return value of rates_total, will be used as prev_calculated in next call

   return(rates_total);
  }
//+------------------------------------------------------------------+
#ifndef _func_GetTimeColor
#define _func_GetTimeColor
int GetTimeColor(ENUM_TIMEFRAMES p){
int cl = clrWhite;
	switch(p)
	{
        case PERIOD_CURRENT:
            cl = GetTimeColor(_Period);
            break;
		case PERIOD_M1:
		    //cl = clrWhite;
			cl = 0xFFFFFF;//	　	white
		    break;
		case PERIOD_M5:
		    //cl = clrYellow;
			cl = 0xFFFF00;//	　	yellow
		    break;
		case PERIOD_M15:
			cl = 0x0000FF;//	　	blue
		
		    break;
		case PERIOD_M30:
			cl = 0x00FF00;//	　	lime
		    break;
		case PERIOD_H1:
	    	//cl = clrYellow;
			cl = 0x00FFFF;//	　	aqua
		    break;
		case PERIOD_H4:
			cl = 0xFF0000;//	　	red
		    break;
		case PERIOD_D1:
			cl = 0xFF00FF;//	　	fuchsia
		    break;		    
		case PERIOD_W1:
		    cl = clrLavenderBlush;
		    break;
		default:
		    break;
	}
    return cl;		    
}
#endif// _func_GetTimeColor



#ifdef comenntttttt
三原色（赤、緑、青）
16 進数は 0x00BBGGRR 
cl = 0x0000FF;//	　	blue
cl = 0x00FFFF;//	　	aqua
cl = 0x00FF00;//	　	lime
cl = 0xFFFF00;//	　	yellow
cl = 0xFF0000;//	　	red
cl = 0xFF00FF;//	　	fuchsia
cl = 0xFFFFFF;//	　	white
cl = 0x000000;//	　	black



cl = 0x000000;//	　	black


カスタム指標には表示に活用できる多数の設定があります。これらの設定は、IndicatorSetDouble()、IndicatorSetInteger() 及び IndicatorSetString() 関数を使用して対応する指標のプロパティに行われます。指標のプロパティの識別子は ENUM_CUSTOMIND_PROPERTY 列挙にリストされています。

ENUM_CUSTOMIND_PROPERTY_INTEGER
IndicatorSetInteger

この関数は、対応する指標プロパティの値を設定します。指標プロパティは int または 型でなければなりません。この関数には 2 つのバージョンがあります。

プロパティ識別子との呼び出し



bool  IndicatorSetInteger( 
   int  prop_id,          // 識別子 
  int  prop_value        // 設定する値 
  );
 

プロパティ識別子と修飾子との呼び出し



bool  IndicatorSetInteger( 
   int  prop_id,          // 識別子 
  int  prop_modifier,    // 修飾子 
  int  prop_value        // 設定する値 
  ）
 
INDICATOR_LEVELCOLOR


IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,clrBlack);

#endif // commentttttt

