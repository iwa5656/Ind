#ifndef classMApf
#define classMApf
class MApf
{
public:
    // 
    #define NUM_OF_BUFFER_MA 300
    double ma[NUM_OF_BUFFER_MA];			//	配列のデータ
    int ma_count;			//	有効データ数
    int ma_period;			//	期間
    int ma_type;//0sma,1ema			//	タイプ
	//--- コンストラクタとデストラクタ
	MApf(void){};
	MApf(int n,int tm){ ma_period=n;ma_type=tm;}
		

	~MApf(void){};


void 	add_new_bar_calc(double &v[],int maxidx,int count){ // 確定足が入った配列、配列の最後の要素idx（最新データ）、データの数    追加データは　配列サイズ-1に入っている。
    //必要なデータがあるか？ないなら抜ける
    if(count<= ma_period){return;}//

    ////maタイプに従って計算
    double now_v = v[maxidx];//追加された値
    double tma=0.0;
    int i;
    //値の算出
    if(ma_type==0){//sma
			//単純　確定足
            for(i=maxidx;i>=maxidx+1-ma_period;i--){
                tma=tma+v[i];
            }
            tma=tma/(double)ma_period;
    }else if (ma_type == 1 ){//ema
            //すでに計算したデータがあるか
            if(ma_count>0){
                double pre_ema = ma[NUM_OF_BUFFER_MA-1];//一つ前のema
                tma = (pre_ema*((double)ma_period-1.0)+now_v*2.0  )/((double)ma_period+1.0);  //一つ前の計算結果に（N-1）をかけて、現在値を2倍して、加算したものを（N+1) 
            }else{
                //一つもないときは
                //smaと同じ
                for(i=maxidx;i>=maxidx+1-ma_period;i--){
                    tma=tma+v[i];
                }
                tma=tma/(double)ma_period;
            }
    }else{return;}
	//データ左つめで移動・一番右に計算したものを格納						
    for(i = 1 ;i<NUM_OF_BUFFER_MA;i++){
        ma[i-1]=ma[i];
    }
    ma[NUM_OF_BUFFER_MA-1]=tma;
    if(ma_count<NUM_OF_BUFFER_MA){ma_count++;}
}


void	Init_ma(void){//	初期化:配列、数を初期化
    for(int i = 0 ;i<NUM_OF_BUFFER_MA;i++){
        ma[i]=0.0;
    }
    ma_count = 0;
}					
bool	get_ma(int idx, double &out_data){//idx指定でmaを取得　　Input para:idx:最新0,1がその次に新しい。戻り値成功失敗。
    if(idx > ma_count-1){return false;}
    out_data = ma[idx];
    return true;
}							
	
bool	get_ma(double now_value,double &out_data //現在値渡して、現在のmaを計算	        Input para: 最新値、出力変数
    ,double &v[],int maxidx,int count       //確定足が入った配列、配列の最後の要素idx（最新データ）、データの数    追加データは　配列サイズ-1に入っている。
){
    bool ret =false;

    //必要なデータがあるか？ないなら抜ける
    if(count<= ma_period){return ret;}//

    ////maタイプに従って計算
    double now_v = now_value;//追加された値
    double tma=0.0;
    int i;

    //値の算出
    if(ma_type==0){//sma
        //単純　確定足
        for(i=maxidx;i>=maxidx+1-ma_period+1;i--){ //期間ー１分を過去データから取得し、加算
            tma=tma+v[i];
        }
        tma = tma + now_value;//最新のものも加算
        tma=tma/(double)ma_period;//平均
        ret = true;
    }else if (ma_type == 1 ){//ema
        //すでに計算したデータがあるか
        if(ma_count>0){
            double pre_ema = ma[NUM_OF_BUFFER_MA-1];//一つ前のema
            tma = (pre_ema*((double)ma_period-1.0)+now_v*2.0  )/((double)ma_period+1.0);  //一つ前の計算結果に（N-1）をかけて、現在値を2倍して、加算したものを（N+1) 
        }else{
            //一つもないときは
            //smaと同じ
            for(i=maxidx;i>=maxidx+1-ma_period+1;i--){ //期間ー１分を過去データから取得し、加算
                tma=tma+v[i];
            }
            tma = tma + now_value;//最新のものも加算
            tma=tma/(double)ma_period;//平均
        }
        ret = true;
    }else{return false;}

    return ret;
}			

};//end class

#endif// classMApf