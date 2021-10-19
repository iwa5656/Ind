#ifndef _LIB_XY_FUNC_
#define _LIB_XY_FUNC_

struct real_point {
  datetime t;
  double v;
};
struct imi_point{
  double x;
  double y;
};

//線分と点の距離
double cal_point_line_dist(real_point &a,real_point &b,real_point &c){
  double ret=0;//距離線分abとｃとの距離
  datetime Tk = a.t;
  imi_point d,e,f;
  chg_r2i(a,d,Tk);
  chg_r2i(b,e,Tk);
  chg_r2i(c,f,Tk);
  ret = cal_point_line_dist_imi(d,e,f);
  return(ret);
}
double cal_point_line_dist_imi(imi_point &d,imi_point &e,imi_point &f){
  double ret=0;//距離線分deとfとの距離
  if(d.x == e.x){    return ret;  }
  double x1,y1,x2,y2,x0,y0;  x1=d.x;y1=d.y;  x2=e.x;y2=e.y;  x0=f.x;y0=f.y;
  double arufa=(y2-y1)/(x2-x1);
  double y_x0=arufa*x0-arufa*x1+y1;
  ret = MathAbs(arufa*x0+(-1)*y0+((-1)*arufa*x1+y1))/MathSqrt(arufa*arufa+1);
  return ret;
}


//線分abと点cの位置関係を知る(上か下か線上か？)
int chk_point_line_upperordownside(real_point &a,real_point &b,real_point &c){
  int ret=0;//上：1　下-1、　線分上0
  datetime Tk = a.t;
  imi_point d,e,f;
  chg_r2i(a,d,Tk);
  chg_r2i(b,e,Tk);
  chg_r2i(c,f,Tk);
  ret = chk_point_line_upperordownside_imi(d,e,f);
  return ret;
}
int chk_point_line_upperordownside_imi(imi_point &d,imi_point &e,imi_point &f){
  int ret=0;//上：1　下-1、　線分上0
  if(d.x == e.x){    return ret;  }
  double x1,y1,x2,y2,x0,y0;  x1=d.x;y1=d.y;  x2=e.x;y2=e.y;  x0=f.x;y0=f.y;
  double arufa=(y2-y1)/(x2-x1);
  double y_x0=arufa*x0-arufa*x1+y1;
  if(y_x0 < y0){ret = 1;}else if(y_x0 > y0){ret = -1;}else{ret = 0;}
  return ret;
}
//線分と線分から上方向に距離D離れた線分の間にあるかの判別
int chk_point_lineAndLine_inner_upperD(real_point &a,real_point &b,real_point &c
,double dist){
  int ret=0;//０：外,　　1：中
  datetime Tk = a.t;
  imi_point d,e,f;
  chg_r2i(a,d,Tk);
  chg_r2i(b,e,Tk);
  chg_r2i(c,f,Tk);
  ret = chk_point_lineAndLine_inner_upperD_imi(d,e,f,dist);
  return ret;
}
int chk_point_lineAndLine_inner_upperD_imi(imi_point &d,imi_point &e,imi_point &f
,double dist){
  int ret=0;//０：外,　　1：中
  if(d.x == e.x){  /*x軸上なので別のやり方*/}
  else{
    //距離dist離れた数式を算出
    double x1,y1,x2,y2,x0,y0;  x1=d.x;y1=d.y;  x2=e.x;y2=e.y;  x0=f.x;y0=f.y;
    double arufa=(y2-y1)/(x2-x1);

    double y_x0=arufa*x0-arufa*x1+y1;
    double y_d_x0=arufa*x0 -arufa*x1+y1     +dist*MathSqrt(arufa*arufa+1);
    //ｙ_d_x0  ＝ax+b ±Dist*sqrt（a^2+1）

    if(y_x0<=y0 && y_d_x0>=y0){
      ret = 1;//範囲内
    }

  }

  return ret;

}




//線分と線分から上下方向に距離D離れた線分の間にあるかの判別
int chk_point_lineAndLine_inner_upperD_downD(real_point &a,real_point &b,real_point &c
,double dist){
  int ret=0;//０：外,　　1：中
  datetime Tk = a.t;
  imi_point d,e,f;
  chg_r2i(a,d,Tk);
  chg_r2i(b,e,Tk);
  chg_r2i(c,f,Tk);
  ret = chk_point_lineAndLine_inner_upperD_downD_imi(d,e,f,dist);
  return ret;
}
int chk_point_lineAndLine_inner_upperD_downD_imi(imi_point &d,imi_point &e,imi_point &f
,double dist){
  int ret=0;//０：外,　　1：中
  if(d.x == e.x){  /*x軸上なので別のやり方*/ }
  else{
    //距離dist離れた数式を算出
    double x1,y1,x2,y2,x0,y0;  x1=d.x;y1=d.y;  x2=e.x;y2=e.y;  x0=f.x;y0=f.y;
    double arufa=(y2-y1)/(x2-x1);

//    double y_x0=arufa*x0-arufa*x1+y1;
    double y_d_up_x0=arufa*x0 -arufa*x1+y1     +dist*MathSqrt(arufa*arufa+1);
    double y_d_dn_x0=arufa*x0 -arufa*x1+y1     -dist*MathSqrt(arufa*arufa+1);
    //ｙ_d_x0  ＝ax+b ±Dist*sqrt（a^2+1）

    if(y_d_dn_x0<=y0 && y_d_up_x0>=y0){
      ret = 1;//範囲内
    }
  }
  return ret;
}






//リアル座標から意味座標へ変換
bool chg_r2i(real_point &a,imi_point &o,datetime Tk){
  bool ret=false;
  o.y = a.v;
  ret = chg_t2x(Tk,a.t,PERIOD_M5,o.x);
  return ret;
}


//基準時間から指定時間inp_tにバーが何本あるか（Tkおなじなら０とする。その前の時間を-1とする）
bool chg_t2x(datetime Tk,datetime inp_t, ENUM_TIMEFRAMES peri,double &out_bar_idx){
  bool ret=false;
  int t_per_bar=PeriodSeconds(peri);//1barの秒数

  datetime tk,i_t;
  if(Tk>inp_t){
    tk=Tk;i_t=inp_t;
  }else{
    tk=inp_t;i_t=Tk;
  }


  int weekcount=0;//何週間分?
//→週初(月曜0：00)めからＴｋまでのbar数：fromWeekStart_barcount
  datetime fromWeekStart_t=0;
  //週末までのbarの数　週末は金曜23：59
  //datetime toWeekEnd_t=0;
  datetime t_a,t_b,t_c;
  t_a=0;t_b=0;t_c=0;
  MqlDateTime dt_tk;
  ret = TimeToStruct( tk,dt_tk);
  if(ret != false){
    //曜日
    //int day_of_week;   // 曜日（日曜が 0、月曜が 1、...土曜が 6 ） 
    if(dt_tk.day_of_week == 0 || dt_tk.day_of_week == 6){
      ret = false;
    }else{
      fromWeekStart_t=(dt_tk.day_of_week-1)*(24*60*60)+
        (
          dt_tk.hour*60*60+
          dt_tk.min*60+
          dt_tk.sec
        );
      #ifdef delll
      toWeekEnd_barcount=(5-dt_tk.day_of_week)*(24*60*60)+
        (
          (24-dt_tk.hour-1)*60*60+
          (60-dt_tk.min-1)*60+
          (60-dt_tk.sec-1)
        );
      #endif // delll  
      
    }
    t_a=tk-i_t;
    if(t_a>fromWeekStart_t){//土日跨ぎそうか
      t_c=t_a-fromWeekStart_t;
      weekcount=1;
      weekcount =(int)(weekcount + t_c/(7*24*60*60));
      int amari = (int)(t_c%(7*24*60*60));
      if(amari ==0){weekcount--;}
    }else{}
    ret = true;
    out_bar_idx=(int)((t_a-weekcount*(2*24*60*60))/t_per_bar);
    if(Tk>inp_t){
      out_bar_idx = out_bar_idx*(-1);
    }else{
      out_bar_idx = out_bar_idx;
    }
  }
  return ret;
}

#ifdef commentss
基準時間Txとバーインデックスから元の時間を求めるには									
	基準Txからバーインデックス分時間をずらす								
	土日が挟むときはその分時間を足す必要がある。								
		１W分のバーの数は分かるので、Wc							
			バーidx/Wcの絶対値で何週間あるかわかる＝＞						
		x→ｔへ変換							
			Inp	Tk,	基準となる時間				
				bidx	インデックス（ｘ軸）			バーidx	bidx 0がTkと同じ時間　未来は＋、過去がマイナス
				時間軸	peri	または　時間軸の一つのバーの秒数			
#endif // comeentss        
bool chg_x2t(datetime Tk,int bidx, ENUM_TIMEFRAMES peri,datetime &out_t){
  bool ret=false;
  int t_per_bar=PeriodSeconds(peri);//1barの秒数

  //→週初(月曜0：00)めからＴｋまでのbar数：fromWeekStart_barcount
  int fromWeekStart_barcount=0;
  //週末までのbarの数　週末は金曜23：59
  int toWeekEnd_barcount=0;
  MqlDateTime dt_struct;
  ret = TimeToStruct( Tk,dt_struct);
  if(ret != false){
    //曜日
    //int day_of_week;   // 曜日（日曜が 0、月曜が 1、...土曜が 6 ） 
    if(dt_struct.day_of_week == 0 || dt_struct.day_of_week == 6){
      ret = false;
    }else{
      fromWeekStart_barcount=(dt_struct.day_of_week-1)*(24*60*60/t_per_bar)+
        (
          dt_struct.hour*60*60+
          dt_struct.min*60+
          dt_struct.sec
        )/t_per_bar;
      toWeekEnd_barcount=(5-dt_struct.day_of_week)*(24*60*60/t_per_bar)+
        (
          (24-dt_struct.hour-1)*60*60+
          (60-dt_struct.min-1)*60+
          (60-dt_struct.sec-1)
        )/t_per_bar;
      
    }
  }
  int abs_bar_count;//絶対数
  abs_bar_count = MathAbs(bidx);
  int weekcount=0;//何週間分?
  if(bidx<0){//過去方向に対して
    if(abs_bar_count>fromWeekStart_barcount){
      //週をまたぐため何週間あるか　＋１
      weekcount=1;
      //何週間分＝int(　（barー①）/時間軸の１Wのbarの数)
      weekcount=weekcount+(abs_bar_count-fromWeekStart_barcount)/(5*24*60*60);
      int amari=(abs_bar_count-fromWeekStart_barcount)%(5*24*60*60);
      if(amari == 0){weekcount--;}
    }else{}//週を跨がない
    //Tkから　　土日分とバーの数分　ずらした時間
    out_t=Tk-(2*24*60*60)*weekcount-(abs_bar_count)*t_per_bar;
    ret = true;
  }else if ( bidx==0 ){
    out_t=Tk;
    ret = true;
  }else{//Tkの未来方向
    if(abs_bar_count>toWeekEnd_barcount){
      //週をまたぐため何週間あるか　＋１
      weekcount=1;
      //何週間分＝int(　（barー①）/時間軸の１Wのbarの数)
      weekcount=weekcount+(abs_bar_count-toWeekEnd_barcount)/(5*24*60*60);
      int amari=(abs_bar_count-toWeekEnd_barcount)%(5*24*60*60);
      if(amari == 0){weekcount--;}
    }else{}//週を跨がない
    //Tkから　　土日分とバーの数分　ずらした時間
    out_t=Tk+(2*24*60*60)*weekcount+(abs_bar_count)*t_per_bar;
    ret = true;
  
  }
  return ret;
}


#ifdef del_test
void test11(){
bool ret;
datetime Tk=D'2021.10.04 00:30:27';
int bidx=-2;
ENUM_TIMEFRAMES peri=PERIOD_M5;
datetime out_t=0;
//chg_x2t(datetime Tk,int bidx, ENUM_TIMEFRAMES peri,datetime &out_t){

  Tk=D'2021.10.04 00:30:27';
  bidx=-2;
  peri=PERIOD_M5;
  out_t=0;
  printf("Tk="+TimeToString(Tk));
  chg_x2t(Tk,bidx, peri,out_t);
  printf("bidx="+ IntegerToString(bidx)+"  out_t="+TimeToString(out_t));
  printf("---------------------\n");



  Tk=D'2021.10.04 00:00:27';
  bidx=0;
  peri=PERIOD_M5;
  out_t=0;
  printf("Tk="+TimeToString(Tk));
  chg_x2t(Tk,bidx, peri,out_t);
  printf("bidx="+ IntegerToString(bidx)+"  out_t="+TimeToString(out_t));
  printf("---------------------\n");
  
  Tk=D'2021.10.04 00:00:27';
  bidx=-1;
  peri=PERIOD_M5;
  out_t=0;
  printf("Tk="+TimeToString(Tk));
  chg_x2t(Tk,bidx, peri,out_t);
  printf("bidx="+ IntegerToString(bidx)+"  out_t="+TimeToString(out_t));
  printf("---------------------\n");

    
  Tk=D'2021.10.04 00:00:27';
  bidx=0-5*24*60*60/(5*60);
  peri=PERIOD_M5;
  out_t=0;
  printf("Tk="+TimeToString(Tk));
  chg_x2t(Tk,bidx, peri,out_t);
  printf("bidx="+ IntegerToString(bidx)+"  out_t="+TimeToString(out_t));
  printf("---------------------\n");

  Tk=D'2021.10.04 00:00:27';
  bidx=0-5*24*60*60/(5*60)-1;
  peri=PERIOD_M5;
  out_t=0;
  printf("Tk="+TimeToString(Tk));
  chg_x2t(Tk,bidx, peri,out_t);
  printf("bidx="+ IntegerToString(bidx)+"  out_t="+TimeToString(out_t));
  printf("---------------------\n");




  Tk=D'2021.10.01 23:55:27';
  bidx=0;
  peri=PERIOD_M5;
  out_t=0;
  printf("Tk="+TimeToString(Tk));
  chg_x2t(Tk,bidx, peri,out_t);
  printf("bidx="+ IntegerToString(bidx)+"  out_t="+TimeToString(out_t));
  printf("---------------------\n");

  Tk=D'2021.10.01 23:55:27';
  bidx=1;
  peri=PERIOD_M5;
  out_t=0;
  printf("Tk="+TimeToString(Tk));
  chg_x2t(Tk,bidx, peri,out_t);
  printf("bidx="+ IntegerToString(bidx)+"  out_t="+TimeToString(out_t));
  printf("---------------------\n");

  Tk=D'2021.10.01 23:55:27';
  bidx=2;
  peri=PERIOD_M5;
  out_t=0;
  printf("Tk="+TimeToString(Tk));
  chg_x2t(Tk,bidx, peri,out_t);
  printf("bidx="+ IntegerToString(bidx)+"  out_t="+TimeToString(out_t));
  printf("---------------------\n");



  datetime inp_t;
  int out_bar_idx;

  Tk=    D'2021.10.01 23:55:27';
  inp_t= D'2021.10.01 23:55:27';
   //bool chg_t2x(datetime Tk,datetime inp_t, ENUM_TIMEFRAMES peri,int &out_bar_idx){

  chg_t2x(Tk,inp_t, peri,out_bar_idx);
  printf("Tk="+TimeToString(Tk));
  printf("OUT bidx="+ IntegerToString(out_bar_idx)+"  inp_t="+TimeToString(inp_t));
  printf("---------------------\n");


  Tk=    D'2021.10.04 00:00:27';
  inp_t= D'2021.10.01 23:55:27';
   //bool chg_t2x(datetime Tk,datetime inp_t, ENUM_TIMEFRAMES peri,int &out_bar_idx){

  chg_t2x(Tk,inp_t, peri,out_bar_idx);
  printf("Tk="+TimeToString(Tk));
  printf("OUT bidx="+ IntegerToString(out_bar_idx)+"  inp_t="+TimeToString(inp_t));
  printf("---------------------\n");



  Tk=    D'2021.10.11 00:00:27';
  inp_t= D'2021.10.01 23:55:27';
   //bool chg_t2x(datetime Tk,datetime inp_t, ENUM_TIMEFRAMES peri,int &out_bar_idx){

  chg_t2x(Tk,inp_t, peri,out_bar_idx);
  printf("Tk="+TimeToString(Tk));
  printf("OUT bidx="+ IntegerToString(out_bar_idx)+"  inp_t="+TimeToString(inp_t));
  printf("---------------------\n");




 inp_t=    D'2021.10.11 00:00:27';
  Tk= D'2021.10.01 23:55:27';
   //bool chg_t2x(datetime Tk,datetime inp_t, ENUM_TIMEFRAMES peri,int &out_bar_idx){

  chg_t2x(Tk,inp_t, peri,out_bar_idx);
  printf("Tk="+TimeToString(Tk));
  printf("OUT bidx="+ IntegerToString(out_bar_idx)+"  inp_t="+TimeToString(inp_t));
  printf("---------------------\n");



}
#endif// del_test


#endif//_LIB_XY_FUNC_
