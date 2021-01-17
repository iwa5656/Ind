//	double MAprice(int period,ENUM_MA_METHOD mode);//MODE_SMA,単純平均。,MODE_EMA,指数移動平均。,MODE_SMMA,平滑平均。,MODE_LWMA,線形加重移動平均。


// 0が一番古い　CANDLE_BUFFER_MAX_NUM－１が最新
//        int candle_bar_count;//zigzag_open close high
//        datetime time[CANDLE_BUFFER_MAX_NUM];// idx 0が古い想定
//        double open[CANDLE_BUFFER_MAX_NUM];// idx 0が古い想定
//        double close[CANDLE_BUFFER_MAX_NUM];// idx 0が古い想定
//        double high[CANDLE_BUFFER_MAX_NUM];// idx 0が古い想定
//        double low[CANDLE_BUFFER_MAX_NUM];// idx 0が古い想定
//MAprice(20,MODE_SMA);
double MAprice(int ma_period,ENUM_MA_METHOD mode){
    return(MAprice(ma_period,mode,0));
}

double MAprice(int ma_period,ENUM_MA_METHOD mode,int shift){
	double ma=0.0;
	int i;
	switch(mode){
		
		case MODE_SMA:
			//単純　確定足
			if(candle_bar_count-shift > ma_period+1){
				for(i=CANDLE_BUFFER_MAX_NUM-1-ma_period-shift+1;i<=CANDLE_BUFFER_MAX_NUM-1-shift;i++){
					ma=ma+close[i];
				}
				ma=ma/(double)ma_period;
			}
			break;
		case MODE_EMA:
			//1日目の計算　EMA（ｎ日）＝（ｃ1+ｃ2+ｃ3+ｃ4+ｃ5+……+ｃｎ）÷ｎ
			//2日目以降の計算　EMA（ｎ日）＝（前日のEMA）+α×（当日終値－前日のEMA）
			//　ｃｎ＝ｎ－１日目前の価格。ｃ１＝当日価格。
			//　α（平滑定数）＝2÷（ｎ+1)。0≦α≦1、ｎ＝平均する期間。
			//　期間をｎだと　N+1の過去でSMAを計算して、順番に計算していく
			if(candle_bar_count-shift > ma_period*2+1){
				// 一日目の計算
				ma=MAprice(ma_period,MODE_SMA,ma_period+1);
				// 2日目以降の計算　EMA（ｎ日）＝（前日のEMA）+α×（当日終値－前日のEMA）
				if(ma!=0.0){
					for(i=CANDLE_BUFFER_MAX_NUM-1-ma_period-shift+1;i<=CANDLE_BUFFER_MAX_NUM-1-shift;i++){
						ma=ma+(close[i]-ma)*2.0/((double)ma_period + 1);
					}
				}
			}

			break;
//		case :
//			break;
		
		
		default:
			break;
	}
	
	
	return(ma);
}

double MAkatamuki(int ma_period,ENUM_MA_METHOD mode){ // maの差　現在maー一つ前のma
    return(MAkatamuki(ma_period,mode,0));
}
double MAkatamuki(int ma_period,ENUM_MA_METHOD mode,int shift){ // maの差　現在maー一つ前のma
	double ma=0.0;
	int i;
	double ma2=0.0;
	int ma_pre_shift=1;//何個前のmaかを指定
	double katamuki=0.0;
	switch(mode){
		
		case MODE_SMA:
			//単純　確定足
			if(candle_bar_count-shift > ma_period+1){
				for(i=CANDLE_BUFFER_MAX_NUM-1-ma_period-shift;i<CANDLE_BUFFER_MAX_NUM-1-shift;i++){
					ma=ma+close[i];
				}
				ma=ma/(double)ma_period;
			}
			if(candle_bar_count-shift > ma_period+1+ma_pre_shift){
				for(i=CANDLE_BUFFER_MAX_NUM-1-ma_period-ma_pre_shift-shift;i<CANDLE_BUFFER_MAX_NUM-1-ma_pre_shift-shift;i++){
					ma2=ma2+close[i];
				}
				ma2=ma2/(double)ma_period;
			}
			katamuki=ma-ma2;
			break;
//		case :
//			break;
//		case :
//			break;
		
		
		default:
			break;
	}
	
	
	return(katamuki);
} 

double sigma(int ma_period,int shift,double &out_ma,double &sig){// 標準偏差σ　　入力は期間。　直近のキャンドルから期間
	double heikin = MAprice(period, MODE_SMA,shift);
	double t=0.0;
	double sum=0.0;
	
	if(candle_bar_count-shift > ma_period+1){
	    // sum  (x-xheikinn)^2
		for(int i=CANDLE_BUFFER_MAX_NUM-1-ma_period-shift;i<CANDLE_BUFFER_MAX_NUM-1-shift;i++){
			t=close[i]-heikin;
			t=t*t;
			sum+=t;
		}
		sum = MathSqrt(sum / (double)ma_period);
	}
	out_ma = heikin;
	sig = sum;	
    return sum;	
}
//double bolingerband(int period,double &b1,double &b2,double &b3)