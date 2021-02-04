//#include "..\class_candle_data.mqh"
//#include "..\class_allcandle.mqh"
//#include "..\classMethod.mqh"

//各種パターン
//pt_sup
//データ
int pre_pt_sup_zig_count;
int pt_sup_find_count;
	//データ定義
    #define NUM_OF_pt_sup  2312640
//12*24*365*22 //60000	
#ifdef dellll
	struct struct_pt_sup{
		int pt_sup_status;//有効1、無効0
		int idx;//基準zigzag idx
		//フラッグ用
			double pt_sup_upper_value;
			double pt_sup_down_value;
			double pt_sup_distance_updown_value;
			double pt_sup_distance_updown_pips;
			int pt_sup_position_first;// 基準１の位置が上か下か？上のほう１：　下のほう-1
		//支える形用
			double		pt_sup_line_4_y;//4
			datetime	pt_sup_line_4_x;
			double		pt_sup_line_6_y;//6
			datetime	pt_sup_line_6_x;

			double		pt_sup_ma;
			double		pt_sup_ma_kiri_ritu;
			double		pt_sup_ma_katamuki;
			double		pt_sup_6_4_line_price;
			double		pt_sup_3_price;
			double		pt_sup_5_price;
			double		pt_sup_2_1_dist;
			double		pt_sup_2_1_dist_pips;
			int 		pt_sup_updn;//1up , -1dn

			//int pt_sup_position_first;// 基準１の位置が上か下か？上のほう１：　下のほう-1
		//add 20200531
		int pt_kind;//0:flag　1:支える形
	};
#endif // dellll
	struct_pt_sup pt_sup_data[NUM_OF_pt_sup];
	int pt_sup_data_count;
	struct_pt_sup pt_sup_data_now;
	
void init_pt_sup(){
    pt_sup_data_count = 0;
    pt_sup_data_now.pt_sup_status = 0;//無効
    pt_sup_find_count = 0;
}

void calc_pt_sup(){
    if(zigzagdata_count<7){
        return;// 数が足りてないのでもどず
    }
    int base_idx = zigzagdata_count-1;
	if(base_idx < 0){
		return;//error
	}

#ifdef commenttttt
________________________
									
						2			
									
									
		6		4				1:MAline
			
			5		3		
							
									
	7								
________________________
________________________
	7								
									
							
			5		3		
			
		6		4				1:MAline
									
									
						2			
________________________
#endif//commenttttt	

	double x1=ZigX(1);
	double x2=ZigX(2);
	double x3=ZigX(3);
	double x4=ZigX(4);
	double x5=ZigX(5);
	double x6=ZigX(6);
	double x7=ZigX(7);
	double y1=ZigY(1);
	double y2=ZigY(2);
	double y3=ZigY(3);
	double y4=ZigY(4);
	double y5=ZigY(5);
	double y6=ZigY(6);
	double y7=ZigY(7);

    double d12 = Dist_zigzag(chgKijun2Idx(base_idx,1),chgKijun2Idx(base_idx,2));
    double d23 = Dist_zigzag(chgKijun2Idx(base_idx,2),chgKijun2Idx(base_idx,3));
    double d34 = Dist_zigzag(chgKijun2Idx(base_idx,3),chgKijun2Idx(base_idx,4));
    double d45 = Dist_zigzag(chgKijun2Idx(base_idx,4),chgKijun2Idx(base_idx,5));
    double d56 = Dist_zigzag(chgKijun2Idx(base_idx,5),chgKijun2Idx(base_idx,6));
    double d67 = Dist_zigzag(chgKijun2Idx(base_idx,6),chgKijun2Idx(base_idx,7));
    double ddheikin=(d12+d23+d34+d45+d56+d67)/6;
    double gosahaba=ddheikin*0.20;
    double gosahaba_pips = chgPrice2Pips(gosahaba);
    

	
	bool condition;
	double gosa_pips = 20;//３点のずれの許容幅
	double gosa = chgPips2price(gosa_pips);
    bool bsameline641 = Is_3point_same_online( x6, y6, x4, y4, x1, y1,  gosa_pips);
	
	condition = 
		//y4==y6
			Is_2point_same_price(y6,y4,gosahaba_pips)
		//y1 == Line46
			&&true//&&bsameline641
		
		//(y7<y5  &&  y7<y3)
			&&(y7<y5  &&  y7<y3)
	;
	
	if(condition==true){
		//add_pt_sup();
	    int i=pt_sup_data_count;
	    base_idx = zigzagdata_count-1;
		if(base_idx < 0){
			return;//error
		}	
		//同一idの場合、登録済みなので登録しない
		if( IsExitstZigzagdata(base_idx) ){
		    return;
		}	
		candle_data *c = p_allcandle.get_candle_data_pointer(period);
		double ma=		c.MAprice(20,MODE_SMA);
		double price = c.get_now_price();
		double t = (double)c.get_now_time();
		double katamuki = c.MAkatamuki(20,MODE_SMA);
		pt_sup_data[i].pt_sup_status = 1;//有効1、無効0
		pt_sup_data[i].idx = base_idx;//基準zigzag idx
		pt_sup_data[i].pt_sup_line_4_y = y4;
		pt_sup_data[i].pt_sup_line_6_y = y6;
		pt_sup_data[i].pt_sup_6_4_line_price = (y4+y6)/2;
		pt_sup_data[i].pt_sup_3_price = y3;
		pt_sup_data[i].pt_sup_5_price = y5;
		pt_sup_data[i].pt_sup_2_1_dist = Dist_zigzag(chgKijun2Idx(base_idx,1),chgKijun2Idx(base_idx,2));
		pt_sup_data[i].pt_sup_2_1_dist_pips = chgPrice2Pips(pt_sup_data[i].pt_sup_2_1_dist);
		pt_sup_data[i].pt_sup_ma = 	ma;
		if(ma !=0){pt_sup_data[i].pt_sup_ma_kiri_ritu = 	(price - ma)/ma;}
		pt_sup_data[i].pt_sup_ma_katamuki = 	katamuki;// 20  ma1-ma2
		if(y7<y2){
			pt_sup_data[i].pt_sup_updn =1;//1up , -1dn
		}else{
			pt_sup_data[i].pt_sup_updn =-1;//1up , -1dn
		}
	    pt_sup_data_count++;
	}
	
	
	//有効無効フラグの更新
	//過去データの不成立の確認
	//基準より後のzigzagが上下ラインをXX％超えたらEnd
	for(int i=0;i<pt_sup_data_count;i++){
	    if(pt_sup_data[i].pt_sup_status==1){
	        if(pt_sup_data[i].idx<=zigzagdata_count-1){
                double now_price = zigzagdata[zigzagdata_count-1].value;
                double dd = pt_sup_data[i].pt_sup_distance_updown_value*gosa;
                
                if(
                	(pt_sup_data[i].pt_sup_updn==1 &&
                	 pt_sup_data[i].pt_sup_5_price >now_price &&
                	 pt_sup_data[i].pt_sup_3_price >now_price)
					||
                	(pt_sup_data[i].pt_sup_updn==-1 &&
                	 pt_sup_data[i].pt_sup_5_price <now_price &&
                	 pt_sup_data[i].pt_sup_3_price <now_price)
                ){
					pt_sup_data[i].pt_sup_status=0;
        	    }
        	}
        }
	}	
	
}


//データ追加処理
void add_pt_sup(){

//直接記述

}	

bool IsExitst_pt_sup_Zigzagdata(int base_idx){//すでに同じzigzagdata　idがあれば　true
    int idx;
    if(pt_sup_data_count>0){
        idx = pt_sup_data[pt_sup_data_count-1].idx;
    }else{
        return(false);
    }
    return(base_idx == 	idx);
}    
//データ取得処理
int get_pt_sup(struct_pt_sup &pt){
//    for(int =0;i<pt_sup_data_count;i++){
//    }
    if(pt_sup_data_count==0){
        return(0);
    }
    //struct_pt_sup apt;
    int i = pt_sup_data_count-1;
	pt.pt_sup_status  = 					pt_sup_data[i].pt_sup_status 				;
	pt.idx  =                               pt_sup_data[i].idx                            ;
	pt.pt_sup_upper_value  =              pt_sup_data[i].pt_sup_upper_value           ;
	pt.pt_sup_down_value  =               pt_sup_data[i].pt_sup_down_value            ;
	pt.pt_sup_distance_updown_value  =    pt_sup_data[i].pt_sup_distance_updown_value ;
	pt.pt_sup_distance_updown_pips  =     pt_sup_data[i].pt_sup_distance_updown_pips  ;

	pt.pt_sup_position_first = pt_sup_data[i].pt_sup_position_first;

    return(1);

}
int get_pattern_pt_sup_last_idx(void){
    if(pt_sup_data_count==0){
        return(-1);
    }
    return(pt_sup_data_count-1);
}
bool    Is_pattern_pt_sup(void){
    struct_pt_sup pt;
    int iret = get_pt_sup( pt);
    //すでに登録されていないか？調査し、ないなら、新パターン成立とする。
    
	//pt.pt_sup_status  = 					pt_sup_data[i].pt_sup_status 				;
	//pt.idx  =                               pt_sup_data[i].idx                            ;
	//pt.pt_sup_upper_value  =              pt_sup_data[i].pt_sup_upper_value           ;
	//pt.pt_sup_down_value  =               pt_sup_data[i].pt_sup_down_value            ;
	//pt.pt_sup_distance_updown_value  =    pt_sup_data[i].pt_sup_distance_updown_value ;
	//pt.pt_sup_distance_updown_pips  =     pt_sup_data[i].pt_sup_distance_updown_pips  ;
    bool ret=false;
	if(iret == 1&& pt.pt_sup_status==1){
		ret = true;
	}
#ifdef dellll
    if(  pt.pt_sup_status == 1){
        bool bex=Is_exist_pt_sup(pt.idx);
        if(bex ==false){
            ret=true;
            
        }else{
            ret=false;
        }
    }
#endif //dellll    
    return(ret);
}

#ifdef delll
void get_2tenkann_line_seppen_katamuki(double x1,double y1,double x2,double y2,double &seppen,double &katamuki){
//傾きないときは傾き０
    if(x1==x2){
        katamuki = 0;
        seppen = x1;
    }else{
 del       katamuki = chgPrice2Pips((y2-y1))/((x2-x1)/PeriodSeconds(Inp_base_time_frame));
        //katamuki = katamuki *3600;
        //katamuki = (y2-y1)*3600/(x2-x1);
        //切片ｂ＝ｙ１＋　a（－Ｘ１）
        seppen = chgPrice2Pips(y1);
        seppen = katamuki*(0-x1/(PeriodSeconds(Inp_base_time_frame)));
        seppen = chgPrice2Pips(y1)+katamuki*(0-x1/(PeriodSeconds(Inp_base_time_frame)));
    }
}
void get_2tennkann_line_and_1point_distance(double x1,double y1,double x2,double y2,double x0,double y0,double &dis){
// P1,P2の2点間を通過する直線とP0（ｘ０、ｙ０）の距離disを求める
    double bunshi = MathAbs(
        (y2-y1)*x0-(x2-x1)*y0+x2*y1-y2*x1)
    ;
    double bunnbo = MathSqrt(
        (y2-y1)*(y2-y1)+(x2-x1)*(x2-x1))
    ;
    if(bunnbo==0){
        printf("error 0 wari "+ __FUNCTION__);
    }else{
        dis = bunshi/bunnbo;
    }
}
//３点が同一直線上に並んでいるか
bool Is_3point_same_online(double x1,double y1,double x2,double y2,double x3,double y3, double gosa_pips){
    bool ret=false;
    double dis_LP1P3_P2;
    double dis_LP2P3_P1;
    double dis_LP1P2_P3;
    double max,gosa;
    get_2tennkann_line_and_1point_distance(x1,y1,x3,y3,x2,y2,dis_LP1P3_P2);
    get_2tennkann_line_and_1point_distance(x2,y2,x3,y3,x1,y1,dis_LP2P3_P1);
    get_2tennkann_line_and_1point_distance(x1,y1,x2,y2,x3,y3,dis_LP1P2_P3);
    max = MathMax(dis_LP1P3_P2,dis_LP2P3_P1);
    max = MathMax(max,dis_LP1P2_P3);
    gosa = chgPips2price(gosa_pips);
    if(max < gosa){
        ret = true;
    }
    return ret;
}
int get_updn_atline(double x0,double y0,double katamuki,double seppen){//ラインの上か下か？ 1:upper,-1 down, 0:same
    double d=y0-katamuki*x0-seppen;
    int ret;
    if(d>0){//uegawa
        ret =1;
    }else if(d<0){//shitagawa
        ret = -1;
    }else{//sen jou
        ret =0;
    }
    return ret;
}


//2点がほぼ同じ高さか？
bool Is_2point_same_price(double y1,double y2,double gosapips){
	return(MathAbs(y1-y2)<chgPips2price(gosapips));
}
#endif //delll
