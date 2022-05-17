#define  debug_20211101

//---------------------------
//----------option-------
//---------------------------
//#define USE_CALC_PASS_kako
//#define USE_HYOUKA
#define USE_ZIGZAG_M1 
#define USE_ZIGZAG_M5 
#define USE_ZIGZAG_M15

#define USE_ZIGZAG_M30
#define USE_ZIGZAG_H1
#define USE_ZIGZAG_H4
#define USE_ZIGZAG_D1

//#define USE_Tick_bar  //Tick barをりようする
#define USE_OnDEinit_Fractals
//#define USE_Fractals
//#define USE_OnDeinit_output_zigzag_output_each_period   //ファイルへZigzagデータを出力
//#define USE_out_candle_debug
//#define USE_debug_candle_date_view    //ファイル出力

//パターン表示利用？
//#define USE_pt_range_flag_sup  //パターン認識と表示をする。


#define USE_debug_during_Period_hanndann   //テスト期間内かの判定

//tpsl
#define USE_tpsl_view_ctr //tpslの結果＋エントリー情報を出力したい

//cci debug use
//#define debug_CCI_USE


//debug call Lcn 2回エントリー
//#define USE_debug_Lcn_2kaicall

//----view fibo
//#define USE_fibo_expansion_M5
//#define USE_fibo_expansion_M15
//#define USE_fibo_expansion_M30
//#define USE_fibo_expansion_H1
//#define USE_fibo_expansion_H4
//#define USE_fibo_expansion_D1

//#define USE_fibo_M5
//#define USE_fibo_M15
//#define USE_fibo_M30
//#define USE_fibo_H1
//#define USE_fibo_H4
//#define USE_fibo_D1





//---------------------------
//---------------------------

input double Inp_nobiritu =1.0;// tp d12率
input double Inp_songiriritu= 1.15;//　sl d12率
input double Inp_tp_per_sl_hiritu=1.0;// tp/sl率以上でエントリー可とする
input bool Inp_VjiUse=false;// \Vjiつかうｔ、使わないF
#define USE_IND_TO_EA_FOR_OPTIMUM_TESTER //最適化時T、単体動作時はF　グローバル変数最適化時使えないため

double nobiritu;
double songiriritu;

input double Inp_para_double1 =0.1;//double para1
input double Inp_para_double2 =1.0;//double para2
input double Inp_para_double3 =0.2;//double para3
input double Inp_para_double4 =2.0;//double para4
input double Inp_para_int1 =2;//int para1
input double Inp_para_int2 =-1;//int para2
input double Inp_para_int3 =0;//int para2


input bool use_calc_pass_kako=true;  // 過去全部計算F:一部T
input int use_calc_pass_kako_num=5000;  // 過去何bar分計算するか（一部計算の時有効）
 


//input ENUM_TIMEFRAMES Inp_base_time_frame = PERIOD_M5;// 評価時間軸
input ENUM_TIMEFRAMES Inp_base_time_frame = PERIOD_M5;// 評価時間軸
//input ENUM_TIMEFRAMES Inp_base_time_frame = PERIOD_H1;// 評価時間軸
//input ENUM_TIMEFRAMES Inp_base_time_frame = PERIOD_H4;// 評価時間軸


input int Inp_MAPO_period0=20;//MA周期Fast
input int Inp_MAPO_period1=75;//MA周期Middle
input int Inp_MAPO_period2=200;//MA周期Slow
input int Inp_MAPO_period3=10;//MA周期VeryFast
input int Inp_MAPO_matype=1;//SMA:0,EMA:1


//#define Lib_iunima_mtf_ru

int idebug;
#ifdef Lib_iunima_mtf_ru
#include "iunima_mtf_ru.mqh"
#endif// Lib_iunima_mtf_ru

#ifdef USE_tpsl_view_ctr
#include "tpsl_ctrl.mqh"
#endif// USE_tpsl_view_ctr

#include "func_view_text.mqh"

#define USE_Lib_Myfunc_Ind_entry_exit
#ifdef USE_Lib_Myfunc_Ind_entry_exit
#include <_inc\\動的エントリー監視LIB\\Lib_Myfunc_Ind_entry_exit.mqh> //SetSendData_forEntry_tpsl_direct_ctrl(int EntryDirect,int hyoukaNo,int hyoukaSyuhouNo,double EntryPrice,double Tp_Price,double Sl_Price,double lots)
#endif//USE_Lib_Myfunc_Ind_entry_exit

#include "lib\Lib_xy_func.mqh"

//+------------------------------------------------------------------+
//|                                                        Ticks.mq5 |
//|                        Copyright 2010, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "2010, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
//#property indicator_separate_window
#property indicator_chart_window                //Indicator in separate Ewindow
#property indicator_buffers 7+2+5+1   //iunima_mtf_ru*5

#define  buffer_MAX 300
//#define  buffer_MAX 60000

//Specify the names, shown in the Data Window
#property indicator_label1 "Open;High;Low;Close"

#property indicator_plots 3 +2+5    //iunima_mtf_ru*5                    //Number of graphic plots

#property indicator_type1 DRAW_COLOR_CANDLES    //Drawing style - colored candles
#property indicator_width1 3                    ///Width of a line (optional)

//EMA
#property indicator_label2 "EMA"
//#property indicator_type2   DRAW_LINE
#property indicator_type2   DRAW_NONE   //データ渡し用
#property indicator_color2  clrYellow 
#property indicator_style2 STYLE_SOLID 
#property indicator_width2  3 

//目安の目印を最後のバーの上下に表示させる nPips: [1]に表示、バーずれたら、値を変えるだけ
#property indicator_type3   DRAW_ARROW 
#property indicator_label3 "mejirushi"
#property indicator_color3  clrYellow//clrAzure//clrYellow 
#property indicator_style3 STYLE_SOLID 
#property indicator_width3  3



#property indicator_label4 "Fractal"
#property indicator_label5 "Fractal2"

#property indicator_label6 "M1"
#property indicator_label7 "MM"
#property indicator_label8 "MMM"
#property indicator_label9 "MMMM"
#property indicator_label10 "MMMMM"

 
//#include "Fractals.mqh"
double buffLandmark[],buffLandmarkdata[buffer_MAX]; // 描画用バッファとデータ用バッファ
input double LandMarkW = 5.0;// 上の指標用の幅設定LandMarkW

//#include "Zigzag.mqh"
#include "class_allcandle.mqh"

#ifdef USE_pt_range_flag_sup
#include "classMethod.mqh"
//#include "classMethod_range.mqh"
#include "classMethod_flag.mqh"
#endif // USE_pt_range_flag_sup

#include "Trade_nn\Trade_01.mqh"
                                                //Declaration of buffers
double buffer_open[],buffer_high[],buffer_low[],buffer_close[]; //Buffers for data
double buffer_open_tick[buffer_MAX],buffer_high_tick[buffer_MAX],buffer_low_tick[buffer_MAX],buffer_close_tick[buffer_MAX]; //Buffers for data
double buffer_color_line[];  //Buffer for color indexes
double buffer_tmp[1];        //Temporary buffer for RSI values
int n_tickcount;
ulong counttick;
//--- input parameters
input int      number_of_ticks=1000;
input int      points_indent=10;
int     getticks=70*40; // The number of required ticks 
input int max_n=70;
//--- indicator buffers
double         BidBuffer[];
double         AskBuffer[];
int ticks;
int Tick_bar_NUM;
int pre_rates_total;
bool flag_new_bar;
//EMA

bool flag_EMA_init;
double	buffEMA[]; // for draw data
double	buffEMAdata[buffer_MAX];// original data
input int EMA_n=21;// 期間
input int tick_view_type = 0;//どの精度何桁？０がそのまま、１PiPsはEURUSで４。tick_view_type
//input double d_seido = 0.0001; // eq精度.01JU.0001 price 1Pips
input double d_seido = 0.011; // eq精度.01JU.0001 price 1Pips
// bar count
long make_bar_count; // 最大　buffer_MAX

//option input sono2
input bool bUSE_view_mesenkirikawari_arrow = false;//目線切り替わりを矢印で表示　黒塗り斜めは目線切り替わり。中抜け矢印は続伸
input bool bUSE_view_Zigzag_chgpoint = false;//zigzagの線がどこで確定するかわかるようにする。
input bool bUSE_view_output_Cn_kirikawari= true;	//Cn　続伸、逆　をジャーナルにテキスト出力

input bool bUSE_view_Fractals_Day= false;	//日足にあたるFractal（高値、安値を表示）



// test
bool pre_pattern_pt_sup;
int sz1[10];
int  global_rates_total;
int  golobal_prev_calculated;
//new bar判定
datetime timeM1[],timeM5[],timeM15[],timeM30[],timeH1[],timeH4[],timeD1[],timeW1[],timeMN1[];
bool flagchgbarM1,flagchgbarM5,flagchgbarM15,flagchgbarM30,flagchgbarH1,flagchgbarH4,flagchgbarD1,flagchgbarW1,flagchgbarMN1;
datetime pre_timeM1;
//allcandle
allcandle *p_allcandle;

//MApo
#include "candle_cal\cal_MA\MA_torimatome1.mqh"
MA_torimatome1 *p_MA_torimatome1;

// hyouka
//TradeMethodbase ctrl data
#ifdef aasdfadfasdfaf
#include "TradeMethodFW\classTradeMethodbase.mqh"
#include "TradeMethodFW\classTradeMethod_A1.mqh"
#include "TradeMethodFW\classTradeMethod_A1_1_2.mqh"
#include "TradeMethodFW\classTradeMethod_A1_1_3.mqh"
#include "TradeMethodFW\classTradeMethod_A1_2.mqh"
#include "TradeMethodFW\classTradeMethod_A1_3.mqh"
#include "TradeMethodFW\classTradeMethod_A1_3_1.mqh"
#include "TradeMethodFW\classTradeMethod_A1_4.mqh"
#include "TradeMethodFW\classTradeMethod_A1_5.mqh"
#include "TradeMethodFW\classTradeMethod_A1_6.mqh"

#include "TradeMethodFW\classTradeMethod_A2_1.mqh"
#include "TradeMethodFW\classTradeMethod_A2_2.mqh"
#include "TradeMethodFW\classTradeMethod_A2_3.mqh"
#include "TradeMethodFW\classTradeMethod_A2_4.mqh"
#include "TradeMethodFW\classTradeMethod_A2_5_1.mqh"
#include "TradeMethodFW\classTradeMethod_A2_5_2.mqh"
#include "TradeMethodFW\classTradeMethod_A2_6.mqh"
#endif //aasdafasdfasdf

//#include "TradeMethodFW\classTradeMethod_Z1_1.mqh"
//#include "TradeMethodFW\classTradeMethod_B1_1.mqh"
//#include "TradeMethodFW\classTradeMethod_B1_2.mqh"
//#include "TradeMethodFW\classTradeMethod_B1_3.mqh"
//#include "TradeMethodFW\classTradeMethod_B1_3_PO.mqh"
#include "TradeMethodFW\classTradeMethod_C1_1_PO.mqh"


#define NUM_OF_TMBs 7
TradeMethodbase *TMBs[NUM_OF_TMBs];
int count_TMBs;
void On_init_TMBs(){count_TMBs=0;
//TMBs[0]=new TradeMethod_A1("method_A1",PERIOD_M15,p_allcandle.get_candle_data_pointer(PERIOD_M15),p_allcandle);count_TMBs++;
//TMBs[1]=new TradeMethod_A1_2("method_A1_2",PERIOD_M15,p_allcandle.get_candle_data_pointer(PERIOD_M15),p_allcandle);count_TMBs++;
//TMBs[2]=new TradeMethod_A1_3("method_A1_3",PERIOD_M15,p_allcandle.get_candle_data_pointer(PERIOD_M15),p_allcandle);count_TMBs++;
//TMBs[3]=new TradeMethod_A1_4("method_A1_4",PERIOD_M15,p_allcandle.get_candle_data_pointer(PERIOD_M15),p_allcandle);count_TMBs++;
//TMBs[4]=new TradeMethod_A1_5("method_A1_5",PERIOD_M15,p_allcandle.get_candle_data_pointer(PERIOD_M15),p_allcandle);count_TMBs++;


//TMBs[0]=new TradeMethod_A1_3("method_A1_3",PERIOD_M15,p_allcandle.get_candle_data_pointer(PERIOD_M15),p_allcandle);count_TMBs++;
//TMBs[1]=new TradeMethod_A1_3_1("method_A1_3_1",PERIOD_M15,p_allcandle.get_candle_data_pointer(PERIOD_M15),p_allcandle);count_TMBs++;

//TMBs[0]=new TradeMethod_A1_3_1("method_A1_3_1",PERIOD_M15,p_allcandle.get_candle_data_pointer(PERIOD_M15),p_allcandle);count_TMBs++;
//TMBs[1]=new TradeMethod_A1_3("method_A1_3",PERIOD_M15,p_allcandle.get_candle_data_pointer(PERIOD_M15),p_allcandle);count_TMBs++;
//TMBs[0]=new TradeMethod_A1_3_1("method_A1_3_1",PERIOD_M5,p_allcandle.get_candle_data_pointer(PERIOD_M5),p_allcandle);count_TMBs++;
//TMBs[1]=new TradeMethod_A1_3("method_A1_3",PERIOD_M5,p_allcandle.get_candle_data_pointer(PERIOD_M5),p_allcandle);count_TMBs++;


ENUM_TIMEFRAMES period_inp = Inp_base_time_frame;
//TMBs[0]=new TradeMethod_A1("method_A1",period_inp,p_allcandle.get_candle_data_pointer(period_inp),p_allcandle);count_TMBs++;
//TMBs[1]=new TradeMethod_A1_1_2("method_A1_1_2",period_inp,p_allcandle.get_candle_data_pointer(period_inp),p_allcandle);count_TMBs++;
//TMBs[2]=new TradeMethod_A1_1_3("method_A1_1_3",period_inp,p_allcandle.get_candle_data_pointer(period_inp),p_allcandle);count_TMBs++;
//TMBs[3]=new TradeMethod_A1_2("method_A1_2",period_inp,p_allcandle.get_candle_data_pointer(period_inp),p_allcandle);count_TMBs++;
//TMBs[4]=new TradeMethod_A1_3("method_A1_3",period_inp,p_allcandle.get_candle_data_pointer(period_inp),p_allcandle);count_TMBs++;
//TMBs[5]=new TradeMethod_A1_3_1("method_A1_3_1",period_inp,p_allcandle.get_candle_data_pointer(period_inp),p_allcandle);count_TMBs++;
//TMBs[6]=new TradeMethod_A1_4("method_A1_4",period_inp,p_allcandle.get_candle_data_pointer(period_inp),p_allcandle);count_TMBs++;
//TMBs[7]=new TradeMethod_A1_5("method_A1_5",period_inp,p_allcandle.get_candle_data_pointer(period_inp),p_allcandle);count_TMBs++;

//TMBs[0]=new TradeMethod_A1_6("method_A1_6",period_inp,p_allcandle.get_candle_data_pointer(period_inp),p_allcandle);count_TMBs++;

//TMBs[count_TMBs]=new TradeMethod_A2_1("method_A2_1",period_inp,p_allcandle.get_candle_data_pointer(period_inp),p_allcandle);count_TMBs++;
//TMBs[count_TMBs]=new TradeMethod_A2_2("method_A2_2",period_inp,p_allcandle.get_candle_data_pointer(period_inp),p_allcandle);count_TMBs++;
//TMBs[count_TMBs]=new TradeMethod_A2_3("method_A2_3",period_inp,p_allcandle.get_candle_data_pointer(period_inp),p_allcandle);count_TMBs++;
//TMBs[count_TMBs]=new TradeMethod_A2_4("method_A2_4",period_inp,p_allcandle.get_candle_data_pointer(period_inp),p_allcandle);count_TMBs++;
//TMBs[count_TMBs]=new TradeMethod_A2_5_1("method_A2_5_1",period_inp,p_allcandle.get_candle_data_pointer(period_inp),p_allcandle);count_TMBs++;
//TMBs[count_TMBs]=new TradeMethod_A2_5_2("method_A2_5_2",period_inp,p_allcandle.get_candle_data_pointer(period_inp),p_allcandle);count_TMBs++;
//TMBs[count_TMBs]=new TradeMethod_A2_6("method_A2_6",period_inp,p_allcandle.get_candle_data_pointer(period_inp),p_allcandle);count_TMBs++;

//TMBs[count_TMBs]=new TradeMethod_A2_3_T("method_A2_3_T",period_inp,p_allcandle.get_candle_data_pointer(period_inp),p_allcandle);count_TMBs++;


//TMBs[count_TMBs]=new TradeMethod_B1_1("method_B1_1",period_inp,p_allcandle.get_candle_data_pointer(period_inp),p_allcandle);count_TMBs++;
//TMBs[count_TMBs]=new TradeMethod_B1_3_PO("method_B1_3_PO",period_inp,p_allcandle.get_candle_data_pointer(period_inp),p_allcandle);count_TMBs++;
TMBs[count_TMBs]=new TradeMethod_C1_1_PO("method_C1_1_PO",period_inp,p_allcandle.get_candle_data_pointer(period_inp),p_allcandle);count_TMBs++;

}


void Tick_TMBs(){
    for(int i=0;i<count_TMBs;i++){
        TMBs[i].hyouka();
    }
}
void De_init_TMBs(int ccc){
    for(int i=0;i<count_TMBs;i++){
        TMBs[i].OnDeinit(ccc);
    }
}
void Notice_TorihikikikannNai_TMBs(){
    for(int i=0;i<count_TMBs;i++){
        TMBs[i].notice_TorihikikikannNai();
    }
}
void On_init_MA_torimatome1(){
    candle_data *cc= p_allcandle.get_candle_data_pointer(Inp_base_time_frame);
    if(cc!=NULL){
        p_MA_torimatome1 = new MA_torimatome1(cc);
        p_MA_torimatome1.reg_MApf(0,Inp_MAPO_period0,Inp_MAPO_matype);
        p_MA_torimatome1.reg_MApf(1,Inp_MAPO_period1,Inp_MAPO_matype);
        p_MA_torimatome1.reg_MApf(2,Inp_MAPO_period2,Inp_MAPO_matype);
        p_MA_torimatome1.reg_MApf(3,Inp_MAPO_period3,Inp_MAPO_matype);
    }
}

#ifdef USE_HYOUKA
//MethodPattern *m_hyouka;// ★★ 複数のMethodPatternを持てるようにして、平行にしょりするには
//MethodPattern_range *m_hyouka;// ★★ 複数のMethodPatternを持てるようにして、平行にしょりするには
MethodPattern_flag *m_hyouka;// ★★ 複数のMethodPatternを持てるようにして、平行にしょりするには
#endif//USE_HYOUKA

//debug用
int debug_i1;
bool b_during_test_piriod;//テスト期間中かを確認　trueテスト期間中、falseテスト期間外
datetime pre_test_starttime;//テスト期間開始　一つ前のバー
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                         |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   Comment("");
#ifdef USE_HYOUKA
   m_hyouka.kekka_calc_out_all();
   for(int n =0;n<7;n++){
    m_hyouka.view_kekka_youso_flag(n);
   }
#endif//USE_HYOUKA   

#ifdef USE_tpsl_view_ctr
    tpsl_outall();
#endif// USE_tpsl_view_ctr
    De_init_TMBs(reason);

   printf("Ondeinit...");
#ifdef USE_OnDeinit_output_zigzag_output_each_period   
   zigzag_output();//debug Zigzagout 20200809
#endif// USE_OnDeinit_output_zigzag_output_each_period
   if(reason == REASON_CHARTCHANGE){//チャートが変更
        #ifdef USE_OnDEinit_Fractals
           //OnDeinit_Fractals(reason);
        #endif//USE_OnDEinit_Fractals
//debug 20200509 EAで呼ぶと消えてしまうため
////        p_allcandle.OnDeinit(reason);
////        m_hyouka.OnDeinit(reason);
////        Deinit_XXX_objdelete();
   }
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   //debug
   //init_ema_bolinger();//Ing表示
   
    nobiritu =  Inp_nobiritu;// tp d12率
    songiriritu =  Inp_songiriritu;//　sl d12率
    b_during_test_piriod=false;
    pre_test_starttime=0;
    
printf("%%%&&&Start_Inp_nobiritu="+DoubleToString(Inp_nobiritu,3)+" Inp_songiriritu="+DoubleToString(Inp_songiriritu,3));
  
init_zigzag_debug();//debug 20200603  
    //パターン（Trade)初期化
    init_pt();
    init_Trace();

#ifdef USE_Lib_Myfunc_Ind_entry_exit
    init_entry_check_tick();
    init_entry_exit_ctr_forInd();
#endif//USE_Lib_Myfunc_Ind_entry_exit

	//get_timeframe_value();//debug
  Deinit_XXX_objdelete();
	p_allcandle = new allcandle(
        bUSE_view_Zigzag_chgpoint,
        bUSE_view_mesenkirikawari_arrow,
        bUSE_view_output_Cn_kirikawari,
        Inp_base_time_frame
    );
    p_allcandle.set_Inp_para_double1(Inp_para_double1);
    p_allcandle.set_Inp_para_double2(Inp_para_double2);
    p_allcandle.set_Inp_para_double3(Inp_para_double3);
    p_allcandle.set_Inp_para_double4(Inp_para_double4);
    p_allcandle.set_Inp_para_int1(Inp_para_int1);
    p_allcandle.set_Inp_para_int2(Inp_para_int2);
    p_allcandle.set_Inp_para_int3(Inp_para_int3);
	p_allcandle.Oninit();
//	m_hyouka = new MethodPattern_range("Wtop",PERIOD_M1,p_allcandle.get_candle_data_pointer(PERIOD_M1),p_allcandle);
//	m_hyouka = new MethodPattern_range("Wtop",Inp_base_time_frame,p_allcandle.get_candle_data_pointer(Inp_base_time_frame),p_allcandle);
#ifdef USE_HYOUKA
	m_hyouka = new MethodPattern_flag("Wtop",Inp_base_time_frame,p_allcandle.get_candle_data_pointer(Inp_base_time_frame),p_allcandle);
	m_hyouka.Oninit();
#endif//USE_HYOUKA
    On_init_TMBs();
    On_init_MA_torimatome1();
//--- indicator buffers mapping
//Assign the arrays with the indicator buffers
   SetIndexBuffer(0,buffer_open	,INDICATOR_DATA);
   SetIndexBuffer(1,buffer_high	,INDICATOR_DATA);
   SetIndexBuffer(2,buffer_low	,INDICATOR_DATA);
   SetIndexBuffer(3,buffer_close	,INDICATOR_DATA);
   //Assign the array with the color indexes buffer
   SetIndexBuffer(4,buffer_color_line,INDICATOR_COLOR_INDEX);
   
   // デフォルトの０は描画しないようにする。
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(5,PLOT_EMPTY_VALUE,0);

   //　時系列データへ（０が最新）
   ArraySetAsSeries(buffer_open,true);
   ArraySetAsSeries(buffer_high,true);
   ArraySetAsSeries(buffer_low,true);
   ArraySetAsSeries(buffer_close,true);  
   ArraySetAsSeries(buffer_color_line,true);  
   
   //初期化
   ArrayInitialize(buffer_open,0);
   ArrayInitialize(buffer_high,0);
   ArrayInitialize(buffer_low,0);
   ArrayInitialize(buffer_close,0);  
   ArrayInitialize(buffer_color_line,0);  
   
   //　色の設定　
   setPlotColor_candle(0); 
   n_tickcount=0;
   counttick=0;
   ticks=0;
   //max_n=70;
   getticks=70*100;
   getticks=70*buffer_MAX +1;


//EMA
	flag_EMA_init = false;
   SetIndexBuffer(5,buffEMA,INDICATOR_DATA);
   PlotIndexSetDouble(5,PLOT_EMPTY_VALUE,0);
   //　時系列データへ（０が最新）
   ArraySetAsSeries(buffEMA,true);   
   // init buff 0
   ArrayInitialize(buffEMA,0); 
   ArrayInitialize(buffEMAdata,0); 
   
//
// 目標、サイズ目印　size Landmark
   SetIndexBuffer(6,buffLandmark,INDICATOR_DATA);
   PlotIndexSetDouble(6,PLOT_EMPTY_VALUE,0);
   //　時系列データへ（０が最新）
   ArraySetAsSeries(buffLandmark,true);   
   // init data buff 0
   ArrayInitialize(buffLandmark,0); 
   ArrayInitialize(buffLandmarkdata,0); 
    
//Fractals
   //OnInit_Fractals();

//
#ifdef USE_Tick_bar
   // 元のチャートを背景と同じにする
   SetBarColor(true);
#endif//USE_Tick_bar

//   

// bar count 
make_bar_count =0;
   
///////////
#ifdef aaaaaaaa
Print("aaaaaaaaaaaaaaaaaaaaaa");
#endif

  ///////////////////////////////   
// test 
sz1[1]=1;
Print(sz1[1]);  
test(sz1);
Print(sz1[1]);   
//---
#ifdef Lib_iunima_mtf_ru
    // MA
    OnInit_iunima_mtf_ru(9,5);
#endif// Lib_iunima_mtf_ru


   pre_rates_total = 0;
   flag_new_bar = false;
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+


#ifdef commenttt
	時間[1]が変わった時が、新規足ができたというとき←現在のタイムスケール
	初期から複数足を処理する場合、
		rates_total-1-1までは、配列を移動することに足がかわるということ（10個　８個目まで）
	Tickで足が増えていくとき（
		rates_total-1

	datetime pre_time_1;
	pre_time_1 = 0;

	pre_time_1 = time[1]
#endif // commenttt


int pass;
////---------------------
////------Oncal oncal
////---------------------
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {



// debug candle 2020/08/13
//    out_candle_debug(1515434400,rates_total,prev_calculated,time,open,high,low,close);
//    out_candle_debug(1517994000,rates_total,prev_calculated,time,open,high,low,close);
    
// debug candle 2020/08/13

  global_rates_total=rates_total;
  golobal_prev_calculated = prev_calculated;
  #ifdef USE_debug_during_Period_hanndann
    if(b_during_test_piriod==false){
        if(pre_test_starttime==0){
            pre_test_starttime=time[rates_total-1];
        }else{
            if(prev_calculated!=0 && time[prev_calculated-1]>pre_test_starttime){
                b_during_test_piriod=true;
                Notice_TorihikikikannNai_TMBs();//取引FWオブジェクトに期間内になったことを連絡
                printf("b_during_test_piriod=true  計算がテスト期間内に入った★");
            }
        }
    }
  #endif//USE_debug_during_Period_hanndann

  ArraySetAsSeries(time,true);
  ArraySetAsSeries(close,true);//chg 20201123 
//#ifdef USE_CALC_PASS_kako
if(use_calc_pass_kako == true) { 
    if(rates_total > prev_calculated+use_calc_pass_kako_num){
        return   rates_total -use_calc_pass_kako_num;
    }
}
//#endif //USE_CALC_PASS_kako

//debug IndToEA 
//test_ind_to_ea(rates_total-1);

#ifdef Lib_iunima_mtf_ruZZZZZZZ
    //MA
    int retm;
    retm=OnCalculate_iunima_mtf_ru(rates_total,prev_calculated,time,open,high,low,close,tick_volume,volume,spread);
    if(retm==0){return 0;}
#endif// Lib_iunima_mtf_ru

//    ArraySetAsSeries(time,false);
#ifdef debug20201230
//debug20201230
     bool bnewbar=false;
     bool bnewbar_tick=false;
     bnewbar = isNewBar(_Symbol,PERIOD_CURRENT);
     bnewbar_tick=isNewBar_tick(_Symbol,PERIOD_CURRENT);
   MqlTick tick;
   SymbolInfoTick(_Symbol, tick);
   long ticktime = tick.time_msc;
    bool bcurrent_newbar = false;
#endif//debug20201230

    ///////  
    ///////未処理の足の処理をする
    ///////
    int first_idx = 20;//初データは先の個数以降とする。（一つ前の処理をするためその処理をしないようにするため）
    if(rates_total < first_idx+3){return(0);}// 20個未満は処理せず増えるのを待つ
    int limit;
    //計算が終わってない配列データがある
    if(prev_calculated == 0){// 初めての時は全部を処理
        limit = first_idx;
//    }else if(prev_calculated!=rates_total){limit = prev_calculated-1;}//　未解決の部分から実施　　最後は確定足でないので処理しない
    }else if(prev_calculated!=rates_total){limit = prev_calculated;}//　未解決の部分から実施　　最後は確定足でないので処理しない
    else{// prev_calculated==rates_total 同じ　Tick
        //limit=rates_total-1+1000;
        limit=rates_total;
    }//未処理の確定足なしのためidxは最後とする
//    for(int i = limit;i<rates_total-1;i++){// （time[0]最新、一番古物は rates_total-1）　 
//    for(int i = rates_total-limit;i>=0;i--){// （time[0]最新、一番古物は rates_total-1）　 
//    for(int i = (rates_total)-limit;i>0;i--){// （time[0]最新、一番古物は rates_total-1）　 
    for(int i = (rates_total)-limit;i>=0;i--){// （time[0]最新、一番古物は rates_total-1）　  最新足０が未評価のため含める必要がある
    //繰り返しで判断するM1の配列と参照idxとその前の情報から
        //if(i !=0){ // 初めの開始を２０以降にして初期判断分岐をなくす
         //   ini_new_bar_flag(time[i-1]);
        //}
//        printf(TimeToString(time[0]));
        get_new_bar_flag(time[i]);// 前後の時間を渡し、フラグを設定してもらう。（呼び出し時に初期化する）ex time[i-1]=4:00 ,time[i]=3:59
        //新足作成したか
            //新規足増加
                //データの作成処理：フラクタル、ライン情報、Zigzag情報作成
//        datetime t1=time[i-1],t2=time[i];
        datetime t1=time[i+1],t2=time[i];
        //p_allcandle.calc_new_bar_flag(t1,t2);// 前後の時間を渡し、フラグを設定してもらう。（呼び出し時に初期化する）
        p_allcandle.calc_new_bar_flag(t2);// 前後の時間を渡し、フラグを設定してもらう。（呼び出し時に初期化する）
        //各時間足確定時の処理        
        if(flagchgbarM1){
#ifdef USE_ZIGZAG_M1 
//if(rates_total != prev_calculated && (rates_total-prev_calculated == 1)){
//    flagchgbarM1 = flagchgbarM1;
//    printf(TimeToString(time[0])+"   "+TimeToString(time[1]));
//}
			ENUM_TIMEFRAMES peri=PERIOD_M1;
            //if(Inp_base_time_frame <=  peri){ 
            if(timeframe_hidari_ijou(Inp_base_time_frame,peri)){//現在時間軸足以上の足のみ処理する。　
	            
	            //printf("M1"+TimeToString(time[i]));
	            datetime t = time[i];
	            bool rr = p_allcandle.add_new_bar( peri,t);// ローソク作成
	            //Zigzag作成処理　足確定した分を渡す（ここでは1つ分）　　　　　　　・・・確定、未確定のイメージ
	            int ret3 = p_allcandle.Oncalculate_ZIGZAG(peri);

#ifdef USE_Fractals                
	            int ret4 = p_allcandle.Oncalculate_Fractals(peri);
#endif //USE_Fractals
	            p_allcandle.calc_kakutei(peri);//パターンなどの確定した後に計算するものを実行
#ifdef USE_HYOUKA
                if(peri== Inp_base_time_frame){
    	            m_hyouka.hyouka();
    	        }
#endif//USE_HYOUKA    	        
	            
	            //printf(TimeToString(time[0])+"   "+TimeToString(time[1]));
			}
#endif//USE_ZIGZAG_M1 
                        
        }
        if(flagchgbarM5){
#ifdef USE_ZIGZAG_M5        
			ENUM_TIMEFRAMES peri=PERIOD_M5;
            if(timeframe_hidari_ijou(Inp_base_time_frame,peri)){//現在時間軸足以上の足のみ処理する。　
                datetime t = time[i];
                bool rr = p_allcandle.add_new_bar( peri,t);// ローソク作成
                //Zigzag作成処理　足確定した分を渡す（ここでは1つ分）　　　　　　　・・・確定、未確定のイメージ
                int ret3 = p_allcandle.Oncalculate_ZIGZAG(peri);
#ifdef USE_Fractals                
                int ret4 = p_allcandle.Oncalculate_Fractals(peri);
#endif //USE_Fractals
                p_allcandle.calc_kakutei(peri);//パターンなどの確定した後に計算するものを実行
                //test_ma();//test test test 20220503
#ifdef USE_HYOUKA
                if(peri== Inp_base_time_frame){
    	            m_hyouka.hyouka();
    	        }
#endif//USE_HYOUKA    	        
    	    }
#endif// USE_ZIGZAG_M5
        }
        if(flagchgbarM15){
#ifdef USE_ZIGZAG_M15        
			ENUM_TIMEFRAMES peri=PERIOD_M15;
            if(timeframe_hidari_ijou(Inp_base_time_frame,peri)){//現在時間軸足以上の足のみ処理する。　
#ifdef debug20201230
                //debug20201230
                bcurrent_newbar=true;
                //debug end
#endif//debug20201230

                datetime t = time[i];
                bool rr = p_allcandle.add_new_bar( peri,t);// ローソク作成

#ifdef debug20201230
                printf("M15 add_new_bar:"+TimeToString(t)+"  now time;"+TimeToString(tick.time));//debug20201230
                candle_data *c=p_allcandle.get_candle_data_pointer(peri);
                datetime taddbar=c.get_time(0);
                printf("M15 Close(0)   :"+TimeToString(taddbar)+"  now time;"+TimeToString(tick.time));//debug20201230
#endif//debug20201230
                
                //Zigzag作成処理　足確定した分を渡す（ここでは1つ分）　　　　　　　・・・確定、未確定のイメージ
                int ret3 = p_allcandle.Oncalculate_ZIGZAG(peri);
#ifdef USE_Fractals                
                int ret4 = p_allcandle.Oncalculate_Fractals(peri);
#endif //USE_Fractals                
                                    #ifdef	USE_debug_Lcn_2kaicall
                                        printf(__FUNCTION__+"★M15　pre calc_kakutei");
                                    #endif//USE_debug_Lcn_2kaicall

                p_allcandle.calc_kakutei(peri);//パターンなどの確定した後に計算するものを実行

                                    #ifdef	USE_debug_Lcn_2kaicall
                                        printf(__FUNCTION__+"★M15　after calc_kakutei");
                                    #endif//USE_debug_Lcn_2kaicall
#ifdef debug_CCI_USE
                //debug
                double val_cci=0.0;
                p_allcandle.get_candle_data_pointer(peri).cci_get_value_now(val_cci,t);
                val_cci=val_cci;
#endif //debug_CCI_USE
#ifdef USE_HYOUKA
                if(peri== Inp_base_time_frame){
    	            m_hyouka.hyouka();
    	        }
#endif//USE_HYOUKA    	        
    	    }
#endif// USE_ZIGZAG_M15
        }
        if(flagchgbarM30){
#ifdef USE_ZIGZAG_M30        
			ENUM_TIMEFRAMES peri=PERIOD_M30;
            if(timeframe_hidari_ijou(Inp_base_time_frame,peri)){//現在時間軸足以上の足のみ処理する。　
                datetime t = time[i];
                bool rr = p_allcandle.add_new_bar( peri,t);// ローソク作成
                //Zigzag作成処理　足確定した分を渡す（ここでは1つ分）　　　　　　　・・・確定、未確定のイメージ
                int ret3 = p_allcandle.Oncalculate_ZIGZAG(peri);
#ifdef USE_Fractals                
                int ret4 = p_allcandle.Oncalculate_Fractals(peri);
#endif //USE_Fractals
                p_allcandle.calc_kakutei(peri);//パターンなどの確定した後に計算するものを実行

#ifdef USE_HYOUKA
                if(peri== Inp_base_time_frame){
    	            m_hyouka.hyouka();
    	        }
#endif// USE_HYOUKA

    	    }
#endif// USE_ZIGZAG_M30
        }
        if(flagchgbarH1){
#ifdef USE_ZIGZAG_H1
//            datetime t = time[i];
//            bool rr = p_allcandle.add_new_bar( PERIOD_H1,t);// ローソク作成
//            //Zigzag作成処理　足確定した分を渡す（ここでは1つ分）　　　　　　　・・・確定、未確定のイメージ
//            int ret3 = p_allcandle.Oncalculate_ZIGZAG(PERIOD_H1);
			ENUM_TIMEFRAMES peri=PERIOD_H1;
            if(timeframe_hidari_ijou(Inp_base_time_frame,peri)){//現在時間軸足以上の足のみ処理する。　
                datetime t = time[i];
#ifdef delll
    	        if(t==1515020400){//2018.01.03 23:00
    	            t=t;debug_candle_data( PERIOD_H1);
    	            debug_H1_candle_copyfuffer(1515020400,PERIOD_H1);
    	        }
    	        if(t==1515020400+3600){//2018.01.03 23:00
    	            //t=t;debug_candle_data( PERIOD_H1);
    	            debug_H1_candle_copyfuffer(1515020400+3600,PERIOD_H1);
    	        }    	        
#endif//delll
                bool rr = p_allcandle.add_new_bar( peri,t);// ローソク作成
                //Zigzag作成処理　足確定した分を渡す（ここでは1つ分）　　　　　　　・・・確定、未確定のイメージ
                int ret3 = p_allcandle.Oncalculate_ZIGZAG(peri);
//                int ret4 = p_allcandle.Oncalculate_Fractals(peri);
                p_allcandle.calc_kakutei(peri);//パターンなどの確定した後に計算するものを実行
#ifdef USE_fibo_expansion_H1                
                view_fibo_expansion(1,p_allcandle.get_candle_data_pointer(peri));
#endif// USE_fibo_expansion_H1
#ifdef USE_fibo_H1                
                view_fibo(1,p_allcandle.get_candle_data_pointer(peri));
#endif// USE_fibo_H1

#ifdef USE_HYOUKA
                if(peri== Inp_base_time_frame){
    	            m_hyouka.hyouka();
    	        }
#endif//USE_HYOUKA

    	        
#ifdef delll
    	        //debug 2020/08/13 candle naiyou kakuninn
    	        if(t==1515020400){//2018.01.03 23:00
    	            debug_candle_data( PERIOD_H1);
    	        }
#endif//delll
    	        
    	        
    	    }
#endif// USE_ZIGZAG_H1
            
        }
        if(flagchgbarH4){
#ifdef USE_ZIGZAG_H4
//            datetime t = time[i];
//            bool rr = p_allcandle.add_new_bar( PERIOD_H4,t);// ローソク作成
//            //Zigzag作成処理　足確定した分を渡す（ここでは1つ分）　　　　　　　・・・確定、未確定のイメージ
//            int ret3 = p_allcandle.Oncalculate_ZIGZAG(PERIOD_H4);


//			ENUM_TIMEFRAMES peri=PERIOD_H4;
//            if(timeframe_hidari_ijou(Inp_base_time_frame,peri)){//現在時間軸足以上の足のみ処理する。　
//                datetime t = time[i];
//                bool rr = p_allcandle.add_new_bar( peri,t);// ローソク作成
//                //Zigzag作成処理　足確定した分を渡す（ここでは1つ分）　　　　　　　・・・確定、未確定のイメージ
//                int ret3 = p_allcandle.Oncalculate_ZIGZAG(peri);
////                int ret4 = p_allcandle.Oncalculate_Fractals(peri);
//                p_allcandle.calc_kakutei(peri);//パターンなどの確定した後に計算するものを実行
//                
//		        candle_data *c = p_allcandle.get_candle_data_pointer(PERIOD_H4);
//		        c=p_allcandle.get_candle_data_pointer(PERIOD_H4);
//		        if(c != NULL){
//		            bool pattern_pt_sup=c.Is_pattern_pt_sup();
//		            if(pre_pattern_pt_sup != pattern_pt_sup){
//		                pre_pattern_pt_sup = pattern_pt_sup;
//		            }
//		            pre_pattern_pt_sup = pattern_pt_sup;
//		        }
//                if(peri== Inp_base_time_frame){
//    	            m_hyouka.hyouka();
//    	        }
//    	    }
#endif // USE_ZIGZAG_H4


#ifdef USE_ZIGZAG_H4
//            datetime t = time[i];
//            bool rr = p_allcandle.add_new_bar( PERIOD_D1,t);// ローソク作成
//            //Zigzag作成処理　足確定した分を渡す（ここでは1つ分）　　　　　　　・・・確定、未確定のイメージ
//            int ret3 = p_allcandle.Oncalculate_ZIGZAG(PERIOD_D1);        

			ENUM_TIMEFRAMES peri=PERIOD_H4;
            if(timeframe_hidari_ijou(Inp_base_time_frame,peri)){//現在時間軸足以上の足のみ処理する。　
                datetime t = time[i];
                bool rr = p_allcandle.add_new_bar( peri,t);// ローソク作成
                //Zigzag作成処理　足確定した分を渡す（ここでは1つ分）　　　　　　　・・・確定、未確定のイメージ
                int ret3 = p_allcandle.Oncalculate_ZIGZAG(peri);
                //int ret4 = p_allcandle.Oncalculate_Fractals(peri);
                p_allcandle.calc_kakutei(peri);//パターンなどの確定した後に計算するものを実行
#ifdef USE_fibo_expansion_H4                
                view_fibo_expansion(1,p_allcandle.get_candle_data_pointer(peri));
#endif// USE_fibo_expansion_H4                
#ifdef USE_fibo_H4                
                view_fibo(1,p_allcandle.get_candle_data_pointer(peri));
#endif// USE_fibo_H4                

#ifdef USE_HYOUKA                
                if(peri== Inp_base_time_frame){
    	            m_hyouka.hyouka();
    	        }
#endif//USE_HYOUKA                
    	    }
#endif // USE_ZIGZAG_H4



        }
        if(flagchgbarD1){

#ifdef USE_ZIGZAG_D1
//            datetime t = time[i];
//            bool rr = p_allcandle.add_new_bar( PERIOD_D1,t);// ローソク作成
//            //Zigzag作成処理　足確定した分を渡す（ここでは1つ分）　　　　　　　・・・確定、未確定のイメージ
//            int ret3 = p_allcandle.Oncalculate_ZIGZAG(PERIOD_D1);        

			ENUM_TIMEFRAMES peri=PERIOD_D1;
            if(timeframe_hidari_ijou(Inp_base_time_frame,peri)){//現在時間軸足以上の足のみ処理する。　
                datetime t = time[i];
                bool rr = p_allcandle.add_new_bar( peri,t);// ローソク作成
                //Zigzag作成処理　足確定した分を渡す（ここでは1つ分）　　　　　　　・・・確定、未確定のイメージ
                int ret3 = p_allcandle.Oncalculate_ZIGZAG(peri);
                if(bUSE_view_Fractals_Day==true){
                    int ret4 = p_allcandle.Oncalculate_Fractals(peri);
                }
                p_allcandle.calc_kakutei(peri);//パターンなどの確定した後に計算するものを実行
#ifdef USE_fibo_expansion_D1
                view_fibo_expansion(1,p_allcandle.get_candle_data_pointer(peri));
#endif// USE_fibo_expansion_D1
#ifdef USE_fibo_D1
                view_fibo(1,p_allcandle.get_candle_data_pointer(peri));
#endif// USE_fibo_D1
#ifdef USE_HYOUKA                
                if(peri== Inp_base_time_frame){
    	            m_hyouka.hyouka();
    	        }
#endif//USE_HYOUKA                
    	    }
#endif // USE_ZIGZAG_D1

        }
        if(flagchgbarW1){
           // printf("W1"+TimeToString(time[i]));
        }
        if(flagchgbarMN1){
            //printf("MN"+TimeToString(time[i]));
        }
        //pt
            //test★

                        #ifdef	USE_debug_Lcn_2kaicall
                            printf(__FUNCTION__+"★pre　chk_trade_forTick");
                        #endif//USE_debug_Lcn_2kaicall
        //ma,po
        //足が確定したときのみ、計算
        if(p_allcandle.get_candle_flagchgbar(Inp_base_time_frame)){//　変化フラグが変わったか？
            //candle_data *cc= p_allcandle.get_candle_data_pointer(Inp_base_time_frame);
            candle_data *cc= p_MA_torimatome1.m_c;
            if(cc!=NULL){
                p_MA_torimatome1.add_new_bar_calc(cc.close,cc._CANDLE_BUFFER_MAX_NUM-1,cc.candle_bar_count);
            }
        }


        chk_trade_forTick(close[i],time[i],p_allcandle,true);
                        #ifdef	USE_debug_Lcn_2kaicall
                            printf(__FUNCTION__+"★after　chk_trade_forTick");
                        #endif//USE_debug_Lcn_2kaicall
        Tick_TMBs();                
#ifdef debug_20211101
//printf("chk_trade_forTick"+TimeToString(time[i]));
#endif                         
        
    }    // for
    ///////
    //Tickデータ処理  最新足の処理（エントリーとか、損切とか動的な処理を入れる）
    ///////
        //状態に合わせて処理する。

#ifdef Lib_iunima_mtf_ru
    //MA
    int retm;
//    retm=OnCalculate_iunima_mtf_ru(rates_total,prev_calculated,time,open,high,low,close,tick_volume,volume,spread);
    retm=OnCalculate_iunima_mtf_ru(rates_total,Lib_iunima_mtf_ru_prev_calculated,time,open,high,low,close,tick_volume,volume,spread);
    Lib_iunima_mtf_ru_prev_calculated = retm;
    //if(retm!=rates_total){Lib_iunima_mtf_ru_prev_calculated = 0;}
#endif// Lib_iunima_mtf_ru


//debug 20200603
//chk_zigzag_debug();//debug 20200603//debug 20210105
//debug 20200603
//ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー


//ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
#ifdef commenttt
rates_total　まで計算されていない時の処理が必要
時間が飛ぶとき→現在の最新と前に計算した間を順次実施する。
        早朝にいったん止まるとき
        Weekendと開始
        →一つ一つ処理をする。新足が立つ状況になったら、その時間足の処理をする方針

        まとめて処理する部分（rates_totalと前回計算しているところが異なっているとき）
        最新Tickが来ているときの処理は作成済み
        
        prev_calculated からrates_totalの間を一つずつ処理する
        現在の最新足のTickが来たときは　上記はおなじか？
        ↓↓↓↓↓
        同じときはTick処理：足確立判断はしない。
        違うときは配列のインディックスの時間を使用して、足確立判断する
        
        足増えたら、データ作成処理に回す
        
        そのあとTick処理で各ステイタスに合わせて処理する。
        
#endif//commenttt

#ifdef USE_Tick_bar
   double price_tick;
#endif// USE_Tick_bar   
   int get_ticks=0;
   
   flag_new_bar = false;
   if( pre_rates_total != rates_total){
      flag_new_bar = true;
   }
//   if(Tick_bar_NUM == 188){
//      Tick_bar_NUM = 188;
//   }
   pre_rates_total =rates_total; 
   //新しい足ができたとき
   // refresh Tick 描画データ
   //右にひとつずらず
#ifdef USE_Tick_bar
   if( flag_new_bar == true){
      Move_object_Fractal();
   }
#endif//USE_Tick_bar
//---


#ifdef USE_Tick_bar

   if(ticks==0) // 初期状態のとき
   {
      ArrayInitialize(buffer_low,0);
      ArrayInitialize(buffer_high,0);
      ArrayInitialize(buffer_open,0);
      ArrayInitialize(buffer_close,0);
      ArrayInitialize(buffer_low_tick,0);
      ArrayInitialize(buffer_high_tick,0);
      ArrayInitialize(buffer_open_tick,0);
      ArrayInitialize(buffer_close_tick,0); 
      ArrayInitialize(buffer_color_line,0); 
#ifdef buffer_MAX
   
      //　過去のデータを取り込み
        int     attempts=0;     // Count of attempts 
        bool    success=false; // The flag of a successful copying of ticks 
        MqlTick tick_array[];   // Tick receiving array 
        MqlTick lasttick;       // To receive last tick data 
        SymbolInfoTick(_Symbol,lasttick);       
      
      //--- Make 3 attempts to receive ticks 
        while(attempts<1) 
          { 
          //--- Measuring start time before receiving the ticks 
          uint start=GetTickCount(); 
      //--- Requesting the tick history since 1970.01.01 00:00.001 (parameter from=1 ms) 
          int received=CopyTicks(_Symbol,tick_array,COPY_TICKS_ALL,0,getticks); 
          get_ticks=ArraySize(tick_array); 
          if(get_ticks ==0){ 
          received=-1;
          }
          if(received!=-1) 
             { 
              //--- Showing information about the number of ticks and spent time 
              PrintFormat("%s: received %d ticks in %d ms",_Symbol,received,GetTickCount()-start); 
              //--- If the tick history is synchronized, the error code is equal to zero 
              if(GetLastError()==0) 
                { 
                 success=true; 
                break; 
                } 
              else 
                PrintFormat("%s: Ticks are not synchronized yet, %d ticks received for %d ms. Error=%d", 
                _Symbol,received,GetTickCount()-start,_LastError); 
             } 
          //--- Counting attempts 
           attempts++; 
          //--- A one-second pause to wait for the end of synchronization of the tick database 
//          Sleep(1000);   //debug del 
//          Sleep(1000); 
          } 
      //--- Receiving the requested ticks from the beginning of the tick history failed in three attempts 
        if(!success) 
          { 
          PrintFormat("Error! Failed to receive %d ticks of %s in three attempts",getticks,_Symbol); 
          //return; 
          Print("error get tick");
          } 

        
      //tickデータ反映　　順番はどっちかわからん。
//      for(int j=0;  j< get_ticks ; j++){
      for(int j=0;  j< get_ticks ; j++){
         // 元データ作成
//         price_tick=tick_array[get_ticks-1-j].bid; // 一番最後が最新
//         price_tick=tick_array[j].bid; // 一番最後が古い
         price_tick=chg_value_tick(tick_array[j].bid); // 一番最後が古い

         //　更新　　　　　　　　現在値、確定からのTick数、　1バーの最大ティック数
         tick_bar_update(price_tick,n_tickcount, max_n);
         //EMA data update  // for tick data 
         EMA_calc( buffer_close_tick,EMA_n,buffEMAdata);
                         
         if( ticks==0)      ticks++;
      }// for old tick data make
  
  ///////////////////////////////
#endif//buffer_MAX // データ読み込み　　

      
           
   }// if(ticks==0)
#endif//USE_Tick_bar
   //debug del iwa     setMaxMinPrice(ticks,points_indent);
//------------------------------------------
//------------- Tick bar 処理
//------------------------------------------
#ifdef USE_Tick_bar
   MqlTick last_tick;
   if(SymbolInfoTick(Symbol(),last_tick))
     {
//     price_tick = (last_tick.bid+last_tick.ask)/2.0;
//     price_tick = last_tick.bid;
     price_tick = chg_value_tick(last_tick.bid);
     
     tick_bar_update(price_tick,n_tickcount, max_n); 

     
      if( ticks>=0 && (ticks < buffer_MAX-1)){      ticks++;}
      
		#ifdef aaaaa     
		      BidBuffer[ticks]=last_tick.bid;
		      AskBuffer[ticks]=last_tick.ask;
		      int shift=rates_total-1-ticks;
		      ticks++;
		      BidBuffer[rates_total-1]=last_tick.bid;
		      AskBuffer[rates_total-1]=last_tick.ask;
		//      PlotIndexSetInteger(0,PLOT_SHIFT,shift);
		//      PlotIndexSetInteger(1,PLOT_SHIFT,shift);
		      Comment("Bid =",last_tick.bid,"   Ask =",last_tick.ask);
		#endif
     }
   for(int i = 0; i< buffer_MAX-1;i++){
      if( buffer_open_tick[i] == 0.0){
      //   PlotIndexSetDouble(index_of_plot_DRAW_COLOR_CANDLES,PLOT_EMPTY_VALUE,0);
      }else{   
         buffer_color_line[i]=getPlotColor_candle(buffer_open_tick[i],buffer_close_tick[i]);
      }
   }
   //EMA data re
   EMA_calc( buffer_close_tick,EMA_n,buffEMAdata);
   // データを描画データに反映させる
   EMA_show_data_reflash(buffEMAdata,buffEMA,buffer_MAX,EMA_n);

   //　
   buffLandmark[1] = buffer_close[1]+LandMarkW*Point()*10;
   buffLandmark[2] = 0;

   //SetBarColor(true);
#endif//USE_Tick_bar
//------------------------------------------
//------------- Tick bar 処理　End
//------------------------------------------

//test★
//chk_trade_forTick(close[0],time[0],p_allcandle,true);

//after tick
#ifdef USE_IND_TO_EA_FOR_OPTIMUM_TESTER
set_Ind_to_EA_para(buffEMA);
#endif//USE_IND_TO_EA_FOR_OPTIMUM_TESTER
send_ctr_tick_exe();//Ind側送信データについて、送信可能になったら送付する
//--- return value of prev_calculated for next call
   return(rates_total);
}// end Oncalculate









//+------------------------------------------------------------------+
//| set Maximum and Minimum for an indicator window based on last values
//+------------------------------------------------------------------+
void setMaxMinPrice(int last_values,int indent)
  {
   int visiblebars=(int)ChartGetInteger(0,CHART_VISIBLE_BARS);
   int depth=MathMin(last_values,visiblebars);
   int startindex=last_values-depth;
   int max_index=ArrayMaximum(buffer_high_tick,startindex,depth);
   max_index=max_index>=0?max_index:0;
   int min_index=ArrayMinimum(buffer_low_tick,startindex,depth);
   min_index=min_index>=0?min_index:0;
   double MaxPrice=buffer_high_tick[max_index]+indent*_Point;
   double MinPrice=buffer_low_tick[min_index]-indent*_Point;
   IndicatorSetDouble(INDICATOR_MAXIMUM,MaxPrice);
   IndicatorSetDouble(INDICATOR_MINIMUM,MinPrice);
  }
//+------------------------------------------------------------------+
int getPlotColor_candle(double open,double close)
  {
   if( open<close ){
      return(0);
   }else{
      return(1);
   }
   
  }
  
void setPlotColor(int plot)
  {
   PlotIndexSetInteger(plot,PLOT_COLOR_INDEXES,50); //Specify the number of colors

                                                    //In the loops we specify the colors
   for(int i=0;i<=24;i++)
     {
      PlotIndexSetInteger(plot,PLOT_LINE_COLOR,i,StringToColor("\"0,175,"+IntegerToString(i*7)+"\""));
     }
   for(int i=0;i<=24;i++)
     {
      PlotIndexSetInteger(plot,PLOT_LINE_COLOR,i+25,StringToColor("\"0,"+IntegerToString(175-i*7)+",175\""));
     }
  }
void setPlotColor_candle(int plot)
  {
   PlotIndexSetInteger(plot,PLOT_COLOR_INDEXES,2); //Specify the number of colors

                                                    //In the loops we specify the colors
 
      PlotIndexSetInteger(plot,PLOT_LINE_COLOR,0,clrGreen );
      PlotIndexSetInteger(plot,PLOT_LINE_COLOR,1,clrRed);
   }
   
   

// EMA calc
// buffEMA[0] ０から最新の時系列データ
// buffEMA[0] 現在（結果格納）
// 更新タイミング　現在値変わったとき
// 特記事項：　ティックデータがずれた後で、EMAのバッファもシフトすること。
// 初回判断
//EMA_calc( buffer_close_tick,EMA_n,buffEMA);


void EMA_calc( double &  buff_data[],int nn,double & bufEMA[])
{

	double result = 0.0;
	if( flag_EMA_init == false){
		// 1日目
		double tmp=0.0;
		for(int m=nn-1; m >=0;m--){
			tmp = tmp + buff_data[m];
		}

		result = tmp / nn;
	}
	else{
		//　二日目以降
		//result = bufEMA[1]+2/(nn+1)*(buff_data[0] - bufEMA[1]);
		result = bufEMA[1]*(nn+1-2 )/(nn+1) + buff_data[0]*2/(nn+1);
	}

	//結果格納
   bufEMA[0]=result;
//	buffEMA[0] = result;
}

// shift データ確定し、一つ移動
//EMA_shift(buffEMA,buffer_MAX);

void EMA_shift(double & buf[],int bufMAX, int nnn){
     // もとデータのシフト
     int endofcopy = 2;
     if( make_bar_count > nnn+1 ) endofcopy = bufMAX-1;
     for(int i = endofcopy; i>0;i--){
        buf[i]=buf[i-1];

        //Print(i,":",buf[i]);
     }	

      
}  

void   EMA_show_data_reflash(double &bufdata[],double & buf[],int bufMAX,int nnn){

  if( make_bar_count <= nnn){ return;}

  int  s2 = ArraySize( 
  bufdata   // チェックされた配列 
  );
   int  s = ArraySize( 
  buf   // チェックされた配列 
  );
     if( bufMAX > s){ bufMAX = s;}
     int copynum = bufMAX;
     copynum = copynum-nnn;
     for(int i = 0; copynum > i;i++){
        buffEMA[i]=buffEMAdata[i];

        //Print(i,":",buf[i]);
     }	
}

void add_make_bar_count(){
   if( make_bar_count< buffer_MAX){
       make_bar_count++;
   }
   Tick_bar_NUM++; 
}

void test( int & sz2[] ){
   sz2[1]++;
   
}

double chg_value_tick(double inp){
   double result=inp;
   if(tick_view_type != 0){
      result = NormalizeDouble(inp,tick_view_type);//
   }
   return result;
}


void set_view_tickdata(){
        // インジケータバッファの更新
        for(int i = buffer_MAX-1; i>=0;i--){
           buffer_high[i]=buffer_high_tick[i];
           buffer_low[i]=buffer_low_tick[i];
           buffer_open[i]=buffer_open_tick[i];
           buffer_close[i]=buffer_close_tick[i];
        }              
        //for(int i = buffer_MAX-1; i>=0;i--){
        //   buffer_high[i]=chg_value_tick(buffer_high_tick[i]);
        //   buffer_low[i]=chg_value_tick(buffer_low_tick[i]);
        //   buffer_open[i]=chg_value_tick(buffer_open_tick[i]);
        //   buffer_close[i]=chg_value_tick(buffer_close_tick[i]);
        //}
}




#ifdef dell_tick_fractal
//　tick_bar_update(price_tick,n_tickcount, max_n)
void tick_bar_update(double price_tick,int &nn, int max_nn)
{
      int pre_Tick_bar_NUM = Tick_bar_NUM;
     // n_tickcount=0
     if ( nn==0){
        buffer_low_tick[0]=price_tick;
        buffer_high_tick[0]=price_tick;
        buffer_low_tick[0]=price_tick;
        buffer_open_tick[0]=price_tick;
        buffer_close_tick[0]=price_tick;
     }
     //n_tickcount:1kara n_tickcount-1
     if(nn>0 && (max_nn-1> nn)){
        buffer_high_tick[0]=buffer_high_tick[0]>price_tick? buffer_high_tick[0]:price_tick;
        buffer_low_tick[0]=buffer_low_tick[0]<price_tick? buffer_low_tick[0]:price_tick;
        //buffer_open_tick[0]=
        buffer_close_tick[0]=price_tick;
     }
     //n_tickcount=n_tickcount  n_tickcount=0
      //copy
      if(nn==max_nn-1){
      
        // バーが増加した
        add_make_bar_count();

        // もとデータのシフト
        for(int i = buffer_MAX-1; i>0;i--){        
           buffer_high_tick[i]=buffer_high_tick[i-1];
           buffer_low_tick[i]=buffer_low_tick[i-1];
           buffer_open_tick[i]=buffer_open_tick[i-1];
           buffer_close_tick[i]=buffer_close_tick[i-1];
        }
           // 現在値
           buffer_high_tick[0]=price_tick;
           buffer_low_tick[0]=price_tick;
           buffer_open_tick[0]=price_tick;
           buffer_close_tick[0]=price_tick;
     
        // インジケータバッファの更新
        //for(int i = buffer_MAX-1; i>=0;i--){
        //   buffer_high[i]=buffer_high_tick[i];
       ////    buffer_low[i]=buffer_low_tick[i];
       //    buffer_open[i]=buffer_open_tick[i];
       //    buffer_close[i]=buffer_close_tick[i];


       // }
           // 今を表示
           //buffer_high[0]=buffer_high_tick[0];
           //buffer_low[0]=buffer_low_tick[0];
           //buffer_open[0]=buffer_open_tick[0];
           //buffer_close[0]=buffer_close_tick[0];

            // EMA data shift データ確定し、一つ移動
//            EMA_shift(buffEMA,buffer_MAX);
            EMA_shift(buffEMAdata,buffer_MAX,EMA_n);
            

        
      }
     if(nn<max_nn-1){ nn++;}else{nn=0;}
     
      //init
     if ( nn==0){
        buffer_high_tick[0]=price_tick;
        buffer_low_tick[0]=price_tick;
        buffer_open_tick[0]=price_tick;
        buffer_close_tick[0]=price_tick;

     }
     if(pre_Tick_bar_NUM != Tick_bar_NUM){
     // Tickバー増加　処理
         //オブジェクト移動処理
         Move_object_Tick_Fractal();
     //Tick_bar_NUM
         // Fractals 計算
         datetime Time[400];
         datetime  cc = TimeCurrent();
         for(int j = 0; j<400; j++){
            Time[(400-1)-j]= chgidxToTime(j,400) ;
         }
         
               OnCalculate_Fractals(
                Tick_bar_NUM,    // amount of history in bars at the current tick
                Tick_bar_NUM-1,// amount of history in bars at the previous tick
                Time,
                buffer_open_tick,
                buffer_high_tick,
                buffer_low_tick,
                buffer_close_tick
//                Tick_Volume[],
//                Volume[],
//                Spread[]
                );
         //SameLine_data
               OnCalculate_Sameline(
                Tick_bar_NUM,    // amount of history in bars at the current tick
                Tick_bar_NUM-1,// amount of history in bars at the previous tick
                Time,
                buffer_open_tick,
                buffer_high_tick,
                buffer_low_tick,
                buffer_close_tick
//                Tick_Volume[],
//                Volume[],
//                Spread[]
                );         //              
     
     }
     // 今を表示
        // インジケータバッファの更新
         set_view_tickdata();
        //for(int i = buffer_MAX-1; i>=0;i--){
        //   buffer_high[i]=buffer_high_tick[i];
        //   buffer_low[i]=buffer_low_tick[i];
        //   buffer_open[i]=buffer_open_tick[i];
        //   buffer_close[i]=buffer_close_tick[i];
        //}
        
        set_view_sameline(Tick_bar_NUM);// 最後のidxに関連するもののみ表示する。
      
}

void SetBarColor(bool s){

ChartSetInteger(0,	CHART_COLOR_CHART_UP	,clrBlack);
ChartSetInteger(0,	CHART_COLOR_CHART_DOWN	,clrBlack);
ChartSetInteger(0,	CHART_COLOR_CHART_LINE	,clrBlack);
ChartSetInteger(0,	CHART_COLOR_CANDLE_BULL	,clrBlack);

}

void Move_object_Tick_Fractal(){
   Move_object_Fractal();
}
#endif//dell_tick_fractal

void get_new_bar_flag(datetime t){ // 前後の足から各時間軸でNewBarができたか確認する
//ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
//新規足有無の確認
//ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
    //datetime pre_timeM1;
    MqlDateTime pre_dt_struct;
    MqlDateTime dt_struct;
    
    flagchgbarM1=false;flagchgbarM5=false;flagchgbarM15=false;flagchgbarM30=false;flagchgbarH1=false;flagchgbarH4=false;flagchgbarD1=false;flagchgbarW1=false;flagchgbarMN1=false;
    if(pre_timeM1==0){//初回のみ前回地を覚える
        pre_timeM1=t;
        return;
    }

    TimeToStruct(t,dt_struct);
    TimeToStruct(pre_timeM1,pre_dt_struct);
	if(pre_timeM1 !=t){
	    flagchgbarM1=true;
	}
    
    if(((int)pre_dt_struct.min/5) != ((int)dt_struct.min/5)){
    	//M5
    	flagchgbarM5=true;
    	if(((int)pre_dt_struct.min/15) != ((int)dt_struct.min/15)){
    		//M15
    		flagchgbarM15=true;
    		if(((int)pre_dt_struct.min/30) != ((int)dt_struct.min/30)){
    			//M30
    			flagchgbarM30=true;
    		}
    	}
    }
    if(pre_dt_struct.hour != dt_struct.hour){
    	//1h 以上変化
    			flagchgbarH1=true;
    
    	if( ((int)pre_dt_struct.hour/4) != ((int)dt_struct.hour/4)){
    	// 4h 以上変化
    		//0,4,8,12,16,20,24,0,
    		//0123,4567,891011,12131415,16171819,20212223,0123
    	//waru4 0    1   2       3        4        5       0	
    				flagchgbarH4=true;
    	}
    
    }
    if(pre_dt_struct.day!=	dt_struct.day){
    	//1Day 以上変化
    			flagchgbarD1=true;
    }
    if(pre_dt_struct.mon != dt_struct.mon){
    	//1月 以上変化
    			flagchgbarMN1=true;
    }
    if(pre_dt_struct.day_of_week != dt_struct.day_of_week){
    	//1W 以上変化
    			flagchgbarW1=true;
    }
    
    //前回値の保持
    pre_timeM1 = t;
    
    return;    
    
}

void Deinit_XXX_objdelete()
  {
//----
   int total;
   string name,sirname;

   total=ObjectsTotal(0,0,-1)-1;

   for(int numb=total; numb>=0 ; numb--)
     {
      name=ObjectName(0,numb,0,-1);
      sirname=StringSubstr(name,0,StringLen("@zig"));

      if(sirname=="@zig") ObjectDelete(0,name);
     }
    
    printf("call Deinit_XXX_objdelete zig");
//----
   ChartRedraw(0);
  }
  
  
bool timeframe_hidari_ijou(ENUM_TIMEFRAMES left,ENUM_TIMEFRAMES right){//       H1,notoki　H1 H4などがTrue
    int l,r;
    bool ret=false;
    l=get_timeframe_value(left);
    r=get_timeframe_value(right);
    if(l!=-1 && r!=-1){
        ret=(l<=r);
    }
    return ret;
}
int get_timeframe_value(ENUM_TIMEFRAMES s){ //見つからない場合はー１
	ENUM_TIMEFRAMES period_hairetu_[]={PERIOD_M1,PERIOD_M5,PERIOD_M15,PERIOD_M30,PERIOD_H1,PERIOD_H4,PERIOD_D1,PERIOD_W1,PERIOD_MN1};
	//int taiou_junni[]=				{1,2,3,4,5,6,7,8,9,10,11,12}
	bool find_idx=-1;
	for(int i = 0;i<ArraySize(period_hairetu_);i++){
		if(period_hairetu_[i]== s){
		    find_idx = i;
		    break;
		}
	}
	return find_idx;
}

int handle_zigzag;
void init_zigzag_debug(void){
//    handle_zigzag = iCustom(Symbol(),Period(),"examples\\zigzag");//debug 20210105
    handle_zigzag = iCustom(Symbol(),Period(),"examples\\zigzagColor");//debug 20210105

}
#define aaa 200
double bufferzigzag_top[aaa];
double bufferzigzag_low[aaa];
datetime bufferzigzag_time[aaa];
bool ontick_zigzag_debug(void){
    int n=199;
    int ret=0;
    bool ret_out=false;
       if(CopyBuffer(handle_zigzag ,0,0,n,bufferzigzag_top ) < n ) ret=1;  // buffer[0]古い  [1]最新
//       if(CopyBuffer(handle_zigzag ,2,0,n,bufferzigzag_low ) < n ) ret=ret+10;  // buffer[0]古い  [1]最新
       if(CopyBuffer(handle_zigzag ,1,0,n,bufferzigzag_low ) < n ) ret=ret+10;  // buffer[0]古い  [1]最新
    //   bool fffbufferzigzag_low = ArrayGetAsSeries(bufferzigzag_low);
    
       if(CopyTime(_Symbol,_Period,0,n,bufferzigzag_time ) < n ) ret=ret+100;  // buffer[0]古い  [1]最新
    
        if(ret>0){
            printf("error get zigzag "+IntegerToString(ret));
        }else{
            ret_out=true;
        }
        return ret_out;
}
int pre_zigaag_count;
#ifdef debug20210112
void chk_zigzag_debug_handle_zigzagdata(void){
    #define NUM_OF_A 10
	double a_v[NUM_OF_A+1];
	int a_num_max=0;
	datetime a_t[NUM_OF_A+1];
	int a_dir[NUM_OF_A+1];
	double b_v[NUM_OF_A+1];
	int b_num_max=0;
	datetime b_t[NUM_OF_A+1];
	int b_dir[NUM_OF_A+1];
	int idxa=999;
	int idxb=999;

    candle_data *c =  p_allcandle.get_candle_data_pointer(PERIOD_M15);
    if(c == NULL|| c.zigzagdata_count<20){//} || pre_zigaag_count != c.zigzagdata_count){
        return;
    }
     
     //handledata取得 a
	bool ret =false;
	int bbbb_num_max = 199;
	double ttmp_v[NUM_OF_A+1];
	int ttmp_num_max=0;
	datetime ttmp_t[NUM_OF_A+1];
	int ttmp_dir[NUM_OF_A+1];
   int b_key_idx=0;
	// tmp_* [0] 古いものが入っている。
    bool r_ontick_zigzag_debug = false;
//    r_ontick_zigzag_debug=ontick_zigzag_debug();//199個
    {
        datetime tt=c.time[299];
        int n=199;
        int ret=0;
        bool ret_out=false;
       if(CopyBuffer(handle_zigzag ,0,tt,n,bufferzigzag_top ) < n ) ret=1;  // buffer[0]古い  [1]最新
       if(CopyBuffer(handle_zigzag ,1,tt,n,bufferzigzag_low ) < n ) ret=ret+10;  // buffer[0]古い  [1]最新
    //   bool fffbufferzigzag_low = ArrayGetAsSeries(bufferzigzag_low);
    
       if(CopyTime(_Symbol,_Period,tt,n,bufferzigzag_time ) < n ) ret=ret+100;  // buffer[0]古い  [1]最新
    
        if(ret>0){
            printf("error get zigzag "+IntegerToString(ret));
        }else{
            r_ontick_zigzag_debug=true;
        }        
    }
    if(r_ontick_zigzag_debug==false){return;}
	for(int b=bbbb_num_max-1 ;b>=0 ;b--){ //最新足から検索していく
		if(bufferzigzag_top[b]!=0.0){
			ttmp_v[ttmp_num_max]=bufferzigzag_top[b];
			ttmp_t[ttmp_num_max]=bufferzigzag_time[b];
			ttmp_dir[ttmp_num_max]=1;			
			ttmp_num_max++;
		}else if(bufferzigzag_low[b]!=0.0){
			ttmp_v[ttmp_num_max]=bufferzigzag_low[b];
			ttmp_t[ttmp_num_max]=bufferzigzag_time[b];
			ttmp_dir[ttmp_num_max]=-1;			
			ttmp_num_max++;
		}
		if(bufferzigzag_top[b]!=0.0 && (bufferzigzag_low[b]!=0.0)){
			printf("ありえない peakAndBottom !=0.0: "+IntegerToString(c.zigzagdata_count));
		}
		if(ttmp_num_max >NUM_OF_A){
			break;
		}
	}

	if(ttmp_num_max >=1){
		for(int a=0;a<ttmp_num_max;a++){
			int i=ttmp_num_max-1-a;
			a_v[a]=ttmp_v[i];
			a_t[a]=ttmp_t[i];
			a_dir[a]=ttmp_dir[i];
		}
		for(int a=ttmp_num_max;a<NUM_OF_A+1;a++){
			a_v[a]=0.0;
			a_t[a]=0.0;
			a_dir[a]=0.0;
		}
	   a_num_max = ttmp_num_max;	
	   ret = true;
	}

    //Zigzagdata取得
    for(int a=0;a<NUM_OF_A+1;a++){
        int i=(NUM_OF_A)-a+1;//ttmp_num_max-1-a;
        b_v[a]=c.ZigY(i);
        b_t[a]=c.Zigtime(i);
        b_dir[a]=c.ZigUD(i);
    }
    b_num_max =     NUM_OF_A+1;
    //比較
			bool ret_findkey=false;// keyが見つかったか？
         //同一キーの検索　b_key_idx(b),idxa 検索開始位置idx　配列要素なし・同一なしの時は０
			for(int b=0;b<=b_num_max-1;b++){
                b_key_idx = b;
				for(int a=0;a<=NUM_OF_A&& a<a_num_max;a++){
//					if(b_t[b_key_idx]==a_t[a]&& b_v[b_key_idx] == a_v[a]&& b_dir[b_key_idx] == a_dir[a]){
					if(b_t[b_key_idx]==a_t[a]&& b_v[b_key_idx] == a_v[a]&& b_dir[b_key_idx] == a_dir[a] && b_t[b_key_idx]!=0){
						ret_findkey=true;
						idxa=a;// b[5](※1）と同じ要素のあるaのidx　　※1：検索したキー
						break;
					}
				}
				if(ret_findkey==true){break;}
			}
			bool badd_youso=false;
			if(ret_findkey==false){
//				if(a_num_max!=0&&b_num_max!=0){
//					//追加処理へ
//					badd_youso=true;
					idxa=0;
//					idxb=0;
					b_key_idx=0;
//				}else if(){  2つが異なるときの想定がなかった。　同じように処理する必要がある。　add以外にchg　Delもあるはず。　普通の流れに流した方が良かった。badd_yousoは使わない。idxa,b、key_idxを０にすればよい
				      
				
//				}
				printf("key が見つからない");//
			}

			//同じ内容から初めの異なるｉｄｘの決定　　B:idxb　A:idxa_notstart決定　　a,bから順に違うところを見つける。
			bool notflag=false;// a,bで順にみて行って異なるものがあったか？あったtrue
			int idxa_notstart=0;//　異なるものがある若い方からのidx
			idxb=0;
			int max_ab_num_max=MathMax(a_num_max,b_num_max);	
			//　異なる値となるa,bのidxを求める　　（idxa_notstart,idxb）
//			if(ret_findkey==true || badd_youso==true){//keyが見つかったか？or　キー見つからない＆追加処理（aが０この時＆ｂがあるとき）
			if(ret_findkey==true ){//keyが見つかったか？
//				for(int i=idxa;i<=NUM_OF_A;i++){//　ｂとaの同じ要素である　aのidxaから異なるidx　を探す
				for(int ii=idxa;ii<=max_ab_num_max-1;ii++){//　ｂとaの同じ要素である　aのidxaから異なるidx　を探す
//				for(int i=idxa;i<=a_num_max-1;i++){//　ｂとaの同じ要素である　aのidxaから異なるidx　を探す
//					if(i-idxa+b_key_idx>NUM_OF_A){// bの上限超えたか？　超えた場合、ｂが短いので　エリア外のNUM_OF_A＋１＝１４が入る
					if(ii-idxa+b_key_idx>b_num_max-1){// bの上限超えたか？　超えた場合、ｂが短いので　エリア外のNUM_OF_A＋１＝１４が入る
								notflag=true;
							idxb=ii-idxa+b_key_idx;//i-idxa+1;//検査したつぎのidxを設定　
							idxa_notstart=ii;//ｂが短いと話短いとわかって、次のidx
						break;
					}
					if(b_t[ii-idxa+b_key_idx]==a_t[ii] && b_v[ii-idxa+b_key_idx]==a_v[ii]){
						if(b_dir[ii-idxa+b_key_idx]==a_dir[ii]){
							//次を確認する
						}else{
							notflag=true;
							idxb=ii-idxa+b_key_idx;//異なったidxを保持
							idxa_notstart=ii;//異なったidxを保持
							break;
						}
					}else{
						notflag = true;
						idxb=ii-idxa+b_key_idx;//ｂのidx　aと異なるはじめのidx　//異なったidxを保持
						idxa_notstart=ii;//異なったidxを保持
						break;
					}
//						if(i>=NUM_OF_A){// aの上限超えたか？　　　ｂの対応するaがない。状態
					if(ii>=a_num_max-1){// aの上限超えたか？　　　ｂの対応するaがない。状態
						idxb=ii-idxa+b_key_idx+1;//i-idxa+1; 今見ているところの次をさすようにする
//						idxa_notstart=ii+1;//a超過なので、領域外とする。
						idxa_notstart=ii+1;//a超過なので、領域外とする。
						notflag =true;
//							if(idxb <=NUM_OF_A ){
						if(idxb <=b_num_max-1 ){
						#ifdef debug20210112
						printf("add ");
						#endif //debug20210112
						}
						break;
					}

				}
			}//end 異なる値となるa,bのidxを求める　　（idxa_notstart,idxb）
    //結果出力

			if(max_ab_num_max>0){// a,b要素あれば
				//異なった部分を出力　						//a,bで違うところから順に対応するものを表示させる
				bool isout_not=false;
                if(true){
					for(int ii = 0;ii<=max_ab_num_max-1;ii++){//両方のバッファの数を最大に回す
						if(ii+idxa_notstart >NUM_OF_A && ii+idxb>NUM_OF_A){//両方のサイズを超えたらbreak　いらないかも・・・
							break;
						}
						//A
						if(ii+idxa_notstart <=a_num_max-1){
							printf("正A["+IntegerToString(ii+idxa_notstart)+"]\t"+
								TimeToString(a_t[ii+idxa_notstart])+"\t"+
								DoubleToString(a_v[ii+idxa_notstart],6)+"\t"+
								IntegerToString(a_dir[ii+idxa_notstart])
							);
							isout_not=true;
						}else{
							printf("正A["+IntegerToString(ii+idxa_notstart)+"]\t"
							);
							
						}

						//B
						if(ii+idxb <=b_num_max-1){
							printf("作B["+IntegerToString(ii+idxb)+"]\t"+
								TimeToString(b_t[ii+idxb])+"\t"+
								DoubleToString(b_v[ii+idxb],6)+"\t"+
								IntegerToString(b_dir[ii+idxb])
							);
							isout_not=true;
						}else{
							printf("作B["+IntegerToString(ii+idxb)+"]\t"
							);
							
						}
					}
					if(isout_not == true){
						printf("#####★★右から異なる番目"+"a:="+IntegerToString(a_num_max-1-idxa_notstart)+"b:="+IntegerToString(b_num_max-1-idxb));
					}else{
						//異なるものがない場合　まったく同じ結果の場合
						isout_not=isout_not;
					}
				}
            }
    
}
#endif//debug20210112
void chk_zigzag_debug(void){
#ifdef delllll
    //allcandle *p_allcandle;
    
    candle_data *c =  p_allcandle.get_candle_data_pointer(PERIOD_M15);
    if(c != NULL&& c.zigzagdata_count>10&& pre_zigaag_count != c.zigzagdata_count){
        ontick_zigzag_debug();
    	double x1=c.ZigX(1);
    	double  x2=c.ZigX(2);
    	double  x3=c.ZigX(3);
    	double  x4=c.ZigX(4);
    	double  x5=c.ZigX(5);
    	double  x6=c.ZigX(6);
    	double  x7=c.ZigX(7);
    	double  y1=c.ZigY(1);
    	double  y2=c.ZigY(2);
    	double  y3=c.ZigY(3);
    	double  y4=c.ZigY(4);
    	double  y5=c.ZigY(5);
    	double  y6=c.ZigY(6);
    	double  y7=c.ZigY(7);  
    	
    	
    	double ud1 = c.ZigUD(1);      
    	double ud2 = c.ZigUD(2);      
    	double ud3 = c.ZigUD(3);      
    	double ud4 = c.ZigUD(4);      
    	double ud5 = c.ZigUD(5);      
    	double ud6 = c.ZigUD(6);      
    	double ud7 = c.ZigUD(7);      
    
        double zu[10];
        double zd[10];
        double zud[10];
        datetime zt[10];
        int count=0;
        int first_ud=0;//up1 or -1 dn
        int n=140;
        for(int i = n-1 ; i>= 0;i--){
            if(bufferzigzag_top[i]!=0.0){
                if(first_ud == 0){first_ud = 1;}
                zud[count]=bufferzigzag_top[i];
                zt[count] = bufferzigzag_time[i];
                count++;
            }
#ifdef aaaaa            
            if(bufferzigzag_low[i]!=0.0){
                if(first_ud == 0){first_ud = 1;}
                zud[count]=bufferzigzag_low[i];
                 zt[count] = bufferzigzag_time[i];
               count++;
            }
#endif // aaaaaa            
            if(count >7){
                break;
            }
            
        }
        double x[10];
        datetime t[10];
        printf("##########");
        for(int i=0;i<7;i++){
        
            x[i] = c.ZigY(i+1);
            t[i] = c.Zigtime(i+1);
            if(zud[i]!=x[i]){
                printf("error diff x"+i+ "zigorg"+DoubleToString(zud[i]) + "zig="+ DoubleToString(x[i])
                +  " zig count"+c.zigzagdata_count+" "+TimeToString(t[i])+" "+TimeToString(zt[i]));
                
                
            }
            string sssss=" =";
            if(zud[i]!=x[i]){
               sssss="!=";
            }

            printf("["+IntegerToString(i)+"]"+"ZigY="+DoubleToString(c.ZigY(i+1))+"."+sssss+"."+ DoubleToString( zud[i])+TimeToString(c.ZigX(i+1))+":"+TimeToString(zt[i]));
        }
        {int i=1;
            if(c.zigzagdata_count==361){
               x[i] =x[i];
            }
            if(c.zigzagdata_count==362){
               x[i] =x[i];
            }
            if(c.zigzagdata_count==363){
               x[i] =x[i];
            }
            if(c.zigzagdata_count==364){
               x[i] =x[i];
            }
            if(c.zigzagdata_count==365){
               x[i] =x[i];
            }
            if(c.zigzagdata_count==366){
               x[i] =x[i];
            }
            if(c.zigzagdata_count==367){
               x[i] =x[i];
            }
            if(c.zigzagdata_count==368){
               x[i] =x[i];
            }        
        }
        printf("##########_end");
    }
    pre_zigaag_count = c.zigzagdata_count;
#endif //delllll    
}
#ifdef USE_OnDeinit_output_zigzag_output_each_period
void zigzag_output_period(ENUM_TIMEFRAMES period){
    candle_data *c =  p_allcandle.get_candle_data_pointer(period);
    int num=0;
    string TTT=",";
    if(c != NULL&& c.zigzagdata_count>3){
        num=c.zigzagdata_count;
        string symbolname = _Symbol;
        string filename = symbolname+PeriodToString(period)+".csv";
        string outdata="";
        string ss="シンボル名"+TTT+"idx"+TTT+"price"+TTT+"UD"+TTT+"時間ｓ"+TTT+"時間文字"+
        TTT+"ma20"+TTT+"ma20傾き"+TTT+"ma乖離"+TTT+"3シグマ間PIPS"+TTT+"3シグマ間価格"+TTT+
        "σ"+TTT+"ｂ+3σ"+TTT+"ｂ+2σ"+TTT+"ｂ+1σ"+TTT+"ｂ-3σ"+TTT+"ｂ-2σ"+TTT+"ｂ-1σ"+TTT
        ;
        addstring(outdata,ss);
        for(int i=1;i<num;i++){
            int k=num-i;
        	double y1=c.ZigY(k);
    	    double ud1 = c.ZigUD(k);      
            double  x1=c.ZigX(k);
            datetime x1_datetime = c.Zigtime(k);
            string x1_string = TimeToString(x1_datetime,TIME_DATE|TIME_MINUTES);
            ss =
                symbolname+TTT+
                IntegerToString(k)+TTT+
                DoubleToString(y1)+TTT+
                IntegerToString(ud1)+TTT+ 
                IntegerToString(x1_datetime)+TTT+
                x1_string+TTT+

            	DoubleToString(c.zigzagdata[i].ma_20_sma)+TTT+
            	DoubleToString(c.zigzagdata[i].ma_20_sma_katamuki)+TTT+
            	DoubleToString(c.zigzagdata[i].ma_kairi)+TTT+
            	DoubleToString(c.zigzagdata[i].b_sig3updn_pips)+TTT+
            	DoubleToString(c.zigzagdata[i].b_sig3updn_dist)+TTT+
            	DoubleToString(c.zigzagdata[i].b_sig)+TTT+
            	DoubleToString(c.zigzagdata[i].b_3sig_up)+TTT+
            	DoubleToString(c.zigzagdata[i].b_2sig_up)+TTT+
            	DoubleToString(c.zigzagdata[i].b_1sig_up)+TTT+
            	DoubleToString(c.zigzagdata[i].b_3sig_dn)+TTT+
            	DoubleToString(c.zigzagdata[i].b_2sig_dn)+TTT+
            	DoubleToString(c.zigzagdata[i].b_1sig_dn)+TTT
                ;
            addstring(outdata,ss);
        }
        writestring_file(filename,outdata,false);
 
    }

}
#endif//USE_OnDeinit_output_zigzag_output_each_period
#ifdef USE_OnDeinit_output_zigzag_output_each_period
void zigzag_output(void){
    zigzag_output_period(PERIOD_M5); 
    zigzag_output_period(PERIOD_M15); 
    zigzag_output_period(PERIOD_M30); 
    zigzag_output_period(PERIOD_H1); 
    zigzag_output_period(PERIOD_H4); 
    zigzag_output_period(PERIOD_D1); 

}
#endif//USE_OnDeinit_output_zigzag_output_each_period

#ifdef USE_out_candle_debug
void out_candle_debug(datetime t,int rates_total,int prev_calculated,
    const datetime &time[],
    const double &open[],const double &high[],const double &low[],const double &close[]){


    string TTT=",";
        string symbolname = _Symbol;
        string filename = symbolname+PeriodToString(Inp_base_time_frame)+"_candle.csv";
        string outdata="";
        string ss="シンボル名"+TTT+"idx"+TTT+"open"+TTT+"high"+TTT+"low"+TTT+"close"+
        TTT+"time"+TTT+"time名前"
        ;
        addstring(outdata,ss);



    if(time[rates_total-1] == t){
#ifdef adsfasdfasdfasdf    
        for(int i=1;i<rates_total;i++){
            ss = symbolname+TTT+IntegerToString(i)+TTT+
                DoubleToString(open[i]) + TTT+    
                DoubleToString(high[i]) + TTT+    
                DoubleToString(low[i]) + TTT+    
                DoubleToString(close[i]) + TTT+    
                IntegerToString(time[i]) + TTT+    
                TimeToString(time[i]) + TTT
                ;    
            addstring(outdata,ss);
        }
                
        writestring_file(filename,outdata,false);
#endif

        debug_candle_data(PERIOD_H1);

    }

    
}
#endif//USE_out_candle_debug

#ifdef USE_debug_candle_date_view
void debug_candle_data(ENUM_TIMEFRAMES period){
    candle_data *c =  p_allcandle.get_candle_data_pointer(period);
    int num=0;
    string TTT=",";
        string symbolname = _Symbol;
        string filename = symbolname+PeriodToString(period)+"debug_candledata300.csv";
        string outdata="";
        string ss="シンボル名"+TTT+"idx"+TTT+"open"+TTT+"high"+TTT+"low"+TTT+"close"+
        TTT+"time"+TTT+"time名前"
        ;
        addstring(outdata,ss);


    if(c != NULL&& c.candle_bar_count>3){
        num=c.zigzagdata_count;
        int start = 0;
        if(300 > c.candle_bar_count){ start = 300 - c.candle_bar_count;}
        int end=300;
//        for(int i=0;i<c.candle_bar_count;i++){
        for(int i=start;i<end;i++){
            ss = symbolname+TTT+IntegerToString(i)+TTT+
                DoubleToString(c.open[i]) + TTT+    
                DoubleToString(c.high[i]) + TTT+    
                DoubleToString(c.low[i]) + TTT+    
                DoubleToString(c.close[i]) + TTT+    
                IntegerToString(c.time[i]) + TTT+    
                TimeToString(c.time[i]) + TTT
                ;    
            addstring(outdata,ss);
        }
                
        writestring_file(filename,outdata,false);

    }

}
#endif//USE_debug_candle_date_view
#ifdef USE_debug_candle_date_view
//debug_H1_candle_copyfuffer(1515020400,PERIOD_H1);
void debug_H1_candle_copyfuffer(datetime now_bar_time,ENUM_TIMEFRAMES period){
            datetime times[];int ret = 0;int error_count =0;
            int ret1;
            int n=10;
    		ret1 = (CopyTime(_Symbol,(ENUM_TIMEFRAMES)period,(datetime)now_bar_time,(int)n,times));// idx 0 が古い　１が最新
    		if(ret1 <n){
    		    printf("error not get timedata");
    		    error_count+=1;
    		}
            double opens[],closes[],highs[],lows[];
    		ret1 = (CopyOpen(_Symbol,(ENUM_TIMEFRAMES)period,(datetime)now_bar_time,(int)n,opens));
    		if(ret1 <n){
    		    printf("error not get opendata");
    		    error_count+=10;
    		}
    		ret1 = (CopyClose(_Symbol,(ENUM_TIMEFRAMES)period,(datetime)now_bar_time,(int)n,closes));
    		if(ret1 <n){
    		    printf("error not get closedata");
    		    error_count+=100;
    		}
    		ret1 = (CopyHigh(_Symbol,(ENUM_TIMEFRAMES)period,(datetime)now_bar_time,(int)n,highs));
    		if(ret1 <n){
    		    printf("error not get highdata");
    		    error_count+=1000;
    		}
    		ret1 = (CopyLow(_Symbol,(ENUM_TIMEFRAMES)period,(datetime)now_bar_time,(int)n,lows));
    		if(ret1 <n){
    		    printf("error not get lowdata at candle_data::add_new_bar");
    		    error_count+=10000;
    		}
            if(error_count > 0){
                ret = false;
                return;
            }else{//
                
                 string TTT=",";
                    string symbolname = _Symbol;
                    string filename = symbolname+PeriodToString(period)+IntegerToString(now_bar_time)+"debug_copybuffout10.csv";
                    string outdata="";
                    string ss="シンボル名"+TTT+"idx"+TTT+"open"+TTT+"high"+TTT+"low"+TTT+"close"+
                    TTT+"time"+TTT+"time名前"
                    ;
                    addstring(outdata,ss);               
                for(int i=0;i<n;i++){
                    ss= symbolname+TTT+IntegerToString(i)+TTT+
                        DoubleToString(opens[i])+TTT+
                        DoubleToString(highs[i])+TTT+
                        DoubleToString(lows[i])+TTT+
                        DoubleToString(closes[i])+TTT+
                        IntegerToString(times[i])+TTT+
                        TimeToString(times[i])
                        ;
                        addstring(outdata,ss);               

                }
                writestring_file(filename,outdata,false);

            
            }

}
#endif//USE_debug_candle_date_view


#ifdef USE_Lib_Myfunc_Ind_entry_exit
 void SetSendData_forEntry(int EntryNo,int EntryDirect,int hyoukaNo,int hyoukaSyuhouNo,double EntryPrice,double Tp_Price,double Sl_Price){
	//GlobalVariableSet("Ind_EntryNo",EntryNo);
	//GlobalVariableSet("Ind_EntryDirect",EntryDirect);
	//GlobalVariableSet("Ind_hyoukaNo",hyoukaNo);
	//GlobalVariableSet("Ind_hyoukaSyuhouNo",hyoukaSyuhouNo);
	//GlobalVariableSet("Ind_EntryPrice",EntryPrice);
	//GlobalVariableSet("Ind_Tp_Price",Tp_Price);
	//GlobalVariableSet("Ind_Sl_Price",Sl_Price);

	//SetSendData_forEntry_tpsl_direct_ctrl(int EntryDirect,int hyoukaNo,int hyoukaSyuhouNo,double EntryPrice,double Tp_Price,double Sl_Price,double lots)
	double lots = 0.1;	
	SetSendData_forEntry_tpsl_direct_ctrl(EntryDirect,hyoukaNo,hyoukaSyuhouNo,EntryPrice,Tp_Price,Sl_Price,lots);
	
 }
#endif//USE_Lib_Myfunc_Ind_entry_exit

#ifdef USE_Lib_Myfunc_Ind_entry_exit
int Entry_zig_no; 
void init_entry_check_tick(void){
    Entry_zig_no=0;
}
#endif//USE_Lib_Myfunc_Ind_entry_exit

#ifdef dell_debug
void Entry_check_tick(void){
    candle_data *cm5;    
    candle_data *cm15;
    candle_data *ch1;

    cm5=p_allcandle.get_candle_data_pointer(PERIOD_M5);
    cm15=p_allcandle.get_candle_data_pointer(PERIOD_M15);
    ch1=p_allcandle.get_candle_data_pointer(PERIOD_H1);    

    //直近のM5の　Zigzag 
    double cm5y0,cm5y1,cm5y2,cm5y3;
    cm5y0=cm5.ZigY(0);
    cm5y1=cm5.ZigY(1);
    cm5y2=cm5.ZigY(2);
    cm5y3=cm5.ZigY(3);
    
    //直近のh1の　Zigzag 
    double ch1y0,ch1y1,ch1y2,ch1y3,ch1y4;
    ch1y0=ch1.ZigY(0);
    ch1y1=ch1.ZigY(1);
    ch1y2=ch1.ZigY(2);
    ch1y3=ch1.ZigY(3);
    ch1y4=ch1.ZigY(4);
    
    int entry_zig_no = cm5.zigzagdata_count;
    
    double ch1d01,ch1d12,ch1d23,ch1d34;
    ch1d01=MathAbs(ch1y0-ch1y1);
    ch1d12=MathAbs(ch1y1-ch1y2);
    ch1d23=MathAbs(ch1y2-ch1y3);
    ch1d34=MathAbs(ch1y3-ch1y4);

    //続伸時＋底の時
  

}
//時間軸で指定Zigzagのidxの時の目線、目線切り替わりの境界（上下）、算出
//　目線切り替わりの境界のセットの過去分が取れるといいのか？

#endif//dell_debug



#ifdef delll_debug
//int i_test_ind_to_ea;//debug
void test_ind_to_ea(int idx){
    //i_test_ind_to_ea++;
    if(idx >=0){
        buffEMA[0]=idx+1;
    }
}


int handle_ema;
int handle_bolinger;
void init_ema_bolinger(void){
   handle_ema = iMA(_Symbol,PERIOD_CURRENT,10,0,MODE_EMA,PRICE_CLOSE);
   handle_bolinger=iBands(_Symbol,PERIOD_CURRENT,20,0,2,PRICE_CLOSE);
#ifdef commmment
   int  iBands(
  string              symbol,            // 銘柄名
  ENUM_TIMEFRAMES    period,            // 期間
  int                bands_period,     // 平均線の計算の期間
  int                bands_shift,      // 指標の水平シフト
  double              deviation,        // 標準偏差の数
  ENUM_APPLIED_PRICE  applied_price      // 価格の種類かハンドル
  );
#endif//commmmment  
}

void test_arrays(double &oo[]){
   oo[0]=1.0;
   oo[1]=oo[0]+1;
}
#endif//delll_debug



//tmp 
//頂点と境界を探すアルゴリズム								
//data
struct sturct_mesen_tyouten_mesenKirikawariKyouka{					
        datetime t;				
        double v;				
        int zigidx;				
    };
sturct_mesen_tyouten_mesenKirikawariKyouka vtdata[3];
void test_sturct_mesen_tyouten_mesenKirikawariKyouka(){
    bool ret = false;
    int out_dir=0;
    int chk_zigcount;
    //allcandle *pac = p_allcandle;//pac global dell
    if(pac==NULL){return;}
    candle_data *c=pac.get_candle_data_pointer(PERIOD_M15);
    if(c!=NULL){
        chk_zigcount=c.zigzagdata_count;
        if(c.zigzagdata_count >400){
            get_mesen_tyouten_mesenKirikawariKyoukai(PERIOD_M15,c.zigzagdata_count-1
            ,5,vtdata);

            int ma_handle = c.handle_sma_20;
            double ma_sma_20_cal; 
            bool rr=false;
            datetime tt=c.get_now_time();
            rr = c.ma_get_value_now(ma_handle,ma_sma_20_cal,tt);


            double ma_sma_20,ma_ema_20;
            //bool rr2,rr3;rr2=false;rr3=false;
            ma_sma_20 = c.MAprice(20,MODE_SMA,0);
            ma_ema_20 = c.MAprice(20,MODE_EMA,0);
            printf( TimeToString( c.get_now_time()) +"①  ema="+DoubleToString(ma_ema_20)+"  sma="+DoubleToString(ma_sma_20));
            printf( TimeToString( c.get_now_time()) +"②  sma="+DoubleToString(ma_sma_20_cal)+"  sma="+DoubleToString(ma_sma_20)+"sa="+DoubleToString(ma_sma_20_cal-ma_sma_20));
        }
    }
}
void test_ma(){
    //addbarの時に呼び出しのイメージ
    // 足確定時の最新と確定足の足の情報とＭＡ情報を計算する。
    bool ret = false;
    int out_dir=0;
    int chk_zigcount;
    //allcandle *pac = p_allcandle;//pac global dell
    if(pac==NULL){return;}
    candle_data *c=pac.get_candle_data_pointer(PERIOD_M1);
    if(c!=NULL){
        chk_zigcount=c.zigzagdata_count;
        if(c.zigzagdata_count >400){
            //get_mesen_tyouten_mesenKirikawariKyoukai(PERIOD_M5,c.zigzagdata_count-1
            //,5,vtdata);

            //int ma_handle = c.handle_sma_20;
            //double ma_sma_20_cal; 
            //bool rr=false;
            //datetime tt=c.get_now_time();
            //rr = c.ma_get_value_now(ma_handle,ma_sma_20_cal,tt);


            double ma_sma,ma_ema;
            //bool rr2,rr3;rr2=false;rr3=false;
            ma_sma = c.MAprice(3,MODE_SMA,0);
            ma_ema = c.MAprice(3,MODE_EMA,0);
            printf( TimeToString( c.time[299]) +"①  ema="+DoubleToString(ma_ema)+"  sma="+DoubleToString(ma_sma));
            ma_sma = c.MAprice(3,MODE_SMA,1);
            ma_ema = c.MAprice(3,MODE_EMA,1);
            printf( TimeToString( c.time[298]) +"①  ema="+DoubleToString(ma_ema)+"  sma="+DoubleToString(ma_sma));
        }
    }    
}

#ifdef delll
void test_kiriage_channel_kakutei(void){
    bool ret = false;
    int out_dir=0;
    int chk_zigcount;
    static int t_zigzag_count=0;
    static int pre_t_zigzag_count =-1;
    static int pre_E_no = -1;
    static int viewed = 0;
    //allcandle *pac = p_allcandle;//pac global dell
    if(pac==NULL){return;}
    candle_data *c=pac.get_candle_data_pointer(PERIOD_M15);
    if(c!=NULL){
        chk_zigcount=c.zigzagdata_count;
        
        if(c.zigzagdata_count >400 && pre_t_zigzag_count != c.zigzagdata_count
         && c.zigzag_chg_flag==true&&        (c.zigzag_chg_flag_status==1||c.zigzag_chg_flag_status==0||c.zigzag_chg_flag_status==-1)
        ){
 //         	//n個分の　目線の切り替わり＋続伸の線分を取得する(中途半場は除く（切り替わり線分と続伸線分を取得）)
//         	//新しい点を配列の０へ格納
//         	bool get_mesen_Cn_kirikawari_zokusin(int n,struct_mesen_tyouten_zokushin &cn_out[]){
//         		bool ret = false;
            struct_mesen_tyouten_zokushin cn_out[5];
            bool ret_kirikawari_sokusin =               c.get_mesen_Cn_kirikawari_zokusin(5, cn_out);

#ifdef comment
                E
        C
                    F
A           D

    B
#endif //comment
            //形になっているか判定
            real_point A,M,C,B,D,E;
            A.v = cn_out[4].v;/*y*/            A.t = cn_out[4].t;//x
            B.v = cn_out[3].v;/*y*/            B.t = cn_out[3].t;//x
            C.v = cn_out[2].v;/*y*/            C.t = cn_out[2].t;//x
            D.v = cn_out[1].v;/*y*/            D.t = cn_out[1].t;//x
            E.v = cn_out[0].v;/*y*/            E.t = cn_out[0].t;//x
            
           if(   E.v >D.v && C.v > B.v && C.v > D.v &&                       D.v > B.v && E.v > C.v  &&pre_E_no!= cn_out[0].no ){
            
            //if(E.v >D.v && C.v > B.v && C.v > D.v && A.v>B.v&& A.v < C.v&& D.v > B.v && E.v > C.v){
                // A and D  same price
                //view
                pre_E_no = cn_out[0].no;
                int aaaa=0;
                if(A.v>B.v){
                  aaaa=1;
                }
                if( A.v < C.v){
                  aaaa=aaaa+2;
                }
                if(aaaa==3){
                    aaaa = 9;
                    for(int nn=0;nn<4;nn++){
                       string name1 = "PPPtn"+IntegerToString(cn_out[nn].no-1)+"_"+IntegerToString(cn_out[nn+1].no-1)+
                        "("+IntegerToString(cn_out[4].no-1)+"_"+IntegerToString(cn_out[0].no-1)+")";
                       
                       TrendCreate(0,name1,0,cn_out[nn].t,cn_out[nn].v    ,cn_out[nn+1].t,cn_out[nn+1].v,clrWhiteSmoke,STYLE_SOLID,7);
                    }
                    t_zigzag_count = c.zigzagdata_count;
                    
                    printf("###"+IntegerToString(cn_out[0].no-1));
                    printf("   "+DoubleToString(A.v,2)+"  "+TimeToString(A.t));
                    printf("   "+DoubleToString(B.v,2)+"  "+TimeToString(B.t));
                    printf("   "+DoubleToString(C.v,2)+"  "+TimeToString(C.t));
                    printf("   "+DoubleToString(D.v,2)+"  "+TimeToString(D.t));
                    printf("   "+DoubleToString(E.v,2)+"  "+TimeToString(E.t));
                    printf("E point zig count="+IntegerToString(t_zigzag_count-1));
                    
                   

                   
                   viewed=1;
                }
            }
            //止めて見る用
            if(t_zigzag_count+2 == c.zigzagdata_count&& viewed==1){
                t_zigzag_count=t_zigzag_count;
                viewed=2;
            }else if(t_zigzag_count+4 == c.zigzagdata_count && viewed ==2){
                t_zigzag_count=t_zigzag_count;
                viewed=3;
            }
        }
        pre_t_zigzag_count = t_zigzag_count;
    }
}
#endif //delll test
void test_struct_mesen_info_chg_mesen_data1(){
    test_struct_mesen_info_chg_mesen_data1_base(Inp_base_time_frame,1);//base TimeFrame
    test_struct_mesen_info_chg_mesen_data1_base(PERIOD_H4,2);//H4 TimeFrame
    
}
void test_struct_mesen_info_chg_mesen_data1_base(ENUM_TIMEFRAMES tf,int opt){
  bool isnew_bar=flagchgbarM15;
  static int  seiritu_zigcount=-1;
  static int  pre_cond_zigcount=0;
  
   #ifdef debug_20211101
  // printf("call #1test_struct_mesen_info_chg_mesen_data1");
   #endif      

  if(isnew_bar == true || true){//&& b_during_test_piriod==true){
      //debug
        //printf("debug call test_struct_mesen_info_chg_mesen_data1");

   #ifdef debug_20211101
  // printf("call #2test_struct_mesen_info_chg_mesen_data1");
   #endif      


    bool ret = false;
    int out_dir=0;
    int chk_zigcount;
    //allcandle *pac = p_allcandle;//pac global dell
    if(pac==NULL){return;}
    //candle_data *c=pac.get_candle_data_pointer(PERIOD_M15);
    candle_data *c=pac.get_candle_data_pointer(tf);
    
    struct_mesen_info_chg_mesen_data1 o;
    if(c!=NULL){
        chk_zigcount=c.zigzagdata_count;
        if(c.zigzagdata_count >10){
   #ifdef debug_20211101
   //printf("call #3test_struct_mesen_info_chg_mesen_data1");
   #endif      

#ifdef debug20211105
if(c.zigzagdata_count == 310){
c.zigzagdata_count =310;
}else if(c.zigzagdata_count == 311){
c.zigzagdata_count =311;
}else if(c.zigzagdata_count == 312){
c.zigzagdata_count =312;
}else if(c.zigzagdata_count == 313){
c.zigzagdata_count =313;

}
#endif//debug20211105


            if(c.isChg_mesen2()==true  && seiritu_zigcount != c.zigzagdata_count){//目線が切り替わったばかりの時のみTrue
                    #ifdef debug_20211101
                    printf("call #33 "+  TimeToString(c.time[CANDLE_BUFFER_MAX_NUM-1]) +   "  test_struct_mesen_info_chg_mesen_data1");
                    #endif      

               seiritu_zigcount = c.zigzagdata_count;
                ret = c.get_info_chg_mesen_data1( o);
                if(ret == true){
                    #ifdef debug_20211101
                    printf("call #4 "+  TimeToString(c.time[CANDLE_BUFFER_MAX_NUM-1]) +   "  test_struct_mesen_info_chg_mesen_data1");
                    #endif      


                    //hyouji
                    out_dir=1;
                        string name;
                        color clr;
                        ENUM_LINE_STYLE style;//=STYLE_DOT     STYLE_DASHDOTDOT
                        bool nuritubushi=true;
                        int width = 3;
                        if(o.dir == 1){
                            name="MC"+"UP_"+PeriodToString(c.period)+"_"+IntegerToString(o.kiten_zig_idx);
                            clr = clrHoneydew;
                            style=STYLE_DOT;
                        }else{
                            name="MC"+"DN_"+PeriodToString(c.period)+"_"+IntegerToString(o.kiten_zig_idx);
                            clr = clrPink;//clrOldLace;
                            style=STYLE_DASHDOTDOT;
                        }
                        if(opt==1){//塗りつぶしあり
                            nuritubushi=true;
                        }else if(opt==2){//塗りつぶしなし
                            nuritubushi=false;
                        }

                        RectangleCreate(0,name,0,
                        o.kiten_t,o.tyouten_v,
                        o.koetaten_t,o.koetaten_v,
                        clr,
                        style,
                        width,
                        nuritubushi,//四角形を色で塗りつぶす
                        true,//背景で表示する
                        true,//
                        false//オブジェクトリストに隠す
                        );
                        string tt="Dn-1";
                        if(o.dir==1){tt="Up+1 ";}
                        printf("debbbbbbbbbbbbbbbbbbbbbbbbbbbb "+tt +" tyzg="+IntegerToString(o.tyouten_zig_idx)+"t="+TimeToString(o.koetaten_t));
                }
            }
            
            if(seiritu_zigcount + 3 == c.zigzagdata_count){
                    if(pre_cond_zigcount!=c.zigzagdata_count){
                       out_dir=2;
                       pre_cond_zigcount=c.zigzagdata_count;
                    }
            
            }else if(seiritu_zigcount + 5 ==  c.zigzagdata_count){
                    if(pre_cond_zigcount!=c.zigzagdata_count){
                       out_dir=3;
                       pre_cond_zigcount=c.zigzagdata_count;
                    }
            
            }else if(seiritu_zigcount + 7 == c.zigzagdata_count){
                    if(pre_cond_zigcount!=c.zigzagdata_count){
                       out_dir=4;
                       pre_cond_zigcount=c.zigzagdata_count;
                    }
            
            }
            
            
        }
    }


  }

        
}
//	Zigidxを起点に、※頂点・目線切り替わり境界３つを探してくる							
bool	get_mesen_tyouten_mesenKirikawariKyoukai(
            ENUM_TIMEFRAMES period_,
            int zigidx,//探す起点のidxを含んで過去を探す
            int num,  //取得数
            sturct_mesen_tyouten_mesenKirikawariKyouka &out_data[])
{

		//戻り値						
		//	n個取得成功　true					
		//	取得失敗	FALSE				
    bool ret = false;
    int out_dir=0;
    int chk_zigcount;
    //allcandle *pac = p_allcandle;//pac global dell

    candle_data *c=pac.get_candle_data_pointer(period_);
    if(c!=NULL)
    {
        chk_zigcount=c.zigzagdata_count;
        if(zigidx<chk_zigcount
            && c.count_mesen_C >num)
        {
            //Cnを３つとってきてそれを起点に境界と頂点を探す
       		struct_mesen_C mesen_cc[5];
            //目線切り替わり付近からの頂点を取得する
	        struct_mesen_tyouten cn_tyoutenn[5];


//         	//n個分の　目線の切り替わり＋続伸の線分を取得する(中途半場は除く（切り替わり線分と続伸線分を取得）)
//         	//新しい点を配列の０へ格納
//         	bool get_mesen_Cn_kirikawari_zokusin(int n,struct_mesen_tyouten_zokushin &cn_out[]){
//         		bool ret = false;
            struct_mesen_tyouten_zokushin cn_out[5];
            bool ret_kirikawari_sokusin =
               c.get_mesen_Cn_kirikawari_zokusin(5, cn_out);

            int i;
            for(i=0;i<num;i++){
                if(c.get_mesen_Cn_new(i,mesen_cc[i])==false){return false;}
                if(c.get_mesen_tyoutenn(4, cn_tyoutenn)==false){return false;}
            }
        }    
        bool r=false;
            
    }
    return ret;
}