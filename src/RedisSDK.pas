unit RedisSDK;

interface

uses Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  QSimplePool, qstring, Forms;

type
  TRedisLogLevel = (llEmergency, llAlert, llFatal, llError, llWarning, llHint,
    llMessage, llDebug);
  TstatusCmdCallback = procedure(redisClient, params: Pointer; CmdResult: PChar;
    IsErrResult: Boolean); stdcall;
  TLogProc = procedure(Data: Pointer; logLevel: Integer;
    logMsg: PChar); stdcall;
  // 如果resultLen>0就是PByte
  TStringCmdCallback = procedure(redisClient, params: Pointer;
    CmdResult: Pointer; resultLen: Integer; IsErrResult: Boolean); stdcall;
  TScanCmdCallback = procedure(redisClient, params: Pointer; keys: PChar;
    cursor: Int64; IsErrResult: Boolean); stdcall;
  TIntCmdCallBack = procedure(redisClient, params: Pointer; intResult: Int64;
    errMsg: PChar); stdcall;
  //管道执行回调
  TPipeExecCallBack = procedure(pipeClient,params: Pointer;errMsg: PChar);stdcall;

  TRedisSDKData = record
    MangData: Pointer;
    // statusCmdCallBack: TstatusCmdCallback;
    LogProc: TLogProc;
  end;

  PRedisSDKData = ^TRedisSDKData;

  TRedisConStyle = (RedisConSingle, // 单台连接
    RedisConSentinel, // 哨兵模式
    RedisConCluster // 集群模式
    );

  TRedisConfig = record
    ConStyle: TRedisConStyle;
    ClientData: Pointer;
    Data: Pointer;
  end;

  PRedisConfig = ^TRedisConfig;

  // 单机模式配置
  TRedisSingleCfg = record
    Network: PChar; // tcp utf8
    Addr: PChar;
    Username: PChar;
    Password: PChar;
    DBIndex: Byte;
    MaxRetries: Byte;
    DialTimeout: Byte;
    ReadTimeout: Byte;
    WriteTimeout: Byte;
  end;

  PRedisSingleCfg = ^TRedisSingleCfg;

  // 哨兵支持主从切换的配置
  TRedisSentinelCfg = record
    MasterName: PChar; // 主服务名
    SentinelAddrs: PChar; // 哨兵服务地址 ;分割
    Password: PChar;
    DBIndex: Byte;
    MaxRetries: Byte;
    DialTimeout: Byte;
    ReadTimeout: Byte;
    WriteTimeout: Byte;
  end;

  PRedisSentinelCfg = ^TRedisSentinelCfg;

  TWndMsgCmd = (MC_Log, MC_StatusCmd, MC_ScanCmd, MC_SelectScan, MC_StringCmd,
    MC_IntCmd,MC_pipeCmd,MC_BoolCmd);

  PSynWndMessageItem = ^TSynWndMessageItem;

  TSynWndMessageItem = record
    Cmd: TWndMsgCmd;
    params: Pointer;
    Next: PSynWndMessageItem;
  end;

  TValueInterface = record
    ValueLen: Integer;
    Value: Pointer;
  end;

  PValueInterface = ^TValueInterface;

  TRedisKeyValue = record
    Key: PChar;
    Value: TValueInterface;
  end;

  PRedisKeyValue = ^TRedisKeyValue;

  TBitCount = record
    Start, EndB: Int64;
  end;

  PBitCount = ^TBitCount;

  TDxRedisSdkManager = class;
  TRedisStatusCmd = procedure(Sender: Tobject; CmdResult: string;
    IsErrResult: Boolean) of Object;
  TRedisStatusCmdA = reference to procedure(CmdResult: string;
    IsErrResult: Boolean);
  PRedisStatusCmdA = ^TRedisStatusCmdA;
  TRedisStatusCmdG = procedure(CmdResult: string; IsErrResult: Boolean);

  TRedisScanCmdReturn = procedure(Sender: Tobject; keys: array of string;
    cursor: UInt64; errMsg: string) of object;
  TRedisScanCmdReturnA = reference to procedure(keys: array of string;
    cursor: UInt64; errMsg: string);
  PRedisScanCmdReturnA = ^TRedisScanCmdReturnA;
  TRedisScanCmdReturnG = procedure(keys: array of string; cursor: UInt64;
    errMsg: string);

  TRedisSelectScanCmdReturn = procedure(Sender: Tobject; DBIndex: Integer;
    keys: array of string; cursor: Int64; errMsg: string) of object;
  TRedisSelectScanCmdReturnA = reference to procedure(DBIndex: Integer;
    keys: array of string; cursor: Int64; errMsg: string);
  PRedisSelectScanCmdReturnA = ^TRedisSelectScanCmdReturnA;
  TRedisSelectScanCmdReturnG = procedure(DBIndex: Integer;
    keys: array of string; cursor: Int64; errMsg: string);

  TRedisStringCmdReturn = procedure(Sender: Tobject; CmdResult: string;
    IsErrResult: Boolean) of object;
  TRedisStringCmdReturnA = reference to procedure(CmdResult: string;
    IsErrResult: Boolean);
  PRedisStringCmdReturnA = ^TRedisStringCmdReturnA;
  TRedisStringCmdReturnG = procedure(CmdResult: string; IsErrResult: Boolean);

  TRedisStringCmdReturnByte = procedure(Sender: Tobject; resultBuffer: PByte;
    byteLen: Integer; errMsg: string) of object;
  TRedisStringCmdReturnByteA = reference to procedure(resultBuffer: PByte;
    byteLen: Integer; errMsg: string);
  PRedisStringCmdReturnByteA = ^TRedisStringCmdReturnByteA;
  TRedisStringCmdReturnByteG = procedure(resultBuffer: PByte; byteLen: Integer;
    errMsg: string);

  TIntCmdReturn = procedure(Sender: Tobject; intResult: Int64; errMsg: string)
    of object;
  TIntCmdReturnA = reference to procedure(intResult: Int64; errMsg: string);
  PIntCmdReturnA = ^TIntCmdReturnA;
  TIntCmdReturnG = procedure(intResult: Int64; errMsg: string);

  TBoolCmdReturn = procedure(Sender: Tobject; returnResult: bool; errMsg: string)
    of object;
  TBoolCmdReturnA = reference to procedure(returnResult: bool; errMsg: string);
  PBoolCmdReturnA = ^TBoolCmdReturnA;
  TBoolCmdReturnG = procedure(returnResult: bool; errMsg: string);

  TPipelineExecReturn = procedure(Sender: TObject;ErrMsg: string) of object;
  TPipelineExecReturnA = reference to procedure(errMsg: string);
  PPipelineExecReturnA = ^TPipelineExecReturnA;
  TPipelineExecReturnG = procedure(ErrMsg: string);

  TKeyValue = record
    Key: string;
    Value: string;
  end;
  TSetArgModeStyle = (smsNone, smsNx, smsXX);

  TsetArgs = record
    style: TSetArgModeStyle;
    get: Boolean;
    keepTTl: Boolean;
    ttl: Byte;
    ExpireAt: TDateTime;
  end;

  PsetArgs = ^TsetArgs;

  TLPosArgs = record
    Rank, MaxLen: Int64;
  end;

  PLPosArgs = ^TLPosArgs;

  TZValue = record
    Score: Float64;
    Member: Pointer;
    MemLen: Integer;
  end;

  PZValue = ^TZValue;

  TZStrValue = record
    Score: Float64;
    Member: string;
  end;

  TDxRedisClient = class
  private
    FRedisSdkManager: TDxRedisSdkManager;
    FConStyle: TRedisConStyle;
    FReadTimeout: Byte;
    FDialTimeout: Byte;
    FWriteTimeout: Byte;
    FDefaultDBIndex: Byte;
    FPassword: string;
    FUserName: string;
    FRedisClient: Pointer;
    FAddress: string;
    FMaxRetry: Byte;
    procedure SetRedisSdkManager(const Value: TDxRedisSdkManager);
    procedure SetConStyle(const Value: TRedisConStyle);
    procedure SetDefaultDBIndex(const Value: Byte);
    procedure SetDialTimeout(const Value: Byte);
    procedure SetPassword(const Value: string);
    procedure SetReadTimeout(const Value: Byte);
    procedure SetWriteTimeout(const Value: Byte);
    procedure SetUserName(const Value: string);
    procedure SetAddress(const Value: string);
    procedure SetMaxRetry(const Value: Byte);
  protected
    FRunningCount: Integer; // 正在执行的命令数量
    procedure InitRedisClient;
    procedure CloseRedisClient;
    function NewPipeline(isTxPipe: Boolean;Data: Pointer): Pointer;
    procedure FreePipeline(pipeClient: Pointer);
  public
    destructor Destroy; override;
{$REGION 'StatusCmd'}
    procedure Ping(block: Boolean; StatusCmdReturn: TRedisStatusCmd); overload;
    procedure Ping(block: Boolean; StatusCmdReturn: TRedisStatusCmdA); overload;
    procedure Ping(block: Boolean; StatusCmdReturn: TRedisStatusCmdG); overload;
    procedure Rename(Key, NewKey: string; block: Boolean;
      StatusCmdReturn: TRedisStatusCmd); overload;
    procedure Rename(Key, NewKey: string; block: Boolean;
      StatusCmdReturn: TRedisStatusCmdA); overload;
    procedure Rename(Key, NewKey: string; block: Boolean;
      StatusCmdReturn: TRedisStatusCmdG); overload;
    procedure Migrate(host, port, Key: string; db, timeout: Integer;
      block: Boolean; StatusCmdReturn: TRedisStatusCmd); overload;
    procedure Migrate(host, port, Key: string; db, timeout: Integer;
      block: Boolean; StatusCmdReturn: TRedisStatusCmdA); overload;
    procedure Migrate(host, port, Key: string; db, timeout: Integer;
      block: Boolean; StatusCmdReturn: TRedisStatusCmdG); overload;
    procedure Restore(Key, Value: string; ttl: Integer; block: Boolean;
      StatusCmdReturn: TRedisStatusCmd); overload;
    procedure Restore(Key, Value: string; ttl: Integer; block: Boolean;
      StatusCmdReturn: TRedisStatusCmdA); overload;
    procedure Restore(Key, Value: string; ttl: Integer; block: Boolean;
      StatusCmdReturn: TRedisStatusCmdG); overload;
    procedure RestoreReplace(Key, Value: string; ttl: Integer; block: Boolean;
      StatusCmdReturn: TRedisStatusCmd); overload;
    procedure RestoreReplace(Key, Value: string; ttl: Integer; block: Boolean;
      StatusCmdReturn: TRedisStatusCmdA); overload;
    procedure RestoreReplace(Key, Value: string; ttl: Integer; block: Boolean;
      StatusCmdReturn: TRedisStatusCmdG); overload;
    procedure TypeCmd(Key: string; block: Boolean;
      StatusCmdReturn: TRedisStatusCmd); overload;
    procedure TypeCmd(Key: string; block: Boolean;
      StatusCmdReturn: TRedisStatusCmdA); overload;
    procedure TypeCmd(Key: string; block: Boolean;
      StatusCmdReturn: TRedisStatusCmdG); overload;
    procedure MSet(keyValueArray: array of TKeyValue; block: Boolean;
      StatusCmdReturn: TRedisStatusCmd); overload;
    procedure MSet(keyValueArray: array of TKeyValue; block: Boolean;
      StatusCmdReturn: TRedisStatusCmdA); overload;
    procedure MSet(keyValueArray: array of TKeyValue; block: Boolean;
      StatusCmdReturn: TRedisStatusCmdG); overload;
    procedure MSet(keyValueArray: array of TRedisKeyValue; block: Boolean;
      StatusCmdReturn: TRedisStatusCmd); overload;
    procedure MSet(keyValueArray: array of TRedisKeyValue; block: Boolean;
      StatusCmdReturn: TRedisStatusCmdA); overload;
    procedure MSet(keyValueArray: array of TRedisKeyValue; block: Boolean;
      StatusCmdReturn: TRedisStatusCmdG); overload;

    procedure SetCmd(Key, Value: string; expiration: Integer; block: Boolean;
      StatusCmdReturn: TRedisStatusCmd); overload;
    procedure SetCmd(Key, Value: string; expiration: Integer; block: Boolean;
      StatusCmdReturn: TRedisStatusCmdA); overload;
    procedure SetCmd(Key, Value: string; expiration: Integer; block: Boolean;
      StatusCmdReturn: TRedisStatusCmdG); overload;
    procedure SetCmd(Key: string; ValueBuffer: PByte;
      BufferLen, expiration: Integer; block: Boolean;
      StatusCmdReturn: TRedisStatusCmd); overload;
    procedure SetCmd(Key: string; ValueBuffer: PByte;
      BufferLen, expiration: Integer; block: Boolean;
      StatusCmdReturn: TRedisStatusCmdA); overload;
    procedure SetCmd(Key: string; ValueBuffer: PByte;
      BufferLen, expiration: Integer; block: Boolean;
      StatusCmdReturn: TRedisStatusCmdG); overload;
    procedure SetEx(Key, Value: string; expiration: Integer; block: Boolean;
      StatusCmdReturn: TRedisStatusCmd); overload;
    procedure SetEx(Key, Value: string; expiration: Integer; block: Boolean;
      StatusCmdReturn: TRedisStatusCmdA); overload;
    procedure SetEx(Key, Value: string; expiration: Integer; block: Boolean;
      StatusCmdReturn: TRedisStatusCmdG); overload;
    procedure SetEx(Key: string; ValueBuffer: PByte;
      BufferLen, expiration: Integer; block: Boolean;
      StatusCmdReturn: TRedisStatusCmd); overload;
    procedure SetEx(Key: string; ValueBuffer: PByte;
      BufferLen, expiration: Integer; block: Boolean;
      StatusCmdReturn: TRedisStatusCmdA); overload;
    procedure SetEx(Key: string; ValueBuffer: PByte;
      BufferLen, expiration: Integer; block: Boolean;
      StatusCmdReturn: TRedisStatusCmdG); overload;
    procedure SetArgs(Key, Value: string; args: TsetArgs; block: Boolean;
      StatusCmdReturn: TRedisStatusCmd); overload;
    procedure SetArgs(Key, Value: string; args: TsetArgs; block: Boolean;
      StatusCmdReturn: TRedisStatusCmdA); overload;
    procedure SetArgs(Key, Value: string; args: TsetArgs; block: Boolean;
      StatusCmdReturn: TRedisStatusCmdG); overload;
    procedure SetArgs(Key: string; ValueBuffer: PByte; BufferLen: Integer;
      args: TsetArgs; block: Boolean;
      StatusCmdReturn: TRedisStatusCmd); overload;
    procedure SetArgs(Key: string; ValueBuffer: PByte; BufferLen: Integer;
      args: TsetArgs; block: Boolean;
      StatusCmdReturn: TRedisStatusCmdA); overload;
    procedure SetArgs(Key: string; ValueBuffer: PByte; BufferLen: Integer;
      args: TsetArgs; block: Boolean;
      StatusCmdReturn: TRedisStatusCmdG); overload;
    procedure LSet(Key: string; index: Int64; Value: string; block: Boolean;
      StatusCmdReturn: TRedisStatusCmd); overload;
    procedure LSet(Key: string; index: Int64; Value: string; block: Boolean;
      StatusCmdReturn: TRedisStatusCmdA); overload;
    procedure LSet(Key: string; index: Int64; Value: string; block: Boolean;
      StatusCmdReturn: TRedisStatusCmdG); overload;
    procedure LSet(Key: string; index: Int64; ValueBuffer: PByte;
      BufferLen: Integer; block: Boolean;
      StatusCmdReturn: TRedisStatusCmd); overload;
    procedure LSet(Key: string; index: Int64; ValueBuffer: PByte;
      BufferLen: Integer; block: Boolean;
      StatusCmdReturn: TRedisStatusCmdA); overload;
    procedure LSet(Key: string; index: Int64; ValueBuffer: PByte;
      BufferLen: Integer; block: Boolean;
      StatusCmdReturn: TRedisStatusCmdG); overload;
    procedure LTrim(Key: string; Start, stop: Int64; block: Boolean;
      StatusCmdReturn: TRedisStatusCmd); overload;
    procedure LTrim(Key: string; Start, stop: Int64; block: Boolean;
      StatusCmdReturn: TRedisStatusCmdA); overload;
    procedure LTrim(Key: string; Start, stop: Int64; block: Boolean;
      StatusCmdReturn: TRedisStatusCmdG); overload;
    procedure ScriptFlush(block: Boolean;
      StatusCmdReturn: TRedisStatusCmd); overload;
    procedure ScriptFlush(block: Boolean;
      StatusCmdReturn: TRedisStatusCmdA); overload;
    procedure ScriptFlush(block: Boolean;
      StatusCmdReturn: TRedisStatusCmdG); overload;
    procedure ScriptKill(block: Boolean;
      StatusCmdReturn: TRedisStatusCmd); overload;
    procedure ScriptKill(block: Boolean;
      StatusCmdReturn: TRedisStatusCmdA); overload;
    procedure ScriptKill(block: Boolean;
      StatusCmdReturn: TRedisStatusCmdG); overload;
    procedure ScriptLoad(script: string; block: Boolean;
      StatusCmdReturn: TRedisStatusCmd); overload;
    procedure ScriptLoad(script: string; block: Boolean;
      StatusCmdReturn: TRedisStatusCmdA); overload;
    procedure ScriptLoad(script: string; block: Boolean;
      StatusCmdReturn: TRedisStatusCmdG); overload;
{$ENDREGION}
{$REGION 'scanCmd'}
    procedure Scan(cursor: UInt64; match: string; count: Int64; block: Boolean;
      scanCmdReturn: TRedisScanCmdReturn); overload;
    procedure Scan(cursor: UInt64; match: string; count: Int64; block: Boolean;
      scanCmdReturn: TRedisScanCmdReturnA); overload;
    procedure Scan(cursor: UInt64; match: string; count: Int64; block: Boolean;
      scanCmdReturn: TRedisScanCmdReturnG); overload;
    procedure ScanType(cursor: UInt64; match, KeyType: string; count: Int64;
      block: Boolean; scanCmdReturn: TRedisScanCmdReturn); overload;
    procedure ScanType(cursor: UInt64; match, KeyType: string; count: Int64;
      block: Boolean; scanCmdReturn: TRedisScanCmdReturnA); overload;
    procedure ScanType(cursor: UInt64; match, KeyType: string; count: Int64;
      block: Boolean; scanCmdReturn: TRedisScanCmdReturnG); overload;

    procedure SelectAndScan(index: Integer; match, KeyType: string;
      count: Integer; block: Boolean;
      scanCmdReturn: TRedisSelectScanCmdReturn); overload;
    procedure SelectAndScan(index: Integer; match, KeyType: string;
      count: Integer; block: Boolean;
      scanCmdReturn: TRedisSelectScanCmdReturnA); overload;
    procedure SelectAndScan(index: Integer; match, KeyType: string;
      count: Integer; block: Boolean;
      scanCmdReturn: TRedisSelectScanCmdReturnG); overload;

    procedure SScan(cursor: UInt64; Key, match: string; count: Int64;
      block: Boolean; scanCmdReturn: TRedisScanCmdReturn); overload;
    procedure SScan(cursor: UInt64; Key, match: string; count: Int64;
      block: Boolean; scanCmdReturn: TRedisScanCmdReturnA); overload;
    procedure SScan(cursor: UInt64; Key, match: string; count: Int64;
      block: Boolean; scanCmdReturn: TRedisScanCmdReturnG); overload;
    procedure HScan(cursor: UInt64; Key, match: string; count: Int64;
      block: Boolean; scanCmdReturn: TRedisScanCmdReturn); overload;
    procedure HScan(cursor: UInt64; Key, match: string; count: Int64;
      block: Boolean; scanCmdReturn: TRedisScanCmdReturnA); overload;
    procedure HScan(cursor: UInt64; Key, match: string; count: Int64;
      block: Boolean; scanCmdReturn: TRedisScanCmdReturnG); overload;
    procedure ZScan(cursor: UInt64; Key, match: string; count: Int64;
      block: Boolean; scanCmdReturn: TRedisScanCmdReturn); overload;
    procedure ZScan(cursor: UInt64; Key, match: string; count: Int64;
      block: Boolean; scanCmdReturn: TRedisScanCmdReturnA); overload;
    procedure ZScan(cursor: UInt64; Key, match: string; count: Int64;
      block: Boolean; scanCmdReturn: TRedisScanCmdReturnG); overload;
{$ENDREGION}
{$REGION 'stringCmd'}
    procedure get(Key: string; block: Boolean;
      stringCmdReturn: TRedisStringCmdReturn); overload;
    procedure get(Key: string; block: Boolean;
      stringCmdReturn: TRedisStringCmdReturnA); overload;
    procedure get(Key: string; block: Boolean;
      stringCmdReturn: TRedisStringCmdReturnG); overload;
    procedure get(Key: string; block: Boolean;
      stringCmdReturn: TRedisStringCmdReturnByte); overload;
    procedure get(Key: string; block: Boolean;
      stringCmdReturn: TRedisStringCmdReturnByteA); overload;
    procedure get(Key: string; block: Boolean;
      stringCmdReturn: TRedisStringCmdReturnByteG); overload;

    procedure GetRange(Key: string; Start, stop: Int64; block: Boolean;
      stringCmdReturn: TRedisStringCmdReturn); overload;
    procedure GetRange(Key: string; Start, stop: Int64; block: Boolean;
      stringCmdReturnA: TRedisStringCmdReturnA); overload;
    procedure GetRange(Key: string; Start, stop: Int64; block: Boolean;
      stringCmdReturnG: TRedisStringCmdReturnG); overload;
    procedure GetRange(Key: string; Start, stop: Int64; block: Boolean;
      stringCmdReturn: TRedisStringCmdReturnByte); overload;
    procedure GetRange(Key: string; Start, stop: Int64; block: Boolean;
      stringCmdReturnA: TRedisStringCmdReturnByteA); overload;
    procedure GetRange(Key: string; Start, stop: Int64; block: Boolean;
      stringCmdReturnG: TRedisStringCmdReturnByteG); overload;

    procedure GetSet(Key: string; Value: string; block: Boolean;
      stringCmdReturn: TRedisStringCmdReturn); overload;
    procedure GetSet(Key: string; Value: string; block: Boolean;
      stringCmdReturn: TRedisStringCmdReturnA); overload;
    procedure GetSet(Key: string; Value: string; block: Boolean;
      stringCmdReturn: TRedisStringCmdReturnG); overload;
    procedure GetSet(Key: string; Value: PByte; ValueLen: Integer;
      block: Boolean; stringCmdReturn: TRedisStringCmdReturnByte); overload;
    procedure GetSet(Key: string; Value: PByte; ValueLen: Integer;
      block: Boolean; stringCmdReturn: TRedisStringCmdReturnByteA); overload;
    procedure GetSet(Key: string; Value: PByte; ValueLen: Integer;
      block: Boolean; stringCmdReturn: TRedisStringCmdReturnByteG); overload;

    procedure GetEx(Key: string; expiration: Integer; block: Boolean;
      stringCmdReturn: TRedisStringCmdReturn); overload;
    procedure GetEx(Key: string; expiration: Integer; block: Boolean;
      stringCmdReturn: TRedisStringCmdReturnA); overload;
    procedure GetEx(Key: string; expiration: Integer; block: Boolean;
      stringCmdReturn: TRedisStringCmdReturnG); overload;
    procedure GetEx(Key: string; expiration: Integer; block: Boolean;
      stringCmdReturn: TRedisStringCmdReturnByte); overload;
    procedure GetEx(Key: string; expiration: Integer; block: Boolean;
      stringCmdReturn: TRedisStringCmdReturnByteA); overload;
    procedure GetEx(Key: string; expiration: Integer; block: Boolean;
      stringCmdReturn: TRedisStringCmdReturnByteG); overload;

    procedure GetDel(Key: string; block: Boolean;
      stringCmdReturn: TRedisStringCmdReturn); overload;
    procedure GetDel(Key: string; block: Boolean;
      stringCmdReturn: TRedisStringCmdReturnA); overload;
    procedure GetDel(Key: string; block: Boolean;
      stringCmdReturn: TRedisStringCmdReturnG); overload;
    procedure GetDel(Key: string; block: Boolean;
      stringCmdReturn: TRedisStringCmdReturnByte); overload;
    procedure GetDel(Key: string; block: Boolean;
      stringCmdReturn: TRedisStringCmdReturnByteA); overload;
    procedure GetDel(Key: string; block: Boolean;
      stringCmdReturn: TRedisStringCmdReturnByteG); overload;

    procedure HGet(Key, field: string; block: Boolean;
      stringCmdReturn: TRedisStringCmdReturn); overload;
    procedure HGet(Key, field: string; block: Boolean;
      stringCmdReturn: TRedisStringCmdReturnA); overload;
    procedure HGet(Key, field: string; block: Boolean;
      stringCmdReturn: TRedisStringCmdReturnG); overload;
    procedure HGet(Key, field: string; block: Boolean;
      stringCmdReturn: TRedisStringCmdReturnByte); overload;
    procedure HGet(Key, field: string; block: Boolean;
      stringCmdReturn: TRedisStringCmdReturnByteA); overload;
    procedure HGet(Key, field: string; block: Boolean;
      stringCmdReturn: TRedisStringCmdReturnByteG); overload;

    procedure BRPopLPush(src, dst: string; timeout: Integer; block: Boolean;
      stringCmdReturn: TRedisStringCmdReturn); overload;
    procedure BRPopLPush(src, dst: string; timeout: Integer; block: Boolean;
      stringCmdReturn: TRedisStringCmdReturnA); overload;
    procedure BRPopLPush(src, dst: string; timeout: Integer; block: Boolean;
      stringCmdReturn: TRedisStringCmdReturnG); overload;
    procedure BRPopLPush(src, dst: string; timeout: Integer; block: Boolean;
      stringCmdReturn: TRedisStringCmdReturnByte); overload;
    procedure BRPopLPush(src, dst: string; timeout: Integer; block: Boolean;
      stringCmdReturn: TRedisStringCmdReturnByteA); overload;
    procedure BRPopLPush(src, dst: string; timeout: Integer; block: Boolean;
      stringCmdReturn: TRedisStringCmdReturnByteG); overload;

    procedure RPopLPush(src, dst: string; block: Boolean;
      stringCmdReturn: TRedisStringCmdReturn); overload;
    procedure RPopLPush(src, dst: string; block: Boolean;
      stringCmdReturn: TRedisStringCmdReturnA); overload;
    procedure RPopLPush(src, dst: string; block: Boolean;
      stringCmdReturn: TRedisStringCmdReturnG); overload;
    procedure RPopLPush(src, dst: string; block: Boolean;
      stringCmdReturn: TRedisStringCmdReturnByte); overload;
    procedure RPopLPush(src, dst: string; block: Boolean;
      stringCmdReturn: TRedisStringCmdReturnByteA); overload;
    procedure RPopLPush(src, dst: string; block: Boolean;
      stringCmdReturn: TRedisStringCmdReturnByteG); overload;

    procedure LIndex(Key: string; index: Int64; block: Boolean;
      stringCmdReturn: TRedisStringCmdReturn); overload;
    procedure LIndex(Key: string; index: Int64; block: Boolean;
      stringCmdReturn: TRedisStringCmdReturnA); overload;
    procedure LIndex(Key: string; index: Int64; block: Boolean;
      stringCmdReturn: TRedisStringCmdReturnG); overload;
    procedure LIndex(Key: string; index: Int64; block: Boolean;
      stringCmdReturn: TRedisStringCmdReturnByte); overload;
    procedure LIndex(Key: string; index: Int64; block: Boolean;
      stringCmdReturn: TRedisStringCmdReturnByteA); overload;
    procedure LIndex(Key: string; index: Int64; block: Boolean;
      stringCmdReturn: TRedisStringCmdReturnByteG); overload;

    procedure LPop(Key: string; block: Boolean;
      stringCmdReturn: TRedisStringCmdReturn); overload;
    procedure LPop(Key: string; block: Boolean;
      stringCmdReturn: TRedisStringCmdReturnA); overload;
    procedure LPop(Key: string; block: Boolean;
      stringCmdReturn: TRedisStringCmdReturnG); overload;
    procedure LPop(Key: string; block: Boolean;
      stringCmdReturn: TRedisStringCmdReturnByte); overload;
    procedure LPop(Key: string; block: Boolean;
      stringCmdReturn: TRedisStringCmdReturnByteA); overload;
    procedure LPop(Key: string; block: Boolean;
      stringCmdReturn: TRedisStringCmdReturnByteG); overload;

    procedure RPop(Key: string; block: Boolean;
      stringCmdReturn: TRedisStringCmdReturn); overload;
    procedure RPop(Key: string; block: Boolean;
      stringCmdReturn: TRedisStringCmdReturnA); overload;
    procedure RPop(Key: string; block: Boolean;
      stringCmdReturn: TRedisStringCmdReturnG); overload;
    procedure RPop(Key: string; block: Boolean;
      stringCmdReturn: TRedisStringCmdReturnByte); overload;
    procedure RPop(Key: string; block: Boolean;
      stringCmdReturn: TRedisStringCmdReturnByteA); overload;
    procedure RPop(Key: string; block: Boolean;
      stringCmdReturn: TRedisStringCmdReturnByteG); overload;

    procedure SPop(Key: string; block: Boolean;
      stringCmdReturn: TRedisStringCmdReturn); overload;
    procedure SPop(Key: string; block: Boolean;
      stringCmdReturn: TRedisStringCmdReturnA); overload;
    procedure SPop(Key: string; block: Boolean;
      stringCmdReturn: TRedisStringCmdReturnG); overload;
    procedure SPop(Key: string; block: Boolean;
      stringCmdReturn: TRedisStringCmdReturnByte); overload;
    procedure SPop(Key: string; block: Boolean;
      stringCmdReturn: TRedisStringCmdReturnByteA); overload;
    procedure SPop(Key: string; block: Boolean;
      stringCmdReturn: TRedisStringCmdReturnByteG); overload;

    procedure SRandMember(Key: string; block: Boolean;
      stringCmdReturn: TRedisStringCmdReturn); overload;
    procedure SRandMember(Key: string; block: Boolean;
      stringCmdReturn: TRedisStringCmdReturnA); overload;
    procedure SRandMember(Key: string; block: Boolean;
      stringCmdReturn: TRedisStringCmdReturnG); overload;
    procedure SRandMember(Key: string; block: Boolean;
      stringCmdReturn: TRedisStringCmdReturnByte); overload;
    procedure SRandMember(Key: string; block: Boolean;
      stringCmdReturn: TRedisStringCmdReturnByteA); overload;
    procedure SRandMember(Key: string; block: Boolean;
      stringCmdReturn: TRedisStringCmdReturnByteG); overload;

    procedure ClientList(block: Boolean;
      stringCmdReturn: TRedisStringCmdReturn); overload;
    procedure ClientList(block: Boolean;
      stringCmdReturn: TRedisStringCmdReturnA); overload;
    procedure ClientList(block: Boolean;
      stringCmdReturn: TRedisStringCmdReturnG); overload;

    procedure Info(sections: array of string; block: Boolean;
      stringCmdReturn: TRedisStringCmdReturn); overload;
    procedure Info(sections: array of string; block: Boolean;
      stringCmdReturn: TRedisStringCmdReturnA); overload;
    procedure Info(sections: array of string; block: Boolean;
      stringCmdReturn: TRedisStringCmdReturnG); overload;

    procedure XAdd(stream, ID: string; MaxLen, MaxLenApprox: Int64;
      Value: string; block: Boolean;
      stringCmdReturn: TRedisStringCmdReturn); overload;
    procedure XAdd(stream, ID: string; MaxLen, MaxLenApprox: Int64;
      Value: string; block: Boolean;
      stringCmdReturn: TRedisStringCmdReturnA); overload;
    procedure XAdd(stream, ID: string; MaxLen, MaxLenApprox: Int64;
      Value: string; block: Boolean;
      stringCmdReturn: TRedisStringCmdReturnG); overload;
{$ENDREGION}
    procedure Del(keys: array of string; block: Boolean;
      intCmdReturn: TIntCmdReturn); overload;
    procedure Del(keys: array of string; block: Boolean;
      intCmdReturn: TIntCmdReturnA); overload;
    procedure Del(keys: array of string; block: Boolean;
      intCmdReturn: TIntCmdReturnG); overload;

    procedure Unlink(keys: array of string; block: Boolean;
      intCmdReturn: TIntCmdReturn); overload;
    procedure Unlink(keys: array of string; block: Boolean;
      intCmdReturn: TIntCmdReturnA); overload;
    procedure Unlink(keys: array of string; block: Boolean;
      intCmdReturn: TIntCmdReturnG); overload;

    procedure Exists(keys: array of string; block: Boolean;
      intCmdReturn: TIntCmdReturn); overload;
    procedure Exists(keys: array of string; block: Boolean;
      intCmdReturn: TIntCmdReturnA); overload;
    procedure Exists(keys: array of string; block: Boolean;
      intCmdReturn: TIntCmdReturnG); overload;

    procedure ObjectRefCount(Key: string; block: Boolean;
      intCmdReturn: TIntCmdReturn); overload;
    procedure ObjectRefCount(Key: string; block: Boolean;
      intCmdReturn: TIntCmdReturnA); overload;
    procedure ObjectRefCount(Key: string; block: Boolean;
      intCmdReturn: TIntCmdReturnG); overload;

    procedure Touch(keys: array of string; block: Boolean;
      intCmdReturn: TIntCmdReturn); overload;
    procedure Touch(keys: array of string; block: Boolean;
      intCmdReturn: TIntCmdReturnA); overload;
    procedure Touch(keys: array of string; block: Boolean;
      intCmdReturn: TIntCmdReturnG); overload;

    procedure Append(Key, Value: string; block: Boolean;
      intCmdReturn: TIntCmdReturn); overload;
    procedure Append(Key, Value: string; block: Boolean;
      intCmdReturn: TIntCmdReturnA); overload;
    procedure Append(Key, Value: string; block: Boolean;
      intCmdReturn: TIntCmdReturnG); overload;

    procedure Decr(Key: string; block: Boolean;
      intCmdReturn: TIntCmdReturn); overload;
    procedure Decr(Key: string; block: Boolean;
      intCmdReturn: TIntCmdReturnA); overload;
    procedure Decr(Key: string; block: Boolean;
      intCmdReturn: TIntCmdReturnG); overload;

    procedure DecrBy(Key: string; decrement: Int64; block: Boolean;
      intCmdReturn: TIntCmdReturn); overload;
    procedure DecrBy(Key: string; decrement: Int64; block: Boolean;
      intCmdReturn: TIntCmdReturnA); overload;
    procedure DecrBy(Key: string; decrement: Int64; block: Boolean;
      intCmdReturn: TIntCmdReturnG); overload;

    procedure Incr(Key: string; block: Boolean;
      intCmdReturn: TIntCmdReturn); overload;
    procedure Incr(Key: string; block: Boolean;
      intCmdReturn: TIntCmdReturnA); overload;
    procedure Incr(Key: string; block: Boolean;
      intCmdReturn: TIntCmdReturnG); overload;

    procedure IncrBy(Key: string; increment: Int64; block: Boolean;
      intCmdReturn: TIntCmdReturn); overload;
    procedure IncrBy(Key: string; increment: Int64; block: Boolean;
      intCmdReturn: TIntCmdReturnA); overload;
    procedure IncrBy(Key: string; increment: Int64; block: Boolean;
      intCmdReturn: TIntCmdReturnG); overload;

    procedure StrLen(Key: string; block: Boolean;
      intCmdReturn: TIntCmdReturn); overload;
    procedure StrLen(Key: string; block: Boolean;
      intCmdReturn: TIntCmdReturnA); overload;
    procedure StrLen(Key: string; block: Boolean;
      intCmdReturn: TIntCmdReturnG); overload;

    procedure SetRange(Key: string; offset: Int64; Value: string;
      block: Boolean; intCmdReturn: TIntCmdReturn); overload;
    procedure SetRange(Key: string; offset: Int64; Value: string;
      block: Boolean; intCmdReturn: TIntCmdReturnA); overload;
    procedure SetRange(Key: string; offset: Int64; Value: string;
      block: Boolean; intCmdReturn: TIntCmdReturnG); overload;

    procedure GetBit(Key: string; offset: Int64; block: Boolean;
      intCmdReturn: TIntCmdReturn); overload;
    procedure GetBit(Key: string; offset: Int64; block: Boolean;
      intCmdReturn: TIntCmdReturnA); overload;
    procedure GetBit(Key: string; offset: Int64; block: Boolean;
      intCmdReturn: TIntCmdReturnG); overload;

    procedure SetBit(Key: string; offset: Int64; Value: Integer; block: Boolean;
      intCmdReturn: TIntCmdReturn); overload;
    procedure SetBit(Key: string; offset: Int64; Value: Integer; block: Boolean;
      intCmdReturn: TIntCmdReturnA); overload;
    procedure SetBit(Key: string; offset: Int64; Value: Integer; block: Boolean;
      intCmdReturn: TIntCmdReturnG); overload;

    procedure BitCount(Key: string; BitCount: TBitCount; block: Boolean;
      intCmdReturn: TIntCmdReturn); overload;
    procedure BitCount(Key: string; BitCount: TBitCount; block: Boolean;
      intCmdReturn: TIntCmdReturnA); overload;
    procedure BitCount(Key: string; BitCount: TBitCount; block: Boolean;
      intCmdReturn: TIntCmdReturnG); overload;

    procedure BitOpAnd(destKey: string; keys: array of string; block: Boolean;
      intCmdReturn: TIntCmdReturn); overload;
    procedure BitOpAnd(destKey: string; keys: array of string; block: Boolean;
      intCmdReturn: TIntCmdReturnA); overload;
    procedure BitOpAnd(destKey: string; keys: array of string; block: Boolean;
      intCmdReturn: TIntCmdReturnG); overload;

    procedure BitOpOr(destKey: string; keys: array of string; block: Boolean;
      intCmdReturn: TIntCmdReturn); overload;
    procedure BitOpOr(destKey: string; keys: array of string; block: Boolean;
      intCmdReturn: TIntCmdReturnA); overload;
    procedure BitOpOr(destKey: string; keys: array of string; block: Boolean;
      intCmdReturn: TIntCmdReturnG); overload;

    procedure BitOpXor(destKey: string; keys: array of string; block: Boolean;
      intCmdReturn: TIntCmdReturn); overload;
    procedure BitOpXor(destKey: string; keys: array of string; block: Boolean;
      intCmdReturn: TIntCmdReturnA); overload;
    procedure BitOpXor(destKey: string; keys: array of string; block: Boolean;
      intCmdReturn: TIntCmdReturnG); overload;

    procedure BitOpNot(destKey, Key: string; block: Boolean;
      intCmdReturn: TIntCmdReturn); overload;
    procedure BitOpNot(destKey, Key: string; block: Boolean;
      intCmdReturn: TIntCmdReturnA); overload;
    procedure BitOpNot(destKey, Key: string; block: Boolean;
      intCmdReturn: TIntCmdReturnG); overload;

    procedure BitPos(Key: string; bit: Int64; bitPoss: array of Int64;
      block: Boolean; intCmdReturn: TIntCmdReturn); overload;
    procedure BitPos(Key: string; bit: Int64; bitPoss: array of Int64;
      block: Boolean; intCmdReturn: TIntCmdReturnA); overload;
    procedure BitPos(Key: string; bit: Int64; bitPoss: array of Int64;
      block: Boolean; intCmdReturn: TIntCmdReturnG); overload;

    procedure HDel(Key: string; fields: array of string; block: Boolean;
      intCmdReturn: TIntCmdReturn); overload;
    procedure HDel(Key: string; fields: array of string; block: Boolean;
      intCmdReturn: TIntCmdReturnA); overload;
    procedure HDel(Key: string; fields: array of string; block: Boolean;
      intCmdReturn: TIntCmdReturnG); overload;

    procedure HIncrBy(Key, field: string; Incr: Int64; block: Boolean;
      intCmdReturn: TIntCmdReturn); overload;
    procedure HIncrBy(Key, field: string; Incr: Int64; block: Boolean;
      intCmdReturn: TIntCmdReturnA); overload;
    procedure HIncrBy(Key, field: string; Incr: Int64; block: Boolean;
      intCmdReturn: TIntCmdReturnG); overload;

    procedure HLen(Key: string; block: Boolean;
      intCmdReturn: TIntCmdReturn); overload;
    procedure HLen(Key: string; block: Boolean;
      intCmdReturn: TIntCmdReturnA); overload;
    procedure HLen(Key: string; block: Boolean;
      intCmdReturn: TIntCmdReturnG); overload;

    procedure HSet(Key: string; keyValues: array of TKeyValue; block: Boolean;
      intCmdReturn: TIntCmdReturn); overload;
    procedure HSet(Key: string; keyValues: array of TKeyValue; block: Boolean;
      intCmdReturn: TIntCmdReturnA); overload;
    procedure HSet(Key: string; keyValues: array of TKeyValue; block: Boolean;
      intCmdReturn: TIntCmdReturnG); overload;
    procedure HSet(Key: string; keyValues: array of TRedisKeyValue; block: Boolean;
      intCmdReturn: TIntCmdReturn); overload;
    procedure HSet(Key: string; keyValues: array of TRedisKeyValue; block: Boolean;
      intCmdReturn: TIntCmdReturnA); overload;
    procedure HSet(Key: string; keyValues: array of TRedisKeyValue; block: Boolean;
      intCmdReturn: TIntCmdReturnG); overload;

    procedure LInsert(Key: string; before: Boolean; pivot, Value: string;
      block: Boolean; intCmdReturn: TIntCmdReturn); overload;
    procedure LInsert(Key: string; before: Boolean; pivot, Value: string;
      block: Boolean; intCmdReturn: TIntCmdReturnA); overload;
    procedure LInsert(Key: string; before: Boolean; pivot, Value: string;
      block: Boolean; intCmdReturn: TIntCmdReturnG); overload;

    procedure LInsertBefore(Key: string; pivot, Value: string; block: Boolean;
      intCmdReturn: TIntCmdReturn); overload;
    procedure LInsertBefore(Key: string; pivot, Value: string; block: Boolean;
      intCmdReturn: TIntCmdReturnA); overload;
    procedure LInsertBefore(Key: string; pivot, Value: string; block: Boolean;
      intCmdReturn: TIntCmdReturnG); overload;

    procedure LInsertAfter(Key: string; pivot, Value: string; block: Boolean;
      intCmdReturn: TIntCmdReturn); overload;
    procedure LInsertAfter(Key: string; pivot, Value: string; block: Boolean;
      intCmdReturn: TIntCmdReturnA); overload;
    procedure LInsertAfter(Key: string; pivot, Value: string; block: Boolean;
      intCmdReturn: TIntCmdReturnG); overload;

    procedure LLen(Key: string; block: Boolean;
      intCmdReturn: TIntCmdReturn); overload;
    procedure LLen(Key: string; block: Boolean;
      intCmdReturn: TIntCmdReturnA); overload;
    procedure LLen(Key: string; block: Boolean;
      intCmdReturn: TIntCmdReturnG); overload;

    procedure LPos(Key, Value: string; args: TLPosArgs; block: Boolean;
      intCmdReturn: TIntCmdReturn); overload;
    procedure LPos(Key, Value: string; args: TLPosArgs; block: Boolean;
      intCmdReturn: TIntCmdReturnA); overload;
    procedure LPos(Key, Value: string; args: TLPosArgs; block: Boolean;
      intCmdReturn: TIntCmdReturnG); overload;

    procedure LPush(Key: string; values: array of string; block: Boolean;
      intCmdReturn: TIntCmdReturn); overload;
    procedure LPush(Key: string; values: array of string; block: Boolean;
      intCmdReturn: TIntCmdReturnA); overload;
    procedure LPush(Key: string; values: array of string; block: Boolean;
      intCmdReturn: TIntCmdReturnG); overload;
    procedure LPush(Key: string; values: array of TValueInterface;
      block: Boolean; intCmdReturn: TIntCmdReturn); overload;
    procedure LPush(Key: string; values: array of TValueInterface;
      block: Boolean; intCmdReturn: TIntCmdReturnA); overload;
    procedure LPush(Key: string; values: array of TValueInterface;
      block: Boolean; intCmdReturn: TIntCmdReturnG); overload;

    procedure LPushx(Key: string; values: array of string; block: Boolean;
      intCmdReturn: TIntCmdReturn); overload;
    procedure LPushx(Key: string; values: array of string; block: Boolean;
      intCmdReturn: TIntCmdReturnA); overload;
    procedure LPushx(Key: string; values: array of string; block: Boolean;
      intCmdReturn: TIntCmdReturnG); overload;
    procedure LPushx(Key: string; values: array of TValueInterface;
      block: Boolean; intCmdReturn: TIntCmdReturn); overload;
    procedure LPushx(Key: string; values: array of TValueInterface;
      block: Boolean; intCmdReturn: TIntCmdReturnA); overload;
    procedure LPushx(Key: string; values: array of TValueInterface;
      block: Boolean; intCmdReturn: TIntCmdReturnG); overload;

    procedure RPush(Key: string; values: array of string; block: Boolean;
      intCmdReturn: TIntCmdReturn); overload;
    procedure RPush(Key: string; values: array of string; block: Boolean;
      intCmdReturn: TIntCmdReturnA); overload;
    procedure RPush(Key: string; values: array of string; block: Boolean;
      intCmdReturn: TIntCmdReturnG); overload;
    procedure RPush(Key: string; values: array of TValueInterface;
      block: Boolean; intCmdReturn: TIntCmdReturn); overload;
    procedure RPush(Key: string; values: array of TValueInterface;
      block: Boolean; intCmdReturn: TIntCmdReturnA); overload;
    procedure RPush(Key: string; values: array of TValueInterface;
      block: Boolean; intCmdReturn: TIntCmdReturnG); overload;

    procedure RPushx(Key: string; values: array of string; block: Boolean;
      intCmdReturn: TIntCmdReturn); overload;
    procedure RPushx(Key: string; values: array of string; block: Boolean;
      intCmdReturn: TIntCmdReturnA); overload;
    procedure RPushx(Key: string; values: array of string; block: Boolean;
      intCmdReturn: TIntCmdReturnG); overload;
    procedure RPushx(Key: string; values: array of TValueInterface;
      block: Boolean; intCmdReturn: TIntCmdReturn); overload;
    procedure RPushx(Key: string; values: array of TValueInterface;
      block: Boolean; intCmdReturn: TIntCmdReturnA); overload;
    procedure RPushx(Key: string; values: array of TValueInterface;
      block: Boolean; intCmdReturn: TIntCmdReturnG); overload;

    procedure LRem(Key: string; count: Int64; Value: TValueInterface;
      block: Boolean; intCmdReturn: TIntCmdReturn); overload;
    procedure LRem(Key: string; count: Int64; Value: TValueInterface;
      block: Boolean; intCmdReturn: TIntCmdReturnA); overload;
    procedure LRem(Key: string; count: Int64; Value: TValueInterface;
      block: Boolean; intCmdReturn: TIntCmdReturnG); overload;

    procedure SAdd(Key: string; values: array of string; block: Boolean;
      intCmdReturn: TIntCmdReturn); overload;
    procedure SAdd(Key: string; values: array of string; block: Boolean;
      intCmdReturn: TIntCmdReturnA); overload;
    procedure SAdd(Key: string; values: array of string; block: Boolean;
      intCmdReturn: TIntCmdReturnG); overload;
    procedure SAdd(Key: string; values: array of TValueInterface;
      block: Boolean; intCmdReturn: TIntCmdReturn); overload;
    procedure SAdd(Key: string; values: array of TValueInterface;
      block: Boolean; intCmdReturn: TIntCmdReturnA); overload;
    procedure SAdd(Key: string; values: array of TValueInterface;
      block: Boolean; intCmdReturn: TIntCmdReturnG); overload;

    procedure SCard(Key: string; block: Boolean;
      intCmdReturn: TIntCmdReturn); overload;
    procedure SCard(Key: string; block: Boolean;
      intCmdReturn: TIntCmdReturnA); overload;
    procedure SCard(Key: string; block: Boolean;
      intCmdReturn: TIntCmdReturnG); overload;

    procedure SDiffStore(destKey: string; keys: array of string; block: Boolean;
      intCmdReturn: TIntCmdReturn); overload;
    procedure SDiffStore(destKey: string; keys: array of string; block: Boolean;
      intCmdReturn: TIntCmdReturnA); overload;
    procedure SDiffStore(destKey: string; keys: array of string; block: Boolean;
      intCmdReturn: TIntCmdReturnG); overload;

    procedure SInterStore(destKey: string; keys: array of string;
      block: Boolean; intCmdReturn: TIntCmdReturn); overload;
    procedure SInterStore(destKey: string; keys: array of string;
      block: Boolean; intCmdReturn: TIntCmdReturnA); overload;
    procedure SInterStore(destKey: string; keys: array of string;
      block: Boolean; intCmdReturn: TIntCmdReturnG); overload;

    procedure SRem(Key: string; membersArr: array of string; block: Boolean;
      intCmdReturn: TIntCmdReturn); overload;
    procedure SRem(Key: string; membersArr: array of string; block: Boolean;
      intCmdReturn: TIntCmdReturnA); overload;
    procedure SRem(Key: string; membersArr: array of string; block: Boolean;
      intCmdReturn: TIntCmdReturnG); overload;
    procedure SRem(Key: string; membersArr: array of TValueInterface;
      block: Boolean; intCmdReturn: TIntCmdReturn); overload;
    procedure SRem(Key: string; membersArr: array of TValueInterface;
      block: Boolean; intCmdReturn: TIntCmdReturnA); overload;
    procedure SRem(Key: string; membersArr: array of TValueInterface;
      block: Boolean; intCmdReturn: TIntCmdReturnG); overload;

    procedure SUnionStore(destKey: string; keys: array of string;
      block: Boolean; intCmdReturn: TIntCmdReturn); overload;
    procedure SUnionStore(destKey: string; keys: array of string;
      block: Boolean; intCmdReturn: TIntCmdReturnA); overload;
    procedure SUnionStore(destKey: string; keys: array of string;
      block: Boolean; intCmdReturn: TIntCmdReturnG); overload;

    procedure ZAdd(Key: string; zvalue: array of TZStrValue; block: Boolean;
      intCmdReturn: TIntCmdReturn); overload;
    procedure ZAdd(Key: string; zvalue: array of TZStrValue; block: Boolean;
      intCmdReturn: TIntCmdReturnA); overload;
    procedure ZAdd(Key: string; zvalue: array of TZStrValue; block: Boolean;
      intCmdReturn: TIntCmdReturnG); overload;
    procedure ZAdd(Key: string; zvalue: array of TZValue; block: Boolean;
      intCmdReturn: TIntCmdReturn); overload;
    procedure ZAdd(Key: string; zvalue: array of TZValue; block: Boolean;
      intCmdReturn: TIntCmdReturnA); overload;
    procedure ZAdd(Key: string; zvalue: array of TZValue; block: Boolean;
      intCmdReturn: TIntCmdReturnG); overload;

    procedure ZAddNX(Key: string; zvalue: array of TZStrValue; block: Boolean;
      intCmdReturn: TIntCmdReturn); overload;
    procedure ZAddNX(Key: string; zvalue: array of TZStrValue; block: Boolean;
      intCmdReturn: TIntCmdReturnA); overload;
    procedure ZAddNX(Key: string; zvalue: array of TZStrValue; block: Boolean;
      intCmdReturn: TIntCmdReturnG); overload;
    procedure ZAddNX(Key: string; zvalue: array of TZValue; block: Boolean;
      intCmdReturn: TIntCmdReturn); overload;
    procedure ZAddNX(Key: string; zvalue: array of TZValue; block: Boolean;
      intCmdReturn: TIntCmdReturnA); overload;
    procedure ZAddNX(Key: string; zvalue: array of TZValue; block: Boolean;
      intCmdReturn: TIntCmdReturnG); overload;

    procedure ZAddXX(Key: string; zvalue: array of TZStrValue; block: Boolean;
      intCmdReturn: TIntCmdReturn); overload;
    procedure ZAddXX(Key: string; zvalue: array of TZStrValue; block: Boolean;
      intCmdReturn: TIntCmdReturnA); overload;
    procedure ZAddXX(Key: string; zvalue: array of TZStrValue; block: Boolean;
      intCmdReturn: TIntCmdReturnG); overload;
    procedure ZAddXX(Key: string; zvalue: array of TZValue; block: Boolean;
      intCmdReturn: TIntCmdReturn); overload;
    procedure ZAddXX(Key: string; zvalue: array of TZValue; block: Boolean;
      intCmdReturn: TIntCmdReturnA); overload;
    procedure ZAddXX(Key: string; zvalue: array of TZValue; block: Boolean;
      intCmdReturn: TIntCmdReturnG); overload;

    procedure ZAddCh(Key: string; zvalue: array of TZStrValue; block: Boolean;
      intCmdReturn: TIntCmdReturn); overload;
    procedure ZAddCh(Key: string; zvalue: array of TZStrValue; block: Boolean;
      intCmdReturn: TIntCmdReturnA); overload;
    procedure ZAddCh(Key: string; zvalue: array of TZStrValue; block: Boolean;
      intCmdReturn: TIntCmdReturnG); overload;
    procedure ZAddCh(Key: string; zvalue: array of TZValue; block: Boolean;
      intCmdReturn: TIntCmdReturn); overload;
    procedure ZAddCh(Key: string; zvalue: array of TZValue; block: Boolean;
      intCmdReturn: TIntCmdReturnA); overload;
    procedure ZAddCh(Key: string; zvalue: array of TZValue; block: Boolean;
      intCmdReturn: TIntCmdReturnG); overload;

    procedure ZAddNXCh(Key: string; zvalue: array of TZStrValue; block: Boolean;
      intCmdReturn: TIntCmdReturn); overload;
    procedure ZAddNXCh(Key: string; zvalue: array of TZStrValue; block: Boolean;
      intCmdReturn: TIntCmdReturnA); overload;
    procedure ZAddNXCh(Key: string; zvalue: array of TZStrValue; block: Boolean;
      intCmdReturn: TIntCmdReturnG); overload;
    procedure ZAddNXCh(Key: string; zvalue: array of TZValue; block: Boolean;
      intCmdReturn: TIntCmdReturn); overload;
    procedure ZAddNXCh(Key: string; zvalue: array of TZValue; block: Boolean;
      intCmdReturn: TIntCmdReturnA); overload;
    procedure ZAddNXCh(Key: string; zvalue: array of TZValue; block: Boolean;
      intCmdReturn: TIntCmdReturnG); overload;

    procedure ZAddXXCh(Key: string; zvalue: array of TZStrValue; block: Boolean;
      intCmdReturn: TIntCmdReturn); overload;
    procedure ZAddXXCh(Key: string; zvalue: array of TZStrValue; block: Boolean;
      intCmdReturn: TIntCmdReturnA); overload;
    procedure ZAddXXCh(Key: string; zvalue: array of TZStrValue; block: Boolean;
      intCmdReturn: TIntCmdReturnG); overload;
    procedure ZAddXXCh(Key: string; zvalue: array of TZValue; block: Boolean;
      intCmdReturn: TIntCmdReturn); overload;
    procedure ZAddXXCh(Key: string; zvalue: array of TZValue; block: Boolean;
      intCmdReturn: TIntCmdReturnA); overload;
    procedure ZAddXXCh(Key: string; zvalue: array of TZValue; block: Boolean;
      intCmdReturn: TIntCmdReturnG); overload;

    procedure ZCard(Key: string; block: Boolean;
      intCmdReturn: TIntCmdReturn); overload;
    procedure ZCard(Key: string; block: Boolean;
      intCmdReturn: TIntCmdReturnA); overload;
    procedure ZCard(Key: string; block: Boolean;
      intCmdReturn: TIntCmdReturnG); overload;

    procedure ZCount(Key, min, max: string; block: Boolean;
      intCmdReturn: TIntCmdReturn); overload;
    procedure ZCount(Key, min, max: string; block: Boolean;
      intCmdReturn: TIntCmdReturnA); overload;
    procedure ZCount(Key, min, max: string; block: Boolean;
      intCmdReturn: TIntCmdReturnG); overload;

    procedure ZLexCount(Key, min, max: string; block: Boolean;
      intCmdReturn: TIntCmdReturn); overload;
    procedure ZLexCount(Key, min, max: string; block: Boolean;
      intCmdReturn: TIntCmdReturnA); overload;
    procedure ZLexCount(Key, min, max: string; block: Boolean;
      intCmdReturn: TIntCmdReturnG); overload;

    procedure ZRemRangeByRank(Key: string; Start, stop: Int64; block: Boolean;
      intCmdReturn: TIntCmdReturn); overload;
    procedure ZRemRangeByRank(Key: string; Start, stop: Int64; block: Boolean;
      intCmdReturn: TIntCmdReturnA); overload;
    procedure ZRemRangeByRank(Key: string; Start, stop: Int64; block: Boolean;
      intCmdReturn: TIntCmdReturnG); overload;

    procedure ZRank(Key, Member: string; block: Boolean;
      intCmdReturn: TIntCmdReturn); overload;
    procedure ZRank(Key, Member: string; block: Boolean;
      intCmdReturn: TIntCmdReturnA); overload;
    procedure ZRank(Key, Member: string; block: Boolean;
      intCmdReturn: TIntCmdReturnG); overload;

    procedure ZRem(Key: string; membersArr: array of string; block: Boolean;
      intCmdReturn: TIntCmdReturn); overload;
    procedure ZRem(Key: string; membersArr: array of string; block: Boolean;
      intCmdReturn: TIntCmdReturnA); overload;
    procedure ZRem(Key: string; membersArr: array of string; block: Boolean;
      intCmdReturn: TIntCmdReturnG); overload;
    procedure ZRem(Key: string; membersArr: array of TValueInterface;
      block: Boolean; intCmdReturn: TIntCmdReturn); overload;
    procedure ZRem(Key: string; membersArr: array of TValueInterface;
      block: Boolean; intCmdReturn: TIntCmdReturnA); overload;
    procedure ZRem(Key: string; membersArr: array of TValueInterface;
      block: Boolean; intCmdReturn: TIntCmdReturnG); overload;

    procedure ZRemRangeByScore(Key, min, max: string; block: Boolean;
      intCmdReturn: TIntCmdReturn); overload;
    procedure ZRemRangeByScore(Key, min, max: string; block: Boolean;
      intCmdReturn: TIntCmdReturnA); overload;
    procedure ZRemRangeByScore(Key, min, max: string; block: Boolean;
      intCmdReturn: TIntCmdReturnG); overload;

    procedure ZRemRangeByLex(Key, min, max: string; block: Boolean;
      intCmdReturn: TIntCmdReturn); overload;
    procedure ZRemRangeByLex(Key, min, max: string; block: Boolean;
      intCmdReturn: TIntCmdReturnA); overload;
    procedure ZRemRangeByLex(Key, min, max: string; block: Boolean;
      intCmdReturn: TIntCmdReturnG); overload;
    //返回毫秒
    procedure TTL(key: string;block: Boolean;intCmdReturn: TIntCmdReturn); overload;
    procedure TTL(key: string;block: Boolean;intCmdReturn: TIntCmdReturnA); overload;
    procedure TTL(key: string;block: Boolean;intCmdReturn: TIntCmdReturnG); overload;

    procedure Expire(key: string;expiration: Integer;block: Boolean;CmdReturn: TBoolCmdReturn); overload;
    procedure Expire(key: string;expiration: Integer;block: Boolean;CmdReturn: TBoolCmdReturnA); overload;
    procedure Expire(key: string;expiration: Integer;block: Boolean;CmdReturn: TBoolCmdReturnG); overload;
    procedure ExpireAt(key: string;atTime: TDateTime;block: Boolean;CmdReturn: TBoolCmdReturn); overload;
    procedure ExpireAt(key: string;atTime: TDateTime;block: Boolean;CmdReturn: TBoolCmdReturnA); overload;
    procedure ExpireAt(key: string;atTime: TDateTime;block: Boolean;CmdReturn: TBoolCmdReturnG); overload;

    procedure PExpire(key: string;expiration: Integer;block: Boolean;CmdReturn: TBoolCmdReturn); overload;
    procedure PExpire(key: string;expiration: Integer;block: Boolean;CmdReturn: TBoolCmdReturnA); overload;
    procedure PExpire(key: string;expiration: Integer;block: Boolean;CmdReturn: TBoolCmdReturnG); overload;
    procedure PExpireAt(key: string;atTime: TDateTime;block: Boolean;CmdReturn: TBoolCmdReturn); overload;
    procedure PExpireAt(key: string;atTime: TDateTime;block: Boolean;CmdReturn: TBoolCmdReturnA); overload;
    procedure PExpireAt(key: string;atTime: TDateTime;block: Boolean;CmdReturn: TBoolCmdReturnG); overload;

    procedure Move(key: string;db: Integer;block: Boolean;CmdReturn: TBoolCmdReturn); overload;
    procedure Move(key: string;db: Integer;block: Boolean;CmdReturn: TBoolCmdReturnA); overload;
    procedure Move(key: string;db: Integer;block: Boolean;CmdReturn: TBoolCmdReturnG); overload;

    procedure Persist(key: string;block: Boolean;CmdReturn: TBoolCmdReturn); overload;
    procedure Persist(key: string;block: Boolean;CmdReturn: TBoolCmdReturnA); overload;
    procedure Persist(key: string;block: Boolean;CmdReturn: TBoolCmdReturnG); overload;

    procedure RenameNX(key,newKey: string;block: Boolean;CmdReturn: TBoolCmdReturn); overload;
    procedure RenameNX(key,newKey: string;block: Boolean;CmdReturn: TBoolCmdReturnA); overload;
    procedure RenameNX(key,newKey: string;block: Boolean;CmdReturn: TBoolCmdReturnG); overload;

    procedure MSetNX(keyValues: array of TKeyValue; block: Boolean;CmdReturn: TBoolCmdReturn); overload;
    procedure MSetNX(keyValues: array of TKeyValue; block: Boolean;CmdReturn: TBoolCmdReturnA); overload;
    procedure MSetNX(keyValues: array of TKeyValue; block: Boolean;CmdReturn: TBoolCmdReturnG); overload;
    procedure MSetNX(keyValues: array of TRedisKeyValue; block: Boolean;CmdReturn: TBoolCmdReturn); overload;
    procedure MSetNX(keyValues: array of TRedisKeyValue; block: Boolean;CmdReturn: TBoolCmdReturnA); overload;
    procedure MSetNX(keyValues: array of TRedisKeyValue; block: Boolean;CmdReturn: TBoolCmdReturnG); overload;

    procedure SetNX(key,value: string;expiration: Integer; block: Boolean;CmdReturn: TBoolCmdReturn); overload;
    procedure SetNX(key,value: string;expiration: Integer; block: Boolean;CmdReturn: TBoolCmdReturnA); overload;
    procedure SetNX(key,value: string;expiration: Integer; block: Boolean;CmdReturn: TBoolCmdReturnG); overload;
    procedure SetNX(key: string;valueBuffer: PByte;buffLen,expiration: Integer; block: Boolean;CmdReturn: TBoolCmdReturn); overload;
    procedure SetNX(key: string;valueBuffer: PByte;buffLen,expiration: Integer; block: Boolean;CmdReturn: TBoolCmdReturnA); overload;
    procedure SetNX(key: string;valueBuffer: PByte;buffLen,expiration: Integer; block: Boolean;CmdReturn: TBoolCmdReturnG); overload;

    procedure SetXX(key,value: string;expiration: Integer; block: Boolean;CmdReturn: TBoolCmdReturn); overload;
    procedure SetXX(key,value: string;expiration: Integer; block: Boolean;CmdReturn: TBoolCmdReturnA); overload;
    procedure SetXX(key,value: string;expiration: Integer; block: Boolean;CmdReturn: TBoolCmdReturnG); overload;
    procedure SetXX(key: string;valueBuffer: PByte;buffLen,expiration: Integer; block: Boolean;CmdReturn: TBoolCmdReturn); overload;
    procedure SetXX(key: string;valueBuffer: PByte;buffLen,expiration: Integer; block: Boolean;CmdReturn: TBoolCmdReturnA); overload;
    procedure SetXX(key: string;valueBuffer: PByte;buffLen,expiration: Integer; block: Boolean;CmdReturn: TBoolCmdReturnG); overload;

    procedure HExists(key,field: string;block: Boolean;CmdReturn: TBoolCmdReturn); overload;
    procedure HExists(key,field: string;block: Boolean;CmdReturn: TBoolCmdReturnA); overload;
    procedure HExists(key,field: string;block: Boolean;CmdReturn: TBoolCmdReturnG); overload;

    procedure HMSet(Key: string;keyValues: array of TKeyValue; block: Boolean;CmdReturn: TBoolCmdReturn); overload;
    procedure HMSet(Key: string;keyValues: array of TKeyValue; block: Boolean;CmdReturn: TBoolCmdReturnA); overload;
    procedure HMSet(Key: string;keyValues: array of TKeyValue; block: Boolean;CmdReturn: TBoolCmdReturnG); overload;
    procedure HMSet(Key: string;keyValues: array of TRedisKeyValue; block: Boolean;CmdReturn: TBoolCmdReturn); overload;
    procedure HMSet(Key: string;keyValues: array of TRedisKeyValue; block: Boolean;CmdReturn: TBoolCmdReturnA); overload;
    procedure HMSet(Key: string;keyValues: array of TRedisKeyValue; block: Boolean;CmdReturn: TBoolCmdReturnG); overload;

    procedure HSetNX(key,field,value: string;block: Boolean;CmdReturn: TBoolCmdReturn); overload;
    procedure HSetNX(key,field,value: string;block: Boolean;CmdReturn: TBoolCmdReturnA); overload;
    procedure HSetNX(key,field,value: string;block: Boolean;CmdReturn: TBoolCmdReturnG); overload;
    procedure HSetNX(key,field: string;valueBuffer: PByte;buffLen: Integer; block: Boolean;CmdReturn: TBoolCmdReturn); overload;
    procedure HSetNX(key,field: string;valueBuffer: PByte;buffLen: Integer; block: Boolean;CmdReturn: TBoolCmdReturnA); overload;
    procedure HSetNX(key,field: string;valueBuffer: PByte;buffLen: Integer; block: Boolean;CmdReturn: TBoolCmdReturnG); overload;

    procedure SIsMember(key,value: string;block: Boolean;CmdReturn: TBoolCmdReturn); overload;
    procedure SIsMember(key,value: string;block: Boolean;CmdReturn: TBoolCmdReturnA); overload;
    procedure SIsMember(key,value: string;block: Boolean;CmdReturn: TBoolCmdReturnG); overload;
    procedure SIsMember(key: string;valueBuffer: PByte;buffLen: Integer; block: Boolean;CmdReturn: TBoolCmdReturn); overload;
    procedure SIsMember(key: string;valueBuffer: PByte;buffLen: Integer; block: Boolean;CmdReturn: TBoolCmdReturnA); overload;
    procedure SIsMember(key: string;valueBuffer: PByte;buffLen: Integer; block: Boolean;CmdReturn: TBoolCmdReturnG); overload;

    procedure SMove(source, destination,member: string;block: Boolean;CmdReturn: TBoolCmdReturn); overload;
    procedure SMove(source, destination,member: string;block: Boolean;CmdReturn: TBoolCmdReturnA); overload;
    procedure SMove(source, destination,member: string;block: Boolean;CmdReturn: TBoolCmdReturnG); overload;
    procedure SMove(source, destination: string;member: PByte;memberLen: Integer; block: Boolean;CmdReturn: TBoolCmdReturn); overload;
    procedure SMove(source, destination: string;member: PByte;memberLen: Integer; block: Boolean;CmdReturn: TBoolCmdReturnA); overload;
    procedure SMove(source, destination: string;member: PByte;memberLen: Integer; block: Boolean;CmdReturn: TBoolCmdReturnG); overload;

    procedure ClientPause(pauseTime: Integer;block: Boolean;CmdReturn: TBoolCmdReturn); overload;
    procedure ClientPause(pauseTime: Integer;block: Boolean;CmdReturn: TBoolCmdReturnA); overload;
    procedure ClientPause(pauseTime: Integer;block: Boolean;CmdReturn: TBoolCmdReturnG); overload;

    property RedisSdkManager: TDxRedisSdkManager read FRedisSdkManager
      write SetRedisSdkManager;
    property DefaultDBIndex: Byte read FDefaultDBIndex write SetDefaultDBIndex;
    property Password: string read FPassword write SetPassword;
    property DialTimeout: Byte read FDialTimeout write SetDialTimeout;
    property ReadTimeout: Byte read FReadTimeout write SetReadTimeout;
    property WriteTimeout: Byte read FWriteTimeout write SetWriteTimeout;
    property MaxRetry: Byte read FMaxRetry write SetMaxRetry;
    property Username: string read FUserName write SetUserName;
    property Address: string read FAddress write SetAddress;
    property ConStyle: TRedisConStyle read FConStyle write SetConStyle; // 连接
  end;

  TxAddArgs = record
    stream: Pointer;
    MaxLen: Int64;
    MaxLenApprox: Int64;
    ID: Pointer;
    Value: Pointer;
    VLen: Integer;
  end;

  PxAddArgs = ^TxAddArgs;

  TRedisLogEvent = procedure(Sender: Tobject; logLevel: TRedisLogLevel;
    logMsg: string) of object;

  TDxRedisSdkManager = class
  private
    FDllHandle: THandle;
  protected
    FInitRedisSdk: procedure(sdkData: PRedisSDKData); stdcall;
    FFreeRedisSdk: procedure(); stdcall;
    FNewRedisConnection: function(cfgData: PRedisConfig): Pointer; stdcall;
    FFreeRedisConnection: procedure(redisClient: Pointer); stdcall;
    FPing: procedure(ClientData: Pointer; block: Boolean;
      resultCallBack: TstatusCmdCallback; params: Pointer); stdcall;
    FTTL: procedure(ClientData: Pointer;Key: Pchar; block: Boolean;
      resultCallBack: TIntCmdCallBack; params: Pointer); stdcall;
    FSelect: procedure(pipeData: Pointer; dbIndex: Integer;
      resultCallBack: TstatusCmdCallback; params: Pointer); stdcall;
    FRename: procedure(ClientData: Pointer; Key, NewKey: PChar; block: Boolean;
      resultCallBack: TstatusCmdCallback; params: Pointer); stdcall;
    FMigrate: procedure(redisClient: Pointer; host, port, Key: PChar;
      db, timeout: Integer; block: Boolean; resultCallBack: TstatusCmdCallback;
      params: Pointer); stdcall;
    FRestore: procedure(redisClient: Pointer; Key, Value: PChar; ttl: Integer;
      block: Boolean; resultCallBack: TstatusCmdCallback;
      params: Pointer); stdcall;
    FRestoreReplace: procedure(redisClient: Pointer; Key, Value: PChar;
      ttl: Integer; block: Boolean; resultCallBack: TstatusCmdCallback;
      params: Pointer); stdcall;
    FType: procedure(redisClient: Pointer; Key: PChar; block: Boolean;
      resultCallBack: TstatusCmdCallback; params: Pointer); stdcall;
    FMSet: procedure(redisClient: Pointer; keyValueArray: PRedisKeyValue;
      arrLen: Integer; block: Boolean; resultCallBack: TstatusCmdCallback;
      params: Pointer); stdcall;
    FSet: procedure(redisClient: Pointer; Key: PChar; Value: Pointer;
      byteLen, expiration: Integer; block: Boolean;
      resultCallBack: TstatusCmdCallback; params: Pointer); stdcall;
    FSetArgs: procedure(redisClient: Pointer; Key: PChar; Value: Pointer;
      byteLen: Integer; SetArgs: PsetArgs; block: Boolean;
      resultCallBack: TstatusCmdCallback; params: Pointer); stdcall;
    FSetEx: procedure(redisClient: Pointer; Key: PChar; Value: Pointer;
      byteLen, expiration: Integer; block: Boolean;
      resultCallBack: TstatusCmdCallback; params: Pointer); stdcall;
    FLSet: procedure(redisClient: Pointer; Key: PChar; index: Int64;
      Value: Pointer; byteLen: Integer; block: Boolean;
      resultCallBack: TstatusCmdCallback; params: Pointer); stdcall;
    FLTrim: procedure(redisClient: Pointer; Key: PChar; Start, stop: Int64;
      block: Boolean; resultCallBack: TstatusCmdCallback;
      params: Pointer); stdcall;
    FScriptFlush: procedure(redisClient: Pointer; block: Boolean;
      resultCallBack: TstatusCmdCallback; params: Pointer); stdcall;
    FScriptKill: procedure(redisClient: Pointer; block: Boolean;
      resultCallBack: TstatusCmdCallback; params: Pointer); stdcall;
    FScriptLoad: procedure(redisClient: Pointer; script: PChar; block: Boolean;
      resultCallBack: TstatusCmdCallback; params: Pointer); stdcall;
    FScan: procedure(redisClient: Pointer; cursor: UInt64; match: PChar;
      count: Int64; block: Boolean; resultCallBack: TScanCmdCallback;
      params: Pointer); stdcall;
    FScanType: procedure(redisClient: Pointer; cursor: UInt64;
      match, KeyType: PChar; count: Int64; block: Boolean;
      resultCallBack: TScanCmdCallback; params: Pointer); stdcall;
    FSelectAndScan: procedure(redisClient: Pointer; index, count: Integer;
      match, KeyType: PChar; block: Boolean; resultCallBack: TScanCmdCallback;
      params: Pointer); stdcall;
    FSScan: procedure(redisClient: Pointer; cursor: UInt64; Key, match: PChar;
      count: Int64; block: Boolean; resultCallBack: TScanCmdCallback;
      params: Pointer); stdcall;
    FHScan: procedure(redisClient: Pointer; cursor: UInt64; Key, match: PChar;
      count: Int64; block: Boolean; resultCallBack: TScanCmdCallback;
      params: Pointer); stdcall;
    FZScan: procedure(redisClient: Pointer; cursor: UInt64; Key, match: PChar;
      count: Int64; block: Boolean; resultCallBack: TScanCmdCallback;
      params: Pointer); stdcall;
    FGet: procedure(redisClient: Pointer; Key: PChar;
      isByteRetur, block: Boolean; resultCallBack: TStringCmdCallback;
      params: Pointer); stdcall;
    FGetRange: procedure(redisClient: Pointer; Key: PChar; Start, stop: Int64;
      isByteReturn, block: Boolean; resultCallBack: TStringCmdCallback;
      params: Pointer); stdcall;
    FGetSet: procedure(redisClient: Pointer; Key: PChar; Value: Pointer;
      byteLen: Integer; block: Boolean; resultCallBack: TStringCmdCallback;
      params: Pointer); stdcall;
    FGetEx: procedure(redisClient: Pointer; Key: PChar; expiration: Integer;
      isByteReturn, block: Boolean; resultCallBack: TStringCmdCallback;
      params: Pointer); stdcall;
    FGetDel: procedure(redisClient: Pointer; Key: PChar;
      isByteReturn, block: Boolean; resultCallBack: TStringCmdCallback;
      params: Pointer); stdcall;
    FHGet: procedure(redisClient: Pointer; Key, field: PChar;
      isByteReturn, block: Boolean; resultCallBack: TStringCmdCallback;
      params: Pointer); stdcall;
    FBRPopLPush: procedure(redisClient: Pointer; src, dst: PChar;
      timeout: Integer; isByteReturn, block: Boolean;
      resultCallBack: TStringCmdCallback; params: Pointer); stdcall;
    FRPopLPush: procedure(redisClient: Pointer; src, dst: PChar;
      isByteReturn, block: Boolean; resultCallBack: TStringCmdCallback;
      params: Pointer); stdcall;
    FLIndex: procedure(redisClient: Pointer; Key: PChar; index: Int64;
      isByteReturn, block: Boolean; resultCallBack: TStringCmdCallback;
      params: Pointer); stdcall;
    FLPop: procedure(redisClient: Pointer; Key: PChar;
      isByteReturn, block: Boolean; resultCallBack: TStringCmdCallback;
      params: Pointer); stdcall;
    FRPop: procedure(redisClient: Pointer; Key: PChar;
      isByteReturn, block: Boolean; resultCallBack: TStringCmdCallback;
      params: Pointer); stdcall;
    FSPop: procedure(redisClient: Pointer; Key: PChar;
      isByteReturn, block: Boolean; resultCallBack: TStringCmdCallback;
      params: Pointer); stdcall;
    FSRandMember: procedure(redisClient: Pointer; Key: PChar;
      isByteReturn, block: Boolean; resultCallBack: TStringCmdCallback;
      params: Pointer); stdcall;
    FClientList: procedure(redisClient: Pointer; block: Boolean;
      resultCallBack: TStringCmdCallback; params: Pointer); stdcall;
    FInfo: procedure(redisClient: Pointer; sections: PChar; block: Boolean;
      resultCallBack: TStringCmdCallback; params: Pointer); stdcall;
    FXAdd: procedure(redisClient: Pointer; args: PxAddArgs; block: Boolean;
      resultCallBack: TStringCmdCallback; params: Pointer); stdcall;
    FDel: procedure(redisClient: Pointer; keys: PChar; block: Boolean;
      resultCallBack: TIntCmdCallBack; params: Pointer); stdcall;
    FUnlink: procedure(redisClient: Pointer; keys: PChar; block: Boolean;
      resultCallBack: TIntCmdCallBack; params: Pointer); stdcall;
    FExists: procedure(redisClient: Pointer; keys: PChar; block: Boolean;
      resultCallBack: TIntCmdCallBack; params: Pointer); stdcall;
    FObjectRefCount: procedure(redisClient: Pointer; Key: PChar; block: Boolean;
      resultCallBack: TIntCmdCallBack; params: Pointer); stdcall;
    FTouch: procedure(redisClient: Pointer; keys: PChar; block: Boolean;
      resultCallBack: TIntCmdCallBack; params: Pointer); stdcall;
    FAppend: procedure(redisClient: Pointer; Key, Value: PChar; block: Boolean;
      resultCallBack: TIntCmdCallBack; params: Pointer); stdcall;
    FDecr: procedure(redisClient: Pointer; Key: PChar; block: Boolean;
      resultCallBack: TIntCmdCallBack; params: Pointer); stdcall;
    FDecrBy: procedure(redisClient: Pointer; Key: PChar; decrement: Int64;
      block: Boolean; resultCallBack: TIntCmdCallBack;
      params: Pointer); stdcall;
    FIncr: procedure(redisClient: Pointer; Key: PChar; block: Boolean;
      resultCallBack: TIntCmdCallBack; params: Pointer); stdcall;
    FIncrBy: procedure(redisClient: Pointer; Key: PChar; increment: Int64;
      block: Boolean; resultCallBack: TIntCmdCallBack;
      params: Pointer); stdcall;
    FStrLen: procedure(redisClient: Pointer; Key: PChar; block: Boolean;
      resultCallBack: TIntCmdCallBack; params: Pointer); stdcall;
    FSetRange: procedure(redisClient: Pointer; Key: PChar; offset: Int64;
      Value: PChar; block: Boolean; resultCallBack: TIntCmdCallBack;
      params: Pointer); stdcall;
    FGetBit: procedure(redisClient: Pointer; Key: PChar; offset: Int64;
      block: Boolean; resultCallBack: TIntCmdCallBack;
      params: Pointer); stdcall;
    FSetBit: procedure(redisClient: Pointer; Key: PChar; offset: Int64;
      Value: Integer; block: Boolean; resultCallBack: TIntCmdCallBack;
      params: Pointer); stdcall;
    FBitCount: procedure(redisClient: Pointer; Key: PChar; BitCount: PBitCount;
      block: Boolean; resultCallBack: TIntCmdCallBack;
      params: Pointer); stdcall;
    FBitOpAnd: procedure(redisClient: Pointer; destKey, keys: PChar;
      block: Boolean; resultCallBack: TIntCmdCallBack;
      params: Pointer); stdcall;
    FBitOpOr: procedure(redisClient: Pointer; destKey, keys: PChar;
      block: Boolean; resultCallBack: TIntCmdCallBack;
      params: Pointer); stdcall;
    FBitOpXor: procedure(redisClient: Pointer; destKey, keys: PChar;
      block: Boolean; resultCallBack: TIntCmdCallBack;
      params: Pointer); stdcall;
    FBitOpNot: procedure(redisClient: Pointer; destKey, keys: PChar;
      block: Boolean; resultCallBack: TIntCmdCallBack;
      params: Pointer); stdcall;
    FBitPos: procedure(redisClient: Pointer; Key: PChar; bit: Int64;
      BitPos: PInt64; posLen: Integer; block: Boolean;
      resultCallBack: TIntCmdCallBack; params: Pointer); stdcall;
    FHDel: procedure(redisClient: Pointer; Key, fields: PChar; block: Boolean;
      resultCallBack: TIntCmdCallBack; params: Pointer); stdcall;
    FHIncrBy: procedure(redisClient: Pointer; Key, field: PChar; Incr: Int64;
      block: Boolean; resultCallBack: TIntCmdCallBack;
      params: Pointer); stdcall;
    FHLen: procedure(redisClient: Pointer; Key: PChar; block: Boolean;
      resultCallBack: TIntCmdCallBack; params: Pointer); stdcall;
    FHSet: procedure(redisClient: Pointer; Key: PChar;
      keyValueArr: PRedisKeyValue; arrLen: Integer; block: Boolean;
      resultCallBack: TIntCmdCallBack; params: Pointer); stdcall;
    FLInsert: procedure(redisClient: Pointer; Key: PChar; before: Boolean;
      pivot, Value: PChar; block: Boolean; resultCallBack: TIntCmdCallBack;
      params: Pointer); stdcall;
    FLInsertBefore: procedure(redisClient: Pointer; Key: PChar;
      pivot, Value: PChar; block: Boolean; resultCallBack: TIntCmdCallBack;
      params: Pointer); stdcall;
    FLInsertAfter: procedure(redisClient: Pointer; Key: PChar;
      pivot, Value: PChar; block: Boolean; resultCallBack: TIntCmdCallBack;
      params: Pointer); stdcall;
    FLLen: procedure(redisClient: Pointer; Key: PChar; block: Boolean;
      resultCallBack: TIntCmdCallBack; params: Pointer); stdcall;
    FLPos: procedure(redisClient: Pointer; Key, Value: PChar; args: PLPosArgs;
      block: Boolean; resultCallBack: TIntCmdCallBack;
      params: Pointer); stdcall;
    FLPush: procedure(redisClient: Pointer; Key: PChar;
      valueArr: PValueInterface; arrLen: Integer; block: Boolean;
      resultCallBack: TIntCmdCallBack; params: Pointer); stdcall;
    FLPushX: procedure(redisClient: Pointer; Key: PChar;
      valueArr: PValueInterface; arrLen: Integer; block: Boolean;
      resultCallBack: TIntCmdCallBack; params: Pointer); stdcall;
    FLRem: procedure(redisClient: Pointer; Key: PChar; count: Int64;
      Value: PValueInterface; block: Boolean; resultCallBack: TIntCmdCallBack;
      params: Pointer); stdcall;
    FRPush: procedure(redisClient: Pointer; Key: PChar;
      valueArr: PValueInterface; arrLen: Integer; block: Boolean;
      resultCallBack: TIntCmdCallBack; params: Pointer); stdcall;
    FRPushX: procedure(redisClient: Pointer; Key: PChar;
      valueArr: PValueInterface; arrLen: Integer; block: Boolean;
      resultCallBack: TIntCmdCallBack; params: Pointer); stdcall;
    FSAdd: procedure(redisClient: Pointer; Key: PChar;
      valueArr: PValueInterface; arrLen: Integer; block: Boolean;
      resultCallBack: TIntCmdCallBack; params: Pointer); stdcall;
    FSCard: procedure(redisClient: Pointer; Key: PChar; block: Boolean;
      resultCallBack: TIntCmdCallBack; params: Pointer); stdcall;
    FSDiffStore: procedure(redisClient: Pointer; destination, keys: PChar;
      block: Boolean; resultCallBack: TIntCmdCallBack;
      params: Pointer); stdcall;
    FSInterStore: procedure(redisClient: Pointer; destination, keys: PChar;
      block: Boolean; resultCallBack: TIntCmdCallBack;
      params: Pointer); stdcall;
    FSRem: procedure(redisClient: Pointer; Key: PChar;
      membersArr: PValueInterface; membersArrLen: Integer; block: Boolean;
      resultCallBack: TIntCmdCallBack; params: Pointer); stdcall;
    FSUnionStore: procedure(redisClient: Pointer; destination, keys: PChar;
      block: Boolean; resultCallBack: TIntCmdCallBack;
      params: Pointer); stdcall;
    FZAdd: procedure(redisClient: Pointer; Key: PChar; ZValueArr: PZValue;
      arrLen: Integer; block: Boolean; resultCallBack: TIntCmdCallBack;
      params: Pointer); stdcall;
    FZAddNX: procedure(redisClient: Pointer; Key: PChar; ZValueArr: PZValue;
      arrLen: Integer; block: Boolean; resultCallBack: TIntCmdCallBack;
      params: Pointer); stdcall;
    FZAddXX: procedure(redisClient: Pointer; Key: PChar; ZValueArr: PZValue;
      arrLen: Integer; block: Boolean; resultCallBack: TIntCmdCallBack;
      params: Pointer); stdcall;
    FZAddCh: procedure(redisClient: Pointer; Key: PChar; ZValueArr: PZValue;
      arrLen: Integer; block: Boolean; resultCallBack: TIntCmdCallBack;
      params: Pointer); stdcall;
    FZAddNXCh: procedure(redisClient: Pointer; Key: PChar; ZValueArr: PZValue;
      arrLen: Integer; block: Boolean; resultCallBack: TIntCmdCallBack;
      params: Pointer); stdcall;
    FZAddXXCh: procedure(redisClient: Pointer; Key: PChar; ZValueArr: PZValue;
      arrLen: Integer; block: Boolean; resultCallBack: TIntCmdCallBack;
      params: Pointer); stdcall;
    FZCard: procedure(redisClient: Pointer; Key: PChar; block: Boolean;
      resultCallBack: TIntCmdCallBack; params: Pointer); stdcall;
    FZCount: procedure(redisClient: Pointer; Key, min, max: PChar;
      block: Boolean; resultCallBack: TIntCmdCallBack;
      params: Pointer); stdcall;
    FZLexCount: procedure(redisClient: Pointer; Key, min, max: PChar;
      block: Boolean; resultCallBack: TIntCmdCallBack;
      params: Pointer); stdcall;
    FZRemRangeByRank: procedure(redisClient: Pointer; Key: PChar;
      Start, stop: Int64; block: Boolean; resultCallBack: TIntCmdCallBack;
      params: Pointer); stdcall;
    FZRank: procedure(redisClient: Pointer; Key, Member: PChar; block: Boolean;
      resultCallBack: TIntCmdCallBack; params: Pointer); stdcall;
    FZRem: procedure(redisClient: Pointer; Key: PChar;
      membersArr: PValueInterface; membersArrLen: Integer; block: Boolean;
      resultCallBack: TIntCmdCallBack; params: Pointer); stdcall;
    FZRemRangeByScore: procedure(redisClient: Pointer; Key, min, max: PChar;
      block: Boolean; resultCallBack: TIntCmdCallBack;
      params: Pointer); stdcall;
    FZRemRangeByLex: procedure(redisClient: Pointer; Key, min, max: PChar;
      block: Boolean; resultCallBack: TIntCmdCallBack;
      params: Pointer); stdcall;
    FNewPipeLiner: function(redisClient,PipeClient: Pointer; txPipeLine: Boolean)
      : Pointer; stdcall;
    FFreePipeLiner: procedure(pipeClient: Pointer); stdcall;
    FPipeExec: procedure(pipeClient: Pointer; block: Boolean;resultCallBack: TPipeExecCallBack;params: Pointer); stdcall;

    FExpire: procedure(clientData: Pointer;key: Pchar;expiration: Integer;block: Boolean;resultCallBack: TIntCmdCallBack;
      params: Pointer);stdcall;
    FExpireAt: procedure(clientData: Pointer;Key: PChar;time: TDateTime;block: Boolean;resultCallBack: TIntCmdCallBack;
      params: Pointer);stdcall;
    FMove: procedure(clientData: Pointer;key: Pchar;db: Integer;block: Boolean;resultCallBack: TIntCmdCallBack;
      params: Pointer);stdcall;
    FPExpire: procedure(clientData: Pointer;key: Pchar;expiration: Integer;block: Boolean;resultCallBack: TIntCmdCallBack;
      params: Pointer);stdcall;
    FPExpireAt: procedure(clientData: Pointer;Key: PChar;time: TDateTime;block: Boolean;resultCallBack: TIntCmdCallBack;
      params: Pointer);stdcall;
    FPersist: procedure(clientData: Pointer;Key: PChar;block: Boolean;resultCallBack: TIntCmdCallBack;params: Pointer);stdcall;
    FRenameNX: procedure(clientData: Pointer;key,newKey: Pchar;block: Boolean;resultCallBack: TIntCmdCallBack;params: Pointer);stdcall;
    FMSetNX: procedure(clientData: Pointer;keyValueArr: PRedisKeyValue; arrLen: Integer;block: Boolean;resultCallBack: TIntCmdCallBack;
      params: Pointer);stdcall;
    FSetNX: procedure(clientData: Pointer;key: Pchar;value: Pointer;byteLen,expiration: Integer;block: Boolean;resultCallBack: TIntCmdCallBack;
      params: Pointer);stdcall;
    FSetXX: procedure(clientData: Pointer;key: Pchar;value: Pointer;byteLen,expiration: Integer;block: Boolean;resultCallBack: TIntCmdCallBack;
      params: Pointer);stdcall;
    FHExists: procedure(clientData: Pointer;key,field: Pchar;block: Boolean;resultCallBack: TIntCmdCallBack;params: Pointer);stdcall;
    FHMSet: procedure(clientData: Pointer;key: PChar;keyValueArr: PRedisKeyValue; arrLen: Integer;block: Boolean;resultCallBack: TIntCmdCallBack;
      params: Pointer);stdcall;
    FHSetNX: procedure(clientData: Pointer;key,field: PChar;value: Pointer;byteLen: integer;block: Boolean;resultCallBack: TIntCmdCallBack;
      params: Pointer);stdcall;
    FSIsMember: procedure(clientData: Pointer;key: PChar;member: Pointer;byteLen: Integer;block: Boolean;resultCallBack: TIntCmdCallBack;
      params: Pointer);stdcall;
    FSMove: procedure(clientData: Pointer;source,destination: PChar;member: Pointer;byteLen: Integer;block: Boolean;resultCallBack: TIntCmdCallBack;
      params: Pointer);stdcall;
    FClientPause: procedure(clientData: Pointer;pauseTimes: integer;block: Boolean;resultCallBack: TIntCmdCallBack;params: Pointer);stdcall;

    FOnLog: TRedisLogEvent;
    FAsynWnd: THandle;
    FFirst, FLast: PSynWndMessageItem;
    FLocker: Tobject;
    FPointerPool: TQSimplePool;
    FDllPath: string;
    FClients: TList;
    function GetActive: Boolean;
    procedure SetDll(const Value: string);
    function GetCount: Integer;
    function GetClients(index: Integer): TDxRedisClient;
  protected
    procedure DoRedisLogEvent(Sender: Tobject; logLevel: TRedisLogLevel;
      logMsg: string);
    procedure AsynWndProc(var AMsg: TMessage); virtual;
    procedure InitSDK; virtual;
    procedure PostRedisMsg(redisCmd: TWndMsgCmd; params: Pointer);
    procedure InitDll(DllPath: string);
    procedure ProcessRedisMsgs;
    procedure DoStatusCmdMsg(statusRecord: Pointer);
    procedure DoScanCmdMsg(scanResult: Pointer);
    procedure DoSelectScanCmdMsg(scanResult: Pointer);
    procedure DoStringCmdMsg(strResult: Pointer);
    procedure DoIntCmdMsg(intResult: Pointer);
    procedure DoBoolCmdMsg(boolResult: Pointer);
    procedure DoPipeCmdMsg(pipeResult: Pointer);
    procedure Wakeup; inline;

  public
    constructor Create;
    destructor Destroy; override;
    property Active: Boolean read GetActive;
    property DllPath: string write SetDll;
    property OnLog: TRedisLogEvent read FOnLog write FOnLog;
    property count: Integer read GetCount;
    property Clients[index: Integer]: TDxRedisClient read GetClients;
    procedure DisConnectAll;
  end;

implementation
uses cmdCallBack;

procedure selectAndScanCmdResult(redisClient, params: Pointer; keys: PChar;
  cursor: Int64; IsErrResult: Boolean); stdcall;
var
  client: TDxRedisClient absolute redisClient;
  errMsg: string;
  keyArray: array of string;
  l: Integer;
  p: PChar;
  scanCmdResult: PRedisScanResult;
begin
  if GetCurrentThreadId <> MainThreadID then
  begin
    New(scanCmdResult);
    scanCmdResult^.client := redisClient;
    scanCmdResult^.IsErrResult := IsErrResult;
    scanCmdResult^.params := params;
    scanCmdResult^.keys := StrPas(keys);
    scanCmdResult^.cursor := cursor;
    client.RedisSdkManager.PostRedisMsg(MC_SelectScan, scanCmdResult);
  end
  else
  begin
    if PSelectCmdMethod(params)^.Method.Code <> nil then
    begin
      if IsErrResult then
      begin
        SetLength(keyArray, 0);
        errMsg := StrPas(keys);
      end
      else
      begin
        errMsg := '';
        SetLength(keyArray, 4);
        l := 0;
        p := keys;
        repeat
          keyArray[l] := DecodeTokenW(p, #13#10, #0, False);
          Inc(l);
          if (l = Length(keyArray)) and (p^ <> #0) then
            SetLength(keyArray, l + 4);
        until p^ = #0;
        SetLength(keyArray, l);
      end;

      if PSelectCmdMethod(params)^.Method.Data = nil then
        TRedisSelectScanCmdReturnG(PSelectCmdMethod(params)^.Method.Code)
          (PSelectCmdMethod(params)^.DBIndex, keyArray, cursor, errMsg)
      else if PSelectCmdMethod(params)^.Method.Data = Pointer(-1) then
      begin
        TRedisSelectScanCmdReturnA(PSelectCmdMethod(params)^.Method.Code)
          (PSelectCmdMethod(params)^.DBIndex, keyArray, cursor, errMsg);
        PSelectCmdMethod(params)^.Method.Code := nil;
      end
      else
        TRedisSelectScanCmdReturn(PSelectCmdMethod(params)^.Method)
          (client, PSelectCmdMethod(params)^.DBIndex, keyArray, cursor, errMsg);
    end;
    Dispose(params);
  end;
  AtomicDecrement(client.FRunningCount, 1);
end;

{ TDxRedisSdkManager }

procedure TDxRedisSdkManager.AsynWndProc(var AMsg: TMessage);
begin
  if AMsg.Msg = WM_APP then
    ProcessRedisMsgs
  else
    AMsg.Result := DefWindowProc(FAsynWnd, AMsg.Msg, AMsg.WParam, AMsg.LParam);
end;

constructor TDxRedisSdkManager.Create;
begin
  inherited Create;
  FClients := TList.Create;
  FLocker := Tobject.Create;
  FPointerPool := TQSimplePool.Create(200, Sizeof(TSynWndMessageItem));
end;

destructor TDxRedisSdkManager.Destroy;
begin
  if FDllHandle <> 0 then
  begin
    FFreeRedisSdk;
    // FreeLibrary(FDllHandle);
  end;
  if FAsynWnd <> 0 then
    DeallocateHWnd(FAsynWnd);
  FPointerPool.Free;
  FLocker.Free;
  FClients.Free;
  inherited;
end;

procedure TDxRedisSdkManager.DisConnectAll;
begin
  while FClients.count > 0 do
    TDxRedisClient(FClients.Items[FClients.count - 1]).Free;
end;

procedure TDxRedisSdkManager.DoBoolCmdMsg(boolResult: Pointer);
var
  bResult: PRedisIntResult;
begin
  bResult := boolResult;
  if PMethod(bResult^.params)^.Code <> nil then
  begin
    if PMethod(bResult^.params)^.Data = nil then
      TBoolCmdReturnG(PMethod(bResult^.params)^.Code)(bResult^.CmdResult = 1, bResult^.errMsg)
    else if PMethod(bResult^.params)^.Data = Pointer(-1) then
    begin
      TBoolCmdReturnA(PMethod(bResult^.params)^.Code)(bResult^.CmdResult = 1, bResult^.errMsg);
      PMethod(bResult^.params)^.Code := nil;
    end
    else
      TBoolCmdReturn(PMethod(bResult^.params)^)(bResult^.client, bResult^.CmdResult = 1, bResult^.errMsg);
  end;
  Dispose(bResult^.params);
end;

procedure TDxRedisSdkManager.DoIntCmdMsg(intResult: Pointer);
var
  iResult: PRedisIntResult;
begin
  iResult := intResult;
  if PMethod(iResult^.params)^.Code <> nil then
  begin
    if PMethod(iResult^.params)^.Data = nil then
      TIntCmdReturnG(PMethod(iResult^.params)^.Code)
        (iResult^.CmdResult, iResult^.errMsg)
    else if PMethod(iResult^.params)^.Data = Pointer(-1) then
    begin
      TIntCmdReturnA(PMethod(iResult^.params)^.Code)
        (iResult^.CmdResult, iResult^.errMsg);
      PMethod(iResult^.params)^.Code := nil;
    end
    else
      TIntCmdReturn(PMethod(iResult^.params)^)
        (iResult^.client, iResult^.CmdResult, iResult^.errMsg);
  end;
  Dispose(iResult^.params);
end;

procedure TDxRedisSdkManager.DoPipeCmdMsg(pipeResult: Pointer);
var
  statusResult: PRedisStatusResult;
begin
  statusResult := pipeResult;
  if PMethod(statusResult^.params)^.Code <> nil then
  begin
    if PMethod(statusResult^.params)^.Data = nil then
      TPipelineExecReturnG(PMethod(statusResult^.params)^.Code)(statusResult^.CmdResult)
    else if PMethod(statusResult^.params)^.Data = Pointer(-1) then
    begin
      TPipelineExecReturnA(PMethod(statusResult^.params)^.Code)(statusResult^.CmdResult);
      PMethod(statusResult^.params)^.Code := nil;
    end
    else
      TPipelineExecReturn(PMethod(statusResult^.params)^)(statusResult^.client,statusResult^.CmdResult);
  end;
  Dispose(statusResult^.params);
end;

procedure TDxRedisSdkManager.DoRedisLogEvent(Sender: Tobject;
  logLevel: TRedisLogLevel; logMsg: string);
begin
  if Assigned(FOnLog) then
    FOnLog(self, logLevel, logMsg);
end;

procedure TDxRedisSdkManager.DoScanCmdMsg(scanResult: Pointer);
var
  sResult: PRedisScanResult;
  errMsg: string;
  keyArray: array of string;
  l: Integer;
  p: PChar;
begin
  sResult := scanResult;
  if PMethod(sResult^.params)^.Code <> nil then
  begin
    if sResult^.IsErrResult then
    begin
      SetLength(keyArray, 0);
      errMsg := sResult^.keys;
    end
    else
    begin
      errMsg := '';
      SetLength(keyArray, 4);
      l := 0;
      p := PChar(sResult^.keys);
      repeat
        keyArray[l] := DecodeTokenW(p, #13#10, #0, False);
        Inc(l);
        if (l = Length(keyArray)) and (p^ <> #0) then
          SetLength(keyArray, l + 4);
      until p^ = #0;
      SetLength(keyArray, l);
    end;
    if PMethod(sResult^.params)^.Data = nil then
      TRedisScanCmdReturnG(PMethod(sResult^.params)^.Code)
        (keyArray, sResult^.cursor, errMsg)
    else if PMethod(sResult^.params)^.Data = Pointer(-1) then
    begin
      TRedisScanCmdReturnA(PMethod(sResult^.params)^.Code)
        (keyArray, sResult^.cursor, errMsg);
      TRedisScanCmdReturnA(PMethod(sResult^.params)^.Code) := nil;
    end
    else
      TRedisScanCmdReturn(PMethod(sResult^.params)^)(sResult^.client, keyArray,
        sResult^.cursor, errMsg);
  end;
  Dispose(sResult^.params);
end;

procedure TDxRedisSdkManager.DoSelectScanCmdMsg(scanResult: Pointer);
var
  sResult: PRedisScanResult;
  errMsg: string;
  keyArray: array of string;
  l: Integer;
  p: PChar;
begin
  sResult := scanResult;
  if PSelectCmdMethod(sResult^.params)^.Method.Code <> nil then
  begin
    if sResult^.IsErrResult then
    begin
      SetLength(keyArray, 0);
      errMsg := sResult^.keys;
    end
    else
    begin
      errMsg := '';
      SetLength(keyArray, 4);
      l := 0;
      p := PChar(sResult^.keys);
      repeat
        keyArray[l] := DecodeTokenW(p, #13#10, #0, False);
        Inc(l);
        if (l = Length(keyArray)) and (p^ <> #0) then
          SetLength(keyArray, l + 4);
      until p^ = #0;
      SetLength(keyArray, l);
    end;
    if PSelectCmdMethod(sResult^.params)^.Method.Data = nil then
      TRedisSelectScanCmdReturnG(PSelectCmdMethod(sResult^.params)^.Method.Code)
        (PSelectCmdMethod(sResult^.params)^.DBIndex, keyArray,
        sResult^.cursor, errMsg)
    else if PSelectCmdMethod(sResult^.params)^.Method.Data = Pointer(-1) then
    begin
      TRedisSelectScanCmdReturnA(PSelectCmdMethod(sResult^.params)^.Method.Code)
        (PSelectCmdMethod(sResult^.params)^.DBIndex, keyArray,
        sResult^.cursor, errMsg);
      PSelectCmdMethod(sResult^.params)^.Method.Code := nil;
    end
    else
      TRedisSelectScanCmdReturn(PSelectCmdMethod(sResult^.params)^.Method)
        (sResult^.client, PSelectCmdMethod(sResult^.params)^.DBIndex, keyArray,
        sResult^.cursor, errMsg);
  end;
  Dispose(sResult^.params);
end;

procedure TDxRedisSdkManager.DoStatusCmdMsg(statusRecord: Pointer);
var
  statusResult: PRedisStatusResult;
begin
  statusResult := statusRecord;
  if PMethod(statusResult^.params)^.Code <> nil then
  begin
    if PMethod(statusResult^.params)^.Data = nil then
      TRedisStatusCmdG(PMethod(statusResult^.params)^.Code)
        (statusResult^.CmdResult, statusResult^.IsErrResult)
    else if PMethod(statusResult^.params)^.Data = Pointer(-1) then
    begin
      TRedisStatusCmdA(PMethod(statusResult^.params)^.Code)
        (statusResult^.CmdResult, statusResult^.IsErrResult);
      TRedisStatusCmdA(PMethod(statusResult^.params)^.Code) := nil;
    end
    else
      TRedisStatusCmd(PMethod(statusResult^.params)^)(statusResult^.client,
        statusResult^.CmdResult, statusResult^.IsErrResult);
  end;
  Dispose(statusResult^.params);
end;

procedure TDxRedisSdkManager.DoStringCmdMsg(strResult: Pointer);
var
  strMethod: PStringCmdMethod;
  strByteResult: PRedisStringByteResult;
begin
  strByteResult := strResult;
  strMethod := strByteResult^.params;
  try
    if strMethod^.Method.Code <> nil then
    begin
      if strMethod^.isByteReturn then
      begin
        if strMethod^.Method.Data = nil then
          TRedisStringCmdReturnByteG(strMethod^.Method.Code)
            (strByteResult^.Buffer, strByteResult^.BufferLen,
            strByteResult^.strValue)
        else if strMethod^.Method.Data = Pointer(-1) then
        begin
          TRedisStringCmdReturnByteA(strMethod^.Method.Code)
            (strByteResult^.Buffer, strByteResult^.BufferLen,
            strByteResult^.strValue);
          TRedisStringCmdReturnByteA(strMethod^.Method.Code) := nil;
        end
        else
          TRedisStringCmdReturnByte(strMethod^.Method)(strByteResult^.client,
            strByteResult^.Buffer, strByteResult^.BufferLen,
            strByteResult^.strValue);
      end
      else
      begin
        if strMethod^.Method.Data = nil then
          TRedisStringCmdReturnG(strMethod^.Method.Code)
            (strByteResult^.strValue, strByteResult^.IsErrResult)
        else if strMethod^.Method.Data = Pointer(-1) then
        begin
          TRedisStringCmdReturnA(strMethod^.Method.Code)
            (strByteResult^.strValue, strByteResult^.IsErrResult);
          TRedisStringCmdReturnA(strMethod^.Method.Code) := nil;
        end
        else
          TRedisStringCmdReturn(strMethod^.Method)(strByteResult^.client,
            strByteResult^.strValue, strByteResult^.IsErrResult);
      end;
    end;
  finally
    if strByteResult^.Buffer <> nil then
      FreeMemory(strByteResult^.Buffer);
    Dispose(strMethod);
  end;
end;

function TDxRedisSdkManager.GetActive: Boolean;
begin
  Result := FDllHandle > 0;
end;

function TDxRedisSdkManager.GetClients(index: Integer): TDxRedisClient;
begin
  if (index >= 0) and (index < FClients.count) then
    Result := FClients[index]
  else
    Result := nil;
end;

function TDxRedisSdkManager.GetCount: Integer;
begin
  Result := FClients.count;
end;

procedure TDxRedisSdkManager.InitDll(DllPath: string);
var
  H: THandle;
begin
  FDllHandle := LoadLibrary(PChar(DllPath));
  if FDllHandle > 0 then
  begin
    FInitRedisSdk := GetProcAddress(FDllHandle, 'InitRedisSdk');
    FFreeRedisSdk := GetProcAddress(FDllHandle, 'FreeRedisSdk');
    FNewRedisConnection := GetProcAddress(FDllHandle, 'NewRedisConnection');
    FFreeRedisConnection := GetProcAddress(FDllHandle, 'FreeRedisConnection');
    FPing := GetProcAddress(FDllHandle, 'Ping');
    FTTL := GetProcAddress(FDllHandle, 'TTL');
    FSelect := GetProcAddress(FDllHandle, 'Select');
    FRename := GetProcAddress(FDllHandle, 'Rename');
    FMigrate := GetProcAddress(FDllHandle, 'Migrate');
    FRestore := GetProcAddress(FDllHandle, 'Restore');
    FRestoreReplace := GetProcAddress(FDllHandle, 'RestoreReplace');
    FType := GetProcAddress(FDllHandle, 'Type');
    FMSet := GetProcAddress(FDllHandle, 'MSet');
    FSet := GetProcAddress(FDllHandle, 'Set');
    FSetArgs := GetProcAddress(FDllHandle, 'SetArgs');
    FSetEx := GetProcAddress(FDllHandle, 'SetEX');
    FLSet := GetProcAddress(FDllHandle, 'LSet');
    FLTrim := GetProcAddress(FDllHandle, 'LTrim');
    FScriptFlush := GetProcAddress(FDllHandle, 'ScriptFlush');
    FScriptKill := GetProcAddress(FDllHandle, 'ScriptKill');
    FScriptLoad := GetProcAddress(FDllHandle, 'ScriptLoad');
    FScan := GetProcAddress(FDllHandle, 'Scan');
    FScanType := GetProcAddress(FDllHandle, 'ScanType');
    FSelectAndScan := GetProcAddress(FDllHandle, 'SelectAndScan');
    FSScan := GetProcAddress(FDllHandle, 'SScan');
    FHScan := GetProcAddress(FDllHandle, 'HScan');
    FZScan := GetProcAddress(FDllHandle, 'ZScan');
    FGet := GetProcAddress(FDllHandle, 'Get');
    FGetRange := GetProcAddress(FDllHandle, 'GetRange');
    FGetSet := GetProcAddress(FDllHandle, 'GetSet');
    FGetEx := GetProcAddress(FDllHandle, 'GetEx');
    FGetDel := GetProcAddress(FDllHandle, 'GetDel');
    FHGet := GetProcAddress(FDllHandle, 'HGet');
    FBRPopLPush := GetProcAddress(FDllHandle, 'BRPopLPush');
    FLIndex := GetProcAddress(FDllHandle, 'LIndex');
    FLPop := GetProcAddress(FDllHandle, 'LPop');
    FRPop := GetProcAddress(FDllHandle, 'RPop');
    FRPopLPush := GetProcAddress(FDllHandle, 'RPopLPush');
    FSPop := GetProcAddress(FDllHandle, 'SPop');
    FSRandMember := GetProcAddress(FDllHandle, 'SRandMember');
    FClientList := GetProcAddress(FDllHandle, 'ClientList');
    FInfo := GetProcAddress(FDllHandle, 'Info');
    FXAdd := GetProcAddress(FDllHandle, 'XAdd');
    FDel := GetProcAddress(FDllHandle, 'Del');
    FUnlink := GetProcAddress(FDllHandle, 'Unlink');
    FExists := GetProcAddress(FDllHandle, 'Exists');
    FObjectRefCount := GetProcAddress(FDllHandle, 'ObjectRefCount');
    FTouch := GetProcAddress(FDllHandle, 'Touch');
    FAppend := GetProcAddress(FDllHandle, 'Append');
    FDecr := GetProcAddress(FDllHandle, 'Decr');
    FDecrBy := GetProcAddress(FDllHandle, 'DecrBy');
    FIncr := GetProcAddress(FDllHandle, 'Incr');
    FIncrBy := GetProcAddress(FDllHandle, 'IncrBy');
    FStrLen := GetProcAddress(FDllHandle, 'StrLen');
    FSetRange := GetProcAddress(FDllHandle, 'SetRange');
    FGetBit := GetProcAddress(FDllHandle, 'GetBit');
    FSetBit := GetProcAddress(FDllHandle, 'SetBit');
    FBitCount := GetProcAddress(FDllHandle, 'BitCount');
    FBitOpAnd := GetProcAddress(FDllHandle, 'BitOpAnd');
    FBitOpOr := GetProcAddress(FDllHandle, 'BitOpOr');
    FBitOpXor := GetProcAddress(FDllHandle, 'BitOpXor');
    FBitOpNot := GetProcAddress(FDllHandle, 'BitOpNot');
    FBitPos := GetProcAddress(FDllHandle, 'BitPos');
    FHDel := GetProcAddress(FDllHandle, 'HDel');
    FHIncrBy := GetProcAddress(FDllHandle, 'HIncrBy');
    FHLen := GetProcAddress(FDllHandle, 'HLen');
    FHSet := GetProcAddress(FDllHandle, 'HSet');
    FLInsert := GetProcAddress(FDllHandle, 'LInsert');
    FLInsertBefore := GetProcAddress(FDllHandle, 'LInsertBefore');
    FLInsertAfter := GetProcAddress(FDllHandle, 'LInsertAfter');
    FLLen := GetProcAddress(FDllHandle, 'LLen');
    FLPos := GetProcAddress(FDllHandle, 'LPos');
    FLPush := GetProcAddress(FDllHandle, 'LPush');
    FLPushX := GetProcAddress(FDllHandle, 'LPushX');
    FLRem := GetProcAddress(FDllHandle, 'LRem');
    FRPush := GetProcAddress(FDllHandle, 'RPush');
    FRPushX := GetProcAddress(FDllHandle, 'RPushX');
    FSAdd := GetProcAddress(FDllHandle, 'SAdd');
    FSCard := GetProcAddress(FDllHandle, 'SCard');
    FSDiffStore := GetProcAddress(FDllHandle, 'SDiffStore');
    FSInterStore := GetProcAddress(FDllHandle, 'SInterStore');
    FSRem := GetProcAddress(FDllHandle, 'SRem');
    FSUnionStore := GetProcAddress(FDllHandle, 'SUnionStore');
    FZAdd := GetProcAddress(FDllHandle, 'ZAdd');
    FZAddNX := GetProcAddress(FDllHandle, 'ZAddNX');
    FZAddXX := GetProcAddress(FDllHandle, 'ZAddXX');
    FZAddCh := GetProcAddress(FDllHandle, 'ZAddCh');
    FZAddNXCh := GetProcAddress(FDllHandle, 'ZAddNXCh');
    FZAddXXCh := GetProcAddress(FDllHandle, 'ZAddXXCh');
    FZCard := GetProcAddress(FDllHandle, 'ZCard');
    FZCount := GetProcAddress(FDllHandle, 'ZCount');
    FZLexCount := GetProcAddress(FDllHandle, 'ZLexCount');
    FZRemRangeByRank := GetProcAddress(FDllHandle, 'ZRemRangeByRank');
    FZRank := GetProcAddress(FDllHandle, 'ZRank');
    FZRem := GetProcAddress(FDllHandle, 'ZRem');
    FZRemRangeByScore := GetProcAddress(FDllHandle, 'ZRemRangeByScore');
    FZRemRangeByLex := GetProcAddress(FDllHandle, 'ZRemRangeByLex');
    FNewPipeLiner := GetProcAddress(FDllHandle, 'NewPipeLiner');
    FFreePipeLiner := GetProcAddress(FDllHandle, 'FreePipeLiner');
    FPipeExec := GetProcAddress(FDllHandle, 'PipeExec');

    FExpire := GetProcAddress(FDllHandle, 'Expire');
    FExpireAt := GetProcAddress(FDllHandle, 'ExpireAt');
    FMove := GetProcAddress(FDllHandle, 'Move');
    FPExpire := GetProcAddress(FDllHandle, 'PExpire');
    FPExpireAt := GetProcAddress(FDllHandle, 'PExpireAt');
    FPersist := GetProcAddress(FDllHandle, 'Persist');
    FRenameNX := GetProcAddress(FDllHandle, 'RenameNX');
    FMSetNX := GetProcAddress(FDllHandle, 'MSetNX');
    FSetNX := GetProcAddress(FDllHandle, 'SetNX');
    FSetXX := GetProcAddress(FDllHandle, 'SetXX');
    FHExists := GetProcAddress(FDllHandle, 'HExists');
    FHMSet := GetProcAddress(FDllHandle, 'HMSet');
    FHSetNX := GetProcAddress(FDllHandle, 'HSetNX');
    FSIsMember := GetProcAddress(FDllHandle, 'SIsMember');
    FSMove := GetProcAddress(FDllHandle, 'SMove');
    FClientPause := GetProcAddress(FDllHandle, 'ClientPause');

    // 确保本窗口是在主消息线程中，否则需要在相应的线程中做独立的线程内的消息循环
    if GetCurrentThreadId <> MainThreadID then
      TThread.Synchronize(nil,
        procedure
        begin
          H := AllocateHWnd(AsynWndProc);
        end)
    else
      H := AllocateHWnd(AsynWndProc);
    FAsynWnd := H;

    InitSDK
  end;
end;

procedure TDxRedisSdkManager.InitSDK;
var
  RedisSDK: TRedisSDKData;
begin
  if Assigned(FInitRedisSdk) then
  begin
    RedisSDK.MangData := self;
    RedisSDK.LogProc := LogProc;
    FInitRedisSdk(@RedisSDK);
  end;
end;

procedure TDxRedisSdkManager.PostRedisMsg(redisCmd: TWndMsgCmd;
params: Pointer);
var
  AItem: PSynWndMessageItem;
begin
  AItem := FPointerPool.Pop;
  AItem.Cmd := redisCmd;
  AItem.params := params;
  AItem.Next := nil;
  MonitorEnter(FLocker);
  if Assigned(FLast) then
    FLast.Next := AItem
  else
    FFirst := AItem;
  FLast := AItem;
  MonitorExit(FLocker);
  Wakeup
end;

procedure TDxRedisSdkManager.ProcessRedisMsgs;
var
  AItem: PSynWndMessageItem;
begin
  if Assigned(FFirst) then
  begin
    MonitorEnter(FLocker);
    AItem := FFirst;
    if Assigned(AItem) then
      FFirst := FFirst.Next;
    if AItem = FLast then
      FLast := nil;
    MonitorExit(FLocker);
    if Assigned(AItem) then
    begin
      try
        case AItem.Cmd of
          MC_Log:
            begin
              if Assigned(FOnLog) then
                FOnLog(self, PLogData(AItem^.params)^.logLevel,
                  PLogData(AItem^.params)^.logMsg);
            end;
          MC_StatusCmd:
            begin
              DoStatusCmdMsg(AItem^.params);
            end;
          MC_ScanCmd:
            begin
              DoScanCmdMsg(AItem^.params);
            end;
          MC_SelectScan:
            DoSelectScanCmdMsg(AItem^.params);
          MC_StringCmd:
            DoStringCmdMsg(AItem^.params);
          MC_IntCmd:
            DoIntCmdMsg(AItem^.params);
          MC_BoolCmd: DoBoolCmdMsg(AItem^.params);
          MC_pipeCmd:
            DoPipeCmdMsg(AItem^.params);
        end;
      except
      end;
      Dispose(AItem^.params);
      AItem^.params := nil;
      FPointerPool.Push(AItem);
      PostMessage(FAsynWnd, WM_APP, 0, 0); // 投递执行下一个
    end
  end;
end;

procedure TDxRedisSdkManager.SetDll(const Value: string);
begin
  if FDllPath <> Value then
  begin
    if FDllHandle <> 0 then
    begin

    end;
    FDllPath := Value;
    InitDll(FDllPath);
  end;
end;

procedure TDxRedisSdkManager.Wakeup;
begin
  PostMessage(FAsynWnd, WM_APP, 0, 0);
end;

{ TDxRedisClient }

procedure TDxRedisClient.TypeCmd(Key: string; block: Boolean;
StatusCmdReturn: TRedisStatusCmd);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(StatusCmdReturn);
  FRedisSdkManager.FType(FRedisClient, PChar(Key), block, statusCmdResult, Mnd);
end;

procedure TDxRedisClient.TypeCmd(Key: string; block: Boolean;
StatusCmdReturn: TRedisStatusCmdA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStatusCmdA(@TMethod(ATemp).Code)^ := StatusCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FType(FRedisClient, PChar(Key), block, statusCmdResult, Mnd);
end;

procedure TDxRedisClient.Touch(keys: array of string; block: Boolean;
intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
  keyList: string;
  i: Integer;
begin
  keyList := '';
  if Length(keys) > 0 then
  begin
    for i := Low(keys) to High(keys) do
    begin
      if keyList = '' then
        keyList := keys[i]
      else
        keyList := keyList + #13#10 + keys[i];
    end;
    New(Mnd);
    Mnd^ := TMethod(intCmdReturn);
    AtomicIncrement(FRunningCount, 1);
    FRedisSdkManager.FTouch(FRedisClient, PChar(keyList), block,
      intCmdResult, Mnd);
  end;
end;

procedure TDxRedisClient.Touch(keys: array of string; block: Boolean;
intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  keyList: string;
  i: Integer;
  ATemp: TIntCmdReturn;
begin
  keyList := '';
  if Length(keys) > 0 then
  begin
    TMethod(ATemp).Data := Pointer(-1);
    TMethod(ATemp).Code := nil;
    PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
    New(Mnd);
    Mnd^ := TMethod(ATemp);
    for i := Low(keys) to High(keys) do
    begin
      if keyList = '' then
        keyList := keys[i]
      else
        keyList := keyList + #13#10 + keys[i];
    end;
    AtomicIncrement(FRunningCount, 1);
    FRedisSdkManager.FTouch(FRedisClient, PChar(keyList), block,
      intCmdResult, Mnd);
  end;
end;

procedure TDxRedisClient.Touch(keys: array of string; block: Boolean;
intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
  keyList: string;
  i: Integer;
begin
  keyList := '';
  if Length(keys) > 0 then
  begin
    New(Mnd);
    Mnd^.Data := nil;
    TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
    for i := Low(keys) to High(keys) do
    begin
      if keyList = '' then
        keyList := keys[i]
      else
        keyList := keyList + #13#10 + keys[i];
    end;
    AtomicIncrement(FRunningCount, 1);
    FRedisSdkManager.FTouch(FRedisClient, PChar(keyList), block,
      intCmdResult, Mnd);
  end;
end;

procedure TDxRedisClient.TTL(key: string; block: Boolean;
  intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  FRedisSdkManager.FTTL(FRedisClient, PChar(Key),block, intCmdResult, Mnd);
end;

procedure TDxRedisClient.TTL(key: string; block: Boolean;
  intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FTTL(FRedisClient, PChar(Key),block, intCmdResult, Mnd);
end;

procedure TDxRedisClient.TTL(key: string; block: Boolean;
  intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  FRedisSdkManager.FTTL(FRedisClient, PChar(Key),block, intCmdResult, Mnd);
end;

procedure TDxRedisClient.TypeCmd(Key: string; block: Boolean;
StatusCmdReturn: TRedisStatusCmdG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TRedisStatusCmdA(Mnd^.Code) := StatusCmdReturn;
  FRedisSdkManager.FType(FRedisClient, PChar(Key), block, statusCmdResult, Mnd);
end;

procedure TDxRedisClient.Unlink(keys: array of string; block: Boolean;
intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
  keyList: string;
  i: Integer;
begin
  keyList := '';
  if Length(keys) > 0 then
  begin
    New(Mnd);
    Mnd^ := TMethod(intCmdReturn);
    for i := Low(keys) to High(keys) do
    begin
      if keyList = '' then
        keyList := keys[i]
      else
        keyList := keyList + #13#10 + keys[i];
    end;
    AtomicIncrement(FRunningCount, 1);
    FRedisSdkManager.FUnlink(FRedisClient, PChar(keyList), block,
      intCmdResult, Mnd);
  end;
end;

procedure TDxRedisClient.Unlink(keys: array of string; block: Boolean;
intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  keyList: string;
  i: Integer;
  ATemp: TIntCmdReturn;
begin
  keyList := '';
  if Length(keys) > 0 then
  begin
    TMethod(ATemp).Data := Pointer(-1);
    TMethod(ATemp).Code := nil;
    PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
    New(Mnd);
    Mnd^ := TMethod(ATemp);
    for i := Low(keys) to High(keys) do
    begin
      if keyList = '' then
        keyList := keys[i]
      else
        keyList := keyList + #13#10 + keys[i];
    end;
    AtomicIncrement(FRunningCount, 1);
    FRedisSdkManager.FUnlink(FRedisClient, PChar(keyList), block,
      intCmdResult, Mnd);
  end;
end;

procedure TDxRedisClient.Unlink(keys: array of string; block: Boolean;
intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
  keyList: string;
  i: Integer;
begin
  keyList := '';
  if Length(keys) > 0 then
  begin
    New(Mnd);
    Mnd^.Data := nil;
    TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
    for i := Low(keys) to High(keys) do
    begin
      if keyList = '' then
        keyList := keys[i]
      else
        keyList := keyList + #13#10 + keys[i];
    end;
    AtomicIncrement(FRunningCount, 1);
    FRedisSdkManager.FUnlink(FRedisClient, PChar(keyList), block,
      intCmdResult, Mnd);
  end;
end;

procedure TDxRedisClient.XAdd(stream, ID: string; MaxLen, MaxLenApprox: Int64;
Value: string; block: Boolean; stringCmdReturn: TRedisStringCmdReturn);
var
  Mnd: PStringCmdMethod;
  args: TxAddArgs;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method := TMethod(stringCmdReturn);

  args.stream := PChar(stream);
  args.ID := PChar(ID);
  args.MaxLen := MaxLen;
  args.MaxLenApprox := MaxLenApprox;
  args.VLen := 0;
  args.Value := PChar(Value);

  FRedisSdkManager.FXAdd(FRedisClient, @args, block, stringCmdResult, Mnd)
end;

procedure TDxRedisClient.XAdd(stream, ID: string; MaxLen, MaxLenApprox: Int64;
Value: string; block: Boolean; stringCmdReturn: TRedisStringCmdReturnA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PStringCmdMethod;
  args: TxAddArgs;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStringCmdReturnA(@TMethod(ATemp).Code)^ := stringCmdReturn;
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method := TMethod(ATemp);

  args.stream := PChar(stream);
  args.ID := PChar(ID);
  args.MaxLen := MaxLen;
  args.MaxLenApprox := MaxLenApprox;
  args.VLen := 0;
  args.Value := PChar(Value);
  FRedisSdkManager.FXAdd(FRedisClient, @args, block, stringCmdResult, Mnd)
end;

procedure TDxRedisClient.XAdd(stream, ID: string; MaxLen, MaxLenApprox: Int64;
Value: string; block: Boolean; stringCmdReturn: TRedisStringCmdReturnG);
var
  Mnd: PStringCmdMethod;
  args: TxAddArgs;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method.Data := nil;
  TRedisStringCmdReturnA(Mnd^.Method.Code) := stringCmdReturn;
  args.stream := PChar(stream);
  args.ID := PChar(ID);
  args.MaxLen := MaxLen;
  args.MaxLenApprox := MaxLenApprox;
  args.VLen := 0;
  args.Value := PChar(Value);
  FRedisSdkManager.FXAdd(FRedisClient, @args, block, stringCmdResult, Mnd)
end;

procedure TDxRedisClient.ZScan(cursor: UInt64; Key, match: string; count: Int64;
block: Boolean; scanCmdReturn: TRedisScanCmdReturn);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(scanCmdReturn);
  FRedisSdkManager.FZScan(FRedisClient, cursor, PChar(Key), PChar(match), count,
    block, scanCmdResult, Mnd);
end;

procedure TDxRedisClient.ZScan(cursor: UInt64; Key, match: string; count: Int64;
block: Boolean; scanCmdReturn: TRedisScanCmdReturnA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisScanCmdReturnA(@TMethod(ATemp).Code)^ := scanCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FZScan(FRedisClient, cursor, PChar(Key), PChar(match), count,
    block, scanCmdResult, Mnd);
end;

procedure TDxRedisClient.ZScan(cursor: UInt64; Key, match: string; count: Int64;
block: Boolean; scanCmdReturn: TRedisScanCmdReturnG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TRedisScanCmdReturnA(Mnd^.Code) := scanCmdReturn;
  FRedisSdkManager.FZScan(FRedisClient, cursor, PChar(Key), PChar(match), count,
    block, scanCmdResult, Mnd);
end;

procedure TDxRedisClient.BRPopLPush(src, dst: string; timeout: Integer;
block: Boolean; stringCmdReturn: TRedisStringCmdReturn);
var
  Mnd: PStringCmdMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method := TMethod(stringCmdReturn);
  FRedisSdkManager.FBRPopLPush(FRedisClient, PChar(src), PChar(dst), timeout,
    False, block, stringCmdResult, Mnd);
end;

procedure TDxRedisClient.BRPopLPush(src, dst: string; timeout: Integer;
block: Boolean; stringCmdReturn: TRedisStringCmdReturnA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PStringCmdMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStringCmdReturnA(@TMethod(ATemp).Code)^ := stringCmdReturn;
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method := TMethod(ATemp);
  FRedisSdkManager.FBRPopLPush(FRedisClient, PChar(src), PChar(dst), timeout,
    False, block, stringCmdResult, Mnd);
end;

procedure TDxRedisClient.BRPopLPush(src, dst: string; timeout: Integer;
block: Boolean; stringCmdReturn: TRedisStringCmdReturnG);
var
  Mnd: PStringCmdMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method.Data := nil;
  TRedisStringCmdReturnA(Mnd^.Method.Code) := stringCmdReturn;
  FRedisSdkManager.FBRPopLPush(FRedisClient, PChar(src), PChar(dst), timeout,
    False, block, stringCmdResult, Mnd);
end;

procedure TDxRedisClient.ClientList(block: Boolean;
stringCmdReturn: TRedisStringCmdReturn);
var
  Mnd: PStringCmdMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method := TMethod(stringCmdReturn);
  FRedisSdkManager.FClientList(FRedisClient, block, stringCmdResult, Mnd)
end;

procedure TDxRedisClient.ClientList(block: Boolean;
stringCmdReturn: TRedisStringCmdReturnA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PStringCmdMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStringCmdReturnA(@TMethod(ATemp).Code)^ := stringCmdReturn;
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method := TMethod(ATemp);
  FRedisSdkManager.FClientList(FRedisClient, block, stringCmdResult, Mnd)
end;

procedure TDxRedisClient.ClientList(block: Boolean;
stringCmdReturn: TRedisStringCmdReturnG);
var
  Mnd: PStringCmdMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method.Data := nil;
  TRedisStringCmdReturnA(Mnd^.Method.Code) := stringCmdReturn;
  FRedisSdkManager.FClientList(FRedisClient, block, stringCmdResult, Mnd)
end;

procedure TDxRedisClient.CloseRedisClient;
var
  tk: DWORD;
begin
  // 关闭Client
  if FRedisClient <> nil then
  begin
    FRedisSdkManager.FFreeRedisConnection(FRedisClient);
    if FRedisSdkManager.FClients[FRedisSdkManager.FClients.count - 1] = self
    then
      FRedisSdkManager.FClients.Delete(FRedisSdkManager.FClients.count - 1)
    else
      FRedisSdkManager.FClients.Remove(self);
    FRedisClient := nil;
    tk := GetTickCount;
    while AtomicCmpExchange(FRunningCount, 0, 0) > 0 do
    begin
      Application.ProcessMessages;
      Sleep(0);
      if GetTickCount - tk > 3000 then
        Break;
    end;
  end;
end;

procedure TDxRedisClient.Del(keys: array of string; block: Boolean;
intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
  keyList: string;
  i: Integer;
begin
  keyList := '';
  if Length(keys) > 0 then
  begin
    New(Mnd);
    Mnd^ := TMethod(intCmdReturn);
    for i := Low(keys) to High(keys) do
    begin
      if keyList = '' then
        keyList := keys[i]
      else
        keyList := keyList + #13#10 + keys[i];
    end;
    AtomicIncrement(FRunningCount, 1);
    FRedisSdkManager.FDel(FRedisClient, PChar(keyList), block,
      intCmdResult, Mnd);
  end;
end;

procedure TDxRedisClient.Del(keys: array of string; block: Boolean;
intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  keyList: string;
  i: Integer;
  ATemp: TIntCmdReturn;
begin
  keyList := '';
  if Length(keys) > 0 then
  begin
    TMethod(ATemp).Data := Pointer(-1);
    TMethod(ATemp).Code := nil;
    PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
    New(Mnd);
    Mnd^ := TMethod(ATemp);
    for i := Low(keys) to High(keys) do
    begin
      if keyList = '' then
        keyList := keys[i]
      else
        keyList := keyList + #13#10 + keys[i];
    end;
    AtomicIncrement(FRunningCount, 1);
    FRedisSdkManager.FDel(FRedisClient, PChar(keyList), block,
      intCmdResult, Mnd);
  end;
end;

procedure TDxRedisClient.Decr(Key: string; block: Boolean;
intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  FRedisSdkManager.FDecr(FRedisClient, PChar(Key), block, intCmdResult, Mnd);
end;

procedure TDxRedisClient.Decr(Key: string; block: Boolean;
intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FDecr(FRedisClient, PChar(Key), block, intCmdResult, Mnd);
end;

procedure TDxRedisClient.Decr(Key: string; block: Boolean;
intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  FRedisSdkManager.FDecr(FRedisClient, PChar(Key), block, intCmdResult, Mnd);
end;

procedure TDxRedisClient.DecrBy(Key: string; decrement: Int64; block: Boolean;
intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  FRedisSdkManager.FDecrBy(FRedisClient, PChar(Key), decrement, block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.DecrBy(Key: string; decrement: Int64; block: Boolean;
intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FDecrBy(FRedisClient, PChar(Key), decrement, block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.DecrBy(Key: string; decrement: Int64; block: Boolean;
intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  FRedisSdkManager.FDecrBy(FRedisClient, PChar(Key), decrement, block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.Incr(Key: string; block: Boolean;
intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  FRedisSdkManager.FIncr(FRedisClient, PChar(Key), block, intCmdResult, Mnd);
end;

procedure TDxRedisClient.Incr(Key: string; block: Boolean;
intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FIncr(FRedisClient, PChar(Key), block, intCmdResult, Mnd);
end;

procedure TDxRedisClient.Incr(Key: string; block: Boolean;
intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  FRedisSdkManager.FIncr(FRedisClient, PChar(Key), block, intCmdResult, Mnd);
end;

procedure TDxRedisClient.StrLen(Key: string; block: Boolean;
intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  FRedisSdkManager.FStrLen(FRedisClient, PChar(Key), block, intCmdResult, Mnd);
end;

procedure TDxRedisClient.StrLen(Key: string; block: Boolean;
intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FStrLen(FRedisClient, PChar(Key), block, intCmdResult, Mnd);
end;

procedure TDxRedisClient.StrLen(Key: string; block: Boolean;
intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  FRedisSdkManager.FStrLen(FRedisClient, PChar(Key), block, intCmdResult, Mnd);
end;

procedure TDxRedisClient.IncrBy(Key: string; increment: Int64; block: Boolean;
intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  FRedisSdkManager.FIncrBy(FRedisClient, PChar(Key), increment, block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.IncrBy(Key: string; increment: Int64; block: Boolean;
intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FIncrBy(FRedisClient, PChar(Key), increment, block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.IncrBy(Key: string; increment: Int64; block: Boolean;
intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  FRedisSdkManager.FIncrBy(FRedisClient, PChar(Key), increment, block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.Del(keys: array of string; block: Boolean;
intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
  keyList: string;
  i: Integer;
begin
  keyList := '';
  if Length(keys) > 0 then
  begin
    New(Mnd);
    Mnd^.Data := nil;
    TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
    for i := Low(keys) to High(keys) do
    begin
      if keyList = '' then
        keyList := keys[i]
      else
        keyList := keyList + #13#10 + keys[i];
    end;
    AtomicIncrement(FRunningCount, 1);
    FRedisSdkManager.FDel(FRedisClient, PChar(keyList), block,
      intCmdResult, Mnd);
  end;
end;

destructor TDxRedisClient.Destroy;
begin
  SetRedisSdkManager(nil);
  inherited;
end;

procedure TDxRedisClient.Exists(keys: array of string; block: Boolean;
intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
  keyList: string;
  i: Integer;
begin
  keyList := '';
  if Length(keys) > 0 then
  begin
    New(Mnd);
    Mnd^ := TMethod(intCmdReturn);
    for i := Low(keys) to High(keys) do
    begin
      if keyList = '' then
        keyList := keys[i]
      else
        keyList := keyList + #13#10 + keys[i];
    end;
    AtomicIncrement(FRunningCount, 1);
    FRedisSdkManager.FExists(FRedisClient, PChar(keyList), block,
      intCmdResult, Mnd);
  end;
end;

procedure TDxRedisClient.Exists(keys: array of string; block: Boolean;
intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  keyList: string;
  i: Integer;
  ATemp: TIntCmdReturn;
begin
  keyList := '';
  if Length(keys) > 0 then
  begin
    TMethod(ATemp).Data := Pointer(-1);
    TMethod(ATemp).Code := nil;
    PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
    New(Mnd);
    Mnd^ := TMethod(ATemp);
    for i := Low(keys) to High(keys) do
    begin
      if keyList = '' then
        keyList := keys[i]
      else
        keyList := keyList + #13#10 + keys[i];
    end;
    AtomicIncrement(FRunningCount, 1);
    FRedisSdkManager.FExists(FRedisClient, PChar(keyList), block,
      intCmdResult, Mnd);
  end;
end;

procedure TDxRedisClient.Exists(keys: array of string; block: Boolean;
intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
  keyList: string;
  i: Integer;
begin
  keyList := '';
  if Length(keys) > 0 then
  begin
    New(Mnd);
    Mnd^.Data := nil;
    TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
    for i := Low(keys) to High(keys) do
    begin
      if keyList = '' then
        keyList := keys[i]
      else
        keyList := keyList + #13#10 + keys[i];
    end;
    AtomicIncrement(FRunningCount, 1);
    FRedisSdkManager.FExists(FRedisClient, PChar(keyList), block,
      intCmdResult, Mnd);
  end;
end;

procedure TDxRedisClient.Expire(key: string; expiration: Integer;
  block: Boolean; CmdReturn: TBoolCmdReturn);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  FRedisSdkManager.FExpire(FRedisClient, PChar(Key),expiration,block, boolCmdResult, Mnd);
end;

procedure TDxRedisClient.Expire(key: string; expiration: Integer;
  block: Boolean; CmdReturn: TBoolCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PBoolCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FExpire(FRedisClient, PChar(Key),expiration,block, boolCmdResult, Mnd);
end;

procedure TDxRedisClient.Expire(key: string; expiration: Integer;
  block: Boolean; CmdReturn: TBoolCmdReturnG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TBoolCmdReturnA(Mnd^.Code) := CmdReturn;
  FRedisSdkManager.FExpire(FRedisClient, PChar(Key),expiration,block, boolCmdResult, Mnd);
end;

procedure TDxRedisClient.ExpireAt(key: string; atTime: TDateTime;
  block: Boolean; CmdReturn: TBoolCmdReturn);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  FRedisSdkManager.FExpireAt(FRedisClient, PChar(Key),atTime,block, boolCmdResult, Mnd);
end;

procedure TDxRedisClient.ExpireAt(key: string; atTime: TDateTime;
  block: Boolean; CmdReturn: TBoolCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PBoolCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FExpireAt(FRedisClient, PChar(Key),atTime,block, boolCmdResult, Mnd);
end;

procedure TDxRedisClient.ExpireAt(key: string; atTime: TDateTime;
  block: Boolean; CmdReturn: TBoolCmdReturnG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TBoolCmdReturnA(Mnd^.Code) := CmdReturn;
  FRedisSdkManager.FExpireAt(FRedisClient, PChar(Key),atTime,block, boolCmdResult, Mnd);
end;

procedure TDxRedisClient.PExpire(key: string; expiration: Integer;
  block: Boolean; CmdReturn: TBoolCmdReturn);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  FRedisSdkManager.FPExpire(FRedisClient, PChar(Key),expiration,block, boolCmdResult, Mnd);
end;

procedure TDxRedisClient.PExpire(key: string; expiration: Integer;
  block: Boolean; CmdReturn: TBoolCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PBoolCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FPExpire(FRedisClient, PChar(Key),expiration,block, boolCmdResult, Mnd);
end;

procedure TDxRedisClient.PExpire(key: string; expiration: Integer;
  block: Boolean; CmdReturn: TBoolCmdReturnG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TBoolCmdReturnA(Mnd^.Code) := CmdReturn;
  FRedisSdkManager.FPExpire(FRedisClient, PChar(Key),expiration,block, boolCmdResult, Mnd);
end;

procedure TDxRedisClient.PExpireAt(key: string; atTime: TDateTime;
  block: Boolean; CmdReturn: TBoolCmdReturn);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  FRedisSdkManager.FPExpireAt(FRedisClient, PChar(Key),atTime,block, boolCmdResult, Mnd);
end;

procedure TDxRedisClient.PExpireAt(key: string; atTime: TDateTime;
  block: Boolean; CmdReturn: TBoolCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PBoolCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FPExpireAt(FRedisClient, PChar(Key),atTime,block, boolCmdResult, Mnd);
end;

procedure TDxRedisClient.PExpireAt(key: string; atTime: TDateTime;
  block: Boolean; CmdReturn: TBoolCmdReturnG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TBoolCmdReturnA(Mnd^.Code) := CmdReturn;
  FRedisSdkManager.FPExpireAt(FRedisClient, PChar(Key),atTime,block, boolCmdResult, Mnd);
end;

procedure TDxRedisClient.Move(key: string; db: Integer;
  block: Boolean; CmdReturn: TBoolCmdReturn);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  FRedisSdkManager.FMove(FRedisClient, PChar(Key),db,block, boolCmdResult, Mnd);
end;

procedure TDxRedisClient.Move(key: string; db: Integer;
  block: Boolean; CmdReturn: TBoolCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PBoolCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FMove(FRedisClient, PChar(Key),db,block, boolCmdResult, Mnd);
end;

procedure TDxRedisClient.Move(key: string; db: Integer;
  block: Boolean; CmdReturn: TBoolCmdReturnG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TBoolCmdReturnA(Mnd^.Code) := CmdReturn;
  FRedisSdkManager.FMove(FRedisClient, PChar(Key),db,block, boolCmdResult, Mnd);
end;

procedure TDxRedisClient.Persist(key: string;block: Boolean; CmdReturn: TBoolCmdReturn);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  FRedisSdkManager.FPersist(FRedisClient, PChar(Key),block, boolCmdResult, Mnd);
end;

procedure TDxRedisClient.Persist(key: string;block: Boolean; CmdReturn: TBoolCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PBoolCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FPersist(FRedisClient, PChar(Key),block, boolCmdResult, Mnd);
end;

procedure TDxRedisClient.Persist(key: string;block: Boolean; CmdReturn: TBoolCmdReturnG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TBoolCmdReturnA(Mnd^.Code) := CmdReturn;
  FRedisSdkManager.FPersist(FRedisClient, PChar(Key),block, boolCmdResult, Mnd);
end;

procedure TDxRedisClient.RenameNX(key,newKey: string;block: Boolean; CmdReturn: TBoolCmdReturn);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  FRedisSdkManager.FRenameNX(FRedisClient, PChar(Key),PChar(newKey),block, boolCmdResult, Mnd);
end;

procedure TDxRedisClient.RenameNX(key,newKey: string;block: Boolean; CmdReturn: TBoolCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PBoolCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FRenameNX(FRedisClient, PChar(Key),PChar(newKey),block, boolCmdResult, Mnd);
end;

procedure TDxRedisClient.RenameNX(key,newKey: string;block: Boolean; CmdReturn: TBoolCmdReturnG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TBoolCmdReturnA(Mnd^.Code) := CmdReturn;
  FRedisSdkManager.FRenameNX(FRedisClient, PChar(Key),PChar(newKey),block, boolCmdResult, Mnd);
end;

procedure TDxRedisClient.MSetNX(keyValues: array of TKeyValue;block: Boolean; CmdReturn: TBoolCmdReturn);
var
  Mnd: PMethod;
  i, l: Integer;
  redisKVs: array of TRedisKeyValue;
begin
  l := Length(keyValues);
  if l = 0 then
    Exit;
  AtomicIncrement(FRunningCount, 1);
  SetLength(redisKVs, l);
  for i := 0 to l - 1 do
  begin
    redisKVs[i].Key := PChar(keyValues[i].Key);
    redisKVs[i].Value.Value := PChar(keyValues[i].Value);
    redisKVs[i].Value.ValueLen := 0;
  end;

  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  FRedisSdkManager.FMSetNX(FRedisClient,@redisKVs[0], l, block,boolCmdResult, Mnd);
end;

procedure TDxRedisClient.MSetNX(keyValues: array of TKeyValue;block: Boolean; CmdReturn: TBoolCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
  i, l: Integer;
  redisKVs: array of TRedisKeyValue;
begin
  l := Length(keyValues);
  if l = 0 then
    Exit;
  AtomicIncrement(FRunningCount, 1);
  SetLength(redisKVs, l);
  for i := 0 to l - 1 do
  begin
    redisKVs[i].Key := PChar(keyValues[i].Key);
    redisKVs[i].Value.Value := PChar(keyValues[i].Value);
    redisKVs[i].Value.ValueLen := 0;
  end;
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PBoolCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FMSetNX(FRedisClient, @redisKVs[0], l, block,boolCmdResult, Mnd);
end;

procedure TDxRedisClient.MSetNX(keyValues: array of TKeyValue;block: Boolean; CmdReturn: TBoolCmdReturnG);
var
  Mnd: PMethod;
  i, l: Integer;
  redisKVs: array of TRedisKeyValue;
begin
  l := Length(keyValues);
  if l = 0 then
    Exit;
  AtomicIncrement(FRunningCount, 1);
  SetLength(redisKVs, l);
  for i := 0 to l - 1 do
  begin
    redisKVs[i].Key := PChar(keyValues[i].Key);
    redisKVs[i].Value.Value := PChar(keyValues[i].Value);
    redisKVs[i].Value.ValueLen := 0;
  end;
  New(Mnd);
  Mnd^.Data := nil;
  TBoolCmdReturnA(Mnd^.Code) := CmdReturn;
  FRedisSdkManager.FMSetNX(FRedisClient, @redisKVs[0], l, block,boolCmdResult, Mnd);
end;

procedure TDxRedisClient.MSetNX(keyValues: array of TRedisKeyValue;block: Boolean; CmdReturn: TBoolCmdReturn);
var
  Mnd: PMethod;
  i, l: Integer;
begin
  l := Length(keyValues);
  if l = 0 then
    Exit;
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  FRedisSdkManager.FMSetNX(FRedisClient,@keyValues[0], l, block,boolCmdResult, Mnd);
end;

procedure TDxRedisClient.MSetNX(keyValues: array of TRedisKeyValue;block: Boolean; CmdReturn: TBoolCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
  i, l: Integer;
begin
  l := Length(keyValues);
  if l = 0 then
    Exit;
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PBoolCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FMSetNX(FRedisClient, @keyValues[0], l, block,boolCmdResult, Mnd);
end;

procedure TDxRedisClient.MSetNX(keyValues: array of TRedisKeyValue;block: Boolean; CmdReturn: TBoolCmdReturnG);
var
  Mnd: PMethod;
  i, l: Integer;
begin
  l := Length(keyValues);
  if l = 0 then
    Exit;
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TBoolCmdReturnA(Mnd^.Code) := CmdReturn;
  FRedisSdkManager.FMSetNX(FRedisClient, @keyValues[0], l, block,boolCmdResult, Mnd);
end;

procedure TDxRedisClient.SetNX(key,value: string;expiration: Integer; block: Boolean;CmdReturn: TBoolCmdReturn);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  FRedisSdkManager.FSetNX(FRedisClient, PChar(Key),PChar(value),0,expiration,block, boolCmdResult, Mnd);
end;

procedure TDxRedisClient.SetNX(key,value: string;expiration: Integer; block: Boolean;CmdReturn: TBoolCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PBoolCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FSetNX(FRedisClient, PChar(Key),PChar(value),0,expiration,block, boolCmdResult, Mnd);
end;

procedure TDxRedisClient.SetNX(key,value: string;expiration: Integer; block: Boolean;CmdReturn: TBoolCmdReturnG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TBoolCmdReturnA(Mnd^.Code) := CmdReturn;
  FRedisSdkManager.FSetNX(FRedisClient, PChar(Key),PChar(value),0,expiration,block, boolCmdResult, Mnd);
end;

procedure TDxRedisClient.SetNX(key: string;valueBuffer: PByte;buffLen,expiration: Integer; block: Boolean;CmdReturn: TBoolCmdReturn);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  FRedisSdkManager.FSetNX(FRedisClient, PChar(Key),valueBuffer,buffLen,expiration,block, boolCmdResult, Mnd);
end;

procedure TDxRedisClient.SetNX(key: string;valueBuffer: PByte;buffLen,expiration: Integer; block: Boolean;CmdReturn: TBoolCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PBoolCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FSetNX(FRedisClient, PChar(Key),valueBuffer,buffLen,expiration,block, boolCmdResult, Mnd);
end;

procedure TDxRedisClient.SetNX(key: string;valueBuffer: PByte;buffLen,expiration: Integer; block: Boolean;CmdReturn: TBoolCmdReturnG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TBoolCmdReturnA(Mnd^.Code) := CmdReturn;
  FRedisSdkManager.FSetNX(FRedisClient, PChar(Key),valueBuffer,buffLen,expiration,block, boolCmdResult, Mnd);
end;

procedure TDxRedisClient.SetXX(key,value: string;expiration: Integer; block: Boolean;CmdReturn: TBoolCmdReturn);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  FRedisSdkManager.FSetXX(FRedisClient, PChar(Key),PChar(value),0,expiration,block, boolCmdResult, Mnd);
end;

procedure TDxRedisClient.SetXX(key,value: string;expiration: Integer; block: Boolean;CmdReturn: TBoolCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PBoolCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FSetXX(FRedisClient, PChar(Key),PChar(value),0,expiration,block, boolCmdResult, Mnd);
end;

procedure TDxRedisClient.SetXX(key,value: string;expiration: Integer; block: Boolean;CmdReturn: TBoolCmdReturnG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TBoolCmdReturnA(Mnd^.Code) := CmdReturn;
  FRedisSdkManager.FSetXX(FRedisClient, PChar(Key),PChar(value),0,expiration,block, boolCmdResult, Mnd);
end;

procedure TDxRedisClient.SetXX(key: string;valueBuffer: PByte;buffLen,expiration: Integer; block: Boolean;CmdReturn: TBoolCmdReturn);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  FRedisSdkManager.FSetXX(FRedisClient, PChar(Key),valueBuffer,buffLen,expiration,block, boolCmdResult, Mnd);
end;

procedure TDxRedisClient.SetXX(key: string;valueBuffer: PByte;buffLen,expiration: Integer; block: Boolean;CmdReturn: TBoolCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PBoolCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FSetXX(FRedisClient, PChar(Key),valueBuffer,buffLen,expiration,block, boolCmdResult, Mnd);
end;

procedure TDxRedisClient.SetXX(key: string;valueBuffer: PByte;buffLen,expiration: Integer; block: Boolean;CmdReturn: TBoolCmdReturnG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TBoolCmdReturnA(Mnd^.Code) := CmdReturn;
  FRedisSdkManager.FSetXX(FRedisClient, PChar(Key),valueBuffer,buffLen,expiration,block, boolCmdResult, Mnd);
end;

procedure TDxRedisClient.HExists(key,field: string;block: Boolean; CmdReturn: TBoolCmdReturn);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  FRedisSdkManager.FHExists(FRedisClient, PChar(Key),PChar(field),block, boolCmdResult, Mnd);
end;

procedure TDxRedisClient.HExists(key,field: string;block: Boolean; CmdReturn: TBoolCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PBoolCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FHExists(FRedisClient, PChar(Key),PChar(field),block, boolCmdResult, Mnd);
end;

procedure TDxRedisClient.HExists(key,field: string;block: Boolean; CmdReturn: TBoolCmdReturnG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TBoolCmdReturnA(Mnd^.Code) := CmdReturn;
  FRedisSdkManager.FHExists(FRedisClient, PChar(Key),PChar(field),block, boolCmdResult, Mnd);
end;

procedure TDxRedisClient.HMSet(key: string; keyValues: array of TKeyValue;block: Boolean; CmdReturn: TBoolCmdReturn);
var
  Mnd: PMethod;
  i, l: Integer;
  redisKVs: array of TRedisKeyValue;
begin
  l := Length(keyValues);
  if l = 0 then
    Exit;
  AtomicIncrement(FRunningCount, 1);
  SetLength(redisKVs, l);
  for i := 0 to l - 1 do
  begin
    redisKVs[i].Key := PChar(keyValues[i].Key);
    redisKVs[i].Value.Value := PChar(keyValues[i].Value);
    redisKVs[i].Value.ValueLen := 0;
  end;

  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  FRedisSdkManager.FHMSet(FRedisClient,PChar(Key),@redisKVs[0], l, block,boolCmdResult, Mnd);
end;

procedure TDxRedisClient.HMSet(key: string;keyValues: array of TKeyValue;block: Boolean; CmdReturn: TBoolCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
  i, l: Integer;
  redisKVs: array of TRedisKeyValue;
begin
  l := Length(keyValues);
  if l = 0 then
    Exit;
  AtomicIncrement(FRunningCount, 1);
  SetLength(redisKVs, l);
  for i := 0 to l - 1 do
  begin
    redisKVs[i].Key := PChar(keyValues[i].Key);
    redisKVs[i].Value.Value := PChar(keyValues[i].Value);
    redisKVs[i].Value.ValueLen := 0;
  end;
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PBoolCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FHMSet(FRedisClient,PChar(key), @redisKVs[0], l, block,boolCmdResult, Mnd);
end;

procedure TDxRedisClient.HMSet(key: string;keyValues: array of TKeyValue;block: Boolean; CmdReturn: TBoolCmdReturnG);
var
  Mnd: PMethod;
  i, l: Integer;
  redisKVs: array of TRedisKeyValue;
begin
  l := Length(keyValues);
  if l = 0 then
    Exit;
  AtomicIncrement(FRunningCount, 1);
  SetLength(redisKVs, l);
  for i := 0 to l - 1 do
  begin
    redisKVs[i].Key := PChar(keyValues[i].Key);
    redisKVs[i].Value.Value := PChar(keyValues[i].Value);
    redisKVs[i].Value.ValueLen := 0;
  end;
  New(Mnd);
  Mnd^.Data := nil;
  TBoolCmdReturnA(Mnd^.Code) := CmdReturn;
  FRedisSdkManager.FHMSet(FRedisClient,PChar(key), @redisKVs[0], l, block,boolCmdResult, Mnd);
end;

procedure TDxRedisClient.HMSet(key: string; keyValues: array of TRedisKeyValue;block: Boolean; CmdReturn: TBoolCmdReturn);
var
  Mnd: PMethod;
  i, l: Integer;
begin
  l := Length(keyValues);
  if l = 0 then
    Exit;
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  FRedisSdkManager.FHMSet(FRedisClient,PChar(Key),@keyValues[0], l, block,boolCmdResult, Mnd);
end;

procedure TDxRedisClient.HMSet(key: string;keyValues: array of TRedisKeyValue;block: Boolean; CmdReturn: TBoolCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
  i, l: Integer;
begin
  l := Length(keyValues);
  if l = 0 then
    Exit;
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PBoolCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FHMSet(FRedisClient,PChar(key), @keyValues[0], l, block,boolCmdResult, Mnd);
end;

procedure TDxRedisClient.HMSet(key: string;keyValues: array of TRedisKeyValue;block: Boolean; CmdReturn: TBoolCmdReturnG);
var
  Mnd: PMethod;
  i, l: Integer;
begin
  l := Length(keyValues);
  if l = 0 then
    Exit;
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TBoolCmdReturnA(Mnd^.Code) := CmdReturn;
  FRedisSdkManager.FHMSet(FRedisClient,PChar(key), @keyValues[0], l, block,boolCmdResult, Mnd);
end;

procedure TDxRedisClient.HSetNX(key,field,value: string;block: Boolean;CmdReturn: TBoolCmdReturn);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  FRedisSdkManager.FHSetNX(FRedisClient, PChar(Key),PChar(field),PChar(value),0,block, boolCmdResult, Mnd);
end;

procedure TDxRedisClient.HSetNX(key,field,value: string;block: Boolean;CmdReturn: TBoolCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PBoolCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FHSetNX(FRedisClient, PChar(Key),PChar(field),PChar(value),0,block, boolCmdResult, Mnd);
end;

procedure TDxRedisClient.HSetNX(key,field,value: string;block: Boolean;CmdReturn: TBoolCmdReturnG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TBoolCmdReturnA(Mnd^.Code) := CmdReturn;
  FRedisSdkManager.FHSetNX(FRedisClient, PChar(Key),PChar(field),PChar(value),0,block, boolCmdResult, Mnd);
end;

procedure TDxRedisClient.HSetNX(key,field: string;valueBuffer: PByte;buffLen: Integer; block: Boolean;CmdReturn: TBoolCmdReturn);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  FRedisSdkManager.FHSetNX(FRedisClient, PChar(Key),PChar(field),valueBuffer,buffLen,block, boolCmdResult, Mnd);
end;

procedure TDxRedisClient.HSetNX(key,field: string;valueBuffer: PByte;buffLen: Integer; block: Boolean;CmdReturn: TBoolCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PBoolCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FHSetNX(FRedisClient, PChar(Key),PChar(field),valueBuffer,buffLen,block, boolCmdResult, Mnd);
end;

procedure TDxRedisClient.HSetNX(key,field: string;valueBuffer: PByte;buffLen: Integer; block: Boolean;CmdReturn: TBoolCmdReturnG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TBoolCmdReturnA(Mnd^.Code) := CmdReturn;
  FRedisSdkManager.FHSetNX(FRedisClient, PChar(Key),PChar(field),valueBuffer,buffLen,block, boolCmdResult, Mnd);
end;

procedure TDxRedisClient.SIsMember(key,value: string;block: Boolean;CmdReturn: TBoolCmdReturn);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  FRedisSdkManager.FSIsMember(FRedisClient, PChar(Key),PChar(value),0,block, boolCmdResult, Mnd);
end;

procedure TDxRedisClient.SIsMember(key,value: string;block: Boolean;CmdReturn: TBoolCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PBoolCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FSIsMember(FRedisClient, PChar(Key),PChar(value),0,block, boolCmdResult, Mnd);
end;

procedure TDxRedisClient.SIsMember(key,value: string;block: Boolean;CmdReturn: TBoolCmdReturnG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TBoolCmdReturnA(Mnd^.Code) := CmdReturn;
  FRedisSdkManager.FSIsMember(FRedisClient, PChar(Key),PChar(value),0,block, boolCmdResult, Mnd);
end;

procedure TDxRedisClient.SIsMember(key: string;valueBuffer: PByte;buffLen: Integer; block: Boolean;CmdReturn: TBoolCmdReturn);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  FRedisSdkManager.FSIsMember(FRedisClient, PChar(Key),valueBuffer,buffLen,block, boolCmdResult, Mnd);
end;

procedure TDxRedisClient.SIsMember(key: string;valueBuffer: PByte;buffLen: Integer; block: Boolean;CmdReturn: TBoolCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PBoolCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FSIsMember(FRedisClient, PChar(Key),valueBuffer,buffLen,block, boolCmdResult, Mnd);
end;

procedure TDxRedisClient.SIsMember(key: string;valueBuffer: PByte;buffLen: Integer; block: Boolean;CmdReturn: TBoolCmdReturnG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TBoolCmdReturnA(Mnd^.Code) := CmdReturn;
  FRedisSdkManager.FSIsMember(FRedisClient, PChar(Key),valueBuffer,buffLen,block, boolCmdResult, Mnd);
end;

procedure TDxRedisClient.SMove(source, destination,member: string;block: Boolean;CmdReturn: TBoolCmdReturn);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  FRedisSdkManager.FSMove(FRedisClient, PChar(source),PChar(destination),PChar(member),0,block, boolCmdResult, Mnd);
end;

procedure TDxRedisClient.SMove(source, destination,member: string;block: Boolean;CmdReturn: TBoolCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PBoolCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FSMove(FRedisClient, PChar(source),PChar(destination),PChar(member),0,block, boolCmdResult, Mnd);
end;

procedure TDxRedisClient.SMove(source, destination,member: string;block: Boolean;CmdReturn: TBoolCmdReturnG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TBoolCmdReturnA(Mnd^.Code) := CmdReturn;
  FRedisSdkManager.FSMove(FRedisClient, PChar(source),PChar(destination),PChar(member),0,block, boolCmdResult, Mnd);
end;

procedure TDxRedisClient.SMove(source, destination: string;member: PByte;memberLen: Integer; block: Boolean;CmdReturn: TBoolCmdReturn);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  FRedisSdkManager.FSMove(FRedisClient, PChar(source),PChar(destination),member,memberLen,block, boolCmdResult, Mnd);
end;

procedure TDxRedisClient.SMove(source, destination: string;member: PByte;memberLen: Integer; block: Boolean;CmdReturn: TBoolCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PBoolCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FSMove(FRedisClient, PChar(source),PChar(destination),member,memberLen,block, boolCmdResult, Mnd);
end;

procedure TDxRedisClient.SMove(source, destination: string;member: PByte;memberLen: Integer; block: Boolean;CmdReturn: TBoolCmdReturnG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TBoolCmdReturnA(Mnd^.Code) := CmdReturn;
  FRedisSdkManager.FSMove(FRedisClient, PChar(source),PChar(destination),member,memberLen,block, boolCmdResult, Mnd);
end;

procedure TDxRedisClient.ClientPause(pauseTime: Integer;block: Boolean;CmdReturn: TBoolCmdReturn);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  FRedisSdkManager.FClientPause(FRedisClient, pauseTime,block, boolCmdResult, Mnd);
end;

procedure TDxRedisClient.ClientPause(pauseTime: Integer;block: Boolean;CmdReturn: TBoolCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PBoolCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FClientPause(FRedisClient, pauseTime,block, boolCmdResult, Mnd);
end;

procedure TDxRedisClient.ClientPause(pauseTime: Integer;block: Boolean;CmdReturn: TBoolCmdReturnG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TBoolCmdReturnA(Mnd^.Code) := CmdReturn;
  FRedisSdkManager.FClientPause(FRedisClient, pauseTime,block, boolCmdResult, Mnd);
end;

procedure TDxRedisClient.FreePipeline(pipeClient: Pointer);
begin
  FRedisSdkManager.FFreePipeLiner(pipeClient);
end;

procedure TDxRedisClient.get(Key: string; block: Boolean;
stringCmdReturn: TRedisStringCmdReturn);
var
  Mnd: PStringCmdMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method := TMethod(stringCmdReturn);
  FRedisSdkManager.FGet(FRedisClient, PChar(Key), False, block,
    stringCmdResult, Mnd);
end;

procedure TDxRedisClient.get(Key: string; block: Boolean;
stringCmdReturn: TRedisStringCmdReturnA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PStringCmdMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStringCmdReturnA(@TMethod(ATemp).Code)^ := stringCmdReturn;
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method := TMethod(ATemp);
  FRedisSdkManager.FGet(FRedisClient, PChar(Key), False, block,
    stringCmdResult, Mnd);
end;

procedure TDxRedisClient.get(Key: string; block: Boolean;
stringCmdReturn: TRedisStringCmdReturnG);
var
  Mnd: PStringCmdMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method.Data := nil;
  TRedisStringCmdReturnA(Mnd^.Method.Code) := stringCmdReturn;
  FRedisSdkManager.FGet(FRedisClient, PChar(Key), False, block,
    stringCmdResult, Mnd);
end;

procedure TDxRedisClient.get(Key: string; block: Boolean;
stringCmdReturn: TRedisStringCmdReturnByte);
var
  Mnd: PStringCmdMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Method := TMethod(stringCmdReturn);
  Mnd^.isByteReturn := True;
  FRedisSdkManager.FGet(FRedisClient, PChar(Key), True, block,
    stringCmdResult, Mnd);
end;

procedure TDxRedisClient.get(Key: string; block: Boolean;
stringCmdReturn: TRedisStringCmdReturnByteA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PStringCmdMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStringCmdReturnByteA(@TMethod(ATemp).Code)^ := stringCmdReturn;
  New(Mnd);
  Mnd^.isByteReturn := True;
  Mnd^.Method := TMethod(ATemp);
  FRedisSdkManager.FGet(FRedisClient, PChar(Key), True, block,
    stringCmdResult, Mnd);
end;

procedure TDxRedisClient.GetEx(Key: string; expiration: Integer; block: Boolean;
stringCmdReturn: TRedisStringCmdReturnByte);
var
  Mnd: PStringCmdMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Method := TMethod(stringCmdReturn);
  Mnd^.isByteReturn := True;
  FRedisSdkManager.FGetEx(FRedisClient, PChar(Key), expiration, True, block,
    stringCmdResult, Mnd);
end;

procedure TDxRedisClient.GetEx(Key: string; expiration: Integer; block: Boolean;
stringCmdReturn: TRedisStringCmdReturnByteA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PStringCmdMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStringCmdReturnByteA(@TMethod(ATemp).Code)^ := stringCmdReturn;
  New(Mnd);
  Mnd^.isByteReturn := True;
  Mnd^.Method := TMethod(ATemp);
  FRedisSdkManager.FGetEx(FRedisClient, PChar(Key), expiration, True, block,
    stringCmdResult, Mnd);
end;

procedure TDxRedisClient.GetDel(Key: string; block: Boolean;
stringCmdReturn: TRedisStringCmdReturnByte);
var
  Mnd: PStringCmdMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Method := TMethod(stringCmdReturn);
  Mnd^.isByteReturn := True;
  FRedisSdkManager.FGetDel(FRedisClient, PChar(Key), True, block,
    stringCmdResult, Mnd);
end;

procedure TDxRedisClient.GetDel(Key: string; block: Boolean;
stringCmdReturn: TRedisStringCmdReturnByteA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PStringCmdMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStringCmdReturnByteA(@TMethod(ATemp).Code)^ := stringCmdReturn;
  New(Mnd);
  Mnd^.isByteReturn := True;
  Mnd^.Method := TMethod(ATemp);
  FRedisSdkManager.FGetDel(FRedisClient, PChar(Key), True, block,
    stringCmdResult, Mnd);
end;

procedure TDxRedisClient.GetDel(Key: string; block: Boolean;
stringCmdReturn: TRedisStringCmdReturnByteG);
var
  Mnd: PStringCmdMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Method.Data := nil;
  Mnd^.isByteReturn := True;
  TRedisStringCmdReturnByteA(Mnd^.Method.Code) := stringCmdReturn;
  FRedisSdkManager.FGetDel(FRedisClient, PChar(Key), True, block,
    stringCmdResult, Mnd);
end;

procedure TDxRedisClient.GetEx(Key: string; expiration: Integer; block: Boolean;
stringCmdReturn: TRedisStringCmdReturnByteG);
var
  Mnd: PStringCmdMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Method.Data := nil;
  Mnd^.isByteReturn := True;
  TRedisStringCmdReturnByteA(Mnd^.Method.Code) := stringCmdReturn;
  FRedisSdkManager.FGetEx(FRedisClient, PChar(Key), expiration, True, block,
    stringCmdResult, Mnd);
end;

procedure TDxRedisClient.get(Key: string; block: Boolean;
stringCmdReturn: TRedisStringCmdReturnByteG);
var
  Mnd: PStringCmdMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Method.Data := nil;
  Mnd^.isByteReturn := True;
  TRedisStringCmdReturnByteA(Mnd^.Method.Code) := stringCmdReturn;
  FRedisSdkManager.FGet(FRedisClient, PChar(Key), True, block,
    stringCmdResult, Mnd);
end;

procedure TDxRedisClient.GetDel(Key: string; block: Boolean;
stringCmdReturn: TRedisStringCmdReturn);
var
  Mnd: PStringCmdMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method := TMethod(stringCmdReturn);
  FRedisSdkManager.FGetDel(FRedisClient, PChar(Key), False, block,
    stringCmdResult, Mnd);
end;

procedure TDxRedisClient.GetDel(Key: string; block: Boolean;
stringCmdReturn: TRedisStringCmdReturnA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PStringCmdMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStringCmdReturnA(@TMethod(ATemp).Code)^ := stringCmdReturn;
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method := TMethod(ATemp);
  FRedisSdkManager.FGetDel(FRedisClient, PChar(Key), False, block,
    stringCmdResult, Mnd);
end;

procedure TDxRedisClient.GetDel(Key: string; block: Boolean;
stringCmdReturn: TRedisStringCmdReturnG);
var
  Mnd: PStringCmdMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method.Data := nil;
  TRedisStringCmdReturnA(Mnd^.Method.Code) := stringCmdReturn;
  FRedisSdkManager.FGetDel(FRedisClient, PChar(Key), False, block,
    stringCmdResult, Mnd);
end;

procedure TDxRedisClient.GetEx(Key: string; expiration: Integer; block: Boolean;
stringCmdReturn: TRedisStringCmdReturn);
var
  Mnd: PStringCmdMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method := TMethod(stringCmdReturn);
  FRedisSdkManager.FGetEx(FRedisClient, PChar(Key), expiration, False, block,
    stringCmdResult, Mnd);
end;

procedure TDxRedisClient.GetEx(Key: string; expiration: Integer; block: Boolean;
stringCmdReturn: TRedisStringCmdReturnA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PStringCmdMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStringCmdReturnA(@TMethod(ATemp).Code)^ := stringCmdReturn;
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method := TMethod(ATemp);
  FRedisSdkManager.FGetEx(FRedisClient, PChar(Key), expiration, False, block,
    stringCmdResult, Mnd);
end;

procedure TDxRedisClient.GetEx(Key: string; expiration: Integer; block: Boolean;
stringCmdReturn: TRedisStringCmdReturnG);
var
  Mnd: PStringCmdMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method.Data := nil;
  TRedisStringCmdReturnA(Mnd^.Method.Code) := stringCmdReturn;
  FRedisSdkManager.FGetEx(FRedisClient, PChar(Key), expiration, False, block,
    stringCmdResult, Mnd);
end;

procedure TDxRedisClient.GetRange(Key: string; Start, stop: Int64;
block: Boolean; stringCmdReturn: TRedisStringCmdReturn);
var
  Mnd: PStringCmdMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method := TMethod(stringCmdReturn);
  FRedisSdkManager.FGetRange(FRedisClient, PChar(Key), Start, stop, False,
    block, stringCmdResult, Mnd);
end;

procedure TDxRedisClient.GetRange(Key: string; Start, stop: Int64;
block: Boolean; stringCmdReturnA: TRedisStringCmdReturnA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PStringCmdMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStringCmdReturnA(@TMethod(ATemp).Code)^ := stringCmdReturnA;
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method := TMethod(ATemp);
  FRedisSdkManager.FGetRange(FRedisClient, PChar(Key), Start, stop, False,
    block, stringCmdResult, Mnd);
end;

procedure TDxRedisClient.GetRange(Key: string; Start, stop: Int64;
block: Boolean; stringCmdReturnG: TRedisStringCmdReturnG);
var
  Mnd: PStringCmdMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method.Data := nil;
  TRedisStringCmdReturnA(Mnd^.Method.Code) := stringCmdReturnG;
  FRedisSdkManager.FGetRange(FRedisClient, PChar(Key), Start, stop, False,
    block, stringCmdResult, Mnd);
end;

procedure TDxRedisClient.GetRange(Key: string; Start, stop: Int64;
block: Boolean; stringCmdReturn: TRedisStringCmdReturnByte);
var
  Mnd: PStringCmdMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Method := TMethod(stringCmdReturn);
  Mnd^.isByteReturn := True;
  FRedisSdkManager.FGetRange(FRedisClient, PChar(Key), Start, stop, True, block,
    stringCmdResult, Mnd);
end;

procedure TDxRedisClient.GetRange(Key: string; Start, stop: Int64;
block: Boolean; stringCmdReturnA: TRedisStringCmdReturnByteA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PStringCmdMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStringCmdReturnByteA(@TMethod(ATemp).Code)^ := stringCmdReturnA;
  New(Mnd);
  Mnd^.isByteReturn := True;
  Mnd^.Method := TMethod(ATemp);
  FRedisSdkManager.FGetRange(FRedisClient, PChar(Key), Start, stop, True, block,
    stringCmdResult, Mnd);
end;

procedure TDxRedisClient.GetRange(Key: string; Start, stop: Int64;
block: Boolean; stringCmdReturnG: TRedisStringCmdReturnByteG);
var
  Mnd: PStringCmdMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.isByteReturn := True;
  Mnd^.Method.Data := nil;
  TRedisStringCmdReturnByteA(Mnd^.Method.Code) := stringCmdReturnG;
  FRedisSdkManager.FGetRange(FRedisClient, PChar(Key), Start, stop, True, block,
    stringCmdResult, Mnd);
end;

procedure TDxRedisClient.GetSet(Key, Value: string; block: Boolean;
stringCmdReturn: TRedisStringCmdReturn);
var
  Mnd: PStringCmdMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method := TMethod(stringCmdReturn);
  FRedisSdkManager.FGetSet(FRedisClient, PChar(Key), PChar(Value), 0, block,
    stringCmdResult, Mnd);
end;

procedure TDxRedisClient.GetSet(Key, Value: string; block: Boolean;
stringCmdReturn: TRedisStringCmdReturnA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PStringCmdMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStringCmdReturnA(@TMethod(ATemp).Code)^ := stringCmdReturn;
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method := TMethod(ATemp);
  FRedisSdkManager.FGetSet(FRedisClient, PChar(Key), PChar(Value), 0, block,
    stringCmdResult, Mnd);
end;

procedure TDxRedisClient.GetSet(Key, Value: string; block: Boolean;
stringCmdReturn: TRedisStringCmdReturnG);
var
  Mnd: PStringCmdMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.isByteReturn := True;
  Mnd^.Method.Data := nil;
  TRedisStringCmdReturnA(Mnd^.Method.Code) := stringCmdReturn;
  FRedisSdkManager.FGetSet(FRedisClient, PChar(Key), PChar(Value), 0, block,
    stringCmdResult, Mnd);
end;

procedure TDxRedisClient.GetSet(Key: string; Value: PByte; ValueLen: Integer;
block: Boolean; stringCmdReturn: TRedisStringCmdReturnByte);
var
  Mnd: PStringCmdMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.isByteReturn := True;
  Mnd^.Method := TMethod(stringCmdReturn);
  FRedisSdkManager.FGetSet(FRedisClient, PChar(Key), Value, ValueLen, block,
    stringCmdResult, Mnd);
end;

procedure TDxRedisClient.GetSet(Key: string; Value: PByte; ValueLen: Integer;
block: Boolean; stringCmdReturn: TRedisStringCmdReturnByteA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PStringCmdMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStringCmdReturnByteA(@TMethod(ATemp).Code)^ := stringCmdReturn;
  New(Mnd);
  Mnd^.isByteReturn := True;
  Mnd^.Method := TMethod(ATemp);
  FRedisSdkManager.FGetSet(FRedisClient, PChar(Key), Value, ValueLen, block,
    stringCmdResult, Mnd);
end;

procedure TDxRedisClient.GetSet(Key: string; Value: PByte; ValueLen: Integer;
block: Boolean; stringCmdReturn: TRedisStringCmdReturnByteG);
var
  Mnd: PStringCmdMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.isByteReturn := True;
  Mnd^.Method.Data := nil;
  TRedisStringCmdReturnByteA(Mnd^.Method.Code) := stringCmdReturn;
  FRedisSdkManager.FGetSet(FRedisClient, PChar(Key), Value, ValueLen, block,
    stringCmdResult, Mnd);
end;

procedure TDxRedisClient.HScan(cursor: UInt64; Key, match: string; count: Int64;
block: Boolean; scanCmdReturn: TRedisScanCmdReturn);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(scanCmdReturn);
  FRedisSdkManager.FHScan(FRedisClient, cursor, PChar(Key), PChar(match), count,
    block, scanCmdResult, Mnd);
end;

procedure TDxRedisClient.HScan(cursor: UInt64; Key, match: string; count: Int64;
block: Boolean; scanCmdReturn: TRedisScanCmdReturnA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisScanCmdReturnA(@TMethod(ATemp).Code)^ := scanCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FHScan(FRedisClient, cursor, PChar(Key), PChar(match), count,
    block, scanCmdResult, Mnd);
end;

procedure TDxRedisClient.HGet(Key, field: string; block: Boolean;
stringCmdReturn: TRedisStringCmdReturn);
var
  Mnd: PStringCmdMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method := TMethod(stringCmdReturn);
  FRedisSdkManager.FHGet(FRedisClient, PChar(Key), PChar(field), False, block,
    stringCmdResult, Mnd);
end;

procedure TDxRedisClient.HGet(Key, field: string; block: Boolean;
stringCmdReturn: TRedisStringCmdReturnA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PStringCmdMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStringCmdReturnA(@TMethod(ATemp).Code)^ := stringCmdReturn;
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method := TMethod(ATemp);
  FRedisSdkManager.FHGet(FRedisClient, PChar(Key), PChar(field), False, block,
    stringCmdResult, Mnd);
end;

procedure TDxRedisClient.HGet(Key, field: string; block: Boolean;
stringCmdReturn: TRedisStringCmdReturnG);
var
  Mnd: PStringCmdMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method.Data := nil;
  TRedisStringCmdReturnA(Mnd^.Method.Code) := stringCmdReturn;
  FRedisSdkManager.FHGet(FRedisClient, PChar(Key), PChar(field), False, block,
    stringCmdResult, Mnd);
end;

procedure TDxRedisClient.HScan(cursor: UInt64; Key, match: string; count: Int64;
block: Boolean; scanCmdReturn: TRedisScanCmdReturnG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TRedisScanCmdReturnA(Mnd^.Code) := scanCmdReturn;
  FRedisSdkManager.FHScan(FRedisClient, cursor, PChar(Key), PChar(match), count,
    block, scanCmdResult, Mnd);
end;

procedure TDxRedisClient.HSet(Key: string; keyValues: array of TKeyValue;
block: Boolean; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
  i, l: Integer;
  redisKVs: array of TRedisKeyValue;
begin
  l := Length(keyValues);
  if l = 0 then
    Exit;
  AtomicIncrement(FRunningCount, 1);
  SetLength(redisKVs, l);
  for i := 0 to l - 1 do
  begin
    redisKVs[i].Key := PChar(keyValues[i].Key);
    redisKVs[i].Value.Value := PChar(keyValues[i].Value);
    redisKVs[i].Value.ValueLen := 0;
  end;

  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  FRedisSdkManager.FHSet(FRedisClient, PChar(Key), @redisKVs[0], l, block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.HSet(Key: string; keyValues: array of TKeyValue;
block: Boolean; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
  i, l: Integer;
  redisKVs: array of TRedisKeyValue;
begin
  l := Length(keyValues);
  if l = 0 then
    Exit;
  AtomicIncrement(FRunningCount, 1);
  SetLength(redisKVs, l);
  for i := 0 to l - 1 do
  begin
    redisKVs[i].Key := PChar(keyValues[i].Key);
    redisKVs[i].Value.Value := PChar(keyValues[i].Value);
    redisKVs[i].Value.ValueLen := 0;
  end;
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FHSet(FRedisClient, PChar(Key), @redisKVs[0], l, block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.HSet(Key: string; keyValues: array of TKeyValue;
block: Boolean; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
  i, l: Integer;
  redisKVs: array of TRedisKeyValue;
begin
  l := Length(keyValues);
  if l = 0 then
    Exit;
  AtomicIncrement(FRunningCount, 1);
  SetLength(redisKVs, l);
  for i := 0 to l - 1 do
  begin
    redisKVs[i].Key := PChar(keyValues[i].Key);
    redisKVs[i].Value.Value := PChar(keyValues[i].Value);
    redisKVs[i].Value.ValueLen := 0;
  end;
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  FRedisSdkManager.FHSet(FRedisClient, PChar(Key), @redisKVs[0], l, block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.HSet(Key: string; keyValues: array of TRedisKeyValue;
block: Boolean; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
  i, l: Integer;
begin
  l := Length(keyValues);
  if l = 0 then
    Exit;
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  FRedisSdkManager.FHSet(FRedisClient, PChar(Key), @keyValues[0], l, block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.HSet(Key: string; keyValues: array of TRedisKeyValue;
block: Boolean; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
  i, l: Integer;
begin
  l := Length(keyValues);
  if l = 0 then
    Exit;
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FHSet(FRedisClient, PChar(Key), @keyValues[0], l, block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.HSet(Key: string; keyValues: array of TRedisKeyValue;
block: Boolean; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
  i, l: Integer;
begin
  l := Length(keyValues);
  if l = 0 then
    Exit;
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  FRedisSdkManager.FHSet(FRedisClient, PChar(Key), @keyValues[0], l, block,
    intCmdResult, Mnd);
end;


procedure TDxRedisClient.Info(sections: array of string; block: Boolean;
stringCmdReturn: TRedisStringCmdReturn);
var
  Mnd: PStringCmdMethod;
  section: string;
  i: Integer;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method := TMethod(stringCmdReturn);
  section := '';
  if Length(sections) > 0 then
  begin
    for i := Low(sections) to High(sections) do
    begin
      if section = '' then
        section := sections[i]
      else
        section := section + ';' + sections[i];
    end;
  end;
  FRedisSdkManager.FInfo(FRedisClient, PChar(section), block,
    stringCmdResult, Mnd)
end;

procedure TDxRedisClient.Info(sections: array of string; block: Boolean;
stringCmdReturn: TRedisStringCmdReturnA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PStringCmdMethod;
  section: string;
  i: Integer;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStringCmdReturnA(@TMethod(ATemp).Code)^ := stringCmdReturn;
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method := TMethod(ATemp);

  section := '';
  if Length(sections) > 0 then
  begin
    for i := Low(sections) to High(sections) do
    begin
      if section = '' then
        section := sections[i]
      else
        section := section + ';' + sections[i];
    end;
  end;
  FRedisSdkManager.FInfo(FRedisClient, PChar(section), block,
    stringCmdResult, Mnd)
end;

procedure TDxRedisClient.Info(sections: array of string; block: Boolean;
stringCmdReturn: TRedisStringCmdReturnG);
var
  Mnd: PStringCmdMethod;
  section: string;
  i: Integer;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method.Data := nil;
  TRedisStringCmdReturnA(Mnd^.Method.Code) := stringCmdReturn;

  section := '';
  if Length(sections) > 0 then
  begin
    for i := Low(sections) to High(sections) do
    begin
      if section = '' then
        section := sections[i]
      else
        section := section + ';' + sections[i];
    end;
  end;
  FRedisSdkManager.FInfo(FRedisClient, PChar(section), block,
    stringCmdResult, Mnd)
end;

procedure TDxRedisClient.InitRedisClient;
var
  singCfg: TRedisSingleCfg;
  Sentinel: TRedisSentinelCfg;
  redisCfg: TRedisConfig;
begin
  redisCfg.ConStyle := FConStyle;
  redisCfg.ClientData := self;
  case FConStyle of
    RedisConSingle:
      begin
        FillChar(singCfg, Sizeof(singCfg), 0);
        singCfg.Network := 'tcp';
        singCfg.MaxRetries := FMaxRetry;
        singCfg.Addr := PChar(FAddress);
        singCfg.Username := PChar(FUserName);
        singCfg.Password := PChar(FPassword);
        singCfg.DBIndex := FDefaultDBIndex;
        singCfg.DialTimeout := FDialTimeout;
        singCfg.ReadTimeout := FReadTimeout;
        singCfg.WriteTimeout := FWriteTimeout;

        redisCfg.Data := @singCfg;
        FRedisClient := FRedisSdkManager.FNewRedisConnection(@redisCfg);
      end;
    RedisConSentinel:
      begin
        FillChar(Sentinel, Sizeof(Sentinel), 0);
        Sentinel.MasterName := PChar(FUserName);
        Sentinel.SentinelAddrs := PChar(FAddress);
        Sentinel.DBIndex := FDefaultDBIndex;
        Sentinel.MaxRetries := FMaxRetry;
        Sentinel.Password := PChar(FPassword);
        Sentinel.DialTimeout := FDialTimeout;
        Sentinel.ReadTimeout := FReadTimeout;
        Sentinel.WriteTimeout := FWriteTimeout;

        redisCfg.Data := @Sentinel;
        FRedisClient := FRedisSdkManager.FNewRedisConnection(@redisCfg);
      end;
    RedisConCluster:
      ;
  end;
  if FRedisClient <> nil then
    FRedisSdkManager.FClients.Add(self)
end;

procedure TDxRedisClient.LSet(Key: string; index: Int64; Value: string;
block: Boolean; StatusCmdReturn: TRedisStatusCmd);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(StatusCmdReturn);
  FRedisSdkManager.FLSet(FRedisClient, PChar(Key), index, PChar(Value), 0,
    block, statusCmdResult, Mnd);
end;

procedure TDxRedisClient.LSet(Key: string; index: Int64; Value: string;
block: Boolean; StatusCmdReturn: TRedisStatusCmdA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStatusCmdA(@TMethod(ATemp).Code)^ := StatusCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FLSet(FRedisClient, PChar(Key), index, PChar(Value), 0,
    block, statusCmdResult, Mnd);
end;

procedure TDxRedisClient.LSet(Key: string; index: Int64; Value: string;
block: Boolean; StatusCmdReturn: TRedisStatusCmdG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TRedisStatusCmdA(Mnd^.Code) := StatusCmdReturn;
  FRedisSdkManager.FLSet(FRedisClient, PChar(Key), index, PChar(Value), 0,
    block, statusCmdResult, Mnd);
end;

procedure TDxRedisClient.Migrate(host, port, Key: string; db, timeout: Integer;
block: Boolean; StatusCmdReturn: TRedisStatusCmd);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(StatusCmdReturn);
  AtomicIncrement(FRunningCount, 1);
  FRedisSdkManager.FMigrate(FRedisClient, PChar(host), PChar(port), PChar(Key),
    db, timeout, block, statusCmdResult, Mnd);
end;

procedure TDxRedisClient.Migrate(host, port, Key: string; db, timeout: Integer;
block: Boolean; StatusCmdReturn: TRedisStatusCmdA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PMethod;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStatusCmdA(@TMethod(ATemp).Code)^ := StatusCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  AtomicIncrement(FRunningCount, 1);
  FRedisSdkManager.FMigrate(FRedisClient, PChar(host), PChar(port), PChar(Key),
    db, timeout, block, statusCmdResult, Mnd);
end;

procedure TDxRedisClient.Migrate(host, port, Key: string; db, timeout: Integer;
block: Boolean; StatusCmdReturn: TRedisStatusCmdG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TRedisStatusCmdA(Mnd^.Code) := StatusCmdReturn;
  AtomicIncrement(FRunningCount, 1);
  FRedisSdkManager.FMigrate(FRedisClient, PChar(host), PChar(port), PChar(Key),
    db, timeout, block, statusCmdResult, Mnd);
end;

procedure TDxRedisClient.MSet(keyValueArray: array of TKeyValue; block: Boolean;
StatusCmdReturn: TRedisStatusCmd);
var
  Mnd: PMethod;
  i, l: Integer;
  redisKVs: array of TRedisKeyValue;
begin
  l := Length(keyValueArray);
  if l = 0 then
    Exit;
  AtomicIncrement(FRunningCount, 1);
  SetLength(redisKVs, l);
  for i := 0 to l - 1 do
  begin
    redisKVs[i].Key := PChar(keyValueArray[i].Key);
    redisKVs[i].Value.Value := PChar(keyValueArray[i].Value);
    redisKVs[i].Value.ValueLen := 0;
  end;

  New(Mnd);
  Mnd^ := TMethod(StatusCmdReturn);
  FRedisSdkManager.FMSet(FRedisClient, @redisKVs[0], l, block,
    statusCmdResult, Mnd);
end;

procedure TDxRedisClient.MSet(keyValueArray: array of TKeyValue; block: Boolean;
StatusCmdReturn: TRedisStatusCmdA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PMethod;
  l, i: Integer;
  redisKVs: array of TRedisKeyValue;
begin
  l := Length(keyValueArray);
  if l = 0 then
    Exit;
  AtomicIncrement(FRunningCount, 1);
  SetLength(redisKVs, l);
  for i := 0 to l - 1 do
  begin
    redisKVs[i].Key := PChar(keyValueArray[i].Key);
    redisKVs[i].Value.Value := PChar(keyValueArray[i].Value);
    redisKVs[i].Value.ValueLen := 0;
  end;
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStatusCmdA(@TMethod(ATemp).Code)^ := StatusCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FMSet(FRedisClient, @redisKVs[0], l, block,
    statusCmdResult, Mnd);
end;

procedure TDxRedisClient.MSet(keyValueArray: array of TKeyValue; block: Boolean;
StatusCmdReturn: TRedisStatusCmdG);
var
  Mnd: PMethod;
  l, i: Integer;
  redisKVs: array of TRedisKeyValue;
begin
  l := Length(keyValueArray);
  if l = 0 then
    Exit;
  AtomicIncrement(FRunningCount, 1);
  SetLength(redisKVs, l);
  for i := 0 to l - 1 do
  begin
    redisKVs[i].Key := PChar(keyValueArray[i].Key);
    redisKVs[i].Value.Value := PChar(keyValueArray[i].Value);
    redisKVs[i].Value.ValueLen := 0;
  end;

  New(Mnd);
  Mnd^.Data := nil;
  TRedisStatusCmdA(Mnd^.Code) := StatusCmdReturn;
  FRedisSdkManager.FMSet(FRedisClient, @redisKVs[0], l, block,
    statusCmdResult, Mnd);
end;

procedure TDxRedisClient.MSet(keyValueArray: array of TRedisKeyValue; block: Boolean;
StatusCmdReturn: TRedisStatusCmd);
var
  Mnd: PMethod;
  i, l: Integer;
begin
  l := Length(keyValueArray);
  if l = 0 then
    Exit;
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(StatusCmdReturn);
  FRedisSdkManager.FMSet(FRedisClient, @keyValueArray[0], l, block,
    statusCmdResult, Mnd);
end;

procedure TDxRedisClient.MSet(keyValueArray: array of TRedisKeyValue; block: Boolean;
StatusCmdReturn: TRedisStatusCmdA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PMethod;
  l, i: Integer;
begin
  l := Length(keyValueArray);
  if l = 0 then
    Exit;
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStatusCmdA(@TMethod(ATemp).Code)^ := StatusCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FMSet(FRedisClient, @keyValueArray[0], l, block,
    statusCmdResult, Mnd);
end;

procedure TDxRedisClient.MSet(keyValueArray: array of TRedisKeyValue; block: Boolean;
StatusCmdReturn: TRedisStatusCmdG);
var
  Mnd: PMethod;
  l, i: Integer;
begin
  l := Length(keyValueArray);
  if l = 0 then
    Exit;
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TRedisStatusCmdA(Mnd^.Code) := StatusCmdReturn;
  FRedisSdkManager.FMSet(FRedisClient, @keyValueArray[0], l, block,
    statusCmdResult, Mnd);
end;

function TDxRedisClient.NewPipeline(isTxPipe: Boolean;Data: Pointer): Pointer;
begin
  Result := FRedisSdkManager.FNewPipeLiner(FRedisClient,Data,isTxPipe);
end;

procedure TDxRedisClient.ObjectRefCount(Key: string; block: Boolean;
intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  FRedisSdkManager.FObjectRefCount(FRedisClient, PChar(Key), block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.ObjectRefCount(Key: string; block: Boolean;
intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FObjectRefCount(FRedisClient, PChar(Key), block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.ObjectRefCount(Key: string; block: Boolean;
intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  FRedisSdkManager.FObjectRefCount(FRedisClient, PChar(Key), block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.Ping(block: Boolean;
StatusCmdReturn: TRedisStatusCmdG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TRedisStatusCmdA(Mnd^.Code) := StatusCmdReturn;
  AtomicIncrement(FRunningCount, 1);
  FRedisSdkManager.FPing(FRedisClient, block, statusCmdResult, Mnd);
end;

procedure TDxRedisClient.Rename(Key, NewKey: string; block: Boolean;
StatusCmdReturn: TRedisStatusCmd);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(StatusCmdReturn);
  AtomicIncrement(FRunningCount, 1);
  FRedisSdkManager.FRename(FRedisClient, PChar(Key), PChar(NewKey), block,
    statusCmdResult, Mnd);
end;

procedure TDxRedisClient.Rename(Key, NewKey: string; block: Boolean;
StatusCmdReturn: TRedisStatusCmdA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PMethod;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStatusCmdA(@TMethod(ATemp).Code)^ := StatusCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  AtomicIncrement(FRunningCount, 1);
  FRedisSdkManager.FRename(FRedisClient, PChar(Key), PChar(NewKey), block,
    statusCmdResult, Mnd);
end;

procedure TDxRedisClient.Rename(Key, NewKey: string; block: Boolean;
StatusCmdReturn: TRedisStatusCmdG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TRedisStatusCmdA(Mnd^.Code) := StatusCmdReturn;
  AtomicIncrement(FRunningCount, 1);
  FRedisSdkManager.FRename(FRedisClient, PChar(Key), PChar(NewKey), block,
    statusCmdResult, Mnd);
end;

procedure TDxRedisClient.Restore(Key, Value: string; ttl: Integer;
block: Boolean; StatusCmdReturn: TRedisStatusCmd);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(StatusCmdReturn);
  AtomicIncrement(FRunningCount, 1);
  FRedisSdkManager.FRestore(FRedisClient, PChar(Key), PChar(Key), ttl, block,
    statusCmdResult, Mnd);
end;

procedure TDxRedisClient.Restore(Key, Value: string; ttl: Integer;
block: Boolean; StatusCmdReturn: TRedisStatusCmdA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStatusCmdA(@TMethod(ATemp).Code)^ := StatusCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FRestore(FRedisClient, PChar(Key), PChar(Key), ttl, block,
    statusCmdResult, Mnd);
end;

procedure TDxRedisClient.Restore(Key, Value: string; ttl: Integer;
block: Boolean; StatusCmdReturn: TRedisStatusCmdG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TRedisStatusCmdA(Mnd^.Code) := StatusCmdReturn;
  FRedisSdkManager.FRestore(FRedisClient, PChar(Key), PChar(Key), ttl, block,
    statusCmdResult, Mnd);
end;

procedure TDxRedisClient.RestoreReplace(Key, Value: string; ttl: Integer;
block: Boolean; StatusCmdReturn: TRedisStatusCmd);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(StatusCmdReturn);
  FRedisSdkManager.FRestoreReplace(FRedisClient, PChar(Key), PChar(Key), ttl,
    block, statusCmdResult, Mnd);
end;

procedure TDxRedisClient.RestoreReplace(Key, Value: string; ttl: Integer;
block: Boolean; StatusCmdReturn: TRedisStatusCmdA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStatusCmdA(@TMethod(ATemp).Code)^ := StatusCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FRestoreReplace(FRedisClient, PChar(Key), PChar(Key), ttl,
    block, statusCmdResult, Mnd);
end;

procedure TDxRedisClient.RestoreReplace(Key, Value: string; ttl: Integer;
block: Boolean; StatusCmdReturn: TRedisStatusCmdG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TRedisStatusCmdA(Mnd^.Code) := StatusCmdReturn;
  FRedisSdkManager.FRestoreReplace(FRedisClient, PChar(Key), PChar(Key), ttl,
    block, statusCmdResult, Mnd);
end;

procedure TDxRedisClient.RPopLPush(src, dst: string; block: Boolean;
stringCmdReturn: TRedisStringCmdReturnG);
var
  Mnd: PStringCmdMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method.Data := nil;
  TRedisStringCmdReturnA(Mnd^.Method.Code) := stringCmdReturn;
  FRedisSdkManager.FRPopLPush(FRedisClient, PChar(src), PChar(dst), False,
    block, stringCmdResult, Mnd);
end;

procedure TDxRedisClient.RPopLPush(src, dst: string; block: Boolean;
stringCmdReturn: TRedisStringCmdReturnA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PStringCmdMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStringCmdReturnA(@TMethod(ATemp).Code)^ := stringCmdReturn;
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method := TMethod(ATemp);
  FRedisSdkManager.FRPopLPush(FRedisClient, PChar(src), PChar(dst), False,
    block, stringCmdResult, Mnd);
end;

procedure TDxRedisClient.RPopLPush(src, dst: string; block: Boolean;
stringCmdReturn: TRedisStringCmdReturn);
var
  Mnd: PStringCmdMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method := TMethod(stringCmdReturn);
  FRedisSdkManager.FRPopLPush(FRedisClient, PChar(src), PChar(dst), False,
    block, stringCmdResult, Mnd);
end;

procedure TDxRedisClient.RPopLPush(src, dst: string; block: Boolean;
stringCmdReturn: TRedisStringCmdReturnByteG);
var
  Mnd: PStringCmdMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Method.Data := nil;
  Mnd^.isByteReturn := True;
  TRedisStringCmdReturnByteA(Mnd^.Method.Code) := stringCmdReturn;
  FRedisSdkManager.FRPopLPush(FRedisClient, PChar(src), PChar(dst), True, block,
    stringCmdResult, Mnd);
end;

procedure TDxRedisClient.RPopLPush(src, dst: string; block: Boolean;
stringCmdReturn: TRedisStringCmdReturnByteA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PStringCmdMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStringCmdReturnByteA(@TMethod(ATemp).Code)^ := stringCmdReturn;
  New(Mnd);
  Mnd^.isByteReturn := True;
  Mnd^.Method := TMethod(ATemp);
  FRedisSdkManager.FRPopLPush(FRedisClient, PChar(src), PChar(dst), True, block,
    stringCmdResult, Mnd);
end;

procedure TDxRedisClient.RPopLPush(src, dst: string; block: Boolean;
stringCmdReturn: TRedisStringCmdReturnByte);
var
  Mnd: PStringCmdMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Method := TMethod(stringCmdReturn);
  Mnd^.isByteReturn := True;
  FRedisSdkManager.FRPopLPush(FRedisClient, PChar(src), PChar(dst), True, block,
    stringCmdResult, Mnd);
end;

procedure TDxRedisClient.Ping(block: Boolean;
StatusCmdReturn: TRedisStatusCmdA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PMethod;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStatusCmdA(@TMethod(ATemp).Code)^ := StatusCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  AtomicIncrement(FRunningCount, 1);
  FRedisSdkManager.FPing(FRedisClient, block, statusCmdResult, Mnd);
end;

procedure TDxRedisClient.Ping(block: Boolean; StatusCmdReturn: TRedisStatusCmd);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(StatusCmdReturn);
  AtomicIncrement(FRunningCount, 1);
  FRedisSdkManager.FPing(FRedisClient, block, statusCmdResult, Mnd);
end;

procedure TDxRedisClient.ScriptFlush(block: Boolean;
StatusCmdReturn: TRedisStatusCmd);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(StatusCmdReturn);
  FRedisSdkManager.FScriptFlush(FRedisClient, block, statusCmdResult, Mnd);
end;

procedure TDxRedisClient.ScriptFlush(block: Boolean;
StatusCmdReturn: TRedisStatusCmdA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStatusCmdA(@TMethod(ATemp).Code)^ := StatusCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FScriptFlush(FRedisClient, block, statusCmdResult, Mnd);
end;

procedure TDxRedisClient.Scan(cursor: UInt64; match: string; count: Int64;
block: Boolean; scanCmdReturn: TRedisScanCmdReturn);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(scanCmdReturn);
  FRedisSdkManager.FScan(FRedisClient, cursor, PChar(match), count, block,
    scanCmdResult, Mnd);
end;

procedure TDxRedisClient.Scan(cursor: UInt64; match: string; count: Int64;
block: Boolean; scanCmdReturn: TRedisScanCmdReturnA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisScanCmdReturnA(@TMethod(ATemp).Code)^ := scanCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FScan(FRedisClient, cursor, PChar(match), count, block,
    scanCmdResult, Mnd);
end;

procedure TDxRedisClient.Scan(cursor: UInt64; match: string; count: Int64;
block: Boolean; scanCmdReturn: TRedisScanCmdReturnG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TRedisScanCmdReturnA(Mnd^.Code) := scanCmdReturn;
  FRedisSdkManager.FScan(FRedisClient, cursor, PChar(match), count, block,
    scanCmdResult, Mnd);
end;

procedure TDxRedisClient.ScanType(cursor: UInt64; match, KeyType: string;
count: Int64; block: Boolean; scanCmdReturn: TRedisScanCmdReturn);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(scanCmdReturn);
  FRedisSdkManager.FScanType(FRedisClient, cursor, PChar(match), PChar(KeyType),
    count, block, scanCmdResult, Mnd);
end;

procedure TDxRedisClient.ScanType(cursor: UInt64; match, KeyType: string;
count: Int64; block: Boolean; scanCmdReturn: TRedisScanCmdReturnA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisScanCmdReturnA(@TMethod(ATemp).Code)^ := scanCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FScanType(FRedisClient, cursor, PChar(match), PChar(KeyType),
    count, block, scanCmdResult, Mnd);
end;

procedure TDxRedisClient.ScanType(cursor: UInt64; match, KeyType: string;
count: Int64; block: Boolean; scanCmdReturn: TRedisScanCmdReturnG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TRedisScanCmdReturnA(Mnd^.Code) := scanCmdReturn;
  FRedisSdkManager.FScanType(FRedisClient, cursor, PChar(match), PChar(KeyType),
    count, block, scanCmdResult, Mnd);
end;

procedure TDxRedisClient.ScriptFlush(block: Boolean;
StatusCmdReturn: TRedisStatusCmdG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TRedisStatusCmdA(Mnd^.Code) := StatusCmdReturn;
  FRedisSdkManager.FScriptFlush(FRedisClient, block, statusCmdResult, Mnd);
end;

procedure TDxRedisClient.ScriptKill(block: Boolean;
StatusCmdReturn: TRedisStatusCmd);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(StatusCmdReturn);
  FRedisSdkManager.FScriptKill(FRedisClient, block, statusCmdResult, Mnd);
end;

procedure TDxRedisClient.ScriptKill(block: Boolean;
StatusCmdReturn: TRedisStatusCmdA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStatusCmdA(@TMethod(ATemp).Code)^ := StatusCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FScriptKill(FRedisClient, block, statusCmdResult, Mnd);
end;

procedure TDxRedisClient.ScriptKill(block: Boolean;
StatusCmdReturn: TRedisStatusCmdG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TRedisStatusCmdA(Mnd^.Code) := StatusCmdReturn;
  FRedisSdkManager.FScriptKill(FRedisClient, block, statusCmdResult, Mnd);
end;

procedure TDxRedisClient.ScriptLoad(script: string; block: Boolean;
StatusCmdReturn: TRedisStatusCmd);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(StatusCmdReturn);
  FRedisSdkManager.FScriptLoad(FRedisClient, PChar(script), block,
    statusCmdResult, Mnd);
end;

procedure TDxRedisClient.ScriptLoad(script: string; block: Boolean;
StatusCmdReturn: TRedisStatusCmdA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStatusCmdA(@TMethod(ATemp).Code)^ := StatusCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FScriptLoad(FRedisClient, PChar(script), block,
    statusCmdResult, Mnd);
end;

procedure TDxRedisClient.ScriptLoad(script: string; block: Boolean;
StatusCmdReturn: TRedisStatusCmdG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TRedisStatusCmdA(Mnd^.Code) := StatusCmdReturn;
  FRedisSdkManager.FScriptLoad(FRedisClient, PChar(script), block,
    statusCmdResult, Mnd);
end;

procedure TDxRedisClient.SelectAndScan(index: Integer; match, KeyType: string;
count: Integer; block: Boolean; scanCmdReturn: TRedisSelectScanCmdReturn);
var
  Mnd: PSelectCmdMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.DBIndex := index;
  Mnd^.Method := TMethod(scanCmdReturn);
  FRedisSdkManager.FSelectAndScan(FRedisClient, index, count, PChar(match),
    PChar(KeyType), block, selectAndScanCmdResult, Mnd);
end;

procedure TDxRedisClient.SelectAndScan(index: Integer; match, KeyType: string;
count: Integer; block: Boolean; scanCmdReturn: TRedisSelectScanCmdReturnG);
var
  Mnd: PSelectCmdMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.DBIndex := index;
  Mnd^.Method.Data := nil;
  TRedisSelectScanCmdReturnA(Mnd^.Method.Code) := scanCmdReturn;
  FRedisSdkManager.FSelectAndScan(FRedisClient, index, count, PChar(match),
    PChar(KeyType), block, selectAndScanCmdResult, Mnd);
end;

procedure TDxRedisClient.SelectAndScan(index: Integer; match, KeyType: string;
count: Integer; block: Boolean; scanCmdReturn: TRedisSelectScanCmdReturnA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PSelectCmdMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisSelectScanCmdReturnA(@TMethod(ATemp).Code)^ := scanCmdReturn;
  New(Mnd);
  Mnd^.DBIndex := index;
  Mnd^.Method := TMethod(ATemp);
  FRedisSdkManager.FSelectAndScan(FRedisClient, index, count, PChar(match),
    PChar(KeyType), block, selectAndScanCmdResult, Mnd);
end;

procedure TDxRedisClient.SetAddress(const Value: string);
begin
  FAddress := Value;
end;

procedure TDxRedisClient.SetArgs(Key: string; ValueBuffer: PByte;
BufferLen: Integer; args: TsetArgs; block: Boolean;
StatusCmdReturn: TRedisStatusCmd);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(StatusCmdReturn);
  FRedisSdkManager.FSetArgs(FRedisClient, PChar(Key), ValueBuffer, BufferLen,
    @args, block, statusCmdResult, Mnd);
end;

procedure TDxRedisClient.SetArgs(Key: string; ValueBuffer: PByte;
BufferLen: Integer; args: TsetArgs; block: Boolean;
StatusCmdReturn: TRedisStatusCmdA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStatusCmdA(@TMethod(ATemp).Code)^ := StatusCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FSetArgs(FRedisClient, PChar(Key), ValueBuffer, BufferLen,
    @args, block, statusCmdResult, Mnd);
end;

procedure TDxRedisClient.SetArgs(Key: string; ValueBuffer: PByte;
BufferLen: Integer; args: TsetArgs; block: Boolean;
StatusCmdReturn: TRedisStatusCmdG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TRedisStatusCmdA(Mnd^.Code) := StatusCmdReturn;
  FRedisSdkManager.FSetArgs(FRedisClient, PChar(Key), ValueBuffer, BufferLen,
    @args, block, statusCmdResult, Mnd);
end;

procedure TDxRedisClient.SetArgs(Key, Value: string; args: TsetArgs;
block: Boolean; StatusCmdReturn: TRedisStatusCmd);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(StatusCmdReturn);
  FRedisSdkManager.FSetArgs(FRedisClient, PChar(Key), PChar(Value), 0, @args,
    block, statusCmdResult, Mnd);
end;

procedure TDxRedisClient.SetArgs(Key, Value: string; args: TsetArgs;
block: Boolean; StatusCmdReturn: TRedisStatusCmdA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStatusCmdA(@TMethod(ATemp).Code)^ := StatusCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FSetArgs(FRedisClient, PChar(Key), PChar(Value), 0, @args,
    block, statusCmdResult, Mnd);
end;

procedure TDxRedisClient.SetArgs(Key, Value: string; args: TsetArgs;
block: Boolean; StatusCmdReturn: TRedisStatusCmdG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TRedisStatusCmdA(Mnd^.Code) := StatusCmdReturn;
  FRedisSdkManager.FSetArgs(FRedisClient, PChar(Key), PChar(Value), 0, @args,
    block, statusCmdResult, Mnd);
end;

procedure TDxRedisClient.SetCmd(Key, Value: string; expiration: Integer;
block: Boolean; StatusCmdReturn: TRedisStatusCmd);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(StatusCmdReturn);
  FRedisSdkManager.FSet(FRedisClient, PChar(Key), PChar(Value), 0, expiration,
    block, statusCmdResult, Mnd);
end;

procedure TDxRedisClient.SetCmd(Key, Value: string; expiration: Integer;
block: Boolean; StatusCmdReturn: TRedisStatusCmdA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStatusCmdA(@TMethod(ATemp).Code)^ := StatusCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FSet(FRedisClient, PChar(Key), PChar(Value), 0, expiration,
    block, statusCmdResult, Mnd);
end;

procedure TDxRedisClient.SetCmd(Key, Value: string; expiration: Integer;
block: Boolean; StatusCmdReturn: TRedisStatusCmdG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TRedisStatusCmdA(Mnd^.Code) := StatusCmdReturn;
  FRedisSdkManager.FSet(FRedisClient, PChar(Key), PChar(Value), 0, expiration,
    block, statusCmdResult, Mnd);
end;

procedure TDxRedisClient.SetConStyle(const Value: TRedisConStyle);
begin
  FConStyle := Value;
end;

procedure TDxRedisClient.SetDefaultDBIndex(const Value: Byte);
begin
  if FDefaultDBIndex <> Value then
  begin
    FDefaultDBIndex := Value;
    if FRedisClient <> nil then
    begin
      // 执行Select指令

    end;
  end;
end;

procedure TDxRedisClient.SetDialTimeout(const Value: Byte);
begin
  FDialTimeout := Value;
end;

procedure TDxRedisClient.SetEx(Key, Value: string; expiration: Integer;
block: Boolean; StatusCmdReturn: TRedisStatusCmdG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TRedisStatusCmdA(Mnd^.Code) := StatusCmdReturn;
  FRedisSdkManager.FSetEx(FRedisClient, PChar(Key), PChar(Value), 0, expiration,
    block, statusCmdResult, Mnd);
end;

procedure TDxRedisClient.SetEx(Key, Value: string; expiration: Integer;
block: Boolean; StatusCmdReturn: TRedisStatusCmdA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStatusCmdA(@TMethod(ATemp).Code)^ := StatusCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FSetEx(FRedisClient, PChar(Key), PChar(Value), 0, expiration,
    block, statusCmdResult, Mnd);
end;

procedure TDxRedisClient.SetEx(Key, Value: string; expiration: Integer;
block: Boolean; StatusCmdReturn: TRedisStatusCmd);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(StatusCmdReturn);
  FRedisSdkManager.FSetEx(FRedisClient, PChar(Key), PChar(Value), 0, expiration,
    block, statusCmdResult, Mnd);
end;

procedure TDxRedisClient.SetEx(Key: string; ValueBuffer: PByte;
BufferLen, expiration: Integer; block: Boolean;
StatusCmdReturn: TRedisStatusCmdG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TRedisStatusCmdA(Mnd^.Code) := StatusCmdReturn;
  FRedisSdkManager.FSetEx(FRedisClient, PChar(Key), ValueBuffer, BufferLen,
    expiration, block, statusCmdResult, Mnd);
end;

procedure TDxRedisClient.SetMaxRetry(const Value: Byte);
begin
  FMaxRetry := Value;
end;

procedure TDxRedisClient.SetEx(Key: string; ValueBuffer: PByte;
BufferLen, expiration: Integer; block: Boolean;
StatusCmdReturn: TRedisStatusCmdA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStatusCmdA(@TMethod(ATemp).Code)^ := StatusCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FSetEx(FRedisClient, PChar(Key), ValueBuffer, BufferLen,
    expiration, block, statusCmdResult, Mnd);
end;

procedure TDxRedisClient.SetEx(Key: string; ValueBuffer: PByte;
BufferLen, expiration: Integer; block: Boolean;
StatusCmdReturn: TRedisStatusCmd);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(StatusCmdReturn);
  FRedisSdkManager.FSetEx(FRedisClient, PChar(Key), ValueBuffer, BufferLen,
    expiration, block, statusCmdResult, Mnd);
end;

procedure TDxRedisClient.SetPassword(const Value: string);
begin
  FPassword := Value;
end;

procedure TDxRedisClient.SetRange(Key: string; offset: Int64; Value: string;
block: Boolean; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  FRedisSdkManager.FSetRange(FRedisClient, PChar(Key), offset, PChar(Value),
    block, intCmdResult, Mnd);
end;

procedure TDxRedisClient.SetRange(Key: string; offset: Int64; Value: string;
block: Boolean; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FSetRange(FRedisClient, PChar(Key), offset, PChar(Value),
    block, intCmdResult, Mnd);
end;

procedure TDxRedisClient.SetRange(Key: string; offset: Int64; Value: string;
block: Boolean; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  FRedisSdkManager.FSetRange(FRedisClient, PChar(Key), offset, PChar(Value),
    block, intCmdResult, Mnd);
end;

procedure TDxRedisClient.SetBit(Key: string; offset: Int64; Value: Integer;
block: Boolean; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  FRedisSdkManager.FSetBit(FRedisClient, PChar(Key), offset, Value, block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.SetBit(Key: string; offset: Int64; Value: Integer;
block: Boolean; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FSetBit(FRedisClient, PChar(Key), offset, Value, block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.SetBit(Key: string; offset: Int64; Value: Integer;
block: Boolean; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  FRedisSdkManager.FSetBit(FRedisClient, PChar(Key), offset, Value, block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.GetBit(Key: string; offset: Int64; block: Boolean;
intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  FRedisSdkManager.FGetBit(FRedisClient, PChar(Key), offset, block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.GetBit(Key: string; offset: Int64; block: Boolean;
intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FGetBit(FRedisClient, PChar(Key), offset, block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.GetBit(Key: string; offset: Int64; block: Boolean;
intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  FRedisSdkManager.FGetBit(FRedisClient, PChar(Key), offset, block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.SetReadTimeout(const Value: Byte);
begin
  FReadTimeout := Value;
end;

procedure TDxRedisClient.SetRedisSdkManager(const Value: TDxRedisSdkManager);
begin
  if FRedisSdkManager <> Value then
  begin
    if FRedisSdkManager <> nil then
      CloseRedisClient;
    FRedisSdkManager := Value;
    if FRedisSdkManager <> nil then
      InitRedisClient;
  end;
end;

procedure TDxRedisClient.SetUserName(const Value: string);
begin
  FUserName := Value;
end;

procedure TDxRedisClient.SetWriteTimeout(const Value: Byte);
begin
  FWriteTimeout := Value;
end;

procedure TDxRedisClient.SScan(cursor: UInt64; Key, match: string; count: Int64;
block: Boolean; scanCmdReturn: TRedisScanCmdReturn);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(scanCmdReturn);
  FRedisSdkManager.FSScan(FRedisClient, cursor, PChar(Key), PChar(match), count,
    block, scanCmdResult, Mnd);
end;

procedure TDxRedisClient.SScan(cursor: UInt64; Key, match: string; count: Int64;
block: Boolean; scanCmdReturn: TRedisScanCmdReturnA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisScanCmdReturnA(@TMethod(ATemp).Code)^ := scanCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FSScan(FRedisClient, cursor, PChar(Key), PChar(match), count,
    block, scanCmdResult, Mnd);
end;

procedure TDxRedisClient.SScan(cursor: UInt64; Key, match: string; count: Int64;
block: Boolean; scanCmdReturn: TRedisScanCmdReturnG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TRedisScanCmdReturnA(Mnd^.Code) := scanCmdReturn;
  FRedisSdkManager.FSScan(FRedisClient, cursor, PChar(Key), PChar(match), count,
    block, scanCmdResult, Mnd);
end;

procedure TDxRedisClient.SetCmd(Key: string; ValueBuffer: PByte;
BufferLen, expiration: Integer; block: Boolean;
StatusCmdReturn: TRedisStatusCmd);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(StatusCmdReturn);
  FRedisSdkManager.FSet(FRedisClient, PChar(Key), ValueBuffer, BufferLen,
    expiration, block, statusCmdResult, Mnd);
end;

procedure TDxRedisClient.SetCmd(Key: string; ValueBuffer: PByte;
BufferLen, expiration: Integer; block: Boolean;
StatusCmdReturn: TRedisStatusCmdA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStatusCmdA(@TMethod(ATemp).Code)^ := StatusCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FSet(FRedisClient, PChar(Key), ValueBuffer, BufferLen,
    expiration, block, statusCmdResult, Mnd);
end;

procedure TDxRedisClient.SetCmd(Key: string; ValueBuffer: PByte;
BufferLen, expiration: Integer; block: Boolean;
StatusCmdReturn: TRedisStatusCmdG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TRedisStatusCmdA(Mnd^.Code) := StatusCmdReturn;
  FRedisSdkManager.FSet(FRedisClient, PChar(Key), ValueBuffer, BufferLen,
    expiration, block, statusCmdResult, Mnd);
end;

procedure TDxRedisClient.LSet(Key: string; index: Int64; ValueBuffer: PByte;
BufferLen: Integer; block: Boolean; StatusCmdReturn: TRedisStatusCmd);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(StatusCmdReturn);
  FRedisSdkManager.FLSet(FRedisClient, PChar(Key), index, ValueBuffer,
    BufferLen, block, statusCmdResult, Mnd);
end;

procedure TDxRedisClient.LSet(Key: string; index: Int64; ValueBuffer: PByte;
BufferLen: Integer; block: Boolean; StatusCmdReturn: TRedisStatusCmdA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStatusCmdA(@TMethod(ATemp).Code)^ := StatusCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FLSet(FRedisClient, PChar(Key), index, ValueBuffer,
    BufferLen, block, statusCmdResult, Mnd);
end;

procedure TDxRedisClient.LIndex(Key: string; index: Int64; block: Boolean;
stringCmdReturn: TRedisStringCmdReturnG);
var
  Mnd: PStringCmdMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method.Data := nil;
  TRedisStringCmdReturnA(Mnd^.Method.Code) := stringCmdReturn;
  FRedisSdkManager.FLIndex(FRedisClient, PChar(Key), index, False, block,
    stringCmdResult, Mnd);
end;

procedure TDxRedisClient.LIndex(Key: string; index: Int64; block: Boolean;
stringCmdReturn: TRedisStringCmdReturnA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PStringCmdMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStringCmdReturnA(@TMethod(ATemp).Code)^ := stringCmdReturn;
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method := TMethod(ATemp);
  FRedisSdkManager.FLIndex(FRedisClient, PChar(Key), index, False, block,
    stringCmdResult, Mnd);
end;

procedure TDxRedisClient.LIndex(Key: string; index: Int64; block: Boolean;
stringCmdReturn: TRedisStringCmdReturn);
var
  Mnd: PStringCmdMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method := TMethod(stringCmdReturn);
  FRedisSdkManager.FLIndex(FRedisClient, PChar(Key), index, False, block,
    stringCmdResult, Mnd);
end;

procedure TDxRedisClient.LIndex(Key: string; index: Int64; block: Boolean;
stringCmdReturn: TRedisStringCmdReturnByteG);
var
  Mnd: PStringCmdMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Method.Data := nil;
  Mnd^.isByteReturn := True;
  TRedisStringCmdReturnByteA(Mnd^.Method.Code) := stringCmdReturn;
  FRedisSdkManager.FLIndex(FRedisClient, PChar(Key), index, True, block,
    stringCmdResult, Mnd);
end;

procedure TDxRedisClient.LInsert(Key: string; before: Boolean;
pivot, Value: string; block: Boolean; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  FRedisSdkManager.FLInsert(FRedisClient, PChar(Key), before, PChar(pivot),
    PChar(Value), block, intCmdResult, Mnd);
end;

procedure TDxRedisClient.LInsert(Key: string; before: Boolean;
pivot, Value: string; block: Boolean; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FLInsert(FRedisClient, PChar(Key), before, PChar(pivot),
    PChar(Value), block, intCmdResult, Mnd);
end;

procedure TDxRedisClient.LInsert(Key: string; before: Boolean;
pivot, Value: string; block: Boolean; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  FRedisSdkManager.FLInsert(FRedisClient, PChar(Key), before, PChar(pivot),
    PChar(Value), block, intCmdResult, Mnd);
end;

procedure TDxRedisClient.LInsertBefore(Key: string; pivot, Value: string;
block: Boolean; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  FRedisSdkManager.FLInsertBefore(FRedisClient, PChar(Key), PChar(pivot),
    PChar(Value), block, intCmdResult, Mnd);
end;

procedure TDxRedisClient.LInsertBefore(Key: string; pivot, Value: string;
block: Boolean; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FLInsertBefore(FRedisClient, PChar(Key), PChar(pivot),
    PChar(Value), block, intCmdResult, Mnd);
end;

procedure TDxRedisClient.LInsertBefore(Key: string; pivot, Value: string;
block: Boolean; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  FRedisSdkManager.FLInsertBefore(FRedisClient, PChar(Key), PChar(pivot),
    PChar(Value), block, intCmdResult, Mnd);
end;

procedure TDxRedisClient.LInsertAfter(Key: string; pivot, Value: string;
block: Boolean; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  FRedisSdkManager.FLInsertAfter(FRedisClient, PChar(Key), PChar(pivot),
    PChar(Value), block, intCmdResult, Mnd);
end;

procedure TDxRedisClient.LInsertAfter(Key: string; pivot, Value: string;
block: Boolean; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FLInsertAfter(FRedisClient, PChar(Key), PChar(pivot),
    PChar(Value), block, intCmdResult, Mnd);
end;

procedure TDxRedisClient.LInsertAfter(Key: string; pivot, Value: string;
block: Boolean; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  FRedisSdkManager.FLInsertAfter(FRedisClient, PChar(Key), PChar(pivot),
    PChar(Value), block, intCmdResult, Mnd);
end;

procedure TDxRedisClient.LLen(Key: string; block: Boolean;
intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  FRedisSdkManager.FLLen(FRedisClient, PChar(Key), block, intCmdResult, Mnd);
end;

procedure TDxRedisClient.LLen(Key: string; block: Boolean;
intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FLLen(FRedisClient, PChar(Key), block, intCmdResult, Mnd);
end;

procedure TDxRedisClient.LLen(Key: string; block: Boolean;
intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  FRedisSdkManager.FLLen(FRedisClient, PChar(Key), block, intCmdResult, Mnd);
end;

procedure TDxRedisClient.LPop(Key: string; block: Boolean;
stringCmdReturn: TRedisStringCmdReturnG);
var
  Mnd: PStringCmdMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method.Data := nil;
  TRedisStringCmdReturnA(Mnd^.Method.Code) := stringCmdReturn;
  FRedisSdkManager.FLPop(FRedisClient, PChar(Key), False, block,
    stringCmdResult, Mnd);
end;

procedure TDxRedisClient.LPop(Key: string; block: Boolean;
stringCmdReturn: TRedisStringCmdReturnA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PStringCmdMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStringCmdReturnA(@TMethod(ATemp).Code)^ := stringCmdReturn;
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method := TMethod(ATemp);
  FRedisSdkManager.FLPop(FRedisClient, PChar(Key), False, block,
    stringCmdResult, Mnd);
end;

procedure TDxRedisClient.LPop(Key: string; block: Boolean;
stringCmdReturn: TRedisStringCmdReturn);
var
  Mnd: PStringCmdMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method := TMethod(stringCmdReturn);
  FRedisSdkManager.FLPop(FRedisClient, PChar(Key), False, block,
    stringCmdResult, Mnd);
end;

procedure TDxRedisClient.LPop(Key: string; block: Boolean;
stringCmdReturn: TRedisStringCmdReturnByteG);
var
  Mnd: PStringCmdMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Method.Data := nil;
  Mnd^.isByteReturn := True;
  TRedisStringCmdReturnByteA(Mnd^.Method.Code) := stringCmdReturn;
  FRedisSdkManager.FLPop(FRedisClient, PChar(Key), True, block,
    stringCmdResult, Mnd);
end;

procedure TDxRedisClient.LPos(Key, Value: string; args: TLPosArgs;
block: Boolean; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  FRedisSdkManager.FLPos(FRedisClient, PChar(Key), PChar(Value), @args, block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.LPos(Key, Value: string; args: TLPosArgs;
block: Boolean; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FLPos(FRedisClient, PChar(Key), PChar(Value), @args, block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.LPos(Key, Value: string; args: TLPosArgs;
block: Boolean; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  FRedisSdkManager.FLPos(FRedisClient, PChar(Key), PChar(Value), @args, block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.LPush(Key: string; values: array of string;
block: Boolean; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
  i, l: Integer;
  redisKVs: array of TValueInterface;
begin
  l := Length(values);
  if l = 0 then
    Exit;
  AtomicIncrement(FRunningCount, 1);
  SetLength(redisKVs, l);
  for i := 0 to l - 1 do
  begin
    redisKVs[i].ValueLen := 0;
    redisKVs[i].Value := PChar(values[i]);
  end;

  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  FRedisSdkManager.FLPush(FRedisClient, PChar(Key), @redisKVs[0], l, block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.LPush(Key: string; values: array of string;
block: Boolean; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
  i, l: Integer;
  redisKVs: array of TValueInterface;
begin
  l := Length(values);
  if l = 0 then
    Exit;
  AtomicIncrement(FRunningCount, 1);
  SetLength(redisKVs, l);
  for i := 0 to l - 1 do
  begin
    redisKVs[i].ValueLen := 0;
    redisKVs[i].Value := PChar(values[i]);
  end;
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FLPush(FRedisClient, PChar(Key), @redisKVs[0], l, block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.LPush(Key: string; values: array of string;
block: Boolean; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
  i, l: Integer;
  redisKVs: array of TValueInterface;
begin
  l := Length(values);
  if l = 0 then
    Exit;
  AtomicIncrement(FRunningCount, 1);
  SetLength(redisKVs, l);
  for i := 0 to l - 1 do
  begin
    redisKVs[i].ValueLen := 0;
    redisKVs[i].Value := PChar(values[i]);
  end;
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  FRedisSdkManager.FLPush(FRedisClient, PChar(Key), @redisKVs[0], l, block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.LPushx(Key: string; values: array of string;
block: Boolean; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
  i, l: Integer;
  redisKVs: array of TValueInterface;
begin
  l := Length(values);
  if l = 0 then
    Exit;
  AtomicIncrement(FRunningCount, 1);
  SetLength(redisKVs, l);
  for i := 0 to l - 1 do
  begin
    redisKVs[i].ValueLen := 0;
    redisKVs[i].Value := PChar(values[i]);
  end;

  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  FRedisSdkManager.FLPushX(FRedisClient, PChar(Key), @redisKVs[0], l, block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.LPushx(Key: string; values: array of string;
block: Boolean; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
  i, l: Integer;
  redisKVs: array of TValueInterface;
begin
  l := Length(values);
  if l = 0 then
    Exit;
  AtomicIncrement(FRunningCount, 1);
  SetLength(redisKVs, l);
  for i := 0 to l - 1 do
  begin
    redisKVs[i].ValueLen := 0;
    redisKVs[i].Value := PChar(values[i]);
  end;
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FLPushX(FRedisClient, PChar(Key), @redisKVs[0], l, block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.LPushx(Key: string; values: array of string;
block: Boolean; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
  i, l: Integer;
  redisKVs: array of TValueInterface;
begin
  l := Length(values);
  if l = 0 then
    Exit;
  AtomicIncrement(FRunningCount, 1);
  SetLength(redisKVs, l);
  for i := 0 to l - 1 do
  begin
    redisKVs[i].ValueLen := 0;
    redisKVs[i].Value := PChar(values[i]);
  end;
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  FRedisSdkManager.FLPushX(FRedisClient, PChar(Key), @redisKVs[0], l, block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.LPop(Key: string; block: Boolean;
stringCmdReturn: TRedisStringCmdReturnByteA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PStringCmdMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStringCmdReturnByteA(@TMethod(ATemp).Code)^ := stringCmdReturn;
  New(Mnd);
  Mnd^.isByteReturn := True;
  Mnd^.Method := TMethod(ATemp);
  FRedisSdkManager.FLPop(FRedisClient, PChar(Key), True, block,
    stringCmdResult, Mnd);
end;

procedure TDxRedisClient.LPop(Key: string; block: Boolean;
stringCmdReturn: TRedisStringCmdReturnByte);
var
  Mnd: PStringCmdMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Method := TMethod(stringCmdReturn);
  Mnd^.isByteReturn := True;
  FRedisSdkManager.FLPop(FRedisClient, PChar(Key), True, block,
    stringCmdResult, Mnd);
end;

procedure TDxRedisClient.RPop(Key: string; block: Boolean;
stringCmdReturn: TRedisStringCmdReturnG);
var
  Mnd: PStringCmdMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method.Data := nil;
  TRedisStringCmdReturnA(Mnd^.Method.Code) := stringCmdReturn;
  FRedisSdkManager.FRPop(FRedisClient, PChar(Key), False, block,
    stringCmdResult, Mnd);
end;

procedure TDxRedisClient.RPop(Key: string; block: Boolean;
stringCmdReturn: TRedisStringCmdReturnA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PStringCmdMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStringCmdReturnA(@TMethod(ATemp).Code)^ := stringCmdReturn;
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method := TMethod(ATemp);
  FRedisSdkManager.FRPop(FRedisClient, PChar(Key), False, block,
    stringCmdResult, Mnd);
end;

procedure TDxRedisClient.RPop(Key: string; block: Boolean;
stringCmdReturn: TRedisStringCmdReturn);
var
  Mnd: PStringCmdMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method := TMethod(stringCmdReturn);
  FRedisSdkManager.FRPop(FRedisClient, PChar(Key), False, block,
    stringCmdResult, Mnd);
end;

procedure TDxRedisClient.RPop(Key: string; block: Boolean;
stringCmdReturn: TRedisStringCmdReturnByteG);
var
  Mnd: PStringCmdMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Method.Data := nil;
  Mnd^.isByteReturn := True;
  TRedisStringCmdReturnByteA(Mnd^.Method.Code) := stringCmdReturn;
  FRedisSdkManager.FRPop(FRedisClient, PChar(Key), True, block,
    stringCmdResult, Mnd);
end;

procedure TDxRedisClient.RPop(Key: string; block: Boolean;
stringCmdReturn: TRedisStringCmdReturnByteA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PStringCmdMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStringCmdReturnByteA(@TMethod(ATemp).Code)^ := stringCmdReturn;
  New(Mnd);
  Mnd^.isByteReturn := True;
  Mnd^.Method := TMethod(ATemp);
  FRedisSdkManager.FRPop(FRedisClient, PChar(Key), True, block,
    stringCmdResult, Mnd);
end;

procedure TDxRedisClient.RPop(Key: string; block: Boolean;
stringCmdReturn: TRedisStringCmdReturnByte);
var
  Mnd: PStringCmdMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Method := TMethod(stringCmdReturn);
  Mnd^.isByteReturn := True;
  FRedisSdkManager.FRPop(FRedisClient, PChar(Key), True, block,
    stringCmdResult, Mnd);
end;

procedure TDxRedisClient.SPop(Key: string; block: Boolean;
stringCmdReturn: TRedisStringCmdReturnG);
var
  Mnd: PStringCmdMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method.Data := nil;
  TRedisStringCmdReturnA(Mnd^.Method.Code) := stringCmdReturn;
  FRedisSdkManager.FSPop(FRedisClient, PChar(Key), False, block,
    stringCmdResult, Mnd);
end;

procedure TDxRedisClient.SPop(Key: string; block: Boolean;
stringCmdReturn: TRedisStringCmdReturnA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PStringCmdMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStringCmdReturnA(@TMethod(ATemp).Code)^ := stringCmdReturn;
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method := TMethod(ATemp);
  FRedisSdkManager.FSPop(FRedisClient, PChar(Key), False, block,
    stringCmdResult, Mnd);
end;

procedure TDxRedisClient.SPop(Key: string; block: Boolean;
stringCmdReturn: TRedisStringCmdReturn);
var
  Mnd: PStringCmdMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method := TMethod(stringCmdReturn);
  FRedisSdkManager.FSPop(FRedisClient, PChar(Key), False, block,
    stringCmdResult, Mnd);
end;

procedure TDxRedisClient.SPop(Key: string; block: Boolean;
stringCmdReturn: TRedisStringCmdReturnByteG);
var
  Mnd: PStringCmdMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Method.Data := nil;
  Mnd^.isByteReturn := True;
  TRedisStringCmdReturnByteA(Mnd^.Method.Code) := stringCmdReturn;
  FRedisSdkManager.FSPop(FRedisClient, PChar(Key), True, block,
    stringCmdResult, Mnd);
end;

procedure TDxRedisClient.SPop(Key: string; block: Boolean;
stringCmdReturn: TRedisStringCmdReturnByteA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PStringCmdMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStringCmdReturnByteA(@TMethod(ATemp).Code)^ := stringCmdReturn;
  New(Mnd);
  Mnd^.isByteReturn := True;
  Mnd^.Method := TMethod(ATemp);
  FRedisSdkManager.FSPop(FRedisClient, PChar(Key), True, block,
    stringCmdResult, Mnd);
end;

procedure TDxRedisClient.SPop(Key: string; block: Boolean;
stringCmdReturn: TRedisStringCmdReturnByte);
var
  Mnd: PStringCmdMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Method := TMethod(stringCmdReturn);
  Mnd^.isByteReturn := True;
  FRedisSdkManager.FSPop(FRedisClient, PChar(Key), True, block,
    stringCmdResult, Mnd);
end;

procedure TDxRedisClient.SRandMember(Key: string; block: Boolean;
stringCmdReturn: TRedisStringCmdReturnG);
var
  Mnd: PStringCmdMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method.Data := nil;
  TRedisStringCmdReturnA(Mnd^.Method.Code) := stringCmdReturn;
  FRedisSdkManager.FSRandMember(FRedisClient, PChar(Key), False, block,
    stringCmdResult, Mnd);
end;

procedure TDxRedisClient.SRandMember(Key: string; block: Boolean;
stringCmdReturn: TRedisStringCmdReturnA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PStringCmdMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStringCmdReturnA(@TMethod(ATemp).Code)^ := stringCmdReturn;
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method := TMethod(ATemp);
  FRedisSdkManager.FSRandMember(FRedisClient, PChar(Key), False, block,
    stringCmdResult, Mnd);
end;

procedure TDxRedisClient.SRandMember(Key: string; block: Boolean;
stringCmdReturn: TRedisStringCmdReturn);
var
  Mnd: PStringCmdMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method := TMethod(stringCmdReturn);
  FRedisSdkManager.FSRandMember(FRedisClient, PChar(Key), False, block,
    stringCmdResult, Mnd);
end;

procedure TDxRedisClient.SRandMember(Key: string; block: Boolean;
stringCmdReturn: TRedisStringCmdReturnByteG);
var
  Mnd: PStringCmdMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Method.Data := nil;
  Mnd^.isByteReturn := True;
  TRedisStringCmdReturnByteA(Mnd^.Method.Code) := stringCmdReturn;
  FRedisSdkManager.FSRandMember(FRedisClient, PChar(Key), True, block,
    stringCmdResult, Mnd);
end;

procedure TDxRedisClient.SRandMember(Key: string; block: Boolean;
stringCmdReturn: TRedisStringCmdReturnByteA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PStringCmdMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStringCmdReturnByteA(@TMethod(ATemp).Code)^ := stringCmdReturn;
  New(Mnd);
  Mnd^.isByteReturn := True;
  Mnd^.Method := TMethod(ATemp);
  FRedisSdkManager.FSRandMember(FRedisClient, PChar(Key), True, block,
    stringCmdResult, Mnd);
end;

procedure TDxRedisClient.SRandMember(Key: string; block: Boolean;
stringCmdReturn: TRedisStringCmdReturnByte);
var
  Mnd: PStringCmdMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Method := TMethod(stringCmdReturn);
  Mnd^.isByteReturn := True;
  FRedisSdkManager.FSRandMember(FRedisClient, PChar(Key), True, block,
    stringCmdResult, Mnd);
end;

procedure TDxRedisClient.LIndex(Key: string; index: Int64; block: Boolean;
stringCmdReturn: TRedisStringCmdReturnByteA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PStringCmdMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStringCmdReturnByteA(@TMethod(ATemp).Code)^ := stringCmdReturn;
  New(Mnd);
  Mnd^.isByteReturn := True;
  Mnd^.Method := TMethod(ATemp);
  FRedisSdkManager.FLIndex(FRedisClient, PChar(Key), index, True, block,
    stringCmdResult, Mnd);
end;

procedure TDxRedisClient.LIndex(Key: string; index: Int64; block: Boolean;
stringCmdReturn: TRedisStringCmdReturnByte);
var
  Mnd: PStringCmdMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Method := TMethod(stringCmdReturn);
  Mnd^.isByteReturn := True;
  FRedisSdkManager.FLIndex(FRedisClient, PChar(Key), index, True, block,
    stringCmdResult, Mnd);
end;

procedure TDxRedisClient.LSet(Key: string; index: Int64; ValueBuffer: PByte;
BufferLen: Integer; block: Boolean; StatusCmdReturn: TRedisStatusCmdG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TRedisStatusCmdA(Mnd^.Code) := StatusCmdReturn;
  FRedisSdkManager.FLSet(FRedisClient, PChar(Key), index, ValueBuffer,
    BufferLen, block, statusCmdResult, Mnd);
end;

procedure TDxRedisClient.LTrim(Key: string; Start, stop: Int64; block: Boolean;
StatusCmdReturn: TRedisStatusCmd);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(StatusCmdReturn);
  FRedisSdkManager.FLTrim(FRedisClient, PChar(Key), Start, stop, block,
    statusCmdResult, Mnd);
end;

procedure TDxRedisClient.LTrim(Key: string; Start, stop: Int64; block: Boolean;
StatusCmdReturn: TRedisStatusCmdA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStatusCmdA(@TMethod(ATemp).Code)^ := StatusCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FLTrim(FRedisClient, PChar(Key), Start, stop, block,
    statusCmdResult, Mnd);
end;

procedure TDxRedisClient.LTrim(Key: string; Start, stop: Int64; block: Boolean;
StatusCmdReturn: TRedisStatusCmdG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TRedisStatusCmdA(Mnd^.Code) := StatusCmdReturn;
  FRedisSdkManager.FLTrim(FRedisClient, PChar(Key), Start, stop, block,
    statusCmdResult, Mnd);
end;

procedure TDxRedisClient.HGet(Key, field: string; block: Boolean;
stringCmdReturn: TRedisStringCmdReturnByte);
var
  Mnd: PStringCmdMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Method := TMethod(stringCmdReturn);
  Mnd^.isByteReturn := True;
  FRedisSdkManager.FHGet(FRedisClient, PChar(Key), PChar(field), True, block,
    stringCmdResult, Mnd);
end;

procedure TDxRedisClient.HGet(Key, field: string; block: Boolean;
stringCmdReturn: TRedisStringCmdReturnByteA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PStringCmdMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStringCmdReturnByteA(@TMethod(ATemp).Code)^ := stringCmdReturn;
  New(Mnd);
  Mnd^.isByteReturn := True;
  Mnd^.Method := TMethod(ATemp);
  FRedisSdkManager.FHGet(FRedisClient, PChar(Key), PChar(field), True, block,
    stringCmdResult, Mnd);
end;

procedure TDxRedisClient.HGet(Key, field: string; block: Boolean;
stringCmdReturn: TRedisStringCmdReturnByteG);
var
  Mnd: PStringCmdMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Method.Data := nil;
  Mnd^.isByteReturn := True;
  TRedisStringCmdReturnByteA(Mnd^.Method.Code) := stringCmdReturn;
  FRedisSdkManager.FHGet(FRedisClient, PChar(Key), PChar(field), True, block,
    stringCmdResult, Mnd);
end;

procedure TDxRedisClient.HIncrBy(Key, field: string; Incr: Int64;
block: Boolean; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  FRedisSdkManager.FHIncrBy(FRedisClient, PChar(Key), PChar(field), Incr, block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.HIncrBy(Key, field: string; Incr: Int64;
block: Boolean; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FHIncrBy(FRedisClient, PChar(Key), PChar(field), Incr, block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.HIncrBy(Key, field: string; Incr: Int64;
block: Boolean; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  FRedisSdkManager.FHIncrBy(FRedisClient, PChar(Key), PChar(field), Incr, block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.HLen(Key: string; block: Boolean;
intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  FRedisSdkManager.FHLen(FRedisClient, PChar(Key), block, intCmdResult, Mnd);
end;

procedure TDxRedisClient.HLen(Key: string; block: Boolean;
intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FHLen(FRedisClient, PChar(Key), block, intCmdResult, Mnd);
end;

procedure TDxRedisClient.HLen(Key: string; block: Boolean;
intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  FRedisSdkManager.FHLen(FRedisClient, PChar(Key), block, intCmdResult, Mnd);
end;

procedure TDxRedisClient.BRPopLPush(src, dst: string; timeout: Integer;
block: Boolean; stringCmdReturn: TRedisStringCmdReturnByte);
var
  Mnd: PStringCmdMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Method := TMethod(stringCmdReturn);
  Mnd^.isByteReturn := True;
  FRedisSdkManager.FBRPopLPush(FRedisClient, PChar(src), PChar(dst), timeout,
    True, block, stringCmdResult, Mnd);
end;

procedure TDxRedisClient.BRPopLPush(src, dst: string; timeout: Integer;
block: Boolean; stringCmdReturn: TRedisStringCmdReturnByteA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PStringCmdMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStringCmdReturnByteA(@TMethod(ATemp).Code)^ := stringCmdReturn;
  New(Mnd);
  Mnd^.isByteReturn := True;
  Mnd^.Method := TMethod(ATemp);
  FRedisSdkManager.FBRPopLPush(FRedisClient, PChar(src), PChar(dst), timeout,
    True, block, stringCmdResult, Mnd);
end;

procedure TDxRedisClient.Append(Key, Value: string; block: Boolean;
intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  FRedisSdkManager.FAppend(FRedisClient, PChar(Key), PChar(Value), block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.Append(Key, Value: string; block: Boolean;
intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FAppend(FRedisClient, PChar(Key), PChar(Value), block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.Append(Key, Value: string; block: Boolean;
intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  FRedisSdkManager.FAppend(FRedisClient, PChar(Key), PChar(Value), block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.BitCount(Key: string; BitCount: TBitCount;
block: Boolean; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  FRedisSdkManager.FBitCount(FRedisClient, PChar(Key), @BitCount, block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.BitCount(Key: string; BitCount: TBitCount;
block: Boolean; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FBitCount(FRedisClient, PChar(Key), @BitCount, block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.BitCount(Key: string; BitCount: TBitCount;
block: Boolean; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  FRedisSdkManager.FBitCount(FRedisClient, PChar(Key), @BitCount, block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.BitOpAnd(destKey: string; keys: array of string;
block: Boolean; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
  keyList: string;
  i: Integer;
begin
  if Length(keys) > 0 then
  begin
    keyList := '';
    New(Mnd);
    Mnd^ := TMethod(intCmdReturn);
    for i := Low(keys) to High(keys) do
    begin
      if keyList = '' then
        keyList := keys[i]
      else
        keyList := keyList + #13#10 + keys[i];
    end;
    AtomicIncrement(FRunningCount, 1);
    FRedisSdkManager.FBitOpAnd(FRedisClient, PChar(destKey), PChar(keyList),
      block, intCmdResult, Mnd);
  end;
end;

procedure TDxRedisClient.BitOpAnd(destKey: string; keys: array of string;
block: Boolean; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  keyList: string;
  i: Integer;
  ATemp: TIntCmdReturn;
begin
  if Length(keys) > 0 then
  begin
    keyList := '';
    AtomicIncrement(FRunningCount, 1);
    for i := Low(keys) to High(keys) do
    begin
      if keyList = '' then
        keyList := keys[i]
      else
        keyList := keyList + #13#10 + keys[i];
    end;
    TMethod(ATemp).Data := Pointer(-1);
    TMethod(ATemp).Code := nil;
    PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
    New(Mnd);
    Mnd^ := TMethod(ATemp);
    FRedisSdkManager.FBitOpAnd(FRedisClient, PChar(destKey), PChar(keyList),
      block, intCmdResult, Mnd);
  end;
end;

procedure TDxRedisClient.BitOpAnd(destKey: string; keys: array of string;
block: Boolean; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
  keyList: string;
  i: Integer;
begin
  if Length(keys) > 0 then
  begin
    keyList := '';
    AtomicIncrement(FRunningCount, 1);
    for i := Low(keys) to High(keys) do
    begin
      if keyList = '' then
        keyList := keys[i]
      else
        keyList := keyList + #13#10 + keys[i];
    end;
    New(Mnd);
    Mnd^.Data := nil;
    TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
    FRedisSdkManager.FBitOpAnd(FRedisClient, PChar(destKey), PChar(keyList),
      block, intCmdResult, Mnd);
  end;
end;

procedure TDxRedisClient.BitOpNot(destKey, Key: string; block: Boolean;
intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  FRedisSdkManager.FBitOpNot(FRedisClient, PChar(destKey), PChar(Key), block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.BitOpNot(destKey, Key: string; block: Boolean;
intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FBitOpNot(FRedisClient, PChar(destKey), PChar(Key), block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.BitOpNot(destKey, Key: string; block: Boolean;
intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  FRedisSdkManager.FBitOpNot(FRedisClient, PChar(destKey), PChar(Key), block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.BitOpOr(destKey: string; keys: array of string;
block: Boolean; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
  keyList: string;
  i: Integer;
begin
  if Length(keys) > 0 then
  begin
    keyList := '';
    AtomicIncrement(FRunningCount, 1);
    for i := Low(keys) to High(keys) do
    begin
      if keyList = '' then
        keyList := keys[i]
      else
        keyList := keyList + #13#10 + keys[i];
    end;
    New(Mnd);
    Mnd^ := TMethod(intCmdReturn);
    FRedisSdkManager.FBitOpOr(FRedisClient, PChar(destKey), PChar(keyList),
      block, intCmdResult, Mnd);
  end;
end;

procedure TDxRedisClient.BitOpOr(destKey: string; keys: array of string;
block: Boolean; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  keyList: string;
  i: Integer;
  ATemp: TIntCmdReturn;
begin
  if Length(keys) > 0 then
  begin
    keyList := '';
    AtomicIncrement(FRunningCount, 1);
    for i := Low(keys) to High(keys) do
    begin
      if keyList = '' then
        keyList := keys[i]
      else
        keyList := keyList + #13#10 + keys[i];
    end;
    TMethod(ATemp).Data := Pointer(-1);
    TMethod(ATemp).Code := nil;
    PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
    New(Mnd);
    Mnd^ := TMethod(ATemp);
    FRedisSdkManager.FBitOpOr(FRedisClient, PChar(destKey), PChar(keyList),
      block, intCmdResult, Mnd);
  end;
end;

procedure TDxRedisClient.BitOpOr(destKey: string; keys: array of string;
block: Boolean; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
  keyList: string;
  i: Integer;
begin
  if Length(keys) > 0 then
  begin
    keyList := '';
    AtomicIncrement(FRunningCount, 1);
    New(Mnd);
    Mnd^.Data := nil;
    TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
    for i := Low(keys) to High(keys) do
    begin
      if keyList = '' then
        keyList := keys[i]
      else
        keyList := keyList + #13#10 + keys[i];
    end;
    FRedisSdkManager.FBitOpOr(FRedisClient, PChar(destKey), PChar(keyList),
      block, intCmdResult, Mnd);
  end;
end;

procedure TDxRedisClient.BitOpXor(destKey: string; keys: array of string;
block: Boolean; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
  keyList: string;
  i: Integer;
begin
  if Length(keys) > 0 then
  begin
    keyList := '';
    for i := Low(keys) to High(keys) do
    begin
      if keyList = '' then
        keyList := keys[i]
      else
        keyList := keyList + #13#10 + keys[i];
    end;
    AtomicIncrement(FRunningCount, 1);
    New(Mnd);
    Mnd^ := TMethod(intCmdReturn);
    FRedisSdkManager.FBitOpXor(FRedisClient, PChar(destKey), PChar(keyList),
      block, intCmdResult, Mnd);
  end;
end;

procedure TDxRedisClient.BitOpXor(destKey: string; keys: array of string;
block: Boolean; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  keyList: string;
  i: Integer;
  ATemp: TIntCmdReturn;
begin
  if Length(keys) > 0 then
  begin
    keyList := '';
    AtomicIncrement(FRunningCount, 1);
    for i := Low(keys) to High(keys) do
    begin
      if keyList = '' then
        keyList := keys[i]
      else
        keyList := keyList + #13#10 + keys[i];
    end;
    TMethod(ATemp).Data := Pointer(-1);
    TMethod(ATemp).Code := nil;
    PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
    New(Mnd);
    Mnd^ := TMethod(ATemp);
    FRedisSdkManager.FBitOpXor(FRedisClient, PChar(destKey), PChar(keyList),
      block, intCmdResult, Mnd);
  end;
end;

procedure TDxRedisClient.BitOpXor(destKey: string; keys: array of string;
block: Boolean; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
  keyList: string;
  i: Integer;
begin
  if Length(keys) > 0 then
  begin
    keyList := '';
    AtomicIncrement(FRunningCount, 1);
    for i := Low(keys) to High(keys) do
    begin
      if keyList = '' then
        keyList := keys[i]
      else
        keyList := keyList + #13#10 + keys[i];
    end;
    New(Mnd);
    Mnd^.Data := nil;
    TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
    FRedisSdkManager.FBitOpXor(FRedisClient, PChar(destKey), PChar(keyList),
      block, intCmdResult, Mnd);
  end;
end;

procedure TDxRedisClient.HDel(Key: string; fields: array of string;
block: Boolean; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
  fldList: string;
  i: Integer;
begin
  if Length(fields) > 0 then
  begin
    fldList := '';
    New(Mnd);
    Mnd^ := TMethod(intCmdReturn);
    for i := Low(fields) to High(fields) do
    begin
      if fldList = '' then
        fldList := fields[i]
      else
        fldList := fldList + #13#10 + fields[i];
    end;
    AtomicIncrement(FRunningCount, 1);
    FRedisSdkManager.FHDel(FRedisClient, PChar(Key), PChar(fldList), block,
      intCmdResult, Mnd);
  end;
end;

procedure TDxRedisClient.HDel(Key: string; fields: array of string;
block: Boolean; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  fldList: string;
  i: Integer;
  ATemp: TIntCmdReturn;
begin
  if Length(fields) > 0 then
  begin
    fldList := '';
    AtomicIncrement(FRunningCount, 1);
    for i := Low(fields) to High(fields) do
    begin
      if fldList = '' then
        fldList := fields[i]
      else
        fldList := fldList + #13#10 + fields[i];
    end;
    TMethod(ATemp).Data := Pointer(-1);
    TMethod(ATemp).Code := nil;
    PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
    New(Mnd);
    Mnd^ := TMethod(ATemp);
    FRedisSdkManager.FHDel(FRedisClient, PChar(Key), PChar(fldList), block,
      intCmdResult, Mnd);
  end;
end;

procedure TDxRedisClient.HDel(Key: string; fields: array of string;
block: Boolean; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
  fldList: string;
  i: Integer;
begin
  if Length(fields) > 0 then
  begin
    New(Mnd);
    Mnd^.Data := nil;
    TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
    fldList := '';
    AtomicIncrement(FRunningCount, 1);
    for i := Low(fields) to High(fields) do
    begin
      if fldList = '' then
        fldList := fields[i]
      else
        fldList := fldList + #13#10 + fields[i];
    end;
    FRedisSdkManager.FHDel(FRedisClient, PChar(Key), PChar(fldList), block,
      intCmdResult, Mnd);
  end;
end;

procedure TDxRedisClient.BitPos(Key: string; bit: Int64;
bitPoss: array of Int64; block: Boolean; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
  l: Integer;
begin
  l := Length(bitPoss);
  if l = 0 then
    Exit;
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  FRedisSdkManager.FBitPos(FRedisClient, PChar(Key), bit, @bitPoss[0], l, block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.BitPos(Key: string; bit: Int64;
bitPoss: array of Int64; block: Boolean; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
  l: Integer;
begin
  l := Length(bitPoss);
  if l = 0 then
    Exit;
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FBitPos(FRedisClient, PChar(Key), bit, @bitPoss[0], l, block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.BitPos(Key: string; bit: Int64;
bitPoss: array of Int64; block: Boolean; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
  l: Integer;
begin
  l := Length(bitPoss);
  if l = 0 then
    Exit;
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  FRedisSdkManager.FBitPos(FRedisClient, PChar(Key), bit, @bitPoss[0], l, block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.BRPopLPush(src, dst: string; timeout: Integer;
block: Boolean; stringCmdReturn: TRedisStringCmdReturnByteG);
var
  Mnd: PStringCmdMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Method.Data := nil;
  Mnd^.isByteReturn := True;
  TRedisStringCmdReturnByteA(Mnd^.Method.Code) := stringCmdReturn;
  FRedisSdkManager.FBRPopLPush(FRedisClient, PChar(src), PChar(dst), timeout,
    True, block, stringCmdResult, Mnd);
end;

procedure TDxRedisClient.LPush(Key: string; values: array of TValueInterface;
block: Boolean; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
  l: Integer;
begin
  l := Length(values);
  if l = 0 then
    Exit;
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  FRedisSdkManager.FLPush(FRedisClient, PChar(Key), @values[0], l, block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.LPush(Key: string; values: array of TValueInterface;
block: Boolean; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
  l: Integer;
begin
  l := Length(values);
  if l = 0 then
    Exit;
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FLPush(FRedisClient, PChar(Key), @values[0], l, block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.LPush(Key: string; values: array of TValueInterface;
block: Boolean; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
  l: Integer;
begin
  l := Length(values);
  if l = 0 then
    Exit;
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  FRedisSdkManager.FLPush(FRedisClient, PChar(Key), @values[0], l, block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.LPushx(Key: string; values: array of TValueInterface;
block: Boolean; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
  l: Integer;
begin
  l := Length(values);
  if l = 0 then
    Exit;
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  FRedisSdkManager.FLPushX(FRedisClient, PChar(Key), @values[0], l, block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.LPushx(Key: string; values: array of TValueInterface;
block: Boolean; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
  l: Integer;
begin
  l := Length(values);
  if l = 0 then
    Exit;
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FLPushX(FRedisClient, PChar(Key), @values[0], l, block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.LPushx(Key: string; values: array of TValueInterface;
block: Boolean; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
  l: Integer;
begin
  l := Length(values);
  if l = 0 then
    Exit;
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  FRedisSdkManager.FLPushX(FRedisClient, PChar(Key), @values[0], l, block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.LRem(Key: string; count: Int64; Value: TValueInterface;
block: Boolean; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  FRedisSdkManager.FLRem(FRedisClient, PChar(Key), count, @Value, block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.LRem(Key: string; count: Int64; Value: TValueInterface;
block: Boolean; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FLRem(FRedisClient, PChar(Key), count, @Value, block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.LRem(Key: string; count: Int64; Value: TValueInterface;
block: Boolean; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  FRedisSdkManager.FLRem(FRedisClient, PChar(Key), count, @Value, block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.RPush(Key: string; values: array of string;
block: Boolean; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
  i, l: Integer;
  redisKVs: array of TValueInterface;
begin
  l := Length(values);
  if l = 0 then
    Exit;
  AtomicIncrement(FRunningCount, 1);
  SetLength(redisKVs, l);
  for i := 0 to l - 1 do
  begin
    redisKVs[i].ValueLen := 0;
    redisKVs[i].Value := PChar(values[i]);
  end;

  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  FRedisSdkManager.FRPush(FRedisClient, PChar(Key), @redisKVs[0], l, block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.RPush(Key: string; values: array of string;
block: Boolean; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
  i, l: Integer;
  redisKVs: array of TValueInterface;
begin
  l := Length(values);
  if l = 0 then
    Exit;
  AtomicIncrement(FRunningCount, 1);
  SetLength(redisKVs, l);
  for i := 0 to l - 1 do
  begin
    redisKVs[i].ValueLen := 0;
    redisKVs[i].Value := PChar(values[i]);
  end;
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FRPush(FRedisClient, PChar(Key), @redisKVs[0], l, block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.RPush(Key: string; values: array of string;
block: Boolean; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
  i, l: Integer;
  redisKVs: array of TValueInterface;
begin
  l := Length(values);
  if l = 0 then
    Exit;
  AtomicIncrement(FRunningCount, 1);
  SetLength(redisKVs, l);
  for i := 0 to l - 1 do
  begin
    redisKVs[i].ValueLen := 0;
    redisKVs[i].Value := PChar(values[i]);
  end;
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  FRedisSdkManager.FRPush(FRedisClient, PChar(Key), @redisKVs[0], l, block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.RPush(Key: string; values: array of TValueInterface;
block: Boolean; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
  l: Integer;
begin
  l := Length(values);
  if l = 0 then
    Exit;
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  FRedisSdkManager.FRPush(FRedisClient, PChar(Key), @values[0], l, block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.RPush(Key: string; values: array of TValueInterface;
block: Boolean; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
  l: Integer;
begin
  l := Length(values);
  if l = 0 then
    Exit;
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FRPush(FRedisClient, PChar(Key), @values[0], l, block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.RPush(Key: string; values: array of TValueInterface;
block: Boolean; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
  l: Integer;
begin
  l := Length(values);
  if l = 0 then
    Exit;
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  FRedisSdkManager.FRPush(FRedisClient, PChar(Key), @values[0], l, block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.RPushx(Key: string; values: array of string;
block: Boolean; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
  i, l: Integer;
  redisKVs: array of TValueInterface;
begin
  l := Length(values);
  if l = 0 then
    Exit;
  AtomicIncrement(FRunningCount, 1);
  SetLength(redisKVs, l);
  for i := 0 to l - 1 do
  begin
    redisKVs[i].ValueLen := 0;
    redisKVs[i].Value := PChar(values[i]);
  end;

  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  FRedisSdkManager.FRPushX(FRedisClient, PChar(Key), @redisKVs[0], l, block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.RPushx(Key: string; values: array of string;
block: Boolean; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
  i, l: Integer;
  redisKVs: array of TValueInterface;
begin
  l := Length(values);
  if l = 0 then
    Exit;
  AtomicIncrement(FRunningCount, 1);
  SetLength(redisKVs, l);
  for i := 0 to l - 1 do
  begin
    redisKVs[i].ValueLen := 0;
    redisKVs[i].Value := PChar(values[i]);
  end;
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FRPushX(FRedisClient, PChar(Key), @redisKVs[0], l, block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.RPushx(Key: string; values: array of string;
block: Boolean; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
  i, l: Integer;
  redisKVs: array of TValueInterface;
begin
  l := Length(values);
  if l = 0 then
    Exit;
  AtomicIncrement(FRunningCount, 1);
  SetLength(redisKVs, l);
  for i := 0 to l - 1 do
  begin
    redisKVs[i].ValueLen := 0;
    redisKVs[i].Value := PChar(values[i]);
  end;
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  FRedisSdkManager.FRPushX(FRedisClient, PChar(Key), @redisKVs[0], l, block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.RPushx(Key: string; values: array of TValueInterface;
block: Boolean; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
  l: Integer;
begin
  l := Length(values);
  if l = 0 then
    Exit;
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  FRedisSdkManager.FRPushX(FRedisClient, PChar(Key), @values[0], l, block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.RPushx(Key: string; values: array of TValueInterface;
block: Boolean; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
  l: Integer;
begin
  l := Length(values);
  if l = 0 then
    Exit;
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FRPushX(FRedisClient, PChar(Key), @values[0], l, block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.RPushx(Key: string; values: array of TValueInterface;
block: Boolean; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
  l: Integer;
begin
  l := Length(values);
  if l = 0 then
    Exit;
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  FRedisSdkManager.FRPushX(FRedisClient, PChar(Key), @values[0], l, block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.SAdd(Key: string; values: array of string;
block: Boolean; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
  i, l: Integer;
  redisKVs: array of TValueInterface;
begin
  l := Length(values);
  if l = 0 then
    Exit;
  AtomicIncrement(FRunningCount, 1);
  SetLength(redisKVs, l);
  for i := 0 to l - 1 do
  begin
    redisKVs[i].ValueLen := 0;
    redisKVs[i].Value := PChar(values[i]);
  end;

  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  FRedisSdkManager.FSAdd(FRedisClient, PChar(Key), @redisKVs[0], l, block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.SAdd(Key: string; values: array of string;
block: Boolean; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
  i, l: Integer;
  redisKVs: array of TValueInterface;
begin
  l := Length(values);
  if l = 0 then
    Exit;
  AtomicIncrement(FRunningCount, 1);
  SetLength(redisKVs, l);
  for i := 0 to l - 1 do
  begin
    redisKVs[i].ValueLen := 0;
    redisKVs[i].Value := PChar(values[i]);
  end;
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FSAdd(FRedisClient, PChar(Key), @redisKVs[0], l, block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.SAdd(Key: string; values: array of string;
block: Boolean; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
  i, l: Integer;
  redisKVs: array of TValueInterface;
begin
  l := Length(values);
  if l = 0 then
    Exit;
  AtomicIncrement(FRunningCount, 1);
  SetLength(redisKVs, l);
  for i := 0 to l - 1 do
  begin
    redisKVs[i].ValueLen := 0;
    redisKVs[i].Value := PChar(values[i]);
  end;
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  FRedisSdkManager.FSAdd(FRedisClient, PChar(Key), @redisKVs[0], l, block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.SAdd(Key: string; values: array of TValueInterface;
block: Boolean; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
  l: Integer;
begin
  l := Length(values);
  if l = 0 then
    Exit;
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  FRedisSdkManager.FSAdd(FRedisClient, PChar(Key), @values[0], l, block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.SAdd(Key: string; values: array of TValueInterface;
block: Boolean; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
  l: Integer;
begin
  l := Length(values);
  if l = 0 then
    Exit;
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FSAdd(FRedisClient, PChar(Key), @values[0], l, block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.SAdd(Key: string; values: array of TValueInterface;
block: Boolean; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
  l: Integer;
begin
  l := Length(values);
  if l = 0 then
    Exit;
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  FRedisSdkManager.FSAdd(FRedisClient, PChar(Key), @values[0], l, block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.SCard(Key: string; block: Boolean;
intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  FRedisSdkManager.FSCard(FRedisClient, PChar(Key), block, intCmdResult, Mnd);
end;

procedure TDxRedisClient.SCard(Key: string; block: Boolean;
intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FSCard(FRedisClient, PChar(Key), block, intCmdResult, Mnd);
end;

procedure TDxRedisClient.SCard(Key: string; block: Boolean;
intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  FRedisSdkManager.FSCard(FRedisClient, PChar(Key), block, intCmdResult, Mnd);
end;

procedure TDxRedisClient.ZCard(Key: string; block: Boolean;
intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  FRedisSdkManager.FZCard(FRedisClient, PChar(Key), block, intCmdResult, Mnd);
end;

procedure TDxRedisClient.ZCard(Key: string; block: Boolean;
intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FZCard(FRedisClient, PChar(Key), block, intCmdResult, Mnd);
end;

procedure TDxRedisClient.ZAdd(Key: string; zvalue: array of TZStrValue;
block: Boolean; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
  i: Integer;
  zv: array of TZValue;
begin
  i := Length(zvalue);
  if i = 0 then
    Exit;
  AtomicIncrement(FRunningCount, 1);
  SetLength(zv, i);
  for i := Low(zvalue) to High(zvalue) do
  begin
    zv[i].Score := zvalue[i].Score;
    zv[i].Member := PChar(zvalue[i].Member);
    zv[i].MemLen := 0;
  end;

  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  FRedisSdkManager.FZAdd(FRedisClient, PChar(Key), @zv[0], Length(zvalue),
    block, intCmdResult, Mnd);
end;

procedure TDxRedisClient.ZAdd(Key: string; zvalue: array of TZStrValue;
block: Boolean; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  i, l: Integer;
  zv: array of TZValue;
  ATemp: TIntCmdReturn;
begin
  l := Length(zvalue);
  if l > 0 then
  begin
    AtomicIncrement(FRunningCount, 1);
    SetLength(zv, l);
    for i := Low(zvalue) to High(zvalue) do
    begin
      zv[i].Score := zvalue[i].Score;
      zv[i].Member := PChar(zvalue[i].Member);
      zv[i].MemLen := 0;
    end;

    TMethod(ATemp).Data := Pointer(-1);
    TMethod(ATemp).Code := nil;
    PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
    New(Mnd);
    Mnd^ := TMethod(ATemp);
    FRedisSdkManager.FZAdd(FRedisClient, PChar(Key), @zv[0], l, block,
      intCmdResult, Mnd);
  end;
end;

procedure TDxRedisClient.ZAdd(Key: string; zvalue: array of TZStrValue;
block: Boolean; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
  i, l: Integer;
  zv: array of TZValue;
begin
  l := Length(zvalue);
  if l > 0 then
  begin
    AtomicIncrement(FRunningCount, 1);
    SetLength(zv, l);
    for i := Low(zvalue) to High(zvalue) do
    begin
      zv[i].Score := zvalue[i].Score;
      zv[i].Member := PChar(zvalue[i].Member);
      zv[i].MemLen := 0;
    end;
    New(Mnd);
    Mnd^.Data := nil;
    TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
    FRedisSdkManager.FZAdd(FRedisClient, PChar(Key), @zv[0], l, block,
      intCmdResult, Mnd);
  end;
end;

procedure TDxRedisClient.ZCard(Key: string; block: Boolean;
intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  FRedisSdkManager.FZCard(FRedisClient, PChar(Key), block, intCmdResult, Mnd);
end;

procedure TDxRedisClient.ZCount(Key, min, max: string; block: Boolean;
intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  FRedisSdkManager.FZCount(FRedisClient, PChar(Key), PChar(min), PChar(max),
    block, intCmdResult, Mnd);
end;

procedure TDxRedisClient.ZCount(Key, min, max: string; block: Boolean;
intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FZCount(FRedisClient, PChar(Key), PChar(min), PChar(max),
    block, intCmdResult, Mnd);
end;

procedure TDxRedisClient.ZCount(Key, min, max: string; block: Boolean;
intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  FRedisSdkManager.FZCount(FRedisClient, PChar(Key), PChar(min), PChar(max),
    block, intCmdResult, Mnd);
end;

procedure TDxRedisClient.SDiffStore(destKey: string; keys: array of string;
block: Boolean; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
  keyList: string;
  i: Integer;
begin
  if Length(keys) > 0 then
  begin
    New(Mnd);
    Mnd^ := TMethod(intCmdReturn);
    keyList := '';
    AtomicIncrement(FRunningCount, 1);
    for i := Low(keys) to High(keys) do
    begin
      if keyList = '' then
        keyList := keys[i]
      else
        keyList := keyList + #13#10 + keys[i];
    end;
    FRedisSdkManager.FSDiffStore(FRedisClient, PChar(destKey), PChar(keyList),
      block, intCmdResult, Mnd);
  end;
end;

procedure TDxRedisClient.SDiffStore(destKey: string; keys: array of string;
block: Boolean; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  keyList: string;
  i: Integer;
  ATemp: TIntCmdReturn;
begin
  if Length(keys) > 0 then
  begin
    TMethod(ATemp).Data := Pointer(-1);
    TMethod(ATemp).Code := nil;
    PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
    New(Mnd);
    Mnd^ := TMethod(ATemp);
    keyList := '';
    AtomicIncrement(FRunningCount, 1);
    for i := Low(keys) to High(keys) do
    begin
      if keyList = '' then
        keyList := keys[i]
      else
        keyList := keyList + #13#10 + keys[i];
    end;
    FRedisSdkManager.FSDiffStore(FRedisClient, PChar(destKey), PChar(keyList),
      block, intCmdResult, Mnd);
  end;
end;

procedure TDxRedisClient.SDiffStore(destKey: string; keys: array of string;
block: Boolean; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
  keyList: string;
  i: Integer;
begin
  if Length(keys) > 0 then
  begin
    New(Mnd);
    Mnd^.Data := nil;
    TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
    keyList := '';
    AtomicIncrement(FRunningCount, 1);
    for i := Low(keys) to High(keys) do
    begin
      if keyList = '' then
        keyList := keys[i]
      else
        keyList := keyList + #13#10 + keys[i];
    end;
    FRedisSdkManager.FSDiffStore(FRedisClient, PChar(destKey), PChar(keyList),
      block, intCmdResult, Mnd);
  end;
end;

procedure TDxRedisClient.SInterStore(destKey: string; keys: array of string;
block: Boolean; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
  keyList: string;
  i: Integer;
begin
  if Length(keys) > 0 then
  begin
    New(Mnd);
    Mnd^ := TMethod(intCmdReturn);
    keyList := '';
    AtomicIncrement(FRunningCount, 1);
    for i := Low(keys) to High(keys) do
    begin
      if keyList = '' then
        keyList := keys[i]
      else
        keyList := keyList + #13#10 + keys[i];
    end;
    FRedisSdkManager.FSInterStore(FRedisClient, PChar(destKey), PChar(keyList),
      block, intCmdResult, Mnd);
  end;
end;

procedure TDxRedisClient.SInterStore(destKey: string; keys: array of string;
block: Boolean; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  keyList: string;
  i: Integer;
  ATemp: TIntCmdReturn;
begin
  if Length(keys) > 0 then
  begin
    AtomicIncrement(FRunningCount, 1);
    TMethod(ATemp).Data := Pointer(-1);
    TMethod(ATemp).Code := nil;
    PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
    New(Mnd);
    Mnd^ := TMethod(ATemp);
    keyList := '';
    for i := Low(keys) to High(keys) do
    begin
      if keyList = '' then
        keyList := keys[i]
      else
        keyList := keyList + #13#10 + keys[i];
    end;
    FRedisSdkManager.FSInterStore(FRedisClient, PChar(destKey), PChar(keyList),
      block, intCmdResult, Mnd);
  end;
end;

procedure TDxRedisClient.SInterStore(destKey: string; keys: array of string;
block: Boolean; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
  keyList: string;
  i: Integer;
begin
  if Length(keys) > 0 then
  begin
    New(Mnd);
    Mnd^.Data := nil;
    TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
    keyList := '';
    AtomicIncrement(FRunningCount, 1);
    for i := Low(keys) to High(keys) do
    begin
      if keyList = '' then
        keyList := keys[i]
      else
        keyList := keyList + #13#10 + keys[i];
    end;
    FRedisSdkManager.FSInterStore(FRedisClient, PChar(destKey), PChar(keyList),
      block, intCmdResult, Mnd);
  end;
end;

procedure TDxRedisClient.SRem(Key: string; membersArr: array of string;
block: Boolean; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
  i, l: Integer;
  redisKVs: array of TValueInterface;
begin
  l := Length(membersArr);
  if l = 0 then
    Exit;
  AtomicIncrement(FRunningCount, 1);
  SetLength(redisKVs, l);
  for i := 0 to l - 1 do
  begin
    redisKVs[i].ValueLen := 0;
    redisKVs[i].Value := PChar(membersArr[i]);
  end;

  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  FRedisSdkManager.FSRem(FRedisClient, PChar(Key), @redisKVs[0], l, block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.SRem(Key: string; membersArr: array of string;
block: Boolean; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
  i, l: Integer;
  redisKVs: array of TValueInterface;
begin
  l := Length(membersArr);
  if l = 0 then
    Exit;
  AtomicIncrement(FRunningCount, 1);
  SetLength(redisKVs, l);
  for i := 0 to l - 1 do
  begin
    redisKVs[i].ValueLen := 0;
    redisKVs[i].Value := PChar(membersArr[i]);
  end;
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FSRem(FRedisClient, PChar(Key), @redisKVs[0], l, block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.SRem(Key: string; membersArr: array of string;
block: Boolean; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
  i, l: Integer;
  redisKVs: array of TValueInterface;
begin
  l := Length(membersArr);
  if l = 0 then
    Exit;
  AtomicIncrement(FRunningCount, 1);
  SetLength(redisKVs, l);
  for i := 0 to l - 1 do
  begin
    redisKVs[i].ValueLen := 0;
    redisKVs[i].Value := PChar(membersArr[i]);
  end;
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  FRedisSdkManager.FSRem(FRedisClient, PChar(Key), @redisKVs[0], l, block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.SRem(Key: string; membersArr: array of TValueInterface;
block: Boolean; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
  l: Integer;
begin
  l := Length(membersArr);
  if l = 0 then
    Exit;
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  FRedisSdkManager.FSRem(FRedisClient, PChar(Key), @membersArr[0], l, block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.SRem(Key: string; membersArr: array of TValueInterface;
block: Boolean; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
  l: Integer;
begin
  l := Length(membersArr);
  if l = 0 then
    Exit;
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FSRem(FRedisClient, PChar(Key), @membersArr[0], l, block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.SRem(Key: string; membersArr: array of TValueInterface;
block: Boolean; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
  l: Integer;
begin
  l := Length(membersArr);
  if l = 0 then
    Exit;
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  FRedisSdkManager.FSRem(FRedisClient, PChar(Key), @membersArr[0], l, block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.SUnionStore(destKey: string; keys: array of string;
block: Boolean; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
  keyList: string;
  i: Integer;
begin
  keyList := '';
  if Length(keys) > 0 then
  begin
    New(Mnd);
    Mnd^ := TMethod(intCmdReturn);
    for i := Low(keys) to High(keys) do
    begin
      if keyList = '' then
        keyList := keys[i]
      else
        keyList := keyList + #13#10 + keys[i];
    end;
    AtomicIncrement(FRunningCount, 1);
    FRedisSdkManager.FSUnionStore(FRedisClient, PChar(destKey), PChar(keyList),
      block, intCmdResult, Mnd);
  end;
end;

procedure TDxRedisClient.SUnionStore(destKey: string; keys: array of string;
block: Boolean; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  keyList: string;
  i: Integer;
  ATemp: TIntCmdReturn;
begin
  if Length(keys) > 0 then
  begin
    TMethod(ATemp).Data := Pointer(-1);
    TMethod(ATemp).Code := nil;
    PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
    New(Mnd);
    Mnd^ := TMethod(ATemp);

    keyList := '';
    for i := Low(keys) to High(keys) do
    begin
      if keyList = '' then
        keyList := keys[i]
      else
        keyList := keyList + #13#10 + keys[i];
    end;
    AtomicIncrement(FRunningCount, 1);
    FRedisSdkManager.FSUnionStore(FRedisClient, PChar(destKey), PChar(keyList),
      block, intCmdResult, Mnd);
  end;
end;

procedure TDxRedisClient.SUnionStore(destKey: string; keys: array of string;
block: Boolean; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
  keyList: string;
  i: Integer;
begin
  if Length(keys) > 0 then
  begin
    AtomicIncrement(FRunningCount, 1);
    New(Mnd);
    Mnd^.Data := nil;
    TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
    keyList := '';
    for i := Low(keys) to High(keys) do
    begin
      if keyList = '' then
        keyList := keys[i]
      else
        keyList := keyList + #13#10 + keys[i];
    end;
    FRedisSdkManager.FSUnionStore(FRedisClient, PChar(destKey), PChar(keyList),
      block, intCmdResult, Mnd);
  end;
end;

procedure TDxRedisClient.ZAdd(Key: string; zvalue: array of TZValue;
block: Boolean; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
  i: Integer;
begin
  i := Length(zvalue);
  if i = 0 then
    Exit;
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  FRedisSdkManager.FZAdd(FRedisClient, PChar(Key), @zvalue[0], i, block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.ZAdd(Key: string; zvalue: array of TZValue;
block: Boolean; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  l: Integer;
  ATemp: TIntCmdReturn;
begin
  l := Length(zvalue);
  if l > 0 then
  begin
    AtomicIncrement(FRunningCount, 1);
    TMethod(ATemp).Data := Pointer(-1);
    TMethod(ATemp).Code := nil;
    PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
    New(Mnd);
    Mnd^ := TMethod(ATemp);
    FRedisSdkManager.FZAdd(FRedisClient, PChar(Key), @zvalue[0], l, block,
      intCmdResult, Mnd);
  end;
end;

procedure TDxRedisClient.ZAdd(Key: string; zvalue: array of TZValue;
block: Boolean; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
  l: Integer;
begin
  l := Length(zvalue);
  if l > 0 then
  begin
    AtomicIncrement(FRunningCount, 1);
    New(Mnd);
    Mnd^.Data := nil;
    TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
    FRedisSdkManager.FZAdd(FRedisClient, PChar(Key), @zvalue[0], l, block,
      intCmdResult, Mnd);
  end;
end;

procedure TDxRedisClient.ZAddNX(Key: string; zvalue: array of TZStrValue;
block: Boolean; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
  i: Integer;
  zv: array of TZValue;
begin
  i := Length(zvalue);
  if i = 0 then
    Exit;
  AtomicIncrement(FRunningCount, 1);
  SetLength(zv, i);
  for i := Low(zvalue) to High(zvalue) do
  begin
    zv[i].Score := zvalue[i].Score;
    zv[i].Member := PChar(zvalue[i].Member);
    zv[i].MemLen := 0;
  end;

  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  FRedisSdkManager.FZAddNX(FRedisClient, PChar(Key), @zv[0], Length(zvalue),
    block, intCmdResult, Mnd);
end;

procedure TDxRedisClient.ZAddNX(Key: string; zvalue: array of TZStrValue;
block: Boolean; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  i, l: Integer;
  zv: array of TZValue;
  ATemp: TIntCmdReturn;
begin
  l := Length(zvalue);
  if l > 0 then
  begin
    AtomicIncrement(FRunningCount, 1);
    SetLength(zv, l);
    for i := Low(zvalue) to High(zvalue) do
    begin
      zv[i].Score := zvalue[i].Score;
      zv[i].Member := PChar(zvalue[i].Member);
      zv[i].MemLen := 0;
    end;

    TMethod(ATemp).Data := Pointer(-1);
    TMethod(ATemp).Code := nil;
    PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
    New(Mnd);
    Mnd^ := TMethod(ATemp);
    FRedisSdkManager.FZAddNX(FRedisClient, PChar(Key), @zv[0], l, block,
      intCmdResult, Mnd);
  end;
end;

procedure TDxRedisClient.ZAddNX(Key: string; zvalue: array of TZStrValue;
block: Boolean; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
  i, l: Integer;
  zv: array of TZValue;
begin
  l := Length(zvalue);
  if l > 0 then
  begin
    AtomicIncrement(FRunningCount, 1);
    SetLength(zv, l);
    for i := Low(zvalue) to High(zvalue) do
    begin
      zv[i].Score := zvalue[i].Score;
      zv[i].Member := PChar(zvalue[i].Member);
      zv[i].MemLen := 0;
    end;
    New(Mnd);
    Mnd^.Data := nil;
    TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
    FRedisSdkManager.FZAddNX(FRedisClient, PChar(Key), @zv[0], l, block,
      intCmdResult, Mnd);
  end;
end;

procedure TDxRedisClient.ZAddNX(Key: string; zvalue: array of TZValue;
block: Boolean; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
  i: Integer;
begin
  i := Length(zvalue);
  if i = 0 then
    Exit;
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  FRedisSdkManager.FZAddNX(FRedisClient, PChar(Key), @zvalue[0], i, block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.ZAddNX(Key: string; zvalue: array of TZValue;
block: Boolean; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  l: Integer;
  ATemp: TIntCmdReturn;
begin
  l := Length(zvalue);
  if l > 0 then
  begin
    AtomicIncrement(FRunningCount, 1);
    TMethod(ATemp).Data := Pointer(-1);
    TMethod(ATemp).Code := nil;
    PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
    New(Mnd);
    Mnd^ := TMethod(ATemp);
    FRedisSdkManager.FZAddNX(FRedisClient, PChar(Key), @zvalue[0], l, block,
      intCmdResult, Mnd);
  end;
end;

procedure TDxRedisClient.ZAddNX(Key: string; zvalue: array of TZValue;
block: Boolean; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
  l: Integer;
begin
  l := Length(zvalue);
  if l > 0 then
  begin
    AtomicIncrement(FRunningCount, 1);
    New(Mnd);
    Mnd^.Data := nil;
    TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
    FRedisSdkManager.FZAddNX(FRedisClient, PChar(Key), @zvalue[0], l, block,
      intCmdResult, Mnd);
  end;
end;

procedure TDxRedisClient.ZAddXX(Key: string; zvalue: array of TZStrValue;
block: Boolean; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
  i: Integer;
  zv: array of TZValue;
begin
  i := Length(zvalue);
  if i = 0 then
    Exit;
  AtomicIncrement(FRunningCount, 1);
  SetLength(zv, i);
  for i := Low(zvalue) to High(zvalue) do
  begin
    zv[i].Score := zvalue[i].Score;
    zv[i].Member := PChar(zvalue[i].Member);
    zv[i].MemLen := 0;
  end;

  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  FRedisSdkManager.FZAddXX(FRedisClient, PChar(Key), @zv[0], Length(zvalue),
    block, intCmdResult, Mnd);
end;

procedure TDxRedisClient.ZAddXX(Key: string; zvalue: array of TZStrValue;
block: Boolean; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  i, l: Integer;
  zv: array of TZValue;
  ATemp: TIntCmdReturn;
begin
  l := Length(zvalue);
  if l > 0 then
  begin
    AtomicIncrement(FRunningCount, 1);
    SetLength(zv, l);
    for i := Low(zvalue) to High(zvalue) do
    begin
      zv[i].Score := zvalue[i].Score;
      zv[i].Member := PChar(zvalue[i].Member);
      zv[i].MemLen := 0;
    end;

    TMethod(ATemp).Data := Pointer(-1);
    TMethod(ATemp).Code := nil;
    PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
    New(Mnd);
    Mnd^ := TMethod(ATemp);
    FRedisSdkManager.FZAddXX(FRedisClient, PChar(Key), @zv[0], l, block,
      intCmdResult, Mnd);
  end;
end;

procedure TDxRedisClient.ZAddXX(Key: string; zvalue: array of TZStrValue;
block: Boolean; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
  i, l: Integer;
  zv: array of TZValue;
begin
  l := Length(zvalue);
  if l > 0 then
  begin
    AtomicIncrement(FRunningCount, 1);
    SetLength(zv, l);
    for i := Low(zvalue) to High(zvalue) do
    begin
      zv[i].Score := zvalue[i].Score;
      zv[i].Member := PChar(zvalue[i].Member);
      zv[i].MemLen := 0;
    end;
    New(Mnd);
    Mnd^.Data := nil;
    TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
    FRedisSdkManager.FZAddXX(FRedisClient, PChar(Key), @zv[0], l, block,
      intCmdResult, Mnd);
  end;
end;

procedure TDxRedisClient.ZAddXX(Key: string; zvalue: array of TZValue;
block: Boolean; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
  i: Integer;
begin
  i := Length(zvalue);
  if i = 0 then
    Exit;
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  FRedisSdkManager.FZAddXX(FRedisClient, PChar(Key), @zvalue[0], i, block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.ZAddXX(Key: string; zvalue: array of TZValue;
block: Boolean; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  l: Integer;
  ATemp: TIntCmdReturn;
begin
  l := Length(zvalue);
  if l > 0 then
  begin
    AtomicIncrement(FRunningCount, 1);
    TMethod(ATemp).Data := Pointer(-1);
    TMethod(ATemp).Code := nil;
    PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
    New(Mnd);
    Mnd^ := TMethod(ATemp);
    FRedisSdkManager.FZAddXX(FRedisClient, PChar(Key), @zvalue[0], l, block,
      intCmdResult, Mnd);
  end;
end;

procedure TDxRedisClient.ZAddXX(Key: string; zvalue: array of TZValue;
block: Boolean; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
  l: Integer;
begin
  l := Length(zvalue);
  if l > 0 then
  begin
    AtomicIncrement(FRunningCount, 1);
    New(Mnd);
    Mnd^.Data := nil;
    TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
    FRedisSdkManager.FZAddXX(FRedisClient, PChar(Key), @zvalue[0], l, block,
      intCmdResult, Mnd);
  end;
end;

procedure TDxRedisClient.ZAddCh(Key: string; zvalue: array of TZStrValue;
block: Boolean; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
  i: Integer;
  zv: array of TZValue;
begin
  i := Length(zvalue);
  if i = 0 then
    Exit;
  AtomicIncrement(FRunningCount, 1);
  SetLength(zv, i);
  for i := Low(zvalue) to High(zvalue) do
  begin
    zv[i].Score := zvalue[i].Score;
    zv[i].Member := PChar(zvalue[i].Member);
    zv[i].MemLen := 0;
  end;

  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  FRedisSdkManager.FZAddCh(FRedisClient, PChar(Key), @zv[0], Length(zvalue),
    block, intCmdResult, Mnd);
end;

procedure TDxRedisClient.ZAddCh(Key: string; zvalue: array of TZStrValue;
block: Boolean; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  i, l: Integer;
  zv: array of TZValue;
  ATemp: TIntCmdReturn;
begin
  l := Length(zvalue);
  if l > 0 then
  begin
    AtomicIncrement(FRunningCount, 1);
    SetLength(zv, l);
    for i := Low(zvalue) to High(zvalue) do
    begin
      zv[i].Score := zvalue[i].Score;
      zv[i].Member := PChar(zvalue[i].Member);
      zv[i].MemLen := 0;
    end;

    TMethod(ATemp).Data := Pointer(-1);
    TMethod(ATemp).Code := nil;
    PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
    New(Mnd);
    Mnd^ := TMethod(ATemp);
    FRedisSdkManager.FZAddCh(FRedisClient, PChar(Key), @zv[0], l, block,
      intCmdResult, Mnd);
  end;
end;

procedure TDxRedisClient.ZAddCh(Key: string; zvalue: array of TZStrValue;
block: Boolean; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
  i, l: Integer;
  zv: array of TZValue;
begin
  l := Length(zvalue);
  if l > 0 then
  begin
    AtomicIncrement(FRunningCount, 1);
    SetLength(zv, l);
    for i := Low(zvalue) to High(zvalue) do
    begin
      zv[i].Score := zvalue[i].Score;
      zv[i].Member := PChar(zvalue[i].Member);
      zv[i].MemLen := 0;
    end;
    New(Mnd);
    Mnd^.Data := nil;
    TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
    FRedisSdkManager.FZAddCh(FRedisClient, PChar(Key), @zv[0], l, block,
      intCmdResult, Mnd);
  end;
end;

procedure TDxRedisClient.ZAddCh(Key: string; zvalue: array of TZValue;
block: Boolean; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
  i: Integer;
begin
  i := Length(zvalue);
  if i = 0 then
    Exit;
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  FRedisSdkManager.FZAddCh(FRedisClient, PChar(Key), @zvalue[0], i, block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.ZAddCh(Key: string; zvalue: array of TZValue;
block: Boolean; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  l: Integer;
  ATemp: TIntCmdReturn;
begin
  l := Length(zvalue);
  if l > 0 then
  begin
    AtomicIncrement(FRunningCount, 1);
    TMethod(ATemp).Data := Pointer(-1);
    TMethod(ATemp).Code := nil;
    PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
    New(Mnd);
    Mnd^ := TMethod(ATemp);
    FRedisSdkManager.FZAddCh(FRedisClient, PChar(Key), @zvalue[0], l, block,
      intCmdResult, Mnd);
  end;
end;

procedure TDxRedisClient.ZAddCh(Key: string; zvalue: array of TZValue;
block: Boolean; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
  l: Integer;
begin
  l := Length(zvalue);
  if l > 0 then
  begin
    AtomicIncrement(FRunningCount, 1);
    New(Mnd);
    Mnd^.Data := nil;
    TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
    FRedisSdkManager.FZAddCh(FRedisClient, PChar(Key), @zvalue[0], l, block,
      intCmdResult, Mnd);
  end;
end;

procedure TDxRedisClient.ZAddNXCh(Key: string; zvalue: array of TZStrValue;
block: Boolean; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
  i: Integer;
  zv: array of TZValue;
begin
  i := Length(zvalue);
  if i = 0 then
    Exit;
  AtomicIncrement(FRunningCount, 1);
  SetLength(zv, i);
  for i := Low(zvalue) to High(zvalue) do
  begin
    zv[i].Score := zvalue[i].Score;
    zv[i].Member := PChar(zvalue[i].Member);
    zv[i].MemLen := 0;
  end;

  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  FRedisSdkManager.FZAddNXCh(FRedisClient, PChar(Key), @zv[0], Length(zvalue),
    block, intCmdResult, Mnd);
end;

procedure TDxRedisClient.ZAddNXCh(Key: string; zvalue: array of TZStrValue;
block: Boolean; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  i, l: Integer;
  zv: array of TZValue;
  ATemp: TIntCmdReturn;
begin
  l := Length(zvalue);
  if l > 0 then
  begin
    AtomicIncrement(FRunningCount, 1);
    SetLength(zv, l);
    for i := Low(zvalue) to High(zvalue) do
    begin
      zv[i].Score := zvalue[i].Score;
      zv[i].Member := PChar(zvalue[i].Member);
      zv[i].MemLen := 0;
    end;

    TMethod(ATemp).Data := Pointer(-1);
    TMethod(ATemp).Code := nil;
    PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
    New(Mnd);
    Mnd^ := TMethod(ATemp);
    FRedisSdkManager.FZAddNXCh(FRedisClient, PChar(Key), @zv[0], l, block,
      intCmdResult, Mnd);
  end;
end;

procedure TDxRedisClient.ZAddNXCh(Key: string; zvalue: array of TZStrValue;
block: Boolean; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
  i, l: Integer;
  zv: array of TZValue;
begin
  l := Length(zvalue);
  if l > 0 then
  begin
    AtomicIncrement(FRunningCount, 1);
    SetLength(zv, l);
    for i := Low(zvalue) to High(zvalue) do
    begin
      zv[i].Score := zvalue[i].Score;
      zv[i].Member := PChar(zvalue[i].Member);
      zv[i].MemLen := 0;
    end;
    New(Mnd);
    Mnd^.Data := nil;
    TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
    FRedisSdkManager.FZAddNXCh(FRedisClient, PChar(Key), @zv[0], l, block,
      intCmdResult, Mnd);
  end;
end;

procedure TDxRedisClient.ZAddNXCh(Key: string; zvalue: array of TZValue;
block: Boolean; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
  i: Integer;
begin
  i := Length(zvalue);
  if i = 0 then
    Exit;
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  FRedisSdkManager.FZAddNXCh(FRedisClient, PChar(Key), @zvalue[0], i, block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.ZAddNXCh(Key: string; zvalue: array of TZValue;
block: Boolean; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  l: Integer;
  ATemp: TIntCmdReturn;
begin
  l := Length(zvalue);
  if l > 0 then
  begin
    AtomicIncrement(FRunningCount, 1);
    TMethod(ATemp).Data := Pointer(-1);
    TMethod(ATemp).Code := nil;
    PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
    New(Mnd);
    Mnd^ := TMethod(ATemp);
    FRedisSdkManager.FZAddNXCh(FRedisClient, PChar(Key), @zvalue[0], l, block,
      intCmdResult, Mnd);
  end;
end;

procedure TDxRedisClient.ZAddNXCh(Key: string; zvalue: array of TZValue;
block: Boolean; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
  l: Integer;
begin
  l := Length(zvalue);
  if l > 0 then
  begin
    AtomicIncrement(FRunningCount, 1);
    New(Mnd);
    Mnd^.Data := nil;
    TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
    FRedisSdkManager.FZAddNXCh(FRedisClient, PChar(Key), @zvalue[0], l, block,
      intCmdResult, Mnd);
  end;
end;

procedure TDxRedisClient.ZAddXXCh(Key: string; zvalue: array of TZStrValue;
block: Boolean; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
  i: Integer;
  zv: array of TZValue;
begin
  i := Length(zvalue);
  if i = 0 then
    Exit;
  AtomicIncrement(FRunningCount, 1);
  SetLength(zv, i);
  for i := Low(zvalue) to High(zvalue) do
  begin
    zv[i].Score := zvalue[i].Score;
    zv[i].Member := PChar(zvalue[i].Member);
    zv[i].MemLen := 0;
  end;

  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  FRedisSdkManager.FZAddXXCh(FRedisClient, PChar(Key), @zv[0], Length(zvalue),
    block, intCmdResult, Mnd);
end;

procedure TDxRedisClient.ZAddXXCh(Key: string; zvalue: array of TZStrValue;
block: Boolean; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  i, l: Integer;
  zv: array of TZValue;
  ATemp: TIntCmdReturn;
begin
  l := Length(zvalue);
  if l > 0 then
  begin
    AtomicIncrement(FRunningCount, 1);
    SetLength(zv, l);
    for i := Low(zvalue) to High(zvalue) do
    begin
      zv[i].Score := zvalue[i].Score;
      zv[i].Member := PChar(zvalue[i].Member);
      zv[i].MemLen := 0;
    end;

    TMethod(ATemp).Data := Pointer(-1);
    TMethod(ATemp).Code := nil;
    PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
    New(Mnd);
    Mnd^ := TMethod(ATemp);
    FRedisSdkManager.FZAddXXCh(FRedisClient, PChar(Key), @zv[0], l, block,
      intCmdResult, Mnd);
  end;
end;

procedure TDxRedisClient.ZAddXXCh(Key: string; zvalue: array of TZStrValue;
block: Boolean; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
  i, l: Integer;
  zv: array of TZValue;
begin
  l := Length(zvalue);
  if l > 0 then
  begin
    AtomicIncrement(FRunningCount, 1);
    SetLength(zv, l);
    for i := Low(zvalue) to High(zvalue) do
    begin
      zv[i].Score := zvalue[i].Score;
      zv[i].Member := PChar(zvalue[i].Member);
      zv[i].MemLen := 0;
    end;
    New(Mnd);
    Mnd^.Data := nil;
    TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
    FRedisSdkManager.FZAddXXCh(FRedisClient, PChar(Key), @zv[0], l, block,
      intCmdResult, Mnd);
  end;
end;

procedure TDxRedisClient.ZAddXXCh(Key: string; zvalue: array of TZValue;
block: Boolean; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
  i: Integer;
begin
  i := Length(zvalue);
  if i = 0 then
    Exit;
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  FRedisSdkManager.FZAddXXCh(FRedisClient, PChar(Key), @zvalue[0], i, block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.ZAddXXCh(Key: string; zvalue: array of TZValue;
block: Boolean; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  l: Integer;
  ATemp: TIntCmdReturn;
begin
  l := Length(zvalue);
  if l > 0 then
  begin
    AtomicIncrement(FRunningCount, 1);
    TMethod(ATemp).Data := Pointer(-1);
    TMethod(ATemp).Code := nil;
    PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
    New(Mnd);
    Mnd^ := TMethod(ATemp);
    FRedisSdkManager.FZAddXXCh(FRedisClient, PChar(Key), @zvalue[0], l, block,
      intCmdResult, Mnd);
  end;
end;

procedure TDxRedisClient.ZAddXXCh(Key: string; zvalue: array of TZValue;
block: Boolean; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
  l: Integer;
begin
  l := Length(zvalue);
  if l > 0 then
  begin
    AtomicIncrement(FRunningCount, 1);
    New(Mnd);
    Mnd^.Data := nil;
    TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
    FRedisSdkManager.FZAddXXCh(FRedisClient, PChar(Key), @zvalue[0], l, block,
      intCmdResult, Mnd);
  end;
end;

procedure TDxRedisClient.ZLexCount(Key, min, max: string; block: Boolean;
intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  FRedisSdkManager.FZLexCount(FRedisClient, PChar(Key), PChar(min), PChar(max),
    block, intCmdResult, Mnd);
end;

procedure TDxRedisClient.ZLexCount(Key, min, max: string; block: Boolean;
intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FZLexCount(FRedisClient, PChar(Key), PChar(min), PChar(max),
    block, intCmdResult, Mnd);
end;

procedure TDxRedisClient.ZLexCount(Key, min, max: string; block: Boolean;
intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  FRedisSdkManager.FZLexCount(FRedisClient, PChar(Key), PChar(min), PChar(max),
    block, intCmdResult, Mnd);
end;

procedure TDxRedisClient.ZRemRangeByRank(Key: string; Start, stop: Int64;
block: Boolean; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  FRedisSdkManager.FZRemRangeByRank(FRedisClient, PChar(Key), Start, stop,
    block, intCmdResult, Mnd);
end;

procedure TDxRedisClient.ZRemRangeByRank(Key: string; Start, stop: Int64;
block: Boolean; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FZRemRangeByRank(FRedisClient, PChar(Key), Start, stop,
    block, intCmdResult, Mnd);
end;

procedure TDxRedisClient.ZRemRangeByRank(Key: string; Start, stop: Int64;
block: Boolean; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  FRedisSdkManager.FZRemRangeByRank(FRedisClient, PChar(Key), Start, stop,
    block, intCmdResult, Mnd);
end;

procedure TDxRedisClient.ZRank(Key, Member: string; block: Boolean;
intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  FRedisSdkManager.FZRank(FRedisClient, PChar(Key), PChar(Member), block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.ZRank(Key, Member: string; block: Boolean;
intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FZRank(FRedisClient, PChar(Key), PChar(Member), block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.ZRank(Key, Member: string; block: Boolean;
intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  FRedisSdkManager.FZRank(FRedisClient, PChar(Key), PChar(Member), block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.ZRem(Key: string; membersArr: array of string;
block: Boolean; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
  i, l: Integer;
  redisKVs: array of TValueInterface;
begin
  l := Length(membersArr);
  if l = 0 then
    Exit;
  AtomicIncrement(FRunningCount, 1);
  SetLength(redisKVs, l);
  for i := 0 to l - 1 do
  begin
    redisKVs[i].ValueLen := 0;
    redisKVs[i].Value := PChar(membersArr[i]);
  end;

  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  FRedisSdkManager.FZRem(FRedisClient, PChar(Key), @redisKVs[0], l, block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.ZRem(Key: string; membersArr: array of string;
block: Boolean; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
  i, l: Integer;
  redisKVs: array of TValueInterface;
begin
  l := Length(membersArr);
  if l = 0 then
    Exit;
  AtomicIncrement(FRunningCount, 1);
  SetLength(redisKVs, l);
  for i := 0 to l - 1 do
  begin
    redisKVs[i].ValueLen := 0;
    redisKVs[i].Value := PChar(membersArr[i]);
  end;
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FZRem(FRedisClient, PChar(Key), @redisKVs[0], l, block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.ZRem(Key: string; membersArr: array of string;
block: Boolean; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
  i, l: Integer;
  redisKVs: array of TValueInterface;
begin
  l := Length(membersArr);
  if l = 0 then
    Exit;
  AtomicIncrement(FRunningCount, 1);
  SetLength(redisKVs, l);
  for i := 0 to l - 1 do
  begin
    redisKVs[i].ValueLen := 0;
    redisKVs[i].Value := PChar(membersArr[i]);
  end;
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  FRedisSdkManager.FZRem(FRedisClient, PChar(Key), @redisKVs[0], l, block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.ZRem(Key: string; membersArr: array of TValueInterface;
block: Boolean; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
  l: Integer;
begin
  l := Length(membersArr);
  if l = 0 then
    Exit;
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  FRedisSdkManager.FZRem(FRedisClient, PChar(Key), @membersArr[0], l, block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.ZRem(Key: string; membersArr: array of TValueInterface;
block: Boolean; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
  l: Integer;
begin
  l := Length(membersArr);
  if l = 0 then
    Exit;
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FZRem(FRedisClient, PChar(Key), @membersArr[0], l, block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.ZRem(Key: string; membersArr: array of TValueInterface;
block: Boolean; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
  l: Integer;
begin
  l := Length(membersArr);
  if l = 0 then
    Exit;
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  FRedisSdkManager.FZRem(FRedisClient, PChar(Key), @membersArr[0], l, block,
    intCmdResult, Mnd);
end;

procedure TDxRedisClient.ZRemRangeByScore(Key, min, max: string; block: Boolean;
intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  FRedisSdkManager.FZRemRangeByScore(FRedisClient, PChar(Key), PChar(min),
    PChar(max), block, intCmdResult, Mnd);
end;

procedure TDxRedisClient.ZRemRangeByScore(Key, min, max: string; block: Boolean;
intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FZRemRangeByScore(FRedisClient, PChar(Key), PChar(min),
    PChar(max), block, intCmdResult, Mnd);
end;

procedure TDxRedisClient.ZRemRangeByScore(Key, min, max: string; block: Boolean;
intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  FRedisSdkManager.FZRemRangeByScore(FRedisClient, PChar(Key), PChar(min),
    PChar(max), block, intCmdResult, Mnd);
end;

procedure TDxRedisClient.ZRemRangeByLex(Key, min, max: string; block: Boolean;
intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  FRedisSdkManager.FZRemRangeByLex(FRedisClient, PChar(Key), PChar(min),
    PChar(max), block, intCmdResult, Mnd);
end;

procedure TDxRedisClient.ZRemRangeByLex(Key, min, max: string; block: Boolean;
intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FZRemRangeByLex(FRedisClient, PChar(Key), PChar(min),
    PChar(max), block, intCmdResult, Mnd);
end;

procedure TDxRedisClient.ZRemRangeByLex(Key, min, max: string; block: Boolean;
intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  FRedisSdkManager.FZRemRangeByLex(FRedisClient, PChar(Key), PChar(min),
    PChar(max), block, intCmdResult, Mnd);
end;

end.
