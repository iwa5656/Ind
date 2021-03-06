bool eq_zigzag(int idx1,int idx2,double gosaPips){
    bool ret = false;
    double v1,v2;
    datetime t1,t2;
    int k1,k2;
    int c1,c2;//最大数
    bool bret1,bret2;
    bret1=get_zigzagdata(period,idx1,v1,t1,k1,c1);
    bret2=get_zigzagdata(period,idx2,v2,t2,k2,c2);
    double dd = gosaPips*10*Point();
    if(v1+ dd >=v2 && v1-dd <= v2){
        ret = true;
    }
    return(ret);
}
bool lt_zigzag(int idx1,int idx2,double gosaPips){ // idx1は2-ｄｄよりも小さい
    bool ret = false;
    double v1,v2;
    datetime t1,t2;
    int k1,k2;
    int c1,c2;//最大数
    bool bret1,bret2;
    bret1=get_zigzagdata(period,idx1,v1,t1,k1,c1);
    bret2=get_zigzagdata(period,idx2,v2,t2,k2,c2);
    double dd = gosaPips*10*Point();
    if(v1 <=v2- dd){
        ret = true;
    }
    return(ret);
}
bool gt_zigzag(int idx1,int idx2,double gosaPips){// idx１は２＋ｄｄよりもBig
    bool ret = false;
    double v1,v2;
    datetime t1,t2;
    int k1,k2;
    int c1,c2;//最大数
    bool bret1,bret2;
    bret1=get_zigzagdata(period,idx1,v1,t1,k1,c1);
    bret2=get_zigzagdata(period,idx2,v2,t2,k2,c2);
    double dd = gosaPips*10*Point();
    if((v1) >= (v2+ dd)){
        ret = true;
    }
    return(ret);
}
double Dist_zigzag(int idx1,int idx2){// 単位は価格
    return(Dist_zigzag(idx1,idx2,0));// 単位は価格
}
double Dist_zigzag(int idx1,int idx2,double gosaPips){// 単位は価格
    //bool ret = false;
    double v1,v2;
    datetime t1,t2;
    int k1,k2;
    int c1,c2;//最大数
    bool bret1,bret2;
    bret1=get_zigzagdata(period,idx1,v1,t1,k1,c1);
    bret2=get_zigzagdata(period,idx2,v2,t2,k2,c2);
    return(MathAbs(v1-v2));
    //return(ret);
}
double Dist_ipips_zigzag(int idx1,int idx2,double gosaPips){// 単位はPips
    double r = Dist_zigzag(idx1,idx2,0);
    return( r/Point()  / 10 );
}
int chgKijun2Idx(int base_idx,int idx){// base_idxはっ注目count－１、idxは基準が１として
// 基準１は9,2は８、base：注目idx　カウント１０の時idx９
    return(base_idx-idx+1);
}
