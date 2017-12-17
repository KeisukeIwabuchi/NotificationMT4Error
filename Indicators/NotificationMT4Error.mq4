//+------------------------------------------------------------------+
//|                                         NotificationMT4Error.mq4 |
//|                                 Copyright 2017, Keisuke Iwabuchi |
//|                                         http://order-button.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Keisuke Iwabuchi"
#property link      "http://order-button.com/"
#property version   "1.00"
#property strict
#property indicator_chart_window


#define OBJ_NAME "CsutomIndicatorCheckerVLine"


#import "Kernel32.dll"
   bool CopyFileW(string lpExistingFileName, // 既存のファイルの名前
                 string lpNewFileName,      // 新しいファイルの名前
                 bool   bFailIfExists);     // ファイルが存在する場合の動作
#import


sinput int CheckInterval = 300; // CheckInterval(sec)


int OnInit()
{
   if(!FolderCreate("NotificationMT4Error")) {
      return(INIT_FAILED);
   }
   
   EventSetTimer(CheckInterval);
   OnTimer();
   
   return(INIT_SUCCEEDED);
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
                const int &spread[])
{
   return(rates_total);
}


void OnTimer()
{
   string data_path = TerminalInfoString(TERMINAL_DATA_PATH);
   string log_file = data_path + "\\MQL4\\Logs\\20171215.log";
   string destination = data_path + "\\MQL4\\Files\\NotificationMT4Error\\20171215.log";
   
   if(!CopyFileW(log_file, destination, false)) {
      return;
   }
   
   string rows[]; 
   string body = "";
   Read("NotificationMT4Error\\20171215.log", rows);
   
   for(int i = 0; i < ArraySize(rows); i++) {
      body = rows[i] + "\n" + body;
   }
   Comment(body);
}


void OnDeinit(const int reason)
{
   Comment("");
   EventKillTimer();
}


void Read(const string path, string &rows[])
{
   int    str_size;
   int    handle = FileOpen(path, FILE_READ|FILE_CSV);
   int    count  = 0;

   if(handle == INVALID_HANDLE) return;
      
   while(!FileIsEnding(handle)) {
      str_size  = FileReadInteger(handle, INT_VALUE);
      ArrayResize(rows, count + 1);
      rows[count] = FileReadString(handle, str_size);
      count++;
   }
   
   if(handle != INVALID_HANDLE) FileClose(handle);
}
