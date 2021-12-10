#ifndef classC2_m
#define classC2_m
#include"ClassC.mqh"
class classC2 :public classC
{
public:
   //string name;
	//--- コンストラクタとデストラクタ
	classC2(void){		printf("classC2 コンストラクタ　デフォルト");};
	classC2(string s){name = s;
		//init_mem_hyouka_data();
		printf("classC2 コンストラクタ　特別引数あり");
	};
	~classC2(void){printf("classC2 end");};
	//--- オブジェクトを初期化する

    //関数
	int		hyouka(void);//　評価・状態遷移含む処理
   void funcC2(void){printf("classC2 call funcC2");}

};

	int		classC2::hyouka(void)//　評価・状態遷移含む処理
	{
		printf("classC2 hyouka");
		return 0;
	}

#endif//classC2_m
