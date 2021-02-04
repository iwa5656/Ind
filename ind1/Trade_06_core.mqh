    //#include "Trade_06_core.mqh"
//Trade_06_core.mqh

//void chk_trade_forTick(double v,double t,allcandle *pallcandle,bool isTrade){
#ifdef commmment
［STEP１］上位目線の切り替わり後、上位の時間軸でLCnがいったん逆に行ってから、戻ったときにエントリー
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
//新規バーのチェック
isnew_bar=isNewBar(_Symbol, peri);
if(isnew_bar == true){



    //上位足の目線切り替わり？
    ENUM_TIMEFRAMES peri_h=PERIOD_H1;
    //ENUM_TIMEFRAMES 
    peri=PERIOD_M15;


    candle_data *c_h=pac.get_candle_data_pointer(peri_h);
    candle_data *c_l=pac.get_candle_data_pointer(peri);
    int out_status=0,out_zigzagidx=0, out_dir=0;
    bool ret_isChg_mesen=false;
    int paraCn_zigzagidx_ev;
    ENUM_TIMEFRAMES paraCn_period_;
	double paraCn_sv;double paraCn_ev;datetime paraCn_st;datetime paraCn_et;int paraCn_dir;

    if(c_h!=NULL && c_l!=NULL){
    
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
            
            //エントリー処理
            //ｔｐはＮの100％
            //ＳＬはＣｎのｓを超えたら終了
            //    or　c_lのLCnのｓを超えたら終了
            //フィルタ
                //上位が続伸の形　続伸継続を狙う
            double tp;
            double sl;
            int e_dir;
            b_ok_entry
            if(b_ok_entry == true&& flag_is_entry == false){
                SetSendData_forEntry_sokuji(e_dir,0,0,0.0,0.0,0.0,0.1);
                flag_is_entry=true;
                uint total=PositionsTotal();
                if(total >1){
                    printf("エントリー後"+IntegerToString(total)+"以上　あるのはおかしい");
                }
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

        //上位目線で目線が変わったor新しく続伸した→　Cn　LCnのために登録
        ret_isChg_mesen=c_h.isChg_mesen(out_status,out_zigzagidx, out_dir);
		//目線がきりかわった、変化があった　true.　　　目線の切り替わりなしは　false
		// Status  目線切り替わり１、続伸２
        if(ret_isChg_mesen==true){
            paraCn_zigzagidx_ev=c_h.zigzagdata_count-1;
            if(paraCn_zigzagidx_ev != out_zigzagidx){
                printf("error zigzag ret_isChg_mesen"+"  Cn_zigzagidx_ev="+IntegerToString(paraCn_zigzagidx_ev)+"out_zigzagidx="+IntegerToString(out_zigzagidx));
                
            }
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
        //Cn値更新下化の確認
        if(c_l.Cn_ev!=c_l.zigzagdata[c_l.Cn_zigzagidx_ev].value //値が異なるか？
            && c_l.Cn_zigzagidx_ev == c_h.zigzagdata_count-1)   //最後のZigzagとおなじか？
            {
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
            c_l.set_LCn_set_Cn_data(paraCn_zigzagidx_ev, paraCn_period_,
			                  paraCn_sv, paraCn_ev, paraCn_st, paraCn_et, paraCn_dir);

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
}    //end if(isnew_bar
