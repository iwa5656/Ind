//#define USE_Tick_bar  //Tick barをりようする
#define USE_OnDEinit_Fractals
#define USE_CALC_PASS_kako
#define USE_ZIGZAG_M1 
#define USE_ZIGZAG_M5 
//#define USE_ZIGZAG_M15 
//#define USE_ZIGZAG_M30
#define USE_ZIGZAG_H1
#define USE_ZIGZAG_H4
 
 

input ENUM_TIMEFRAMES Inp_base_time_frame = PERIOD_M5;// 評価時間軸
//input ENUM_TIMEFRAMES Inp_base_time_frame = PERIOD_H1;// 評価時間軸

#define Lib_iunima_mtf_ru

int idebug;
#ifdef Lib_iunima_mtf_ru
#include "iunima_mtf_ru.mqh"
#endif// Lib_iunima_mtf_ru

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
#property indicator_type2   DRAW_LINE 
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
#include "classMethod.mqh"
//#include "classMethod_range.mqh"
#include "classMethod_flag.mqh"

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
// hyouka
//MethodPattern *m_hyouka;// ★★ 複数のMethodPatternを持てるようにして、平行にしょりするには
//MethodPattern_range *m_hyouka;// ★★ 複数のMethodPatternを持てるようにして、平行にしょりするには
MethodPattern_flag *m_hyouka;// ★★ 複数のMethodPatternを持てるようにして、平行にしょりするには
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                         |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   Comment("");
   m_hyouka.kekka_calc_out_all();
   for(int n =0;n<7;n++){
    m_hyouka.view_kekka_youso_flag(n);
   }
   printf("Ondeinit...");
   zigzag_output();//debug Zigzagout 20200809
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
init_zigzag_debug();//debug 20200603  
  
	//get_timeframe_value();//debug
  Deinit_XXX_objdelete();
	p_allcandle = new allcandle;
	p_allcandle.Oninit();
//	m_hyouka = new MethodPattern_range("Wtop",PERIOD_M1,p_allcandle.get_candle_data_pointer(PERIOD_M1),p_allcandle);
//	m_hyouka = new MethodPattern_range("Wtop",Inp_base_time_frame,p_allcandle.get_candle_data_pointer(Inp_base_time_frame),p_allcandle);
	m_hyouka = new MethodPattern_flag("Wtop",Inp_base_time_frame,p_allcandle.get_candle_data_pointer(Inp_base_time_frame),p_allcandle);
	m_hyouka.Oninit();
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
  global_rates_total=rates_total;
  golobal_prev_calculated = prev_calculated;
  ArraySetAsSeries(time,true);
#ifdef USE_CALC_PASS_kako  
if(rates_total > prev_calculated+1000){
    return   rates_total -1000;
}
#endif //USE_CALC_PASS_kako

#ifdef Lib_iunima_mtf_ruZZZZZZZ
    //MA
    int retm;
    retm=OnCalculate_iunima_mtf_ru(rates_total,prev_calculated,time,open,high,low,close,tick_volume,volume,spread);
    if(retm==0){return 0;}
#endif// Lib_iunima_mtf_ru

//    ArraySetAsSeries(time,false);

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
    else{
        limit=rates_total-1+1000;
    }//未処理の確定足なしのためidxは最後とする
//    for(int i = limit;i<rates_total-1;i++){// （time[0]最新、一番古物は rates_total-1）　 
//    for(int i = rates_total-limit;i>=0;i--){// （time[0]最新、一番古物は rates_total-1）　 
    for(int i = (rates_total)-limit;i>0;i--){// （time[0]最新、一番古物は rates_total-1）　 
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
        p_allcandle.calc_new_bar_flag(t1,t2);// 前後の時間を渡し、フラグを設定してもらう。（呼び出し時に初期化する）
        
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
	            int ret4 = p_allcandle.Oncalculate_Fractals(peri);
	            p_allcandle.calc_kakutei(peri);//パターンなどの確定した後に計算するものを実行
	            m_hyouka.hyouka();
	            
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
                int ret4 = p_allcandle.Oncalculate_Fractals(peri);
                p_allcandle.calc_kakutei(peri);//パターンなどの確定した後に計算するものを実行
                if(peri== Inp_base_time_frame){
    	            m_hyouka.hyouka();
    	        }
    	    }
#endif// USE_ZIGZAG_M5
        }
        if(flagchgbarM15){
#ifdef USE_ZIGZAG_M15        
			ENUM_TIMEFRAMES peri=PERIOD_M15;
            if(timeframe_hidari_ijou(Inp_base_time_frame,peri)){//現在時間軸足以上の足のみ処理する。　
                datetime t = time[i];
                bool rr = p_allcandle.add_new_bar( peri,t);// ローソク作成
                //Zigzag作成処理　足確定した分を渡す（ここでは1つ分）　　　　　　　・・・確定、未確定のイメージ
                int ret3 = p_allcandle.Oncalculate_ZIGZAG(peri);
                int ret4 = p_allcandle.Oncalculate_Fractals(peri);
                p_allcandle.calc_kakutei(peri);//パターンなどの確定した後に計算するものを実行
                if(peri== Inp_base_time_frame){
    	            m_hyouka.hyouka();
    	        }
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
                int ret4 = p_allcandle.Oncalculate_Fractals(peri);
                p_allcandle.calc_kakutei(peri);//パターンなどの確定した後に計算するものを実行
                if(peri== Inp_base_time_frame){
    	            m_hyouka.hyouka();
    	        }
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
                bool rr = p_allcandle.add_new_bar( peri,t);// ローソク作成
                //Zigzag作成処理　足確定した分を渡す（ここでは1つ分）　　　　　　　・・・確定、未確定のイメージ
                int ret3 = p_allcandle.Oncalculate_ZIGZAG(peri);
//                int ret4 = p_allcandle.Oncalculate_Fractals(peri);
                p_allcandle.calc_kakutei(peri);//パターンなどの確定した後に計算するものを実行
                if(peri== Inp_base_time_frame){
    	            m_hyouka.hyouka();
    	        }
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
                if(peri== Inp_base_time_frame){
    	            m_hyouka.hyouka();
    	        }
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
                int ret4 = p_allcandle.Oncalculate_Fractals(peri);
                p_allcandle.calc_kakutei(peri);//パターンなどの確定した後に計算するものを実行
                if(peri== Inp_base_time_frame){
    	            m_hyouka.hyouka();
    	        }
    	    }
#endif // USE_ZIGZAG_D1

        }
        if(flagchgbarW1){
           // printf("W1"+TimeToString(time[i]));
        }
        if(flagchgbarMN1){
            //printf("MN"+TimeToString(time[i]));
        }
        
    }    
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
//chk_zigzag_debug();//debug 20200603
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

   double price_tick;
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



//--- return value of prev_calculated for next call
   return(rates_total);
  }
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
    //handle_zigzag = iCustom(Symbol(),Period(),"examples\\zigzag");

}
#define aaa 200
double bufferzigzag_top[aaa];
double bufferzigzag_low[aaa];
datetime bufferzigzag_time[aaa];
void ontick_zigzag_debug(void){
    int n=140;
    int ret=0;
       if(CopyBuffer(handle_zigzag ,0,0,n,bufferzigzag_top ) < n ) ret=1;  // buffer[0]古い  [1]最新
       if(CopyBuffer(handle_zigzag ,2,0,n,bufferzigzag_low ) < n ) ret=ret+10;  // buffer[0]古い  [1]最新
    //   bool fffbufferzigzag_low = ArrayGetAsSeries(bufferzigzag_low);
    
       if(CopyTime(_Symbol,_Period,0,n,bufferzigzag_time ) < n ) ret=ret+100;  // buffer[0]古い  [1]最新
    
        if(ret>0){
            printf("error get zigzag "+IntegerToString(ret));
        }
}
int pre_zigaag_count;
void chk_zigzag_debug(void){
    //allcandle *p_allcandle;
    
    candle_data *c =  p_allcandle.get_candle_data_pointer(PERIOD_M5);
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
        for(int i=0;i<7;i++){
        
            x[i] = c.ZigY(i+1);
            t[i] = c.Zigtime(i+1);
            if(zud[i]!=x[i]){
                printf("error diff x"+i+ "zigorg"+DoubleToString(zud[i]) + "zig="+ DoubleToString(x[i])
                +  " zig count"+c.zigzagdata_count+" "+TimeToString(t[i])+" "+TimeToString(zt[i]));
            }
        }
    }
    pre_zigaag_count = c.zigzagdata_count;
}

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

void zigzag_output(void){
    zigzag_output_period(PERIOD_M5); 
    zigzag_output_period(PERIOD_M15); 
    zigzag_output_period(PERIOD_M30); 
    zigzag_output_period(PERIOD_H1); 
    zigzag_output_period(PERIOD_H4); 
    zigzag_output_period(PERIOD_D1); 

}