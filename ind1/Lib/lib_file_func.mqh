#ifndef _LIB_FILE_FUNC_
#define _LIB_FILE_FUNC_

int outfile_controle_count;    // 何個貯めたかカウント
int outfile_controle_per_num; //何個ごとに出力するか
string outfile_str;// 出力用文字列保持用

//oninit
void OnInit_file(void){
    outfile_controle_per_num= 1000; //何個ごとに出力するか  
    outfile_controle_count=outfile_controle_per_num;    // 何個貯めたかカウント
}
//ondeinit
void OnDeinit_file(void){
	//残りデータを出力
	outfile_controle_count=outfile_controle_per_num;
	test_writestring_file2("test_mesen_Candle2.csv","",true);
}
void OnCalculate_file(void){
	
}


void test_writestring_file2(string filename,string str,bool add)  //  表示文字列、　true　既存の文字のあとに追加、false　上書き（数が足りないと過去のものが残る）
{
   if(outfile_controle_count>= outfile_controle_per_num){
      outfile_controle_count=0;
      str = outfile_str+str;
      outfile_str="";
   }else{
      outfile_str = outfile_str+str;
      outfile_controle_count++;
      return;
   }

//ファイルの最後にStrに追加　改行は\r\nでOK
	//--- ファイルを開く 
	ResetLastError();
//	int file_handle=FileOpen(InpDirectoryName+"/"+InpFileName,FILE_READ|FILE_BIN|FILE_ANSI);
//	int file_handle=FileOpen("C:\\Users\\makoto\\AppData\\Roaming\\MetaQuotes\\terminal\\D0E8209F77C8CF37AD8BF550E51FF075\\MQL5\\Experts\\Data\\test.txt",FILE_READ|FILE_BIN|FILE_ANSI);
//	int file_handle=FileOpen("test.txt",FILE_READ|FILE_BIN|FILE_ANSI);
//	int file_handle=FileOpen("Data\\test.txt",FILE_READ|FILE_ANSI);
//	int file_handle=FileOpen("Data\\test.txt",FILE_WRITE |FILE_BIN|FILE_ANSI);
	int file_handle=FileOpen("Data\\"+filename,FILE_READ|FILE_WRITE |FILE_ANSI|FILE_TXT);
	if(file_handle!=INVALID_HANDLE)
    	{
//debug	  	PrintFormat("%s file is available for reading",filename);
//debug	  	PrintFormat("File path: %s\\Files\\",TerminalInfoString(TERMINAL_DATA_PATH));
	  	//--- 追加の変数
//	  	int	  str_size;
//	  	string str;
         string tmp;

if ( add== true){	  	
	  	//--- ファイルからデータを読む
	  	while(!FileIsEnding(file_handle))
		{
		        tmp=FileReadString(file_handle);

#ifdef aaa	  	
		      	//--- 時間を書くのに使用されるシンボルの数を見つける
		        str_size=FileReadInteger(file_handle,INT_VALUE);
		      	//--- 文字列を読む
		        str=FileReadString(file_handle,str_size);
		      	//--- 文字列を出力する
		      	PrintFormat(str);
#endif
		}
}		
//      str = (string)TimeCurrent();
//      str = str + "\t" + "test"+ "\r\ntest2";
//      FileSeek(file_handle,0, SEEK_END);
      FileWrite(file_handle,str);
      FileFlush(file_handle);
		//--- ファイルを閉じる
	  	FileClose(file_handle);
//debug	  	PrintFormat("Data is read, %s file is closed",filename);
    	}
	else
  	PrintFormat("Failed to open %s file, Error code = %d",filename,GetLastError());
}



void writestring_file(string filename,string str,bool add)  //  表示文字列、　true　既存の文字のあとに追加、false　上書き（数が足りないと過去のものが残る）
{


//ファイルの最後にStrに追加　改行は\r\nでOK
	//--- ファイルを開く 
	ResetLastError();
//	int file_handle=FileOpen(InpDirectoryName+"/"+InpFileName,FILE_READ|FILE_BIN|FILE_ANSI);
//	int file_handle=FileOpen("C:\\Users\\makoto\\AppData\\Roaming\\MetaQuotes\\terminal\\D0E8209F77C8CF37AD8BF550E51FF075\\MQL5\\Experts\\Data\\test.txt",FILE_READ|FILE_BIN|FILE_ANSI);
//	int file_handle=FileOpen("test.txt",FILE_READ|FILE_BIN|FILE_ANSI);
//	int file_handle=FileOpen("Data\\test.txt",FILE_READ|FILE_ANSI);
//	int file_handle=FileOpen("Data\\test.txt",FILE_WRITE |FILE_BIN|FILE_ANSI);
	int file_handle=FileOpen("Data\\"+filename,FILE_READ|FILE_WRITE |FILE_ANSI|FILE_TXT);
	if(file_handle!=INVALID_HANDLE)
    	{
//debug	  	PrintFormat("%s file is available for reading",filename);
//debug	  	PrintFormat("File path: %s\\Files\\",TerminalInfoString(TERMINAL_DATA_PATH));
	  	//--- 追加の変数
//	  	int	  str_size;
//	  	string str2;
         string tmp;
        string sss="";  	

if ( add== true){	
	  	//--- ファイルからデータを読む-> 最後まで進める。
	  	while(!FileIsEnding(file_handle))
		{
		        tmp=FileReadString(file_handle);
//                sss=sss+tmp;
//#define aaa                
#ifdef aaa	  	
		      	//--- 時間を書くのに使用されるシンボルの数を見つける
		        str_size=FileReadInteger(file_handle,INT_VALUE);
		      	//--- 文字列を読む
		        str2=FileReadString(file_handle,str_size);
		      	//--- 文字列を出力する
		      	PrintFormat(str2);
#endif
		}
}		
//      str = (string)TimeCurrent();
//      str = str + "\t" + "test"+ "\r\ntest2";
//      FileSeek(file_handle,0, SEEK_END);
      FileWrite(file_handle,str);
      FileFlush(file_handle);
		//--- ファイルを閉じる
	  	FileClose(file_handle);
//debug	  	PrintFormat("Data is read, %s file is closed",filename);
    	}
	else
  	PrintFormat("Failed to open %s file, Error code = %d",filename,GetLastError());
}


#endif//_LIB_FILE_FUNC_
