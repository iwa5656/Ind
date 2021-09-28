#include "lib\lib_file_func.mqh"
#property indicator_chart_window

#property indicator_buffers 10
#property indicator_plots   10



int a[];
int b[];
int gethairetu(int i){
    if(i==0){
        //return(a);
        }else{ 
//        return(b);
        }
        return 0;
}
int inpp[5];

void func(int &i){
    i=100;
}
void func2(double &dd[]){
    CopyBuffer(0,0,0,1,dd);
}    

int arrow_id;
void OnInit()
  {
  init_arrow_view();
  int i;
  	for(i=0;i<10;i++){
		writestring_file("test.txt",IntegerToString(i),true);
	}
  
printf("Oninit");
  }

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
  
  
  test_arrow_view(time[0],close[0]);
  test_main();
   return(rates_total);
  }
  
  
  void init_arrow_view(void){
   arrow_id=32;
  }
  void test_arrow_view(datetime t,double v){
  
   if(isNewBar(Symbol(),Period())==true){
         if(arrow_id>255){arrow_id=32;}
         
         datetime time=TimeCurrent(); 
         string up_arrow="up_arrow="+IntegerToString(arrow_id)+":"+TimeToString(time); 
         double lastClose[1]; 
         int close=CopyClose(Symbol(),Period(),0,1,lastClose);     // 終値を取得 
      //--- 価格が取得された 
        if(close>0) 
           { 
#ifdef delll           
           ObjectCreate(0,up_arrow,OBJ_ARROW,0,0,0,0,0);         // 矢印を作成 
          ObjectSetInteger(0,up_arrow,OBJPROP_ARROWCODE,arrow_id);   // 矢印のコードを作成 
          ObjectSetInteger(0,up_arrow,OBJPROP_COLOR,clrWhite );
          ObjectSetInteger(0,up_arrow,OBJPROP_TIME,time);       // 時間を設定 
          ObjectSetDouble(0,up_arrow,OBJPROP_PRICE,lastClose[0]);// 価格を設定 
//          ObjectSetInteger(0,up_arrow,OBJPROP_WIDTH,3);
          ObjectSetInteger(0,up_arrow,OBJPROP_WIDTH,arrow_id%15);
          ChartRedraw(0);                                       // 矢印を描画 
          arrow_id++;
 #endif //dell
 
 
 double pos_offset=chgPips2price(5.0);//5pips その方向にずらす。
 
 
           ObjectCreate(0,up_arrow,OBJ_ARROW,0,0,0,0,0);         // 矢印を作成 
 
          ObjectSetInteger(0,up_arrow,OBJPROP_ARROWCODE,242);   // 矢印のコードを作成 
          ObjectSetInteger(0,up_arrow,OBJPROP_COLOR,clrWhite );
          ObjectSetInteger(0,up_arrow,OBJPROP_TIME,time);       // 時間を設定 
          ObjectSetDouble(0,up_arrow,OBJPROP_PRICE,lastClose[0]+pos_offset*0);// 価格を設定 
          ObjectSetInteger(0,up_arrow,OBJPROP_WIDTH,6);
          ChartRedraw(0);                                       // 矢印を描画 
 
            up_arrow=up_arrow+":2";
           ObjectCreate(0,up_arrow,OBJ_ARROW,0,0,0,0,0);         // 矢印を作成 
          ObjectSetInteger(0,up_arrow,OBJPROP_ARROWCODE,246);   // 矢印のコードを作成 
          ObjectSetInteger(0,up_arrow,OBJPROP_COLOR,clrWhite );
          ObjectSetInteger(0,up_arrow,OBJPROP_TIME,time);       // 時間を設定 
          ObjectSetDouble(0,up_arrow,OBJPROP_PRICE,lastClose[0]+pos_offset*1);// 価格を設定 
          ObjectSetInteger(0,up_arrow,OBJPROP_WIDTH,6);
          ChartRedraw(0);                                       // 矢印を描画 
 
 
 
 
 
 
 
 
 
          }
   } 
  }
  
  
double chgPips2price(double d){return(d*Point()*10.0);}
double chgPrice2Pips(double d){return(d/(Point()*10.0));}
  
  bool isNewBar(string symbol, ENUM_TIMEFRAMES tf)
{
   static datetime bartime = 0;
   static long ticktime = 0;
   MqlTick tick;
   SymbolInfoTick(symbol, tick);
   if(iTime(symbol, tf, 0) != bartime)
   {
      bartime = iTime(symbol, tf, 0);
      ticktime = tick.time_msc;
      return true;
   }
   else if(ticktime == tick.time_msc) return true;
   return false;
}
  
  //+------------------------------------------------------------------+ 
//| テキスト記述を取得                                                    | 
//+------------------------------------------------------------------+ 
string getUninitReasonText(int reasonCode) 
  { 
   string text=""; 
//--- 
   switch(reasonCode) 
     { 
     case REASON_ACCOUNT: 
         text="Account was changed";break; 
     case REASON_CHARTCHANGE: 
         text="Symbol or timeframe was changed";break; 
     case REASON_CHARTCLOSE: 
         text="Chart was closed";break; 
     case REASON_PARAMETERS: 
         text="Input-parameter was changed";break; 
     case REASON_RECOMPILE: 
         text="Program "+__FILE__+" was recompiled";break; 
     case REASON_REMOVE: 
         text="Program "+__FILE__+" was removed from chart";break; 
     case REASON_TEMPLATE: 
         text="New template was applied to chart";break; 
     default:text="Another reason"; 
     } 
//--- 
   return text; 
  } 
//+------------------------------------------------------------------+ 
//| エキスパート初期化解除に使用される関数                                    | 
//+------------------------------------------------------------------+ 
void OnDeinit(const int reason) 
  { 
//--- 初期化解除の理由のコード取得の方法その 1 
   Print(__FUNCTION__,"_Uninitalization reason code = ",reason); 
//--- 初期化解除の理由のコード取得の方法その 2  
   Print(__FUNCTION__,"_UninitReason = ",getUninitReasonText(_UninitReason)); 
  }  

void test_main(){

}

//+------------------------------------------------------------------+ 
//| 関数                                    | 
//+------------------------------------------------------------------+ 
//+------------------------------------------------------------------+ 
//| 登録                                    | 
//+------------------------------------------------------------------+ 
//+------------------------------------------------------------------+ 
//| 登録Add                                    | 
//+------------------------------------------------------------------+ 
bool add_pt()