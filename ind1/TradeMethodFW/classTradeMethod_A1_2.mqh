#ifndef classTradeMethod_A1_2
#define classTradeMethod_A1_2

#include "..\class_candle_data.mqh"
#include "..\class_allcandle.mqh"
#include "..\lib\lib_file_func.mqh"
#include <_inc\\My_function_lib2.mqh>
#include "..\lib\lib_xy_func.mqh"
#include "classTradeMethodbase.mqh"



extern datetime pre_timeM1;
class TradeMethod_A1_2 :public TradeMethodbase 
{
public:
   int hyouka_data_koyuu_num;

	//--- コンストラクタとデストラクタ
	TradeMethod_A1_2(void){};
	TradeMethod_A1_2(string s,ENUM_TIMEFRAMES p,candle_data *c,allcandle *a){name = s;period = p;candle = c; p_allcandle = a;hyouka_data_koyuu_num=0;
		init_mem_hyouka_data_koyuu();
	};
	~TradeMethod_A1_2(void){view_kekka_youso(1);};
	//--- オブジェクトを初期化する
   void Oninit(void){}
   void OnDeinit(const int reason){
      debug_A1_tp_sl_All();
      kekka_calc();printf("instantA1");
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
		
		bool isnew_bar=p_allcandle.flagchgbarM15;//　tbd ★★どのの時間軸使用するかは。。。使用するcandleのフラグにした方が良い
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
void debug_A1_tp_sl(real_point &A,real_point &B,real_point &C,real_point &D,real_point &E,real_point &F,real_point &G);
void TradeMethod_A1_2::debug_A1_tp_sl_All(void);
void debug_A1_tp_sl_idx(int idx);
    
};//end class def


void TradeMethod_A1_2::hyouka_zig_kakutei(void){ // 足確定で呼ばれる想定
// 
//real_point　zzzz;
	real_point a,b,c,d,e,f,nn;
	double sa;//基準値からの損益価格
	double sa_pips;
    //追加必要か？
    // パターン成立したか？
 //       //Zigzag変化したとき
//        if(candle.zigzag_chg_flag==true){
   		if(candle.zigzag_chg_flag==true&&      
   		  (candle.zigzag_chg_flag_status==1||candle.zigzag_chg_flag_status==0||candle.zigzag_chg_flag_status==-1)){
            //パターン成立
            if(Is_pattern()){
   						
                //評価データに追加、状態を１へ、重複しないように同じZigzagパターン番号の時で既にあるなら追加しない。（add処理で実現）
                //get_pattern_key_id(&key_id);
                add_hyouka_data(last_zigidx_E);
                

                
            }
		}
//    	}
    //

    //
   double now = candle.close[ZIGZAG_BUFFER_MAX_NUM-1];
   datetime now_time = candle.time[ZIGZAG_BUFFER_MAX_NUM-1];
   nn.v=now;
   nn.t=now_time;
   bool ret_channel=false;
   bool flag_exit_syori=false;
   real_point A,M,C,B,D,E;
   int ret_b_up=false;
   for(int i = 0; i<hyouka_data_num ;i++){
      switch(hyouka_data[i].status){
         case 1:// CEラインがD通ったライン付近に現在値がなったか？
         	//////////////////////////////
         	//** 評価パターン０：
         	//////////////////////////////
            

			//Eの場所かの判断はBDの平行線をCを起点にして、CEのラインの上下ddの5%以内に入ったらTrue
			//          D
			//    B
			//            E         
			//A     C
			//  x 
			//  p1=A,p2=B,p3=C,p4=D,(p5=E)
			//チャネルBD、CEのEの部分になっているか？ CE線分の延長線上の　距離（BDとCの距離）の5％（10％の幅）範囲内ならtrueを返す
			//bool chk_WithInRange_chanell_E_point(real_point &p1,real_point &p2,real_point &p3,real_point &p4,real_point &nowpoint,real_point &p5_e){
			//  bool ret = false;
			//  imi_point a,b,c,d,e,n;
			
			a.t=hyouka_data_koyuu[i].tyouten[4].t;a.v=hyouka_data_koyuu[i].tyouten[4].v;  
			b.t=hyouka_data_koyuu[i].tyouten[3].t;b.v=hyouka_data_koyuu[i].tyouten[3].v;  
			c.t=hyouka_data_koyuu[i].tyouten[2].t;c.v=hyouka_data_koyuu[i].tyouten[2].v;  
			d.t=hyouka_data_koyuu[i].tyouten[1].t;d.v=hyouka_data_koyuu[i].tyouten[1].v;  
			e.t=hyouka_data_koyuu[i].tyouten[0].t;e.v=hyouka_data_koyuu[i].tyouten[0].v;  
			//A(x)BCD  (ACDE)
			ret_channel=	chk_WithInRange_chanell_E_point(a,c,d,e, nn,f)  ;

			//エントリーできるか   
			if(ret_channel == true){

				//エントリー
				entry_syori(i,now,now_time,1);// buyの形
				//エントリー後の状態へ移行
				hyouka_data[i].status =2;
			}else if(candle.zigzag_chg_flag==true&&candle.zigzag_chg_flag_status==0){
				//登録後Zigが変更になったかどうか確認し、更新
				int iret=
				chk_chg_zigdata_for_pt(i);
				if(iret ==2){ //ptと形が異なるようになったので　無効化へ
					hyouka_data[i].status = 0;
				}
			}

		
	
			break;
         case 2://エントリー中
			//Exitか？
			   
			//CEにタッチしたらExit		勝ち
            //形になっているか判定
            //real_point A,M,C,B,D,E;
            //real_point a;
            //real_point　h;

            A.v = hyouka_data_koyuu[i].tyouten[4].v;/*y*/            A.t = hyouka_data_koyuu[i].tyouten[4].t;//x
            B.v = hyouka_data_koyuu[i].tyouten[3].v;/*y*/            B.t = hyouka_data_koyuu[i].tyouten[3].t;//x
            C.v = hyouka_data_koyuu[i].tyouten[2].v;/*y*/            C.t = hyouka_data_koyuu[i].tyouten[2].t;//x
            D.v = hyouka_data_koyuu[i].tyouten[1].v;/*y*/            D.t = hyouka_data_koyuu[i].tyouten[1].t;//x
            E.v = hyouka_data_koyuu[i].tyouten[0].v;/*y*/            E.t = hyouka_data_koyuu[i].tyouten[0].t;//x
				//線分abと点cの位置関係を知る(上か下か線上か？)
      				//int chk_point_line_upperordownside(real_point &a,real_point &b,real_point &c){
      				//int ret=0;//上：1　下-1、　線分上0
            ret_b_up=chk_point_line_upperordownside(C,E,nn);
            if(ret_b_up == 1||ret_b_up == 0){//上のチャネルにぶつかる
               //exit syori
               flag_exit_syori=true;
//            }else if(A.v>nn.v){ //Aのラインを下に割る
            }else if(B.v>nn.v){ //Bのラインを下に割る
      			//A未満になったらExit			前提条件が崩れているので撤退
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
         			+"   ikey="+IntegerToString(hyouka_data[i].reg_ikey)
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
int TradeMethod_A1_2::chk_chg_zigdata_for_pt(int idx){// 更新し、値を変更した1（パターン成立）、未変更０、パターン成立しない２
   bool bchg=false;
	for(int i=0;i<5;i++){
		if(candle.zigzagdata[hyouka_data_koyuu[idx].tyouten[4-i].no-1].value != hyouka_data_koyuu[idx].tyouten[4-i].v){
		   hyouka_data_koyuu[idx].tyouten[4-i].v = candle.zigzagdata[hyouka_data_koyuu[idx].tyouten[4-i].no-1].value;
		   hyouka_data_koyuu[idx].tyouten[4-i].t = candle.zigzagdata[hyouka_data_koyuu[idx].tyouten[4-i].no-1].time;
		   bchg = true;
		}
	}
	if(bchg==true){

            //形になっているか判定
            real_point A,M,C,B,D,E;
            //real_point a;
            //real_point　h;

            A.v = hyouka_data_koyuu[idx].tyouten[4].v;/*y*/            A.t = hyouka_data_koyuu[idx].tyouten[4].t;//x
            B.v = hyouka_data_koyuu[idx].tyouten[3].v;/*y*/            B.t = hyouka_data_koyuu[idx].tyouten[3].t;//x
            C.v = hyouka_data_koyuu[idx].tyouten[2].v;/*y*/            C.t = hyouka_data_koyuu[idx].tyouten[2].t;//x
            D.v = hyouka_data_koyuu[idx].tyouten[1].v;/*y*/            D.t = hyouka_data_koyuu[idx].tyouten[1].t;//x
            E.v = hyouka_data_koyuu[idx].tyouten[0].v;/*y*/            E.t = hyouka_data_koyuu[idx].tyouten[0].t;//x
           if(   E.v >D.v && C.v > B.v && C.v > D.v &&                       D.v > B.v && E.v > C.v  &&A.v>B.v && A.v < C.v){
			   return 1;
		   }else{
			   return 2;
		   }
        


	   
	}
	return 0;

}
bool    TradeMethod_A1_2::add_hyouka_data_koyuu(int para_refidx){
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
        hyouka_data_koyuu[hyouka_data_koyuu_num].tyouten[4]=cn_out[4];
        hyouka_data_koyuu[hyouka_data_koyuu_num].last_zigidx = para_refidx;
        hyouka_data_koyuu[hyouka_data_koyuu_num].first_zigidx = cn_out[4].no-1;

        hyouka_data_koyuu_num++;

    	//// view mark 
    	//double now = candle.close[ZIGZAG_BUFFER_MAX_NUM-1];
    	//datetime now_time = candle.time[ZIGZAG_BUFFER_MAX_NUM-1];
    	//view_start(now,now_time, IntegerToString(hyouka_data_koyuu_num));

        
	}
    return(ret);
}
//bool    TradeMethod_A1_2::Is_pattern(void){
//    int base_idx = candle.zigzagdata_count-1;
//	return(Is_pattern(base_idx));
//}
bool    TradeMethod_A1_2::Is_pattern(int base_idx){  //  基準となるzigzagcountからー１した値　　　　 int base_idx = candle.zigzagdata_count-1;
    bool ret = false;
    
   //初回の前提条件が成立したかどうか確認
   //　成立時、キーも取得・保持が必要（キーとする）　　　AorE点のどちらかのZigＺａｇＣｏｕｎｔ
    
    ret = Is_pattern();
    return(ret);
}






//void test_kiriage_channel_kakutei(void){
bool    TradeMethod_A1_2::Is_pattern(void){// 成否返す。成立時　last_zigzag_E, Aの点、cn_outのABCDEの点を保持する
    bool ret = false;
    int out_dir=0;
    int chk_zigcount;
    static int t_zigzag_count=0;
    static int pre_t_zigzag_count =-1;
    static int pre_E_no = -1;
    static int viewed = 0;
    //allcandle *pac = p_allcandle;//pac global dell
    //if(pac==NULL){return;}
    candle_data *c=candle;//pac.get_candle_data_pointer(PERIOD_M15);
    if(c!=NULL){
        chk_zigcount=c.zigzagdata_count;
        
        if(c.zigzagdata_count >400 && pre_t_zigzag_count != c.zigzagdata_count
         && c.zigzag_chg_flag==true&&        (c.zigzag_chg_flag_status==1||c.zigzag_chg_flag_status==0||c.zigzag_chg_flag_status==-1)
        ){
 //         	//n個分の　目線の切り替わり＋続伸の線分を取得する(中途半場は除く（切り替わり線分と続伸線分を取得）)
//         	//新しい点を配列の０へ格納
//         	bool get_mesen_Cn_kirikawari_zokusin(int n,struct_mesen_tyouten_zokushin &cn_out[]){
//         		bool ret = false;
            //struct_mesen_tyouten_zokushin *cn_out;
			   //cn_out=&tmp_tyouten;
            bool ret_kirikawari_sokusin =               c.get_mesen_Cn_kirikawari_zokusin(5, cn_out);

#ifdef comment
						G
                E
        C
                    F
A           D

    B
#endif //comment
            //形になっているか判定
            real_point A,M,C,B,D,E,F,G;
            //real_point a;
            //real_point　h;

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
                       
                       //TrendCreate(0,name1,0,cn_out[nn].t,cn_out[nn].v    ,cn_out[nn+1].t,cn_out[nn+1].v,clrWhiteSmoke,STYLE_SOLID,7);
                       c.CreateTline(0,name1,0,cn_out[nn].t,cn_out[nn].v    ,cn_out[nn+1].t,cn_out[nn+1].v,clrWhiteSmoke,STYLE_SOLID,7,name);
                    }
                    printf("###"+IntegerToString(cn_out[0].no-1));
                    printf("   "+"idx="+IntegerToString(cn_out[4].no-1)+":  "+DoubleToString(A.v,2)+"  "+TimeToString(A.t));
                    printf("   "+"idx="+IntegerToString(cn_out[3].no-1)+":  "+DoubleToString(B.v,2)+"  "+TimeToString(B.t));
                    printf("   "+"idx="+IntegerToString(cn_out[2].no-1)+":  "+DoubleToString(C.v,2)+"  "+TimeToString(C.t));
                    printf("   "+"idx="+IntegerToString(cn_out[1].no-1)+":  "+DoubleToString(D.v,2)+"  "+TimeToString(D.t));
                    printf("   "+"idx="+IntegerToString(cn_out[0].no-1)+":  "+DoubleToString(E.v,2)+"  "+TimeToString(E.t));
                    
                   
					//F 
					//G　point  ＣＥとFＧ（ｅとおるＤＥ）
					debug_A1_tp_sl(A,B,C,D,E,F,G);
					




                   t_zigzag_count = c.zigzagdata_count;
                   printf("E point zig count(idx)="+IntegerToString(t_zigzag_count-1));
                   viewed=1;
                   last_zigidx_E=cn_out[0].no-1;
                   first_zigidx_A=cn_out[4].no-1;
                      ret =true;
				   
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
    return ret;
}



void TradeMethod_A1_2::debug_A1_tp_sl(real_point &A,real_point &B,real_point &C,real_point &D,real_point &E,real_point& F,real_point &G){
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

void TradeMethod_A1_2::debug_A1_tp_sl_All(void){
   printf("勝ち負け"+":"+"pips"+":"+"lastzig"+":"+"b_same_A_D="+":"+"   dd_F_G_rieki="+":"+"   dd_F_D_sl=   "+":"+"   dd_F_A_sl=   "+":"+"   dd_F_B_sl=   ");
   for(int i = 0;i< hyouka_data_koyuu_num;i++){
      if(hyouka_data[i].status ==999){
         debug_A1_tp_sl_idx(i);
      }
   }
}

void TradeMethod_A1_2::debug_A1_tp_sl_idx(int idx){

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

#endif//classTradeMethod_A1_2



