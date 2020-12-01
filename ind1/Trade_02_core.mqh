    peri = PERIOD_M5;
    ret= chk_pt_mesen(peri,ret_match_zigcount,ret_pt_katachi);
    if(ret == true){//目線変化あり？
        //pt成立
            //既存？//新規？
            bool r=false;bool rr=false;
            r=Is_pt_zigcount_katachi(ret_pt_katachi,ret_match_zigcount);
            if(r==false){//初めて
                //Pt表示（レクタングル＋名前（時間＋パターン名）
                view_pt(peri,ret_match_zigcount,ret_pt_katachi);
                //★データの格納・記憶
                    //pt追加
                reg_pt(peri,ret_match_zigcount,ret_pt_katachi);

                //entry 
                int dir=0;
                if(ret_pt_katachi==PT_MESEN_UP){
                  dir = 1;
                }
                if(ret_pt_katachi==PT_MESEN_DN){
                  dir = -1;
                }
                candle_data *c=pac.get_candle_data_pointer(peri);
                int zigcount;
                if(c!=NULL){

                    bool r=false;
                    bool s=false;
                    zigcount = c.zigzagdata_count;
                    r = get_ZigY_array_org(ay,peri,c.zigzagdata_count-zigcount);
                    if(r==false){return ;}
                    r = get_ZigX_array_org(at,peri,c.zigzagdata_count-zigcount);
                    if(r==false){return ;}
                    r = get_ZigUD_array_org(aud,peri,c.zigzagdata_count-zigcount);
                    if(r==false){return ;}

                    double d12=MathAbs(ay[1]-ay[2]);
                    struct_mesen_C c0;
                    struct_mesen_C c1;
                    struct_mesen_C c2;
                    
                    bool rr;bool rrr;
                    r=c.get_mesen_Cn_kirikawariCn(0,c0);//抜けたCn
                    rr=c.get_mesen_Cn_kirikawariCn(1,c1);//その前のCn
                    rrr=c.get_mesen_Cn_kirikawariCn(2,c2);//その前のその前のCn
                    if(r==false || rr ==false || rrr==false){printf("error mesen entry");return;}

                    double dd_c1;
                    dd_c1 = MathAbs(c1.up-c1.dn);
                    double dd_c0_c1,dd_c2_c1,dd_c2_c0;
                    double v0,v1,v2;
                    v0 = c0.dir==1?c0.up:c0.dn;
                    v1 = c1.dir==1?c1.up:c1.dn;
                    v2 = c2.dir==1?c2.up:c2.dn;
                    dd_c0_c1 = MathAbs(v0-v1);
                    dd_c2_c1 = MathAbs(v2-v1);
                    dd_c2_c0 = MathAbs(v2-v0);

                    bool isVji= (c0.no == c1.no+1);// V字回復しているか
                    //エントリー比率がOKか？
                    bool isOk_tp_per_sl_hiritu=false;
                    double tp_per_sl=dd_c2_c0/dd_c0_c1;// 伸び幅/損切幅
                    
                    if(tp_per_sl>Inp_tp_per_sl_hiritu){// 1倍以上など
                        isOk_tp_per_sl_hiritu = true;
                    }
                    
                    //長期の情報を取得する
                    //長期のMAの情報を取得
                    //Tbd
                    int dir_tyoukiMA;
                    
                    //エントリーの判断
                    bool isEntry=false;
                    double entryprice;
                    double tpprice;
                    double slprice;
                                        
                    if(isVji==true && isOk_tp_per_sl_hiritu == true){
//                    if(isVji==true ){
                        isEntry = true;
                        //エントリーデータの作成


                        //抜けた目線辺をd12とする（未確定含む）：EntryPoint
                        //ｔｐはｄ１２のnobiritu、ｓｌはｄ１２の損切率
                        if(dir==1){
                        entryprice = v;
                        tpprice = v+dd_c2_c0*nobiritu;
                        slprice = v-dd_c0_c1*songiriritu;
                        }else{
                        entryprice = v;
                        tpprice = v-dd_c2_c0*nobiritu;
                        slprice = v+dd_c0_c1*songiriritu;
                        }
                    }

                    //エントリー処理
                    if(isTrade == true && isEntry == true){
                        SetSendData_forEntry_tpsl_direct_ctrl(
                        dir,PT_MESEN_UP,PT_MESEN_UP,
                        entryprice,//double EntryPrice,
                        tpprice,//double Tp_Price,
                        slprice,//double Sl_Price,
                        0.1); //lots){
                        printf("SetSendData_forEntry_tpsl_direct_ctrl"+":dir="+IntegerToString(dir)+":entryp="+DoubleToString(entryprice,5)+":tp="+DoubleToString(tpprice,5)+":sl="+DoubleToString(slprice));
                    }else{
                        //ｐｔの確認のみでトレードしない
                    }
                    
                }//end //エントリーの判断      

            }
    }
