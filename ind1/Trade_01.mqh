//トレードファイル
#define MAX_GET_ZIGZAGDATA_NUM 10
#include "class_allcandle.mqh"
#define USE_MYFUNC_IND_ENTRY_EXIT
#ifdef USE_MYFUNC_IND_ENTRY_EXIT
#include <_inc\\動的エントリー監視LIB\\Lib_Myfunc_Ind_entry_exit.mqh>
#endif//USE_MYFUNC_IND_ENTRY_EXIT
allcandle *pac;//allcandle pointer
bool flag_is_entry;//エントリー中か　trueエントリー中　false未エントリー
struct struct_pt_data{
    //Zigzagcount
    //pt種別
    //pt構成数（点の数）
};
//input double nobiritu=1.0;// tp d12率
//input double songiriritu = 1.15;//　sl d12率

//Zigパターンは最新Zigは含めないこととする
#define PT_RANGE_LAST_LOW   1 //レンジ　最後のZigが下にある（上で反発するかも）
#define PT_RANGE_LAST_TOP   2 //レンジ　最後のZigが上にある（上で反発するかも）
#define PT_MESEN_UP         3 //目線が上に切り替わり
#define PT_MESEN_DN         4 //目線が下に切り替わり
#define PT_ZOKUSIN_UP         50 //上方向に続伸の形
#define PT_ZOKUSIN_DN         60 //下方向に続伸の形
#define PT_ZOKUSIN_DN_6    61//続伸下　61
#define PT_ZOKUSIN_UP_6    51//続伸上　51
#define PT_ZOKUSIN_DN_Low_3tenLine    71//　下向きで下辺3点が直線上にある
#define PT_ZOKUSIN_DN_Squeeze      72//　下向きスクイーズ（下辺3点と上辺2点）
#define PT_ZOKUSIN_DN_KAKUDAI      73//　下向き拡大（下辺3点と上辺2点）
#define PT_ZOKUSIN_DN_HEIKOU      70//　下向き平行（下辺3点と上辺2点）
#define PT_ZOKUSIN_UP_Top_3tenLine    81//　上向きで上辺3点が直線上にある
#define PT_ZOKUSIN_UP_Squeeze      82//　上向きスクイーズ（上辺3点と下辺2点）
#define PT_ZOKUSIN_UP_KAKUDAI      83//　上向き拡大（上辺3点と下辺2点）
#define PT_ZOKUSIN_UP_HEIKOU      80//　上向き平行（上辺3点と下辺2点）

#define PT_FLAG_DN          90//下向きフラッグ８点（２が４を超えない（弱さ見えたとき））


void chk_trade_forTick(double v,double t,allcandle *pallcandle,bool isTrade){
    double ay[MAX_GET_ZIGZAGDATA_NUM+1];// 価格Zigzag　１からデータ入っている。０は使わない
    int aud[MAX_GET_ZIGZAGDATA_NUM+1];
    datetime at[MAX_GET_ZIGZAGDATA_NUM+1];
    pac = pallcandle;
    //各パターンが成立したかの調査
        //各パターンが成立後、不成立になったかの調査も含めること
    
    //長期のパターン成立？
        //成立→状態を長期パターン成立
    //

    //レンジか
    bool ret=false;
//    ENUM_TIMEFRAMES peri=PERIOD_H1;
    ENUM_TIMEFRAMES peri=PERIOD_M15;
    int ret_match_zigcount =0;//基準のZigzagcount　ｙ１のZigzagcount
    int ret_pt_katachi = 0;//形
    ret = chk_pt_range(peri,ret_match_zigcount,ret_pt_katachi);
    if(ret == true){
        //pt成立
            //既存？//新規？
            bool r=false;bool rr=false;
            r=Is_pt_zigcount_katachi(ret_pt_katachi,ret_match_zigcount);
            if(r==false){
                //Pt表示（レクタングル＋名前（時間＋パターン名）
                view_pt(peri,ret_match_zigcount,ret_pt_katachi);
                //★データの格納・記憶
                    //pt追加
                reg_pt(peri,ret_match_zigcount,ret_pt_katachi);
            }
    }
    //続伸の形か？
    peri=PERIOD_M15;
//    int ret_match_dn_zokusin =0;
    ret=chk_pt_zokusin(peri,ret_match_zigcount,ret_pt_katachi);//★１
    ret =false;//debug not view
    if(ret == true){
        //pt成立
            //既存？//新規？
            bool r=false;bool rr=false;
            r=Is_pt_zigcount_katachi(ret_pt_katachi,ret_match_zigcount);//★１
            if(r==false){
                //Pt表示（レクタングル＋名前（時間＋パターン名）
                view_pt(peri,ret_match_zigcount,ret_pt_katachi);//★１
                //★データの格納・記憶
                    //pt追加
                reg_pt(peri,ret_match_zigcount,ret_pt_katachi);//★１
            }
    }

    //heikouの形か？
    peri=PERIOD_H4;
//    int ret_match_dn_zokusin =0;
    ret=chk_pt_heikou(peri,ret_match_zigcount,ret_pt_katachi);//★１
    if(ret == true){
        //pt成立
            //既存？//新規？
            bool r=false;bool rr=false;
            r=Is_pt_zigcount_katachi(ret_pt_katachi,ret_match_zigcount);//★１
            if(r==false){
                //Pt表示（レクタングル＋名前（時間＋パターン名）
                view_pt(peri,ret_match_zigcount,ret_pt_katachi);//★１
                //★データの格納・記憶
                    //pt追加
                reg_pt(peri,ret_match_zigcount,ret_pt_katachi);//★１
            }
    }
    peri=PERIOD_H1;
//    int ret_match_dn_zokusin =0;
    ret=chk_pt_heikou(peri,ret_match_zigcount,ret_pt_katachi);//★１
    if(ret == true){
        //pt成立
            //既存？//新規？
            bool r=false;bool rr=false;
            r=Is_pt_zigcount_katachi(ret_pt_katachi,ret_match_zigcount);//★１
            if(r==false){
                //Pt表示（レクタングル＋名前（時間＋パターン名）
                view_pt(peri,ret_match_zigcount,ret_pt_katachi);//★１
                //★データの格納・記憶
                    //pt追加
                reg_pt(peri,ret_match_zigcount,ret_pt_katachi);//★１
            }
    }    
       
    peri=PERIOD_M15;
//    int ret_match_dn_zokusin =0;
    ret=chk_pt_heikou(peri,ret_match_zigcount,ret_pt_katachi);//★１
    if(ret == true){
        //pt成立
            //既存？//新規？
            bool r=false;bool rr=false;
            r=Is_pt_zigcount_katachi(ret_pt_katachi,ret_match_zigcount);//★１
            if(r==false){
                //Pt表示（レクタングル＋名前（時間＋パターン名）
                view_pt(peri,ret_match_zigcount,ret_pt_katachi);//★１
                //★データの格納・記憶
                    //pt追加
                reg_pt(peri,ret_match_zigcount,ret_pt_katachi);//★１
            }
    }
    //下フラグ
    peri=PERIOD_M15;
//    int ret_match_dn_zokusin =0;
    ret=chk_shita_flag(peri,ret_match_zigcount,ret_pt_katachi);//★１
    if(ret == true){
        //pt成立
            //既存？//新規？
            bool r=false;bool rr=false;
            r=Is_pt_zigcount_katachi(ret_pt_katachi,ret_match_zigcount);//★１
            if(r==false){
                //Pt表示（レクタングル＋名前（時間＋パターン名）
                view_pt(peri,ret_match_zigcount,ret_pt_katachi);//★１
                //★データの格納・記憶
                    //pt追加
                reg_pt(peri,ret_match_zigcount,ret_pt_katachi);//★１
                
                //1の起点の表示
                string name;
                datetime tt;
                double pp;
                name=IntegerToString(ret_pt_katachi)+":↓Flag　"+PeriodToString(peri)+"zig:"+IntegerToString(ret_match_zigcount);
                int cc=GetTimeColor(peri);
                pp = ay[1];
                tt= at[1];
              
                CreateArrowRightPrice(0,name,0,tt,pp,cc,nSize);
            }
    }    


    //エントリー判断・エントリー
    //#include"Trade_01_core.mqh"
    //#include"Trade_02_core.mqh"
    #include"Trade_05_core.mqh"

    //debug test
    //#include"Trade_debug.mqh"

#ifdef aaaaa    
    peri = PERIOD_H1;
    ret= chk_pt_mesen(peri,ret_match_zigcount,ret_pt_katachi);
    if(ret == true){
        //pt成立
            //既存？//新規？
            bool r=false;bool rr=false;
            r=Is_pt_zigcount_katachi(ret_pt_katachi,ret_match_zigcount);
            if(r==false){
                //Pt表示（レクタングル＋名前（時間＋パターン名）
                view_pt(peri,ret_match_zigcount,ret_pt_katachi);
                //★データの格納・記憶
                    //pt追加
                reg_pt(peri,ret_match_zigcount,ret_pt_katachi);
            }
    }    
#endif //aaaa    


//entry exit ctrl syori
	double bid;
	double ask;
	//RefreshPrice(bid, ask);
      //
	//entry_exit_ctr_tick_exe(ask,bid);


}
struct struct_pt{
    ENUM_TIMEFRAMES period_;
    int zigcount;
    int pt_katachi;//パターン形種別
    int status;//パターンの状態
};
////////////////////////
//ptdata、メモリ系
////////////////////////
struct_pt ptdata[];
int ptdata_count;
//int ptdata_mem_count;//メモリ用 最大値を記憶
#define NUM_YOBI_MEM 1000
void init_pt(void){
    ptdata_count=0;
    ArrayResize(ptdata,1,NUM_YOBI_MEM); 
//    ptdata_mem_count=0;
//for init EntryExitLib
#ifdef USE_MYFUNC_IND_ENTRY_EXIT
//    init_entry_exit_ctr_forEA();//(★EA)
    init_entry_exit_ctr_forInd();//　for　Ind使用★　Initへ追加
#endif//USE_MYFUNC_IND_ENTRY_EXIT

}
bool reg_pt(ENUM_TIMEFRAMES period_,int zigcount,int pt_katachi){
    bool ret=false;
    ptdata[ptdata_count].period_ = period_;
    ptdata[ptdata_count].pt_katachi = pt_katachi;
    ptdata[ptdata_count].zigcount = zigcount;
    
    ptdata_count++;
    ArrayResize(ptdata,ptdata_count+1,NUM_YOBI_MEM);
     
    return(ret);
}
bool Is_pt_zigcount_katachi(int pt_katachi,int zigcount){
    bool ret = false;
    if(zigcount<=0){return false;}
    if(ptdata_count <=0){return false;}
    for(int i=ptdata_count-1;i>=0;i--){
        if(ptdata[i].pt_katachi == pt_katachi && ptdata[i].zigcount == zigcount){
            ret = true;
            break;
        }
    }
    return(ret);
}
bool get_pt_zigcount_for_katachi(int pt_katachi,int &out_zigcount){
//戻り値　ありTrueなしFALSE
//出力　Zigcount（配列idxではない）
    bool ret = false;
    for(int i=ptdata_count-1;i<=0;i--){
        if(ptdata[i].pt_katachi == pt_katachi){
            ret = true;
            out_zigcount = ptdata[i].zigcount;
            break;
        }
    }
    return(ret);
}
bool view_pt(ENUM_TIMEFRAMES period_,int zigcount,int pt_katachi){
    double ay[MAX_GET_ZIGZAGDATA_NUM+1];// 価格Zigzag　１からデータ入っている。０は使わない
    int aud[MAX_GET_ZIGZAGDATA_NUM+1];
    datetime at[MAX_GET_ZIGZAGDATA_NUM+1];
    candle_data *c=pac.get_candle_data_pointer(period_);
    if(c!=NULL){
        bool r=false;
        bool s=false;
        r = get_ZigY_array_org(ay,period_,c.zigzagdata_count-zigcount);
        if(r==false){return false;}
        r = get_ZigX_array_org(at,period_,c.zigzagdata_count-zigcount);
        if(r==false){return false;}
        r = get_ZigUD_array_org(aud,period_,c.zigzagdata_count-zigcount);
        if(r==false){return false;}

        if(pt_katachi == PT_RANGE_LAST_LOW ||
            pt_katachi == PT_RANGE_LAST_TOP
        ){
            string name="range"+zigcount+PeriodToString(period_);
            RectangleCreate(0,name,0,at[1],ay[1],at[4],ay[4]);
            
        }
        if(pt_katachi == PT_MESEN_DN ||
            pt_katachi == PT_MESEN_UP
        ){
            string name="mesen"+zigcount+PeriodToString(period_);
            //RectangleCreate(0,name,0,0,time1,price1,time2,price2,,,,)
            int cc=GetTimeColor(period_);
            TrendCreate(0,name,0,at[1],ay[1],at[2],ay[2],cc,STYLE_SOLID,4);
//            TrendCreate(0,name,0,at[1],ay[1],at[2],ay[2],clrMagenta,STYLE_SOLID,4);
        }
        if(pt_katachi == PT_ZOKUSIN_UP ||
            pt_katachi == PT_ZOKUSIN_DN
        ){
            string name1="zokushin_up"+zigcount+PeriodToString(period_);
            string name2="zokushin_dn"+zigcount+PeriodToString(period_);
            int cc=GetTimeColor(period_);
            if(pt_katachi == PT_ZOKUSIN_UP){
              TrendCreate(0,name1,0,at[1],ay[1],at[5],ay[5],cc,STYLE_SOLID,4);
              TrendCreate(0,name2,0,at[2],ay[2],at[4],ay[4],cc,STYLE_SOLID,4);
            }
            if(pt_katachi == PT_ZOKUSIN_DN){
              TrendCreate(0,name1,0,at[2],ay[2],at[4],ay[4],cc,STYLE_SOLID,4);
              TrendCreate(0,name2,0,at[1],ay[1],at[5],ay[5],cc,STYLE_SOLID,4);
            }
        }
        if(
            pt_katachi == PT_ZOKUSIN_DN_6 ||
            pt_katachi == PT_ZOKUSIN_UP_6 ||
            pt_katachi == PT_ZOKUSIN_DN_Low_3tenLine ||
            pt_katachi == PT_ZOKUSIN_DN_Squeeze ||
            pt_katachi == PT_ZOKUSIN_DN_KAKUDAI ||
            pt_katachi == PT_ZOKUSIN_DN_HEIKOU ||
            pt_katachi == PT_ZOKUSIN_UP_Top_3tenLine ||
            pt_katachi == PT_ZOKUSIN_UP_Squeeze ||
            pt_katachi == PT_ZOKUSIN_UP_KAKUDAI ||
            pt_katachi == PT_ZOKUSIN_UP_HEIKOU 
        ){              
              string name1=IntegerToString(pt_katachi)+":heikou"+zigcount+PeriodToString(period_);
              string name2=IntegerToString(pt_katachi)+":heikou_"+zigcount+PeriodToString(period_);
              int cc=GetTimeColor(period_);
              TrendCreate(0,name1,0,at[5],ay[5],at[3],ay[3],cc,STYLE_SOLID,4);
              TrendCreate(0,name2,0,at[2],ay[2],at[6],ay[6],cc,STYLE_SOLID,4);
            
        }


    }else{return false;}
    return true;
}
bool chk_pt_mesen(ENUM_TIMEFRAMES period_,int &zigcount,int &pt_katachi){
    //PT_MESEN_UP,PT_MESEN_DN
    bool ret = false;
    int out_dir=0;
    int chk_zigcount;

    candle_data *c=pac.get_candle_data_pointer(period_);
    if(c!=NULL){
        chk_zigcount=c.zigzagdata_count;
        bool r=false;
        r=c.chk_mesen_C_zigcount_updn(chk_zigcount,out_dir);
#ifdef aaaaa
            chk_mesen_C_zigcount_updn(now)
        bool chk_mesen_C_zigcount_updn(int zigcount,int out_dir){
        // Cnが変化したものが、Zigcountと会えば　True
        // 方向を返す。該当しないときは０　　上１　下-1
#endif 
        if(r==true){
            ret = true;
            if(out_dir ==1){
                pt_katachi = PT_MESEN_UP;
            }else if(out_dir ==-1){
                pt_katachi = PT_MESEN_DN;
            }
            zigcount=chk_zigcount;
        } 
    }
    return ret;
}


bool chk_pt_range(ENUM_TIMEFRAMES period_,int &zigcount,int &pt_katachi){
    // レンジパターンか
    // 上ラインが同じかどうかの判断は、　サイズの１０％など可変とする。とりあえず１０％としておく
#ifdef commentt
    pt_katachi ==1   1が下の方にある
        ４         2
    　　　   3          1
    or
    pt_katachi ==2　　1が上の方にある
    　　　   3          1
        ４         2
#endif//comenntt
    bool ret=false;
    double ay[MAX_GET_ZIGZAGDATA_NUM+1];// 価格Zigzag　１からデータ入っている。０は使わない
    int aud[MAX_GET_ZIGZAGDATA_NUM+1];
    datetime at[MAX_GET_ZIGZAGDATA_NUM+1];
    double gosa = 0.1;
    int offset = 1;
    candle_data *c=pac.get_candle_data_pointer(period_);
    if(c!=NULL){
        bool r=false;
        bool s=false;
        r = get_ZigY_array_org(ay,period_,offset);
        if(r==false){return false;}
        r = get_ZigX_array_org(at,period_,offset);
        if(r==false){return false;}
        r = get_ZigUD_array_org(aud,period_,offset);
        if(r==false){return false;}
        r=calc_Is_same_2point_2hen_gosa(ay[1],ay[3],MathAbs(ay[1]-ay[2]),MathAbs(ay[3]-ay[4]),gosa);
        s=calc_Is_same_2point_2hen_gosa(ay[2],ay[4],MathAbs(ay[1]-ay[2]),MathAbs(ay[3]-ay[4]),gosa);
        if(r==true&&s==true){
//        if(r==true||s==true){
            //range 成立判断
            //Zigzagcountを基準として覚える
            zigcount=c.zigzagdata_count-offset;
            if(aud[1]==1){
                //1が上なので、
                pt_katachi=2;
            }else{
                pt_katachi=1;
            }
            ret = true;//成立
//        r=calc_Is_same_2point_2hen_gosa(ay[1],ay[3],MathAbs(ay[1]-ay[2]),MathAbs(ay[3]-ay[4]),gosa);
 //       s=calc_Is_same_2point_2hen_gosa(ay[2],ay[4],MathAbs(ay[1]-ay[2]),MathAbs(ay[3]-ay[4]),gosa);
                    
        }else{
            ret = false;//未成立
        }
    }else{return false;}
    return ret;
}
bool chk_pt_zokusin(ENUM_TIMEFRAMES period_,int &zigcount,int &pt_katachi){
    // 上、下方向に続伸か
#ifdef commentt
    pt_katachi ==60   1が下の方にある
              ４
        5        
                            2
          　　　   3                    V  
                                1
    or
    pt_katachi ==50　　1が上の方にある
                                   1
          　　　   3                    V  
                            2
        5        
              ４
#endif//comenntt
    bool ret=false;
    double ay[MAX_GET_ZIGZAGDATA_NUM+1];// 価格Zigzag　１からデータ入っている。０は使わない
    int aud[MAX_GET_ZIGZAGDATA_NUM+1];
    datetime at[MAX_GET_ZIGZAGDATA_NUM+1];
    double gosa = 0.1;
    int offset = 1;
    candle_data *c=pac.get_candle_data_pointer(period_);
    if(c!=NULL){
        bool r=false;
        bool s=false;
        r = get_ZigY_array_org(ay,period_,offset);
        if(r==false){return false;}
        r = get_ZigX_array_org(at,period_,offset);
        if(r==false){return false;}
        r = get_ZigUD_array_org(aud,period_,offset);
        if(r==false){return false;}

        if(
            (aud[1]==-1)
            &&(ay[5]>ay[3]&& ay[3]>ay[1] && ay[4]>ay[2])
        ){
          ret = true;
          pt_katachi = 60;
        }
        if(
            (aud[1]==1)
            &&(ay[5]<ay[3]&& ay[3]<ay[1] && ay[4]<ay[2])
        ){
          ret = true;
          pt_katachi = 50;
        }
        if(ret == true){
            zigcount=c.zigzagdata_count-offset;
        }

    }else{return false;}
    return ret;
}


bool chk_pt_heikou(ENUM_TIMEFRAMES period_,int &zigcount,int &pt_katachi){
    // 上、下方向に平行・スクイーズ・拡大判断（６－２で判断１は除く）（６－４ー２，５－３）
#ifdef commentt
    1を除く形について分類
    0該当なし
    61続伸下　61
    51続伸上　51
    71　下向きで下辺3点が直線上にある
      72　下向きスクイーズ（下辺3点と上辺2点）
      73　下向き拡大（下辺3点と上辺2点）
      70　下向き平行（下辺3点と上辺2点）
    81　上向きで上辺3点が直線上にある
      82　上向きスクイーズ（上辺3点と下辺2点）
      83　上向き拡大（上辺3点と下辺2点）
      80　上向き平行（上辺3点と下辺2点）

    pt_katachi ==70   1が下の方にある　かつ2つ平行、3点が直線７１、3点＋２点でスクイーズ７２
              5
        6        
                            3
          　　　   4                    1  
                                2
    or
    pt_katachi ==80　　1が上の方にある　かつ2つ平行、3点が直線81、3点＋２点でスクイーズ82
                                   2
          　　　   4                    1  
                            3
        6        
              5
#endif//comenntt
    bool ret=false;
    double ay[MAX_GET_ZIGZAGDATA_NUM+1];// 価格Zigzag　１からデータ入っている。０は使わない
    int aud[MAX_GET_ZIGZAGDATA_NUM+1];
    datetime at[MAX_GET_ZIGZAGDATA_NUM+1];
    double gosa = 0.1;
    int offset = 0;//Zigzagの１も利用したいので、最新点（不確定）も含める
    int pt_katachi_tmp=0;
    candle_data *c=pac.get_candle_data_pointer(period_);
    if(c!=NULL){
        bool r=false;
        bool s=false;
        bool s2=false;
        r = get_ZigY_array_org(ay,period_,offset);
        if(r==false){return false;}
        r = get_ZigX_array_org(at,period_,offset);
        if(r==false){return false;}
        r = get_ZigUD_array_org(aud,period_,offset);
        if(r==false){return false;}

        if(
            (aud[1]==1)
            &&(ay[6]>ay[4]&& ay[4]>ay[2] && ay[5]>ay[3])
        ){
          s2 = true;
          pt_katachi_tmp = 61;//続伸下向き
        }
        if(
            (aud[1]==-1)
            &&(ay[6]<ay[4]&& ay[4]<ay[2] && ay[5]<ay[3])
        ){
          s2 = true;
          pt_katachi_tmp = 51;//続伸上向き
        }
        if(s2 == true){//続伸の形か？
          //Zigzagの辺のサイズの平均を取得（絶対値）
          bool r1=false,r2=false;
          double gosabairitu=0.2;//平均Zig高さの何パーセントか？（誤差率）1で１００％
          double ave_zigheikin_value;
          r1=c.get_zigzag_average_dist(0,ave_zigheikin_value);
          r2=c.Is_3point_same_online((double)at[6],ay[6],(double)at[4],ay[4],(double)at[2],ay[2], chgPrice2Pips(ave_zigheikin_value*gosabairitu));
          if(r1==true&&r2==true){// 直線上にある
            if(pt_katachi_tmp == 61){
              pt_katachi_tmp = 71;//下向きで下辺3点が直線上にある
            }
            if(pt_katachi_tmp == 51){
              pt_katachi_tmp = 81;//上向きで上辺3点が直線上にある
            }
              //途中結果を格納
              ret = true;
              pt_katachi = pt_katachi_tmp;
              zigcount=c.zigzagdata_count-offset;            
            bool r3=false;
            r3=c.Is_heikou_2line((double)at[6],ay[6],(double)at[2],ay[2],(double)at[5],ay[5],(double)at[3],ay[3]);
            if(r3==true){//平行？
              if(pt_katachi_tmp == 71){
                pt_katachi_tmp = 70;//下向き平行（下辺3点と上辺2点）
              }
              if(pt_katachi_tmp == 81){
                pt_katachi_tmp = 80;//上向き平行（上辺3点と下辺2点）
              }              
              ret = true;
              pt_katachi = pt_katachi_tmp;
              zigcount=c.zigzagdata_count-offset;
            }else{//拡大？スクイーズ？
              int ttt=c.get_heikou_2line_katamuki_kannkei((double)at[6],ay[6],(double)at[2],ay[2],(double)at[5],ay[5],(double)at[3],ay[3]);
              if(ttt == -1){//-1スクイーズ
                if(pt_katachi_tmp == 71){
                  pt_katachi_tmp = 72;//下向きスクイーズ（下辺3点と上辺2点）
                }
                if(pt_katachi_tmp == 81){
                  pt_katachi_tmp = 82;//上向きスクイーズ（上辺3点と下辺2点）
                }              
              }else if(ttt == 1){//１拡大？
                if(pt_katachi_tmp == 71){
                  pt_katachi_tmp = 73;//下向き拡大（下辺3点と上辺2点）
                }
                if(pt_katachi_tmp == 81){
                  pt_katachi_tmp = 83;//上向き拡大（上辺3点と下辺2点）
                }              
              }
              if(ttt==1 || ttt==-1){
                ret = true;
                pt_katachi = pt_katachi_tmp;
                zigcount=c.zigzagdata_count-offset;                
              }
            }//end 拡大？スクイーズ？
          }//end 直線上にある 
        }//end /続伸の形か？

    }else{return false;}
    return ret;
}
bool chk_shita_flag(ENUM_TIMEFRAMES period_,int &zigcount,int &pt_katachi){
  //下方向フラッグ
  //  A：左が一番長い。その右はAの５０％以内の高さ
  //　8－１の６は４より下がっている
  //　８－７は一番長い、
  //    1以降２まで上方向に切り上げていく  上辺６＜４、下辺７＜５＜３
    bool ret=false;
    double ay[MAX_GET_ZIGZAGDATA_NUM+1];// 価格Zigzag　１からデータ入っている。０は使わない
    int aud[MAX_GET_ZIGZAGDATA_NUM+1];
    datetime at[MAX_GET_ZIGZAGDATA_NUM+1];
    double adist[MAX_GET_ZIGZAGDATA_NUM+1];
    double gosa = 0.1;
    int offset = 0;//Zigzagの１も利用したいので、最新点（不確定）も含める
    int pt_katachi_tmp=0;
    candle_data *c=pac.get_candle_data_pointer(period_);
    if(c!=NULL){
        bool r=false;
        bool s=false;
        bool s2=false;
        r = get_ZigY_array_org(ay,period_,offset);
        if(r==false){return false;}
        r = get_ZigX_array_org(at,period_,offset);
        if(r==false){return false;}
        r = get_ZigUD_array_org(aud,period_,offset);
        if(r==false){return false;}
        r = get_ZigDist_array_org(adist,period_,offset);
        if(r==false){return false;}
        int baseidx=8;
        if(
            (aud[baseidx-1]==-1)
            // 8baseなら下辺７，５，３上辺６，４
            &&(ay[baseidx-1]<ay[baseidx-3]&& ay[baseidx-3]<ay[baseidx-5] && ay[baseidx-2]<ay[baseidx-4])
            //
        ){
          bool yowai=false;
          // ２が４まで到達していない（戻りが弱くなった証拠あるか？）
          if(ay[baseidx-6]<ay[baseidx-4]){
            yowai = true;
          }
          bool tyokkin3wokoeru =false;
          if(ay[1]<ay[3]){
            tyokkin3wokoeru = true;  
          }else{
            tyokkin3wokoeru = false;
          }
          bool tyokkin5wokoeru =false;
          if(ay[1]<ay[5]){
            tyokkin5wokoeru = true;  
          }else{
            tyokkin5wokoeru = false;
          }
          //8-7の長い辺の７０％以内のフラッグ
          bool hannbunnika70=false;
          if(ay[8]-adist[7]*0.3 > ay[4]){
            hannbunnika70=true;
          } 
          //8-7の長い辺の30％以内のフラッグ
          bool hannbunnika30=false;
          if(ay[8]-adist[7]*0.7 > ay[4]){
            hannbunnika30=true;
          } 
          if(yowai==true ){
            ret =true;
            pt_katachi = 90;//下向きフラッグ
            zigcount=c.zigzagdata_count;
          }
        }

    }  
  return ret;

}
//Zigzagdataの配列データを得る
bool get_ZigY_array(double &data[],ENUM_TIMEFRAMES period_){// 最後のZigzagPointを扱うとき　基準はZigzagcount
    return(get_ZigY_array_org(data,period_,0));
}
bool get_ZigY_array_org(double &data[],ENUM_TIMEFRAMES period_,int offset){//　基準Zigzagcount　は最後からどれだけ移動するかを表すOffset＝最後のZigzagCount－基準のZigzagcountで求めること　
    candle_data *c=pac.get_candle_data_pointer(period_);
    bool ret=false;
    int n=MAX_GET_ZIGZAGDATA_NUM;//とりあえず固定
    if(c!=NULL){
        for(int i = 1;i<=MAX_GET_ZIGZAGDATA_NUM;i++){
            data[i] = c.ZigY(i+offset);
            if(data[i]==0){return false;}
        }
    }else{return false;}    
    return(true);
}
bool get_ZigX_array(datetime &data[],ENUM_TIMEFRAMES period_){
    return ( get_ZigX_array_org(data,period_,0));
}
bool get_ZigX_array_org(datetime &data[],ENUM_TIMEFRAMES period_,int offset){
    candle_data *c=pac.get_candle_data_pointer(period_);
    bool ret=false;
    int n=MAX_GET_ZIGZAGDATA_NUM;//とりあえず固定
    if(c!=NULL){
        for(int i = 1;i<=MAX_GET_ZIGZAGDATA_NUM;i++){
            data[i] = (datetime)c.ZigX(i+offset);
            if(data[i]==0){return false;}
        }
    }else{return false;}    
    return(true);
}
bool get_ZigUD_array(int &data[],ENUM_TIMEFRAMES period_){
    return(get_ZigUD_array_org(data,period_,0));
}
bool get_ZigDist_array_org(double &data[],ENUM_TIMEFRAMES period_,int offset){//　基準Zigzagcount　は最後からどれだけ移動するかを表すOffset＝最後のZigzagCount－基準のZigzagcountで求めること　//add 20210110
//距離を求める（価格差）data[idx]は  右記の絶対値（ZigX(idx)-ZigY(idx+1)）
// data[0]は使わない１－MAX_GET_ZIGZAGDATA_NUMのidxに格納
//　data[1]がZigzag1-2の線分の長さ

    candle_data *c=pac.get_candle_data_pointer(period_);
    bool ret=false;
    int n=MAX_GET_ZIGZAGDATA_NUM;//とりあえず固定
    if(c!=NULL){
        for(int i = 1;i<=MAX_GET_ZIGZAGDATA_NUM;i++){
            double a=0.0,b=0.0;
            a=c.ZigY(i+offset);
            b=c.ZigY(i+offset+1);
            if(a==0.0||b==0.0){return false;}
            data[i] = MathAbs(a-b);
            if(data[i]==0){return false;}
        }
    }else{return false;}    
    return(true);
}
bool get_ZigUD_array_org(int &data[],ENUM_TIMEFRAMES period_,int offset){
    // offset 0の時は、ZigXX(1) 
    //　offset = (Zigzagcount-1) - 該当のZigzagの数-1
    // 例：最大７カウントのとき　一つ前のとき６のZig(1)はZig(2)としたい
    // offset = 7-1  - 6-1=1
    // ZigXX(n+offset)
    candle_data *c=pac.get_candle_data_pointer(period_);
    bool ret=false;
    int n=MAX_GET_ZIGZAGDATA_NUM;//とりあえず固定
    if(c!=NULL){
        for(int i = 1;i<=MAX_GET_ZIGZAGDATA_NUM;i++){
            data[i] = (int)c.ZigUD(i+offset);
            if(data[i]==0){return false;}
        }
    }else{return false;}    
    return(true);
}
//2点が同一かどうかの判定、　
//（input：2点価格、同一範囲dy 線分が2本あった場合。その平均の１０％とする。）
bool calc_Is_same_2point_2hen_gosa(double a,double b,double ady,double bdy,double gosa){
    // 2点a,b  a含む線分の長さady、b含む線分の長さbdy, gosaは線分の何パーセントか１０％は0.1
    bool ret=false;
    double dy=((ady+bdy)*gosa)/2.0;
    if(MathAbs(a-b)<dy){
        ret = true;
    }
    return(ret);
}

/////////////////////Lib とすべき
//+------------------------------------------------------------------+
//| 与えられた座標で四角形を作成する                                         |
//+------------------------------------------------------------------+
//RectangleCreate(0,name,0,0,time1,price1,time2,price2,,,,)
bool RectangleCreate(const long            chart_ID=0,       // チャート識別子
                    const string          name="Rectangle", // 四角形名
                    const int             sub_window=0,     // サブウィンドウ番号
                    datetime              time1=0,           // 1 番目のポイントの時間
                    double                price1=0,         // 1 番目のポイントの価格
                    datetime              time2=0,           // 2 番目のポイントの時間
                    double                price2=0,         // 2 番目のポイントの価格
                    const color           clr=clrRed,       // 四角形の色
                    const ENUM_LINE_STYLE style=STYLE_SOLID, // 四角形の線のスタイルs
                    const int             width=1,           // 四角形の線の幅
                    const bool            fill=false,       // 四角形を色で塗りつぶす
                    const bool            back=false,       // 背景で表示する
                    const bool            selection=true,   // 強調表示して移動
                    const bool            hidden=true,       // オブジェクトリストに隠す
                    const long            z_order=0)         // マウスクリックの優先順位
 {
//--- 設定されてない場合アンカーポイントの座標を設定する
  ChangeRectangleEmptyPoints(time1,price1,time2,price2);
//--- エラー値をリセットする
  ResetLastError();
//--- 与えられた座標で四角形を作成する
  if(!ObjectCreate(chart_ID,name,OBJ_RECTANGLE,sub_window,time1,price1,time2,price2))
    {
    Print(__FUNCTION__,
          ": failed to create a rectangle! Error code = ",GetLastError());
    return(false);
    }
//--- 四角形の色を設定
  ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- 四角形の線のスタイルを設定
  ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- 四角形の線の幅を設定s
  ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- 四角形を色で塗りつぶすモードを有効（true）か無効（false）にする
  ObjectSetInteger(chart_ID,name,OBJPROP_FILL,fill);
//--- 前景（false）または背景（true）に表示
  ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- 強調表示して 四角形を移動するモードを有効（true）か無効（false）にする
//--- ObjectCreate 関数を使用してグラフィックオブジェクトを作成する際、オブジェクトは
//--- デフォルトではハイライトされたり動かされたり出来ない。このメソッド内では、選択パラメータは
//--- デフォルトでは true でハイライトと移動を可能にする。
  ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
  ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- オブジェクトリストのグラフィックオブジェクトを非表示（true）か表示（false）にする
  ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- チャートのマウスクリックのイベントを受信するための優先順位を設定する
  ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- 実行成功
  return(true);
 }
 void ChangeRectangleEmptyPoints(datetime &time1,double &price1,
                              datetime &time2,double &price2)
 {
//--- 1 番目のポイントの時間が設定されていない場合、現在足になる
  if(!time1)
     time1=TimeCurrent();
//--- 1 番目のポイントの価格が設定されていない場合、売値になる
  if(!price1)
     price1=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- 2 番目のポイントの時間が設定されていない場合、2 番目から 9 バー左に置かれる
  if(!time2)
    {
    //--- 最後の 10 バーのオープン時間を受信するための配列
    datetime temp[10];
    CopyTime(Symbol(),Period(),time1,10,temp);
    //--- 2 番目のポイントを最初のものから 9 バー左に設定する
     time2=temp[0];
    }
//--- 1 番目のポイントの価格が設定されていない場合、2 番目より 300 ポイント低くする
  if(!price2)
     price2=price1-300*SymbolInfoDouble(Symbol(),SYMBOL_POINT);
 }
 //+------------------------------------------------------------------+
//| 与えられた座標で傾向線を作成する                                         |
//+------------------------------------------------------------------+
bool TrendCreate(const long            chart_ID=0,       // チャート識別子
                const string          name="TrendLine", // 線の名称
                const int             sub_window=0,     // サブウィンドウ番号
                datetime              time1=0,           // 1 番目のポイントの時間
                double                price1=0,         // 1 番目のポイントの価格
                datetime              time2=0,           // 2 番目のポイントの時間
                double                price2=0,         // 2 番目のポイントの価格
                const color           clr=clrRed,       // 線の色
                const ENUM_LINE_STYLE style=STYLE_SOLID, // 線のスタイル
                const int             width=1,           // 線の幅
                const bool            back=false,       // 背景で表示する
                const bool            selection=true,   // 強調表示して移動
                const bool            ray_left=false,   // 線の左への継続
                const bool            ray_right=false,   // 線の右への継続
                const bool            hidden=true,       // オブジェクトリストに隠す
                const long            z_order=0)         // マウスクリックの優先順位
 {
//--- 設定されてない場合アンカーポイントの座標を設定する
  ChangeTrendEmptyPoints(time1,price1,time2,price2);
//--- エラー値をリセットする
  ResetLastError();
//--- 与えられた座標で傾向線を作成する
  if(!ObjectCreate(chart_ID,name,OBJ_TREND,sub_window,time1,price1,time2,price2))
    {
    Print(__FUNCTION__,
          ": failed to create a trend line! Error code = ",GetLastError());
    return(false);
    }
//--- 線の色を設定する
  ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- 線の表示スタイルを設定する
  ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- 線の幅を設定する
  ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- 前景（false）または背景（true）に表示
  ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- マウスで線を移動させるモードを有効（true）か無効（false）にする
//--- ObjectCreate 関数を使用してグラフィックオブジェクトを作成する際、オブジェクトは
//--- デフォルトではハイライトされたり動かされたり出来ない。このメソッド内では、選択パラメータは
//--- デフォルトでは true でハイライトと移動を可能にする。
  ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
  ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- 線の表示を左に延長するモードを有効（true）か無効（false）にする
  ObjectSetInteger(chart_ID,name,OBJPROP_RAY_LEFT,ray_left);
//--- 線の表示を右に延長するモードを有効（true）か無効（false）にする
  ObjectSetInteger(chart_ID,name,OBJPROP_RAY_RIGHT,ray_right);
//--- オブジェクトリストのグラフィックオブジェクトを非表示（true）か表示（false）にする
  ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- チャートのマウスクリックのイベントを受信するための優先順位を設定する
  ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- 実行成功
  return(true);
 }
//+------------------------------------------------------------------+
//| 傾向線のアンカーポイントを移動する                                         |
//+------------------------------------------------------------------+
bool TrendPointChange(const long   chart_ID=0,       // チャート識別子
                    const string name="TrendLine", // 線の名称
                    const int    point_index=0,   // アンカーポイントのインデックス
                    datetime     time=0,           // アンカーポイントの時間座標
                    double       price=0)         // アンカーポイントの価格座標
 {
//--- ポイントの位置が設定されていない場合、売値を有する現在足に移動する
  if(!time)
     time=TimeCurrent();
  if(!price)
     price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- エラー値をリセットする
  ResetLastError();
//--- 傾向線のアンカーポイントを移動する
  if(!ObjectMove(chart_ID,name,point_index,time,price))
    {
    Print(__FUNCTION__,
          ": failed to move the anchor point! Error code = ",GetLastError());
    return(false);
    }
//--- 実行成功
  return(true);
 }
//+------------------------------------------------------------------+
//| この関数はチャートから傾向線を削除する                                      |
//+------------------------------------------------------------------+
bool TrendDelete(const long   chart_ID=0,       // チャート識別子
                const string name="TrendLine") // 線の名称
 {
//--- エラー値をリセットする
  ResetLastError();
//--- 傾向線を削除する
  if(!ObjectDelete(chart_ID,name))
    {
    Print(__FUNCTION__,
          ": failed to delete a trend line! Error code = ",GetLastError());
    return(false);
    }
//--- 実行成功
  return(true);
 }
//+------------------------------------------------------------------+
//| 傾向線のアンカーポイントの値をチェックして                                     |
//| 空の物には初期値を設定する                                             |
//+------------------------------------------------------------------+
void ChangeTrendEmptyPoints(datetime &time1,double &price1,
                          datetime &time2,double &price2)
 {
//--- 1 番目のポイントの時間が設定されていない場合、現在足になる
  if(!time1)
     time1=TimeCurrent();
//--- 1 番目のポイントの価格が設定されていない場合、売値になる
  if(!price1)
     price1=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- 2 番目のポイントの時間が設定されていない場合、2 番目から 9 バー左に置かれる
  if(!time2)
    {
    //--- 最後の 10 バーのオープン時間を受信するための配列
    datetime temp[10];
    CopyTime(Symbol(),Period(),time1,10,temp);
    //--- 2 番目のポイントを最初のものから 9 バー左に設定する
     time2=temp[0];
    }
//--- 2 番目のポイントの価格は設定されていない場合は 1 番目のポイントと等しい
  if(!price2)
     price2=price1;
 }

void CreateArrowRightPrice //CreateArrowRightPrice(0,"",0,Time,Price,Color,3)
(
 long   chart_id,         // chart ID
 string name,             // object name
 int    nwin,             // window index
 datetime Time,           // position of price label by time
 double Price,            // position of price label by vertical
 color  Color,            // text color
 uint    Size             // font size
 //,int idx            // ０最新のidx
 )
//---- 
  {
//----
//	datetime idxtime = TimeCurrent()-idx * timePerbar;
	//not use tick so
//	idxtime = Time;
//	idxtime = time[idx];
	
//string new_name = 
   bool ret=false;
   ret=ObjectCreate(chart_id,name,OBJ_ARROW_RIGHT_PRICE,nwin,Time,Price);
//   ObjectCreate(chart_id,name,OBJ_ARROW_RIGHT_PRICE,nwin,idxtime,Price);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetInteger(chart_id,name,OBJPROP_WIDTH,Size);
//ObjectSetInteger(chart_id,name,OBJPROP_BACK,true);
//----
  }