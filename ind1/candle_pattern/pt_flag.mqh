//#include "..\class_candle_data.mqh"
//#include "..\class_allcandle.mqh"
//#include "..\classMethod.mqh"

//レンジパターン
//pt_flag
//データ
int pre_pt_flag_zig_count;
int pt_flag_find_count;
	//データ定義
    #define NUM_OF_PT_FLAG 6000	
#ifdef dellll
	struct struct_pt_flag{
		int pt_flag_status;//有効1、無効0
		int idx;//基準zigzag idx
		double pt_flag_upper_value;
		double pt_flag_down_value;
		double pt_flag_distance_updown_value;
		double pt_flag_distance_updown_pips;
		int pt_flag_position_first;// 基準１の位置が上か下か？上のほう１：　下のほう-1
	};
#endif // dellll
	struct_pt_flag pt_flag_data[NUM_OF_PT_FLAG];
	int pt_flag_data_count;
	struct_pt_flag pt_flag_data_now;
	
void init_pt_flag(){
    pt_flag_data_count = 0;
    pt_flag_data_now.pt_flag_status = 0;//無効
    pt_flag_find_count = 0;
}	
//確定時計算データ更新
void calc_pt_flag(){
    if(zigzagdata_count<7){
        return;// 数が足りてないのでもどず
    }
    int base_idx = zigzagdata_count-1;
	if(base_idx < 0){
		return;//error
	}
#ifdef commenttttt
________________________
			
			5		3		1
		
				4		2
							
									
	6								
________________________
		6		4		2
			
			5		3		1
							
									
	7								
________________________
	6								


				4		2

			5		3		1
________________________
	7								


			5		3		1
	
		6		4		2
________________________
#endif//commenttttt	
	//条件一覧
	
	//xは時間にするdatetime
	//1-6
	
	//1,3,5が直線上か？
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
	//ZigUD(1);
	double gosa_pips = 10;//３点のずれの許容幅
    bool bsameline135 = Is_3point_same_online( x1, y1, x3, y3, x5, y5,  gosa_pips);
	bool bsameline246 = Is_3point_same_online( x2, y2, x4, y4, x6, y6,  gosa_pips);
	double a1=0;//katamuki
	double b1=0; //seppen
	get_2tenkann_line_seppen_katamuki(x1,y1,x5,y5,b1,a1);
	double a2=0;//katamuki
	double b2=0; //seppen
	get_2tenkann_line_seppen_katamuki(x2,y2,x4,y4,b2,a2);
	
	if(bsameline135 == true && bsameline246==true && pre_pt_flag_zig_count!=zigzagdata_count){
	    pt_flag_find_count++;
	    a1=a1*3600;
	    printf("	    pt_flag_find_count++"+IntegerToString(	    pt_flag_find_count));

	    printf("135idx="+IntegerToString(chgKijun2Idx(base_idx,1)) +" a1="+DoubleToString(a1) 
	    +" b1="+DoubleToString(b1));
	    printf("24idx="+IntegerToString(chgKijun2Idx(base_idx,1)) +" a2="+DoubleToString(a2) 
	    +" b2="+DoubleToString(b1));
	    
	    bsameline135 = Is_3point_same_online( x1, y1, x3, y3, x5, y5,  gosa_pips);//debug 
	    pre_pt_flag_zig_count = zigzagdata_count;
	}
	
	double sapips_1_2 = chgPrice2Pips(
	    Dist_zigzag(
	        chgKijun2Idx(base_idx,1),chgKijun2Idx(base_idx,2)));
	double sapips_3_4 = chgPrice2Pips(
	    Dist_zigzag(
	        chgKijun2Idx(base_idx,3),chgKijun2Idx(base_idx,4)));
	
	double gosa = 0.1;//10%
	double gosaPips = (sapips_1_2*gosa);
	bool ret = (sapips_1_2*(1.0+gosa)>sapips_3_4)&&((sapips_1_2*(1.0-gosa)<sapips_3_4));
	if(ret == true){
	    ret =ret;
	    //idebug=1;
	}
	//ret = true;
	

	bool ret2=ret 
	    //1,3 大体同じ
	    &&eq_zigzag(chgKijun2Idx(base_idx,1),chgKijun2Idx(base_idx,3),gosaPips)// ★大体同じgosaPips,gosa参照
	    //2，4大体同じ
	    &&eq_zigzag(chgKijun2Idx(base_idx,2),chgKijun2Idx(base_idx,4),gosaPips)// ★大体同じgosaPips,gosa参照
	;
	if(ret2==true){//rang
	    eq_zigzag(chgKijun2Idx(base_idx,1),chgKijun2Idx(base_idx,3),gosaPips);// debug zzz
	    add_pt_flag();
	}
	
	//過去データの不成立の確認
	//基準より後のzigzagが上下ラインをXX％超えたらEnd
	for(int i=0;i<pt_flag_data_count;i++){
	    if(pt_flag_data[i].pt_flag_status==1){
	        if(pt_flag_data[i].idx<zigzagdata_count-1){
                double now_price = zigzagdata[zigzagdata_count-1].value;
                double dd = pt_flag_data[i].pt_flag_distance_updown_value*gosa;
        	    if(pt_flag_data[i].pt_flag_upper_value+dd<now_price ||
        	        pt_flag_data[i].pt_flag_down_value-dd>now_price){
        	            pt_flag_data[i].pt_flag_status=0;
        	    }
        	}
        }
	}
}
//データ追加処理
void add_pt_flag(){
    int i=pt_flag_data_count;
    int base_idx = zigzagdata_count-1;
	if(base_idx < 0){
		return;//error
	}
	
	//同一idの場合、登録済みなので登録しない
	if( IsExitstZigzagdata(base_idx) ){
	    return;
	}
	
	double dn_value,up_value;
	int idx;
	double v1,v2;
	datetime t;
	int k;
	int c;    
    bool ret;
    //基準1データ取得
    idx=chgKijun2Idx(base_idx,1);//基準のzigのidx, 基準での番号　（1が最後のデータ）
    ret = get_zigzagdata(period,idx,v1,t,k,c);
    if(ret == false){
        printf("error at "+__FUNCTION__ +"  "+__FILE__+"("+IntegerToString(__LINE__)+")");
        return;
    }
    
    //基準2データ取得
    idx=chgKijun2Idx(base_idx,2);//基準のzigのidx, 基準での番号　（1が最後のデータ）
    ret = get_zigzagdata(period,idx,v2,t,k,c);
    if(ret == false){
        printf("error at "+__FUNCTION__ +"  "+__FILE__+"("+IntegerToString(__LINE__)+")");
        return;
    }
    int pos;
    if(v1>v2){
	    up_value = v1;
	    dn_value = v2;
	    pos=1;
	}else{ 
	    up_value = v2;
	    dn_value = v1;
	    pos=-1;
    }
	pt_flag_data[i].pt_flag_status = 1;//有効1、無効0
	pt_flag_data[i].idx = base_idx;//基準zigzag idx
	pt_flag_data[i].pt_flag_upper_value = up_value;
	pt_flag_data[i].pt_flag_down_value = dn_value;
	pt_flag_data[i].pt_flag_distance_updown_value = Dist_zigzag(chgKijun2Idx(base_idx,1),chgKijun2Idx(base_idx,2));
	pt_flag_data[i].pt_flag_distance_updown_pips = chgPrice2Pips(pt_flag_data[i].pt_flag_distance_updown_value);
	pt_flag_data[i].pt_flag_position_first = pos;

    pt_flag_data_count++;
}
bool IsExitst_pt_flag_Zigzagdata(int base_idx){//すでに同じzigzagdata　idがあれば　true
    int idx;
    if(pt_flag_data_count>0){
        idx = pt_flag_data[pt_flag_data_count-1].idx;
    }else{
        return(false);
    }
    return(base_idx == 	idx);
}    
//データ取得処理
int get_pt_flag(struct_pt_flag &pt){
//    for(int =0;i<pt_flag_data_count;i++){
//    }
    if(pt_flag_data_count==0){
        return(0);
    }
    //struct_pt_flag apt;
    int i = pt_flag_data_count-1;
	pt.pt_flag_status  = 					pt_flag_data[i].pt_flag_status 				;
	pt.idx  =                               pt_flag_data[i].idx                            ;
	pt.pt_flag_upper_value  =              pt_flag_data[i].pt_flag_upper_value           ;
	pt.pt_flag_down_value  =               pt_flag_data[i].pt_flag_down_value            ;
	pt.pt_flag_distance_updown_value  =    pt_flag_data[i].pt_flag_distance_updown_value ;
	pt.pt_flag_distance_updown_pips  =     pt_flag_data[i].pt_flag_distance_updown_pips  ;

	pt.pt_flag_position_first = pt_flag_data[i].pt_flag_position_first;

    return(1);

}
int get_pattern_flag_pt_flag_last_idx(void){
    if(pt_flag_data_count==0){
        return(-1);
    }
    return(pt_flag_data_count-1);
}
bool    Is_pattern_flag(void){
    struct_pt_flag pt;
    int iret = get_pt_flag( pt);
    //すでに登録されていないか？調査し、ないなら、新パターン成立とする。
    
	//pt.pt_flag_status  = 					pt_flag_data[i].pt_flag_status 				;
	//pt.idx  =                               pt_flag_data[i].idx                            ;
	//pt.pt_flag_upper_value  =              pt_flag_data[i].pt_flag_upper_value           ;
	//pt.pt_flag_down_value  =               pt_flag_data[i].pt_flag_down_value            ;
	//pt.pt_flag_distance_updown_value  =    pt_flag_data[i].pt_flag_distance_updown_value ;
	//pt.pt_flag_distance_updown_pips  =     pt_flag_data[i].pt_flag_distance_updown_pips  ;
    bool ret=false;
	if(iret == 1&& pt.pt_flag_status==1){
		ret = true;
	}
#ifdef dellll
    if(  pt.pt_flag_status == 1){
        bool bex=Is_exist_pt_flag(pt.idx);
        if(bex ==false){
            ret=true;
            
        }else{
            ret=false;
        }
    }
#endif //dellll    
    return(ret);
}

void get_2tenkann_line_seppen_katamuki(double x1,double y1,double x2,double y2,double &seppen,double &katamuki){
//傾きないときは傾き０
    if(x1==x2){
        katamuki = 0;
        seppen = x1;
    }else{
        katamuki = chgPrice2Pips((y2-y1))/((x2-x1)/PeriodSeconds(Inp_base_time_frame));
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
//２Lineが平行か？ ((x1,y1),(x2,y2)) と((x4,y4),(x4,y4))　数字が小さいものが時間的に古いものとする
bool Is_heikou_2line(double x1,double y1,double x2,double y2,double x3,double y3,double x4,double y4){
	int ret=get_heikou_2line_katamuki_kannkei(x1,y1,x2,y2,x3,y3,x4,y4);
	if(ret==0){
		return true;
	}
	return false;	
}

int get_heikou_2line_katamuki_kannkei(double x1,double y1,double x2,double y2,double x3,double y3,double x4,double y4){
	//傾きの関係
		//-1スクイーズ：時間たつにつれて狭まっている
		//1拡大
		//0平行
		// error 99
	//平行かどうかの基準　傾きが倍率以内なら平行とする。
	double bairitu = 1.1;//傾き倍率　大きいものを小さいもので割った比率

	double a1,a2;//katamuki bunshi
	a1=(y2-y1);
	a2=(y4-y3);
	double b1,b2;//katamuki bunbo
	b1=(x2-x1);
	b2=(x4-x3);

	if(b1==0.0 || b2==0.0){
		Print(__FUNCTION__,"error arienai0 para error");
		return 99;//error
	}
	double c1,c2;//katamuki
	c1=a1/b1;
	c2=a2/b2;

//	double d1,d2;//
	double b=MathMax(MathAbs(c1),MathAbs(c2));
	double s=MathMin(MathAbs(c1),MathAbs(c2));
	double bs=100;
	if(b==0.0 || s==0.0){
		//bs?bairitu 成立側へ
		bs=100;
	}else{
		bs=	b/s;
	}
	if(bs < bairitu){
		return 0;//平行
	}else if(y1>y3){//初めの直線のほうが上
		if(c1<c2){
				// スクイーズ
				return -1;
		}else if(c1>c2){
				//拡大
				return 1;
		}else{
			Print(__FUNCTION__,"error arienai1");
		}
	}else{//初めの直線のほうが下
		if(c1>c2){
				// スクイーズ
				return -1;
		}else if(c1<c2){
				//拡大
				return 1;
		}else{
			Print(__FUNCTION__,"error arienai2");
		}
	}
	Print(__FUNCTION__,"error arienai4");
	return 99;
}