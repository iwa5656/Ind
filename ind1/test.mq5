#include "lib\lib_file_func.mqh"
#property indicator_chart_window

#property indicator_buffers 10
#property indicator_plots   10

#include "lib\lib_xy_func.mqh"


#ifdef delll
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
#endif //delll

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
  
  test11();
  
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
//bool add_pt(){}

bool chg_t2x(datetime Tk,datetime inp_t, ENUM_TIMEFRAMES peri,int &out_bar_idx){
  bool ret=false;
  int t_per_bar=PeriodSeconds(peri);//1barの秒数

  datetime tk,i_t;
  if(Tk>inp_t){
    tk=Tk;i_t=inp_t;
  }else{
    tk=inp_t;i_t=Tk;
  }


  int weekcount=0;//何週間分?
//→週初(月曜0：00)めからＴｋまでのbar数：fromWeekStart_barcount
  datetime fromWeekStart_t=0;
  //週末までのbarの数　週末は金曜23：59
  //datetime toWeekEnd_t=0;
  datetime t_a,t_b,t_c;
  t_a=0;t_b=0;t_c=0;
  MqlDateTime dt_tk;
  ret = TimeToStruct( tk,dt_tk);
  if(ret != false){
    //曜日
    //int day_of_week;   // 曜日（日曜が 0、月曜が 1、...土曜が 6 ） 
    if(dt_tk.day_of_week == 0 || dt_tk.day_of_week == 6){
      ret = false;
    }else{
      fromWeekStart_t=(dt_tk.day_of_week-1)*(24*60*60)+
        (
          dt_tk.hour*60*60+
          dt_tk.min*60+
          dt_tk.sec
        );
      #ifdef delll
      toWeekEnd_barcount=(5-dt_tk.day_of_week)*(24*60*60)+
        (
          (24-dt_tk.hour-1)*60*60+
          (60-dt_tk.min-1)*60+
          (60-dt_tk.sec-1)
        );
      #endif // delll  
      
    }
    t_a=tk-i_t;
    if(t_a>fromWeekStart_t){//土日跨ぎそうか
      t_c=t_a-fromWeekStart_t;
      weekcount=1;
      weekcount =(int)(weekcount + t_c/(7*24*60*60));
      int amari = (int)(t_c%(7*24*60*60));
      if(amari ==0){weekcount--;}
    }else{}
    ret = true;
    out_bar_idx=(int)((t_a-weekcount*(2*24*60*60))/t_per_bar);
    if(Tk>inp_t){
      out_bar_idx = out_bar_idx*(-1);
    }else{
      out_bar_idx = out_bar_idx;
    }
  }
  return ret;
}

#ifdef commentss
基準時間Txとバーインデックスから元の時間を求めるには									
	基準Txからバーインデックス分時間をずらす								
	土日が挟むときはその分時間を足す必要がある。								
		１W分のバーの数は分かるので、Wc							
			バーidx/Wcの絶対値で何週間あるかわかる＝＞						
		x→ｔへ変換							
			Inp	Tk,	基準となる時間				
				bidx	インデックス（ｘ軸）			バーidx	bidx 0がTkと同じ時間　未来は＋、過去がマイナス
				時間軸	peri	または　時間軸の一つのバーの秒数			
bool chg_x2t(datetime Tk,int bidx, ENUM_TIMEFRAMES peri,datetime &out_t){
  bool ret=false;
  int t_per_bar=PeriodSeconds(peri);//1barの秒数

  //→週初(月曜0：00)めからＴｋまでのbar数：fromWeekStart_barcount
  int fromWeekStart_barcount=0;
  //週末までのbarの数　週末は金曜23：59
  int toWeekEnd_barcount=0;
  MqlDateTime dt_struct;
  ret = TimeToStruct( Tk,dt_struct);
  if(ret != false){
    //曜日
    //int day_of_week;   // 曜日（日曜が 0、月曜が 1、...土曜が 6 ） 
    if(dt_struct.day_of_week == 0 || dt_struct.day_of_week == 6){
      ret = false;
    }else{
      fromWeekStart_barcount=(dt_struct.day_of_week-1)*(24*60*60/t_per_bar)+
        (
          dt_struct.hour*60*60+
          dt_struct.min*60+
          dt_struct.sec
        )/t_per_bar;
      toWeekEnd_barcount=(5-dt_struct.day_of_week)*(24*60*60/t_per_bar)+
        (
          (24-dt_struct.hour-1)*60*60+
          (60-dt_struct.min-1)*60+
          (60-dt_struct.sec-1)
        )/t_per_bar;
      
    }
  }
  int abs_bar_count;//絶対数
  abs_bar_count = MathAbs(bidx);
  int weekcount=0;//何週間分?
  if(bidx<0){//過去方向に対して
    if(abs_bar_count>fromWeekStart_barcount){
      //週をまたぐため何週間あるか　＋１
      weekcount=1;
      //何週間分＝int(　（barー①）/時間軸の１Wのbarの数)
      weekcount=weekcount+(abs_bar_count-fromWeekStart_barcount)/(5*24*60*60);
      int amari=(abs_bar_count-fromWeekStart_barcount)%(5*24*60*60);
      if(amari == 0){weekcount--;}
    }else{}//週を跨がない
    //Tkから　　土日分とバーの数分　ずらした時間
    out_t=Tk-(2*24*60*60)*weekcount-(abs_bar_count)*t_per_bar;
    ret = true;
  }else if ( bidx==0 ){
    out_t=Tk;
    ret = true;
  }else{//Tkの未来方向
    if(abs_bar_count>toWeekEnd_barcount){
      //週をまたぐため何週間あるか　＋１
      weekcount=1;
      //何週間分＝int(　（barー①）/時間軸の１Wのbarの数)
      weekcount=weekcount+(abs_bar_count-toWeekEnd_barcount)/(5*24*60*60);
      int amari=(abs_bar_count-toWeekEnd_barcount)%(5*24*60*60);
      if(amari == 0){weekcount--;}
    }else{}//週を跨がない
    //Tkから　　土日分とバーの数分　ずらした時間
    out_t=Tk+(2*24*60*60)*weekcount+(abs_bar_count)*t_per_bar;
    ret = true;
  
  }
  return ret;
}
#endif // comeentss        

void test11(){
bool ret;
datetime Tk=D'2021.10.04 00:30:27';
int bidx=-2;
ENUM_TIMEFRAMES peri=PERIOD_M5;
datetime out_t=0;
//chg_x2t(datetime Tk,int bidx, ENUM_TIMEFRAMES peri,datetime &out_t){

  Tk=D'2021.10.04 00:30:27';
  bidx=-2;
  peri=PERIOD_M5;
  out_t=0;
  printf("Tk="+TimeToString(Tk));
  chg_x2t(Tk,bidx, peri,out_t);
  printf("bidx="+ IntegerToString(bidx)+"  out_t="+TimeToString(out_t));
  printf("---------------------\n");



  Tk=D'2021.10.04 00:00:27';
  bidx=0;
  peri=PERIOD_M5;
  out_t=0;
  printf("Tk="+TimeToString(Tk));
  chg_x2t(Tk,bidx, peri,out_t);
  printf("bidx="+ IntegerToString(bidx)+"  out_t="+TimeToString(out_t));
  printf("---------------------\n");
  
  Tk=D'2021.10.04 00:00:27';
  bidx=-1;
  peri=PERIOD_M5;
  out_t=0;
  printf("Tk="+TimeToString(Tk));
  chg_x2t(Tk,bidx, peri,out_t);
  printf("bidx="+ IntegerToString(bidx)+"  out_t="+TimeToString(out_t));
  printf("---------------------\n");

    
  Tk=D'2021.10.04 00:00:27';
  bidx=0-5*24*60*60/(5*60);
  peri=PERIOD_M5;
  out_t=0;
  printf("Tk="+TimeToString(Tk));
  chg_x2t(Tk,bidx, peri,out_t);
  printf("bidx="+ IntegerToString(bidx)+"  out_t="+TimeToString(out_t));
  printf("---------------------\n");

  Tk=D'2021.10.04 00:00:27';
  bidx=0-5*24*60*60/(5*60)-1;
  peri=PERIOD_M5;
  out_t=0;
  printf("Tk="+TimeToString(Tk));
  chg_x2t(Tk,bidx, peri,out_t);
  printf("bidx="+ IntegerToString(bidx)+"  out_t="+TimeToString(out_t));
  printf("---------------------\n");




  Tk=D'2021.10.01 23:55:27';
  bidx=0;
  peri=PERIOD_M5;
  out_t=0;
  printf("Tk="+TimeToString(Tk));
  chg_x2t(Tk,bidx, peri,out_t);
  printf("bidx="+ IntegerToString(bidx)+"  out_t="+TimeToString(out_t));
  printf("---------------------\n");

  Tk=D'2021.10.01 23:55:27';
  bidx=1;
  peri=PERIOD_M5;
  out_t=0;
  printf("Tk="+TimeToString(Tk));
  chg_x2t(Tk,bidx, peri,out_t);
  printf("bidx="+ IntegerToString(bidx)+"  out_t="+TimeToString(out_t));
  printf("---------------------\n");

  Tk=D'2021.10.01 23:55:27';
  bidx=2;
  peri=PERIOD_M5;
  out_t=0;
  printf("Tk="+TimeToString(Tk));
  chg_x2t(Tk,bidx, peri,out_t);
  printf("bidx="+ IntegerToString(bidx)+"  out_t="+TimeToString(out_t));
  printf("---------------------\n");



  datetime inp_t;
  int out_bar_idx;

  Tk=    D'2021.10.01 23:55:27';
  inp_t= D'2021.10.01 23:55:27';
   //bool chg_t2x(datetime Tk,datetime inp_t, ENUM_TIMEFRAMES peri,int &out_bar_idx){

  chg_t2x(Tk,inp_t, peri,out_bar_idx);
  printf("Tk="+TimeToString(Tk));
  printf("OUT bidx="+ IntegerToString(out_bar_idx)+"  inp_t="+TimeToString(inp_t));
  printf("---------------------\n");


  Tk=    D'2021.10.04 00:00:27';
  inp_t= D'2021.10.01 23:55:27';
   //bool chg_t2x(datetime Tk,datetime inp_t, ENUM_TIMEFRAMES peri,int &out_bar_idx){

  chg_t2x(Tk,inp_t, peri,out_bar_idx);
  printf("Tk="+TimeToString(Tk));
  printf("OUT bidx="+ IntegerToString(out_bar_idx)+"  inp_t="+TimeToString(inp_t));
  printf("---------------------\n");



  Tk=    D'2021.10.11 00:00:27';
  inp_t= D'2021.10.01 23:55:27';
   //bool chg_t2x(datetime Tk,datetime inp_t, ENUM_TIMEFRAMES peri,int &out_bar_idx){

  chg_t2x(Tk,inp_t, peri,out_bar_idx);
  printf("Tk="+TimeToString(Tk));
  printf("OUT bidx="+ IntegerToString(out_bar_idx)+"  inp_t="+TimeToString(inp_t));
  printf("---------------------\n");




 inp_t=    D'2021.10.11 00:00:27';
  Tk= D'2021.10.01 23:55:27';
   //bool chg_t2x(datetime Tk,datetime inp_t, ENUM_TIMEFRAMES peri,int &out_bar_idx){

  chg_t2x(Tk,inp_t, peri,out_bar_idx);
  printf("Tk="+TimeToString(Tk));
  printf("OUT bidx="+ IntegerToString(out_bar_idx)+"  inp_t="+TimeToString(inp_t));
  printf("---------------------\n");


double x,y;
double dist;

imi_point d,e,f;
d.x=0;d.y=0;e.x=1;e.y=1;f.x=-1;f.y=1;
dist = MathSqrt(2);
printf("outret="+chk_point_lineAndLine_inner_upperD_imi(d,e,f,dist)  +  "期待値＝1");


d.x=0;d.y=0;e.x=1;e.y=1;f.x=0;f.y=0;
dist = MathSqrt(2);
printf("outret="+chk_point_lineAndLine_inner_upperD_imi(d,e,f,dist)  +  "期待値＝1");

d.x=0;d.y=0;e.x=1;e.y=1;f.x=0.1;f.y=0;
dist = MathSqrt(2);
printf("outret="+chk_point_lineAndLine_inner_upperD_imi(d,e,f,dist)  +  "期待値＝0");

d.x=0;d.y=0;e.x=1;e.y=1;f.x=0;f.y=-0.1;
dist = MathSqrt(2);
printf("outret="+chk_point_lineAndLine_inner_upperD_imi(d,e,f,dist)  +  "期待値＝0");


d.x=0;d.y=0;e.x=1;e.y=1;f.x=-0.5;f.y=0.5;
dist = MathSqrt(2);
printf("outret="+chk_point_lineAndLine_inner_upperD_imi(d,e,f,dist)  +  "期待値＝1");



//dist
d.x=0;d.y=0;e.x=1;e.y=1;f.x=1;f.y=-1;
printf("outret="+cal_point_line_dist_imi(d,e,f) +  "期待値＝ru-to2");
;


//
real_point a,b,c;
  Tk=    D'2021.10.11 00:00:27';
  a.t= D'2021.10.01 00:00:00';
  a.v=1.1000;

  a.t= D'2021.10.01 01:00:00';
  a.v=1.1020;





}