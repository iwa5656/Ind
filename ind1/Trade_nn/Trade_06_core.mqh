#define aaaaaa33
#ifdef aaaaaa33
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
        tpls_chk(v);


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
#endif// aaaaaa33
