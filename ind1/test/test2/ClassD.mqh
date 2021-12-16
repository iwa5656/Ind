#ifndef classD_m
//#define classD_m
#include"ClassC.mqh"
#include"ClassC1.mqh"

class classD :public classC
{
protected:

public:
   
   //classC1 *c1;
   //string name;
	//--- コンストラクタとデストラクタ
	classD(void){		printf("classD コンストラクタ　デフォルト");};
	classD(string s){name = s;
		//init_mem_hyouka_data();
		printf("classD コンストラクタ　特別引数あり");
	};
	~classD(void){printf("classD end");};
	//--- オブジェクトを初期化する

    //関数
	int		hyouka(void);//　評価・状態遷移含む処理
   void funcC2(void){printf("classD call funcC2");}

};

	int		classD::hyouka(void)//　評価・状態遷移含む処理
	{
	   classC1 *c11;
	   c11.hyouka();
		printf("classD hyouka");
		return 0;
	}

#endif//classD_m
