#ifndef classAll_m
#define classAll_m
#include"ClassC.mqh"
#include"ClassC1.mqh"
//#include"ClassC2.mqh"
//#include"ClassD.mqh"

class classAll 
{
protected:


public:
   classAll *pre;
   //#undef ClassC_m
   //#include"ClassC.mqh"   
   classC *pc_atall1;
   //classC1 *pc_atall11;
//   ClassC1 *pc1_atall;
   //ClassC2 *pc2_atall;
   //classD *pD_atall;
   //classC1 *c1_atall;
   string name;
	//--- コンストラクタとデストラクタ
	classAll(void){		printf("classAll コンストラクタ　デフォルト");};
	classAll(string s){name = s;
		//init_mem_hyouka_data();
		printf("classAll コンストラクタ　特別引数あり");
	};
	~classAll(void){printf("classAll end");};
	//--- オブジェクトを初期化する

    //関数
	int		hyouka(void);//　評価・状態遷移含む処理
   void funcC2(void){printf("classAll call funcC2");}

};

	int		classAll::hyouka(void)//　評価・状態遷移含む処理
	{
	   classC1 *c11;
	   c11.hyouka();
		printf("classAll hyouka");
		return 0;
	}

#endif//classAll_m
