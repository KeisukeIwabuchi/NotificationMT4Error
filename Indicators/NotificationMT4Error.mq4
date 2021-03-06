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


int    log_count = 0;
string last_log_file = "";
bool   is_first = true;


int OnInit()
{
   if(!FolderCreate("NotificationMT4Error")) {
      return(INIT_FAILED);
   }
   
   EventSetTimer(CheckInterval);
   OnTimer();
   is_first = false;
   
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
   string log_file = getLogFileName(); 
   string log_path = data_path + "\\MQL4\\Logs\\" + log_file;
   string destination = data_path + "\\MQL4\\Files\\NotificationMT4Error\\" + log_file;

   if(log_file != last_log_file) {
      last_log_file = log_file;
      log_count = 0;
   }

   if(!CopyFileW(log_path, destination, false)) {
      return;
   }
   
   string rows[]; 
   string body = "";
   Read("NotificationMT4Error\\" + log_file, rows);
   
   for(int i = ArraySize(rows) - 1; i >= log_count; i--) {
      if(StringSubstr(rows[i], 0, 1) == "1") {
         body += rows[i] + "\n";
      }
   }
   
   if(!is_first && StringLen(body) > 0) {
      SendMail("Notification MT4 Error", body);
   }
   
   log_count = ArraySize(rows);
   
   FileDelete("NotificationMT4Error\\" + log_file);
}


void OnDeinit(const int reason)
{
   Comment("");
   EventKillTimer();
}


string getLogFileName()
{
   string name = "";
   
   name  = IntegerToString(Year());
   name += ZeroPadding(Month());
   name += ZeroPadding(Day());
   name += ".log";
   
   return(name);
}


string ZeroPadding(int value)
{
   if(value < 10) {
      return("0" + IntegerToString(value));
   }
   return(IntegerToString(value));
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
