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
   bool MoveFileExW(string &lpExistingFileName,
                    string &lpNewFileName,
                    int     dwFlags);
#import


#define MOVEFILE_REPLACE_EXISTING 0x1


/** Method of FileOpen */
enum FILE_OPEN
{
   READ  = 0,
   WRITE = 1
};


/** Class for file operation. */
class File
{
   public:
      static bool   MoveEx(string path, string destination);
      static string Read(const string path);
      
   private:
      static int  openHandle(const string path, 
                             const FILE_OPEN type = WRITE);
      static void closeHandle(const int handle);
};


/**
 * Reads a string from a file.
 * In case of failure returns empty string.
 *
 * @param const string path  File name.
 *
 * @return string  Read text(string).
 */
static string File::Read(const string path)
{
   int    str_size;
   string result = "";
   int    handle = File::openHandle(path, READ);
   int    count  = 0;

   if(handle == INVALID_HANDLE) return("");
      
   while(!FileIsEnding(handle)) {
      if(count > 0) result   += "\n";
      
      str_size  = FileReadInteger(handle, INT_VALUE);
      result   += FileReadString(handle, str_size);
      count++;
   }
   
   File::closeHandle(handle);
   
   return(result);
}


/**
 * Moves a file.
 *
 * @param string path         File name to move/rename.
 * @param string destination  File name after operation.
 *
 * @return bool  Returns true if successful, otherwise false.
 */
static bool File::MoveEx(string path, string destination)
{
   return(MoveFileExW(path, destination, MOVEFILE_REPLACE_EXISTING));
}


/**
 * Opnes the file and returns the file handle.
 * In case of failure returns INVALID_HANDLE(= -1).
 *
 * @param const string path     File name.
 * @param const FILE_OPEN type  Method of file open.
 *  WRITE: FILE_WRITE|FILE_CSV
 *  READ:  FILE_READ|FILE_CSV
 *
 * @return int  Returns the file handle.
 */
static int File::openHandle(const string path, 
                            const FILE_OPEN type = WRITE)
{
   int handle = INVALID_HANDLE;
   
   switch(type) {
      case READ:
         handle = FileOpen(path, FILE_READ|FILE_CSV);
         break;
      case WRITE:
         handle = FileOpen(path, FILE_WRITE|FILE_CSV);
         break;
   }
   
   return(handle);
}


/**
 * Close the file previously opened by FileOpen().
 *
 * @param const int handle  File descriptor returned by FileOpen().
 */
static void File::closeHandle(const int handle)
{
   if(handle != INVALID_HANDLE) FileClose(handle);
}


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
   string log_file = data_path + "\\MQL4\\Logs\\20171213.log";
   string destination = data_path + "\\MQL4\\Files\\NotificationMT4Error\\20171213.log";
   
   if(!File::MoveEx(log_file, destination)) {
      return;
   }
   
   string body = File::Read("NotificationMT4Error\\20171213.log");
   Comment(body);
   
   if(File::MoveEx(destination, log_file)) {
      Print("Success");
   } else {
      Print("Fail");
   }
}


void OnDeinit(const int reason)
{
   Comment("");
   EventKillTimer();
}
