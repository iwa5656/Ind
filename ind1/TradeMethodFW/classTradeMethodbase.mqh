#ifndef classTradeMethodbase
#define classTradeMethodbase
#include "..\class_candle_data.mqh"
#include "..\class_allcandle.mqh"
#include "..\lib\lib_file_func.mqh"
#include <_inc\\My_function_lib2.mqh>
#define USE_debug_view_pattern_exit
//extern datetime pre_timeM1;
class TradeMethodbase
{
public:


	int			hyouka_data_num;
	string      name;//method name
    int EntryNo;
	ENUM_TIMEFRAMES period;
	// candle オブジェクトポインタ（キャンドル情報と変化点情報）
	allcandle *p_allcandle;
	candle_data *candle;



	#define NUM_OF_HYOUKA_PATTERN 1
	#define NUM_OF_KEKKA_YOUSO 47
	struct struct_hyouka_data{
		int status;//0は無効   999が完了
		int reg_ikey;//特定キー、例；固有データのidx	
		int ref_koyuu_data;//対象配列のステータスの固有データへの配列番号（　評価と同じidxでもよい）

		int winloss;//0どちらでもない（キャンセル）、-1負け、１勝
		double entry_v;
		datetime entry_t;
		double exit_v;
		datetime exit_t;
		int dir;//0無効、１ｂｕｙ、-1　sell
		int Ind_EntryNo;//EntryNoの記憶用



		int reg_zigzagcount;//登録時のカウント数（add処理で同一か見るため）
        int reg_patterncount;//登録時のカウント数（add処理で同一か見るため）
		double v[10];// 1から　zigzag1,2,3,4,5,6,7,8,9の値　　パターン確定時の起点が１
		double i[10];// 0:  
		double max;
		double min;
		double kekka[NUM_OF_HYOUKA_PATTERN][NUM_OF_KEKKA_YOUSO];// [n][*] n評価パターン
		    //[*][0]:評価パターンの状態　１集計中　それ以外集計していない 完了は　－1
		    //[*][1]:max　勝ち方向
		    //[*][2]:min　負け方向
		    //[*][3]:　勝ち負け　勝１、負けー１
		    //[*][4]:　抜けたときの確定足とラインとの距離
		    //[*][5]:　３－４距離
		    //[*][6]:　６－４距離
	
	};
	//double kekka_matome[10][10];// [n][*] nは評価パターン、　[n][j]  j＝ 0 数、1：勝ち数、２：負け数、３：勝ちPIPS，４：負けPIPS，５：PF，６：，７：　
	
	
	
	//結果まとめ
	// [n][*] nは評価パターン、　[n][j]  j＝ 0 数、1：勝ち数、２：負け数、３：勝ちPIPS，４：負けPIPS，５：PF，６：，７：　
	//	
	//勝ち負け数
	//勝ち数
	int count_of_win;
	//負け数
	int count_of_loss;
	//勝ちPips合計
	double sum_win_Pips;
	//負けPips合計
	double sum_loss_Pips;
	//PF
	double pf;


	//#define NUMOFMAX_HYOUKA_DATA 100000
	#define NUM_YOBI_HYOUKA_DATA_MEM 10 // Mem予備
	struct_hyouka_data hyouka_data[];
	
	//--- コンストラクタとデストラクタ
	TradeMethodbase(void){};
	TradeMethodbase(string s,ENUM_TIMEFRAMES p,candle_data *c,allcandle *a){name = s;period = p;candle = c; p_allcandle = a;hyouka_data_num=0;
		init_mem_hyouka_data();
	};
	~TradeMethodbase(void){kekka_calc();};
	

	//--- オブジェクトを初期化する
    //関数
	void init_mem_hyouka_data(void){init_mem_hyouka_data_base();init_mem_hyouka_data_koyuu();}
	virtual void init_mem_hyouka_data_base(void){
		ArrayResize(hyouka_data,1,NUM_YOBI_HYOUKA_DATA_MEM); 
	}
	virtual void init_mem_hyouka_data_koyuu(void){
		//koyuu
	}
	

	
		
	
	virtual void chk_mem_hyouka_data(int i){
		int m=hyouka_data_num;
		if(hyouka_data_num < i){
			m=i+1;
		}
		ArrayResize(hyouka_data,i,NUM_YOBI_HYOUKA_DATA_MEM);
	}

	virtual int		hyouka(void){//　評価・状態遷移含む処理
		//
		//bool isnew_bar=p_allcandle.flagchgbarM15;//　tbd ★★どのの時間軸使用するかは。。。使用するcandleのフラグにした方が良い
  		//if(isnew_bar == true){
		//	hyouka_kakutei();
		//}
		//if(candle.zigzag_chg_flag==true&&      
		//  (candle.zigzag_chg_flag_status==1||candle.zigzag_chg_flag_status==0||candle.zigzag_chg_flag_status==-1)){
		//	  hyouka_zig_kakutei();
		//}
		return 0;
	}
	virtual void hyouka_tick(void){}
	virtual void hyouka_zig_kakutei(void){}
	virtual void hyouka_kakutei(void){}

//	int     hyouka_tick(void);//Tickの細かい処理　Entryとか　　
    bool    add_hyouka_data(int para_ikey){
      bool r1,r2,ret;
      ret=false;
		r1=add_hyouka_data_base(para_ikey);
		if(r1==true){
   		r2=add_hyouka_data_koyuu(para_ikey);
   		if(r2==true){ret = true;}
      }
      return ret;   
		
	}
	virtual void link_hyouka_data_base_to_koyuu_Set_koyuu_data_idx(int idx_hyouka_base,int idx_hyouka_koyuu){
		hyouka_data[idx_hyouka_base].ref_koyuu_data = idx_hyouka_koyuu;
	}
    virtual bool    add_hyouka_data_base(int para_ikey){
		bool ret = false;	
		if(hyouka_data_num > 0){
			//最後のものと異なっていたら追加
			if( hyouka_data[hyouka_data_num-1].reg_ikey != para_ikey){
				ret = true;
			}
		}else{// 初回は無条件で追加
			ret = true;
		}
		if(ret == true){
			bool bretget=true;
			//mem
			chk_mem_hyouka_data(hyouka_data_num+1);
			hyouka_data[hyouka_data_num].status = 1;//状態初期へ
			hyouka_data[hyouka_data_num].reg_ikey = para_ikey;
			hyouka_data_num++;

       	// view mark 
       	double now = candle.close[ZIGZAG_BUFFER_MAX_NUM-1];
       	datetime now_time = candle.time[ZIGZAG_BUFFER_MAX_NUM-1];
       	view_start(now,now_time, IntegerToString(hyouka_data_num));
       				
		}
		return ret;
	}
    virtual bool    add_hyouka_data_koyuu(int para_ikey){return(false);};
	



    virtual bool    Is_pattern(void);// 直近のZigzagから評価
    virtual bool    Is_pattern(int base_idx);// 指定したzigzagcount－１　の時のパターン成立状態

	void init_hyouka_data( struct_hyouka_data &d);
   virtual void kekka_calc(void){
       //init kekka_matome
   	//勝ち数
   	count_of_win=0;
   	//負け数
   	count_of_loss=0;
   	//勝ちPips合計
   	sum_win_Pips=0.0;
   	//負けPips合計
   	sum_loss_Pips=0.0;
   	//PF
   	pf=0.0;
       double ddd=0.0;
       for(int i = 0; i<hyouka_data_num ;i++){
           if(hyouka_data[i].status == 999){
            ddd=hyouka_data[i].exit_v-hyouka_data[i].entry_v;
            if(ddd==0.0){hyouka_data[i].winloss=0;}
            else if(hyouka_data[i].dir == 1 && ddd>0){hyouka_data[i].winloss=1;}
            else if(hyouka_data[i].dir == 1 && ddd<0){hyouka_data[i].winloss=-1;}
            else if(hyouka_data[i].dir == -1 && ddd>0){hyouka_data[i].winloss=-1;}
            else if(hyouka_data[i].dir == -1 && ddd<0){hyouka_data[i].winloss=1;}
           
   			if(hyouka_data[i].winloss==1){
   				//win
   				sum_win_Pips=sum_win_Pips+MathAbs(hyouka_data[i].entry_v-hyouka_data[i].exit_v);
   				count_of_win++;
   
   			}else if(hyouka_data[i].winloss==-1){
   				sum_loss_Pips=sum_loss_Pips+MathAbs(hyouka_data[i].entry_v-hyouka_data[i].exit_v);
   				//loss
   				count_of_loss++;
   			}
   		}
   	}
   
   	//syouritu
   	double syouritu = 99999;
   	if((count_of_win+count_of_loss)>0){syouritu = (double)count_of_win/ (double)(count_of_win+count_of_loss);	}	
   	//makeritu
   	double makeritu = 1.0-syouritu;
   	//期待値
   	double kitaichi = 99999;
   	if(count_of_win!=0 && count_of_loss!=0){
   		kitaichi =(double)sum_win_Pips/((double)count_of_win)  *  syouritu  
   		-(double)sum_loss_Pips/((double)count_of_loss) * makeritu;
   	}
   	//pf
   	if(sum_loss_Pips!=0){	pf=sum_win_Pips/sum_loss_Pips; }
   
   
	double tapu_kitaichi=0;
    if(sum_loss_Pips!=0){   tapu_kitaichi =kitaichi/(sum_loss_Pips); }
	
	//"タープ期待値" ：負けトレード１通貨あたりの期待値="+DoubleToString(kitaichi/(losspips*(-1)))); }else{printf("");}
        
   	
   	if(count_of_win!=0 && count_of_loss!=0){
		printf("★TimeFrame="+EnumToString(candle.Inp_base_time_frame));
   		printf(
   		"★結果:name="+ name+" ; "+
   		"数="+IntegerToString((int)count_of_win + count_of_loss)+" ; "+
   		"勝数="+IntegerToString((int)count_of_win)+" ; "+
   		"負数="+IntegerToString((int)count_of_loss)+" ; "+
   		"勝Pips="+getPips(sum_win_Pips)+" ; "+
   		"負Pips="+getPips(sum_loss_Pips)+" ; "+
   		"勝率="+DoubleToString(syouritu,3 )+" ; "+
   		"期待値="+getPips( 
   					kitaichi
   				
   				)+" ; "+
   		"Pf="+DoubleToString(pf,2)+" ; "+
		"タープ期待値="+ DoubleToString(tapu_kitaichi)
   		);
   	}
   
       
   }//end func kekka_calc
	


	void entry_syori(int hyouka_idx,double v,datetime t,int para_dir){
		hyouka_data[hyouka_idx].entry_v = v;hyouka_data[hyouka_idx].entry_t = t;hyouka_data[hyouka_idx].dir = para_dir;
		datetime now_time = candle.time[ZIGZAG_BUFFER_MAX_NUM-1];
		double now = candle.close[ZIGZAG_BUFFER_MAX_NUM-1];
		view_entry(now,now_time,IntegerToString(hyouka_data_num));

		//Entry Send for EA
		//void SetSendData_forEntry_sokuji(int EntryDirect,int hyoukaNo,int hyoukaSyuhouNo,double EntryPrice,double Tp_Price,double Sl_Price,double lots){
		SetSendData_forEntry_sokuji(para_dir,0,0,0.0,0.0,0.0,0.1);// lot は固定で0.1　（変更したい場合は、任意に変えること）
		hyouka_data[hyouka_idx].Ind_EntryNo = Ind_EntryNo;//指定のエントリーのIDを記憶しておく
		

	}
	void exit_syori(int hyouka_idx,double v,datetime t){
		hyouka_data[hyouka_idx].exit_v = v;hyouka_data[hyouka_idx].exit_t = t;
		datetime now_time = candle.time[ZIGZAG_BUFFER_MAX_NUM-1];
		double now = candle.close[ZIGZAG_BUFFER_MAX_NUM-1];
		view_exit(now,now_time,IntegerToString(hyouka_data_num));
		view_entryToExit(hyouka_idx);

		//Exit Send For EA
		SetSendData_forExit(hyouka_data[hyouka_idx].Ind_EntryNo);
		

	}
   void view_entryToExit(int idx);
//\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\


    bool eq_zigzag(int idx1,int idx2,double gosaPips);
    bool lt_zigzag(int idx1,int idx2,double gosaPips);// idx1は2-ｄｄよりも小さい
    bool gt_zigzag(int idx1,int idx2,double gosaPips);// idx１は２＋ｄｄよりもBig
    double Dist_zigzag(int idx1,int idx2,double gosaPips);// 単位は価格
    double Dist_ipips_zigzag(int idx1,int idx2,double gosaPips);// 単位はPips
    int chgKijun2Idx(int base_idx,int idx);// base_idxはっ注目count－１、idxは基準が１として
	double rec_max_min(int i,double now,double v,int direct){ // idx,現在値、基準ライン、方向１が上方向がプラス、-1が下方向がプラスになる
		double tmpv;
		if(direct ==1){//起点より上方向がプラス
			tmpv=now-v;
		}else{
			tmpv=v-now;
		}
		if(tmpv>0){//利益方向
			if(hyouka_data[i].max < tmpv){ hyouka_data[i].max = tmpv;}
		}else{
			if(hyouka_data[i].min > tmpv){ hyouka_data[i].min = tmpv;}
		}
		return tmpv;
	};
	void CreateArrowRightPrice //CreateArrowRightPrice(0,"",0,Time,Price,Color,3)
		(
		long   chart_id,         // chart ID
		string name,             // object name
		int    nwin,             // window index
		datetime Time,           // position of price label by time
		double Price,            // position of price label by vertical
		color  Color,            // text color
		uint    Size             // font size
		);
 void view_start(double now, datetime now_time,string s);
 void view_entry(double now, datetime now_time,string s);
 void view_end(double now, datetime now_time,string s);
 void view_exit(double now, datetime now_time,string s){view_end(now,now_time,s); }
 void view_AB_entyouhasenn(real_point &a,real_point &b,string &name);


 void view_kekka_youso(int n);// n 評価パターン番号
// void init_kekka(double &h[][NUM_OF_KEKKA_YOUSO]);
  string getPips(double d);
 void set_kekkadata_ma(int hyoukaidx,int hyoukaPattern,datetime &t);
 double get_ma_katamuki(int i,datetime &t,ENUM_TIMEFRAMES p);// i 0:8  1:20
 void set_kekkadata_jouiashi(int i,int pttern,datetime t,double price);
 void Oninit(void);
 virtual void OnDeinit(const int reason);
//各処理
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




    
};

#ifdef delll
int TradeMethodbase::hyouka(void){ // 足確定で呼ばれる想定
// 
	double sa;//基準値からの損益価格
	double sa_pips;
    //追加必要か？
    // パターン成立したか？
        //Zigzag変化したとき
        if(candle.zigzag_chg_flag==true){
            //パターン成立
            if(Is_pattern()){
                //評価データに追加、状態を１へ、重複しないように同じZigzagパターン番号の時で既にあるなら追加しない。（add処理で実現）
                add_hyouka_data();
                
                	//２－４のライン価格が必要（４）　←上記で保持
                	
                //debug
                if((hyouka_data_num % 50)==0 && hyouka_data_num!=0){
                    //★20200502debug★view_kekka_youso(1);
                }
                
            }
            
    	}
    //

    //
  	double now = candle.close[ZIGZAG_BUFFER_MAX_NUM-1];
    for(int i = 0; i<hyouka_data_num ;i++){
        switch(hyouka_data[i].status){
            case 1:// ブレークアウトするかの判定
            	//////////////////////////////
            	//** 評価パターン０：
            	//////////////////////////////
            	// ２－４のライン価格が必要（４）v[4]
            	if(hyouka_data[i].v[4] > now){
					//ブレークアウトした、遷移
					hyouka_data[i].status =2;
					sa=rec_max_min(i,now,hyouka_data[i].v[4],-1);
					
					//init
					hyouka_data[i].kekka[0][0]=1;// ①集計用を集計中にする
					hyouka_data[i].kekka[1][0]=1;// ①集計用を集計中にする
					
					//set kekka data　基本データ
					hyouka_data[i].kekka[0][4]= sa;//[*][4]:　抜けたときの確定足とラインとの距離
					//set kekka data　基本データ
					hyouka_data[i].kekka[1][4]= sa;//[*][4]:　抜けたときの確定足とラインとの距離


	// view mark 
	//double now = candle.close[ZIGZAG_BUFFER_MAX_NUM-1];
	datetime now_time = candle.time[ZIGZAG_BUFFER_MAX_NUM-1];
	view_entry(now,now_time, IntegerToString(hyouka_data_num));
	                hyouka_data[i].kekka[1][28]=candle.zigzagdata_count;//entry時の数
	                						

                    //katamuki格納
                    //p_allcandle.get_candle_data_pointer();
					
					//set_kekkadata_ma(i,0,now_time);
					set_kekkadata_ma(i,1,now_time);
					set_kekkadata_jouiashi(i,1,now_time,hyouka_data[i].v[4]);// hyoukadatra idx、pattern No,ブレーク時間、ブレークライン価格
				}
            
                break;
            case 2://ブレークアウトした後のデータ収集
#ifdef commentttt            
            		集計したい内容
            			最大最小を常に計算（足更新毎に？Tick毎に）
            			各終了条件を探す。
            			各条件の終了条件がきたら、Maxを格納する
            			
            			終了条件をずっと超えない場合のために、時間でも終了条件を指定しておく。→４ｈとか？
            			すごく伸びて帰ってこない場合もあるため、伸びすぎの終了条件も用意しておく→2倍伸びたら？
            			★将来的には、ほかの時間軸の状態を出力しておきたい。例RSI、ストキャス、CCIとか、MAのかい離率、ボリンジャーバンドの値？方向？エクスパンション？
            			
            			レジサポ（２－４ライン）、三尊の一番高値３、直近高値１（右の山）、５（左の山）、６（５の↓のポイント）
            			SL：指定（３、１、５とか）
            			TPがどこでまでいくか　SL到達せずにどこまで＋になったか（MAX）、ただし、2倍伸びたらそこで打ち切りor次のZigzagの底が出たら終了とするとか・・・。
            			
            			
            		
            			①基点からブレークして、起点超えず（マイナスならずに）以下の数　　（集計終了するのは起点を超えたら集計終了、それまでは、距離が達成したら成立とする）
	            			１０pips
							１５
	            			２０pips
	            			３と２の距離＊　　23.6　38.2　50　61.8　１００％、１２３、１６１
            			②基点からブレークして、３－２の距離超えず（マイナスならずに）以下の数（集計終了するのは３－２を超えたら・・・）
	            			１０pips
							１５
	            			２０pips
	            			３と２の距離＊　　23.6　38.2　50　61.8　１００％、１２３、１６１
						③ブレークしてからして、１－２の距離超えず（マイナスならずに）以下の数（前回の高値で止まっているか？）　　（１－２を超えたら・・・）
							以下のいずれかでもない数
	            			１０pips
	            			２０pips
	            			３と２の距離＊　　23.6　38.2　50　61.8　１００％、１２３、１６１
						④ブレークしてからして、１－２の距離超えず、３－２の距離分伸びた数（同等伸びる　理論の確認）
						
						⑤全体の終了条件
#endif //commentttt
					sa = rec_max_min(i,now,hyouka_data[i].v[4],-1);
					sa_pips = sa*10*Point();
					//終了条件成立か？
						if(hyouka_data[i].kekka[0][0]==1){
						//終了条件①=結果の0：起点   kekka[0][]
							// 3-4の距離
							double dd34=hyouka_data[i].kekka[0][5];
							double kijun_line = hyouka_data[i].v[4];
							string stmp="勝";

							if(kijun_line < now || now < (kijun_line + dd34)){ 
								hyouka_data[i].kekka[0][1]=hyouka_data[i].max;//[*][1]:max　勝ち方向
								hyouka_data[i].kekka[0][2]=hyouka_data[i].min;//[*][2]:min　負け方向
								if(hyouka_data[i].max >dd34){ 
    								hyouka_data[i].kekka[0][3]=1;//[*][3]:　勝ち負け　勝１、負けー１
    							}else{
    								hyouka_data[i].kekka[0][3]=-1;//[*][3]:　勝ち負け　勝１、負けー１
    								stmp="負";
                                }
//								datetime now_time = candle.time[ZIGZAG_BUFFER_MAX_NUM-1];
//                                view_end(now,now_time,stmp);
								//hyouka_data[i].kekka[0][4]=;//[*][4]:　抜けたときの確定足とラインとの距離
								//hyouka_data[i].kekka[0][5]=dd34;//[*][5]:　３－４距離
								// 6-4の距離
								//double dd64=MathAbs(hyouka_data[i].v[6]-hyouka_data[i].v[4]);
								//hyouka_data[i].kekka[0][6]=;//[*][6]:　６－４距離
								hyouka_data[i].kekka[0][0] =-1;//集計　状態を無効に
								
#ifdef debug_view_kobetu								
								printf("hyouka_data["+IntegerToString(i)+"]=max,min,WorL,dd3-4,dd64,max/dd3-4,min/dd3-4="+
									"\t"+getPips( hyouka_data[i].kekka[0][1])+
									"\t"+getPips( hyouka_data[i].kekka[0][2])+
									"\t"+stmp+
									"\t"+getPips( hyouka_data[i].kekka[0][4])+
									"\t"+getPips( hyouka_data[i].kekka[0][5])+
									"\t"+getPips( hyouka_data[i].kekka[0][6])+
									"**\t"+
									"\t"+DoubleToString( hyouka_data[i].kekka[0][1]/hyouka_data[i].kekka[0][5],1)+
									"\t"+DoubleToString( hyouka_data[i].kekka[0][2]/hyouka_data[i].kekka[0][5],1)+
									"");
#endif//debug_view_kobetu									
							}
						}
						
						
						if(hyouka_data[i].kekka[1][0]==1){
						//終了条件①=結果の0：起点   kekka[0][]
							// 3-4の距離
							int p=1;//パターン番号
							double dd34=hyouka_data[i].kekka[p][5];
							double kijun_line = hyouka_data[i].v[4];
							double sl=kijun_line+dd34;
							double tp=kijun_line-dd34;
							string stmp="勝";

							if(sl < now || now < tp){ 
								hyouka_data[i].kekka[p][1]=hyouka_data[i].max;//[*][1]:max　勝ち方向
								hyouka_data[i].kekka[p][2]=hyouka_data[i].min;//[*][2]:min　負け方向
								
								if(hyouka_data[i].max >=dd34){ 
    								hyouka_data[i].kekka[p][3]=1;//[*][3]:　勝ち負け　勝１、負けー１
    							}else{
    								hyouka_data[i].kekka[p][3]=-1;//[*][3]:　勝ち負け　勝１、負けー１
    								stmp="負";
                                }
								//hyouka_data[i].kekka[0][4]=;//[*][4]:　抜けたときの確定足とラインとの距離
								//hyouka_data[i].kekka[0][5]=dd34;//[*][5]:　３－４距離
								// 6-4の距離
								//double dd64=MathAbs(hyouka_data[i].v[6]-hyouka_data[i].v[4]);
								//hyouka_data[i].kekka[0][6]=;//[*][6]:　６－４距離
								
								//hyouka_data[i].kekka[p][0] =-1;//集計　状態を無効に-> 完了
								hyouka_data[i].kekka[p][0] =3;// 少し動いてから止めるためcase３で確認する
#ifdef USE_debug_view_pattern_exit
								datetime now_time = candle.time[ZIGZAG_BUFFER_MAX_NUM-1];
                                view_end(now,now_time,stmp);
#endif//USE_debug_view_pattern_exit
                                hyouka_data[i].kekka[1][29]=candle.zigzagdata_count;//end時の数

							}
						}

                    //評価を画面で見たいための
						if(hyouka_data[i].kekka[1][0]==3){
						    if( hyouka_data[i].kekka[1][29]+1<candle.zigzagdata_count||
						        hyouka_data[i].kekka[1][29]+2<candle.zigzagdata_count||
						        hyouka_data[i].kekka[1][29]+3<candle.zigzagdata_count||
						        hyouka_data[i].kekka[1][29]+4<candle.zigzagdata_count||
						        hyouka_data[i].kekka[1][29]+10<candle.zigzagdata_count){
						        int ff ;
						        ff=candle.zigzagdata_count;    
						    }
						    if(
						        hyouka_data[i].kekka[1][29]+10<candle.zigzagdata_count)
						    {
						        hyouka_data[i].kekka[1][0] =-1;//集計　状態を無効に-> 完了
						    }
						
						
						}


						
				    //無効化判断
					if(	hyouka_data[i].kekka[0][0]!=1 
					    && hyouka_data[i].kekka[1][0]==-1
					    )
					{
					    hyouka_data[i].status  =999;//　完了    
					    kekka_calc();
					}
            
                break;
            case 3:

            
                break;
            default:
                break;
            
            }//すぃｔｃｈ
    }//for
    
    return(0);
}

#endif//delll


bool    TradeMethodbase::Is_pattern(void){
    int base_idx = candle.zigzagdata_count-1;
	return(Is_pattern(base_idx));
}
bool    TradeMethodbase::Is_pattern(int base_idx){  //  基準となるzigzagcountからー１した値　　　　 int base_idx = candle.zigzagdata_count-1;
    bool ret = false;    
    return(ret);
}

bool TradeMethodbase::eq_zigzag(int idx1,int idx2,double gosaPips){
    bool ret = false;
    double v1,v2;
    datetime t1,t2;
    int k1,k2;
    int c1,c2;//最大数
    bool bret1,bret2;
    bret1=candle.get_zigzagdata(period,idx1,v1,t1,k1,c1);
    bret2=candle.get_zigzagdata(period,idx2,v2,t2,k2,c2);
    double dd = gosaPips*10*Point();
    if(v1+ dd >=v2 && v1-dd <= v2){
        ret = true;
    }
    return(ret);
}
bool TradeMethodbase::lt_zigzag(int idx1,int idx2,double gosaPips){ // idx1は2-ｄｄよりも小さい
    bool ret = false;
    double v1,v2;
    datetime t1,t2;
    int k1,k2;
    int c1,c2;//最大数
    bool bret1,bret2;
    bret1=candle.get_zigzagdata(period,idx1,v1,t1,k1,c1);
    bret2=candle.get_zigzagdata(period,idx2,v2,t2,k2,c2);
    double dd = gosaPips*10*Point();
    if(v1 <=v2- dd){
        ret = true;
    }
    return(ret);
}
bool TradeMethodbase::gt_zigzag(int idx1,int idx2,double gosaPips){// idx１は２＋ｄｄよりもBig
    bool ret = false;
    double v1,v2;
    datetime t1,t2;
    int k1,k2;
    int c1,c2;//最大数
    bool bret1,bret2;
    bret1=candle.get_zigzagdata(period,idx1,v1,t1,k1,c1);
    bret2=candle.get_zigzagdata(period,idx2,v2,t2,k2,c2);
    double dd = gosaPips*10*Point();
    if((v1) >= (v2+ dd)){
        ret = true;
    }
    return(ret);
}
double TradeMethodbase::Dist_zigzag(int idx1,int idx2,double gosaPips){// 単位は価格
    //bool ret = false;
    double v1,v2;
    datetime t1,t2;
    int k1,k2;
    int c1,c2;//最大数
    bool bret1,bret2;
    bret1=candle.get_zigzagdata(period,idx1,v1,t1,k1,c1);
    bret2=candle.get_zigzagdata(period,idx2,v2,t2,k2,c2);
    return(MathAbs(v1-v2));
    //return(ret);
}
double TradeMethodbase::Dist_ipips_zigzag(int idx1,int idx2,double gosaPips){// 単位はPips
    double r = Dist_zigzag(idx1,idx2,0);
    return( r/Point()  / 10 );
}
int TradeMethodbase::chgKijun2Idx(int base_idx,int idx){// base_idxはっ注目count－１、idxは基準が１として
// 基準１は9,2は８、base：注目idx　カウント１０の時idx９
    return(base_idx-idx+1);
}

#ifdef dellll
void TradeMethodbase::init_kekka(double &h[][NUM_OF_KEKKA_YOUSO]){
    for(int k = 0; k<10; k++){
        for(int i=0; i<NUM_OF_KEKKA_YOUSO;i++){ 
            h[k][i]=0;
        }
    }    
}
#endif //dellll


void TradeMethodbase::init_hyouka_data( struct_hyouka_data &d){
		d.status=0;//0は無効   999が完了
		d.reg_ikey=0;//特定キー、例；固有データのidx	
		d.ref_koyuu_data=-1;//対象配列のステータスの固有データへの配列番号（　評価と同じidxでもよい）

		d.winloss=0;//0どちらでもない（キャンセル）、-1負け、１勝
		d. entry_v=0;
		d. entry_t=0;
		d. exit_v=0;
		datetime exit_t=0;
		d.dir=0;//0無効、１ｂｕｙ、-1　sell

}


#ifdef mishiyou_kekka_yosou
void TradeMethodbase::view_kekka_youso(int n){// 評価パターンｎ
    string strout="";
    addstring(strout,"kekka　要素　"+IntegerToString(n)+""+ _Symbol + "--------------");
    //printf("kekka　要素　"+IntegerToString(n)+""+ _Symbol + "--------------");
    
    string str="";
    string TAB=",";
    string title=
        "idx"+TAB+
        "max:Pips"+TAB+
        "minPips"+TAB+
        "kati1:make-1"+TAB+
        "抜けたときの確定足とラインとの距離"+TAB+
        "３－４距離"+TAB+
        "６－４距離"+TAB+
        "M5SMA8傾き"+TAB+
        "M5SMA20傾き"+TAB+
        "M15SMA8傾き"+TAB+
        "M15SMA20傾き"+TAB+
        "H1SMA8傾き"+TAB+
        "H1SMA20傾き"+TAB+
        "H4SMA8傾き"+TAB+
        "H4SMA20傾き"+TAB+
        "ブレークの時間string"+TAB+
        "ブレークの時間"+TAB+
        "ブレーク前のH1直近高値100％としたブレーク位置"+TAB+
        "ブレーク前のH1直近B-高値Pips"+TAB+
        "ブレーク前のH1直近B-安値Pips"+TAB+
        "H1足パターン"+TAB+//　Nとか上場中でトレンド、レンジ、？
        "ブレーク前のH4直近高値100％としたブレーク位置"+TAB+
        "ブレーク前のH4直近B-高値Pips"+TAB+
        "ブレーク前のH4直近B-安値Pips"+TAB+
        "H4足パターン"+TAB+//　Nとか上場中でトレンド、レンジ、？
        "ブレーク前のD1直近高値100％としたブレーク位置"+TAB+
        "ブレーク前のD1直近B-高値Pips"+TAB+
        "ブレーク前のD1直近B-安値Pips"+TAB+
        "D1足パターン"+TAB+//　Nとか上場中でトレンド、レンジ、？
        "";
    addstring(strout,title);
    //printf(title);
    for(int i = 0; i<hyouka_data_num ;i++){
        if(hyouka_data[i].status == 999){
           str=
            IntegerToString(i)+TAB+
            getPips(hyouka_data[i].kekka[n][1])+TAB+
            getPips(hyouka_data[i].kekka[n][2])+TAB+
            IntegerToString((int)hyouka_data[i].kekka[n][3])+TAB+
            getPips(hyouka_data[i].kekka[n][4])+TAB+
            getPips(hyouka_data[i].kekka[n][5])+TAB+
            getPips(hyouka_data[i].kekka[n][6])+TAB+
            getPips(hyouka_data[i].kekka[n][7])+TAB+
            getPips(hyouka_data[i].kekka[n][8])+TAB+
            getPips(hyouka_data[i].kekka[n][9])+TAB+
            getPips(hyouka_data[i].kekka[n][10])+TAB+
            getPips(hyouka_data[i].kekka[n][11])+TAB+
            getPips(hyouka_data[i].kekka[n][12])+TAB+
            getPips(hyouka_data[i].kekka[n][13])+TAB+
            getPips(hyouka_data[i].kekka[n][14])+TAB+
            TimeToString((datetime)( hyouka_data[i].kekka[n][15]))+TAB+
            IntegerToString( (int)(hyouka_data[i].kekka[n][15]))+TAB+//ブレークの時間
            
            DoubleToString( hyouka_data[i].kekka[n][16],2)+TAB+                 //"ブレーク前のH1直近高値100％としたブレーク位置"+TAB+
            getPips(hyouka_data[i].kekka[n][17])+TAB+        //"ブレーク前のH1直近B-高値Pips"+TAB+
            getPips(hyouka_data[i].kekka[n][18])+TAB+        //"ブレーク前のH1直近B-安値Pips"+TAB+
            IntegerToString( (int)(hyouka_data[i].kekka[n][19]))+TAB+           //"H1足パターン"+TAB+//　Nとか上場中でトレンド、レンジ、？

            DoubleToString( hyouka_data[i].kekka[n][20],2)+TAB+                 //"ブレーク前のH4直近高値100％としたブレーク位置"+TAB+
            getPips(hyouka_data[i].kekka[n][21])+TAB+        //"ブレーク前のH4直近B-高値Pips"+TAB+
            getPips(hyouka_data[i].kekka[n][22])+TAB+        //"ブレーク前のH4直近B-安値Pips"+TAB+
            IntegerToString( (int)(hyouka_data[i].kekka[n][23]))+TAB+           //"H4足パターン"+TAB+//　Nとか上場中でトレンド、レンジ、？

            DoubleToString( hyouka_data[i].kekka[n][24],2)+TAB+                 //"ブレーク前のD1直近高値100％としたブレーク位置"+TAB+
            getPips(hyouka_data[i].kekka[n][25])+TAB+        //"ブレーク前のD1直近B-高値Pips"+TAB+
            getPips(hyouka_data[i].kekka[n][26])+TAB+        //"ブレーク前のD1直近B-安値Pips"+TAB+
            IntegerToString( (int)(hyouka_data[i].kekka[n][27]))+TAB+           //"D1足パターン"+TAB+//　Nとか上場中でトレンド、レンジ、？


            //for(int j = 0;j<NUM_OF_KEKKA_YOUSO;j++){
            //    str = str+
            //
            "";
            addstring(strout,str);
            //printf(str);
        }
    }
    writestring_file("out_pattern"+IntegerToString(n)+".txt",strout,false);
}
#endif//mishiyou_kekka_yosou

string TradeMethodbase::getPips(double d){
	double pips = d/(Point()*10);
	
	return DoubleToString(pips,1);
}
void TradeMethodbase::view_end(double now, datetime now_time,string s){
    CreateArrowRightPrice(0,s+TimeToString(now_time),0,now_time,now,clrRed,2);
}
void TradeMethodbase::view_start(double now, datetime now_time,string s){
    CreateArrowRightPrice(0,s+TimeToString(now_time),0,now_time,now,clrBlue,2);
}
void TradeMethodbase::view_entry(double now, datetime now_time,string s){
    CreateArrowRightPrice(0,s+TimeToString(now_time),0,now_time,now,clrGreenYellow,2);
}

void TradeMethodbase::view_AB_entyouhasenn(real_point &a,real_point &b,string &name){
	//線分abの延長bcに線（AB実践、BC点線）
	//ab -> bc のcを求める
	real_point c;
	imi_point A,B,C;
	datetime Tk = a.t;

	chg_r2i(a,A,Tk);
	chg_r2i(b,B,Tk);
	move_LineAB_To_startpointC_imi(A,B,B,C);// C

	chg_i2r(C,c,Tk);

	//ab 実践
	int wide = 10;
	candle.CreateTline(0,"J"+name,0,a.t,a.v    ,b.t,b.v,clrPurple,STYLE_SOLID,wide,"J"+name);	

	//bc　破線
	candle.CreateTline(0,"T"+name,0,b.t,b.v    ,c.t,c.v,clrPink,STYLE_DOT,wide,"T"+name);	

		//	STYLE_SOLID	実線。
		//	STYLE_DASH	途切れ線。
		//	STYLE_DOT	点線。
		//	STYLE_DASHDOT	一点鎖線。
		//	STYLE_DASHDOTDOT	二点鎖線。

}


void TradeMethodbase::Oninit(void){
    EntryNo=0;
}
void TradeMethodbase::OnDeinit(const int reason){
	kekka_calc();printf("aa");
}
void TradeMethodbase::view_entryToExit(int idx){
   double p1 = hyouka_data[idx].entry_v;
   datetime t1 = hyouka_data[idx].entry_t;
   double p2 = hyouka_data[idx].exit_v;
   datetime t2 = hyouka_data[idx].exit_t;
  string name1 = name+"entry_exit  "+IntegerToString(idx)+":";
  
  //TrendCreate(0,name1,0,cn_out[nn].t,cn_out[nn].v    ,cn_out[nn+1].t,cn_out[nn+1].v,clrWhiteSmoke,STYLE_SOLID,7);
  candle.CreateTline(0,name1,0,t1,p1    ,t2,p2,clrPurple,STYLE_SOLID,10,name1);	
  printf("exit "+name1);
}
//+------------------------------------------------------------------+
//|  Creating a text label                                           |
//+------------------------------------------------------------------+
void TradeMethodbase::CreateArrowRightPrice //CreateArrowRightPrice(0,"",0,Time,Price,Color,3)
(
 long   chart_id,         // chart ID
 string name1,             // object name
 int    nwin,             // window index
 datetime Time,           // position of price label by time
 double Price,            // position of price label by vertical
 color  Color,            // text color
 uint    Size             // font size
 )
//---- 
  {
//----

//string new_name = 
//   ObjectCreate(chart_id,name,OBJ_ARROW_RIGHT_PRICE,nwin,Time,Price);
   ObjectCreate(chart_id,name1,OBJ_ARROW_RIGHT_PRICE,nwin,Time,Price);
   ObjectSetInteger(chart_id,name1,OBJPROP_COLOR,Color);
   ObjectSetInteger(chart_id,name1,OBJPROP_WIDTH,Size);
//ObjectSetInteger(chart_id,name,OBJPROP_BACK,true);
//----
  }


#endif//TradeMethodbase
