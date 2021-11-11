//トレードファイル
#define MAX_GET_ZIGZAGDATA_NUM 10
#include "class_allcandle.mqh"
#define USE_MYFUNC_IND_ENTRY_EXIT
#ifdef USE_MYFUNC_IND_ENTRY_EXIT
#include <_inc\\動的エントリー監視LIB\\Lib_Myfunc_Ind_entry_exit.mqh>
#endif//USE_MYFUNC_IND_ENTRY_EXIT
allcandle *pac;//allcandle pointer
bool flag_is_entry;//エントリー中か　trueエントリー中　false未エントリー
bool b_ok_entry;
struct struct_pt_data{
    //Zigzagcount
    //pt種別
    //pt構成数（点の数）
};
//input double nobiritu=1.0;// tp d12率
//input double songiriritu = 1.15;//　sl d12率

//option
//#define USE_VIEW_printf_katachiNo //形の番号と時間を出力
#define USE_debug_Cn_Lcn   //

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


void chk_trade_forTick(double v,datetime t,allcandle *pallcandle,bool isTrade){
//debug
//test_sturct_mesen_tyouten_mesenKirikawariKyouka();
    //debug
   #ifdef debug_20211101
   //printf("call pre test_struct_mesen_info_chg_mesen_data1");
   #endif      
    test_struct_mesen_info_chg_mesen_data1();
    //debug
//debug end
    double ay[MAX_GET_ZIGZAGDATA_NUM+1];// 価格Zigzag　１からデータ入っている。０は使わない
    int aud[MAX_GET_ZIGZAGDATA_NUM+1];
    datetime at[MAX_GET_ZIGZAGDATA_NUM+1];
    ay[0]=0.0;aud[0]=0;at[0]=0;
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
    //#include"Trade_05_core.mqh"
    //#include "Trade_06_core.mqh"
    //debug test
    //#include"Trade_debug.mqh"


////////////////////////////////////////////////    
////////////////////////////////////////////////    
////////////////////////////////////////////////    
////////////////////////////////////////////////  

//#define USE_trade_00 //rand ランダム
#ifdef USE_trade_00
  bool isnew_bar=flagchgbarM15;
  if(isnew_bar == true && b_during_test_piriod==true){


    //最上位足の目線切り替わり？
    ENUM_TIMEFRAMES peri_hh=PERIOD_H4;
    //上位足の目線切り替わり？
    ENUM_TIMEFRAMES peri_h=PERIOD_H1;
    //ENUM_TIMEFRAMES 
    peri=PERIOD_M15;


    candle_data *c_hh=pac.get_candle_data_pointer(peri_hh);
    candle_data *c_h=pac.get_candle_data_pointer(peri_h);
    candle_data *c_l=pac.get_candle_data_pointer(peri);
    int out_status=0,out_zigzagidx=0, out_dir=0;
    bool ret_isChg_mesen=false;
    //int paraCn_zigzagidx_ev;
    //ENUM_TIMEFRAMES paraCn_period_;

    if(c_h!=NULL && c_l!=NULL&&c_hh!=NULL){
      //時間取り出し  Inp_para_int1時間、Inp_para_int2売り買い（0：買い,1売り）
      //　、Inp_para_double1　ｔｐPIPS　　　　、Inp_para_double２　ｓｌPIPS
      MqlDateTime mqldatetime;
      bool bmqldatetime=false;
      bmqldatetime = TimeToStruct(t,mqldatetime);
      int hour = mqldatetime.hour;

      //取引条件確認
      if(hour == Inp_para_int1&& mqldatetime.min ==0){
        int ent_direct=0;
        //エントリー
        double ent_tp;
        double ent_sl;
        if(Inp_para_int2==0){//買い
          ent_direct=1;
          ent_tp = v+chgPips2price(Inp_para_double1);
          ent_sl = v-chgPips2price(Inp_para_double2);
           
        }else if(Inp_para_int2==1){//売り
          ent_direct=-1;
          ent_tp = v-chgPips2price(Inp_para_double1);
          ent_sl = v+chgPips2price(Inp_para_double2);
        }  

        //SetSendData_forEntry_tpsl_direct_ctrl(EntryDirect,hyoukaNo,hyoukaSyuhouNo,EntryPrice,Tp_Price,Sl_Price,lots);
        SetSendData_forEntry_tpsl_direct_ctrl(ent_direct,0,0,v,ent_tp,ent_sl,0.1);
        //view
        string name1="tp="+ TimeToString(t); //IntegerToString(c_l.zigzagdata_count)+"tp/sl="+DoubleToString(d.tp_pips/d.sl_pips);
        string name2="entry="+TimeToString(t); //IntegerToString(c_l.zigzagdata_count)+"oshi="+DoubleToString(d.Cn_oshimodori);
        string name3="sl="+TimeToString(t); //IntegerToString(c_l.zigzagdata_count);
        int cc=GetTimeColor(peri);
          datetime bt=24*15*60;
          TrendCreate(0,name1,0,t,ent_tp    ,t+bt,ent_tp,cc,STYLE_SOLID,4);
          TrendCreate(0,name2,0,t,v ,t+bt,v,cc,STYLE_SOLID,4);          
          TrendCreate(0,name3,0,t,ent_sl    ,t+bt,ent_sl,cc,STYLE_SOLID,4);   

      }
     //チェックtpsl
        tpls_chk(v,t);

#ifdef dellll
        //フィルタ
        int hh_ma_handle = c_hh.handle_sma_20;
        double hh_ma_20_sma; 
        c_hh.ma_get_value_now(hh_ma_handle,hh_ma_20_sma,t);
        double hh_ma_20_sma_katamuki;
        c_hh.ma_get_katamuki_now(hh_ma_handle,hh_ma_20_sma_katamuki,t);
        bool filter1 = hh_ma_20_sma_katamuki>0 && hh_ma_20_sma < v;
        if(filter1==true){
          bool r=false;
          int offset = 0;
          r = get_ZigY_array_org(ay,peri,offset);
          if(r==false){printf("not get ay");return;}
          r = get_ZigX_array_org(at,peri,offset);
          if(r==false){printf("not get at");return;}


      
          //エントリー時	type 2
            double dd54=MathAbs(ay[5]-ay[4]);
            double dd43=MathAbs(ay[4]-ay[3]);
            double dd32=MathAbs(ay[3]-ay[2]);
            double dd21=MathAbs(ay[2]-ay[1]);
            int bb42=(int)MathAbs((at[4]-at[2]));;
            int bb41=(int)MathAbs((at[4]-at[1]));;

            bool cond=false;
            cond =((dd54 >dd43)&&(dd54 >dd32)&&(dd54 >dd21)) &&
                ((ay[5] >ay[4])&&(ay[5] >ay[3])&&(ay[5] >ay[2])&&(ay[5] >ay[1])) &&
                ((ay[2] <ay[5])&&(ay[2] <ay[4])&&(ay[2] <ay[3])&&(ay[2] <ay[1])) &&
                ((ay[1] >ay[3])&&(dd32*1.1 <dd21)) ;


            double para_entryline=Inp_para_double1;//0-N
            double para_tp_ritu=Inp_para_double2;//
            double para_sl_ritu=Inp_para_double3;
            double para_ct_ritu=Inp_para_double4;
            if(cond==true){
                struct_tpsl d;
      //          double entryline=ay[4]+dd43*0.1;
                double entryline=ay[4]+dd43*para_entryline;    //★★
      //          double entryline=ay[4]+dd43*1;
                d.entry	=	entryline;
                d.dir	=	1;			//固定							
      //          d.tp	=	dd21+ay[4];										
      //          d.sl	=	ay[2]-dd32*0.2;
                d.tp	=	dd21*para_tp_ritu+ay[4];					//★★					
                d.sl	=	ay[2]-dd32*para_sl_ritu;
                
      //          d.sl	=	ay[2]-dd32*0.5;		//debug								
                d.tp_pips	=	MathAbs(	chgPrice2Pips(d.tp-entryline));
                d.sl_pips	=	MathAbs(	chgPrice2Pips(d.sl-entryline));									
                    double ttt=0.0;if(d.tp_pips!=0){ttt=d.sl_pips/d.tp_pips;}else{ttt=9999;}												
                d.tp_sl_hi	=	ttt;										
                                                                    
                c_l.get_oshimodoshi_ritu(c_l.zigzagdata_count-1,entryline,d.Cn_oshimodori);													
                c_hh.get_oshimodoshi_ritu(c_hh.zigzagdata_count-1,entryline,d.joui_oshiodori);													

      //          d.canceltime	=	at[1]+bb42*2;   // 4-2の幅以内
      //          d.canceltime	=	at[1]+bb41*2;   // 4-1 *2の幅以内
                d.canceltime	=	(datetime)(at[1]+bb41*para_ct_ritu);   // 4-1 *2の幅以内  //★★
      //d.canceltime	=0;
                d.entryzigidx = c_l.zigzagdata_count-1;
                //登録
                bool isreg=false;
                isreg= tpsl_set_data_entryline_canceltime(d);

                //view
                if(isreg==true){
                  string name1="tp:zig="+IntegerToString(c_l.zigzagdata_count)+"tp/sl="+DoubleToString(d.tp_pips/d.sl_pips);
                  string name2="entry:zig="+IntegerToString(c_l.zigzagdata_count)+"oshi="+DoubleToString(d.Cn_oshimodori);
                  string name3="sl:zig="+IntegerToString(c_l.zigzagdata_count);
                  int cc=GetTimeColor(peri);
                    datetime bt=24*15*60;
                    TrendCreate(0,name1,0,at[1],d.tp    ,d.canceltime,d.tp,cc,STYLE_SOLID,4);
                    TrendCreate(0,name2,0,at[1],d.entry ,d.canceltime,d.entry,cc,STYLE_SOLID,4);          
                    TrendCreate(0,name3,0,at[1],d.sl    ,d.canceltime,d.sl,cc,STYLE_SOLID,4);   
                    cc=cc;      
                } 

            }
        }//filter1==true
#endif //dellll
      }
  }
#endif //USE_trade_00
////////////////////////////////////////////////    
////////////////////////////////////////////////    
////////////////////////////////////////////////    
////////////////////////////////////////////////  

//#define USE_trade_08
#ifdef USE_trade_08
  bool isnew_bar=flagchgbarM15;
  if(isnew_bar == true && b_during_test_piriod==true){


    //最上位足の目線切り替わり？
    ENUM_TIMEFRAMES peri_hh=PERIOD_H4;
    //上位足の目線切り替わり？
    ENUM_TIMEFRAMES peri_h=PERIOD_H1;
    //ENUM_TIMEFRAMES 
    peri=PERIOD_M15;


    candle_data *c_hh=pac.get_candle_data_pointer(peri_hh);
    candle_data *c_h=pac.get_candle_data_pointer(peri_h);
    candle_data *c_l=pac.get_candle_data_pointer(peri);
    int out_status=0,out_zigzagidx=0, out_dir=0;
    bool ret_isChg_mesen=false;
    //int paraCn_zigzagidx_ev;
    //ENUM_TIMEFRAMES paraCn_period_;

    if(c_h!=NULL && c_l!=NULL&&c_hh!=NULL){
     //チェックtpsl
        tpls_chk(v,t);
        //フィルタ
        int hh_ma_handle = c_hh.handle_sma_20;
        double hh_ma_20_sma; 
        c_hh.ma_get_value_now(hh_ma_handle,hh_ma_20_sma,t);
        double hh_ma_20_sma_katamuki;
        c_hh.ma_get_katamuki_now(hh_ma_handle,hh_ma_20_sma_katamuki,t);
        bool filter1 = hh_ma_20_sma_katamuki>0 && hh_ma_20_sma < v;
        if(filter1==true){
          bool r=false;
          int offset = 0;
          r = get_ZigY_array_org(ay,peri,offset);
          if(r==false){printf("not get ay");return;}
          r = get_ZigX_array_org(at,peri,offset);
          if(r==false){printf("not get at");return;}


      
          //エントリー時	type 2
            double dd54=MathAbs(ay[5]-ay[4]);
            double dd43=MathAbs(ay[4]-ay[3]);
            double dd32=MathAbs(ay[3]-ay[2]);
            double dd21=MathAbs(ay[2]-ay[1]);
            int bb42=(int)MathAbs((at[4]-at[2]));;
            int bb41=(int)MathAbs((at[4]-at[1]));;

            bool cond=false;
            cond =((dd54 >dd43)&&(dd54 >dd32)&&(dd54 >dd21)) &&
                ((ay[5] >ay[4])&&(ay[5] >ay[3])&&(ay[5] >ay[2])&&(ay[5] >ay[1])) &&
                ((ay[2] <ay[5])&&(ay[2] <ay[4])&&(ay[2] <ay[3])&&(ay[2] <ay[1])) &&
                ((ay[1] >ay[3])&&(dd32*1.1 <dd21)) ;


            double para_entryline=Inp_para_double1;//0-N
            double para_tp_ritu=Inp_para_double2;//
            double para_sl_ritu=Inp_para_double3;
            double para_ct_ritu=Inp_para_double4;
            if(cond==true){
                struct_tpsl d;
      //          double entryline=ay[4]+dd43*0.1;
                double entryline=ay[4]+dd43*para_entryline;    //★★
      //          double entryline=ay[4]+dd43*1;
                d.entry	=	entryline;
                d.dir	=	1;			//固定							
      //          d.tp	=	dd21+ay[4];										
      //          d.sl	=	ay[2]-dd32*0.2;
                d.tp	=	dd21*para_tp_ritu+ay[4];					//★★					
                d.sl	=	ay[2]-dd32*para_sl_ritu;
                
      //          d.sl	=	ay[2]-dd32*0.5;		//debug								
                d.tp_pips	=	MathAbs(	chgPrice2Pips(d.tp-entryline));
                d.sl_pips	=	MathAbs(	chgPrice2Pips(d.sl-entryline));									
                    double ttt=0.0;if(d.tp_pips!=0){ttt=d.sl_pips/d.tp_pips;}else{ttt=9999;}												
                d.tp_sl_hi	=	ttt;										
                                                                    
                c_l.get_oshimodoshi_ritu(c_l.zigzagdata_count-1,entryline,d.Cn_oshimodori);													
                c_hh.get_oshimodoshi_ritu(c_hh.zigzagdata_count-1,entryline,d.joui_oshiodori);													

      //          d.canceltime	=	at[1]+bb42*2;   // 4-2の幅以内
      //          d.canceltime	=	at[1]+bb41*2;   // 4-1 *2の幅以内
                d.canceltime	=	(datetime)(at[1]+bb41*para_ct_ritu);   // 4-1 *2の幅以内  //★★
      //d.canceltime	=0;
                d.entryzigidx = c_l.zigzagdata_count-1;
                //登録
                bool isreg=false;
                isreg= tpsl_set_data_entryline_canceltime(d);

                //view
                if(isreg==true){
                  string name1="tp:zig="+IntegerToString(c_l.zigzagdata_count)+"tp/sl="+DoubleToString(d.tp_pips/d.sl_pips);
                  string name2="entry:zig="+IntegerToString(c_l.zigzagdata_count)+"oshi="+DoubleToString(d.Cn_oshimodori);
                  string name3="sl:zig="+IntegerToString(c_l.zigzagdata_count);
                  int cc=GetTimeColor(peri);
                    datetime bt=24*15*60;
                    TrendCreate(0,name1,0,at[1],d.tp    ,d.canceltime,d.tp,cc,STYLE_SOLID,4);
                    TrendCreate(0,name2,0,at[1],d.entry ,d.canceltime,d.entry,cc,STYLE_SOLID,4);          
                    TrendCreate(0,name3,0,at[1],d.sl    ,d.canceltime,d.sl,cc,STYLE_SOLID,4);   
                    cc=cc;      
                } 

            }
        }//filter1==true  
      }
  }
#endif //USE_trade_08    
////////////////////////////////////////////////    
////////////////////////////////////////////////    
////////////////////////////////////////////////    
////////////////////////////////////////////////  
//#define USE_trade_07
#ifdef USE_trade_07
  bool isnew_bar=flagchgbarM15;
  if(isnew_bar == true && b_during_test_piriod==true){


    //最上位足の目線切り替わり？
    ENUM_TIMEFRAMES peri_hh=PERIOD_H4;
    //上位足の目線切り替わり？
    ENUM_TIMEFRAMES peri_h=PERIOD_H1;
    //ENUM_TIMEFRAMES 
    peri=PERIOD_M15;


    candle_data *c_hh=pac.get_candle_data_pointer(peri_hh);
    candle_data *c_h=pac.get_candle_data_pointer(peri_h);
    candle_data *c_l=pac.get_candle_data_pointer(peri);
    int out_status=0,out_zigzagidx=0, out_dir=0;
    bool ret_isChg_mesen=false;
    //int paraCn_zigzagidx_ev;
    //ENUM_TIMEFRAMES paraCn_period_;

    if(c_h!=NULL && c_l!=NULL&&c_hh!=NULL){
     //チェックtpsl
     tpls_chk(v,t);
        bool r=false;
        int offset = 0;
        r = get_ZigY_array_org(ay,peri,offset);
        if(r==false){printf("not get ay");return;}
        r = get_ZigX_array_org(at,peri,offset);
        if(r==false){printf("not get at");return;}

    
    //エントリー時	type 2
      double dd54=MathAbs(ay[5]-ay[4]);
      double dd43=MathAbs(ay[4]-ay[3]);
      double dd32=MathAbs(ay[3]-ay[2]);
      double dd21=MathAbs(ay[2]-ay[1]);
      int bb42=(int)MathAbs((at[4]-at[2]));;
      int bb41=(int)MathAbs((at[4]-at[1]));;

      bool cond=false;
      cond =((dd54 >dd43)&&(dd54 >dd32)&&(dd54 >dd21)) &&
          ((ay[5] >ay[4])&&(ay[5] >ay[3])&&(ay[5] >ay[2])&&(ay[5] >ay[1])) &&
          ((ay[2] <ay[5])&&(ay[2] <ay[4])&&(ay[2] <ay[3])&&(ay[2] <ay[1])) &&
          ((ay[1] >ay[3])&&(dd32*1.1 <dd21)) ;


      double para_entryline=Inp_para_double1;//0-N
      double para_tp_ritu=Inp_para_double2;//
      double para_sl_ritu=Inp_para_double3;
      double para_ct_ritu=Inp_para_double4;
      if(cond==true){
          struct_tpsl d;
//          double entryline=ay[4]+dd43*0.1;
          double entryline=ay[4]+dd43*para_entryline;    //★★
//          double entryline=ay[4]+dd43*1;
          d.entry	=	entryline;
          d.dir	=	1;			//固定							
//          d.tp	=	dd21+ay[4];										
//          d.sl	=	ay[2]-dd32*0.2;
          d.tp	=	dd21*para_tp_ritu+ay[4];					//★★					
          d.sl	=	ay[2]-dd32*para_sl_ritu;
          
//          d.sl	=	ay[2]-dd32*0.5;		//debug								
          d.tp_pips	=	MathAbs(	chgPrice2Pips(d.tp-entryline));
          d.sl_pips	=	MathAbs(	chgPrice2Pips(d.sl-entryline));									
              double ttt=0.0;if(d.tp_pips!=0){ttt=d.sl_pips/d.tp_pips;}else{ttt=9999;}												
          d.tp_sl_hi	=	ttt;										
                                                              
          c_l.get_oshimodoshi_ritu(c_l.zigzagdata_count-1,entryline,d.Cn_oshimodori);													
          c_hh.get_oshimodoshi_ritu(c_hh.zigzagdata_count-1,entryline,d.joui_oshiodori);													

//          d.canceltime	=	at[1]+bb42*2;   // 4-2の幅以内
//          d.canceltime	=	at[1]+bb41*2;   // 4-1 *2の幅以内
          d.canceltime	=	(datetime)(at[1]+bb41*para_ct_ritu);   // 4-1 *2の幅以内  //★★
//d.canceltime	=0;
          d.entryzigidx = c_l.zigzagdata_count-1;
          //登録
          bool isreg=false;
          isreg= tpsl_set_data_entryline_canceltime(d);

          //view
          if(isreg==true){
            string name1="tp:zig="+IntegerToString(c_l.zigzagdata_count)+"tp/sl="+DoubleToString(d.tp_pips/d.sl_pips);
            string name2="entry:zig="+IntegerToString(c_l.zigzagdata_count)+"oshi="+DoubleToString(d.Cn_oshimodori);
            string name3="sl:zig="+IntegerToString(c_l.zigzagdata_count);
            int cc=GetTimeColor(peri);
              datetime bt=24*15*60;
              TrendCreate(0,name1,0,at[1],d.tp    ,d.canceltime,d.tp,cc,STYLE_SOLID,4);
              TrendCreate(0,name2,0,at[1],d.entry ,d.canceltime,d.entry,cc,STYLE_SOLID,4);          
              TrendCreate(0,name3,0,at[1],d.sl    ,d.canceltime,d.sl,cc,STYLE_SOLID,4);   
              cc=cc;      
          } 

      }
    }
  }
#endif //USE_trade_07


////////////////////////////////////////////////    
////////////////////////////////////////////////    
////////////////////////////////////////////////    
////////////////////////////////////////////////
//#define USE_trede_06
#ifdef USE_trede_06
    //#include "Trade_06_core.mqh"
//Trade_06_core.mqh

//void chk_trade_forTick(double v,double t,allcandle *pallcandle,bool isTrade){
#ifdef commmment
［STEP１］上位目線の切り替わり後、下位の時間軸でLCnがいったん逆に行ってから、戻ったときにエントリー
    H4、H1、M15

［STEP２-1］
上位目線の切り替わり時に、押し戻しを確認して（下位足で逆方向に行ってから、ローカル目線切り替わり（切り上げ確認））エントリー
［STEP２-2］上（［STEP２-1］）＋
できれば１５０ー１００％
できればだましとなる
上位足の押し戻り位置が100-60％で発生したとき
上位足の押し戻り位置が100-80％で発生したとき
上位足の押し戻り位置が60-20％で発生したとき
上位足の押し戻り位置が20-0％で発生したとき


上位目線の切り替わり時　or　　上位足続伸時に、押し戻しを確認して（下位足の切り上げ確認）エントリー

押し戻し
    上位足の切り上げの辺を基準に、そこから下位足でいったん逆方向に行ってから、元の方向へ戻るところでエントリー
    H4、H1
    H4,M15
    H1、M15
［STEP１］
［STEP２］
［STEP３］
［STEP４］
#endif // commmmment

int TradeStep;
TradeStep=1;

bool isnew_bar = false;
double tp;
double sl;
int e_dir;

b_ok_entry=false;

//新規バーのチェック
//isnew_bar=isNewBar(_Symbol, peri);
isnew_bar=flagchgbarM15;
if(isnew_bar == true){



    //最上位足の目線切り替わり？
    ENUM_TIMEFRAMES peri_hh=PERIOD_H4;
    //上位足の目線切り替わり？
    ENUM_TIMEFRAMES peri_h=PERIOD_H1;
    //ENUM_TIMEFRAMES 
    peri=PERIOD_M15;


    candle_data *c_hh=pac.get_candle_data_pointer(peri_hh);
    candle_data *c_h=pac.get_candle_data_pointer(peri_h);
    candle_data *c_l=pac.get_candle_data_pointer(peri);
    int out_status=0,out_zigzagidx=0, out_dir=0;
    bool ret_isChg_mesen=false;
    int paraCn_zigzagidx_ev;
    ENUM_TIMEFRAMES paraCn_period_;
	double paraCn_sv;double paraCn_ev;datetime paraCn_st;datetime paraCn_et;int paraCn_dir;

    if(c_h!=NULL && c_l!=NULL&&c_hh!=NULL){
        //チェックtpsl
        tpls_chk(v,t);


        //----mesenn変わったか？
        //下位足でLCnの条件が成立したか？（上位の逆に行っていたのが、上位方向となった時
        //デバッグとして、成立したらマーキングすることで、あとで戦略考えるときに使えるはず。
        //    目線切り変わりとなったLCn
        int gigzagidx_l;
        bool ret_isChg_LCn_mesen=false;
        ret_isChg_LCn_mesen=c_l.isChg_LCn_mesen(gigzagidx_l);
        if(ret_isChg_LCn_mesen==true){
            string name1;             // object name
            int    nwin=0;             // window index
            datetime tt;           // position of price label by time
            double pp=0.0;            // position of price label by vertical
            color  Color=clrAqua;            // text color
//            uint    Size;             // font size

            pp=c_l.zigzagdata[gigzagidx_l].value;
            tt=c_l.zigzagdata[gigzagidx_l].time;
            double d_oshimodori_ritu=oshimodori_ritu(c_l.Cn_sv,c_l.Cn_ev,pp,c_l.Cn_dir);//Cn　end　が０の押し戻り率（１が１００％）
            int percent=(int)(d_oshimodori_ritu*100);//１００％表記
            name1="LCnchg"+ IntegerToString(c_l.zigzagdata[gigzagidx_l].kind)+":"
                +"zigidx="+IntegerToString(gigzagidx_l)+":"
                +"os="+IntegerToString(percent)+":"
                +"t="+TimeToString(tt)+":"
                +"p="+DoubleToString(pp,5);
            CreateArrowRightPrice(0,name1,nwin,tt,pp,Color,3);
#ifdef USE_debug_Cn_Lcn
            printf(__FUNCTION__+":目線切り変わりとなったLCn:zigc="+IntegerToString(c_l.zigzagdata_count)+
              " LCnstatus="+IntegerToString(c_l.LCn_status)+
              " LCn_e_zigzagidx="+IntegerToString(c_l.LCn_e_zigzagidx)+
              " LCn_mesen_chg_count="+IntegerToString(c_l.LCn_mesen_chg_count)+
              " Cn_ev"+DoubleToString(c_l.Cn_ev)+
              "");
#endif //USE_debug_Cn_Lcn            
            //エントリー処理
            //ｔｐはＮの100％
            //ＳＬはＣｎのｓを超えたら終了
            //    or　c_lのLCnのｓを超えたら終了
            //フィルタ
                //上位が続伸の形　続伸継続を狙う

            b_ok_entry=true;
            //sl=
            //tp=

            
            
        }

        //上位目線で目線が変わったor新しく続伸した→　Cn　LCnのために登録
        ret_isChg_mesen=c_h.isChg_mesen(out_status,out_zigzagidx, out_dir);
		//目線がきりかわった、変化があった　true.　　　目線の切り替わりなしは　false
		// Status  目線切り替わり１、続伸２
        if(ret_isChg_mesen==true){
            paraCn_zigzagidx_ev=c_h.zigzagdata_count-1;
            if(paraCn_zigzagidx_ev != out_zigzagidx){
                printf("error zigzag ret_isChg_mesen"+"  Cn_zigzagidx_ev="+IntegerToString(paraCn_zigzagidx_ev)+"out_zigzagidx="+IntegerToString(out_zigzagidx));
                
            }
#ifdef USE_debug_Cn_Lcn
            printf(__FUNCTION__+":Status  上位目線切り替わりあり・続伸あり（通知）→LCn:zigc="+IntegerToString(c_l.zigzagdata_count)+
              "LCnstatus="+IntegerToString(c_l.LCn_status)+
              "LCn_e_zigzagidx="+IntegerToString(c_l.LCn_e_zigzagidx)+
              "LCn_mesen_chg_count="+IntegerToString(c_l.LCn_mesen_chg_count)+
              " Cn_ev"+DoubleToString(c_l.Cn_ev)+
              "");
#endif //USE_debug_Cn_Lcn            

            paraCn_period_=peri_h;
            paraCn_ev=c_h.ZigY(1);
            paraCn_et=c_h.Zigtime(1);
            paraCn_dir=(int)c_h.ZigUD(1);

            paraCn_sv=c_h.ZigY(2);
            paraCn_st=c_h.Zigtime(2);
            
            string name1;             // object name
            int    nwin=0;             // window index
            datetime tt;           // position of price label by time
            double pp=0.0;            // position of price label by vertical
            color  Color=clrGreenYellow;            // text color
            //HYOUJI Cn
            pp =  paraCn_ev;
            tt =  paraCn_et;
            name1 = "Cn_e"+IntegerToString(c_h.zigzagdata_count-1) +"tt="+TimeToString(tt)+" pp="+DoubleToString(pp);
            CreateArrowRightPrice(0,name1,nwin,tt,pp,Color,3);
            pp =  paraCn_sv;
            tt =  paraCn_st;
            Color=clrHotPink;            // text color
            name1 = "Cn_s"+IntegerToString(c_h.zigzagdata_count-1-1) +"tt="+TimeToString(tt)+" pp="+DoubleToString(pp);
            CreateArrowRightPrice(0,name1,nwin,tt,pp,Color,3);
            //下位足へCn通知する
            c_l.set_LCn_set_Cn_data(paraCn_zigzagidx_ev, paraCn_period_,
			                  paraCn_sv, paraCn_ev, paraCn_st, paraCn_et, paraCn_dir);
        }
//#ifdef aaaaaaaaa        
        //Cn値更新下化の確認
        if( c_l.Cn_zigzagidx_ev >= c_h.zigzagdata_count){
            printf(__FUNCTION__+"Cn zigzagidx out of range--->restart time["+ TimeToString(t)
               +"] 現状は途中の処理をリセットするLCnは破棄　次のCn発見するまで処理を飛ばす");
            
            
            // Cn,LCnを初期化
            c_l.resetLCn();
            c_h.resetCn();
            return;
        }
//#endif//aaaaaaaaa        
        if(c_l.Cn_ev!=c_h.zigzagdata[c_l.Cn_zigzagidx_ev].value //値が異なるか？
            && c_l.Cn_zigzagidx_ev == c_h.zigzagdata_count-1)   //最後のZigzagとおなじか？
            {
#ifdef USE_debug_Cn_Lcn
            printf(__FUNCTION__+":Status  Cn値更新あり（下位へ再通知） LCn:zigc="+IntegerToString(c_l.zigzagdata_count)+
              "LCnstatus="+IntegerToString(c_l.LCn_status)+
              "LCn_e_zigzagidx="+IntegerToString(c_l.LCn_e_zigzagidx)+
              "LCn_mesen_chg_count="+IntegerToString(c_l.LCn_mesen_chg_count)+
              " Cn_ev"+DoubleToString(c_l.Cn_ev)+
              "");
              printf(" c_l.Cn_ev="+DoubleToString(c_l.Cn_ev));
              printf(" ZigdataHi="+DoubleToString(c_h.zigzagdata[c_l.Cn_zigzagidx_ev].value));
#endif //USE_debug_Cn_Lcn
            //c_l.LCn_status
            //ev値変化があれば再登録
            //下位足へCn通知する
            paraCn_period_=peri_h;
            paraCn_ev=c_h.ZigY(1);
            paraCn_et=c_h.Zigtime(1);
            paraCn_dir=(int)c_h.ZigUD(1);

            paraCn_sv=c_h.ZigY(2);
            paraCn_st=c_h.Zigtime(2);
            paraCn_zigzagidx_ev= c_l.Cn_zigzagidx_ev;           
            if(c_h.zigzagdata_count>2){

               string name1;             // object name
               int    nwin=0;             // window index
               datetime tt;           // position of price label by time
               double pp=0.0;            // position of price label by vertical
               color  Color=clrGreenYellow;            // text color
               //HYOUJI Cn
               pp =  paraCn_ev;
               tt =  paraCn_et;
               name1 = "Cn_e"+IntegerToString(c_h.zigzagdata_count-1) +"tt="+TimeToString(tt)+" pp="+DoubleToString(pp);
               CreateArrowRightPrice(0,name1,nwin,tt,pp,Color,1);
               //pp =  paraCn_sv;
               //tt =  paraCn_st;
               //name1 = "Cn_s"+IntegerToString(c_h.zigzagdata_count-1-1) +"tt="+TimeToString(tt)+" pp="+DoubleToString(pp);
               //CreateArrowRightPrice(0,name1,nwin,tt,pp,Color,3);
               //下位足へCn通知する
               c_l.set_LCn_set_Cn_data(paraCn_zigzagidx_ev, paraCn_period_,
   			                  paraCn_sv, paraCn_ev, paraCn_st, paraCn_et, paraCn_dir);
            }
        }

            double entryprice;
            double tpprice;
            double slprice;
            bool b_exit_all; 
            flag_is_entry=false;//tp slなので、つねにエントリー
            if(b_ok_entry == true && flag_is_entry == false){
                //SetSendData_forEntry_sokuji(e_dir,0,0,0.0,0.0,0.0,0.1);
#ifdef USE_debug_Cn_Lcn
            double tmpt=v-c_l.Cn_ev;
            if (tmpt!=0.0){tmpt=(v-c_l.Cn_sv)/(v-c_l.Cn_ev);}else{tmpt=-99999;}
            printf(__FUNCTION__+":エントリー LCn:zigc="+IntegerToString(c_l.zigzagdata_count)+
              "LCnstatus="+IntegerToString(c_l.LCn_status)+
              "LCn_e_zigzagidx="+IntegerToString(c_l.LCn_e_zigzagidx)+
              "LCn_mesen_chg_count="+IntegerToString(c_l.LCn_mesen_chg_count)+
              " Cn_ev"+DoubleToString(c_l.Cn_ev)+
              "sl/tp"+DoubleToString(MathAbs( tmpt )));
#endif //USE_debug_Cn_Lcn

                tpprice=c_l.Cn_ev;
                slprice=c_l.Cn_sv;
                entryprice=v;
                e_dir=c_l.Cn_dir;
                SetSendData_forEntry_tpsl_direct_ctrl(
                  e_dir,1,1,
                  entryprice,//double EntryPrice,
                  tpprice,//double Tp_Price,
                  slprice,//double Sl_Price,
                  0.1); //lots){
                  printf("SetSendData_forEntry_tpsl_direct_ctrl"+":dir="+IntegerToString(e_dir)+":entryp="+DoubleToString(entryprice,5)+":tp="+DoubleToString(tpprice,5)+":sl="+DoubleToString(slprice));

//                flag_is_entry=true;
                flag_is_entry=false;//tp sl なので、毎回下す
                b_ok_entry=false;
                uint total=PositionsTotal();
                if(total >1){
                    printf("エントリー後"+IntegerToString(total)+"以上　あるのはおかしい");
                }

#ifdef USE_tpsl_view_ctr
                struct_tpsl d;													
                d.entry	=	v;										
                d.dir	=	c_l.Cn_dir;										
                d.tp	=	c_l.Cn_ev;										
                d.sl	=	c_l.Cn_sv;										
                d.tp_pips	=	MathAbs(	chgPrice2Pips(d.tp-v));
                d.sl_pips	=	MathAbs(	chgPrice2Pips(d.sl-v));
                  double ttt=0.0;if(d.tp_pips!=0){ttt=d.sl_pips/d.tp_pips;}else{ttt=9999;}												
                d.tp_sl_hi	=	ttt;										

                c_h.get_oshimodoshi_ritu(c_l.Cn_zigzagidx_ev,v,d.Cn_oshimodori);													
                c_hh.get_oshimodoshi_ritu(c_hh.zigzagdata_count-1,v,d.joui_oshiodori);
                //テスト期間内のものを登録
                if(b_during_test_piriod==true){
                   tpsl_set_data(d);
                }
#endif// USE_tpsl_view_ctr
                


            }else
            if(b_exit_all == true && flag_is_entry == true){
                SetSendData_forExitAll();
                flag_is_entry = false;
                uint total=PositionsTotal();
                if(total >0){
                    printf("削除後"+IntegerToString(total)+"以上　あるのはおかしい");
                }
            }
            


    }
}    //end if(isnew_bar
#endif// USE_trede_06
////////////////////////////////////////////////    
////////////////////////////////////////////////    
////////////////////////////////////////////////    
////////////////////////////////////////////////    
    
    
    
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
//	double bid;
//	double ask;
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

//Trade xx   Trade_xx_core (Tick処理の記述)
//Trade_xx_func_def (ライブラリ定義、データ定義、初期値の設定関数定義)
#include "Trade_06_func_def.mqh"
void init_Trace(void){
  init_Trade_06_func_def();
  init_ChartScreenShot();
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
#ifdef USE_VIEW_printf_katachiNo
        printf("katachi★=\t"+IntegerToString(pt_katachi)+"\t"+TimeToString(at[1]));
#endif// USE_VIEW_printf_katachiNo
        
        if(pt_katachi == PT_RANGE_LAST_LOW ||
            pt_katachi == PT_RANGE_LAST_TOP
        ){
            string name="range"+IntegerToString(zigcount)+PeriodToString(period_);
            RectangleCreate(0,name,0,at[1],ay[1],at[4],ay[4]);
            
        }
        if(pt_katachi == PT_MESEN_DN ||
            pt_katachi == PT_MESEN_UP
        ){
            string name="mesen"+IntegerToString(zigcount)+PeriodToString(period_);
            //RectangleCreate(0,name,0,0,time1,price1,time2,price2,,,,)
            int cc=GetTimeColor(period_);
            TrendCreate(0,name,0,at[1],ay[1],at[2],ay[2],cc,STYLE_SOLID,4);
//            TrendCreate(0,name,0,at[1],ay[1],at[2],ay[2],clrMagenta,STYLE_SOLID,4);
        }
        if(pt_katachi == PT_ZOKUSIN_UP ||
            pt_katachi == PT_ZOKUSIN_DN
        ){
            string name1="zokushin_up"+IntegerToString(zigcount)+PeriodToString(period_);
            string name2="zokushin_dn"+IntegerToString(zigcount)+PeriodToString(period_);
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
              string name1=IntegerToString(pt_katachi)+":heikou"+IntegerToString(zigcount)+PeriodToString(period_);
              string name2=IntegerToString(pt_katachi)+":heikou_"+IntegerToString(+zigcount)+PeriodToString(period_);
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
            // 7<5                                5<3        6<4
        ){
          bool yowai=false;
          // ２が４まで到達していない（戻りが弱くなった証拠あるか？）
          if(ay[baseidx-6]<ay[baseidx-4]){// 2 < 4
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


//-------view
#ifdef dell_already_defined
void CreateArrowRightPrice //CreateArrowRightPrice(0,"",0,Time,Price,Color,3)
(
  long   chart_id,         // chart ID
  string name1,             // object name
  int    nwin,             // window index
  datetime Time,           // position of price label by time
  double Price,            // position of price label by vertical
  color  Color,            // text color
  uint    Size             // font size
){
    //string new_name = 
    //   ObjectCreate(chart_id,name,OBJ_ARROW_RIGHT_PRICE,nwin,Time,Price);
      ObjectCreate(chart_id,name1,OBJ_ARROW_RIGHT_PRICE,nwin,Time,Price);
      ObjectSetInteger(chart_id,name1,OBJPROP_COLOR,Color);
      ObjectSetInteger(chart_id,name1,OBJPROP_WIDTH,Size);
    //ObjectSetInteger(chart_id,name,OBJPROP_BACK,true);
    //----
}
#endif //dell_already_defined
double oshimodori_ritu(double s,double e,double v,double dir){
//---------LIB 押し戻りの比率
	#ifdef commenttt
		ある指定した辺（s,e(右)）、評価価格渡すと		
			s-eが上向きのとき(e上でsが下の時)	
					-XX%					150%
				  e	0%			s			100%
					50%						50%
				s	100%				e   0%
					150%					-XX%
	#endif //commenttt
    if(dir == 0 || s==e){ 
      printf("error oshimodori_ritu");
      return 999999;//error
     }
    double dd_se=MathAbs(s-e);
    double dd_ev=MathAbs(v-e);
    double ret=999999;
    double tmp=(dd_ev/dd_se)*(-1);
    if(e > v){
      ret = tmp*dir;
    }else{
      ret = tmp*dir*(-1);
    }
  return ret;
}


int ChartScreenShot_pos;
void init_ChartScreenShot(void){ChartScreenShot_pos=0;}
void get_ChartScreenShot(string addname){
#ifdef chartevent_denaito_dekinairasii_testingMode_dato_dekinai
#ifdef commmenttt
bool  ChartScreenShot(
  long            chart_id,                  // チャート識別子
  string          filename,                  // 銘柄名
  int              width,                      // 幅
  int              height,                    // 高さ
  ENUM_ALIGN_MODE  align_mode=ALIGN_RIGHT      // 整列の種類
  );

#define        WIDTH  800     // ChartScreenShot() を呼ぶ画像幅
#define        HEIGHT 600     // ChartScreenShot() を呼ぶ画像の縦幅
#endif //commentttt
#define        WIDTH  800     // ChartScreenShot() を呼ぶ画像幅
#define        HEIGHT 600     // ChartScreenShot() を呼ぶ画像の縦幅

string name="ChartScreenShot"+string(ChartScreenShot_pos)+":"+addname+".gif";
//--- terminal_directory\MQL5\Files\ にチャートのスクリーンショットファイルを保存する
          if(ChartScreenShot(0,name,WIDTH,HEIGHT,ALIGN_LEFT))
              Print("We've saved the screenshot ",name);
          //---
#endif //chartevent_denaito_dekinairasii_testingMode_dato_dekinai
}

void view_fibo_expansion(int zigno,candle_data &c){
//zigno 最後（最新）が１とする。
   datetime t1,t2,t3;
   double v1,v2,v3;
   int offset = zigno-1;
   if(c.zigzagdata_count<4){return;}
   v3=c.ZigY(1+offset);
   v2=c.ZigY(2+offset);
   v1=c.ZigY(3+offset);
   t3=c.Zigtime(1+offset);
   t2=c.Zigtime(2+offset);
   t1=c.Zigtime(3+offset);
   string name="expa:"+PeriodToString(c.period)+":zigidx="+  IntegerToString(c.zigzagdata_count-1);
   
//   ObjectCreate(chart_ID,name,OBJ_EXPANSION,sub_window,time1,price1,time2,price2,time3,price3) 
   if(!ObjectCreate(0,name,OBJ_EXPANSION,0,t1,v1,t2,v2,t3,v3)){
      ObjectMove(0,name,0,t1,v1);
      ObjectMove(0,name,1,t2,v2);
      ObjectMove(0,name,2,t3,v3);
   }else{
      //--- オブジェクトの色を設定 
      color clr=(color)c.GetTimeColor(c.period);
      //clr=clrRed;
      ObjectSetInteger(0,name,OBJPROP_COLOR,clr); 
      ObjectSetInteger(0,name,OBJPROP_LEVELCOLOR,clr); 
      
      ENUM_LINE_STYLE style=STYLE_DASHDOTDOT; // 線のスタイル 
      int             width=2;               // 線の幅 
      bool           back=false;             // 背景オブジェクト 
      bool           selection=true;         // 強調表示して移動 
      bool           ray_left=false;         // オブジェクトの左への継続 
      bool           ray_right=false;         // オブジェクトの右への継続 
      bool           hidden=true;           // オブジェクトリストに隠す 
      long           z_order=0;               // マウスクリックの優先順位       
      //--- 線のスタイルを設定する 
        ObjectSetInteger(0,name,OBJPROP_STYLE,style); 
      //--- 線の幅を設定する 
        ObjectSetInteger(0,name,OBJPROP_WIDTH,width); 
      //--- 前景（false）または背景（true）に表示 
        ObjectSetInteger(0,name,OBJPROP_BACK,back); 
      //--- 強調表示してチャンネルを移動するモードを有効（true）か無効（false）にする。 
      //--- ObjectCreate 関数を使用してグラフィックオブジェクトを作成する際、オブジェクトは 
      //--- デフォルトではハイライトされたり動かされたり出来ない。このメソッド内では、選択パラメータは 
      //--- デフォルトでは true でハイライトと移動を可能にする。 
        ObjectSetInteger(0,name,OBJPROP_SELECTABLE,selection); 
         ObjectSetInteger(0,name,OBJPROP_SELECTED,selection); 
      //--- オブジェクトの表示を左に延長するモードを有効（true）か無効（false）にする 
        ObjectSetInteger(0,name,OBJPROP_RAY_LEFT,ray_left); 
      //--- オブジェクトの表示を右に延長するモードを有効（true）か無効（false）にする 
        ObjectSetInteger(0,name,OBJPROP_RAY_RIGHT,ray_right); 
      //--- オブジェクトリストのグラフィックオブジェクトを非表示（true）か表示（false）にする 
        ObjectSetInteger(0,name,OBJPROP_HIDDEN,hidden); 
      //--- チャートのマウスクリックのイベントを受信するための優先順位を設定する 
        ObjectSetInteger(0,name,OBJPROP_ZORDER,z_order);       
   }
}

void view_fibo(int zigno,candle_data &c){
//zigno 最後（最新）が１とする。
   datetime t1,t2,t3;
   double v1,v2,v3;
   int offset = zigno-1;
   if(c.zigzagdata_count<4){return;}
   v3=c.ZigY(1+offset);
   v2=c.ZigY(2+offset);
   v1=c.ZigY(3+offset);
   t3=c.Zigtime(1+offset);
   t2=c.Zigtime(2+offset);
   t1=c.Zigtime(3+offset);
   string name="fibo:"+PeriodToString(c.period)+":zigidx="+  IntegerToString(c.zigzagdata_count-1);
   
//   ObjectCreate(chart_ID,name,OBJ_EXPANSION,sub_window,time1,price1,time2,price2,time3,price3) 
   if(!ObjectCreate(0,name,OBJ_FIBO,0,t1,v1,t2,v2)){
      ObjectMove(0,name,0,t1,v1);
      ObjectMove(0,name,1,t2,v2);
   }else{
      //--- オブジェクトの色を設定 
      color clr=(color)c.GetTimeColor(c.period);
      //clr=clrRed;
      ObjectSetInteger(0,name,OBJPROP_COLOR,clr); 
      ObjectSetInteger(0,name,OBJPROP_LEVELCOLOR,clr); 
      
      ENUM_LINE_STYLE style=STYLE_DASHDOTDOT; // 線のスタイル 
      int             width=2;               // 線の幅 
      bool           back=false;             // 背景オブジェクト 
      bool           selection=true;         // 強調表示して移動 
      bool           ray_left=false;         // オブジェクトの左への継続 
      bool           ray_right=false;         // オブジェクトの右への継続 
      bool           hidden=true;           // オブジェクトリストに隠す 
      long           z_order=0;               // マウスクリックの優先順位       
      //--- 線のスタイルを設定する 
        ObjectSetInteger(0,name,OBJPROP_STYLE,style); 
      //--- 線の幅を設定する 
        ObjectSetInteger(0,name,OBJPROP_WIDTH,width); 
      //--- 前景（false）または背景（true）に表示 
        ObjectSetInteger(0,name,OBJPROP_BACK,back); 
      //--- 強調表示してチャンネルを移動するモードを有効（true）か無効（false）にする。 
      //--- ObjectCreate 関数を使用してグラフィックオブジェクトを作成する際、オブジェクトは 
      //--- デフォルトではハイライトされたり動かされたり出来ない。このメソッド内では、選択パラメータは 
      //--- デフォルトでは true でハイライトと移動を可能にする。 
        ObjectSetInteger(0,name,OBJPROP_SELECTABLE,selection); 
         ObjectSetInteger(0,name,OBJPROP_SELECTED,selection); 
      //--- オブジェクトの表示を左に延長するモードを有効（true）か無効（false）にする 
        ObjectSetInteger(0,name,OBJPROP_RAY_LEFT,ray_left); 
      //--- オブジェクトの表示を右に延長するモードを有効（true）か無効（false）にする 
        ObjectSetInteger(0,name,OBJPROP_RAY_RIGHT,ray_right); 
      //--- オブジェクトリストのグラフィックオブジェクトを非表示（true）か表示（false）にする 
        ObjectSetInteger(0,name,OBJPROP_HIDDEN,hidden); 
      //--- チャートのマウスクリックのイベントを受信するための優先順位を設定する 
        ObjectSetInteger(0,name,OBJPROP_ZORDER,z_order);       
   }
}
