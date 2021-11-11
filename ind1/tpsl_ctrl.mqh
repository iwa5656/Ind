
#define USE_tpsl_view_ctr //tpslの結果＋エントリー情報を出力したい

#ifdef USE_tpsl_view_ctr
#define  NUM_YOBI_TPSL_MEM 1000

//------opt-------
#define USE_view_tpsl_cancel  //tp sl cancel view
//#define USE_printf_SetSendData_forEntry_tpsl_direct //エントリーのPrintf

#ifdef commentttt
エントリー時の情報保持と、エントリーの結果を保持																		
上記を出力する																		
																		
	エントリーの管理																	
		エントリー価格																
		エントリーTP、SL																
		付属情報																
			Cnの押し戻り率															
			上位の目線															
			さらに上位の押し戻り率															
																		
																		
	チェックはベースのBarが確定時に超えたかを評価する																	
		結果を格納																
			勝ち負け															
			結果Pips															
			TP、SLの比率															
																		
	I/F	初期化				init_tpsl(void)												
		エントリーの登録・そのほか情報登録				tpsl_set_data(struct_tpsl &d)												
		状態の監視・データ更新				tpls_chk(double v)												
		全体出力				tpls_outall(void)												
#endif//commentttt																		
	//データ																	
		//構造体	
        struct struct_tpsl{
			double	entry;              //登録時    //エントリー価格ｏｒエントリーレベル（価格）
			int	dir;                    //登録時							
			double	tp;             	//登録時							
			double	sl;             	//登録時							
			double	tp_pips;            //登録時							
			double	sl_pips;            //登録時							
			double	tp_sl_hi;           //sl/tp （tp1でslは？）				登録時							
			double	Cn_oshimodori;      //Cn押し戻り率（Cn_evが０％）		登録時							
			double	joui_oshiodori;     //上位の押し戻り率(eが０％）		  登録時							
			int	winloss;                //勝ち負け(w1,l-1)                  監視時							
			double	kekka_pips;         //結果Pips				                監視時							
			int	status;             	//entry_type=0
                                                //1登録後監視中、２，結果決定				ALL							
                                        //entry_type=1
                                                //1登録後監視中(ｔｐｓｌチェック中)、３エントリー待ち中　　２，結果決定				ALL
            int entry_type;             //登録時    //0:entry,tpsl,   1:entrylevel,tpsl,cancel time
            datetime canceltime;             //登録時    //エントリー待ち中がｃｔまでかかる場合はエントリを無効とする。
            int entryzigidx;//登録時


        };
        //out
        void tpsl_outall(void){
            double losspips=0.0;double winpips=0.0;
            int loss_count=0;int win_count=0;
            for(int i=0;i<tpsl_count;i++){
                if(tpsldata[i].status==2){
                    if(tpsldata[i].winloss==1){
                        win_count++;
                        winpips=winpips+tpsldata[i].kekka_pips;

                    }else if(tpsldata[i].winloss==-1){
                        loss_count++;
                        losspips=losspips+tpsldata[i].kekka_pips;
                    }
                }
            }
            double syouritu=99999;
            if(loss_count!=0){syouritu=(double)win_count/(double)(win_count+loss_count);};
            double kitaichi = -99999;
            if(loss_count!=0&&win_count!=0){
               kitaichi=winpips/win_count*syouritu-losspips/loss_count*(1-syouritu)*(-1);
            }
            double pf;
            if(losspips!=0){pf=winpips/losspips;}else{pf=9999999;}
            printf("total:="+DoubleToString(winpips+losspips,2));
            printf("  期待値：="+DoubleToString(  kitaichi  ));
            printf("  PF値　：="+DoubleToString(  pf  ));
            if(losspips!=0){            printf("  タープの期待値：負けトレード１通貨あたりの期待値="+DoubleToString(kitaichi/(losspips*(-1)))); }else{printf("");}
            printf("  勝率：="+DoubleToString(  syouritu  ));
            printf("  商い数：="+IntegerToString(  win_count+loss_count  ));
            printf("  勝ち数：="+IntegerToString(  win_count  ));
            printf("  負け数：="+IntegerToString(  loss_count  ));
            //
            printf("out put all data tpsldata");
            ArrayPrint(tpsldata);
        }
		//状態の監視・データ更新																
			void	tpls_chk(double v,datetime tt){
					int i;													
					i=tpsl_first_srh_idx;													
					bool find_first_ctrstatus=false;
					bool bview;													
					for(i=tpsl_first_srh_idx;i<tpsl_count;i++){													
						if(tpsldata[i].status==1){	//tpsl chk  利確損切判定											
						   bview=false;
							if( find_first_ctrstatus == false){											
								find_first_ctrstatus=true;										
								tpsl_first_srh_idx=i;										
							}
                            if(tpsldata[i].entry_type==0||tpsldata[i].entry_type==1){
                                //超えたか？											
                                if(    (    tpsldata[i].dir ==1&&tpsldata[i].tp<v) ||											
                                    (tpsldata[i].dir ==-1&&tpsldata[i].tp>v)										
                                ){											
                                    tpsldata[i].winloss=1;										
                                    tpsldata[i].kekka_pips=chgPrice2Pips(MathAbs(v-tpsldata[i].entry));										
                                    tpsldata[i].status=2;//クローズ状態
                                    bview=true;
                                }											
                                                                            
                                if(    (    tpsldata[i].dir ==1&&tpsldata[i].sl>v) ||											
                                    (tpsldata[i].dir ==-1&&tpsldata[i].sl<v)										
                                ){											
                                    tpsldata[i].winloss=-1;										
                                    tpsldata[i].kekka_pips=chgPrice2Pips(MathAbs(v-tpsldata[i].entry))*(-1);										
                                    tpsldata[i].status=2;//クローズ状態										
                                    bview=true;
                                }
                                if(bview==true){
                                    #ifdef USE_view_tpsl_cancel
												string outputname="";
            									if(tpsldata[i].winloss==1){
													outputname="勝:tshi="+ DoubleToString(tpsldata[i].tp_sl_hi)+"  winpips="+DoubleToString(tpsldata[i].tp_pips);
            										printf(outputname);
													
            									}
            									if(tpsldata[i].winloss==-1){
													outputname = "負:tshi="+ DoubleToString(tpsldata[i].tp_sl_hi)+"  winpips="+DoubleToString(tpsldata[i].sl_pips);
            										printf(outputname);
            									}
            									string addname = IntegerToString(i);
            									view_kachi_make_cancel(tpsldata[i].winloss,tt,v,addname,tpsldata[i].kekka_pips);
												get_ChartScreenShot(outputname);
                                    #endif//USE_view_tpsl_cancel                                
                                }
                            }//end if(tpsldata[i].entry_type==0){	
                       
						}//end status==1
                        else if(tpsldata[i].status==3){//３エントリー待ち中
                            if(
                                (tpsldata[i].dir ==1 &&tpsldata[i].entry>v) ||
                                (tpsldata[i].dir ==-1&&tpsldata[i].entry<v)
                            ){
                                tpsldata[i].status=1;//tpslのチェック監視へ
                                //エントリー処理
                                double tpprice=tpsldata[i].tp;
                                double slprice=tpsldata[i].sl;
                                double entryprice=v;
                                int e_dir=tpsldata[i].dir;
                                SetSendData_forEntry_tpsl_direct_ctrl(
                                e_dir,1,1,
                                entryprice,//double EntryPrice,
                                tpprice,//double Tp_Price,
                                slprice,//double Sl_Price,
                                0.1); //lots){
#ifdef USE_printf_SetSendData_forEntry_tpsl_direct									
                                printf("SetSendData_forEntry_tpsl_direct_ctrl"+":dir="+IntegerToString(e_dir)+":entryp="+DoubleToString(entryprice,5)+":tp="+DoubleToString(tpprice,5)+":sl="+DoubleToString(slprice)+":tp_sl_hi="+DoubleToString(tpsldata[i].tp_sl_hi,3) );
#endif //USE_printf_SetSendData_forEntry_tpsl_direct

                            }
                            if(tpsldata[i].canceltime < tt && tpsldata[i].canceltime !=0){
                                tpsldata[i].status=0;//時間がかかっているので、エントリーをキャンセル
                                
                                 #ifdef USE_view_tpsl_cancel
                                printf("キャンセル");
         								string addname = IntegerToString(i);
         								view_kachi_make_cancel(0,tt,v,addname,0);
         								#endif//USE_view_tpsl_cancel
                            }
                                                                    //entry_type=1
                                                //1登録後監視中(ｔｐｓｌチェック中)、３エントリー待ち中　　２，結果決定				ALL

                        }

					}//end　for													
            }															
																		
			void	tpsl_set_data(struct_tpsl &d)			{
					int i=tpsl_count;
			      tpsl_count++;
  					chk_mem_tpsl(i+1);
					tpsldata[i].		status	=	1;						
					tpsldata[i].		entry	=	d.entry;						
					tpsldata[i].		dir	=	d.dir;						
					tpsldata[i].		tp	=	d.tp;						
					tpsldata[i].		sl	=	d.sl;						
					tpsldata[i].		tp_pips	=	d.tp_pips;						
					tpsldata[i].		sl_pips	=	d.sl_pips;						
					tpsldata[i].		tp_sl_hi	=	d.tp_sl_hi;						
					tpsldata[i].		Cn_oshimodori	=	d.Cn_oshimodori;						
					tpsldata[i].		joui_oshiodori	=	d.joui_oshiodori;						

					tpsldata[i].		entry_type	=	0;		//add				

			}														
			bool	tpsl_set_data_entryline_canceltime(struct_tpsl &d)			{
			//登録　　　成功true    失敗（同じものを登録済み）
			      bool ret = false;
			      bool bsame=is_tpsl_same_entry(d.entryzigidx);
			      if(bsame!=true){
   					int i=tpsl_count;
   			      tpsl_count++;
     					chk_mem_tpsl(i+1);
   					tpsldata[i].		status	=	3;						
   					tpsldata[i].		entry	=	d.entry;						
   					tpsldata[i].		dir	=	d.dir;						
   					tpsldata[i].		tp	=	d.tp;						
   					tpsldata[i].		sl	=	d.sl;						
   					tpsldata[i].		tp_pips	=	d.tp_pips;						
   					tpsldata[i].		sl_pips	=	d.sl_pips;						
   					tpsldata[i].		tp_sl_hi	=	d.tp_sl_hi;						
   					tpsldata[i].		Cn_oshimodori	=	d.Cn_oshimodori;						
   					tpsldata[i].		joui_oshiodori	=	d.joui_oshiodori;						
   																		
   					tpsldata[i].		entry_type	=	1;		//add				
   					tpsldata[i].		canceltime	=	d.canceltime;		//add
   					tpsldata[i].		entryzigidx	=	d.entryzigidx;		//add
   					ret = true;
               }
               return ret;
            }
			bool is_tpsl_same_entry(int id){//すでに同じZigzagidｘのものが登録されているか　　true登録されている
			   bool ret = false;
			   
			   for(int i=tpsl_count-1;i>=0;i--){
			      if(tpsldata[i].entryzigidx==id){
			         ret =true;
			         break;
			      }
			      if(tpsldata[i].entryzigidx <id){
			         ret = false;
			         break;
			      }
			   }
			   return ret;
			}															
																		
																		
																		
			void chk_mem_tpsl(int i){															
				int m=tpsl_count;														
				if(tpsl_count < i){														
					m=i+1;													
				}														
				ArrayResize(tpsldata,i,NUM_YOBI_TPSL_MEM);														
			}															
			void init_tpsl(void){															
				chk_mem_tpsl(1);														
				tpsl_count=0;														
				tpsl_first_srh_idx=0;														
			}															
																		
																		
																		
																		
		//データ定義																
			struct_tpsl tpsldata[];															
			int	tpsl_count;														
			int	tpsl_first_srh_idx;														
																		
																		
#ifdef commentttt																		
		実際の呼び出し																
				エントリー時	type 1													
																		
					struct_tpls d;													
					d.entry	=	v;										
					d.dir	=	c_l.Cn_dir;										
					d.tp	=	c_l.Cn_ev;										
					d.sl	=	c_l.Cn_sv;										
					d.tp_pips	=	MathAbs(	chgPrice2Pips(tp-v))									
					d.sl_pips	=	MathAbs(	chgPrice2Pips(sl-v))									
						double ttt=0.0;if(tp_pips!=0){ttt=sl_pips/tp_pips;}else{ttt=9999;}												
					d.tp_sl_hi	=	ttt;										
																		
					c_l.get_oshimodoshi_ritu(c_l.Cn_zigzagidx_ev,v,d.Cn_oshimodori);													
						d.joui_oshiodori	=											
					c_hh.get_oshimodoshi_ritu(c_hh.zigzagdata_count-1,v,d.joui_oshiodori);													
																		
				エントリー時	type 2
                    double dd54=MathAbs(ay[5]-ay[4]);
                    double dd43=MathAbs(ay[4]-ay[3]);
                    double dd32=MathAbs(ay[3]-ay[2]);
                    double dd21=MathAbs(ay[2]-ay[1]);
                    int bb42=MathAbs((at[4]-ay[2]));;

                    bool cond=false;
                    cond =((dd54 >dd43)&&(dd54 >dd32)&&(dd54 >dd21)) &&
                        ((ay[5] >ay[4])&&(ay[5] >ay[3])&&(ay[5] >ay[2])&&(ay[5] >ay[1])) &&
                        ((ay[2] <ay[5])&&(ay[2] <ay[4])&&(ay[2] <ay[3])&&(ay[2] <ay[1])) &&
                        
                        ((ay[1] >ay[3])&&(dd32*1.1 <dd21) ;


                    if(cond==true){
                        struct_tpsl d;
                        double entryline=ay[4]-dd34*1.1;
                        d.entry	=	entryline;
                        d.dir	=	1;			//固定							
                        d.tp	=	dd21+ay[4];										
                        d.sl	=	ay[2]-dd32*0.1;										
                        d.tp_pips	=	MathAbs(	chgPrice2Pips(tp-v))									
                        d.sl_pips	=	MathAbs(	chgPrice2Pips(sl-v))									
                            double ttt=0.0;if(tp_pips!=0){ttt=sl_pips/tp_pips;}else{ttt=9999;}												
                        d.tp_sl_hi	=	ttt;										
                                                                            
                        c_l.get_oshimodoshi_ritu(c_l.gigzagdata_count-1,entryline,d.Cn_oshimodori);													
                        c_hh.get_oshimodoshi_ritu(c_hh.zigzagdata_count-1,entryline,d.joui_oshiodori);													

                        d.canceltime	=	at[1]+bb42;   // 4-2の幅以内

                        tpsl_set_data_entryline_canceltime(d);
                    }
																		
																		
				Ondeinit
                    tpls_outall(void)
#endif//commentttt


#endif// USE_tpsl_view_ctr
