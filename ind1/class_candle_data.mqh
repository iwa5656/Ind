#ifndef class_candle_data
#define class_candle_data

#include <_inc\\My_function_lib2.mqh>
//#include "class_allcandle.mqh"
#include ".\Fractals\Fractals_Input.mqh"
//--- input parameters
#ifndef ZigzagInputPara
#define ZigzagInputPara
input int InpDepth    =12;
input int InpDeviation=5;
input int InpBackstep =3;
int ExtRecalc=3; // recounting's depth
enum EnSearchMode
  {
   Peak=1,    // searching for the next ZigZag peak
   Bottom=-1  // searching for the next ZigZag bottom
  };
#endif//ZigzagInputPara
	struct struct_pt_range{
		int pt_range_status;//有効1、無効0
		int idx;//基準zigzag idx
		double pt_renge_upper_value;
		double pt_range_down_value;
		double pt_range_distance_updown_value;
		double pt_range_distance_updown_pips;
		int pt_range_position_first;// 基準１の位置が上か下か？上のほう１：　下のほう-1
	};
	struct struct_pt_flag{
		int pt_flag_status;//有効1、無効0
		int idx;//基準zigzag idx
		double pt_flag_UPLN_katamuki;
		double pt_flag_UPLN_seppen;
		double pt_flag_UPLN_start_zigzag_idx;
		double pt_flag_UPLN_end_zigzag_idx;

		double pt_flag_DNLN_katamuki;
		double pt_flag_DNLN_seppen;
		double pt_flag_DNLN_start_zigzag_idx;
		double pt_flag_DNLN_end_zigzag_idx;
		
		
		double pt_flag_upper_value;
		double pt_flag_down_value;
		double pt_flag_distance_updown_value;
		double pt_flag_distance_updown_pips;
		int pt_flag_position_first;// 基準１の位置が上か下か？上のほう１：　下のほう-1
	};	
	struct struct_pt_sup{
		int pt_sup_status;//有効1、無効0
		int idx;//基準zigzag idx
		//フラッグ用
			double pt_sup_upper_value;
			double pt_sup_down_value;
			double pt_sup_distance_updown_value;
			double pt_sup_distance_updown_pips;
			int pt_sup_position_first;// 基準１の位置が上か下か？上のほう１：　下のほう-1
		//支える形用
			double		pt_sup_line_4_y;//4
			datetime	pt_sup_line_4_x;
			double		pt_sup_line_6_y;//6
			datetime	pt_sup_line_6_x;

			double		pt_sup_ma;
			double		pt_sup_ma_kiri_ritu;
			double		pt_sup_ma_katamuki;
			double		pt_sup_6_4_line_price;
			double		pt_sup_3_price;
			double		pt_sup_5_price;
			double		pt_sup_2_1_dist;
			double		pt_sup_2_1_dist_pips;
			int 		pt_sup_updn;//1up , -1dn

			//int pt_sup_position_first;// 基準１の位置が上か下か？上のほう１：　下のほう-1
		//add 20200531
		int pt_kind;//0:flag　1:支える形
	};	
	//目線データ
	struct struct_mesen_C{
		int dir;//1上、-1下方向, 0無効
		int no;// Zigzag count.　ラインの右側（新しい時間の点のもの）
		double up;//上のライン　価格
		double dn;//下のライン　価格
	};	
	
	
	
class candle_data
{
public:
    //allcandle *m_allcandle;
    void *m_allcandle;

	//--- コンストラクタとデストラクタ
	candle_data(ENUM_TIMEFRAMES p){
//	candle_data(ENUM_TIMEFRAMES p,allcandle *parent){
//	candle_data(ENUM_TIMEFRAMES p,void *parent){
	    //m_allcandle = parent;
	    period = p;candle_bar_count=0;zigzagdata_count=0;new_bar_flag=false;
	    sma_make_handle(20, handle_sma_20);sma_make_handle(8,handle_sma_8);
	   };
	~candle_data(void){
	   // ((allcandle*) m_allcandle).rest_new_bar_flag();
	 };
	//--- オブジェクトを初期化する
    
    //データ
        //SMA
        int handle_sma_8;
        int handle_sma_20;
        //zigzag
        #define ZIGZAG_BUFFER_MAX_NUM 300
        #define CANDLE_BUFFER_MAX_NUM ZIGZAG_BUFFER_MAX_NUM
		#define NUM_YOBI_ZIGZAG_MEM 3000 // Mem予備
        //#define ZIGZAG_MAX_NUM 600000			
        struct struct_zigzagdata{
        	double	value;
        	datetime time;
        	int kind;		//peak 1 , bottom -1
        	int idx;		// 格納されているidx
        	
        	//頂点info
        	//ボリンジャー
        	double ma_20_sma;
        	double ma_20_sma_katamuki;
        	double ma_kairi;
        	double b_sig3updn_pips;
        	double b_sig3updn_dist;
        	double b_sig;
        	double b_3sig_up;
        	double b_2sig_up;
        	double b_1sig_up;
        	double b_3sig_dn;
        	double b_2sig_dn;
        	double b_1sig_dn;
        	
        	//目線
        	struct_mesen_C mesen;
        };
    	ENUM_TIMEFRAMES period;
    	bool new_bar_flag;
        double ZigzagPeakBuffer[CANDLE_BUFFER_MAX_NUM];// idx 0が古い想定
        double ZigzagBottomBuffer[CANDLE_BUFFER_MAX_NUM];// idx 0が古い想定
        double ZigzagHighMapBuffer[CANDLE_BUFFER_MAX_NUM];// idx 0が古い想定
        double ZigzagLowMapBuffer[CANDLE_BUFFER_MAX_NUM];// idx 0が古い想定
        double ZigzagColorBuffer[CANDLE_BUFFER_MAX_NUM];// idx 0が古い想定
        int candle_bar_count;//zigzag_open close high
        datetime time[CANDLE_BUFFER_MAX_NUM];// idx 0が古い想定
        double open[CANDLE_BUFFER_MAX_NUM];// idx 0が古い想定
        double close[CANDLE_BUFFER_MAX_NUM];// idx 0が古い想定
        double high[CANDLE_BUFFER_MAX_NUM];// idx 0が古い想定
        double low[CANDLE_BUFFER_MAX_NUM];// idx 0が古い想定
        
        //前回算出したラストと異なるなら変更または追加処理候補とする/
        //さらに最後に格納したものとずれているか確認し追加変更する。
        //最後にデータ格納したラストの値
        	double setlast_peak_value;//　最後に格納したものを記憶
        	datetime setlast_peak_time;//　最後に格納したものを記憶
        	double setlast_bottom_value;//　最後に格納したものを記憶
        	datetime setlast_bottom_time;//　最後に格納したものを記憶
        	int setlast_data_kind;// 1peak -1bottom  左記以外初期値　　　最後の種別記憶
        //Zigzag格納用データ
        struct_zigzagdata zigzagdata[];//Zigzag格納用データ
        int zigzagdata_count;	//Zigzag格納用データの数
	    bool zigzag_chg_flag;// new bar 時にリセット
        //ラストのpeakとbottomを記憶しておく
        //記憶は値と、時間
        //今回求めた値(ないなら０)　初期化は計算する前
        double calclast_peak_value;//初期値０
        datetime calclast_peak_time;//初期値０
        double calclast_bottom_value;//初期値０
        datetime calclast_bottom_time;//初期値０
        double get_now_price(){
			return(close[CANDLE_BUFFER_MAX_NUM-1]);
		}
		datetime get_now_time(){
			return(time[CANDLE_BUFFER_MAX_NUM-1]);
		}

		//目線データ
//		struct struct_mesen_C{
//			int dir;//1上、-1下方向, 0無効
//			int no;// Zigzag count.　ラインの右側（新しい時間の点のもの）
//			double up;//上のライン　価格
//			double dn;//下のライン　価格
//		};
		int pre_zigzagdata_count_mesen_C;
		int count_mesen_C;//目線注目辺の数（辺右の点）
		int zigzag_mesen_chg_at_count_mesen_C;//目線が変化したZigzag　カウント（idではない。数）（辺右の点）
		
	
	//I/F
	bool add_new_bar    (
        datetime &now_bar_time// 
    );
    int  Oncalculate_ZIGZAG(void);
    int  Oncalculate_Fractals(void);
    void OnDeinit(const int reason);
    void Oninit(void);
    
    void addzigzagdata(string s,int k,double &v,datetime &t);
    void chgzigzagdata(string s,int k,double &pre_v,datetime &pre_t,double &v,datetime &t);
    void into_Zigzagdata(
		int regIsChg,// chg true,add false
		double &v,
		datetime &t,
		int &k// k 1:peak -1:bottom
	);
    void clean_up_arrays_zigzag(void);
    
    void view_zigzag_Zi_line(
    	int &idx1,
    	int &regIsChg // falseならAddのみ,trueは変更
    );
    void del_view_zigzag_Zi_line(
    	int &idx1,
    	int &idx2
    );
    void zigzagSetOtherInfo(int insert_idx,datetime t, double v);    
    int GetTimeColor(ENUM_TIMEFRAMES period);
    void set_zigzag_Zi_line(	int &idx1,	int &idx2);
	double Highest(const double&array[],int count,int start);
	double Lowest(const double&array[],int count,int start);
	string make_zig_objectname(		ENUM_TIMEFRAMES &period,		int idx1,		int idx2		);
	bool get_split_zig_objectname(	string &s,	ENUM_TIMEFRAMES &period,	int &idx1,	int &idx2);



    bool get_zigzagdata(
    	ENUM_TIMEFRAMES &period,
    	int &idx,
    	double &v,
    	datetime &t,
    	int &k,
    	int &count
    );
    void SetTline(long     chart_id,  // chart ID
                  string   name,      // object name
                  int      nwin,      // window index
                  datetime time1,     // price level time 1
                  double   price1,    // price level 1
                  datetime time2,     // price level time 2
                  double   price2,    // price level 2
                  color    Color,     // line color
                  int      style,     // line style
                  int      width,     // line width
                  string   text)      // text
    ;
    void CreateTline(long     chart_id,  // chart ID
                     string   name,      // object name
                     int      nwin,      // window index
                     datetime time1,     // price level time 1
                     double   price1,    // price level 1
                     datetime time2,     // price level time 2
                     double   price2,    // price level 2
                     color    Color,     // line color
                     int      style,     // line style
                     int      width,     // line width
                     string   text)      // text
    ;
    bool get_new_bar_flag(void){return(new_bar_flag);};
    bool set_new_bar_flag(bool f){new_bar_flag = f;return true;};
    //sma
    void sma_make_handle(int mm,int &handle);//handle_sma作成
    bool sma_get_katamuki_now(int handle,double &katamuki,datetime &t);
    bool sma_get_value_now(int handle,double &ma,datetime &t);
    void calc_kakutei(){
        calc_pt_range();
        calc_pt_flag();
        calc_pt_sup();
    }
	double ZigX(int inp_idx){// 単位は秒数のdatetime
	    int base_idx = zigzagdata_count-1;
		if(base_idx < 0){
			return 0;//error
		}		
		int idx1 = chgKijun2Idx(base_idx,inp_idx);
	    //bool ret = false;
	    double v1,v2;
	    datetime t1,t2;
	    int k1,k2;
	    int c1,c2;//最大数
	    bool bret1;
	    bret1=get_zigzagdata(period,idx1,v1,t1,k1,c1);
	    if(bret1==false){
			v1=0;t1=0;k1=0;c1=0;
		}
	    return((double)t1);
	    //return(ret);
	}
	double ZigY(int inp_idx){// 単位はPrice
	    int base_idx = zigzagdata_count-1;
		if(base_idx < 0){
			return 0;//error
		}		
		int idx1 = chgKijun2Idx(base_idx,inp_idx);
	    //bool ret = false;
	    double v1,v2;
	    datetime t1,t2;
	    int k1,k2;
	    int c1,c2;//最大数
	    bool bret1;
	    bret1=get_zigzagdata(period,idx1,v1,t1,k1,c1);
	    if(bret1==false){
			v1=0;t1=0;k1=0;c1=0;
		}
	    return(v1);
	    //return(ret);
	}
	datetime Zigtime(int inp_idx){// 単位は秒数のPrice
	    int base_idx = zigzagdata_count-1;
		if(base_idx < 0){
			return 0;//error
		}		
		int idx1 = chgKijun2Idx(base_idx,inp_idx);
	    //bool ret = false;
	    double v1,v2;
	    datetime t1,t2;
	    int k1,k2;
	    int c1,c2;//最大数
	    bool bret1;
	    bret1=get_zigzagdata(period,idx1,v1,t1,k1,c1);
	    if(bret1==false){
			v1=0;t1=0;k1=0;c1=0;
		}
	    return(t1);
	    //return(ret);
	}	
	double ZigUD(int inp_idx){// //peak 1 , bottom -1
	    int base_idx = zigzagdata_count-1;//debug 20200516 時間軸指定しなくてもよいか？
		if(base_idx < 0){
			return 0;//error
		}		
		int idx1 = chgKijun2Idx(base_idx,inp_idx);
	    //bool ret = false;
	    double v1,v2;
	    datetime t1,t2;
	    int k1,k2;
	    int c1,c2;//最大数
	    bool bret1;
	    bret1=get_zigzagdata(period,idx1,v1,t1,k1,c1);
	    if(bret1==false){
			v1=0;t1=0;k1=0;c1=0;
		}
	    return(k1);
	    //return(ret);
	}
	//Mem関連
	void init_mem_zigzagdata(void){
//		int i=0;
//		ArrayResize(zigzagdata,zigzagdata_count+1);
//		i=sizeof(zigzagdata);printf("zigzagdata 1   :sizeof="+IntegerToString(i));
		ArrayResize(zigzagdata,zigzagdata_count+1,NUM_YOBI_ZIGZAG_MEM);
//		i=sizeof(zigzagdata[0]);printf("zigzagdata yobi:sizeof="+IntegerToString(i));
	}
	void chk_mem_zigzagdata(int i){
		int m=zigzagdata_count;
		if(zigzagdata_count < i){
			m=i+1;
		}
		ArrayResize(zigzagdata,i,NUM_YOBI_ZIGZAG_MEM);
	}
	//目線関連
	void init_mesen_C(void){
		pre_zigzagdata_count_mesen_C = 0;
		count_mesen_C=0;
		zigzag_mesen_chg_at_count_mesen_C=0;
		for(int i=0;i< zigzagdata_count;i++){//chg mem
			zigzagdata[i].mesen.dir = 0;
		}
		
	}
	bool get_mesen_Cn(int n,struct_mesen_C &cn){
		bool ret = false;
		int finded_count = 0;
		int id = 0;
		if(zigzagdata_count ==0 ){return false;}
		
		for(int i = zigzagdata_count-1;i>0;i--){
			if(zigzagdata[i].mesen.dir !=0){
				if(finded_count == n){
					ret = true;
					id = i;
					cn.dir = zigzagdata[i].mesen.dir;
					cn.up = zigzagdata[i].mesen.up;
					cn.dn = zigzagdata[i].mesen.dn;
					cn.no = zigzagdata[i].mesen.no;
					
					break;
				}else{
					finded_count++;
				}
			}
		}
		return ret;
	}
	//n個目の目線切り替わりのCnを取得する（続伸Cnをのぞく）
	//nは０が直近のCn
	bool get_mesen_Cn_kirikawariCn(int n,struct_mesen_C &cn){
		bool ret = false;
		int finded_count = 0;
		int id = 0;
		if(zigzagdata_count ==0 ){return false;}

		//前後のCnを見る、切り替わりありなら見つけた
		//最新→-1  1 1 1 1 1 -1 
        //      a         a
		//	  見ているものCn　　Cn-1で切り替わりありならCnが対象 
		for(int i = zigzagdata_count-1;i>1;i--){
			if(zigzagdata[i].mesen.dir !=0 ){
			    bool b_find_k=false;
			    int k=0;
			    for(k=i-1;k>0;k--){
			        if(zigzagdata[k].mesen.dir != 0){
			            b_find_k = true;
			            break;
			        }
			    }
				if(b_find_k == true && zigzagdata[i].mesen.dir != zigzagdata[k].mesen.dir ){
    				if(finded_count == n){
    					ret = true;
    					id = i;
    					cn.dir = zigzagdata[i].mesen.dir;
    					cn.up = zigzagdata[i].mesen.up;
    					cn.dn = zigzagdata[i].mesen.dn;
    					cn.no = zigzagdata[i].mesen.no;
    					
    					break;
    				}else{
    					finded_count++;
    				}
    			}
			}
		}
		return ret;
	}
	//Zigzag目線の更新処理、Zig目線フラグの更新
	void calc_mesen_C(void){
		bool flag_mesen_chg = false;//目線が変わった時True
		bool flag_mesen_zokushin = false;//　続伸したとき
		
		int now_zigzagcount = zigzagdata_count;
		if( now_zigzagcount <4){ return;}
		
		
		double y0=ZigY(1);
		double y1=ZigY(2);
		if(count_mesen_C == 0){//　初回のみ実行部分（仮のCnを入れておく）
			if(y0>y1){
				zigzagdata[now_zigzagcount-1].mesen.dir = 1;
				zigzagdata[now_zigzagcount-1].mesen.up = y0;
				zigzagdata[now_zigzagcount-1].mesen.dn = y1;
			}else{
				zigzagdata[now_zigzagcount-1].mesen.dir = -1;
				zigzagdata[now_zigzagcount-1].mesen.up = y1;
				zigzagdata[now_zigzagcount-1].mesen.dn = y0;
			}
			zigzagdata[now_zigzagcount-1].mesen.no = zigzagdata_count;
			count_mesen_C++;
			//前回値の更新
			pre_zigzagdata_count_mesen_C =zigzagdata_count;
			return;
		}
		
		//注目辺cの取得
		struct_mesen_C c0;
		if(get_mesen_Cn(0,c0)==false){return;}
		//確認
		if(c0.dir == 1){// 目線が上方向
			if(c0.dn > y0){//目線変化あり？
				// 上から下に目線切り替わりした
				zigzagdata[now_zigzagcount-1].mesen.up = y1;
				zigzagdata[now_zigzagcount-1].mesen.dn = y0;
				zigzagdata[now_zigzagcount-1].mesen.no = now_zigzagcount;
				
				if(zigzagdata[now_zigzagcount-1].mesen.dir == 0 ){
					zigzagdata[now_zigzagcount-1].mesen.dir = -1;
					count_mesen_C++;
				}
				flag_mesen_chg=true;
			}else if ( c0.up < y0 ){// 続伸
				zigzagdata[now_zigzagcount-1].mesen.up = y0;
				zigzagdata[now_zigzagcount-1].mesen.dn = y1;
				zigzagdata[now_zigzagcount-1].mesen.no = now_zigzagcount;
				if(c0.no != now_zigzagcount){
					flag_mesen_zokushin =true;
				}
				if(zigzagdata[now_zigzagcount-1].mesen.dir == 0 ){
					zigzagdata[now_zigzagcount-1].mesen.dir = 1;
					count_mesen_C++;
				}
				
			}
			
		}else if(c0.dir == -1){// 目線が下目線方向
			if(c0.up <y0){
				//下から上に目線切り替わりした
				zigzagdata[now_zigzagcount-1].mesen.up = y0;
				zigzagdata[now_zigzagcount-1].mesen.dn = y1;
				zigzagdata[now_zigzagcount-1].mesen.no = now_zigzagcount;
				if(zigzagdata[now_zigzagcount-1].mesen.dir == 0 ){
					zigzagdata[now_zigzagcount-1].mesen.dir = 1;
					count_mesen_C++;
				}
				flag_mesen_chg=true;
			}else if ( c0.dn > y0 ){// 続伸した？
				zigzagdata[now_zigzagcount-1].mesen.up = y1;
				zigzagdata[now_zigzagcount-1].mesen.dn = y0;
				zigzagdata[now_zigzagcount-1].mesen.no = now_zigzagcount;
				if(c0.no != now_zigzagcount){
					flag_mesen_zokushin =true;
				}
				if(zigzagdata[now_zigzagcount-1].mesen.dir == 0 ){
					zigzagdata[now_zigzagcount-1].mesen.dir = -1;
					count_mesen_C++;
				}
				
			}
		}

		if(now_zigzagcount != zigzag_mesen_chg_at_count_mesen_C){
			// 以前通知したものと異なるなら、変化ありとする。
				// フラグの有効にするのは、Cnの数がXX以上になってからとする（初回が仮なので、間違っている可能性あり）
			if(count_mesen_C > 2){// xx=6
				
				if(flag_mesen_chg == true){
					printf("「"+PeriodToString(period)+";"+IntegerToString(zigzagdata[now_zigzagcount-1].mesen.dir+"」"));
				    zigzag_mesen_chg_at_count_mesen_C= now_zigzagcount;
				}
				if(flag_mesen_zokushin == true){
					printf("「"+PeriodToString(period)+";"+"続伸"+"」");
					zigzag_mesen_chg_at_count_mesen_C= now_zigzagcount;
					
				}
			}
			
		}

		//前回値の更新
		pre_zigzagdata_count_mesen_C =zigzagdata_count;
	}
	bool isNegativeBar(int n){// 陰線だったらtrue
		bool ret = false;
		if(candle_bar_count < n){return ret;}
		if(close[n]<open[n]){ret = true;}
		return ret;
	}
	bool isPositiveBar(int n){// 陽線だったらtrue
		bool ret = false;
		if(candle_bar_count < n){return ret;}
		if(close[n]>open[n]){ret = true;}
		return ret;
	}
	int state_bar(int n){
		if(isNegativeBar(n)){return -1;}
		if(isPositiveBar(n)){return 1;}
		return 0;
	}	
	bool chk_DD(int n, int &dir,double &a,double &b,double &c,double &now_v,datetime &now_time,datetime &next_kakutei_time){
		bool ret = false;
		int houkou=0;//エントリー方向
		int count=0;//連続何回？
		int serch_idx = 0;
		if(candle_bar_count < n){return ret;}
		//　ue shita -> 下の形
			// ue(ひげ)　shita -> 下の形
		if(state_bar(1)==1 && state_bar(0)==-1){
			houkou = -1;
			serch_idx=2;
		}
		// ue  jyuuji  sita ->下の形
		if(state_bar(2)==1 &&state_bar(1)==0 && state_bar(0)==-1){
			houkou = -1;
			serch_idx=3;
		}

		if(state_bar(1)==-1 && state_bar(0)==1){
			houkou = 1;
			serch_idx=2;
		}
		if(state_bar(2)==-1 &&state_bar(1)==0 && state_bar(0)==1){
			houkou = 1;
			serch_idx=3;
		}
		if(houkou !=0){
			count = 1;
			int i;
			for(i=serch_idx;i<CANDLE_BUFFER_MAX_NUM;i++){
				if(state_bar(serch_idx) ==	serch_idx*(-1) ){//同じ方向かの調査
					count++;
					if(count>= n){
						ret = true;
					}
				}else{
					// 異なる方向が見つかった
					break;
				}


			}
			if(ret == true && i!=CANDLE_BUFFER_MAX_NUM){// n回以上連続
				dir = houkou;
				a = MathAbs(close[1]-close[i]);// 全長
				b = MathAbs(close[1]-close[0]);//　現在値とトップの距離
				c = MathAbs(close[i]-close[0]);//　点在位置と全長起点との距離
				now_v = close[0];
				now_time = time[0];
				next_kakutei_time = now_time + PeriodSeconds(period);
			}

		}


		
		return ret;
	}


bool chk_mesen_C_zigcount_updn(int zigcount,int &out_dir){
// Cnが変化したものが、Zigcountと会えば　True
// 方向を返す。該当しないときは０　　上１　下-1
	bool ret=false;
	bool r=false;bool rr=false;
	struct_mesen_C c0;
	struct_mesen_C c1;
	struct_mesen_C d2;
    r=get_mesen_Cn(0,c0);
    rr=get_mesen_Cn(1,c1);
	out_dir=0;//default
	
	if(r==true&&rr==true){
	if(c0.no == 79 ){
	    r=r;
	}
	if(c0.no == 80 ){
	    rr=rr;
	}


		if(c0.dir !=c1.dir){
			if(c0.no  == zigcount){
				// 変化したCnが現在Zigだった
				ret = true;
				out_dir = c0.dir;
			}
		}
	}
	return(ret);
}	


//	double MAprice(int period,ENUM_MA_METHOD mode);//MODE_SMA,単純平均。,MODE_EMA,指数移動平均。,MODE_SMMA,平滑平均。,MODE_LWMA,線形加重移動平均。
	#include ".\candle_cal\cal_MA\cal_MA_function.mqh"
    
    #include ".\Fractals\Fractals_function.mqh"
    #include ".\Lib\lib_pattern_func.mqh"
    #include ".\candle_pattern\pt_range.mqh"
    #include ".\candle_pattern\pt_flag.mqh"
    #include ".\candle_pattern\pt_sup.mqh"

};
void candle_data::OnDeinit(const int reason){
    OnDeinit_Fractals(reason);
}
void candle_data::Oninit(void){
       zigzagdata_count=0;
	   init_mem_zigzagdata();
       candle_bar_count = 0;
       OnInit_Fractals();
       init_pt_range();
       init_mesen_C();
}
bool candle_data::add_new_bar(datetime &now_bar_time){
    bool ret=true;
    datetime new_bar_time;
    double new_bar_open;
    double new_bar_close;
    double new_bar_high;
    double new_bar_low;
    
    zigzag_chg_flag=false;// リセットしておく
            int error_count = 0;
            datetime times[];
            int ret1;
    		ret1 = (CopyTime(_Symbol,(ENUM_TIMEFRAMES)period,(datetime)now_bar_time,(int)2,times));// idx 0 が古い　１が最新
    		if(ret1 <2){
    		    printf("error not get timedata");
    		    error_count+=1;
    		}
            double opens[],closes[],highs[],lows[];
    		ret1 = (CopyOpen(_Symbol,(ENUM_TIMEFRAMES)period,(datetime)now_bar_time,(int)2,opens));
    		if(ret1 <2){
    		    printf("error not get opendata");
    		    error_count+=10;
    		}
    		ret1 = (CopyClose(_Symbol,(ENUM_TIMEFRAMES)period,(datetime)now_bar_time,(int)2,closes));
    		if(ret1 <2){
    		    printf("error not get closedata");
    		    error_count+=100;
    		}
    		ret1 = (CopyHigh(_Symbol,(ENUM_TIMEFRAMES)period,(datetime)now_bar_time,(int)2,highs));
    		if(ret1 <2){
    		    printf("error not get highdata");
    		    error_count+=1000;
    		}
    		ret1 = (CopyLow(_Symbol,(ENUM_TIMEFRAMES)period,(datetime)now_bar_time,(int)2,lows));
    		if(ret1 <2){
    		    printf("error not get lowdata at candle_data::add_new_bar");
    		    error_count+=10000;
    		}
            if(error_count > 0){
                ret = false;
                return(ret);
            }else{// copyLowなどは１０分のものを２つほしいというと９分と8分の確定足が来る-> 　

#ifdef chg_saisinn_asi
                new_bar_time=times[1];
                new_bar_open=opens[1];
                new_bar_close=closes[1];
                new_bar_high=highs[1];
                new_bar_low=lows[1];
#endif
                new_bar_time=times[0];
                new_bar_open=opens[0];
                new_bar_close=closes[0];
                new_bar_high=highs[0];
                new_bar_low=lows[0];
            }

//    if(count >= CANDLE_BUFFER_MAX_NUM){
        //左に一つずらして入れる　
//        for(int i = 1 ;i<CANDLE_BUFFER_MAX_NUM-1;i++){//countは確定足の数なので、未確定足が一つある 未確定はずらさない->確定足の未格納とする
        for(int i = 1 ;i<CANDLE_BUFFER_MAX_NUM;i++){//countは確定足の数なので、未確定足が一つある 未確定はずらさない->確定足の未格納とする
            ZigzagPeakBuffer[i-1]=ZigzagPeakBuffer[i];
            ZigzagBottomBuffer[i-1]=ZigzagBottomBuffer[i];
            ZigzagHighMapBuffer[i-1]=ZigzagHighMapBuffer[i];
            ZigzagLowMapBuffer[i-1]=ZigzagLowMapBuffer[i];
            ZigzagColorBuffer[i-1]=ZigzagColorBuffer[i];
            time[i-1]=time[i];
            open[i-1]=open[i];
            close[i-1]=close[i];
            high[i-1]=high[i];
            low[i-1]=low[i];        
        }

        //入れる　１
        time[CANDLE_BUFFER_MAX_NUM-1]=new_bar_time;//　一つ前の確立時に時間が入っているはず
        open[CANDLE_BUFFER_MAX_NUM-1]=new_bar_open;
        close[CANDLE_BUFFER_MAX_NUM-1]=new_bar_close;
        high[CANDLE_BUFFER_MAX_NUM-1]=new_bar_high;
        low[CANDLE_BUFFER_MAX_NUM-1]=new_bar_low;
        //printf(TimeToString(new_bar_time));
        if(candle_bar_count<CANDLE_BUFFER_MAX_NUM){candle_bar_count++;}
	return ret;
}



int candle_data::Oncalculate_ZIGZAG(void){
    int ret=CANDLE_BUFFER_MAX_NUM-1;
    int rates_total=CANDLE_BUFFER_MAX_NUM;
    int prev_calculated=CANDLE_BUFFER_MAX_NUM-1;


   int i,limit=0;
//--- check for rates count
   if(rates_total<100)
     {
      //--- clean up arrays
      //ArrayInitialize(ZigzagPeakBuffer,0.0);
      //ArrayInitialize(ZigzagBottomBuffer,0.0);
      //ArrayInitialize(HighMapBuffer,0.0);
      //ArrayInitialize(LowMapBuffer,0.0);
      //ArrayInitialize(ColorBuffer,0.0);
      clean_up_arrays_zigzag();
      //--- exit with zero result
      return(0);
     }
//--- preliminary calculations
   int extreme_counter=0,extreme_search=0;
   int shift,back=0,last_high_pos=0,last_low_pos=0;
   double val=0,res=0;
   double cur_low=0,cur_high=0,last_high=0,last_low=0;
//--- initializing
   if(prev_calculated==0)
     {
      //ArrayInitialize(ZigzagPeakBuffer,0.0);
      //ArrayInitialize(ZigzagBottomBuffer,0.0);
      //ArrayInitialize(HighMapBuffer,0.0);
      //ArrayInitialize(LowMapBuffer,0.0);
      clean_up_arrays_zigzag();
      //--- start calculation from bar number InpDepth
      limit=InpDepth-1;
     }
//--- ZigZag was already calculated before
   if(prev_calculated>0)
     {
      i=rates_total-1;
      //--- searching for the third extremum from the last uncompleted bar
      while(extreme_counter<ExtRecalc && i>rates_total -100)
        {
         res=(ZigzagPeakBuffer[i]+ZigzagBottomBuffer[i]);//新しいほうから値あるものを３つ探す　そのiを使用         
         //---
         if(res!=0)
            extreme_counter++;
         i--;
        }
      i++;
      limit=i;
      //--- what type of exremum we search for
      if(ZigzagLowMapBuffer[i]!=0)
        {
         cur_low=ZigzagLowMapBuffer[i];
         extreme_search=Peak;
        }
      else
        {
         cur_high=ZigzagHighMapBuffer[i];
         extreme_search=Bottom;
        }
      //--- clear indicator values
      for(i=limit+1; i<rates_total && !IsStopped(); i++)//　いったん描画用データを削除
        {
         ZigzagPeakBuffer[i]  =0.0;
         ZigzagBottomBuffer[i]=0.0;
         ZigzagLowMapBuffer[i]      =0.0;
         ZigzagHighMapBuffer[i]     =0.0;
        }
     }
//--- searching for high and low extremes
   for(shift=limit; shift<rates_total && !IsStopped(); shift++)
     {
      //--- low
      val=Lowest(low,InpDepth,shift);
      if(val==last_low)
         val=0.0;
      else
        {
         last_low=val;
         if((low[shift]-val)>(InpDeviation*_Point))
            val=0.0;
         else
           {
            for(back=InpBackstep; back>=1; back--)
              {
               res=ZigzagLowMapBuffer[shift-back];
               //---
               if((res!=0) && (res>val))
                  ZigzagLowMapBuffer[shift-back]=0.0;
              }
           }
        }
      if(low[shift]==val)
         ZigzagLowMapBuffer[shift]=val;
      else
         ZigzagLowMapBuffer[shift]=0.0;
      //--- high
      val=Highest(high,InpDepth,shift);
      if(val==last_high)
         val=0.0;
      else
        {
         last_high=val;
         if((val-high[shift])>(InpDeviation*_Point))
            val=0.0;
         else
           {
            for(back=InpBackstep; back>=1; back--)
              {
               res=ZigzagHighMapBuffer[shift-back];
               //---
               if((res!=0) && (res<val))
                  ZigzagHighMapBuffer[shift-back]=0.0;
              }
           }
        }
      if(high[shift]==val)
         ZigzagHighMapBuffer[shift]=val;
      else
         ZigzagHighMapBuffer[shift]=0.0;
     }
//--- set last values
   if(extreme_search==0) // undefined values
     {
      last_low=0;
      last_high=0;
     }
   else
     {
      last_low=cur_low;
      last_high=cur_high;
     }
//--- final selection of extreme points for ZigZag
#ifdef  USE_debug_zigzag
                printf("↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓");
#endif//USE_debug_zigzag  
	calclast_peak_value=0;calclast_peak_time=0;calclast_bottom_value=0;calclast_bottom_time=0;
   for(shift=limit; shift<rates_total && !IsStopped(); shift++)
     {
      res=0.0;
      switch(extreme_search)
        {
         case 0: // search for an extremum
            if(last_low==0 && last_high==0)
              {
               if(ZigzagHighMapBuffer[shift]!=0)
                 {
                  last_high=high[shift];
                  last_high_pos=shift;
                  extreme_search=-1;
                  ZigzagPeakBuffer[shift]=last_high;
                  ZigzagColorBuffer[shift]=0;
                  res=1;
                  
                  //仮記憶
                  calclast_peak_value =ZigzagPeakBuffer[shift];
                  calclast_peak_time = time[shift];
                 }
               if(ZigzagLowMapBuffer[shift]!=0)
                 {
                  last_low=low[shift];
                  last_low_pos=shift;
                  extreme_search=1;
                  ZigzagBottomBuffer[shift]=last_low;
                  ZigzagColorBuffer[shift]=1;
                  res=1;
                  //仮記憶
                  calclast_bottom_value = ZigzagBottomBuffer[shift];
                  calclast_bottom_time = time[shift];

                 }
              }
            break;
         case Peak: // search for peak
            if(ZigzagLowMapBuffer[shift]!=0.0 && ZigzagLowMapBuffer[shift]<last_low &&
               ZigzagHighMapBuffer[shift]==0.0)
              {
#ifdef  USE_debug_zigzag
                printf("at Peak:BottomBufferChg"+ DoubleToString(LowMapBuffer[shift])+"　←　"
                +DoubleToString(ZigzagBottomBuffer[last_low_pos]) +"  t=  "+TimeToString(time[shift]) 
                +"　←　pretime  "+TimeToString(time[last_low_pos])
                
                );
#endif//USE_debug_zigzag   
               ZigzagBottomBuffer[last_low_pos]=0.0;
               last_low_pos=shift;
               last_low=ZigzagLowMapBuffer[shift];
               ZigzagBottomBuffer[shift]=last_low;
               ZigzagColorBuffer[shift]=1;
               res=1;
                  //仮記憶
                  calclast_bottom_value = ZigzagBottomBuffer[shift];
                  calclast_bottom_time = time[shift];
          
              }
            if(ZigzagHighMapBuffer[shift]!=0.0 && ZigzagLowMapBuffer[shift]==0.0)
              {
#ifdef  USE_debug_zigzag
                printf("at Peak:PeakBufferAdd"+ DoubleToString(HighMapBuffer[shift])+"  t=  "+TimeToString(time[shift]));
#endif//USE_debug_zigzag             
               last_high=ZigzagHighMapBuffer[shift];
               last_high_pos=shift;
               ZigzagPeakBuffer[shift]=last_high;
               ZigzagColorBuffer[shift]=0;
               extreme_search=Bottom;
               res=1;
                  //仮記憶
                  calclast_peak_value =ZigzagPeakBuffer[shift];
                  calclast_peak_time = time[shift];

              }
            break;
         case Bottom: // search for bottom
            if(ZigzagHighMapBuffer[shift]!=0.0 &&
               ZigzagHighMapBuffer[shift]>last_high &&
               ZigzagLowMapBuffer[shift]==0.0)
              {
#ifdef  USE_debug_zigzag
                printf("at Bottom:PeakBufferChg　　"+ DoubleToString(ZigzagHighMapBuffer[shift])+"　←　"
                +DoubleToString(ZigzagPeakBuffer[last_high_pos])+"  t=  "+TimeToString(time[shift])
                +"　←　pretime  "+TimeToString(time[last_high_pos])
                );
#endif//USE_debug_zigzag  


               ZigzagPeakBuffer[last_high_pos]=0.0;
               last_high_pos=shift;
               last_high=ZigzagHighMapBuffer[shift];
               ZigzagPeakBuffer[shift]=last_high;
               ZigzagColorBuffer[shift]=0;
                  //仮記憶
                  calclast_peak_value =ZigzagPeakBuffer[shift];
                  calclast_peak_time = time[shift];
              }
            if(ZigzagLowMapBuffer[shift]!=0.0 && ZigzagHighMapBuffer[shift]==0.0)
              {
               last_low=ZigzagLowMapBuffer[shift];
               last_low_pos=shift;
               ZigzagBottomBuffer[shift]=last_low;
               ZigzagColorBuffer[shift]=1;
               extreme_search=Peak;
                  //仮記憶
                  calclast_bottom_value = ZigzagBottomBuffer[shift];
                  calclast_bottom_time = time[shift];
#ifdef  USE_debug_zigzag
                printf("at Bottom:BottomBufferAdd　　"+ DoubleToString(last_low)+"  t=  "+TimeToString(time[shift]));
#endif//USE_debug_zigzag
                }
            break;
         default:
#ifdef  USE_debug_zigzag
                printf("↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑");
#endif//USE_debug_zigzag  
            return(rates_total);
        }
     }//for
    //本当に変化したかの確認 addorChgの判断
    bool b_chgpeak = false;
    bool b_chgbottom = false;
	if(calclast_peak_value!=0&&
		(calclast_peak_value!=setlast_peak_value&&
		 calclast_peak_time!=setlast_peak_time)
	){
		b_chgpeak=true;
	}
	if(calclast_bottom_value!=0&&
	    (calclast_bottom_value!=setlast_bottom_value&&
	     calclast_bottom_time!=setlast_bottom_time)
	){
		b_chgbottom = true;
	}

// 足一本ごとの評価なので両方変化することはない
        if(b_chgpeak==true && b_chgbottom==true){
            int zzz = 0;
        	b_chgpeak=b_chgpeak;
        	zzz = 1;
        }

	if(b_chgpeak==true || b_chgbottom==true){
		//どっち側の更新か
		//Setのラストはどっちか？
		//初期値があると比較しにくい 
		if(setlast_peak_time!=0 && 
		   setlast_bottom_time!=0)
		{
		    //if(setlast_peak_time>setlast_bottom_time){
		    if(setlast_data_kind==1){
		        //peakが最後に格納されている
		        if(b_chgpeak==true){
		            //変更 peak
		            chgzigzagdata("peakchg",1,setlast_peak_value,setlast_peak_time,calclast_peak_value,calclast_peak_time
		            //,setlast_peak_value,setlast_peak_time,setlast_bottom_value,setlast_bottom_time,setlast_data_kind
		            //,period
);
		        	
		        }else if(b_chgbottom==true){//ｂ＿ｃｈｇBottom＝＝true
		            //追加　bottom
                    addzigzagdata("bottadd",-1,calclast_bottom_value,calclast_bottom_time
                    //,setlast_peak_value,setlast_peak_time,setlast_bottom_value,setlast_bottom_time,setlast_data_kind
                    //,period
);
		        
		        }
		    
		    }else{
		        //bottomが最後に格納されている
		        if(b_chgpeak==true){
		            //追加 peak
		            addzigzagdata("peakadd",1,calclast_peak_value,calclast_peak_time
		            //,setlast_peak_value,setlast_peak_time,setlast_bottom_value,setlast_bottom_time,setlast_data_kind
		            //,period
);
		        }else if(b_chgbottom==true){ //ｂ＿ｃｈｇBottom＝＝true
		            //変更　bottom
		            chgzigzagdata("bottchg",-1,setlast_bottom_value,setlast_bottom_time,calclast_bottom_value,calclast_bottom_time
		            //,setlast_peak_value,setlast_peak_time,setlast_bottom_value,setlast_bottom_time,setlast_data_kind
		            //,period
);
		            
		        }
		    }
		}else{//未格納があるとき
        	if(b_chgpeak==true){
        	    // peak add
        	    addzigzagdata("peakaddXXXX",1,calclast_peak_value,calclast_peak_time
        	    //,setlast_peak_value,setlast_peak_time,setlast_bottom_value,setlast_bottom_time,setlast_data_kind
        	    //,period
);
        	}else if(b_chgbottom==true){
        	    // bottom add
        	    addzigzagdata("bottaddXXX",-1,calclast_bottom_value,calclast_bottom_time
        	    //,setlast_peak_value,setlast_peak_time,setlast_bottom_value,setlast_bottom_time,setlast_data_kind
        	    //,period
); 
        	}
		}
	}
//---　目線の計算処理
	calc_mesen_C();// 目線の計算Cn、変化フラグの更新


//--- return value of prev_calculated for next call
#ifdef  USE_debug_zigzag
                printf("↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑");
#endif//USE_debug_zigzag  

   return(rates_total);
    	
}


void candle_data::addzigzagdata(string s,int k,double &v,datetime &t){// k 1:peak -1:bottom
#ifdef  USE_debug_zigzag
                printf("set "+s+ "   \t"+DoubleToString(v)+"   \t"+TimeToString(t));
#endif//USE_debug_zigzag
	if(k==1){
		setlast_peak_value=v;setlast_peak_time=t;
		
	}else{
		setlast_bottom_value=v;setlast_bottom_time=t;
	}
	setlast_data_kind=k;
	into_Zigzagdata(false,v,t,k);
	zigzag_chg_flag=true;
}

void candle_data::chgzigzagdata(string s,int k,double &pre_v,datetime &pre_t,double &v,datetime &t){// k 1:peak -1:bottom
#ifdef  USE_debug_zigzag
                printf("set "+s+ "   \t"+DoubleToString(v)+"   \t"+TimeToString(t)     
                + "←←   \t"+DoubleToString(pre_v)+"   \t"+TimeToString(pre_t));
#endif//USE_debug_zigzag

	if(k==1){
		setlast_peak_value=v;setlast_peak_time=t;
	}else{
		setlast_bottom_value=v;setlast_bottom_time=t;
	}
	setlast_data_kind=k;
	into_Zigzagdata(true,v,t,k);
	zigzag_chg_flag=true;
	
}
void debug_zigzag(	ENUM_TIMEFRAMES period,	int insert_idx,// chg true,add false
		double &v,
		datetime &t,
		int &k,// k 1:peak -1:bottom
		int c
		){
	printf("@@@@"+"%%period=%%"+IntegerToString((int)period)+
		"%%zigzagdata_count=%%\t"+IntegerToString(c)+
		"%%insert_idx=%%"+IntegerToString(insert_idx)+
		"%%v=%%\t"+DoubleToString(v)+
		"%%t=%%\t"+TimeToString(t)+
		"%%ts=%%\t"+IntegerToString((int)t)+
		"%%ratets_total=%%\t"+IntegerToString(global_rates_total)+
		"%%prev_=%%\t"+IntegerToString(golobal_prev_calculated));
			
}

void candle_data::into_Zigzagdata(
		int regIsChg,// chg true,add false
		double &v,
		datetime &t,
		int &k// k 1:peak -1:bottom
){
	if(zigzagdata_count == 0&& regIsChg == true){
		printf("そんなばかな。初回で変更はない");
		return;
	}
	
	//格納先を決める
	int insert_idx = zigzagdata_count;
	if( regIsChg == true ){// chg?
		//serch &del(上書き）
		if(zigzagdata[zigzagdata_count-1].kind == k ){
			insert_idx = zigzagdata_count-1;
		}else{
			if(zigzagdata[zigzagdata_count-2].kind == k ){
				insert_idx = zigzagdata_count-2;
				printf("そんなばかな。ずれている。2つ前");
			}else{
				printf("そんなばかな。ずれている。3つ以上　格納できない。");
			}
		}
		
	}else{// add
		//defult
		zigzagdata_count++;
		chk_mem_zigzagdata(zigzagdata_count);
	}
#ifdef  USE_debug_zigzag
	debug_zigzag(period,insert_idx,v,t,k,zigzagdata_count);
	//debug 
#endif //USE_debug_zigzag
	if(zigzagdata[insert_idx].time > t){
	    printf("error old data set zigzag:"+TimeToString(t));
	    return;
	}
	zigzagdata[insert_idx].value = v;
	zigzagdata[insert_idx].time = t;
	zigzagdata[insert_idx].kind = k;
	zigzagdata[insert_idx].idx = insert_idx;
	
//	if((insert_idx ==40260 ||insert_idx ==40261) && period==PERIOD_M1){
//	    printf("idx="+IntegerToString(insert_idx)+"  t= "+TimeToString(t));
//	}
	//printf("@zig@Zi@"+"123456"+"@"+""+"@"+DoubleToString(v)+"@"+TimeToString(t)+"@"+""+"@"+""+"@"+""+"");
	//int iii = (int)t;
	//string sss = TimeToString(t);
	//datetime ttt = StringToTime(sss);
	//printf("iii="+IntegerToString(iii)+"   sss="+sss+"   ttt"+ttt);
	//iii = iii;
	
	view_zigzag_Zi_line(insert_idx,regIsChg);
	zigzagSetOtherInfo(insert_idx,t,v);
}
void candle_data::zigzagSetOtherInfo(int insert_idx,datetime t,double v){// add 2020/08/12
	//どの位置のキャンドルか？最新からどれだけずれているかを算出(時間をキーにして特定）
	//if(candle_bar_count > period+1){
	
	//対象キャンドルを検索
	int find_idx=-1;
	for(int i=CANDLE_BUFFER_MAX_NUM-1;i>=0;i--){
		if(t==time[i]){
			find_idx=(CANDLE_BUFFER_MAX_NUM-1)-i;
			break;
		}
	}
	if(find_idx !=-1){ // 発見
		//キャンドルにデータを持たせる前提
		//最新足をidx＝０として、データを取得する
		int ma_period = 20;
		double out_ma=0.0;
		double sig=0.0;
		double ma = MAprice(ma_period,MODE_SMA,find_idx);
		double ma_katamuki = MAkatamuki(ma_period,MODE_SMA,find_idx);
		sigma(ma_period,find_idx,out_ma,sig);
		double bori_3sig_up=out_ma+sig*3;
		double bori_2sig_up=out_ma+sig*2;
		double bori_1sig_up=out_ma+sig*1;
		double bori_3sig_dn=out_ma-sig*3;
		double bori_2sig_dn=out_ma-sig*2;
		double bori_1sig_dn=out_ma-sig*1;
		
		double sig3updn_dist = sig*6;
		double sig3updn_pips = chgPrice2Pips(sig3updn_dist);
		double ma_kairi=(v-ma)/100.00;
		
		zigzagdata[insert_idx].b_1sig_dn=bori_1sig_dn;
		zigzagdata[insert_idx].b_2sig_dn=bori_2sig_dn;
		zigzagdata[insert_idx].b_3sig_dn=bori_3sig_dn;
		zigzagdata[insert_idx].b_1sig_up=bori_1sig_up;
		zigzagdata[insert_idx].b_2sig_up=bori_2sig_up;
		zigzagdata[insert_idx].b_3sig_up=bori_3sig_up;
		zigzagdata[insert_idx].b_sig=sig;
		zigzagdata[insert_idx].b_sig3updn_dist=sig3updn_dist;
		zigzagdata[insert_idx].b_sig3updn_pips=sig3updn_pips;
		zigzagdata[insert_idx].ma_20_sma=ma;
		zigzagdata[insert_idx].ma_20_sma_katamuki=ma_katamuki;
		zigzagdata[insert_idx].ma_kairi=ma_kairi;
		
	}
}
void candle_data::clean_up_arrays_zigzag(void){
	for(int i = 0;i<CANDLE_BUFFER_MAX_NUM ;i++){// idx 0が古い想定
		ZigzagPeakBuffer[i]=0.0;
		ZigzagBottomBuffer[i]=0.0;
		ZigzagHighMapBuffer[i]=0.0;
		ZigzagLowMapBuffer[i]=0.0;
		ZigzagColorBuffer[i]=0.0;		
		
	}
}

//表示Line　　addは一つ追加、chgは　含む線分を削除してから書き直す
//時間軸ごとに取得データを変える
void candle_data::view_zigzag_Zi_line(
	int &idx1,
	int &regIsChg // falseならAddのみ,trueは変更
){
	int preidx=idx1-1;
	int afteridx=idx1+1;
	//変更の時はその前後の線分を削除する
	//そして、その前後の線分を描く
	if( regIsChg == true){// trueは変更chg    での削除処理
		
		//削除 点の前のラインの削除
//		if(idx1!=0 ){
			del_view_zigzag_Zi_line(preidx,idx1);
//		}
//		if(idx1 !=count-1){ // 最後でない
			del_view_zigzag_Zi_line(idx1,afteridx);
//		}
		
		//repaint();

	}
	// 線の描画
//	if(idx1!=0 ){//一つ前と描画
		del_view_zigzag_Zi_line(preidx,idx1);//zzz debug
		set_zigzag_Zi_line(preidx,idx1);
//	}
//	if(idx1 !=count-1){ // 最後でない
		del_view_zigzag_Zi_line(idx1,afteridx);//zzz debug
		set_zigzag_Zi_line(idx1,afteridx);
//	}
	
	

}
void candle_data::del_view_zigzag_Zi_line(
	int &idx1,
	int &idx2
){
    string objname = make_zig_objectname(period,idx1,idx2);
    ObjectDelete(0,objname);
}
int candle_data::GetTimeColor(ENUM_TIMEFRAMES p){
int cl = clrWhite;
	switch(p)
	{
        case PERIOD_CURRENT:
            cl = candle_data::GetTimeColor(_Period);
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
void candle_data::set_zigzag_Zi_line(
	int &idx1,
	int &idx2
){
	datetime t1;
	datetime t2;
	double p1;
	double p2;
	int istyle;
	int iwidth;
	string viewstring;
	int cColor;

	int k;
	int icount,icount2;
	string objname = make_zig_objectname(period,idx1,idx2);
	
	bool bret1,bret2;
	bret1=get_zigzagdata(period,idx1,p1,t1,k,icount);
	bret2=get_zigzagdata(period,idx2,p2,t2,k,icount2);
    
	if(bret1 == false || bret2 == false || idx1 >=icount || idx2 >=icount2|| idx1<0 || idx2<0){
#ifdef USE_debug_zigzag
		printf("get error 	get_zigzagdata at setline. idx1="+IntegerToString(idx1)+ "   idx2="+IntegerToString(idx2)+ "  count ="+IntegerToString(count));
#endif //USE_debug_zigzag
		return;
	}



    
	istyle=STYLE_SOLID;
	iwidth=3;
	
    //cColor = clrWhite;//
    cColor = GetTimeColor(period);
    viewstring = "ZigzagLINE";

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

//idxとPeriodで必要データの取得を行う
bool candle_data::get_zigzagdata(
	ENUM_TIMEFRAMES &p,
	int &idx,
	double &v,
	datetime &t,
	int &k,
	int &c
){
	bool ret = true;

	c=zigzagdata_count;
	if(idx <c && idx >=0){
		v=zigzagdata[idx].value;
		t=zigzagdata[idx].time;
		k=zigzagdata[idx].kind;
	}else{
		ret = false;
	}
	return ret;
}









//+------------------------------------------------------------------+
//| Get highest value for range                                      |
//+------------------------------------------------------------------+
double candle_data::Highest(const double&array[],int icount,int start)
  {
   double res=array[start];
//---
   for(int i=start; i>start-icount && i>=0; i--)
     {
      if(res<array[i])
         res=array[i];
     }
//---
   return(res);
  }
//+------------------------------------------------------------------+
//| Get lowest value for range                                       |
//+------------------------------------------------------------------+
double candle_data::Lowest(const double&array[],int icount,int start)
  {
   double res=array[start];
//---
   for(int i=start; i>start-icount && i>=0; i--)
     {
      if(res>array[i])
         res=array[i];
     }
//---
   return(res);
  }


string candle_data::make_zig_objectname(
ENUM_TIMEFRAMES &p,
int idx1,
int idx2
){
	//@Tick@Zi@stringPeriod@idx1@idx2@period int
	string s = "@zig@Zi@"+PeriodToString(period)+"@"+IntegerToString(idx1)+"@"+IntegerToString(idx2)+"@"+IntegerToString(p);
	return s;
}

bool candle_data::get_split_zig_objectname(
	string &s,
	ENUM_TIMEFRAMES &p,
	int &idx1,
	int &idx2
){
//@zig@Zi@stringPeriod@idx1@idx2@period int
//@moji1@moji2@moji3@num1@num2@num3@

  string sep="@";               // 区切り文字 
  ushort u_sep;                 // 区切り文字のコード 
  string result[];               // 文字列を受け取る配列 
  //--- 区切り文字のコードを取得する 
  u_sep=StringGetCharacter(sep,0); 
  //--- 文字列を部分文字列に分ける 
  int k=StringSplit(s,u_sep,result);
  
  string moji1,moji2,moji3;
  //int idx1,idx2;
  if(k >=7){
      moji1= result[1];
      moji2= result[2];
      moji3= result[3];
      idx1 = (int)StringToInteger(result[4]);
      idx2 = (int)StringToInteger(result[5]);    
      p = (ENUM_TIMEFRAMES)StringToInteger(result[6]);
  }else{
		return false;
  }
  if( StringCompare(moji1,"zig") == 0 ){
      return true;
  }else {
      return false;
  } 


}
//+------------------------------------------------------------------+
//|  Trend line reinstallation                                       |
//+------------------------------------------------------------------+
void candle_data::SetTline(long     chart_id,  // chart ID
              string   name,      // object name
              int      nwin,      // window index
              datetime time1,     // price level time 1
              double   price1,    // price level 1
              datetime time2,     // price level time 2
              double   price2,    // price level 2
              color    Color,     // line color
              int      style,     // line style
              int      width,     // line width
              string   text)      // text
  {
//----
   if(ObjectFind(chart_id,name)==-1) CreateTline(chart_id,name,nwin,time1,price1,time2,price2,Color,style,width,text);
   else
     {
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
      ObjectMove(chart_id,name,0,time1,price1);
      ObjectMove(chart_id,name,1,time2,price2);
     }
//----
}
//+------------------------------------------------------------------+
//|  Trend line creation                                             |
//+------------------------------------------------------------------+
void candle_data::CreateTline(long     chart_id,  // chart ID
                 string   name,      // object name
                 int      nwin,      // window index
                 datetime time1,     // price level time 1
                 double   price1,    // price level 1
                 datetime time2,     // price level time 2
                 double   price2,    // price level 2
                 color    Color,     // line color
                 int      style,     // line style
                 int      width,     // line width
                 string   text)      // text
  {
//----
   ObjectCreate(chart_id,name,OBJ_TREND,nwin,time1,price1,time2,price2);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetInteger(chart_id,name,OBJPROP_STYLE,style);
   ObjectSetInteger(chart_id,name,OBJPROP_WIDTH,width);
   ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,true);
//----
  }

void candle_data::sma_make_handle(int ma_period,int &handle){//handle_sma作成
    handle = iMA(_Symbol,period,ma_period,0,MODE_SMA,PRICE_CLOSE); 
    printf("maked_sma:"+PeriodToString(period)+"h="+IntegerToString(handle));
}
bool candle_data::sma_get_katamuki_now(int handle,double &katamuki,datetime &t){
    double ma[];
    int getnum = 10;
    int iret = CopyBuffer( handle,0,t,getnum,ma);
    if(iret < getnum){return false;}
    
    katamuki=   ma[getnum-1]-ma[getnum-2];//2点　　（最新-１つ前）・２
    //if(katamuki == 0){
    //    katamuki = ma[getnum-1]-ma[getnum-3]//2点　　（最新-１つ前）・２
    //}
    return true;
}
bool candle_data::sma_get_value_now(int handle,double &v,datetime &t){
    double ma[];
    int getnum = 1;
    int iret = CopyBuffer( handle,0,t,getnum,ma);
    if(iret < getnum){return false;}
    
    v=ma[0];
    return true;
}    


int candle_data::Oncalculate_Fractals(void){
    //int ret=CANDLE_BUFFER_MAX_NUM-1;
    int rates_total=CANDLE_BUFFER_MAX_NUM;
    int prev_calculated=CANDLE_BUFFER_MAX_NUM-1;
    int ret = 
    OnCalculate_Fractals_(rates_total,prev_calculated,time,open,high,low,close);
    return(ret);    
}



#endif//class_candle_data
  