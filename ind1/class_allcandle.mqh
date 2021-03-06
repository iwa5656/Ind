#ifndef class_allcandle
#define class_allcandle

#include "class_candle_data.mqh"
//#include "classMethod.mqh"
	ENUM_TIMEFRAMES period_hairetu[]={PERIOD_M1,PERIOD_M5,PERIOD_M15,PERIOD_M30,PERIOD_H1,PERIOD_H4,PERIOD_D1,PERIOD_W1,PERIOD_MN1};
    extern datetime pre_timeM1;
class allcandle
{
public:
	candle_data *m_data[10];
	int m_num;
	bool flagchgbarM1;
	bool flagchgbarM5;
	bool flagchgbarM15;
	bool flagchgbarM30;
	bool flagchgbarH1;
	bool flagchgbarH4;
	bool flagchgbarD1;
	bool flagchgbarW1;
	bool flagchgbarMN1;
	//MethodPattern *m_hyouka;// ★★ 複数のMethodPatternを持てるようにして、平行にしょりするには
	//--- コンストラクタとデストラクタ
	allcandle(void){
    	ENUM_TIMEFRAMES current_time_frame = Period();
		m_num=0;
		int max = ArraySize(period_hairetu);
		for(int i=0;i<max;i++){
			//m_data[i] = new candle_data(period_hairetu[i],GetPointer(this));
			if(current_time_frame <=period_hairetu[i]){
			    m_data[i] = new candle_data(period_hairetu[i]);
			}else{
			    m_data[i] = NULL;
			}
		}
		//m_hyouka = new MethodPattern("Wtop",m_data[0].period,m_data[0]);
	        //MethodPattern(string s,ENUM_TIMEFRAMES p,candle_data *c){name = s;period = p;candle = c; hyouka_data_num=0;};


	};
	~allcandle(void){};
	//--- オブジェクトを初期化する

    //データ
    void addcandle(ENUM_TIMEFRAMES period,candle_data *d);//<-使わない　コンストラクタ時に全部作成しておく
    candle_data *get_candle_data_pointer(ENUM_TIMEFRAMES period);
    int get_datanum(void){return m_num;};
    bool add_new_bar(ENUM_TIMEFRAMES period,datetime t);
    int Oncalculate_ZIGZAG(ENUM_TIMEFRAMES period);
    int Oncalculate_Fractals(ENUM_TIMEFRAMES period);
    void clean_up_arrays_zigzag(ENUM_TIMEFRAMES period);
    bool get_zigzagdata(
    	ENUM_TIMEFRAMES &period,
    	int &idx,
    	double &v,
    	datetime &t,
    	int &k,
    	int &count
    );
    void calc_new_bar_flag(datetime &t1,datetime &t2);
    void rest_new_bar_flag(void);
    bool get_new_bar_flag(ENUM_TIMEFRAMES p);
    bool set_new_bar_flag(ENUM_TIMEFRAMES p,bool f);
    void hyouka(ENUM_TIMEFRAMES p);
    void Oninit(void);
    void OnDeinit(const int reason);
    void calc_kakutei(ENUM_TIMEFRAMES period);
	bool    Is_pattern_range(ENUM_TIMEFRAMES period);
	bool Is_exist_pt_range(ENUM_TIMEFRAMES period,int idx);// aru true,nashi false
    int get_pt_range(ENUM_TIMEFRAMES period,struct_pt_range &pt);

	bool    Is_pattern_flag(ENUM_TIMEFRAMES period);
	bool Is_exist_pt_flag(ENUM_TIMEFRAMES period,int idx);// aru true,nashi false
    int get_pt_flag(ENUM_TIMEFRAMES period,struct_pt_flag &pt);    
};
void allcandle::OnDeinit(const int reason){
		int max = ArraySize(period_hairetu);
		for(int i=0;i<max;i++){
			//m_data[i] = new candle_data(period_hairetu[i],GetPointer(this));
			if(m_data[i]!=NULL){
    			m_data[i].OnDeinit(reason);
    	    }
		}
}

void allcandle::Oninit(void){
		int max = ArraySize(period_hairetu);
		for(int i=0;i<max;i++){
			//m_data[i] = new candle_data(period_hairetu[i],GetPointer(this));
			if(m_data[i]!=NULL){
			    m_data[i].Oninit();
			}
		}
}
void allcandle::addcandle(ENUM_TIMEFRAMES p,candle_data *d){
	
	switch(p)
	{
		case PERIOD_M1:
			m_data[0]=d;m_num++;
			break;
		case PERIOD_M5:
			m_data[1]=d;m_num++;
			break;
		case PERIOD_M15:
			m_data[2]=d;m_num++;
			break;
		case PERIOD_M30:
			m_data[3]=d;m_num++;
			break;
		case PERIOD_H1:
			m_data[4]=d;m_num++;
			break;
		case PERIOD_H4:
			m_data[5]=d;m_num++;
			break;
		case PERIOD_D1:
			m_data[6]=d;m_num++;
			break;
		case PERIOD_W1:
			m_data[6]=d;m_num++;
			break;
		case PERIOD_MN1:
			m_data[7]=d;m_num++;
			break;
		default:
			break;
		
	}
}
candle_data *allcandle::get_candle_data_pointer(ENUM_TIMEFRAMES period){
	candle_data *c=NULL;
	switch(period)
	{
		case PERIOD_M1:
			c=m_data[0];
			break;
		case PERIOD_M5:
			c=m_data[1];
			break;
		case PERIOD_M15:
			c=m_data[2];
			break;
		case PERIOD_M30:
			c=m_data[3];
			break;
		case PERIOD_H1:
			c=m_data[4];
			break;
		case PERIOD_H4:
			c=m_data[5];
			break;
		case PERIOD_D1:
			c=m_data[6];
			break;
		case PERIOD_W1:
			c=m_data[6];
			break;
		case PERIOD_MN1:
			c=m_data[7];
			break;
		default:
			break;
		
	}
	return c;
}	

bool allcandle::add_new_bar(ENUM_TIMEFRAMES period,datetime t){
	candle_data *c=get_candle_data_pointer(period);
	if(c!=NULL){
		return(c.add_new_bar(t));
	}else{return false;}
}
int allcandle::Oncalculate_ZIGZAG(ENUM_TIMEFRAMES period){
	candle_data *c=get_candle_data_pointer(period);
	if(c!=NULL){
		return(c.Oncalculate_ZIGZAG());
	}else{return false;}
}
int allcandle::Oncalculate_Fractals(ENUM_TIMEFRAMES period){
	candle_data *c=get_candle_data_pointer(period);
	if(c!=NULL){
		return(c.Oncalculate_Fractals());
	}else{return false;}
}
void allcandle::clean_up_arrays_zigzag(ENUM_TIMEFRAMES period){
	candle_data *c=get_candle_data_pointer(period);
	if(c!=NULL){
		c.clean_up_arrays_zigzag();
	}else{return ;}
}
bool allcandle::get_zigzagdata(
    	ENUM_TIMEFRAMES &period,
    	int &idx,
    	double &v,
    	datetime &t,
    	int &k,
    	int &count
){
	candle_data *c=get_candle_data_pointer(period);
	if(c!=NULL){
		return(c.get_zigzagdata(
    	    period,
    	    idx,
    	    v,
    	    t,
    	    k,
    	    count
		));
	}else{return false;}

}

void allcandle::calc_new_bar_flag(datetime &pre_time,datetime &t){
	rest_new_bar_flag();// リセット
//ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
//新規足有無の確認
//ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
    MqlDateTime pre_dt_struct;
    MqlDateTime dt_struct;
    flagchgbarM1=false;flagchgbarM5=false;flagchgbarM15=false;flagchgbarM30=false;flagchgbarH1=false;flagchgbarH4=false;flagchgbarD1=false;flagchgbarW1=false;flagchgbarMN1=false;
    TimeToStruct(t,dt_struct);
    TimeToStruct(pre_timeM1,pre_dt_struct);
	if(pre_timeM1 !=t){
	    flagchgbarM1=true;
	    this.set_new_bar_flag(PERIOD_M1,true);
	}
    
    if(((int)pre_dt_struct.min/5) != ((int)dt_struct.min/5)){
    	//M5
    	flagchgbarM5=true;
	    set_new_bar_flag(PERIOD_M5,true);
    	if(((int)pre_dt_struct.min/15) != ((int)dt_struct.min/15)){
    		//M15
    		flagchgbarM15=true;
		    set_new_bar_flag(PERIOD_M15,true);
    		if(((int)pre_dt_struct.min/30) != ((int)dt_struct.min/30)){
    			//M30
    			flagchgbarM30=true;
    			set_new_bar_flag(PERIOD_M30,true);

    		}
    	}
    }
    if(pre_dt_struct.hour != dt_struct.hour){
    	//1h 以上変化
    			flagchgbarH1=true;	    
    			set_new_bar_flag(PERIOD_H1,true);

    
    	if( ((int)pre_dt_struct.hour/4) != ((int)dt_struct.hour/4)){
    	// 4h 以上変化
    		//0,4,8,12,16,20,24,0,
    		//0123,4567,891011,12131415,16171819,20212223,0123
    	//waru4 0    1   2       3        4        5       0	
    				flagchgbarH4=true;	    
    				set_new_bar_flag(PERIOD_H4,true);

    	}
    
    }
    if(pre_dt_struct.day!=	dt_struct.day){
    	//1Day 以上変化
    			flagchgbarD1=true;	    
    			set_new_bar_flag(PERIOD_D1,true);

    			
    }
    if(pre_dt_struct.mon != dt_struct.mon){
    	//1月 以上変化
    			flagchgbarMN1=true;	    
    			set_new_bar_flag(PERIOD_MN1,true);

    }
    if(pre_dt_struct.day_of_week != dt_struct.day_of_week){
    	//1W 以上変化
    			flagchgbarW1=true;
			    set_new_bar_flag(PERIOD_W1,true);

    }
    return;    
}
void allcandle::rest_new_bar_flag(void){
	flagchgbarM1=false;
	flagchgbarM5=false;
	flagchgbarM15=false;
	flagchgbarM30=false;
	flagchgbarH1=false;
	flagchgbarH4=false;
	flagchgbarD1=false;
	flagchgbarW1=false;
	flagchgbarMN1=false;
		int max = ArraySize(period_hairetu);
		for(int i=0;i<max;i++){
		    if(m_data[i]!=NULL){
			    m_data[i].set_new_bar_flag(false);
			}
		}	
}
bool allcandle::get_new_bar_flag(ENUM_TIMEFRAMES period){
	candle_data *c=get_candle_data_pointer(period);
	if(c!=NULL){
		return(c.get_new_bar_flag());
	}else{return false;}
}
bool allcandle::set_new_bar_flag(ENUM_TIMEFRAMES period,bool f){
	candle_data *c=get_candle_data_pointer(period);
	if(c!=NULL){
		return(c.set_new_bar_flag(f));
	}else{return false;}
}
void allcandle::calc_kakutei(ENUM_TIMEFRAMES period){
	candle_data *c=get_candle_data_pointer(period);
	if(c!=NULL){
		c.calc_kakutei();
	}else{
	    ;
	}
}

void allcandle::hyouka(ENUM_TIMEFRAMES p){
    //m_hyouka.hyouka();
    printf("error 引っ越し");
	//candle_data *c=get_candle_data_pointer(p);
	//if(c!=NULL){
///		c.hyouka();
//	}else{ ;}
}


bool allcandle::Is_pattern_range(ENUM_TIMEFRAMES period){
	candle_data *c=get_candle_data_pointer(period);
	if(c!=NULL){
		return(c.Is_pattern_range());
	}else{return false;}
}
int allcandle::get_pt_range(ENUM_TIMEFRAMES period,struct_pt_range &pt){
	candle_data *c=get_candle_data_pointer(period);
	if(c!=NULL){
		return(c.get_pt_range(pt));
	}else{return 0;}
}
//bool allcandle::Is_exist_pt_range(ENUM_TIMEFRAMES period,int f){
//	candle_data *c=get_candle_data_pointer(period);
//	if(c!=NULL){
//		return(c.Is_exist_pt_range(f));
	//}else{return false;}
//}




bool allcandle::Is_pattern_flag(ENUM_TIMEFRAMES period){
	candle_data *c=get_candle_data_pointer(period);
	if(c!=NULL){
		return(c.Is_pattern_flag());
	}else{return false;}
}
int allcandle::get_pt_flag(ENUM_TIMEFRAMES period,struct_pt_flag &pt){
	candle_data *c=get_candle_data_pointer(period);
	if(c!=NULL){
		return(c.get_pt_flag(pt));
	}else{return 0;}
}
#endif//class_allcandle