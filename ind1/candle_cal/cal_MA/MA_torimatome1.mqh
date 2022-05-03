#ifndef classMA_torimatome1
#define classMA_torimatome1
#include "MApf.mqh"
#include "../../class_candle_data.mqh"

//
class MA_torimatome1
{
public:
    // ①all candle作成後、ベースのcandledataを対象に作成し、その後、MAを登録（０１２）          //p_MA_torimatome1,
    //　②ベースの足確定のところに次の通知を追加　add_new_bar_calc(double &v[],int maxidx,int count)
    //　③データ利用は、①のオブジェクト経由でMA,POを取得する
    candle_data *m_c;
    #define NUM_OF_BUFFER_PO 300
    //#define NUM_OF_POs 300
    double POs[NUM_OF_BUFFER_PO];//  0が一番古い、         前回値、前々回、前々々回　　　　　上にPO中　、下にPO中　、崩れた
    int po_count;  
    double pre_po;

    bool flag_po_0_to_dn;//パーフェクトオーダー上になった                           （足確定時に更新：add_new_bar_calc）
    bool flag_po_0_to_up;//パーフェクトオーダー下になった                           （足確定時に更新：add_new_bar_calc）
    bool flag_po_dn_to_0;//パーフェクトオーダー下の状態から、そうでない状態になった     （足確定時に更新：add_new_bar_calc）
    bool flag_po_up_to_0;//パーフェクトオーダー上の状態から、そうでない状態になった     （足確定時に更新：add_new_bar_calc）



	//--- コンストラクタとデストラクタ
	MA_torimatome1(void){};
    #define NUM_OF_CHAILD_MA 3
//	MA_torimatome1(candle_data &p){ m_c=p;  // all candle作成後、ベースのcandledataを対象に作成する。
	MA_torimatome1(candle_data* p){ m_c=p;  // all candle作成後、ベースのcandledataを対象に作成する。
        for(int i=0;i<NUM_OF_CHAILD_MA;i++){
            MApfs[i]=NULL;
        }
        for(int i = 0;i<NUM_OF_BUFFER_PO;i++){POs[i]=0.0;}
        pre_po=0.0;
        po_count=0;

        flag_po_0_to_dn=false;
        flag_po_0_to_up=false;
        flag_po_dn_to_0=false;
        flag_po_up_to_0=false;
    }
		
	~MA_torimatome1(void){};


//データ
    //子供のma
    //    MApf objs
    //        f,m,s,ss
            MApf *MApfs[4];


//登録		
	//MA子供の登録_period、type, ｆｍｓｓｓの指定	
        bool reg_MApf(int idx,int iperiod,int itype){//  idxを指定（0からｎ）して、MAオブジェクトを作成、登録する（０が早い周期）
            if(idx >= NUM_OF_CHAILD_MA){return false;}
            MApfs[idx]=new MApf(iperiod,itype);
            return true;
        }
//呼び出し(子供のMAに確定足を渡す)		
	//足追加時の計算を登録したものに通知	
    void add_new_bar_calc(double &v[],int maxidx,int count){ // 確定足が入った配列、配列の最後の要素idx（最新データ）、データの数    追加データは　配列サイズ-1に入っている。
        for(int i=0;i<NUM_OF_CHAILD_MA;i++){
            if(MApfs[i]!=NULL){
                MApfs[i].add_new_bar_calc(v,maxidx,count);
            }
        }
        //パーフェクトオーダーの更新
        calc_perfect_order();
    }
    void calc_perfect_order(void){
    //perfect_orderの更新
      //各MAがデータがあるか確認、
      //#define NUM_OF_POs 300
      //double POs[NUM_OF_POs];//  0が一番古い、         前回値、前々回、前々々回　　　　　上にPO中　、下にPO中　、崩れた
      //for(int i = 0;i<NUM_OF_POs;i++){POs[i]=0.0;}
      //前回から変化があるか確認
        int po=0;int i;
        double f,m,s;
        if( (MApfs[0].ma_count<=0) || (MApfs[1].ma_count<=0) || (MApfs[2].ma_count<=0) ){return;}
        flag_po_0_to_dn=false;
        flag_po_0_to_up=false;
        flag_po_dn_to_0=false;
        flag_po_up_to_0=false;

        f=MApfs[0].ma[NUM_OF_BUFFER_MA-1];
        m=MApfs[1].ma[NUM_OF_BUFFER_MA-1];
        s=MApfs[2].ma[NUM_OF_BUFFER_MA-1];
        //上にPO中
        if(f>m && m>s){
            po = 1;
        //下にPO中
        }else if(f<m && m<s){
            po = -1;
        //なし
        }else{
            po = 0;
        }
        
        if(pre_po != po){
            if(po ==1){
                flag_po_0_to_up=true;
               printf("★上のパーフェクトオーダー　Start");
            }
            else if(po==-1){
                flag_po_0_to_dn=true;
               printf("★下のパーフェクトオーダー　Start");
            }
            else if(po == 0){
               if(pre_po==1){
                   flag_po_up_to_0=true;
                  printf("★上のパーフェクトオーダー　End");
               }
               else if(pre_po==-1){
                   flag_po_dn_to_0=true;
                  printf("★下のパーフェクトオーダー　End");
               }
            
            }
        }

        //現在がPO中か判断→PO 後
        //PO配をずらす（左へ）
        //データ左つめで移動・一番右に計算したものを格納						
        for(i = 1 ;i<NUM_OF_BUFFER_PO;i++){
            POs[i-1]=POs[i];
        }
        //今回値を設定
        POs[NUM_OF_BUFFER_PO-1]=po;
        if(po_count<NUM_OF_BUFFER_PO){po_count++;}
        pre_po = po;
    }

//データ利用		
	//MAの値を取得　　MAオブジェクトidxを指定　　　　　：　ｆ=0ｍ=1ｓ=3ｓｓ=・・・ 指定して現在oｒ何個目かをとる	
    bool	get_ma(int ma_idx, int idx,double &out_data){//idx指定でmaを取得　　Input para:ma_idxはMAオブジェクトのインデックス、idx:最新0,1がその次に新しい。戻り値成功失敗。
        bool ret = false;
        if(ma_idx >= NUM_OF_CHAILD_MA){return false;}
        if(MApfs[ma_idx]!=NULL){
            ret = MApfs[ma_idx].get_ma(idx,out_data);
        }
        return ret;
    }							


    bool	get_ma(int ma_idx, double now_value,double &out_data //現在値渡して、現在のmaを計算	        Input para: ma_idxはMAオブジェクトのインデックス、最新値、出力変数
    ,double &v[],int maxidx,int count       //確定足が入った配列、配列の最後の要素idx（最新データ）、データの数    追加データは　配列サイズ-1に入っている。
    ){
        bool ret = false;
        if(ma_idx >= NUM_OF_CHAILD_MA){return false;}
        if(MApfs[ma_idx]!=NULL){
            ret = MApfs[ma_idx].get_ma(now_value,out_data,v,maxidx,count);
        }
        return ret;
    }
    //PO状態取得
    bool is_po_dn(){
        if(POs[NUM_OF_BUFFER_PO-1]==-1){
            return true;
        }
        return false;
    }
    bool is_po_up(){
        if(POs[NUM_OF_BUFFER_PO-1]==1){
            return true;
        }
        return false;
    }
    int get_status_po(){
        return(POs[NUM_OF_BUFFER_PO-1]);
    }
    //フラグ
    // 各フラグ参照
    // flag_po_0_to_dn
    // flag_po_0_to_up
    // flag_po_dn_to_0
    // flag_po_up_to_0



};
#endif// classMA_torimatome1
