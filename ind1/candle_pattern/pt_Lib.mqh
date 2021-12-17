
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

	double d1,d2;//
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