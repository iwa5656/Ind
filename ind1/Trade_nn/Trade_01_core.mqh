    peri = PERIOD_M5;
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
                    bool rr;
                    r=c.get_mesen_Cn(0,c0);//抜けたCn
                    rr=c.get_mesen_Cn(1,c1);//その前のCn
                    if(r==false || rr ==false){printf("error mesen entry");return;}

                    double dd_c1;
                    dd_c1 = MathAbs(c1.up-c1.dn);
                    double entryprice;
                    double tpprice;
                    double slprice;
                    #ifdef dellll
                    //double nobiritu=1.0;
                    //double songiriritu = 1.15;
                    #endif // dellll
                    //抜けた目線辺をd12とする（未確定含む）：EntryPoint
                    //ｔｐはｄ１２のnobiritu、ｓｌはｄ１２の損切率
                    if(dir==1){
                      entryprice = v;
                      tpprice = v+d12*nobiritu;
                      slprice = v-d12*songiriritu;
                    }else{
                      entryprice = v;
                      tpprice = v-d12*nobiritu;
                      slprice = v+d12*songiriritu;
                    }
                    if(isTrade == true){
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

                }      

            }
    }
