#ifndef classC1_m
#define classC1_m
#include"ClassC.mqh"
#include"ClassC1.mqh"
#include"ClassC2.mqh"
#include"ClassD.mqh"
#include"ClassAll.mqh"


class classC1 :public classC
{
public:
   classD *cd_atc1;
   classC *cc_atc1;
   classC1 *cc1_atc1;
   classC2 *cc2_atc1;
   classAll *cc3_atcc1;
   
   
   //string name;
	//--- コンストラクタとデストラクタ
	classC1(void){		printf("classC1 コンストラクタ　デフォルト");};
	classC1(string s){name = s;
		//init_mem_hyouka_data();
		printf("classC1 コンストラクタ　特別引数あり");
		cc3_atcc1 = new classAll();
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
