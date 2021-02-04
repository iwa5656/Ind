//#define debug_Line 1  //
//#define USE_SAMEPOINT_CANDL //足からのSamepointを収集表示するか

//+------------------------------------------------------------------+
//|                                           ytg_Fractals_Price.mq5 |
//|                                   Copyright ｩ 2007, Yuriy Tokman |
//|                                            yuriytokman@gmail.com |
//+------------------------------------------------------------------+
#include <_inc\\My_function_lib2.mqh>


//---- drawing the indicator in the main window
//#property indicator_chart_window 
//---- two buffers are used for the indicator calculation and drawing
//#property indicator_buffers 2
//---- only two plots are used
//#property indicator_plots   2

//---- declaration of dynamic arrays that will further be 
// used as indicator buffers
double ExtDownFractalsBuffer[];
double ExtUpFractalsBuffer[];
//#define candle_bar_count candle_bar_count

datetime timePerbar;//一つのパーの秒数
//---
int min_rates_total;
string UpLable_,DnLable_;
string SameLineLabel_;
//+------------------------------------------------------------------+
//|  Creating a text label                                           |
//+------------------------------------------------------------------+
void CreateArrowRightPrice //CreateArrowRightPrice(0,"",0,Time,Price,Color,3)
(
 long   chart_id,         // chart ID
 string name,             // object name
 int    nwin,             // window index
 datetime Time,           // position of price label by time
 double Price,            // position of price label by vertical
 color  Color,            // text color
 uint    Size             // font size
 ,int idx            // ０最新のidx
 )
//---- 
  {
//----
	datetime idxtime = TimeCurrent()-idx * timePerbar;
	//not use tick so
//	idxtime = Time;
	idxtime = time[idx];
	
//string new_name = 
//   ObjectCreate(chart_id,name,OBJ_ARROW_RIGHT_PRICE,nwin,Time,Price);
   ObjectCreate(chart_id,name,OBJ_ARROW_RIGHT_PRICE,nwin,idxtime,Price);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetInteger(chart_id,name,OBJPROP_WIDTH,Size);
//ObjectSetInteger(chart_id,name,OBJPROP_BACK,true);
//----
  }
void CreateArrowBuySell //CreateArrowRightPrice(0,"",0,Time,Price,Color,3,updn)
(
 long   chart_id,         // chart ID
 string name,             // object name
 int    nwin,             // window index
 datetime Time,           // position of price label by time
 double Price,            // position of price label by vertical
 color  Color,            // text color
 uint    Size             // font size
 ,int idx            // ０最新のidx
 ,int updn
 )
//---- 
  {
//----
//	datetime idxtime = TimeCurrent()-idx * timePerbar;
	datetime idxtime = time[idx];
	if(updn==-1){
		//抵抗線　up mark
   		ObjectCreate(chart_id,name,OBJ_ARROW_BUY,nwin,idxtime,Price);
	}else{	
   		ObjectCreate(chart_id,name,OBJ_ARROW_SELL,nwin,idxtime,Price);
   	}
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetInteger(chart_id,name,OBJPROP_WIDTH,Size);
//ObjectSetInteger(chart_id,name,OBJPROP_BACK,true);
#ifdef debug_Line
	printf("CreateArrowBuySell"+name+"  "+ DoubleToString(Price) + "idx = "+ IntegerToString(idx));
#endif //	debug_Line
//----
  }  
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+     

void Deinit_Fractals()
  {
//----
   int total;
   string name,sirname;

   total=ObjectsTotal(0,0,-1)-1;

   for(int numb=total; numb>=0 && !IsStopped(); numb--)
     {
      name=ObjectName(0,numb,0,-1);
      sirname=StringSubstr(name,0,StringLen(UpLable_));

      if(sirname==UpLable_) ObjectDelete(0,name);
     }

   total=ObjectsTotal(0,0,-1)-1;

   for(int numb=total; numb>=0 && !IsStopped(); numb--)
     {
      name=ObjectName(0,numb,0,-1);
      sirname=StringSubstr(name,0,StringLen(DnLable_));

      if(sirname==DnLable_) ObjectDelete(0,name);
     }
//----
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit_Fractals()
  {
//---- initialization of global variables 
   min_rates_total=5;
//   UpLable_="Up_Fractals_Price";
//   DnLable_="Dn_Fractals_Price";
   UpLable_="@Tick@FU";
   DnLable_="@Tick@FD";
   SameLineLabel_="@Tick@SL";//SameLine
   int offset = 7;

#ifdef dellll   
//---- set dynamic array as an indicator buffer
   SetIndexBuffer(offset+0,ExtDownFractalsBuffer,INDICATOR_DATA);
//---- shifting the start of drawing of the indicator 1
   PlotIndexSetInteger(offset+0,PLOT_DRAW_BEGIN,min_rates_total);
//---- indicator symbol
   PlotIndexSetInteger(offset+0,PLOT_ARROW,UpLable);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(ExtDownFractalsBuffer,true);
//---- restriction to draw empty values for the indicator
   PlotIndexSetDouble(offset+0,PLOT_EMPTY_VALUE,0);
	ArrayInitialize(ExtDownFractalsBuffer,0); 

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(offset+1,ExtUpFractalsBuffer,INDICATOR_DATA);
//---- shifting the starting point of the indicator 2 drawing
   PlotIndexSetInteger(offset+1,PLOT_DRAW_BEGIN,min_rates_total);
//---- indicator symbol
   PlotIndexSetInteger(offset+1,PLOT_ARROW,DnLable);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(ExtUpFractalsBuffer,true);
//---- restriction to draw empty values for the indicator
   PlotIndexSetDouble(offset+1,PLOT_EMPTY_VALUE,0);
	ArrayInitialize(ExtUpFractalsBuffer,0); 
//---- Setting the format of accuracy of displaying the indicator
//   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- name for the data window and the label for sub-windows 
   string short_name="Fractals_Price";
//   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//----   
//----   
   //ArraySetAsSeries(ExtUpFractalsBuffer,true);
   //ArraySetAsSeries(ExtDownFractalsBuffer,true);
#endif// dellll
//----   
	timePerbar=PeriodSeconds();
//----
   init_fractal_data();
   init_sameline_data();
   init_samepoint_data();
   

   
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit_Fractals(const int reason)
  {
//----
   Deinit_Fractals();
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+

int OnCalculate_Fractals_(
                const int rates_total,    // amount of history in bars at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &Time[],
                const double &Open[],
                const double &High[],
                const double &Low[],
                const double &Close[]
//                const long &Tick_Volume[],
//                const long &Volume[],
//                const int &Spread[]
                )
  {
//---- checking the number of bars to be enough for calculation
   if(rates_total<min_rates_total) return(0);

//---- declaration of local variables 
   int limit;
   bool   bFound;
   double dCurrent;
   string stime;

//---- calculations of the necessary amount of data to be copied and
//the starting number limit for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      limit=rates_total-min_rates_total-3; // starting index for the calculation of all bars
     }
   else
     {
      if(rates_total==prev_calculated) return(rates_total);
      limit=rates_total-prev_calculated+2; // starting index for the calculation of new bars
     }

//---- indexing elements in arrays as timeseries  
   ArraySetAsSeries(High,true);
   ArraySetAsSeries(Low,true);
   ArraySetAsSeries(Time,true);

//---- main indicator calculation loop
   //for(int bar=2; bar<=limit && !IsStopped(); bar++)
   for(int bar=(rates_total-1)-2; bar>=( (rates_total-1) - limit) && !IsStopped(); bar--)
   //for(int bar=( (rates_total-1) - limit); bar<=(rates_total-1)-2 && !IsStopped(); bar++)
     {
//      ExtUpFractalsBuffer[bar]=0.0;
//      ExtDownFractalsBuffer[bar]=0.0;
            
      //----Fractals up
      bFound=false;
      dCurrent=High[bar];

      if(dCurrent>High[bar+1] && dCurrent>High[bar+2] && dCurrent>High[bar-1] && dCurrent>High[bar-2])
        {
         bFound=true;
//         ExtUpFractalsBuffer[bar]=dCurrent;
         if(ShowPrice)
           {
            stime=TimeToString(Time[bar],TIME_DATE|TIME_MINUTES);
//            CreateArrowRightPrice(0,DnLable_+stime,0,Time[bar],High[bar],DnColor,nSize,bar);
//            CreateArrowRightPrice(0,DnLable_+"@"+IntegerToString( (candle_bar_count-1)-bar )
//               +"@0@"+DoubleToString( High[bar]) + "@0"
            CreateArrowRightPrice(0,DnLable_+"@"+IntegerToString(samepoint_data_count)
               +"@0@"+DoubleToString( High[bar]) + "@0"
            
            ,0,Time[bar],High[bar],DnColor,nSize,bar);
            reg_fractal(chgBarToidx( rates_total,bar),High[bar],2,-1);//フラクタル２、抵抗線－１

           }
        }
      //----6 bars Fractal
      if(!bFound && (rates_total-bar-1)>=3)
        {
         if(dCurrent==High[bar+1] && dCurrent>High[bar+2] && dCurrent>High[bar+3] && 
            dCurrent>High[bar-1] && dCurrent>High[bar-2])
           {
            bFound=true;
//            ExtUpFractalsBuffer[bar]=dCurrent;
           }
        }
      //----7 bars Fractal
      if(!bFound && (rates_total-bar-1)>=4)
        {
         if(dCurrent>=High[bar+1] && dCurrent==High[bar+2] && dCurrent>High[bar+3] && dCurrent>High[bar+4] && 
            dCurrent>High[bar-1] && dCurrent>High[bar-2])
           {
            bFound=true;
//            ExtUpFractalsBuffer[bar]=dCurrent;
           }
        }
      //----8 bars Fractal                          
      if(!bFound && (rates_total-bar-1)>=5)
        {
         if(dCurrent>=High[bar+1] && dCurrent==High[bar+2] && dCurrent==High[bar+3] && dCurrent>High[bar+4] && dCurrent>High[bar+5] && 
            dCurrent>High[bar-1] && dCurrent>High[bar-2])
           {
            bFound=true;
//            ExtUpFractalsBuffer[bar]=dCurrent;
           }
        }
      //----9 bars Fractal                                        
      if(!bFound && (rates_total-bar-1)>=6)
        {
         if(dCurrent>=High[bar+1] && dCurrent==High[bar+2] && dCurrent>=High[bar+3] && dCurrent==High[bar+4] && dCurrent>High[bar+5] && 
            dCurrent>High[bar+6] && dCurrent>High[bar-1] && dCurrent>High[bar-2])
           {
            bFound=true;
//            ExtUpFractalsBuffer[bar]=dCurrent;
           }
        }

      //----Fractals down
      bFound=false;
      dCurrent=Low[bar];

      if(dCurrent<Low[bar+1] && dCurrent<Low[bar+2] && dCurrent<Low[bar-1] && dCurrent<Low[bar-2])
        {
         bFound=true;
//         ExtDownFractalsBuffer[bar]=dCurrent;
         if(ShowPrice)
           {
            stime=TimeToString(Time[bar],TIME_DATE|TIME_MINUTES);
//            CreateArrowRightPrice(0,UpLable_+stime,0,Time[bar],Low[bar],UpColor,nSize,bar);
//            CreateArrowRightPrice(0,UpLable_+"@"+IntegerToString( (candle_bar_count-1)-bar )
//               +"@0@"+DoubleToString( Low[bar]) + "@0"
            CreateArrowRightPrice(0,UpLable_+"@"+IntegerToString( samepoint_data_count)
               +"@0@"+DoubleToString( Low[bar]) + "@0"
               ,0,Time[bar],Low[bar],UpColor,nSize,bar);
			
			reg_fractal(chgBarToidx( rates_total,bar),Low[bar],2,1);//フラクタル２、支持線１
           }
        }
      //----6 bars Fractal
      if(!bFound && (rates_total-bar-1)>=3)
        {
         if(dCurrent==Low[bar+1] && dCurrent<Low[bar+2] && dCurrent<Low[bar+3] && 
            dCurrent<Low[bar-1] && dCurrent<Low[bar-2])
           {
            bFound=true;
//            ExtDownFractalsBuffer[bar]=dCurrent;
           }
        }
      //----7 bars Fractal
      if(!bFound && (rates_total-bar-1)>=4)
        {
         if(dCurrent<=Low[bar+1] && dCurrent==Low[bar+2] && dCurrent<Low[bar+3] && dCurrent<Low[bar+4] && 
            dCurrent<Low[bar-1] && dCurrent<Low[bar-2])
           {
            bFound=true;
//            ExtDownFractalsBuffer[bar]=dCurrent;
           }
        }
      //----8 bars Fractal                          
      if(!bFound && (rates_total-bar-1)>=5)
        {
         if(dCurrent<=Low[bar+1] && dCurrent==Low[bar+2] && dCurrent==Low[bar+3] && dCurrent<Low[bar+4] && dCurrent<Low[bar+5] && 
            dCurrent<Low[bar-1] && dCurrent<Low[bar-2])
           {
            bFound=true;
//            ExtDownFractalsBuffer[bar]=dCurrent;
           }
        }
      //----9 bars Fractal                                        
      if(!bFound && (rates_total-bar-1)>=6)
        {
         if(dCurrent<=Low[bar+1] && dCurrent==Low[bar+2] && dCurrent<=Low[bar+3] && dCurrent==Low[bar+4] && dCurrent<Low[bar+5] && 
            dCurrent<Low[bar+6] && dCurrent<Low[bar-1] && dCurrent<Low[bar-2])
           {
            bFound=true;
//            ExtDownFractalsBuffer[bar]=dCurrent;
           }
        }
     }
//----     
   ChartRedraw(0);
   return(rates_total);
  }
//+------------------------------------------------------------------+
//lib
datetime chgidxToTime(int idx,int num){// Tick　idxと数から。現在のバーから　指定の時間を算出する
	int nn=(num-1)-idx;
	return( 0-nn*timePerbar+ TimeCurrent());
	
}
datetime chgidxToTime(int idx){// Tick　idxと数から。現在のバーから　指定の時間を算出する
    int num = candle_bar_count;
	int nn=(num-1)-idx;
	return( 0-nn*timePerbar+ TimeCurrent());
	
}



int chgBarToidx(int num,int baridx){ // 作成データの０最新IDXから、全体のバーのIDXに変換する。　NUMは全体のバーの数
   if(num >baridx){
      return( (num-1)-baridx);
   }else{
      return(0);
   }
}
int chgidxToBar(int idx){ // chgBarToidxの逆。。　NUMは全体のバーの数
   if(idx <candle_bar_count){
      return( (candle_bar_count-1)-idx);
   }else{
      return(0);
   }
}

bool get_split_tick_name_idx(string &s,string &moji1,string &moji2,int &idx1,int &idx2,double &v1,double &v2){// オブジェクト名から種別とｉｄｘを取得する
//@Tick@KK@0000000@1111111@
//@moji1@moji2@num@num@

  string sep="@";               // 区切り文字 
  ushort u_sep;                 // 区切り文字のコード 
  string result[];               // 文字列を受け取る配列 
  //--- 区切り文字のコードを取得する 
  u_sep=StringGetCharacter(sep,0); 
  //--- 文字列を部分文字列に分ける 
  int k=StringSplit(s,u_sep,result);
  
//  string moji1;
//  string moji2;
//  int idx1,idx2;
  if(k >=7){
      moji1= result[1];
      moji2= result[2];
      idx1 = (int)StringToInteger(result[3]);
      idx2 = (int)StringToInteger(result[4]);    
      v1 = StringToDouble(result[5]);
      v2 = StringToDouble(result[6]);
  }
  if( StringCompare(moji1,"Tick") == 0 ){
      return true;
  }else {
      return false;
  } 
} 

#ifdef delll
void Move_object_Fractal(){//FD,FUを移動　Tickバーとベースの移動に合わせて移動用

   //対象探す。移動
//----
   int total;
   string name;
   string moji1,moji2;
   int idx1,idx2;
   double v1,v2;
   datetime t1,t2;

   total=ObjectsTotal(0,0,-1)-1;

    for(int numb=total; numb>=0 && !IsStopped(); numb--)
    {
        name=ObjectName(0,numb,0,-1);
        //sirname=StringSubstr(name,0,StringLen(UpLable_));
        bool ret = get_split_tick_name_idx(name,moji1,moji2,idx1,idx2,v1,v2);
        if (ret == true){
//         if((candle_bar_count - buffer_MAX) < idx1 ){//idxが（num- 指定の足数）　；　　よりも小さい場合は、削除する。
               t1= chgidxToTime(idx1,candle_bar_count);
               if(moji2 == "FD"|| moji2=="FU"|| moji2=="TT"){
                    if((candle_bar_count - buffer_MAX) < idx1 ){//idxが（num- 指定の足数）　；　　よりも小さい場合は、削除する
                        ObjectMove(0,name,0,t1,v1);
                    }else{
                        ObjectMove(0,name,0,t1,v1);
                    }
                  
               }else
               if(moji2=="LL"){
                   t2= chgidxToTime(idx2,candle_bar_count);
                    if((candle_bar_count - buffer_MAX) < idx2 ){//idxが（num- 指定の足数）　；　　よりも小さい場合は、削除する
                        ObjectMove(0,name,0,t1,v1);
                        ObjectMove(0,name,1,t2,v1);
                    }else{
                        ObjectDelete(0,name);
                    }
               }
               
               
               
//         }else{
//            ObjectDelete(0,name);
//         }
        }
      //if(sirname==UpLable_) ObjectDelete(0,name);
    }
//----
   ChartRedraw(0);   
}
#endif// delll

#ifdef commentdd
Fractalのデータの保存
	idx　TickBARのはじめが０としたid
	値、値（丸めあり）
	上下
#endif // commentdd	
struct struct_Fractal_data {
	int idx;//	idx　TickBARのはじめが０としたid
	double price;double price_marume;//値、値（丸めあり）
	int updn;//1,-1 //上下
};


#define FRACTAL_DATA_NUM	60000
int fractal_data_count;
struct_Fractal_data fractal_data[FRACTAL_DATA_NUM];
void init_fractal_data(){
	fractal_data_count = 0;
}


struct struct_SameLine_data {
	int idx1,idx2;//	idx　TickBARのはじめが０としたid
	double price1;double price2;//値（左）、値（右）
	int updn_bit;//-1,1 //抵抗線　（線の下に足）、支持線（線の上に足）
	    //ビットにする
	        //bit1:0
	        //フラクタルで
	        //    1抵抗線（線の下に足）、2支持線（線の上に足）、4同時
	        //足から調査
	        //    ８抵抗線（線の下に足）、１６支持線（線の上に足）、３２同時
	char updn_count[6];
	int doujipoint_count;//何個同時か（足のみ）
	int hyoukapoint;//評価点
};

#define SAMELINE_DATA_NUM 60000
int sameline_data_count;
int sameline_data_count_view;
struct_SameLine_data sameline_data[SAMELINE_DATA_NUM];
void init_sameline_data(){
	sameline_data_count = 0;
	sameline_data_count_view=0;
}
#ifdef commentdd
SameLineのデータ　//　Tickの足で同じ値でとまっているものを探す
	検索ルール：
		上と下を別々に探す
			クローズの値が対象
			対象はMAXバー
			恥の足を探し、そのセットを作る。上下
				２本をみて、支持線なら（　下足、上足or同時足（値０）
			そのセットから同じ値のものを探す。
				数をカウントする
			選択候補：点数化するか？　まずは全部
				現在足から近い
				たくさん止まっている（数が多い）
				フラクタルの実践も調査対象としたときに重なるものがある
		
	idx1,idx2
	値１＝値２
	備考：
		何個同時か（足のみ）
		抵抗線　（線の下に足）、支持線（線の上に足）
		評価点
SameLine２；　//　Fractalから同値線を探す　２点以上
	idx1,idx2
	値１＝値２
	備考：
		何個同時か（足のみ）
		抵抗線　（線の下に足）、支持線（線の上に足）
		評価点


スクイーズ：SQ
	



ラインを見つけるために
	UPorDNのみでの同値が重なる部分を探す。
	すべてから探す
スクイーズを探す
	①どっちかが並行で、一方がスクイーズ
	②UP－DNの間が小さくなっていくパターン
		フラッグ


Tick足の同値の判定
	ある足の範囲で探す
		Closeの値が対象。
		ひげがついているとなおよい
		
		同じ値が何件
#endif // commentdd
#define MAX_Search_NUM 300  //何本分を対象にデータさくせいするか（SameLine）　　option
int OnCalculate_Sameline(//同じ高さのラインを表示
//SL　idxが２つ　
                const int rates_total,    // amount of history in bars at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &Time[],
                const double &Open[],
                const double &High[],
                const double &Low[],
                const double &Close[]
//                const long &Tick_Volume[],
//                const long &Volume[],
//                const int &Spread[]
                )
  {
//---- checking the number of bars to be enough for calculation
   if(rates_total<min_rates_total) return(0);

//---- declaration of local variables 
   int limit;
   //bool   bFound;
   //double dCurrent;
   string stime;

//---- calculations of the necessary amount of data to be copied and
//the starting number limit for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      limit=rates_total-min_rates_total-3; // starting index for the calculation of all bars
     }
   else
     {
      if(rates_total==prev_calculated) return(rates_total);
      limit=rates_total-prev_calculated+1; // starting index for the calculation of new bars
     }

//---- indexing elements in arrays as timeseries  
//   ArraySetAsSeries(High,true);
//   ArraySetAsSeries(Low,true);
//   ArraySetAsSeries(Time,true);

//---- main indicator calculation loop
    int pre_samepoint_data_count=samepoint_data_count;
   for(int bar=1; bar<=limit-1 && !IsStopped(); bar++)
   {
      bool flag_find =false;
      int kind_updndouji = -99;
      if(chgidxToBar(bar)==93){
		bar = bar;
		}
		if(samepoint_data_count == 98){
		    bar=bar;
		}
      //double price=0.0;
      //端の足を探し、そのセットを作る。上下         
         //対象足と、前足の関係は？
				//２本をみて、支持線なら（　下足、上足or同時足（値０）
					//抵抗（上でとまる:線が上で足がした）
						//陰線
						//端の足判定：自分と前の足で前の足のCloseが自分のCloseより以下となっている
						if( Open[bar]>Open[bar+1]&& (Close[bar]<Open[bar])){
						   flag_find = true;
						   kind_updndouji = -1;
						}else
					//支持
						//陽線
						//端の足判定：自分と前の足で前の足のCloseが自分のCloseより以上となっている
						if(Open[bar]<Open[bar+1]&&(Close[bar]>Open[bar]) ){
						   flag_find = true;
						   kind_updndouji = 1;
						
						}else if(Close[bar]==Close[bar+1]){
						   //同じ高さ
						   flag_find = true;
						   kind_updndouji = 0;
						}
         //結果あれば登録処理（同じ値セット         
                          if(flag_find==true){
                            int kind=2;//足からの端の値なので
                             reg_samepoint( chgBarToidx( rates_total,bar),Open[bar],kind,kind_updndouji);
                          }
    
   }//for samepoint 
#ifdef debug_Line
	printf("##after make samepoint");
	printf("samepoint_data_count="+IntegerToString(samepoint_data_count));
#endif //	debug_Line   
    if(samepoint_data_count ==194 || samepoint_data_count==200){
        samepoint_data_count = samepoint_data_count;    
    }
    if(samepoint_data_count ==193 || samepoint_data_count==200-1){
        samepoint_data_count = samepoint_data_count;    
    }

    //同じ値（範囲付き考慮して）を探して、評価点つけて、格納する
    for(int i=0;i<samepoint_data_count;i++){
            #ifdef debug_Line
            	printf("i="+IntegerToString(i)+  "samepoint_data[i].idx1="+IntegerToString(samepoint_data[i].idx1)+"  ,price=" +DoubleToString(samepoint_data[i].price1));
            #endif //	debug_Line   
        //対象範囲か判定？
        if(samepoint_data[i].idx1 < (rates_total-MAX_Search_NUM)){
            #ifdef debug_Line
            	printf("continuei=  rates_total-MAX_Search_NUM    "+      IntegerToString(rates_total-MAX_Search_NUM)  );
            #endif //	debug_Line 
            continue;
        }
       
        //対象のデータの値段　tprice　からあたらしいSameLine引けるかを調査
        bool flag_sameline = false;
        double tprice = samepoint_data[i].price1;
        int tcount =0;//doujipoint_count
        int max_idx=0;//idx2
        int min_idx=0;//idx1
        int updn_bit=0;
        char updn_count[6]={0,0,0,0,0,0};
        int hyoukatenn=0;//hyoukapoint
        int k;
            //すでに調査済みの値か？
            bool flag_exist = false;
            for(k =0;k<sameline_data_count;k++){
                if(eq_price(sameline_data[k].price1,tprice)){
                    //flag_exist = true;break;
                }
            
            }
            if(flag_exist){
                //一つ分を考慮して更新が必要（評価点と数）
                //古いものを捨てれないのでこまるのでは？　最後に登録するときに」差し替えるイメージ（得点と数　idxはかえない
                continue;
            }            
        //SameLine の一つ分を作成    
        //    samepointからtpriceとあるものを探し出して、評点加えていく
        for(k =0;k<samepoint_data_count;k++){            
#ifdef debug_Line
	printf("k="+IntegerToString(k)+  "samepoint_data[k].idx1="+IntegerToString(samepoint_data[k].idx1));
#endif //	debug_Line   


            if(samepoint_data[k].idx1 < (rates_total-MAX_Search_NUM)  ||
                k==i ){
                continue;
            }

#ifdef debug_Line
	printf("     samepoint_data[k].price1,tprice"+DoubleToString(samepoint_data[k].price1)+"   ="+DoubleToString(tprice));
#endif //	debug_Line   


            //同一のものがあるか、あれば評価、SameLine対象へ
            if( eq_price(samepoint_data[k].price1,tprice) ){
#ifdef debug_Line
	printf("       ##Same == ");
#endif //	debug_Line   
                //同一データを発見
                if(tcount ==0){
                    max_idx = int_max(samepoint_data[k].idx1,samepoint_data[i].idx1);
                    min_idx = int_min(samepoint_data[k].idx1,samepoint_data[i].idx1);
                }
                max_idx = int_max(max_idx,samepoint_data[k].idx1);
                min_idx = int_min(min_idx,samepoint_data[k].idx1);
                tcount++;
                
                //評価点をつける
                if(samepoint_data[k].kind == 1 ){hyoukatenn=hyoukatenn+10;}else{hyoukatenn=hyoukatenn+2;}
                flag_sameline = true;
                //updn
                if(samepoint_data[k].kind == 2){ // 足からの端の値
                    if(samepoint_data[k].updn == -1){//抵抗線
                        updn_bit|=0x8;
                        updn_count[3]++;                     
                    }else if(samepoint_data[k].updn == 1){//支持箋
                        updn_bit|=0x10;
                        updn_count[4]++;                     
                    }else if(samepoint_data[k].updn == 0){//同時
                        updn_bit|=0x20;
                        updn_count[5]++;                     
                    }
                }else if(samepoint_data[k].kind == 1){//フラクタル
                    if(samepoint_data[k].updn == -1){//抵抗線
                        updn_bit|=0x1;
                        updn_count[0]++;
                    }else if(samepoint_data[k].updn == 1){//支持箋
                        updn_bit|=0x2;
                        updn_count[1]++;
                    }else if(samepoint_data[k].updn == 0){//同時
                        updn_bit|=0x4;
                        updn_count[2]++;
                    }
                
                
                }
            }
        }    
        //samelineデータを更新追加
        if(flag_sameline){
            //SameLineとして成立（範囲内に）
            //登録へ
            reg_SameLine(min_idx,max_idx,tprice,updn_bit,updn_count,tcount,hyoukatenn);
        }else{
            // 同じものがない
        }
        
    
    }// for make sameLine
    
    //データを表示する\\\


     
    
//----     
   ChartRedraw(0);
   return(rates_total);
}
struct struct_SamePoint_data {
	int idx1,idx2;//	idx　TickBARのはじめが０としたid 0が一番古い
	double price1;double price2;//値（左）、値（右）
	int updn;//-1,1 //抵抗線　（線の下に足）、支持線（線の上に足）　同時は０
	int kind;// １：フラクタル、２：足から調査した端
	int doujipoint_count;//何個同時か（足のみ）
	int hyoukapoint;//評価点
};
#define SAMEPOINT_DATA_NUM 600000

struct_SamePoint_data samepoint_data[SAMEPOINT_DATA_NUM];
int samepoint_data_count;
void init_samepoint_data(){
   samepoint_data_count=0;
}
void reg_fractal(int idx, double price,int kind,int updn){
	reg_org_samepoint( idx,  price,kind, updn);
}
void reg_samepoint(int idx, double price,int kind,int updn){
#ifdef USE_SAMEPOINT_CANDL
	reg_org_samepoint( idx,  price,kind, updn);
#endif
}

void reg_org_samepoint( int idx, double price,int kind,int updn){
   //同じ高さ、同じIDがあるかどうか調査
   //ないなら登録
   bool flag_find = false;
   for(int i=0;i<samepoint_data_count;i++){
      if(samepoint_data[i].idx1 == idx 
        && samepoint_data[i].price1==price 
        && samepoint_data[i].updn==updn 
        && samepoint_data[i].kind == kind){
         flag_find = true;
         break;
      }
   }
    if(flag_find == false){
        //登録
        samepoint_data[samepoint_data_count].idx1 = samepoint_data_count;//idx;
        samepoint_data[samepoint_data_count].price1=price;
        samepoint_data[samepoint_data_count].kind = kind;
        samepoint_data[samepoint_data_count].updn = updn;
        samepoint_data_count++;
        string strkind="DD";
        if(kind == 1){
			strkind= "TT";
		}else if(kind == 2){
			if(updn == -1){
				strkind= "FD";
			}else{
				strkind="FU";
			}
		}
        CreateArrowBuySell(0,
//            "@Tick@TT"+"@"+IntegerToString( idx )
//            "@Tick@"+strkind+"@"+IntegerToString( idx )
            "@Frc@"+strkind+"@"+IntegerToString( samepoint_data_count-1 )
               +"@0@"
               +DoubleToString( price) + "@0" 
//            ,0, chgidxToTime(idx),price,clrYellow ,nSize,chgidxToBar(idx),updn);
            ,0, chgidxToTime(idx),price,clrYellow ,nSize,chgidxToBar(idx),updn);
            
            
#ifdef debug_Line
	printf("reg_samepoint"+"    ""@Tick@TT"+"@"+IntegerToString( idx )
               +"@0@"
               +DoubleToString( price));
#endif //	debug_Line

            
    }

}
void reg_SameLine(int idx1,int idx2,double price,int updn_bit,char &updn_count[],int doujipoint_count,int hyoukapoint){
    //　同じ価格でラインがあるか確認。あれば上書き、なければ新規
    int i;bool flag_find = false;
    int t;
    for(i=0;i<sameline_data_count;i++){
        if(sameline_data[i].price1 == price){
            flag_find = true;
            break;
        }
    }
    if(flag_find){
        t=i;
        idx1=sameline_data[t].idx1;// 線の開始点は引き継ぐ
    }else{
        t=sameline_data_count;
        sameline_data_count++;
    }
    
    // 新規登録
        sameline_data[t].idx1 = idx1;
        sameline_data[t].idx2 = idx2;
        sameline_data[t].price1 = price;
        sameline_data[t].updn_bit = updn_bit;
        sameline_data[t].updn_count[0] = updn_count[0];
        sameline_data[t].updn_count[1] = updn_count[1];
        sameline_data[t].updn_count[2] = updn_count[2];
        sameline_data[t].updn_count[3] = updn_count[3];
        sameline_data[t].updn_count[4] = updn_count[4];
        sameline_data[t].updn_count[5] = updn_count[5];
    
    
        sameline_data[t].doujipoint_count = doujipoint_count;
        sameline_data[t].hyoukapoint = hyoukapoint;
}     
int int_min(int a,int b){
    int r;
    if(a>b){r=b;}else{r=a;}
    return r;
}         
int int_max(int a,int b){
    int r;
    if(a<b){r=b;}else{r=a;}
    return r;
}
bool eq_price(double a,double b){
    //デフォルトは１Pips
    return(eq_price(a,b,chgPips2price(1.0)));
}
bool eq_price(double a,double b,double d_seido_){// dseido 価格差の最小サイズ
    bool ret=false;
    double d=d_seido_;
    if(a==b){ret = true;}
    if((a+d)>b&&(a-d)<b){
        ret = true;
    }
    return ret;
}


void set_view_sameline(int n){
    for(int i = sameline_data_count_view;i<sameline_data_count;i++){
//        if( n-1-1 == sameline_data[i].idx2 ){// 確定足のidxに関係するものを表示
            SetSameLine(i);
//        }
    
    }
    sameline_data_count_view= sameline_data_count;
}
void SetSameLine(int sameline_idx){
	datetime t1;
	datetime t2;
	double p1;
	double p2;
	int istyle;
	int iwidth;
	string viewstring;
	int cColor;


    t1=chgidxToTime(sameline_data[sameline_idx].idx1);
    t2=chgidxToTime(sameline_data[sameline_idx].idx2);
    p1=sameline_data[sameline_idx].price1;p2=p1;

    
	istyle=STYLE_SOLID;
	iwidth=3;
	
    cColor = clrWhite;//
	string objname;
	objname = "@Tick@LL@"+IntegerToString(sameline_data[sameline_idx].idx1)+"@"+IntegerToString((sameline_data[sameline_idx].idx2))
    	+"@"+DoubleToString(p1,5)
    	+"@"+DoubleToString(p2,5)
    	+"@"+ PeriodToString(_Period)
    	;
	
    viewstring = "SAMELINE";

	//PeriodToString(_Period)+"_op="+IntegerToString(option) +"_K"+IntegerToString(Sn.NoOfZ)+"_" // +DoubleToString(p1)
	//+"_"+TimeToString(t1)+"snidx="+IntegerToString(sn_idx)+"_"+key_name_prefix+kind_name;

	SetTline(
	        0,//      long     chart_id,  // chart ID
	        objname,//      string   name,      // object name
	        0,//      int      nwin,      // window index
	        t1,//      datetime time1,     // price level time 1
	        p1,//      double   price1,    // price level 1
	        t2,//      datetime time2,     // price level time 2
	        p2,//      double   price2,    // price level 2
	        cColor,//      color    Color,     // line color
	        istyle,//      int      style,     // line style
	        iwidth,//      int      width,     // line width
	        viewstring//      string   text)      // text
	);


}


