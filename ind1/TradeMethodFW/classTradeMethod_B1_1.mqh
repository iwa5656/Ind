#ifndef classTradeMethod_B1_1
#define classTradeMethod_B1_1

#include "..\class_candle_data.mqh"
#include "..\class_allcandle.mqh"
#include "..\lib\lib_file_func.mqh"
#include <_inc\\My_function_lib2.mqh>
#include "..\lib\lib_xy_func.mqh"
#include "classTradeMethodbase.mqh"

#ifdef commentttt
"押し戻り：
上位足A-Dが目線が下、かつ
BDの上位X％以内で、下位足の目線が下
利確はBDの下位X％以内になったとき。
"
"上位足
A.v>C.v && B.v>D.v
下位足で目線が下
　値がBDの上位X％だったら、下へエントリー

・AorCを超えたら、パターン不成立とする
・Dの値を更新

para::
Inp_para_double1 =0.1;//double para1    x%
Inp_para_int1 =0;//int para1            baseからどれだけずらすか１で一つ上


（別途確認
エントリー時にTP,SLを確認
Now,C（損切幅）
Now.D（利確幅）
利確が多いときエントリ
）"	"D以下で利確


（別途確認（時間的に勢い内）↓
D以下で利確
Dから時間がBCD＊１．５倍たったら抜ける。）"



#endif //commentttt

//debug viwe
#define USE_View_Pattern_data_A_E_out_debugwindow     //パターン成立時、各点をデバッグウインドに表示（デバッグ用）
#define USE_View_Pattern_data_A_E_out_Line     //パターン成立時、その線分を白で表示（デバッグ用）
#define USE_View_out_hyoukadata //エントリーしたか、勝ち負け、そのサイズなどを表示（数字のみ）
extern datetime pre_timeM1;
class TradeMethod_B1_1 :public TradeMethodbase 
{
public:
   int hyouka_data_koyuu_num;
   double x_hiritu;//inp x％
   int timeframes_chg_to_upper_num;// 上位タイムフレームのシフト数

	//--- コンストラクタとデストラクタ
	TradeMethod_B1_1(void){};
	TradeMethod_B1_1(string s,ENUM_TIMEFRAMES p,candle_data *c,allcandle *a){name = "Method_B1_1";period = p;candle = c; p_allcandle = a;hyouka_data_koyuu_num=0;
        x_hiritu=p_allcandle.get_Inp_para_double1();
        timeframes_chg_to_upper_num=p_allcandle.get_Inp_para_int1();
        if(timeframes_chg_to_upper_num==0){printf("not set timeframes_chg_to_upper_num");}
		init_mem_hyouka_data_koyuu();
	};
	~TradeMethod_B1_1(void){view_kekka_youso(1);};
	//--- オブジェクトを初期化する
   void Oninit(void){}
   void OnDeinit(const int reason){
      #ifdef USE_View_out_hyoukadata
      debug_B1_1_tp_sl_All();
      #endif //USE_View_out_hyoukadata
      kekka_calc();printf("instant_B1_1");
      candle_data *c=p_allcandle.get_updown_TimeFrame(timeframes_chg_to_upper_num,p_allcandle.Inp_base_time_frame);
      printf("★upperFrame="+EnumToString(c.period));
   }
    //関数
//	int		hyouka(void);//　評価・状態遷移含む処理
//   int   hyouka_zig_kakutei(void);// 足確定で呼ばれる想定
//
//	int     hyouka_tick(void);//Tickの細かい処理　Entryとか　　
    bool    add_hyouka_data_koyuu(int);
    bool    Is_pattern(void);// 直近のZigzagから評価
    bool    Is_pattern(int base_idx);// 指定したzigzagcount－１　の時のパターン成立状態
    int    chk_chg_zigdata_for_pt(int idx);//更新
   //一時データ保持用
   //ABCDE
   struct_mesen_tyouten_zokushin cn_out[5];// [0]が一番最新
   int last_zigidx_E;// E
   int first_zigidx_A;// A
   
   
   struct struct_hyouka_data_TradeMethodbaseA1{
      struct_mesen_tyouten_zokushin tyouten[5];
      int last_zigidx;// E
      int first_zigidx;// A
   };
   struct_hyouka_data_TradeMethodbaseA1 hyouka_data_koyuu[];

//各処理
	int		hyouka(void){//　評価・状態遷移含む処理
		
		//bool isnew_bar=p_allcandle.flagchgbarM15;//　tbd ★★どのの時間軸使用するかは。。。使用するcandleのフラグにした方が良い
        bool isnew_bar=p_allcandle.get_candle_flagchgbar(this.period);
  		if(isnew_bar == true){
			hyouka_kakutei();
		

   	    }

   		//if(candle.zigzag_chg_flag==true&&      
   		//  (candle.zigzag_chg_flag_status==1||candle.zigzag_chg_flag_status==0||candle.zigzag_chg_flag_status==-1)){
   			  hyouka_zig_kakutei();
   		//}
		return 0;
	}

void hyouka_zig_kakutei(void); // 足確定で呼ばれる想定
void hyouka_kakutei(void);// 足確定で呼ばれる想定

 void SetSendData_forEntry(int a,int a2,int b,int c,double d,double e,double f){
	GlobalVariableSet("Ind_EntryNo",a);
	GlobalVariableSet("Ind_EntryDirect",a2);
	GlobalVariableSet("Ind_hyoukaNo",b);
	GlobalVariableSet("Ind_hyoukaSyuhouNo",c);
	GlobalVariableSet("Ind_EntryPrice",d);
	GlobalVariableSet("Ind_Tp_Price",e);
	GlobalVariableSet("Ind_Sl_Price",f);
 }
void set_EntryData(int i,int kekkano){
    SetSendData_forEntry(
        EntryNo++,
        (int)hyouka_data[i].kekka[kekkano][37],
        i,kekkano,
        hyouka_data[i].kekka[kekkano][40],
        hyouka_data[i].kekka[kekkano][38],
        hyouka_data[i].kekka[kekkano][39]);
    datetime Time_cur = TimeCurrent();    
    hyouka_data[i].kekka[kekkano][44]=(double)candle.time[ZIGZAG_BUFFER_MAX_NUM-1];
    datetime test =  candle.time[0];
    datetime test2 = candle.time[299];       
}

//mem
void init_mem_hyouka_data_koyuu(void){
	ArrayResize(hyouka_data_koyuu,1,NUM_YOBI_HYOUKA_DATA_MEM); 
	//int i=0;
	//i=sizeof(hyouka_data[0]);printf("hyouka_data 1   :sizeof="+IntegerToString(i));
}
void chk_mem_hyouka_data_koyuu(int i){
	int m=hyouka_data_koyuu_num;
	if(hyouka_data_koyuu_num < i){
		m=i+1;
	}
	ArrayResize(hyouka_data_koyuu,i,NUM_YOBI_HYOUKA_DATA_MEM);	
}
void debug_B1_1_tp_sl(real_point &A,real_point &B,real_point &C,real_point &D,real_point &E,real_point &F,real_point &G);
void TradeMethod_B1_1::debug_B1_1_tp_sl_All(void);
void debug_B1_1_tp_sl_idx(int idx);
    
};//end class def

void TradeMethod_B1_1::hyouka_kakutei(void){ // 足確定で呼ばれる想定
// 
//real_point　zzzz;
	real_point a,b,c,d,e,f,nn;
	double sa;//基準値からの損益価格
	double sa_pips;

   double now = candle.close[ZIGZAG_BUFFER_MAX_NUM-1];
   datetime now_time = candle.time[ZIGZAG_BUFFER_MAX_NUM-1];
   nn.v=now;
   nn.t=now_time;
   bool ret_channel=false;
   bool flag_exit_syori=false;
   real_point A,M,C,B,D,E;
   int ret_b_up=false;
   bool ret_entry=false;
   double dd_BD=0;
   double x=0;
   double kiten_BD_joui_xper=0;
   int zigidx = 0;
   int bkirikawari=0;

    datetime Tk=0;
   imi_point ai,bi,ci,di,ei,nni;
   for(int i = 0; i<hyouka_data_num ;i++){
      switch(hyouka_data[i].status){
         case 1:// 
         	//////////////////////////////
         	//** 評価パターン０：
         	//////////////////////////////
            
#ifdef comment
A
        C
    B

		    D	
#endif //comment

			a.t=hyouka_data_koyuu[i].tyouten[3].t;a.v=hyouka_data_koyuu[i].tyouten[3].v;  
			b.t=hyouka_data_koyuu[i].tyouten[2].t;b.v=hyouka_data_koyuu[i].tyouten[2].v;  
			c.t=hyouka_data_koyuu[i].tyouten[1].t;c.v=hyouka_data_koyuu[i].tyouten[1].v;  
			d.t=hyouka_data_koyuu[i].tyouten[0].t;d.v=hyouka_data_koyuu[i].tyouten[0].v;  

            Tk = a.t;
         //エントリー条件判断
            //下位足で目線が下
            //　値がBDの上位X％だったら、下へエントリー
        dd_BD=MathAbs(b.v-d.v);
        //x=20.0;
        x=x_hiritu*100.0;// para double 1
        kiten_BD_joui_xper=b.v-dd_BD*x/100.0;

        //下位足で目線したになったか？
        zigidx = candle.zigzagdata_count-1;
        bkirikawari=0;
        if(zigidx >=0&& zigidx<= candle.zigzagdata_count-1){
            if(candle.zigzagdata[zigidx].mesen.kind == 1){
                if( candle.zigzagdata[zigidx].mesen.dir == -1){
                    bkirikawari=1;
                }else{

                }
            }    
        }

        if(bkirikawari==1 && b.v> nn.v && kiten_BD_joui_xper <= nn.v){//★　目線がsita かつ　値がBDの上位X％だったら、下へエントリー
            ret_entry=true;
         }         
			//エントリーできるか   
			if(ret_entry == true){

				//エントリー
                int i_dir=-1;
				entry_syori(i,now,now_time,i_dir);// buyの形
				//エントリー後の状態へ移行
				hyouka_data[i].status =2;
			}else if(candle.zigzag_chg_flag==true&&candle.zigzag_chg_flag_status==0){
				//登録後Zigが変更になったかどうか確認し、更新
				int iret=
				chk_chg_zigdata_for_pt(i);
				if(iret ==2){ //ptと形が異なるようになったので　無効化へ
					hyouka_data[i].status = 0;
				}
			}else if(nn.v > c.v){// 無効の形になったら完了
					hyouka_data[i].status = 0;
            }
            //実時間から意味座標変換してバーの数を数えて、  
            //同じサイズ分より超えていたら、無効にする。
                //D-Aのバーの数、Dからのバーの数進めた時間より超えたら無効へ
                chg_r2i(a,ai,Tk);
                chg_r2i(d,di,Tk);
                chg_r2i(nn,nni,Tk);
                if(di.x+MathAbs(ai.x-di.x)<nni.x){
                    hyouka_data[i].status = 0;
                }

	
			break;
         case 2://エントリー中
			//Exitか？
			   
			//CEにタッチしたらExit		勝ち
            //形になっているか判定
            //real_point A,M,C,B,D,E;
            //real_point a;
            //real_point　h;

            A.v = hyouka_data_koyuu[i].tyouten[3].v;/*y*/            A.t = hyouka_data_koyuu[i].tyouten[3].t;//x
            B.v = hyouka_data_koyuu[i].tyouten[2].v;/*y*/            B.t = hyouka_data_koyuu[i].tyouten[2].t;//x
            C.v = hyouka_data_koyuu[i].tyouten[1].v;/*y*/            C.t = hyouka_data_koyuu[i].tyouten[1].t;//x
            D.v = hyouka_data_koyuu[i].tyouten[0].v;/*y*/            D.t = hyouka_data_koyuu[i].tyouten[0].t;//x
            //E.v = hyouka_data_koyuu[i].tyouten[0].v;/*y*/            E.t = hyouka_data_koyuu[i].tyouten[0].t;//x
				//線分abと点cの位置関係を知る(上か下か線上か？)
      				//int chk_point_line_upperordownside(real_point &a,real_point &b,real_point &c){
      				//int ret=0;//上：1　下-1、　線分上0
            //ret_b_up=chk_point_line_upperordownside(C,E,nn);
            
            //利確/損切条件判断
            //if(ret_b_up == 1||ret_b_up == 0){//上のチャネルにぶつかる
            if(D.v>=nn.v){// 利確★
               //exit syori
               flag_exit_syori=true;
            }else if(C.v<=nn.v){ //*のラインを上に割る　//損切★
               //exit syori
               flag_exit_syori=true;
            }
      	   if(flag_exit_syori==true){
      	      exit_syori(i,nn.v,nn.t);
      	      //exit
      	      hyouka_data[i].status = 999;//評価完了
      	      
      	      
               double ddd=hyouka_data[i].exit_v-hyouka_data[i].entry_v;
               if(ddd==0.0){hyouka_data[i].winloss=0;}
               else if(hyouka_data[i].dir == 1 && ddd>0){hyouka_data[i].winloss=1;}
               else if(hyouka_data[i].dir == 1 && ddd<0){hyouka_data[i].winloss=-1;}
               else if(hyouka_data[i].dir == -1 && ddd>0){hyouka_data[i].winloss=-1;}
               else if(hyouka_data[i].dir == -1 && ddd<0){hyouka_data[i].winloss=1;}
               string aaa="負け:=";
      			if(hyouka_data[i].winloss==1){
      				//win
      				aaa="勝ち:=";
      			}
      			if(hyouka_data[i].winloss!=0){
         			printf(aaa + getPips(MathAbs(hyouka_data[i].entry_v-hyouka_data[i].exit_v))
         			+"   ikey="+IntegerToString(hyouka_data[i].reg_ikey)+" = "+name
         			);
         			printf("   entv="+DoubleToString(hyouka_data[i].entry_v,2)+"  exitv="+DoubleToString( hyouka_data[i].exit_v,2));
         			printf("   entt="+TimeToString(hyouka_data[i].entry_t)+"  exitt="+TimeToString( hyouka_data[i].exit_t));
         			
               }

      	      
      	   }
      
             break;
         case 3:
      
         
             break;
         default:
             break;
         
      }//すぃｔｃｈ
   }//for
    
    //return(0);

}
void TradeMethod_B1_1::hyouka_zig_kakutei(void){ // 足確定で呼ばれる想定
// 
//real_point　zzzz;
	//real_point a,b,c,d,e,f,nn;
	double sa;//基準値からの損益価格
	double sa_pips;
    //上位足からのキャンドルポインタを取得して、パターンを判断する。下記を使用する。
    //candle_data *allcandle::get_updown_TimeFrame(int updn,ENUM_TIMEFRAMES period){// updn分TimeFrameを変更したcandle_dataのPointerを取得
    //int timeframes_chg_to_upper_num=2;// 何個上にするか？
    candle_data *c=p_allcandle.get_updown_TimeFrame(timeframes_chg_to_upper_num,p_allcandle.Inp_base_time_frame);

    //追加必要か？
    // パターン成立したか？
 //       //Zigzag変化したとき
//        if(candle.zigzag_chg_flag==true){
   		if(c.zigzag_chg_flag==true&&      
   		  (c.zigzag_chg_flag_status==1||c.zigzag_chg_flag_status==0||c.zigzag_chg_flag_status==-1)){
            //パターン成立
            if(Is_pattern()){
   						
                //評価データに追加、状態を１へ、重複しないように同じZigzagパターン番号の時で既にあるなら追加しない。（add処理で実現）
                //get_pattern_key_id(&key_id);
                add_hyouka_data(last_zigidx_E);
                

                
            }
		   }

}
int TradeMethod_B1_1::chk_chg_zigdata_for_pt(int idx){// 更新し、値を変更した1（パターン成立）、未変更０、パターン成立しない２
   bool bchg=false;
   int midx=3;//hyouka_data_koyuuの最後のidx
    //int timeframes_chg_to_upper_num=2;// 何個上にするか？
    candle_data *c=p_allcandle.get_updown_TimeFrame(timeframes_chg_to_upper_num,p_allcandle.Inp_base_time_frame);
    //if(c.zigzagdata_count>6){}
	for(int i=0;i<=midx;i++){
        if(c.zigzagdata_count < hyouka_data_koyuu[idx].tyouten[midx-i].no){
            printf("error over ");
            return 2;
        }
      //printf(IntegerToString(hyouka_data_koyuu[idx].tyouten[midx-i].no));
		if(c.zigzagdata[hyouka_data_koyuu[idx].tyouten[midx-i].no-1].value != hyouka_data_koyuu[idx].tyouten[midx-i].v){
		   hyouka_data_koyuu[idx].tyouten[midx-i].v = c.zigzagdata[hyouka_data_koyuu[idx].tyouten[midx-i].no-1].value;
		   hyouka_data_koyuu[idx].tyouten[midx-i].t = c.zigzagdata[hyouka_data_koyuu[idx].tyouten[midx-i].no-1].time;
		   bchg = true;
		}
	}
	if(bchg==true){

            //形になっているか判定
            real_point A,M,C,B,D,E;
            //real_point a;
            //real_point　h;

            A.v = hyouka_data_koyuu[idx].tyouten[3].v;/*y*/            A.t = hyouka_data_koyuu[idx].tyouten[3].t;//x
            B.v = hyouka_data_koyuu[idx].tyouten[2].v;/*y*/            B.t = hyouka_data_koyuu[idx].tyouten[2].t;//x
            C.v = hyouka_data_koyuu[idx].tyouten[1].v;/*y*/            C.t = hyouka_data_koyuu[idx].tyouten[1].t;//x
            D.v = hyouka_data_koyuu[idx].tyouten[0].v;/*y*/            D.t = hyouka_data_koyuu[idx].tyouten[0].t;//x
           if(    A.v >C.v && B.v > D.v){
			   return 1;
		   }else{
			   return 2;
		   }
        


	   
	}
	return 0;

}
bool    TradeMethod_B1_1::add_hyouka_data_koyuu(int para_refidx){
    bool ret = false;
    if(hyouka_data_koyuu_num > 0){
        //最後のものと異なっていたら追加
        if( hyouka_data_koyuu[hyouka_data_koyuu_num-1].last_zigidx != para_refidx){
            ret = true;
        }
    }else{// 初回は無条件で追加
        ret = true;
	 }

    if(ret == true){
		//mem
		  chk_mem_hyouka_data_koyuu(hyouka_data_koyuu_num+1);

		//init && reg

        hyouka_data_koyuu[hyouka_data_koyuu_num].tyouten[0]=cn_out[0];
        hyouka_data_koyuu[hyouka_data_koyuu_num].tyouten[1]=cn_out[1];
        hyouka_data_koyuu[hyouka_data_koyuu_num].tyouten[2]=cn_out[2];
        hyouka_data_koyuu[hyouka_data_koyuu_num].tyouten[3]=cn_out[3];
        //hyouka_data_koyuu[hyouka_data_koyuu_num].tyouten[4]=cn_out[4];
        hyouka_data_koyuu[hyouka_data_koyuu_num].last_zigidx = para_refidx;
        hyouka_data_koyuu[hyouka_data_koyuu_num].first_zigidx = cn_out[3].no-1;

        hyouka_data_koyuu_num++;

    	//// view mark 
    	//double now = candle.close[ZIGZAG_BUFFER_MAX_NUM-1];
    	//datetime now_time = candle.time[ZIGZAG_BUFFER_MAX_NUM-1];
    	//view_start(now,now_time, IntegerToString(hyouka_data_koyuu_num));

        
	}
    return(ret);
}
//bool    TradeMethod_B1_1::Is_pattern(void){
//    int base_idx = candle.zigzagdata_count-1;
//	return(Is_pattern(base_idx));
//}
bool    TradeMethod_B1_1::Is_pattern(int base_idx){  //  基準となるzigzagcountからー１した値　　　　 int base_idx = candle.zigzagdata_count-1;
    bool ret = false;
    
   //初回の前提条件が成立したかどうか確認
   //　成立時、キーも取得・保持が必要（キーとする）　　　AorE点のどちらかのZigＺａｇＣｏｕｎｔ
    
    ret = Is_pattern();
    return(ret);
}






//void test_kiriage_channel_kakutei(void){
bool    TradeMethod_B1_1::Is_pattern(void){// 成否返す。成立時　last_zigzag_E, Aの点、cn_outのABCDEの点を保持する
    bool ret = false;
    int out_dir=0;
    int chk_zigcount;
    static int t_zigzag_count=0;
    static int pre_t_zigzag_count =-1;
    static int pre_E_no = -1;
    static int viewed = 0;
    //allcandle *pac = p_allcandle;//pac global dell
    //if(pac==NULL){return;}


    //上位足からのキャンドルポインタを取得して、パターンを判断する。下記を使用する。
    //candle_data *allcandle::get_updown_TimeFrame(int updn,ENUM_TIMEFRAMES period){// updn分TimeFrameを変更したcandle_dataのPointerを取得

//    candle_data *c=candle;//pac.get_candle_data_pointer(PERIOD_M15);
    //int timeframes_chg_to_upper_num=2;// 何個上にするか？
    candle_data *c=p_allcandle.get_updown_TimeFrame(timeframes_chg_to_upper_num,p_allcandle.Inp_base_time_frame);

    if(c!=NULL){
        chk_zigcount=c.zigzagdata_count;
        
        if(c.zigzagdata_count >10 && pre_t_zigzag_count != c.zigzagdata_count
         && c.zigzag_chg_flag==true&&        (c.zigzag_chg_flag_status==1||c.zigzag_chg_flag_status==0||c.zigzag_chg_flag_status==-1)
        ){
 //         	//n個分の　目線の切り替わり＋続伸の線分を取得する(中途半場は除く（切り替わり線分と続伸線分を取得）)
//         	//新しい点を配列の０へ格納
//         	bool get_mesen_Cn_kirikawari_zokusin(int n,struct_mesen_tyouten_zokushin &cn_out[]){
//         		bool ret = false;
            //struct_mesen_tyouten_zokushin *cn_out;
			   //cn_out=&tmp_tyouten;
            //bool ret_kirikawari_sokusin =               c.get_mesen_Cn_kirikawari_zokusin(5, cn_out);
            bool ret_kirikawari = false;
            bool ret_kirikawari_sokusin = false;
            if(c.zigzagdata_count > 6){
                for(int i=0;i<5;i++){
                    int idx =       c.zigzagdata_count-1-i;
                    cn_out[i].v=    c.zigzagdata[idx].value;
                    cn_out[i].t=    c.zigzagdata[idx].time;
                    cn_out[i].dir=  c.zigzagdata[idx].kind;
                    cn_out[i].no=   idx+1;
                }


            }


#ifdef comment
A
        C
    B

		    D			
#endif //comment
            //形になっているか判定
            real_point A,M,C,B,D,E,F,G;
            //real_point a;
            //real_point　h;

            A.v = cn_out[3].v;/*y*/            A.t = cn_out[3].t;//x
            B.v = cn_out[2].v;/*y*/            B.t = cn_out[2].t;//x
            C.v = cn_out[1].v;/*y*/            C.t = cn_out[1].t;//x
            D.v = cn_out[0].v;/*y*/            D.t = cn_out[0].t;//x
            
           if(   A.v >C.v && B.v > D.v &&pre_E_no!= cn_out[0].no ){
            
            //if(E.v >D.v && C.v > B.v && C.v > D.v && A.v>B.v&& A.v < C.v&& D.v > B.v && E.v > C.v){
                // A and D  same price
                //view
                pre_E_no = cn_out[0].no;
                //BCが目線が切り替わったときが条件
                int zigidx = cn_out[0].no-1;
                bool joukenn=false;
                joukenn = true;
                if( joukenn==true){

#ifdef USE_View_Pattern_data_A_E_out_Line
                    for(int nn=0;nn<4-1;nn++){
                       string name1 = name+"PPPtn"+IntegerToString(cn_out[nn].no-1)+"_"+IntegerToString(cn_out[nn+1].no-1)+
                        "("+IntegerToString(cn_out[3].no-1)+"_"+IntegerToString(cn_out[0].no-1)+")";
                       
                       //TrendCreate(0,name1,0,cn_out[nn].t,cn_out[nn].v    ,cn_out[nn+1].t,cn_out[nn+1].v,clrWhiteSmoke,STYLE_SOLID,7);
                       c.CreateTline(0,name1,0,cn_out[nn].t,cn_out[nn].v    ,cn_out[nn+1].t,cn_out[nn+1].v,clrWhiteSmoke,STYLE_SOLID,7,name);
                    }
#endif //USE_View_Pattern_data_A_E_out_Line
#ifdef USE_View_Pattern_data_A_E_out_debugwindow                    
                    printf("###"+IntegerToString(cn_out[0].no-1));
                    printf("   "+"idx="+IntegerToString(cn_out[3].no-1)+":  "+DoubleToString(A.v,2)+"  "+TimeToString(A.t));
                    printf("   "+"idx="+IntegerToString(cn_out[2].no-1)+":  "+DoubleToString(B.v,2)+"  "+TimeToString(B.t));
                    printf("   "+"idx="+IntegerToString(cn_out[1].no-1)+":  "+DoubleToString(C.v,2)+"  "+TimeToString(C.t));
                    printf("   "+"idx="+IntegerToString(cn_out[0].no-1)+":  "+DoubleToString(D.v,2)+"  "+TimeToString(D.t));
                   // printf("   "+"idx="+IntegerToString(cn_out[0].no-1)+":  "+DoubleToString(E.v,2)+"  "+TimeToString(E.t));
#endif //USE_View_Pattern_data_A_E_out_debugwindow                    
                   
#ifdef USE_debug_USE_View_Pattern_data_A_E_out_debugwindow
					//F 
					//G　point  ＣＥとFＧ（ｅとおるＤＥ）
					debug_B1_1_tp_sl(A,B,C,D,E,F,G);
#endif//USE_debug_USE_View_Pattern_data_A_E_out_debugwindow
					




                   t_zigzag_count = c.zigzagdata_count;
#ifdef USE_debug_USE_View_Pattern_data_A_E_out_debugwindow
                   printf("E point zig count(idx)="+IntegerToString(t_zigzag_count-1));
#endif//USE_debug_USE_View_Pattern_data_A_E_out_debugwindow
                   viewed=1;
                   last_zigidx_E=cn_out[0].no-1;
                   first_zigidx_A=cn_out[3].no-1;

                   pre_t_zigzag_count = c.zigzagdata_count;
                   ret = true;
				   
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
        //pre_t_zigzag_count = t_zigzag_count;
    }

    return ret;
}



void TradeMethod_B1_1::debug_B1_1_tp_sl(real_point &A,real_point &B,real_point &C,real_point &D,real_point &E,real_point& F,real_point &G){
							move_LineAB_To_startpointC(C,E,D,F);
							move_LineAB_To_startpointC(D,E,F,G);
							double dd_chanell = cal_point_line_dist(C,E,D);

							bool b_same_A_D=false;
							if(dd_chanell*0.05> MathAbs(A.v-D.v)){
								b_same_A_D=true;
							}

							double dd_F_G_rieki = MathAbs(F.v-G.v);
							double dd_F_D_sl = MathAbs(F.v-D.v);
							double dd_F_B_sl = MathAbs(F.v-B.v);
							double dd_F_A_sl = MathAbs(F.v-A.v);

							printf("   b_same_A_D="+IntegerToString(b_same_A_D));
							printf("   dd_F_G_rieki="+getPips(dd_F_G_rieki));
							printf("   dd_F_D_sl=   "+getPips(dd_F_D_sl));
							printf("   dd_F_A_sl=   "+getPips(dd_F_A_sl));
							printf("   dd_F_B_sl=   "+getPips(dd_F_B_sl));
}

void TradeMethod_B1_1::debug_B1_1_tp_sl_All(void){
   printf("勝ち負け"+":"+"pips"+":"+"lastzig"+":"+"b_same_A_D="+":"+"   dd_F_G_rieki="+":"+"   dd_F_D_sl=   "+":"+"   dd_F_A_sl=   "+":"+"   dd_F_B_sl=   ");
   for(int i = 0;i< hyouka_data_koyuu_num;i++){
      if(hyouka_data[i].status ==999){
         debug_B1_1_tp_sl_idx(i);
      }
   }
}

void TradeMethod_B1_1::debug_B1_1_tp_sl_idx(int idx){

   real_point A,B,C,D,E,F,G;
   
   
   A.v = hyouka_data_koyuu[idx].tyouten[4].v;/*y*/            A.t = hyouka_data_koyuu[idx].tyouten[4].t;//x
   B.v = hyouka_data_koyuu[idx].tyouten[3].v;/*y*/            B.t = hyouka_data_koyuu[idx].tyouten[3].t;//x
   C.v = hyouka_data_koyuu[idx].tyouten[2].v;/*y*/            C.t = hyouka_data_koyuu[idx].tyouten[2].t;//x
   D.v = hyouka_data_koyuu[idx].tyouten[1].v;/*y*/            D.t = hyouka_data_koyuu[idx].tyouten[1].t;//x
   E.v = hyouka_data_koyuu[idx].tyouten[0].v;/*y*/            E.t = hyouka_data_koyuu[idx].tyouten[0].t;//x

	move_LineAB_To_startpointC(C,E,D,F);
	move_LineAB_To_startpointC(D,E,F,G);
	double dd_chanell = cal_point_line_dist(C,E,D);

	bool b_same_A_D=false;
	if(dd_chanell*0.05> MathAbs(A.v-D.v)){
		b_same_A_D=true;
	}

	double dd_F_G_rieki = MathAbs(F.v-G.v);
	double dd_F_D_sl = MathAbs(F.v-D.v);
	double dd_F_B_sl = MathAbs(F.v-B.v);
	double dd_F_A_sl = MathAbs(F.v-A.v);

   //printf("aaaa="+IntegerToString(hyouka_data[idx].reg_ikey));
   int wl=0;
   if(hyouka_data[idx].exit_v>hyouka_data[idx].entry_v){
      wl = 1;
   }

   printf(IntegerToString( hyouka_data[idx].winloss ) +":"+ getPips(hyouka_data[idx].exit_v-hyouka_data[idx].entry_v)+":"+
     IntegerToString( hyouka_data_koyuu[idx].last_zigidx)+":"+
     IntegerToString(b_same_A_D)+":"+
     getPips(dd_F_G_rieki)+":"+
     getPips(dd_F_D_sl)+":"+
     getPips(dd_F_A_sl)+":"+
     getPips(dd_F_B_sl)
     );
}

#endif//classTradeMethod_B1_1



