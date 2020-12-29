//Trade_05_core.mqh

//void chk_trade_forTick(double v,double t,allcandle *pallcandle,bool isTrade){




#ifdef commmment
［STEP１］上位足のトレンド方向のみをトレード対象にする
［STEP２］ダウ理論で上位足のトレード方向の目線を固定する
［STEP３］基準足のバンドウォークを採用する
［STEP４］バンドウォークがサポート・レジスタンスをブレイクしているか確認する
#endif // commmmment
//Step1,2
//上位足の目線を確認
//上か下か判断 h_dir
//境界となる価格　h_v
ENUM_TIMEFRAMES peri_h=PERIOD_H1;
//ENUM_TIMEFRAMES 
peri=PERIOD_M15;
bool isnew_bar = false;
//新規バーのチェック
isnew_bar=isNewBar(_Symbol, peri);
if(isnew_bar == true){
   int h_dir =0;
   double h_v = 0.0;
   bool b_step1 = false;
   
   candle_data *c_h=pac.get_candle_data_pointer(peri_h);
   struct_mesen_C c0;
   bool r_h=false;	
   if(c_h!=NULL){
       r_h=c_h.get_mesen_Cn(0,c0);
       if(r_h == true){
           h_dir = c0.dir;
           h_v= c0.dir==1?c0.up:c0.dn;
           if(c0.dir !=0){
               b_step1=true;
           }
       }
   }
   
   
   //Step3
   double b_2sig_up=0.0;
   double b_2sig_dn=0.0;
   double ema=0.0;
   double mid_sma20 = 0.0;
   double sig=0.0;
   bool b_step3 = false;
   candle_data *c=pac.get_candle_data_pointer(peri);
   //EMA
   if(c!=NULL){
       mid_sma20=c.MAprice(20,MODE_SMA,0);
       c.sigma(20,0,mid_sma20,sig);
       ema=c.MAprice(10,MODE_EMA,0);
       if(mid_sma20!=0.0 && sig !=0.0 && ema!=0.0){
           b_2sig_up=mid_sma20+sig*2;
           b_2sig_dn=mid_sma20-sig*2;
           b_step3 =true;
       }
   
   }
   
   //Step4
   
   //    double ay[MAX_GET_ZIGZAGDATA_NUM+1];// 価格Zigzag　１からデータ入っている。０は使わない
   //    int aud[MAX_GET_ZIGZAGDATA_NUM+1];
   //    datetime at[MAX_GET_ZIGZAGDATA_NUM+1];
       //candle_data *c=pac.get_candle_data_pointer(peri);
       bool b_step4=false;//data取得
       bool b_step4_1=false;//レジサポを超えている
   
       if(c!=NULL){
           bool r=false;
           bool s=true;
           r = get_ZigY_array_org(ay,peri,c.zigzagdata_count-c.zigzagdata_count);
           if(r==false){s=false;}
           r = get_ZigX_array_org(at,peri,c.zigzagdata_count-c.zigzagdata_count);
           if(r==false){s=false;}
           r = get_ZigUD_array_org(aud,peri,c.zigzagdata_count-c.zigzagdata_count);
           if(r==false){s=false;}
           b_step4=s;
       }
       double tyokkinn_yama=0.0;
       bool b_bandwalk = false;
       bool b_ok_entry = false;
       bool b_exit_all = false;
       if(    b_step1==true &&    b_step3==true &&    b_step4==true ){
           if(h_dir == 1){
               //直近の上の山の値
               if(aud[1]==1){
                   tyokkinn_yama = ay[1];
               }else{
                   tyokkinn_yama = ay[2];
               }
               //さらに上にいるか？
               if(tyokkinn_yama< v){
                   b_step4_1=true;
               }
           }else{
               //直近の下の山の値
               if(aud[1]==-1){
                   tyokkinn_yama = ay[1];
               }else{
                   tyokkinn_yama = ay[2];
               }
               //さらに下にいるか？
               if(tyokkinn_yama> v){
                   b_step4_1=true;
               }
   
           }
           //バンドウォーク中？
           if(h_dir ==1){
               if(v>ema && v< b_2sig_up){
                   b_bandwalk = true;
               }
           }else{
               if(v<ema && v> b_2sig_dn){
                   b_bandwalk = true;
               }
           }
   
           //エントリー可能か？
           if(b_step4_1==true && b_bandwalk == true){// レジサポ超えているか？
               //エントリー
               b_ok_entry = true;
           }
   
           if(b_bandwalk==false ){
               // Exit 処理
               b_exit_all =true;
           }
   
   
           if(b_ok_entry == true&& flag_is_entry == false){
           //#define debugggg
           #ifdef debugggg
               h_dir = h_dir*(-1);//debug)
           #endif//debugggg    
               SetSendData_forEntry_sokuji(h_dir,0,0,0.0,0.0,0.0,0.1);
               flag_is_entry=true;
               uint total=PositionsTotal();
               if(total >1){
                   printf("エントリー後"+IntegerToString(total)+"以上　あるのはおかしい");
               }
           }
           if(b_exit_all == true && flag_is_entry == true){
               SetSendData_forExitAll();
               flag_is_entry = false;
               uint total=PositionsTotal();
               if(total >0){
                   printf("削除後"+IntegerToString(total)+"以上　あるのはおかしい");
               }
           }
   
   #ifdef commmment        
   エントリー中のフラグを持っておく、フラグが立っているときのみExit処したい。
   エントリー中に再エントリーしないようにする。
   
   Exit処理を入れる。（コマンドで支持する形にする）
   #endif//commmmment
       }

}//isnew_bar == true
