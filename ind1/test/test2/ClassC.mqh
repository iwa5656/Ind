#ifndef classC_m
//#define classC_m
#include"ClassC.mqh"
class classC   
{

//protected:
public:
   string name;
   int class_typeno;
   
	//--- コンストラクタとデストラクタ
	classC(void){		name = "classC";printf("classC コンストラクタ　デフォルト");};
	classC(string s){name = s;
		//init_mem_hyouka_data();
		printf("classC コンストラクタ　特別引数あり");
	};
	classC(string s,int n){name = s;class_typeno=n;
		//init_mem_hyouka_data();
		printf("classC コンストラクタ　特別引数あり");
	};	
	~classC(void){printf("classC end");};
	//--- オブジェクトを初期化する

    //関数
     int		hyouka(void);//　評価・状態遷移含む処理
//	virtual  int		hyouka(void);//　評価・状態遷移含む処理


};

	int		classC::hyouka(void)//　評価・状態遷移含む処理
	{
		printf("classC hyouka"+" :"+name+":"+IntegerToString(class_typeno));
		
		return 0;
	}




#endif//classC_m
