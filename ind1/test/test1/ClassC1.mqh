#ifndef classC1_m
#define classC1_m
#include"ClassC.mqh"
class classC1 :public classC
{
public:
   //string name;
	//--- コンストラクタとデストラクタ
	classC1(void){		printf("classC1 コンストラクタ　デフォルト");};
	classC1(string s){name = s;
		//init_mem_hyouka_data();
		printf("classC1 コンストラクタ　特別引数あり");
	};
	~classC1(void){printf("classC1 end");};
	//--- オブジェクトを初期化する

    //関数
	int		hyouka(void);//　評価・状態遷移含む処理


};

	int		classC1::hyouka(void)//　評価・状態遷移含む処理
	{
		printf("classC1 hyouka");
		return 0;
	}

#endif//classC1_m
