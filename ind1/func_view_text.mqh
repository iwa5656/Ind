#ifdef delll
    #property description "Script creates \"Text\" graphical object."
    //--- スクリプトの起動時に入力パラメータのウィンドウを表示する
    #property script_show_inputs
    //--- スクリプト入力パラメータ
    input string           InpFont="Arial";         // フォント
    input int               InpFontSize=10;         // フォントサイズ
    input color             InpColor=clrRed;         // 色
    input double           InpAngle=90.0;           // 傾斜角度
    input ENUM_ANCHOR_POINT InpAnchor=ANCHOR_LEFT;   // アンカーの種類
    input bool             InpBack=false;           // 背景オブジェクト
    input bool             InpSelection=false;     // 強調表示して移動
    input bool             InpHidden=true;         // オブジェクトリストに隠す
    input long             InpZOrder=0;             // マウスクリックの優先順位
#endif //dell    

//+------------------------------------------------------------------+
//| テキストオブジェクトを作成する                                             |
//+------------------------------------------------------------------+
bool TextCreate(const long              chart_ID=0,               // チャート識別子
              const string            name="Text",             // オブジェクト名
              const int               sub_window=0,             // サブウィンドウ番号
              datetime                time=0,                   // アンカーポイントの時刻
              double                  price=0,                 // アンカーポイントの価格
              const string            text="Text",             // テキスト
              const string            font="Arial",             // フォント
              const int               font_size=10,             // フォントサイズ
              const color             clr=clrRed,               // 色
              const double            angle=0.0,               // テキストの傾斜
              const ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT_UPPER, // アンカーの種類
              const bool              back=false,               // 背景で表示する
              const bool              selection=false,         // 強調表示して移動
              const bool              hidden=true,             // ブジェクトリストに隠れている
              const long              z_order=0)               // マウスクリックの優先順位
 {
//--- 設定されてない場合アンカーポイントの座標を設定する
  ChangeTextEmptyPoint(time,price);
//--- エラー値をリセットする
  ResetLastError();
//--- テキストオブジェクトを作成する
  if(!ObjectCreate(chart_ID,name,OBJ_TEXT,sub_window,time,price))
    {
    Print(__FUNCTION__,
          ": failed to create \"Text\" object! Error code = ",GetLastError());
    return(false);
    }
//--- テキストを設定する
  ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
//--- テキストフォントを設定する
  ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
//--- フォントサイズを設定する
  ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
//--- テキストの傾斜を設定する
  ObjectSetDouble(chart_ID,name,OBJPROP_ANGLE,angle);
//--- アンカーの種類を設定
  ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor);
//--- 色を設定
  ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- 前景（false）または背景（true）に表示
  ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- マウスでオブジェクトを移動させるモードを有効（true）か無効（false）にする
  ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
  ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- オブジェクトリストのグラフィックオブジェクトを非表示（true）か表示（false）にする
  ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- チャートのマウスクリックのイベントを受信するための優先順位を設定する
  ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- 実行成功
  return(true);
 }
//+------------------------------------------------------------------+
//| アンカーポイントを移動する                                               |
//+------------------------------------------------------------------+
bool TextMove(const long   chart_ID=0, // チャート識別子
            const string name="Text", // オブジェクト名
            datetime     time=0,     // アンカーポイントの時間座標
            double       price=0)     // アンカーポイントの価格座標
 {
//--- ポイントの位置が設定されていない場合、売値を有する現在足に移動する
  if(!time)
     time=TimeCurrent();
  if(!price)
     price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- エラー値をリセットする
  ResetLastError();
//--- アンカーポイントを移動する
  if(!ObjectMove(chart_ID,name,0,time,price))
    {
    Print(__FUNCTION__,
          ": failed to move the anchor point! Error code = ",GetLastError());
    return(false);
    }
//--- 実行成功
  return(true);
 }
//+------------------------------------------------------------------+
//| オブジェクトのテキストを変更する                                            |
//+------------------------------------------------------------------+
bool TextChange(const long   chart_ID=0, // チャート識別子
              const string name="Text", // オブジェクト名
              const string text="Text") // テキスト
 {
//--- エラー値をリセットする
  ResetLastError();
//--- オブジェクトのテキストを変更する
  if(!ObjectSetString(chart_ID,name,OBJPROP_TEXT,text))
    {
    Print(__FUNCTION__,
          ": failed to change the text! Error code = ",GetLastError());
    return(false);
    }
//--- 実行成功
  return(true);
 }
//+------------------------------------------------------------------+
//| テキストオブジェクトを削除する                                             |
//+------------------------------------------------------------------+
bool TextDelete(const long   chart_ID=0, // チャート識別子
              const string name="Text") // オブジェクト名
 {
//--- エラー値をリセットする
  ResetLastError();
//--- オブジェクトを削除する
  if(!ObjectDelete(chart_ID,name))
    {
    Print(__FUNCTION__,
          ": failed to delete \"Text\" object! Error code = ",GetLastError());
    return(false);
    }
//--- 実行成功
  return(true);
 }
//+------------------------------------------------------------------+
//| アンカーポイントの値をチェックして                                           |
//| 空の物には初期値を設定する                                             |
//+------------------------------------------------------------------+
void ChangeTextEmptyPoint(datetime &time,double &price)
 {
//--- ポイントの時間が設定されていない場合、現在足になる
  if(!time)
     time=TimeCurrent();
//--- ポイントの価格が設定されていない場合、売値になる
  if(!price)
     price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
 }
#ifdef delll 
//+------------------------------------------------------------------+
//| スクリプトプログラムを開始する関数                                          |
//+------------------------------------------------------------------+
void OnStart()
 {
  datetime date[]; // 表示中のバーの日付を格納するための配列
  double   low[]; // 表示中の足の安値を格納するための配列
  double   high[]; // 表示中の足の高値を格納するための配列
//--- チャートウィンドウで表示されているバーの数
  int bars=(int)ChartGetInteger(0,CHART_VISIBLE_BARS);
//--- メモリ割り当て
  ArrayResize(date,bars);
  ArrayResize(low,bars);
  ArrayResize(high,bars);
//--- 日付配列に書き込む
  ResetLastError();
  if(CopyTime(Symbol(),Period(),0,bars,date)==-1)
    {
    Print("Failed to copy time values! Error code = ",GetLastError());
    return;
    }
//--- 安値の配列に書き込む
  if(CopyLow(Symbol(),Period(),0,bars,low)==-1)
    {
    Print("Failed to copy the values of Low prices! Error code = ",GetLastError());
    return;
    }
//--- 高値の配列に書き込む
  if(CopyHigh(Symbol(),Period(),0,bars,high)==-1)
    {
    Print("Failed to copy the values of High prices! Error code = ",GetLastError());
    return;
    }
//--- テキスト表示の頻度を定義する
  int scale=(int)ChartGetInteger(0,CHART_SCALE);
//--- ステップを定義する
  int step=1;
  switch(scale)
    {
    case 0:
        step=12;
        break;
    case 1:
        step=6;
        break;
    case 2:
        step=4;
        break;
    case 3:
        step=2;
        break;
    }
//--- 高値と安値のバーの値のテキストを作成する（ギャップで）
  for(int i=0;i<bars;i+=step)
    {
    //--- テキストを作成する
    if(!TextCreate(0,"TextHigh_"+(string)i,0,date[i],high[i],DoubleToString(high[i],5),InpFont,InpFontSize,
        InpColor,InpAngle,InpAnchor,InpBack,InpSelection,InpHidden,InpZOrder))
       {
        return;
       }
    if(!TextCreate(0,"TextLow_"+(string)i,0,date[i],low[i],DoubleToString(low[i],5),InpFont,InpFontSize,
        InpColor,-InpAngle,InpAnchor,InpBack,InpSelection,InpHidden,InpZOrder))
       {
        return;
       }
    //--- スクリプトの動作が強制的に無効にされているかどうかをチェックする
    if(IsStopped())
        return;
    //--- チャートを再描画する
    ChartRedraw();
    // 0.05 秒の遅れ
    Sleep(50);
    }
//--- 半秒の遅れ
  Sleep(500);
//--- テキストを削除する
  for(int i=0;i<bars;i+=step)
    {
    if(!TextDelete(0,"TextHigh_"+(string)i))
        return;
    if(!TextDelete(0,"TextLow_"+(string)i))
        return;
    //--- チャートを再描画する
    ChartRedraw();
    // 0.05 秒の遅れ
    Sleep(50);
    }
//---
 }
 #endif//delll


 void view_kachi_make_cancel(int kind,datetime t,double p,string n,double pips){
    //kind 1勝　-1負け  0キャンセル
    string name1;
    string objname1;
    string text;
    int font_size = 10;
    color clr=clrRed;
    if(kind==1){
        //勝
        text="勝:"+DoubleToString(pips,0)+" pips";
        clr = clrYellow;
    }else if(kind==-1){
        //負け
        text="負:"+DoubleToString(pips,0)+" pips";
        clr = clrRed;
    }else if(kind==0){
        //負け
        text="キャンセル";
        clr = clrWhite;
    }
    objname1= "tpsl:"+n;
    TextCreate(0,objname1,0,t,p,text,"Arial",font_size,clr);
}