#include "classMethod.mqh"
#ifndef classMethod_flag
#define classMethod_flag
class MethodPattern_flag : public MethodPattern
{
//;
public:
    //MethodPattern_flag(void){};
	MethodPattern_flag(string s,ENUM_TIMEFRAMES p,candle_data *c,allcandle *a){name = s;period = p;candle = c; p_allcandle = a;hyouka_data_num=0;
		init_mem_hyouka_data();
	};
	//~MethodPattern_flag(void){view_kekka_youso(1);};

//	int		hyouka(void){return(0);};//　評価・状態遷移含む処理
//    bool    add_hyouka_data(void){};
    //bool    Is_pattern(void){};// 直近のZigzagから評価
    //bool    Is_pattern(int base_idx){};// 指定したzigzagcount－１　の時のパターン成立状態


//	struct struct_hyouka_data{
//		int status;//0は無効   999が完了
//		int zigzagcount;//登録時のカウント数（add処理で同一か見るため）
//		double v[10];// 1から　zigzag1,2,3,4,5,6,7,8,9の値　　パターン確定時の起点が１
//		double i[10];// 0:  
//		double max;
//		double min;
#ifdef commenttttt
________________________
		3		1			基点　1　上

	4		2
________________________
	4		2
	
		3		1			基点　-1　下
________________________
#endif//commenttttt	

				//double kekka[10][NUM_OF_KEKKA_YOUSO];// [n][*] n評価パターン
		    //[*][0]:評価パターンの状態　１-ｎ集計中、完了は　999、それ以外集計していない　0
		    //[*][1]:max　勝ち方向   
		    //[*][2]:min　負け方向
		    //[*][3]:　勝ち負け　勝１、負けー１、０無効
		    //[*][4]:　抜けたときの確定足とラインとの距離　　→未使用
		    //[*][5]:　３－４距離→未使用　→
		    //[*][6]:　６－４距離→未使用　→
		    //[*][7]:katamuki8  　M5
		    //[*][8]:katamuki20　 M5
		    //[*][9]:katamuki8  　M15
		    //[*][10]:katamuki20　 M15
		    //[*][11]:katamuki8  　H1
		    //[*][12]:katamuki20　 H1
		    //[*][13]:katamuki8  　H4
		    //[*][14]:katamuki20　 H4
			//[*][15]:ブレークの時間　datetimeをdouble型で格納
			//    ----UE
			//	  16      "ブレーク前のH1直近高値100％としたブレーク位置"+TAB+
			//	  17      "ブレーク前のH1直近B-高値Pips"+TAB+
			//	  18      "ブレーク前のH1直近B-安値Pips"+TAB+
			//	  19      "H1足パターン"+TAB+//　Nとか上場中でトレンド、レンジ、？
			//	  20      "ブレーク前のH4直近高値100％としたブレーク位置"+TAB+
			//	  21      "ブレーク前のH4直近B-高値Pips"+TAB+
			//	  22      "ブレーク前のH4直近B-安値Pips"+TAB+
			//	  23      "H4足パターン"+TAB+//　Nとか上場中でトレンド、レンジ、？
			//	  24      "ブレーク前のD1直近高値100％としたブレーク位置"+TAB+
			//	  25      "ブレーク前のD1直近B-高値Pips"+TAB+
			//	  26      "ブレーク前のD1直近B-安値Pips"+TAB+
			//	  27      "D1足パターン"+TAB+//　Nとか上場中でトレンド、レンジ、？
			//    28      "entry時のzigzagcount
			//    29      "exit時のzigzagcount
			
			//      30  レンジ基点１の位置：下側、上側？（上１、下ー１）
			//      31  上ライン情報　切片ｙ
			//      32  上ライン情報　傾き 0は水平
			//      33  下ライン情報　切片
			//      34  下ライン情報　傾き 0は水平
			//      35  レンジブレークの確定足の価格
			//      36  パターン成立時の価格記憶

			//      37  entry 方向　上１、下-1、0なし
			//      38  Tp　価格
			//      39  SL　価格
			//      40  entry　価格
			//      41  entry　結果　[Pips]
			//      42  レンジの幅　値　
			//      43  レンジの幅Pips　
			//      44  entry　時間 (数値）　

//C:\download2
////meme20200411fx.xls
////レンジ手法　シート



int hyouka(void){ // 足確定で呼ばれる想定
// 
	double sa;//基準値からの損益価格
	double sa_pips;
	int kachimake=0;
	double entry_kekka;
    //追加必要か？
    // パターン成立したか？
        //Zigzag変化したとき
        if(candle.zigzag_chg_flag==true){
            //パターン成立
            if(p_allcandle.Is_pattern_flag(period)){//debug 20200509
                int iiii=candle.get_pattern_flag_pt_flag_last_idx();
                //debug
                bool rrr=
                //評価データに追加、状態を１へ、重複しないように同じZigzagパターン番号の時で既にあるなら追加しない。（add処理で実現）
                add_hyouka_data();

                //debug
//                if(rrr==true){
//                    printf("Addhyouka#0:zigzagdata_count="+IntegerToString(candle.zigzagdata_count));
//                    printf("Addhyouka#1:get_pattern_flag_pt_flag_last_idx="+IntegerToString(iiii));
//                    printf("Addhyouka#2:add_hyouka_data()=true");
//                }
                //debug
                if((hyouka_data_num % 50)==0 && hyouka_data_num!=0){
                    //★20200502debug★view_kekka_youso(1);
                }
            }
    	}
    //
  	double now = candle.close[ZIGZAG_BUFFER_MAX_NUM-1];
    for(int i = 0; i<hyouka_data_num ;i++){
        switch(hyouka_data[i].status){
            case 1:// ブレークアウトするかの判定
            	//////////////////////////////
            	//** 評価パターン０：
            	//////////////////////////////
				if(hyouka_data[i].kekka[0][0]==1){
					bool flag_end=false;
					//int kachimake=0;
					// 40  entry　価格　と現在価格のMaxMin(1,2）を更新
					rec_max_min(0,now,hyouka_data[i].kekka[0][40],(int)hyouka_data[i].kekka[0][37]);
					if(hyouka_data[i].kekka[0][37] ==1){//上方向
						if(hyouka_data[i].kekka[0][38] <now ){//Tp
							//kati
							flag_end=true;
							kachimake=1;
						}else if(hyouka_data[i].kekka[0][39] >now ){//SL
							//make
							flag_end=true;
							kachimake=-1;
						}
					}else{
						if(hyouka_data[i].kekka[0][38] >now ){//Tp
							//kati
							flag_end=true;
							kachimake=1;
						}else if(hyouka_data[i].kekka[0][39] <now ){//SL
							//make
							flag_end=true;
							kachimake=-1;
						}

					}
					if(flag_end==true){
						entry_kekka=(now-hyouka_data[i].kekka[0][40])*hyouka_data[i].kekka[0][37] ; //40  entry　価格  //37  entry 方向　上１、下-1、0なし
						hyouka_data[i].kekka[0][41]=chgPrice2Pips(entry_kekka);//		41  entry　結果　[Pips]
						hyouka_data[i].kekka[0][3]=(double)kachimake;//[*][3]:　勝ち負け　勝１、負けー１、０無効
						hyouka_data[i].kekka[0][0]=999;
						kekka_calc(0);
					}
				}

            	//////////////////////////////
            	//** 評価パターン1：レンジブレイク    レンジの中から外へ行くのを待つ
            	//////////////////////////////
				if(hyouka_data[i].kekka[1][0]==1){
					if(hyouka_data[i].kekka[1][31]<now){
						hyouka_data[i].kekka[1][35]=now;  //35  レンジブレークの確定足の価格
						hyouka_data[i].kekka[1][40]=now;  //40  entry　価格
						hyouka_data[i].kekka[1][37] =1;//37  entry 方向　上１、下-1、0なし
						
						hyouka_data[i].kekka[1][38] =	hyouka_data[i].kekka[0][31]+hyouka_data[i].kekka[0][42];//tp
						hyouka_data[i].kekka[1][39] =	hyouka_data[i].kekka[0][31] ;//sl 
						hyouka_data[i].kekka[1][0]=2;
						set_EntryData(i,1);//hyouka_data idx, kekka no (syuhouNo)
						if(hyouka_data[i].kekka[1][30]==-1){// 下初期位置から上ラインを抜いたときのみ（上抜いて、上ラインまで戻ってきてだましをねらうため）
						    hyouka_data[i].kekka[2][0]=2;
						    hyouka_data[i].kekka[2][37] =1;//37  entry 方向　上１、下-1、0なし
						}
					}else if(hyouka_data[i].kekka[0][33]>now){
						hyouka_data[i].kekka[1][35]=now;  //35  レンジブレークの確定足の価格
						hyouka_data[i].kekka[1][40]=now;  //40  entry　価格
						hyouka_data[i].kekka[1][37] =-1;//37  entry 方向　上１、下-1、0なし
						
						hyouka_data[i].kekka[1][38] =	hyouka_data[i].kekka[0][33]-hyouka_data[i].kekka[0][42];//tp
						hyouka_data[i].kekka[1][39] =	hyouka_data[i].kekka[0][33] ;//sl 
						hyouka_data[i].kekka[1][0]=2;
						set_EntryData(i,1);//hyouka_data idx, kekka no (syuhouNo)
						if(hyouka_data[i].kekka[1][30]==1){// 上初期位置から下ラインを抜いたときのみ（下抜いて、下ラインまで戻ってきてだましをねらうため）
    						hyouka_data[i].kekka[2][0]=2;
    						hyouka_data[i].kekka[2][37] =-1;//37  entry 方向　上１、下-1、0なし
    					}
					}
            	//////////////////////////////
            	//** 評価パターン1：レンジブレイク    中　エントリー中
            	//////////////////////////////
				}else if(hyouka_data[i].kekka[1][0]==2){
					bool flag_end=false;
					// 40  entry　価格　と現在価格のMaxMinを更新
					rec_max_min(1,now,hyouka_data[i].kekka[1][40],(int)hyouka_data[i].kekka[1][37]);
					if(hyouka_data[i].kekka[1][37] ==1){//上方向
						if(hyouka_data[i].kekka[1][38] <now ){//Tp
							//kati
							flag_end=true;
							kachimake=1;
						}else if(hyouka_data[i].kekka[1][39] >now ){//SL
							//make
							flag_end=true;
							kachimake=-1;
						}
					}else{
						if(hyouka_data[i].kekka[1][38] >now ){//Tp
							//kati
							flag_end=true;
							kachimake=1;
						}else if(hyouka_data[i].kekka[1][39] <now ){//SL
							//make
							flag_end=true;
							kachimake=-1;
						}

					}
					if(flag_end==true){
						entry_kekka=(now-hyouka_data[i].kekka[1][40])*hyouka_data[i].kekka[1][37];  //40  entry　価格  //37  entry 方向　上１、下-1、0なし
						hyouka_data[i].kekka[1][41]=chgPrice2Pips(entry_kekka);//		41  entry　結果　[Pips]
						hyouka_data[i].kekka[1][3]=kachimake;//[*][3]:　勝ち負け　勝１、負けー１、０無効
						hyouka_data[i].kekka[1][0]=999;
						kekka_calc(1);
					}
					
				}
            	//////////////////////////////
            	//** 評価パターン2：超えてから、戻って、さらに伸びる   ライン超え中
            	//////////////////////////////
				if(hyouka_data[i].kekka[2][0]==2){
					bool flag_end=false;
					//ライン幅より、2倍になったらEND（超えた方向方向）。
					if(hyouka_data[i].kekka[2][37] ==1){
						if(hyouka_data[i].kekka[2][31] + hyouka_data[i].kekka[2][42] <now){//31  上ライン情報　切片ｙ//42  レンジの幅　値　
							flag_end = true;
						}
					}else{
						if(hyouka_data[i].kekka[2][33] - hyouka_data[i].kekka[2][42] >now){//33  下ライン情報　切片//42  レンジの幅　値　
							flag_end = true;
						}
					}
					if(flag_end == true){//結果無効
						hyouka_data[i].kekka[2][3]=0;//[*][3]:　勝ち負け　勝１、負けー１、０無効
						hyouka_data[i].kekka[2][0]=999;
					}
					//ラインまで戻る
					//kekka状態ｋ[3][0]=2			超えてからだましになって、逆側へ（逆のラインまで）だましからのエントリー
					//kekka状態ｋ[4][0]=2			超えてからだましになって、逆側へ（逆のラインを超えて、レンジ幅）だましからのエントリー
					if(hyouka_data[i].kekka[2][30] ==-1){  
						if(hyouka_data[i].kekka[2][31] >now){//31  上ライン情報　切片ｙ//42  レンジの幅　値　
							//kekka状態ｋ[3][0]=2			超えてからだましになって、逆側へ（逆のラインまで）だましからのエントリー
							hyouka_data[i].kekka[3][40]=now;  //40  entry　価格
							hyouka_data[i].kekka[3][37] =-1;//37  entry 方向　上１、下-1、0なし
							hyouka_data[i].kekka[3][38] =	hyouka_data[i].kekka[2][31]-hyouka_data[i].kekka[2][42];//tp
							hyouka_data[i].kekka[3][39] =	hyouka_data[i].kekka[2][31] ;//sl 
							hyouka_data[i].kekka[3][0]=2;

							//kekka状態ｋ[4][0]=2			超えてからだましになって、逆側へ（逆のラインを超えて、レンジ幅）だましからのエントリー
							hyouka_data[i].kekka[4][40]=now;  //40  entry　価格
							hyouka_data[i].kekka[4][37] =-1;//37  entry 方向　上１、下-1、0なし
							hyouka_data[i].kekka[4][38] =	hyouka_data[i].kekka[2][31]-hyouka_data[i].kekka[2][42]*2;//tp
							hyouka_data[i].kekka[4][39] =	hyouka_data[i].kekka[2][31] ;//sl 
							hyouka_data[i].kekka[4][0]=2;

							//kekka状態k[2][0]=3					押し戻り中（レンジの中へ戻り中）
							hyouka_data[i].kekka[2][0]=3;
						}
					}else{
						if(hyouka_data[i].kekka[2][33] <now){//33  下ライン情報　切片//42  レンジの幅　値　
							//kekka状態ｋ[3][0]=2			超えてからだましになって、逆側へ（逆のラインまで）だましからのエントリー
							hyouka_data[i].kekka[3][40]=now;  //40  entry　価格
							hyouka_data[i].kekka[3][37] =1;//37  entry 方向　上１、下-1、0なし
							hyouka_data[i].kekka[3][38] =	hyouka_data[i].kekka[2][33]+hyouka_data[i].kekka[2][42];//tp
							hyouka_data[i].kekka[3][39] =	hyouka_data[i].kekka[2][33] ;//sl 
							hyouka_data[i].kekka[3][0]=2;

							//kekka状態ｋ[4][0]=2			超えてからだましになって、逆側へ（逆のラインを超えて、レンジ幅）だましからのエントリー
							hyouka_data[i].kekka[4][40]=now;  //40  entry　価格
							hyouka_data[i].kekka[4][37] =1;//37  entry 方向　上１、下-1、0なし
							hyouka_data[i].kekka[4][38] =	hyouka_data[i].kekka[2][33]+hyouka_data[i].kekka[2][42]*2;//tp
							hyouka_data[i].kekka[4][39] =	hyouka_data[i].kekka[2][33] ;//sl 
							hyouka_data[i].kekka[4][0]=2;

							//kekka状態k[2][0]=3					押し戻り中（レンジの中へ戻り中）
							hyouka_data[i].kekka[2][0]=3;
						}
					}
				}
				//押し戻り中（レンジの中へ戻り中）
				if(hyouka_data[i].kekka[2][0]==3){
					bool b_entry=false;
					if(hyouka_data[i].kekka[2][30] ==-1){  
						if(hyouka_data[i].kekka[2][31] <now){//31  上ライン情報　切片ｙ//42  レンジの幅　値　
							//再度、ライン抜けでEntry					kekka状態k[2][0]=4
							hyouka_data[i].kekka[2][40]=now;  //40  entry　価格
							hyouka_data[i].kekka[2][37] =1;//37  entry 方向　上１、下-1、0なし
							hyouka_data[i].kekka[2][38] =	hyouka_data[i].kekka[2][31]+hyouka_data[i].kekka[2][42];//tp
							hyouka_data[i].kekka[2][39] =	hyouka_data[i].kekka[2][31] ;//sl 
							hyouka_data[i].kekka[2][0]=4;
							b_entry=true;

							hyouka_data[i].kekka[6][40]=now;  //40  entry　価格
							hyouka_data[i].kekka[6][37] =1;//37  entry 方向　上１、下-1、0なし
							hyouka_data[i].kekka[6][38] =	hyouka_data[i].kekka[2][31]+hyouka_data[i].kekka[2][42]*2;//tp
							hyouka_data[i].kekka[6][39] =	hyouka_data[i].kekka[2][31] ;//sl 
							hyouka_data[i].kekka[6][0]=4;
						}
						if(hyouka_data[i].kekka[2][33] >now){
							//反対側のラインにタッチ					kekka状態k[2][0]=999,結果なし状態を記憶★
							hyouka_data[i].kekka[2][0]=999;
						}
					}else{
						if(hyouka_data[i].kekka[2][33] >now){//33  下ライン情報　切片//42  レンジの幅　値　
							//kekka状態ｋ[3][0]=2			超えてからだましになって、逆側へ（逆のラインまで）だましからのエントリー
							hyouka_data[i].kekka[2][40]=now;  //40  entry　価格
							hyouka_data[i].kekka[2][37] =1;//37  entry 方向　上１、下-1、0なし
							hyouka_data[i].kekka[2][38] =	hyouka_data[i].kekka[2][33]-hyouka_data[i].kekka[2][42];//tp
							hyouka_data[i].kekka[2][39] =	hyouka_data[i].kekka[2][33] ;//sl 
							hyouka_data[i].kekka[2][0]=4;
							b_entry=true;

							hyouka_data[i].kekka[6][40]=now;  //40  entry　価格
							hyouka_data[i].kekka[6][37] =1;//37  entry 方向　上１、下-1、0なし
							hyouka_data[i].kekka[6][38] =	hyouka_data[i].kekka[2][33]-hyouka_data[i].kekka[2][42]*2;//tp
							hyouka_data[i].kekka[6][39] =	hyouka_data[i].kekka[2][33] ;//sl 
							hyouka_data[i].kekka[6][0]=4;
						}
						if(hyouka_data[i].kekka[2][31] >now){
							//反対側のラインにタッチ					kekka状態k[2][0]=999,結果なし状態を記憶★
							hyouka_data[i].kekka[2][0]=999;
						}
					}
//debug view
					if(b_entry ==true){
						// view mark 
						//double now = candle.close[ZIGZAG_BUFFER_MAX_NUM-1];
						datetime now_time = candle.time[ZIGZAG_BUFFER_MAX_NUM-1];
						view_entry(now,now_time, IntegerToString(hyouka_data_num));
					}
//debug view
				}
				//2	4	超えて戻ってきてからエントリー中　Tp1倍
				if(hyouka_data[i].kekka[2][0]==4){
					bool flag_end=false;
					// 40  entry　価格　と現在価格のMaxMinを更新
					rec_max_min(2,now,hyouka_data[i].kekka[2][40],(int)hyouka_data[i].kekka[2][37]);
					if(hyouka_data[i].kekka[2][37] ==1){//上方向
						if(hyouka_data[i].kekka[2][38] <now ){//Tp
							//kati
							flag_end=true;
							kachimake=1;
						}else if(hyouka_data[i].kekka[2][39] >now ){//SL
							//make
							flag_end=true;
							kachimake=-1;
						}
					}else{
						if(hyouka_data[i].kekka[2][38] >now ){//Tp
							//kati
							flag_end=true;
							kachimake=1;
						}else if(hyouka_data[i].kekka[2][39] <now ){//SL
							//make
							flag_end=true;
							kachimake=-1;
						}
					}
					if(flag_end==true){
						entry_kekka=(now-hyouka_data[i].kekka[2][40])*hyouka_data[i].kekka[2][37];  //40  entry　価格  //37  entry 方向　上１、下-1、0なし
						hyouka_data[i].kekka[2][41]=chgPrice2Pips(entry_kekka);//		41  entry　結果　[Pips]
						hyouka_data[i].kekka[2][3]=kachimake;//[*][3]:　勝ち負け　勝１、負けー１、０無効
						hyouka_data[i].kekka[2][0]=999;
						kekka_calc(2);
					}
				}
				//6	4	超えて戻ってきてからエントリー中　Tp＊２倍
				if(hyouka_data[i].kekka[6][0]==4){
					bool flag_end=false;
					// 40  entry　価格　と現在価格のMaxMinを更新
					rec_max_min(6,now,hyouka_data[i].kekka[6][40],(int)hyouka_data[i].kekka[6][37]);
					if(hyouka_data[i].kekka[6][37] ==1){//上方向
						if(hyouka_data[i].kekka[6][38] <now ){//Tp
							//kati
							flag_end=true;
							kachimake=1;
						}else if(hyouka_data[i].kekka[6][39] >now ){//SL
							//make
							flag_end=true;
							kachimake=-1;
						}
					}else{
						if(hyouka_data[i].kekka[6][38] >now ){//Tp
							//kati
							flag_end=true;
							kachimake=1;
						}else if(hyouka_data[i].kekka[6][39] <now ){//SL
							//make
							flag_end=true;
							kachimake=-1;
						}
					}
					if(flag_end==true){
						entry_kekka=(now-hyouka_data[i].kekka[6][40])*hyouka_data[i].kekka[6][37];  //40  entry　価格  //37  entry 方向　上１、下-1、0なし
						hyouka_data[i].kekka[6][41]=chgPrice2Pips(entry_kekka);//		41  entry　結果　[Pips]
						hyouka_data[i].kekka[6][3]=kachimake;//[*][3]:　勝ち負け　勝１、負けー１、０無効
						hyouka_data[i].kekka[6][0]=999;
						kekka_calc(6);
					}
				}


				//3	2  超えてからだましになって、逆側へ（逆のラインまで） だましからのエントリー
				if(hyouka_data[i].kekka[3][0]==2){
					bool flag_end=false;

					// 40  entry　価格　と現在価格のMaxMinを更新
					rec_max_min(3,now,hyouka_data[i].kekka[3][40],(int)hyouka_data[i].kekka[3][37]);
					if(hyouka_data[i].kekka[3][37] ==1){//上方向
						if(hyouka_data[i].kekka[3][38] <now ){//Tp
							//kati
							flag_end=true;
							kachimake=1;
						}else if(hyouka_data[i].kekka[3][39] >now ){//SL
							//make
							flag_end=true;
							kachimake=-1;
						}
					}else{
						if(hyouka_data[i].kekka[3][38] >now ){//Tp
							//kati
							flag_end=true;
							kachimake=1;
						}else if(hyouka_data[i].kekka[3][39] <now ){//SL
							//make
							flag_end=true;
							kachimake=-1;
						}
					}
					if(flag_end==true){
						entry_kekka=(now-hyouka_data[i].kekka[3][40])*hyouka_data[i].kekka[3][37];  //40  entry　価格  //37  entry 方向　上１、下-1、0なし
						hyouka_data[i].kekka[3][41]=chgPrice2Pips(entry_kekka);//		41  entry　結果　[Pips]
						hyouka_data[i].kekka[3][3]=kachimake;//[*][3]:　勝ち負け　勝１、負けー１、０無効
						hyouka_data[i].kekka[3][0]=999;
						kekka_calc(3);
					}
				}
				//4	2	超えてからだましになって、逆側へ（逆のラインを超えて、レンジ幅）	だましからのエントリー
				if(hyouka_data[i].kekka[4][0]==2){
					bool flag_end=false;
					// 40  entry　価格　と現在価格のMaxMinを更新
					rec_max_min(4,now,hyouka_data[i].kekka[4][40],(int)hyouka_data[i].kekka[4][37]);
					kachimake=0;
					if(hyouka_data[i].kekka[4][37] ==1){//上方向
						if(hyouka_data[i].kekka[4][38] <now ){//Tp
							//kati
							flag_end=true;
							kachimake=1;
						}else if(hyouka_data[i].kekka[4][39] >now ){//SL
							//make
							flag_end=true;
							kachimake=-1;
						}
					}else{
						if(hyouka_data[i].kekka[4][38] >now ){//Tp
							//kati
							flag_end=true;
							kachimake=1;
						}else if(hyouka_data[i].kekka[4][39] <now ){//SL
							//make
							flag_end=true;
							kachimake=-1;
						}
					}
					if(flag_end==true){
						entry_kekka=(now-hyouka_data[i].kekka[4][40])*hyouka_data[i].kekka[4][37];  //40  entry　価格  //37  entry 方向　上１、下-1、0なし
						hyouka_data[i].kekka[4][41]=chgPrice2Pips(entry_kekka);//		41  entry　結果　[Pips]
						hyouka_data[i].kekka[4][3]=kachimake;//[*][3]:　勝ち負け　勝１、負けー１、０無効
						hyouka_data[i].kekka[4][0]=999;
						kekka_calc(4);
					}
				}
		    //[*][1]:max　勝ち方向   
		    //[*][2]:min　負け方向
				//5	1	どっちに行くか
				if(hyouka_data[i].kekka[5][0]==1){
						// 上下のふり幅を確認
						if(hyouka_data[i].kekka[5][31] <now ){//
							if(hyouka_data[i].kekka[5][1] <now){
								hyouka_data[i].kekka[5][1]=now;// max
							}

						}else if(hyouka_data[i].kekka[5][33] >now ){//
							if(hyouka_data[i].kekka[5][2] >now){
								hyouka_data[i].kekka[5][2]=now;//min
							}
						}
						//2倍行ったら完了
						if(hyouka_data[i].kekka[5][31]+ hyouka_data[i].kekka[5][42]*2<now ){//
							hyouka_data[i].kekka[5][41]=hyouka_data[i].kekka[5][42]*2;
							hyouka_data[i].kekka[5][3]=1;//[*][3]:　勝ち負け　勝１、負けー１、０無効
							hyouka_data[i].kekka[5][0]=999;
							kekka_calc(5);
						}
						if(hyouka_data[i].kekka[5][33]- hyouka_data[i].kekka[5][42]*2>now ){//
							hyouka_data[i].kekka[5][41]=(-1)*hyouka_data[i].kekka[5][42]*2;
							hyouka_data[i].kekka[5][3]=-1;//[*][3]:　勝ち負け　勝１、負けー１、０無効
							hyouka_data[i].kekka[5][0]=999;
							kekka_calc(5);
						}
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
bool    add_hyouka_data(void){
    bool ret = false;
    
    
    if(hyouka_data_num > 0){
        //最後のものと異なっていたら追加
        if( hyouka_data[hyouka_data_num-1].reg_zigzagcount != candle.zigzagdata_count){
            ret = true;
        }
    }else{// 初回は無条件で追加
        ret = true;
	}
	//すでに登録されていルカの調査
	if(Is_exist_pt_flag(candle.zigzagdata_count,candle.pt_flag_data_count) == true){
	    ret = false;
	}
    if(ret == true ){//すでに登録されていないなら
    	double now = candle.close[ZIGZAG_BUFFER_MAX_NUM-1];
        datetime now_time = candle.time[ZIGZAG_BUFFER_MAX_NUM-1];
        bool bretget=true;
		//init && reg
		chk_mem_hyouka_data(hyouka_data_num+1);
		hyouka_data[hyouka_data_num].max = 0.0;
		hyouka_data[hyouka_data_num].min = 0.0;
        hyouka_data[hyouka_data_num].status = 1;
        hyouka_data[hyouka_data_num].reg_zigzagcount = candle.zigzagdata_count;
        hyouka_data[hyouka_data_num].reg_patterncount = candle.pt_flag_data_count;
		//zigzag data 1-7 wo v[1]から格納
		int n=1;
		for(int i = candle.zigzagdata_count-1; i>(candle.zigzagdata_count-1-8);i--){
			int idx=i,k,c;double v;datetime t;
			bool bret = 			candle.get_zigzagdata(period,idx,v,t,k,c);
			if(bret == true){
				hyouka_data[hyouka_data_num].v[n]=v;
				n++;
			}else{
				printf("error get_zigzagdata at Method   add hyouka data; idx="+IntegerToString(idx));
				bretget = false;
			}
		}
		if(bretget == true)
		{
            init_kekka(hyouka_data[hyouka_data_num].kekka);
            struct_pt_flag pt;
            p_allcandle.get_pt_flag(period,pt);// chg 20200509aaa  p_allcandle.get_pt_flag(PERIOD_M1,pt);
            	int p;
            	for(p=0;p<NUM_OF_HYOUKA_PATTERN ;p++){
	    			// 1-2の距離
	    			hyouka_data[hyouka_data_num].kekka[p][42]=pt.pt_flag_distance_updown_value;//42  レンジの幅　値
	    			hyouka_data[hyouka_data_num].kekka[p][43]=pt.pt_flag_distance_updown_pips;//レンジの幅Pips　


	    			hyouka_data[hyouka_data_num].kekka[p][31]=pt.pt_flag_upper_value;
	    			hyouka_data[hyouka_data_num].kekka[p][32]=0;
	    			hyouka_data[hyouka_data_num].kekka[p][33]=pt.pt_flag_down_value;
	    			hyouka_data[hyouka_data_num].kekka[p][34]=0;
   					hyouka_data[hyouka_data_num].kekka[p][30]=pt.pt_flag_position_first;//      30  基点：下側、上側？（上１、下ー１）

                    //debug 
                    hyouka_data[hyouka_data_num].kekka[p][28]=candle.zigzagdata_count;
        		}

			hyouka_data[hyouka_data_num].kekka[0][0]=1;
    		//double now = candle.close[ZIGZAG_BUFFER_MAX_NUM-1];							//
   			hyouka_data[hyouka_data_num].kekka[0][40]=now;								//40  entry　価格

   			hyouka_data[hyouka_data_num].kekka[0][36]=now;								//36  パターン成立時の価格記憶
   			hyouka_data[hyouka_data_num].kekka[0][37]=(-1)*pt.pt_flag_position_first;	//37  entry 方向　上１、下-1、0なし

			double sl_p,tp_p;
			if(pt.pt_flag_position_first ==1){
				sl_p=pt.pt_flag_upper_value;
				tp_p=pt.pt_flag_down_value;
			}else{
				sl_p=pt.pt_flag_down_value;
				tp_p=pt.pt_flag_upper_value;
			}
   			hyouka_data[hyouka_data_num].kekka[0][38]=tp_p;									//38  Tp　価格
   			hyouka_data[hyouka_data_num].kekka[0][39]=sl_p;									//39  SL　価格



			hyouka_data[hyouka_data_num].kekka[1][0]=1;
			hyouka_data[hyouka_data_num].kekka[5][0]=1;



        }
		//
		for(int pp=0;pp< NUM_OF_HYOUKA_PATTERN;pp++){
			set_kekkadata_ma(hyouka_data_num,pp,now_time);
			set_kekkadata_jouiashi(hyouka_data_num,pp,now_time,now);// hyoukadatra idx、pattern No,pattern追加時間、現在価格
		}
        hyouka_data_num++;

    	// view mark 
    	//double now = candle.close[ZIGZAG_BUFFER_MAX_NUM-1];
    	//datetime now_time = candle.time[ZIGZAG_BUFFER_MAX_NUM-1];
    	view_start(now,now_time, IntegerToString(hyouka_data_num));

        
	}
    return(ret);
}

bool Is_exist_pt_flag(int idx,int idx2){// aru true,nashi false  idx zigzag登録時数、idx2　pt_flagの登録所の数
    bool ret=false;
    for(int i = hyouka_data_num-1; i>=0 ;i--){
        if(hyouka_data[i].reg_zigzagcount == idx){
            ret = true;
            break;
        }
        if(hyouka_data[i].reg_patterncount == idx2){
            ret = true;
            break;
        }
    }
    return(ret);
}
void kekka_calc_out_all(){
    printf("out_kekka_calc all==========================");
    kekka_calc(0);
    kekka_calc(1);
    kekka_calc(2);
    kekka_calc(3);
    kekka_calc(4);
    kekka_calc(5);
    kekka_calc(6);
}
void kekka_calc(int k){
    //init kekka_matome
    
	for(int i=0; i<10;i++){ 
		kekka_matome[k][i]=0;
	}

    bool bview=false;
    for(int i = 0; i<hyouka_data_num ;i++){
        if(hyouka_data[i].status != 0){
			if(hyouka_data[i].kekka[k][0] == -1||hyouka_data[i].kekka[k][0] == 999){//無効(集計完了)
//		double kekka[10][10];// [*][0]有効１（集計中）、無効-1　　 [*][1] 数、[*][2] yobi、[*][3]pips0-10,[*][4]pips11-20,[*][5]pips21-31,
//	double kekka_matome[10][10];// [n][*] nは評価パターン、　[n][j]  j＝ 0 数、1：勝ち数、２：負け数、３：勝ちPIPS，４：負けPIPS，５：PF，６：，７：　
				//数0
				kekka_matome[k][0]++;
				if(hyouka_data[i].kekka[k][3]==1){
					kekka_matome[k][1]++;//1：勝ち数
					kekka_matome[k][3]+=hyouka_data[i].kekka[k][41];//３：勝ちPIPS  //41  entry　結果　[Pips]
				}else{
					kekka_matome[k][2]++;//２：負け数
					kekka_matome[k][4]-=hyouka_data[i].kekka[k][41];//４：負けPIPS  //41  entry　結果　[Pips]
				}
				bview=true;
			}

        }
    }
//            for(int k = 0; k<10; k++){
//				if(k==0){continue;}// ０は結果が悪いので出力しない
                if(kekka_matome[k][1]!=0 && kekka_matome[k][2]!=0&&kekka_matome[k][4]!=0){
                  printf(
                    "k="+ IntegerToString(k)+" ; "+
                    "数="+IntegerToString((int)kekka_matome[k][0])+" ; "+
                    "勝数="+IntegerToString((int)kekka_matome[k][1])+" ; "+
                    "負数="+IntegerToString((int)kekka_matome[k][2])+" ; "+
                    "勝Pips="+DoubleToString(kekka_matome[k][3],1)+" ; "+
                    "負Pips="+DoubleToString(kekka_matome[k][4],1)+" ; "+
                    "勝率="+DoubleToString(kekka_matome[k][1]/kekka_matome[k][0],3 )+" ; "+
                    "期待値="+DoubleToString( 
                          kekka_matome[k][3]/kekka_matome[k][1]*kekka_matome[k][1]/kekka_matome[k][0] 
                          -kekka_matome[k][4]/kekka_matome[k][2]*kekka_matome[k][2]/kekka_matome[k][0] 
                          
                          ,2)+" ; "+
                    "Pf="+DoubleToString(kekka_matome[k][3]/kekka_matome[k][4],2)
                    );
                }
    
    
//			}    
    
}



void view_kekka_youso_flag(int n){// 評価パターンｎ
    string strout="";
    addstring(strout,"kekka　要素　"+IntegerToString(n)+""+ _Symbol + "--------------");
    //printf("kekka　要素　"+IntegerToString(n)+""+ _Symbol + "--------------");
    
    string str="";
    string TAB="\t";
    string title=
        "idx"+TAB+
        "0 状態"+TAB+
        "1 max:Pips"+TAB+
        "2 minPips"+TAB+
        "3 kati1:make-1"+TAB+
        "4 抜けたときの確定足とラインとの距離"+TAB+
        "5 ３－４距離"+TAB+
        "6 ６－４距離"+TAB+
        "7 M5SMA8傾き"+TAB+
        "8 M5SMA20傾き"+TAB+
        "9 M15SMA8傾き"+TAB+
        "10 M15SMA20傾き"+TAB+
        "11 H1SMA8傾き"+TAB+
        "12 H1SMA20傾き"+TAB+
        "13 H4SMA8傾き"+TAB+
        "14 H4SMA20傾き"+TAB+
        "15 ブレークの時間string"+TAB+
        " ブレークの時間"+TAB+
        "16 ブレーク前のH1直近高値100％としたブレーク位置"+TAB+
        "17 ブレーク前のH1直近B-高値Pips"+TAB+
        "18 ブレーク前のH1直近B-安値Pips"+TAB+
        "19 H1足パターン"+TAB+//　Nとか上場中でトレンド、レンジ、？
        "20 ブレーク前のH4直近高値100％としたブレーク位置"+TAB+
        "21 ブレーク前のH4直近B-高値Pips"+TAB+
        "22 ブレーク前のH4直近B-安値Pips"+TAB+
        "23 H4足パターン"+TAB+//　Nとか上場中でトレンド、レンジ、？
        "24 ブレーク前のD1直近高値100％としたブレーク位置"+TAB+
        "25 ブレーク前のD1直近B-高値Pips"+TAB+
        "26 ブレーク前のD1直近B-安値Pips"+TAB+
        "27 D1足パターン"+TAB+//　Nとか上場中でトレンド、レンジ、？
        "28  entry時のzigzagcount"+TAB+
        "29  exit時のzigzagcount"+TAB+
        "30  レンジ基点１の位置：下側、上側？（上１、下ー１）"+TAB+
        "31  上ライン情報　切片ｙ"+TAB+
        "32  上ライン情報　傾き 0は水平"+TAB+
        "33  下ライン情報　切片"+TAB+
        "34  下ライン情報　傾き 0は水平"+TAB+
        "35  レンジブレークの確定足の価格"+TAB+
        "36  パターン成立時の価格記憶"+TAB+
        "37  entry 方向　上１、下-1、0なし"+TAB+
        "38  Tp　価格"+TAB+
        "39  SL　価格"+TAB+
        "40  entry　価格"+TAB+
        "41  entry　結果　[Pips]"+TAB+
        "42  レンジの幅　値　"+TAB+
        "43  レンジの幅Pips"+TAB+
        "44  entry　時間 (数値-> 文字）"+TAB+
        "";
    addstring(strout,title);
    //printf(title);
    for(int i = 0; i<hyouka_data_num ;i++){
        if(hyouka_data[i].status != 0 && hyouka_data[i].kekka[n][0]==999){
           str=
            IntegerToString(i)+TAB+
            IntegerToString((int)hyouka_data[i].kekka[n][0])+TAB+
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

            IntegerToString((int)hyouka_data[i].kekka[n][28])+TAB+		//"28  entry時のzigzagcount"+TAB+
            IntegerToString((int)hyouka_data[i].kekka[n][29])+TAB+      //"29  exit時のzigzagcount"+TAB+
            IntegerToString((int)hyouka_data[i].kekka[n][30])+TAB+      //"30  レンジ基点１の位置：下側、上側？（上１、下ー１）"+TAB+
            DoubleToString(hyouka_data[i].kekka[n][31])+TAB+            //"31  上ライン情報　切片ｙ"+TAB+
            DoubleToString(hyouka_data[i].kekka[n][32])+TAB+            //"32  上ライン情報　傾き 0は水平"+TAB+
            DoubleToString(hyouka_data[i].kekka[n][33])+TAB+            //"33  下ライン情報　切片"+TAB+
            DoubleToString(hyouka_data[i].kekka[n][34])+TAB+            //"34  下ライン情報　傾き 0は水平"+TAB+
            DoubleToString(hyouka_data[i].kekka[n][35],6)+TAB+            //"35  レンジブレークの確定足の価格"+TAB+
            DoubleToString(hyouka_data[i].kekka[n][36],6)+TAB+            //"36  パターン成立時の価格記憶"+TAB+
            IntegerToString((int)hyouka_data[i].kekka[n][37])+TAB+            //"37  entry 方向　上１、下-1、0なし"+TAB+
            DoubleToString(hyouka_data[i].kekka[n][38],6)+TAB+            //"38  Tp　価格"+TAB+
            DoubleToString(hyouka_data[i].kekka[n][39],6)+TAB+            //"39  SL　価格"+TAB+
            DoubleToString(hyouka_data[i].kekka[n][40],6)+TAB+            //"40  entry　価格"+TAB+
            DoubleToString(hyouka_data[i].kekka[n][41],1)+TAB+            //"41  entry　結果　[Pips]"+TAB+
            DoubleToString(hyouka_data[i].kekka[n][42],6)+TAB+            //"42  レンジの幅　値　"+TAB+
            DoubleToString(hyouka_data[i].kekka[n][43],1)+TAB+            //"43  レンジの幅Pips"+TAB+
            TimeToString((datetime)(hyouka_data[i].kekka[n][44]))+TAB+            //"44  entry　時間 (数値-> 文字）"
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


};
#endif //classMethod_flag
