
//下記から呼び出し
//chk_trade_forTick(double v,double t,allcandle *pallcandle,bool isTrade){
int dir;
double a;
double b;
double c_;
double now_v;
datetime now_time;
datetime next_kakutei_time;


if(flagchgbarM5==true){
    peri = PERIOD_M5;
    candle_data *c=pac.get_candle_data_pointer(peri);
    bool ret_chk=false;
    if(c!=NULL){
        ret_chk = c.chk_DD(5,dir,a,b,c_,now_v,now_time,next_kakutei_time);
        if(ret_chk == true){
            ret_chk = false;
        }
    }



}

