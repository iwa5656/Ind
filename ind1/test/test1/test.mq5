#property indicator_chart_window

#property indicator_buffers 10
#property indicator_plots   10

#include"ClassC.mqh"
#include"ClassC1.mqh"
#include"ClassC2.mqh"

#include"..\..\classMethod_range.mqh"

classC *cc[3];
int testno;
void OnInit()
  {
    printf("【new classC】");
    cc[0]=new classC();
    printf("【new classC1】");
    cc[1]=new classC1();
    printf("【new classC2】");//基底クラスのコンストラクタも先に呼ばれる
    cc[2]=new classC2("special classC2");
    testno=0;
printf("Oninit");
  }

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
   if(testno==0){
      cc[0].hyouka();
      cc[1].hyouka();
      cc[2].hyouka();// ポインタの型のオブジェクトのメソッドを呼ぶ（　classC2が実態だが、ベースのhyouka関数が呼ばれる）
      
      classC2 *c=cc[2];// ポインタの代入はOK
      // cc[2].funcC2();   <-　ベースクラスで派生クラスの関数は呼べない
      c.funcC2();//ふさわしい型のポインタに入れるとOK
      
      
      c.hyouka();
      testno++;
   }
  
   return(rates_total);
  }
  
  
  
//+------------------------------------------------------------------+ 
//| エキスパート初期化解除に使用される関数                                    | 
//+------------------------------------------------------------------+ 
void OnDeinit(const int reason) 
  { 
//--- 初期化解除の理由のコード取得の方法その 1 
   Print(__FUNCTION__,"_Uninitalization reason code = ",reason); 
//--- 初期化解除の理由のコード取得の方法その 2  
   //Print(__FUNCTION__,"_UninitReason = ",getUninitReasonText(_UninitReason)); 
  }  


//+------------------------------------------------------------------+ 
//| 関数                                    | 
//+------------------------------------------------------------------+ 
//+------------------------------------------------------------------+ 
//| 登録                                    | 
//+------------------------------------------------------------------+ 
//+------------------------------------------------------------------+ 
//| 登録Add                                    | 
//+------------------------------------------------------------------+ 
