#ifndef classMA_torimatome1
#define classMA_torimatome1
#include "MApf.mqh"
#include "../../class_candle_data.mqh"

//debug opt
#define USE_debug_view_torimatome1

//
class MA_torimatome1
{
public:
    // ①all candle作成後、ベースのcandledataを対象に作成し、その後、MAを登録（０１２はPMO用、3以降は自由）          //p_MA_torimatome1,
    //　②ベースの足確定のところに次の通知を追加　add_new_bar_calc(double &v[],int maxidx,int count)
    //　③データ利用は、①のオブジェクト経由でMA,POを取得する
    candle_data *m_c;
    #define NUM_OF_BUFFER_PO 300
    //#define NUM_OF_POs 300
    double POs[NUM_OF_BUFFER_PO];//  idx[0]が一番古い、     前回値、前々回、前々々回　　　　　値：上にPO中1、下にPO中-1　、崩れた0
    int po_count;  
    double pre_po;

    bool flag_po_0_to_dn;//パーフェクトオーダー上になった                           （足確定時に更新：add_new_bar_calc）
    bool flag_po_0_to_up;//パーフェクトオーダー下になった                           （足確定時に更新：add_new_bar_calc）
    bool flag_po_dn_to_0;//パーフェクトオーダー下の状態から、そうでない状態になった     （足確定時に更新：add_new_bar_calc）
    bool flag_po_up_to_0;//パーフェクトオーダー上の状態から、そうでない状態になった     （足確定時に更新：add_new_bar_calc）

	//--- コンストラクタとデストラクタ
	MA_torimatome1(void){};
    #define NUM_OF_CHAILD_MA 5
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
            MApf *MApfs[NUM_OF_CHAILD_MA];


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
               debug_printf("★上のパーフェクトオーダー　Start");
            }
            else if(po==-1){
                flag_po_0_to_dn=true;
               debug_printf("★下のパーフェクトオーダー　Start");
            }
            else if(po == 0){
               if(pre_po==1){
                   flag_po_up_to_0=true;
                  debug_printf("★上のパーフェクトオーダー　End");
               }
               else if(pre_po==-1){
                   flag_po_dn_to_0=true;
                  debug_printf("★下のパーフェクトオーダー　End");
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
    bool is_po_dn_edge(){
        if(POs[NUM_OF_BUFFER_PO-1]==-1&& POs[NUM_OF_BUFFER_PO-1-1]!=-1&&po_count>3){
            return true;
        }
        return false;
    }
    bool is_po_up_edge(){
        if(POs[NUM_OF_BUFFER_PO-1]==1&& POs[NUM_OF_BUFFER_PO-1-1]!=1&&po_count>3){
            return true;
        }
        return false;
    }
    bool is_po(){
        if(POs[NUM_OF_BUFFER_PO-1]==1||POs[NUM_OF_BUFFER_PO-1]==-1){
            return true;
        }
        return false;
    }
    int get_status_po(){
        return(POs[NUM_OF_BUFFER_PO-1]);
    }
    //int get_po_count(){
    //    return(PO_count);
    //}
    //フラグ
    // 各フラグ参照
    // flag_po_0_to_dn
    // flag_po_0_to_up
    // flag_po_dn_to_0
    // flag_po_up_to_0

    int get_near_idx_po_start_end(int &idx_s,int &idx_e,int &po_type){//直近Poの開始と終了idxを得る。PO中ならStartのみ、POでない場合は、過去のｓとe。
        //戻り値：０以外は、idx_sは意味あるものとなっている。
            //　PO期間がなかった:0    見つからなかった
            //  ない状態からPoを期間を見つけた
            //        ｓ、e見つけた           1
            //        ｓはみつけられなかった      2
            //　初めからPOでstartが見つかった： 3
            //  初めからPOでstartがみつからなかった： 4
        int iret = 0;
        //初めの処理
        idx_s=0;idx_e=NUM_OF_BUFFER_PO-1;
        int flag_last_PO  =POs[NUM_OF_BUFFER_PO-1];
        
        int search_type =0;
        po_type=0;
        if(POs[NUM_OF_BUFFER_PO-1]==0){
            search_type=0;//startとendを探す
        }else{
            search_type=1;//startのみ探す
        }
        po_type=POs[NUM_OF_BUFFER_PO-1];

        int seqno=search_type;
        bool flag_finded_start = false;
        bool flag_finded_end = false;
        for(int i=NUM_OF_BUFFER_PO-1;i>0;i--){
            //endを探す
            if(seqno==0){
                if(POs[i]!=POs[i-1]){
                    //変化ありなので po記憶
                    po_type=POs[i-1];
                    idx_e = i-1;
                    flag_finded_end =true;
                    seqno++;
                }
            }else if(seqno==1){
                //startを探す
                if(POs[i]!=POs[i-1]){
                    //変化ありなので po記憶
                    idx_s = i;
                    flag_finded_start =true;
                    break;
                }
            }
        }
        if(search_type==0 ){
            if(flag_finded_end ==false){
                //Po見つからない
                iret=0;
            }else if(flag_finded_start == false){
                //Poがずっとつずいているので、一番古いものを渡す
                iret=2;
            }else {
                //両方見つかった
                iret=1;
            }
        }else if(search_type==1){
            if(flag_finded_start == false){
                //Poがずっとつずいているので、一番古いものを渡す
                iret = 4;
            }else {
                //start見つかった、endはない。
                iret = 3;
            }            
        }
        return iret;
    }
    bool get_near_po_tyouten(double &tyouten_v,int &idx,int &po_type){//Po中の頂点,idxを取得する（PO上なら一番大きい値）
        //戻り値　取得できたtrue,　　できないfalse
        bool bret=false;
        int idx_s=0,idx_e=0;
        int iret=0;
        iret = get_near_idx_po_start_end(idx_s,idx_e,po_type);

        if(iret == true  && m_c !=NULL ){
            double value;
            value = m_c.close[idx_e];idx=idx_e;//初期値
            for(int i=idx_e;i>=idx_s;i--){
                double tmp_v=m_c.close[i];
                if(po_type==1){
                    //max　さがす
                    if(tmp_v>value){value = tmp_v;idx=i;}
                }else if(po_type ==0){
                    //min　さがす
                    if(tmp_v<value){value = tmp_v;idx=i;}
                }
            }
            bret = true;
        }else{
            //bret = false;
        }
        return bret;
    }

    void debug_printf(string s){
    #ifdef USE_debug_view_torimatome1
        printf(s);
    #endif//USE_debug_view_torimatome1
    }

};
#endif// classMA_torimatome1
