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


void OnInit()
  {
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
  
   return(rates_total);
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