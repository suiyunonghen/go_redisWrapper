unit RedisSDK;

interface

uses Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  QSimplePool, qstring, Forms;

type
  //对应redis的string结构
  TValueInterface = record
    ValueLen: Integer;
    Value: Pointer;
  end;
  PValueInterface = ^TValueInterface;

  TRedisLogLevel = (llEmergency, llAlert, llFatal, llError, llWarning, llHint,
    llMessage, llDebug);
  TstatusCmdCallback = procedure(redisClient, params: Pointer; CmdResult: PChar;
    IsErrResult: Boolean); stdcall;
  TLogProc = procedure(Data: Pointer; logLevel: Integer;
    logMsg: PChar); stdcall;
  // 如果resultLen>0就是PByte
  TStringCmdCallback = procedure(redisClient, params: Pointer;
    CmdResult: Pointer; resultLen: Integer; IsErrResult: Boolean); stdcall;
  TScanCmdCallback = procedure(redisClient, params: Pointer; keyValues: Pointer;ValuesLen: Integer;
    cursor: Int64; kvType: Byte); stdcall;
  TIntCmdCallBack = procedure(redisClient, params: Pointer; intResult: Int64;errMsg: PChar); stdcall;
  TfloatCmdCallBack = procedure(redisClient, params: Pointer; floatResult: Double;errMsg: PChar); stdcall;
  //字符串数组指令返回的回调函数
  TstringSliceCmdCallback = procedure(redisClient, params: Pointer;resultSlice: PValueInterface;sliceLen: Integer;errMsg: Pchar);stdcall;
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
    Addr: PChar;
    Username: PChar;
    Password: PChar;
    DBIndex: Byte;
    MaxRetries: Byte;
    DialTimeout: Byte;
    ReadTimeout: Byte;
    WriteTimeout: Byte;
    MinIdleConns: byte;			//10 在启动阶段创建指定数量的Idle连接，并长期维持idle状态的连接数不少于指定数量；。
	  PoolTimeout:  byte;			//当所有连接都处在繁忙状态时，客户端等待可用连接的最大等待时长，默认为读超时+1秒。
	  IdleTimeout:  byte;			//闲置超时，默认5分钟，-1表示取消闲置超时检查
    MaxConnAge:   Byte;     //连接存活时长，从创建开始计时，超过指定时长则关闭连接，默认为0，即不关闭存活时长较长的连接
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
    MinIdleConns: byte;			//10 在启动阶段创建指定数量的Idle连接，并长期维持idle状态的连接数不少于指定数量；。
	  PoolTimeout:  byte;			//当所有连接都处在繁忙状态时，客户端等待可用连接的最大等待时长，默认为读超时+1秒。
	  IdleTimeout:  byte;			//闲置超时，默认5分钟，-1表示取消闲置超时检查
    MaxConnAge:   Byte;     //连接存活时长，从创建开始计时，超过指定时长则关闭连接，默认为0，即不关闭存活时长较长的连接
  end;
  PRedisSentinelCfg = ^TRedisSentinelCfg;

  //集群配置
  TRedisClusterCfg = record
    Username: PChar;
    Password: PChar;
    ClusterAddrs: PChar;//集群节点地址 ;分割
    MaxRedirects: Byte;
    ReadOnly:			Boolean;			//置为true则允许在从节点上执行只含读操作的命令
    RouteByLatency: Boolean;			//默认false。 置为true则ReadOnly自动置为true,表示在处理只读命令时，可以在一个slot对应的主节点和所有从节点中选取Ping()的响应时长最短的一个节点来读数据
    RouteRandomly: Boolean;			//默认false。置为true则ReadOnly自动置为true,表示在处理只读命令时，可以在一个slot对应的主节点和所有从节点中随机挑选一个节点来读数据
    MaxRetries: Byte;
    DialTimeout: Byte;
    ReadTimeout: Byte;
    WriteTimeout: Byte;
    MinIdleConns: Byte;			//10 在启动阶段创建指定数量的Idle连接，并长期维持idle状态的连接数不少于指定数量；。
    PoolTimeout: Byte;			//当所有连接都处在繁忙状态时，客户端等待可用连接的最大等待时长，默认为读超时+1秒。
    IdleTimeout: Byte;			//闲置超时，默认5分钟，-1表示取消闲置超时检查
    MaxConnAge: Byte;			//连接存活时长，从创建开始计时，超过指定时长则关闭连接，默认为0，即不关闭存活时长较长的连接
  end;
  PRedisClusterCfg = ^TRedisClusterCfg;

  TWndMsgCmd = (MC_Log, MC_StatusCmd, MC_ScanCmd, MC_SelectScan, MC_StringCmd,
    MC_IntCmd,MC_FloatCmd,MC_pipeCmd,MC_BoolCmd,MC_StringSliceCmd);

  PSynWndMessageItem = ^TSynWndMessageItem;

  TSynWndMessageItem = record
    Cmd: TWndMsgCmd;
    params: Pointer;
    Next: PSynWndMessageItem;
  end;

  TRedisKeyValue = record
    Key: PChar;
    Value: TValueInterface;
  end;
  PRedisKeyValue = ^TRedisKeyValue;

  TKeyValueEx = record
    Key: string;
    value: TValueInterface;
  end;

  TRedisScoreValue = record
    key: PChar;
    score: Double;
  end;
  PRedisScoreValue = ^TRedisScoreValue;


  TScoreValue = record
    key: string;
    score: Double;
  end;
  PScoreValue = ^TScoreValue;

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

  TRedisScanValueCmdReturn = procedure(Sender: Tobject; Values: array of TValueInterface;
    cursor: UInt64; errMsg: string) of object;
  TRedisScanValueCmdReturnA = reference to procedure(Values: array of TValueInterface;
    cursor: UInt64; errMsg: string);
  PRedisScanValueCmdReturnA = ^TRedisScanValueCmdReturnA;
  TRedisScanValueCmdReturnG = procedure(Values: array of TValueInterface; cursor: UInt64;
    errMsg: string);

  TRedisScanKVCmdReturn = procedure(Sender: Tobject; Values: array of TKeyValueEx;
    cursor: UInt64; errMsg: string) of object;
  TRedisScanKVCmdReturnA = reference to procedure(Values: array of TKeyValueEx;
    cursor: UInt64; errMsg: string);
  PRedisScanKVCmdReturnA = ^TRedisScanKVCmdReturnA;
  TRedisScanKVCmdReturnG = procedure(Values: array of TKeyValueEx; cursor: UInt64;
    errMsg: string);

  TRedisScanKScoreCmdReturn = procedure(Sender: Tobject; Values: array of TScoreValue;
    cursor: UInt64; errMsg: string) of object;
  TRedisScanKScoreCmdReturnA = reference to procedure(Values: array of TScoreValue;
    cursor: UInt64; errMsg: string);
  PRedisScanKScoreCmdReturnA = ^TRedisScanKScoreCmdReturnA;
  TRedisScanKScoreCmdReturnG = procedure(Values: array of TScoreValue; cursor: UInt64;
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

  TfloatCmdReturn = procedure(Sender: Tobject; floatResult: Double; errMsg: string)
    of object;
  TfloatCmdReturnA = reference to procedure(floatResult: Double; errMsg: string);
  PfloatCmdReturnA = ^TfloatCmdReturnA;
  TfloatCmdReturnG = procedure(floatResult: Double; errMsg: string);

  TBoolCmdReturn = procedure(Sender: Tobject; returnResult: boolean; errMsg: string)
    of object;
  TBoolCmdReturnA = reference to procedure(returnResult: boolean; errMsg: string);
  PBoolCmdReturnA = ^TBoolCmdReturnA;
  TBoolCmdReturnG = procedure(returnResult: boolean; errMsg: string);

  TPipelineExecReturn = procedure(Sender: TObject;ErrMsg: string) of object;
  TPipelineExecReturnA = reference to procedure(errMsg: string);
  PPipelineExecReturnA = ^TPipelineExecReturnA;
  TPipelineExecReturnG = procedure(ErrMsg: string);

  TStringSliceCmdReturn = procedure(Sender: Tobject; resultSlice: array of TValueInterface;errMsg: string) of object;
  TStringSliceCmdReturnA = reference to procedure(resultSlice: array of TValueInterface;errMsg: string);
  PStringSliceCmdReturnA = ^TStringSliceCmdReturnA;
  TStringSliceCmdReturnG = procedure(resultSlice: array of TValueInterface;errMsg: string);

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

  TRedisSort = record
    desc:     Boolean;  //排序顺序
    alpha:    Boolean;  //是否是对字符串排序
    offset,count: int64;
    by:       pchar;
    get:      pchar; //\n分割
  end;
  PRedisSort = ^TRedisSort;

  TRedisRangeBy = record
    min,max:  PChar;
    offset,count: Int64;
  end;
  PRedisRangeBy = ^TRedisRangeBy;

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
    FIdleTimeout: byte;
    FMaxConnAge: byte;
    FMinIdleConns: Byte;
    FPoolTimeout: byte;
    FMaxRedirects: Byte;
    FRouteByLatency: Boolean;
    FRouteRandomly: Boolean;
    FReadOnly: Boolean;
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
    procedure SetIdleTimeout(const Value: byte);
    procedure SetMaxConnAge(const Value: byte);
    procedure SetMinIdleConns(const Value: Byte);
    procedure SetPoolTimeout(const Value: byte);
    procedure SetMaxRedirects(const Value: Byte);
    procedure SetReadOnly(const Value: Boolean);
    procedure SetRouteByLatency(const Value: Boolean);
    procedure SetRouteRandomly(const Value: Boolean);
  protected
    FRunningCount: Integer; // 正在执行的命令数量
    //FPipeList: TList; //正在使用的Pipe
    procedure InitRedisClient;
    procedure CloseRedisClient;
    function NewPipeline(isTxPipe: Boolean;Data: Pointer): Pointer;
    procedure FreePipeline(pipeClient: Pointer);
  public
    constructor Create;
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
      block: Boolean; scanCmdReturn: TRedisScanValueCmdReturn); overload;
    procedure SScan(cursor: UInt64; Key, match: string; count: Int64;
      block: Boolean; scanCmdReturn: TRedisScanValueCmdReturnA); overload;
    procedure SScan(cursor: UInt64; Key, match: string; count: Int64;
      block: Boolean; scanCmdReturn: TRedisScanValueCmdReturnG); overload;

    procedure HScan(cursor: UInt64; Key, match: string; count: Int64;
      block: Boolean; scanCmdReturn: TRedisScanKVCmdReturn); overload;
    procedure HScan(cursor: UInt64; Key, match: string; count: Int64;
      block: Boolean; scanCmdReturn: TRedisScanKVCmdReturnA); overload;
    procedure HScan(cursor: UInt64; Key, match: string; count: Int64;
      block: Boolean; scanCmdReturn: TRedisScanKVCmdReturnG); overload;

    procedure ZScan(cursor: UInt64; Key, match: string; count: Int64;
      block: Boolean; scanCmdReturn: TRedisScanKScoreCmdReturn); overload;
    procedure ZScan(cursor: UInt64; Key, match: string; count: Int64;
      block: Boolean; scanCmdReturn: TRedisScanKScoreCmdReturnA); overload;
    procedure ZScan(cursor: UInt64; Key, match: string; count: Int64;
      block: Boolean; scanCmdReturn: TRedisScanKScoreCmdReturnG); overload;
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

    procedure RandomKey(block: Boolean;stringCmdReturn: TRedisStringCmdReturn); overload;
    procedure RandomKey(block: Boolean;stringCmdReturn: TRedisStringCmdReturnA); overload;
    procedure RandomKey(block: Boolean;stringCmdReturn: TRedisStringCmdReturnG); overload;

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

    procedure MGet(keys: array of string; block: Boolean;
      CmdReturn: TStringSliceCmdReturn); overload;
    procedure MGet(keys: array of string; block: Boolean;
      CmdReturn: TStringSliceCmdReturnA); overload;
    procedure MGet(keys: array of string; block: Boolean;
      CmdReturn: TStringSliceCmdReturnG); overload;

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

    procedure IncrByFloat(Key: string; increment: Double; block: Boolean;
      floatCmdReturn: TfloatCmdReturn); overload;
    procedure IncrByFloat(Key: string; increment: Double; block: Boolean;
      floatCmdReturn: TfloatCmdReturnA); overload;
    procedure IncrByFloat(Key: string; increment: Double; block: Boolean;
      floatCmdReturn: TfloatCmdReturnG); overload;

    procedure HIncrByFloat(Key,field: string; increment: Double; block: Boolean;
      floatCmdReturn: TfloatCmdReturn); overload;
    procedure HIncrByFloat(Key,field: string; increment: Double; block: Boolean;
      floatCmdReturn: TfloatCmdReturnA); overload;
    procedure HIncrByFloat(Key,field: string; increment: Double; block: Boolean;
      floatCmdReturn: TfloatCmdReturnG); overload;

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
    procedure LInsert(Key: string; before: Boolean; pivot, Value: TValueInterface;
      block: Boolean; intCmdReturn: TIntCmdReturn); overload;
    procedure LInsert(Key: string; before: Boolean; pivot, Value: TValueInterface;
      block: Boolean; intCmdReturn: TIntCmdReturnA); overload;
    procedure LInsert(Key: string; before: Boolean; pivot, Value: TValueInterface;
      block: Boolean; intCmdReturn: TIntCmdReturnG); overload;

    procedure LInsertBefore(Key: string; pivot, Value: string; block: Boolean;
      intCmdReturn: TIntCmdReturn); overload;
    procedure LInsertBefore(Key: string; pivot, Value: string; block: Boolean;
      intCmdReturn: TIntCmdReturnA); overload;
    procedure LInsertBefore(Key: string; pivot, Value: string; block: Boolean;
      intCmdReturn: TIntCmdReturnG); overload;
    procedure LInsertBefore(Key: string; pivot, Value: TValueInterface; block: Boolean;
      intCmdReturn: TIntCmdReturn); overload;
    procedure LInsertBefore(Key: string; pivot, Value: TValueInterface; block: Boolean;
      intCmdReturn: TIntCmdReturnA); overload;
    procedure LInsertBefore(Key: string; pivot, Value: TValueInterface; block: Boolean;
      intCmdReturn: TIntCmdReturnG); overload;


    procedure LInsertAfter(Key: string; pivot, Value: string; block: Boolean;
      intCmdReturn: TIntCmdReturn); overload;
    procedure LInsertAfter(Key: string; pivot, Value: string; block: Boolean;
      intCmdReturn: TIntCmdReturnA); overload;
    procedure LInsertAfter(Key: string; pivot, Value: string; block: Boolean;
      intCmdReturn: TIntCmdReturnG); overload;
    procedure LInsertAfter(Key: string; pivot, Value: TValueInterface; block: Boolean;
      intCmdReturn: TIntCmdReturn); overload;
    procedure LInsertAfter(Key: string; pivot, Value: TValueInterface; block: Boolean;
      intCmdReturn: TIntCmdReturnA); overload;
    procedure LInsertAfter(Key: string; pivot, Value: TValueInterface; block: Boolean;
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
    //返回秒
    procedure TTL(key: string;block: Boolean;intCmdReturn: TIntCmdReturn); overload;
    procedure TTL(key: string;block: Boolean;intCmdReturn: TIntCmdReturnA); overload;
    procedure TTL(key: string;block: Boolean;intCmdReturn: TIntCmdReturnG); overload;
    //毫秒
    procedure PTTL(key: string;block: Boolean;intCmdReturn: TIntCmdReturn); overload;
    procedure PTTL(key: string;block: Boolean;intCmdReturn: TIntCmdReturnA); overload;
    procedure PTTL(key: string;block: Boolean;intCmdReturn: TIntCmdReturnG); overload;

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

    procedure Keys(pattern: string;block: Boolean;cmdReturn: TRedisScanCmdReturn);overload;
    procedure Keys(pattern: string;block: Boolean;cmdReturn: TRedisScanCmdReturnA);overload;
    procedure Keys(pattern: string;block: Boolean;cmdReturn: TRedisScanCmdReturnG);overload;

    procedure Sort(key: string;sort: TRedisSort;block: Boolean;cmdReturn: TStringSliceCmdReturn);overload;
    procedure Sort(key: string;sort: TRedisSort;block: Boolean;cmdReturn: TStringSliceCmdReturnA);overload;
    procedure Sort(key: string;sort: TRedisSort;block: Boolean;cmdReturn: TStringSliceCmdReturnG);overload;
    procedure SortStore(key,storeKey: string;sort: TRedisSort;block: Boolean;cmdReturn: TIntCmdReturn);overload;
    procedure SortStore(key,storeKey: string;sort: TRedisSort;block: Boolean;cmdReturn: TIntCmdReturnA);overload;
    procedure SortStore(key,storeKey: string;sort: TRedisSort;block: Boolean;cmdReturn: TIntCmdReturnG);overload;
    procedure HKeys(key: string;block: Boolean;cmdReturn: TRedisScanCmdReturn);overload;
    procedure HKeys(key: string;block: Boolean;cmdReturn: TRedisScanCmdReturnA);overload;
    procedure HKeys(key: string;block: Boolean;cmdReturn: TRedisScanCmdReturnG);overload;
    procedure HVals(key: string;block: Boolean;cmdReturn: TStringSliceCmdReturn);overload;
    procedure HVals(key: string;block: Boolean;cmdReturn: TStringSliceCmdReturnA);overload;
    procedure HVals(key: string;block: Boolean;cmdReturn: TStringSliceCmdReturnG);overload;
    procedure HRandField(key: string;count: integer;withValues,block: Boolean;cmdReturn: TStringSliceCmdReturn);overload;
    procedure HRandField(key: string;count: integer;withValues,block: Boolean;cmdReturn: TStringSliceCmdReturnA);overload;
    procedure HRandField(key: string;count: integer;withValues,block: Boolean;cmdReturn: TStringSliceCmdReturnG);overload;
    procedure BRPop(timeout: integer;Keys: array of string;block: Boolean;cmdReturn: TStringSliceCmdReturn);overload;
    procedure BRPop(timeout: integer;Keys: array of string;block: Boolean;cmdReturn: TStringSliceCmdReturnA);overload;
    procedure BRPop(timeout: integer;Keys: array of string;block: Boolean;cmdReturn: TStringSliceCmdReturnG);overload;
    procedure BLPop(timeout: integer;Keys: array of string;block: Boolean;cmdReturn: TStringSliceCmdReturn);overload;
    procedure BLPop(timeout: integer;Keys: array of string;block: Boolean;cmdReturn: TStringSliceCmdReturnA);overload;
    procedure BLPop(timeout: integer;Keys: array of string;block: Boolean;cmdReturn: TStringSliceCmdReturnG);overload;
    procedure LPopCount(key: string;count: Integer;block: Boolean;cmdReturn: TStringSliceCmdReturn);overload;
    procedure LPopCount(key: string;count: Integer;block: Boolean;cmdReturn: TStringSliceCmdReturnA);overload;
    procedure LPopCount(key: string;count: Integer;block: Boolean;cmdReturn: TStringSliceCmdReturnG);overload;
    procedure LRange(key: string;start,stop: int64;block: Boolean;cmdReturn: TStringSliceCmdReturn);overload;
    procedure LRange(key: string;start,stop: int64;block: Boolean;cmdReturn: TStringSliceCmdReturnA);overload;
    procedure LRange(key: string;start,stop: int64;block: Boolean;cmdReturn: TStringSliceCmdReturnG);overload;
    procedure ZRange(key: string;start,stop: int64;block: Boolean;cmdReturn: TStringSliceCmdReturn);overload;
    procedure ZRange(key: string;start,stop: int64;block: Boolean;cmdReturn: TStringSliceCmdReturnA);overload;
    procedure ZRange(key: string;start,stop: int64;block: Boolean;cmdReturn: TStringSliceCmdReturnG);overload;
    procedure ZRevRange(key: string;start,stop: int64;block: Boolean;cmdReturn: TStringSliceCmdReturn);overload;
    procedure ZRevRange(key: string;start,stop: int64;block: Boolean;cmdReturn: TStringSliceCmdReturnA);overload;
    procedure ZRevRange(key: string;start,stop: int64;block: Boolean;cmdReturn: TStringSliceCmdReturnG);overload;
    procedure ZRangeByScore(key: string;opt: TRedisRangeBy;block: Boolean;cmdReturn: TStringSliceCmdReturn);overload;
    procedure ZRangeByScore(key: string;opt: TRedisRangeBy;block:Boolean;cmdReturn: TStringSliceCmdReturnA);overload;
    procedure ZRangeByScore(key: string;opt: TRedisRangeBy;block:Boolean;cmdReturn: TStringSliceCmdReturnG);overload;
    procedure ZRangeByLex(key: string;opt: TRedisRangeBy;block:Boolean;cmdReturn: TStringSliceCmdReturn);overload;
    procedure ZRangeByLex(key: string;opt: TRedisRangeBy;block:Boolean;cmdReturn: TStringSliceCmdReturnA);overload;
    procedure ZRangeByLex(key: string;opt: TRedisRangeBy;block:Boolean;cmdReturn: TStringSliceCmdReturnG);overload;
    procedure SDiff(Keys: array of string;block: Boolean;cmdReturn: TStringSliceCmdReturn);overload;
    procedure SDiff(Keys: array of string;block: Boolean;cmdReturn: TStringSliceCmdReturnA);overload;
    procedure SDiff(Keys: array of string;block: Boolean;cmdReturn: TStringSliceCmdReturnG);overload;
    procedure SUnion(Keys: array of string;block: Boolean;cmdReturn: TStringSliceCmdReturn);overload;
    procedure SUnion(Keys: array of string;block: Boolean;cmdReturn: TStringSliceCmdReturnA);overload;
    procedure SUnion(Keys: array of string;block: Boolean;cmdReturn: TStringSliceCmdReturnG);overload;
    procedure SInter(Keys: array of string;block: Boolean;cmdReturn: TStringSliceCmdReturn);overload;
    procedure SInter(Keys: array of string;block: Boolean;cmdReturn: TStringSliceCmdReturnA);overload;
    procedure SInter(Keys: array of string;block: Boolean;cmdReturn: TStringSliceCmdReturnG);overload;
    procedure SMembers(key: string;block: Boolean;cmdReturn: TStringSliceCmdReturn);overload;
    procedure SMembers(key: string;block: Boolean;cmdReturn: TStringSliceCmdReturnA);overload;
    procedure SMembers(key: string;block: Boolean;cmdReturn: TStringSliceCmdReturnG);overload;
    procedure SPopN(key: string;count: Int64; block: Boolean;cmdReturn: TStringSliceCmdReturn);overload;
    procedure SPopN(key: string;count: Int64;block: Boolean;cmdReturn: TStringSliceCmdReturnA);overload;
    procedure SPopN(key: string;count: Int64;block: Boolean;cmdReturn: TStringSliceCmdReturnG);overload;
    procedure SRandMemberN(key: string;count: Int64; block: Boolean;cmdReturn: TStringSliceCmdReturn);overload;
    procedure SRandMemberN(key: string;count: Int64;block: Boolean;cmdReturn: TStringSliceCmdReturnA);overload;
    procedure SRandMemberN(key: string;count: Int64;block: Boolean;cmdReturn: TStringSliceCmdReturnG);overload;
    procedure ZRevRangeByScore(key: string;opt: TRedisRangeBy;block: Boolean;cmdReturn: TStringSliceCmdReturn);overload;
    procedure ZRevRangeByScore(key: string;opt: TRedisRangeBy;block:Boolean;cmdReturn: TStringSliceCmdReturnA);overload;
    procedure ZRevRangeByScore(key: string;opt: TRedisRangeBy;block:Boolean;cmdReturn: TStringSliceCmdReturnG);overload;
    procedure ZRevRangeByLex(key: string;opt: TRedisRangeBy;block: Boolean;cmdReturn: TStringSliceCmdReturn);overload;
    procedure ZRevRangeByLex(key: string;opt: TRedisRangeBy;block:Boolean;cmdReturn: TStringSliceCmdReturnA);overload;
    procedure ZRevRangeByLex(key: string;opt: TRedisRangeBy;block:Boolean;cmdReturn: TStringSliceCmdReturnG);overload;
    procedure ZRandMember(key: string;count: Integer;withScores,block: Boolean;cmdReturn: TStringSliceCmdReturn);overload;
    procedure ZRandMember(key: string;count: Integer;withScores,block: Boolean;cmdReturn: TStringSliceCmdReturnA);overload;
    procedure ZRandMember(key: string;count: Integer;withScores,block: Boolean;cmdReturn: TStringSliceCmdReturnG);overload;
    procedure ZDiff(Keys: array of string;block: Boolean;cmdReturn: TStringSliceCmdReturn);overload;
    procedure ZDiff(Keys: array of string;block: Boolean;cmdReturn: TStringSliceCmdReturnA);overload;
    procedure ZDiff(Keys: array of string;block: Boolean;cmdReturn: TStringSliceCmdReturnG);overload;

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
    property MinIdleConns: Byte read FMinIdleConns write SetMinIdleConns;
    property PoolTimeout: byte read FPoolTimeout write SetPoolTimeout;
    property IdleTimeout: byte read FIdleTimeout write SetIdleTimeout;
    property MaxConnAge: byte read FMaxConnAge write SetMaxConnAge;
    //集群属性
    property MaxRedirects: Byte read FMaxRedirects write SetMaxRedirects; //集群的最大重定向
    property ReadOnly: Boolean read FReadOnly write SetReadOnly;
    property RouteByLatency: Boolean read FRouteByLatency write SetRouteByLatency;
    property RouteRandomly: Boolean read FRouteRandomly write SetRouteRandomly;
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


  //扫描全部，扫描头      扫描头尾        扫描头中尾
  TScanStyle = (Scan_All,Scan_Head,Scan_HeadEnd,Scan_Segment);

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
    FPTTL: procedure(ClientData: Pointer;Key: Pchar; block: Boolean;
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
    FMGet: procedure(redisClient: Pointer; Keys: PChar; block: Boolean;
      resultCallBack: TstringSliceCmdCallback; params: Pointer); stdcall;

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
    FRandomKey: procedure(redisClient: Pointer;isByteRetur, block: Boolean;
      resultCallBack: TStringCmdCallback;params: Pointer); stdcall;

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
    FIncrByFloat: procedure(redisClient: Pointer; Key: PChar;increment: double; block: Boolean;
      resultCallBack: TfloatCmdCallBack; params: Pointer); stdcall;
    FHIncrByFloat: procedure(redisClient: Pointer; Key,field: PChar;increment: double; block: Boolean;
      resultCallBack: TfloatCmdCallBack; params: Pointer); stdcall;
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
      pivot, Value: PValueInterface; block: Boolean; resultCallBack: TIntCmdCallBack;
      params: Pointer); stdcall;
    FLInsertBefore: procedure(redisClient: Pointer; Key: PChar;
      pivot, Value: PValueInterface; block: Boolean; resultCallBack: TIntCmdCallBack;
      params: Pointer); stdcall;
    FLInsertAfter: procedure(redisClient: Pointer; Key: PChar;
      pivot, Value: PValueInterface; block: Boolean; resultCallBack: TIntCmdCallBack;
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


    FBinCanPrint: function(data: Pointer;dataLen: Integer;scanStyle: byte): Boolean;stdcall;
    FKeys: procedure(cliendData: Pointer;pattern: Pchar;block: Boolean;resultCallBack: TScanCmdCallback;params: Pointer);stdcall;
    FSort: procedure(clientData: Pointer;key: Pchar;sort: PRedisSort;block: Boolean;resultCallBack: TstringSliceCmdCallback;params: Pointer);stdcall;
    FSortStore: procedure(clientData: Pointer;key,storeKey: PChar;sort: PRedisSort;block: Boolean;resultCallBack: TIntCmdCallBack;params: Pointer);stdcall;
    FHKeys: procedure(clientData: Pointer;key: Pchar;block: Boolean;resultCallBack: TScanCmdCallback;params: Pointer);stdcall;
    FHVals: procedure(clientData: Pointer;key: PChar;block: Boolean;resultCallBack: TstringSliceCmdCallback;params: Pointer);stdcall;
    FHRandField: procedure(clientData: Pointer;key: Pchar;count: Integer;withValues,block: Boolean;resultCallBack: TstringSliceCmdCallback;params: Pointer);stdcall;
    FBRPop: procedure(clientData: Pointer;timeout: Integer;keys: PChar;block: Boolean;resultCallBack: TstringSliceCmdCallback;params: Pointer);stdcall;
    FBLPop: procedure(clientData: Pointer;timeout: Integer;keys: PChar;block: Boolean;resultCallBack: TstringSliceCmdCallback;params: Pointer);stdcall;
    FLPopCount: procedure(clientData: Pointer;key: Pchar;count: integer;block: Boolean;resultCallBack: TstringSliceCmdCallback;params: Pointer);stdcall;
    FLRange: procedure(clientData: Pointer;key: PChar;start,stop: Int64;block: Boolean;resultCallBack: TstringSliceCmdCallback;params: Pointer);stdcall;
    FZRange: procedure(clientData: Pointer;key: PChar;start,stop: Int64;block: Boolean;resultCallBack: TstringSliceCmdCallback;params: Pointer);stdcall;
    FZRevRange: procedure(clientData: Pointer;key: PChar;start,stop: Int64;block: Boolean;resultCallBack: TstringSliceCmdCallback;params: Pointer);stdcall;
    FZRangeByScore: procedure(clientData: Pointer;key: Pchar;opt: PRedisRangeBy;block: Boolean;resultCallBack: TstringSliceCmdCallback;params: Pointer);stdcall;
    FZRangeByLex: procedure(clientData: Pointer;key: Pchar;opt: PRedisRangeBy;block: Boolean;resultCallBack: TstringSliceCmdCallback;params: Pointer);stdcall;
    FSDiff: procedure(clientData: Pointer;keys: Pchar;block: Boolean;resultCallBack: TstringSliceCmdCallback;params: Pointer);stdcall;
    FSUnion: procedure(clientData: Pointer;keys: Pchar;block: Boolean;resultCallBack: TstringSliceCmdCallback;params: Pointer);stdcall;
    FSInter: procedure(clientData: Pointer;keys: Pchar;block: Boolean;resultCallBack: TstringSliceCmdCallback;params: Pointer);stdcall;
    FSMembers: procedure(clientData: Pointer;key: PChar;block: Boolean;resultCallBack: TstringSliceCmdCallback;params: Pointer);stdcall;
    FSPopN: procedure(clientData: Pointer;key: Pchar;count: Int64;block: Boolean;resultCallBack: TstringSliceCmdCallback;params: Pointer);stdcall;
    FSRandMemberN: procedure(clientData: Pointer;key: Pchar;count: Int64;block: Boolean;resultCallBack: TstringSliceCmdCallback;params: Pointer);stdcall;
    FZRevRangeByScore: procedure(clientData: Pointer;key: Pchar;opt: PRedisRangeBy;block: Boolean;resultCallBack: TstringSliceCmdCallback;params: Pointer);stdcall;
    FZRevRangeByLex: procedure(clientData: Pointer;key: Pchar;opt: PRedisRangeBy;block: Boolean;resultCallBack: TstringSliceCmdCallback;params: Pointer);stdcall;
    FZRandMember: procedure(ClientData: Pointer;key: Pchar;count: Integer;withScores,block: Boolean;resultCallBack: TstringSliceCmdCallback;params: Pointer);stdcall;
    FZDiff: procedure(clientData: Pointer;keys: Pchar;block: Boolean;resultCallBack: TstringSliceCmdCallback;params: Pointer);stdcall;
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
    procedure DoFLoatCmdMsg(floatResult: Pointer);
    procedure DoBoolCmdMsg(boolResult: Pointer);
    procedure DoPipeCmdMsg(pipeResult: Pointer);
    procedure DoStringSliceCmd(sliceResult: Pointer);
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
    function BinCanPrint(data: Pointer;dataLen: Integer;scanStyle: TScanStyle): Boolean;
  end;

implementation
uses cmdCallBack,redisPipeline;

procedure selectAndScanCmdResult(redisClient, params: Pointer; results: Pointer;ValuesLen: Integer;
  cursor: Int64; resultType: Byte); stdcall;
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
    case TScanResultType(resultType) of
    scanResultErr: scanCmdResult^.ErrMsg := StrPas(PChar(results));
    scanResultKeyValue:
      begin
      end;
    scanResultKeyStr:
      begin
        SetLength(scanCmdResult^.keys, 4);
        l := 0;
        p := results;
        repeat
          scanCmdResult^.keys[l] := DecodeTokenW(p, #13#10, #0, False);
          Inc(l);
          if (l = Length(scanCmdResult^.keys)) and (p^ <> #0) then
            SetLength(scanCmdResult^.keys, l + 4);
        until p^ = #0;
        SetLength(scanCmdResult^.keys, l);
      end;
    scanResultValue:
      begin
      end;
    end;

    scanCmdResult^.resultType := TScanResultType(resultType);
    scanCmdResult^.params := params;
    scanCmdResult^.cursor := cursor;
    client.RedisSdkManager.PostRedisMsg(MC_SelectScan, scanCmdResult);
  end
  else
  begin
    if PSelectCmdMethod(params)^.Method.Code <> nil then
    begin
      case TScanResultType(resultType) of
      scanResultErr:
        begin
          SetLength(keyArray, 0);
          errMsg := StrPas(PChar(results));
        end;
      scanResultKeyValue:
        begin
        end;
      scanResultKeyStr:
        begin
          errMsg := '';
          SetLength(keyArray, 4);
          l := 0;
          p := PChar(results);
          repeat
            keyArray[l] := DecodeTokenW(p, #13#10, #0, False);
            Inc(l);
            if (l = Length(keyArray)) and (p^ <> #0) then
              SetLength(keyArray, l + 4);
          until p^ = #0;
          SetLength(keyArray, l);
        end;
      end;
      if TScanResultType(resultType) in [scanResultErr,scanResultKeyStr] then
      begin
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

function TDxRedisSdkManager.BinCanPrint(data: Pointer; dataLen: Integer;
  scanStyle: TScanStyle): Boolean;
begin
  result := Assigned(FBinCanPrint) and FBinCanPrint(data,dataLen,ord(scanStyle));
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

procedure TDxRedisSdkManager.DoFLoatCmdMsg(floatResult: Pointer);
var
  iResult: PRedisIntResult;
begin
  iResult := floatResult;
  if PMethod(iResult^.params)^.Code <> nil then
  begin
    if PMethod(iResult^.params)^.Data = nil then
      TfloatCmdReturnG(PMethod(iResult^.params)^.Code)
        (iResult^.floatResult, iResult^.errMsg)
    else if PMethod(iResult^.params)^.Data = Pointer(-1) then
    begin
      TfloatCmdReturnA(PMethod(iResult^.params)^.Code)
        (iResult^.floatResult, iResult^.errMsg);
      PMethod(iResult^.params)^.Code := nil;
    end
    else
      TfloatCmdReturn(PMethod(iResult^.params)^)
        (iResult^.client, iResult^.floatResult, iResult^.errMsg);
  end;
  Dispose(iResult^.params);
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
  i,l: Integer;
  mnd: PScanMethod;
  keyArray: array of string;
begin
  sResult := scanResult;
  mnd := sResult^.params;
  if mnd^.Method.Code <> nil then
  begin
    case sResult^.resultType of
    scanResultErr:
      begin
        case mnd^.ScanResultType of
        scanResultKeyStr:
          begin
            if mnd^.Method.Data = nil then
              TRedisScanCmdReturnG(mnd^.Method.Code)(sResult^.keys, sResult^.cursor, sResult^.ErrMsg)
            else if mnd^.Method.Data = Pointer(-1) then
            begin
              TRedisScanCmdReturnA(mnd^.Method.Code)(sResult^.keys, sResult^.cursor, sResult^.ErrMsg);
              mnd^.Method.Code := nil;
            end
            else
              TRedisScanCmdReturn(mnd^.Method)(sResult^.client, sResult^.keys, sResult^.cursor, sResult^.ErrMsg);
          end;
        scanResultValue:
          begin
            if mnd^.Method.Data = nil then
              TRedisScanValueCmdReturnG(mnd^.Method.Code)(sResult^.values, sResult^.cursor, sResult^.ErrMsg)
            else if mnd^.Method.Data = Pointer(-1) then
            begin
              TRedisScanValueCmdReturnA(mnd^.Method.Code)(sResult^.values, sResult^.cursor, sResult^.ErrMsg);
              mnd^.Method.Code := nil;
            end
            else
              TRedisScanValueCmdReturn(mnd^.Method)(sResult^.client, sResult^.values, sResult^.cursor, sResult^.ErrMsg);
          end;
        scanResultScoreValue:
          begin
            if mnd^.Method.Data = nil then
              TRedisScanKScoreCmdReturnG(mnd^.Method.Code)(sResult^.ScoreValues, sResult^.cursor, sResult^.ErrMsg)
            else if mnd^.Method.Data = Pointer(-1) then
            begin
              TRedisScanKScoreCmdReturnA(mnd^.Method.Code)(sResult^.ScoreValues, sResult^.cursor, sResult^.ErrMsg);
              mnd^.Method.Code := nil;
            end
            else
              TRedisScanKScoreCmdReturn(mnd^.Method)(sResult^.client, sResult^.ScoreValues, sResult^.cursor, sResult^.ErrMsg);
          end;
        scanResultKeyValue:
          begin
            if mnd^.Method.Data = nil then
              TRedisScanKVCmdReturnG(mnd^.Method.Code)(sResult^.KeyValues, sResult^.cursor, sResult^.ErrMsg)
            else if mnd^.Method.Data = Pointer(-1) then
            begin
              TRedisScanKVCmdReturnA(mnd^.Method.Code)(sResult^.KeyValues, sResult^.cursor, sResult^.ErrMsg);
              mnd^.Method.Code := nil;
            end
            else
              TRedisScanKVCmdReturn(mnd^.Method)(sResult^.client, sResult^.KeyValues, sResult^.cursor, sResult^.ErrMsg);
          end;
        end;
      end;
    scanResultValue:
      begin
        l := Length(sresult^.values);
        case mnd^.ScanResultType of
        scanResultKeyStr:
          begin            
            SetLength(keyArray, l);
            for i := 0 to l - 1 do
              keyArray[i] := qstring.Utf8Decode(sresult^.Values[i].Value,sresult^.Values[i].ValueLen);
            if mnd^.Method.Data = nil then
              TRedisScanCmdReturnG(mnd^.Method.Code)(keyArray, sresult^.cursor, '')
            else if mnd^.Method.Data = Pointer(-1) then
            begin
              TRedisScanCmdReturnA(mnd^.Method.Code)(keyArray, sresult^.cursor, '');
              mnd^.Method.Code := nil;
            end
            else
              TRedisScanCmdReturn(mnd^.Method)(sresult^.client, keyArray, sresult^.cursor, '');
          end;
        scanResultValue:
          begin
            if mnd^.Method.Data = nil then
              TRedisScanValueCmdReturnG(mnd^.Method.Code)(sResult^.values, sresult^.cursor, '')
            else if mnd^.Method.Data = Pointer(-1) then
            begin
              TRedisScanValueCmdReturnA(mnd^.Method.Code)(sResult^.values, sresult^.cursor, '');
              mnd^.Method.Code := nil;
            end
            else
              TRedisScanValueCmdReturn(mnd^.Method)(sresult^.client, sResult^.values, sresult^.cursor, '');
          end;
        end;
        for i := 0 to l - 1 do
          FreeMemory(sresult^.Values[i].Value);
      end;  
    scanResultKeyStr:
      begin
        case mnd^.ScanResultType of
        scanResultValue:
          begin
          end;
        scanResultKeyStr:
          begin
            if mnd^.Method.Data = nil then
              TRedisScanCmdReturnG(mnd^.Method.Code)(sResult.keys, sresult^.cursor, '')
            else if mnd^.Method.Data = Pointer(-1) then
            begin
              TRedisScanCmdReturnA(mnd^.Method.Code)(sResult.keys, sresult^.cursor, '');
              mnd^.Method.Code := nil;
            end
            else
              TRedisScanCmdReturn(mnd^.Method)(sresult^.client, sResult.keys, sresult^.cursor, '');
          end;
        end;
      end;
    scanResultScoreValue:
      begin
        if mnd^.ScanResultType = scanResultScoreValue then
        begin
          if mnd^.Method.Data = nil then
            TRedisScanKScoreCmdReturnG(mnd^.Method.Code)(sResult^.ScoreValues, sResult^.cursor, '')
          else if mnd^.Method.Data = Pointer(-1) then
          begin
            TRedisScanKScoreCmdReturnA(mnd^.Method.Code)(sResult^.ScoreValues, sResult^.cursor, '');
            mnd^.Method.Code := nil;
          end
          else
            TRedisScanKScoreCmdReturn(mnd^.Method)(sResult^.client, sResult^.ScoreValues, sResult^.cursor, '');
        end;
      end;
    scanResultKeyValue:
      begin
        l := Length(sresult^.KeyValues);
        if mnd^.ScanResultType = scanResultKeyValue then
        begin
          if mnd^.Method.Data = nil then
            TRedisScanKVCmdReturnG(mnd^.Method.Code)(sResult^.KeyValues, sresult^.cursor, '')
          else if mnd^.Method.Data = Pointer(-1) then
          begin
            TRedisScanKVCmdReturnA(mnd^.Method.Code)(sResult^.KeyValues, sresult^.cursor, '');
            mnd^.Method.Code := nil;
          end
          else
            TRedisScanKVCmdReturn(mnd^.Method)(sresult^.client, sResult^.KeyValues, sresult^.cursor, '');
        end;
        for i := 0 to l - 1 do
          FreeMemory(sresult^.KeyValues[i].value.Value);
      end;  
    end;
  end;
  Dispose(sResult^.params);
end;

procedure TDxRedisSdkManager.DoSelectScanCmdMsg(scanResult: Pointer);
var
  sResult: PRedisScanResult;
begin
  sResult := scanResult;
  if PSelectCmdMethod(sResult^.params)^.Method.Code <> nil then
  begin
    if PSelectCmdMethod(sResult^.params)^.Method.Data = nil then
      TRedisSelectScanCmdReturnG(PSelectCmdMethod(sResult^.params)^.Method.Code)
        (PSelectCmdMethod(sResult^.params)^.DBIndex, sResult^.keys,
        sResult^.cursor, sResult^.errMsg)
    else if PSelectCmdMethod(sResult^.params)^.Method.Data = Pointer(-1) then
    begin
      TRedisSelectScanCmdReturnA(PSelectCmdMethod(sResult^.params)^.Method.Code)
        (PSelectCmdMethod(sResult^.params)^.DBIndex, sResult^.keys,
        sResult^.cursor, sResult^.errMsg);
      PSelectCmdMethod(sResult^.params)^.Method.Code := nil;
    end
    else
      TRedisSelectScanCmdReturn(PSelectCmdMethod(sResult^.params)^.Method)
        (sResult^.client, PSelectCmdMethod(sResult^.params)^.DBIndex, sResult^.keys,
        sResult^.cursor, sResult^.errMsg); 
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

procedure TDxRedisSdkManager.DoStringSliceCmd(sliceResult: Pointer);
var
  sliceCmdResult: PRedisStringSliceCmdResult;
  i: Integer;
begin
  sliceCmdResult := sliceResult;
  try
    try
      if PMethod(sliceCmdResult^.params)^.Code <> nil then
      begin
        if PMethod(sliceCmdResult^.params)^.Data = nil then
          TStringSliceCmdReturnG(PMethod(sliceCmdResult^.params)^.Code)(sliceCmdResult^.values,sliceCmdResult^.errMsg)
        else if PMethod(sliceCmdResult^.params)^.Data = Pointer(-1) then
        begin
          TStringSliceCmdReturnA(PMethod(sliceCmdResult^.params)^.Code)(sliceCmdResult^.values,sliceCmdResult^.errMsg);
          PMethod(sliceCmdResult^.params)^.Code := nil;
        end
        else
          TStringSliceCmdReturn(PMethod(sliceCmdResult^.params)^)(sliceCmdResult^.client,sliceCmdResult^.values,sliceCmdResult^.errMsg);
      end;
    except
    end;
  finally
    if Length(sliceCmdResult^.values) > 0 then
    begin
      for i := Low(sliceCmdResult^.values) to High(sliceCmdResult^.values) do
        FreeMemory(sliceCmdResult^.values[i].Value);
    end;
    Dispose(sliceCmdResult^.params);
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
    FPTTL := GetProcAddress(FDllHandle, 'PTTL');
    FSelect := GetProcAddress(FDllHandle, 'Select');
    FRename := GetProcAddress(FDllHandle, 'Rename');
    FMigrate := GetProcAddress(FDllHandle, 'Migrate');
    FRestore := GetProcAddress(FDllHandle, 'Restore');
    FRestoreReplace := GetProcAddress(FDllHandle, 'RestoreReplace');
    FType := GetProcAddress(FDllHandle, 'Type');
    FMSet := GetProcAddress(FDllHandle, 'MSet');
    FMGet := GetProcAddress(FDllHandle, 'MGet');
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
    FRandomKey := GetProcAddress(FDllHandle, 'RandomKey');
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
    FIncrByFloat := GetProcAddress(FDllHandle, 'IncrByFloat');
    FHIncrByFloat := GetProcAddress(FDllHandle, 'HIncrByFloat');
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

    FBinCanPrint := GetProcAddress(FDllHandle, 'BinCanPrint');
    FKeys := GetProcAddress(FDllHandle, 'Keys');
    FSort := GetProcAddress(FDllHandle, 'Sort');
    FSortStore := GetProcAddress(FDllHandle, 'SortStore');
    FHKeys := GetProcAddress(FDllHandle, 'HKeys');
    FHVals := GetProcAddress(FDllHandle, 'HVals');
    FHRandField := GetProcAddress(FDllHandle, 'HRandField');
    FBRPop := GetProcAddress(FDllHandle, 'BRPop');
    FBLPop := GetProcAddress(FDllHandle, 'BLPop');
    FLPopCount := GetProcAddress(FDllHandle, 'LPopCount');
    FLRange := GetProcAddress(FDllHandle, 'LRange');
    FSDiff := GetProcAddress(FDllHandle, 'SDiff');
    FSUnion := GetProcAddress(FDllHandle, 'SUnion');
    FSInter := GetProcAddress(FDllHandle, 'SInter');
    FSMembers := GetProcAddress(FDllHandle, 'SMembers');
    FSPopN := GetProcAddress(FDllHandle, 'SPopN');
    FSRandMemberN := GetProcAddress(FDllHandle, 'SRandMemberN');
    FZRange := GetProcAddress(FDllHandle, 'ZRange');
    FZRangeByScore := GetProcAddress(FDllHandle, 'ZRangeByScore');
    FZRangeByLex := GetProcAddress(FDllHandle, 'ZRangeByLex');
    FZRevRange := GetProcAddress(FDllHandle, 'ZRevRange');
    FZRevRangeByScore := GetProcAddress(FDllHandle, 'ZRevRangeByScore');
    FZRevRangeByLex := GetProcAddress(FDllHandle, 'ZRevRangeByLex');
    FZRandMember := GetProcAddress(FDllHandle, 'ZRandMember');
    FZDiff := GetProcAddress(FDllHandle, 'ZDiff');

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
          MC_FloatCmd: DoFLoatCmdMsg(AItem^.params);
          MC_BoolCmd: DoBoolCmdMsg(AItem^.params);
          MC_StringSliceCmd: DoStringSliceCmd(AItem^.params);
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
block: Boolean; scanCmdReturn: TRedisScanKScoreCmdReturn);
var
  Mnd: PScanMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.ScanResultType := scanResultScoreValue;
  Mnd^.Method := TMethod(scanCmdReturn);
  FRedisSdkManager.FZScan(FRedisClient, cursor, PChar(Key), PChar(match), count,
    block, scanCmdResult, Mnd);
end;

procedure TDxRedisClient.ZScan(cursor: UInt64; Key, match: string; count: Int64;
block: Boolean; scanCmdReturn: TRedisScanKScoreCmdReturnA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PScanMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisScanKScoreCmdReturnA(@TMethod(ATemp).Code)^ := scanCmdReturn;
  New(Mnd);
  Mnd^.ScanResultType := scanResultScoreValue;
  Mnd^.Method := TMethod(ATemp);
  FRedisSdkManager.FZScan(FRedisClient, cursor, PChar(Key), PChar(match), count,
    block, scanCmdResult, Mnd);
end;

procedure TDxRedisClient.ZScan(cursor: UInt64; Key, match: string; count: Int64;
block: Boolean; scanCmdReturn: TRedisScanKScoreCmdReturnG);
var
  Mnd: PScanMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.ScanResultType := scanResultScoreValue;
  Mnd^.Method.Data := nil;
  TRedisScanKScoreCmdReturnA(Mnd^.Method.Code) := scanCmdReturn;
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
    while (AtomicCmpExchange(FRunningCount, 0, 0) > 0) do
    begin
      Application.ProcessMessages;
      Sleep(0);
      if GetTickCount - tk > 3000 then
        Break;
    end;
  end;
end;

constructor TDxRedisClient.Create;
begin
  inherited;
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

procedure TDxRedisClient.IncrByFloat(Key: string; increment: Double;
  block: Boolean; floatCmdReturn: TfloatCmdReturn);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(floatCmdReturn);
  FRedisSdkManager.FIncrByFloat(FRedisClient, PChar(Key), increment, block,
    floatCmdResult, Mnd);
end;

procedure TDxRedisClient.IncrByFloat(Key: string; increment: Double;
  block: Boolean; floatCmdReturn: TfloatCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TfloatCmdReturn;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PfloatCmdReturnA(@TMethod(ATemp).Code)^ := floatCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FIncrByFloat(FRedisClient, PChar(Key), increment, block,
    floatCmdResult, Mnd);
end;

procedure TDxRedisClient.IncrByFloat(Key: string; increment: Double;
  block: Boolean; floatCmdReturn: TfloatCmdReturnG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TFloatCmdReturnA(Mnd^.Code) := floatCmdReturn;
  FRedisSdkManager.FIncrByFloat(FRedisClient, PChar(Key), increment, block,
    floatCmdResult, Mnd);
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
  //FPipeList.Free;
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
  l: Integer;
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
  l: Integer;
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
  l: Integer;
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
  l: Integer;
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
  l: Integer;
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
  l: Integer;
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
{var
  idx: Integer;}
begin
  //idx := FPipeList.IndexOf(pipeClient);
  if TDxPipeClient(pipeClient).PipeData <> nil then
  begin
    FRedisSdkManager.FFreePipeLiner(TDxPipeClient(pipeClient).PipeData);
    AtomicDecrement(FRunningCount, 1);
  end;
  {if idx <> -1 then
    FPipeList.Delete(idx);}
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
block: Boolean; scanCmdReturn: TRedisScanKVCmdReturn);
var
  Mnd: PScanMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Method := TMethod(scanCmdReturn);
  Mnd^.ScanResultType := scanResultKeyValue;
  FRedisSdkManager.FHScan(FRedisClient, cursor, PChar(Key), PChar(match), count,
    block, scanCmdResult, Mnd);
end;

procedure TDxRedisClient.HScan(cursor: UInt64; Key, match: string; count: Int64;
block: Boolean; scanCmdReturn: TRedisScanKVCmdReturnA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PScanMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisScanKVCmdReturnA(@TMethod(ATemp).Code)^ := scanCmdReturn;
  New(Mnd);
  Mnd^.ScanResultType := scanResultKeyValue;
  Mnd^.Method := TMethod(ATemp);
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
block: Boolean; scanCmdReturn: TRedisScanKVCmdReturnG);
var
  Mnd: PScanMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.ScanResultType := scanResultKeyValue;
  Mnd^.Method.Data := nil;
  TRedisScanKVCmdReturnA(Mnd^.Method.Code) := scanCmdReturn;
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
  l: Integer;
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
  l: Integer;
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
  l: Integer;
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
        section := section + #13 + sections[i];
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
        section := section + #13 + sections[i];
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
        section := section + #13 + sections[i];
    end;
  end;
  FRedisSdkManager.FInfo(FRedisClient, PChar(section), block,
    stringCmdResult, Mnd)
end;

procedure TDxRedisClient.InitRedisClient;
var
  singCfg: TRedisSingleCfg;
  Sentinel: TRedisSentinelCfg;
  ClusterCfg: TRedisClusterCfg;
  redisCfg: TRedisConfig;
begin
  redisCfg.ConStyle := FConStyle;
  redisCfg.ClientData := self;
  case FConStyle of
    RedisConSingle:
      begin
        FillChar(singCfg, Sizeof(singCfg), 0);
        singCfg.MaxRetries := FMaxRetry;
        singCfg.Addr := PChar(FAddress);
        singCfg.Username := PChar(FUserName);
        singCfg.Password := PChar(FPassword);
        singCfg.DBIndex := FDefaultDBIndex;
        singCfg.DialTimeout := FDialTimeout;
        singCfg.ReadTimeout := FReadTimeout;
        singCfg.WriteTimeout := FWriteTimeout;
        singCfg.MaxConnAge := FMaxConnAge;
        singCfg.PoolTimeout := FPoolTimeout;
        singCfg.IdleTimeout := FIdleTimeout;
        singCfg.MinIdleConns := FMinIdleConns;

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
        Sentinel.MaxConnAge := FMaxConnAge;
        Sentinel.PoolTimeout := FPoolTimeout;
        Sentinel.IdleTimeout := FIdleTimeout;
        Sentinel.MinIdleConns := FMinIdleConns;
        redisCfg.Data := @Sentinel;
        FRedisClient := FRedisSdkManager.FNewRedisConnection(@redisCfg);
      end;
    RedisConCluster:
      begin
        FillChar(ClusterCfg, Sizeof(ClusterCfg), 0);
        ClusterCfg.MaxRetries := FMaxRetry;
        ClusterCfg.MaxRedirects := FMaxRedirects;
        ClusterCfg.ReadOnly := FReadOnly;
        ClusterCfg.RouteByLatency := FRouteByLatency;
        ClusterCfg.RouteRandomly := FRouteRandomly;
        ClusterCfg.ClusterAddrs := PChar(FAddress);
        ClusterCfg.Username := PChar(FUserName);
        ClusterCfg.Password := PChar(FPassword);
        ClusterCfg.DialTimeout := FDialTimeout;
        ClusterCfg.ReadTimeout := FReadTimeout;
        ClusterCfg.WriteTimeout := FWriteTimeout;
        ClusterCfg.MaxConnAge := FMaxConnAge;
        ClusterCfg.PoolTimeout := FPoolTimeout;
        ClusterCfg.IdleTimeout := FIdleTimeout;
        ClusterCfg.MinIdleConns := FMinIdleConns;

        redisCfg.Data := @Sentinel;
        FRedisClient := FRedisSdkManager.FNewRedisConnection(@redisCfg);
      end;
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

procedure TDxRedisClient.MGet(keys: array of string; block: Boolean;
  CmdReturn: TStringSliceCmdReturn);
var
  Mnd: PMethod;
  keystr: string;
  i: Integer;
begin
  if Length(keys) = 0 then
    Exit;

  keystr := '';
  for i := Low(keys) to High(keys) do
  begin
    if keystr = '' then
      keystr := keys[i]
    else
      keystr := keystr + #13 + keys[i];
  end;
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  FRedisSdkManager.FMGet(FRedisClient, PChar(keystr),block, stringSliceCmdResult, Mnd);
end;

procedure TDxRedisClient.MGet(keys: array of string; block: Boolean;
  CmdReturn: TStringSliceCmdReturnA);
var
  Mnd: PMethod;
  keystr: string;
  i: Integer;
  ATemp: TMethod;
begin
  if Length(keys) = 0 then
    Exit;

  keystr := '';
  for i := Low(keys) to High(keys) do
  begin
    if keystr = '' then
      keystr := keys[i]
    else
      keystr := keystr + #13 + keys[i];
  end;
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PStringSliceCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FMGet(FRedisClient, PChar(keystr),block, stringSliceCmdResult, Mnd);
end;

procedure TDxRedisClient.MGet(keys: array of string; block: Boolean;
  CmdReturn: TStringSliceCmdReturnG);
var
  Mnd: PMethod;
  keystr: string;
  i: Integer;
begin
  if Length(keys) = 0 then
    Exit;

  keystr := '';
  for i := Low(keys) to High(keys) do
  begin
    if keystr = '' then
      keystr := keys[i]
    else
      keystr := keystr + #13 + keys[i];
  end;
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TStringSliceCmdReturnA(Mnd^.Code) := CmdReturn;
  FRedisSdkManager.FMGet(FRedisClient, PChar(keystr),block, stringSliceCmdResult, Mnd);
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
  l: Integer;
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
  l: Integer;
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
  l: Integer;
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
  if Result <> nil then
    AtomicIncrement(FRunningCount, 1);
  {if (Result <>  nil) and (FPipeList.IndexOf(Data) = -1) then
    FPipeList.Add(Data);}
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

procedure TDxRedisClient.PTTL(key: string; block: Boolean;
  intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  FRedisSdkManager.FPTTL(FRedisClient, PChar(Key),block, intCmdResult, Mnd);
end;

procedure TDxRedisClient.PTTL(key: string; block: Boolean;
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
  FRedisSdkManager.FPTTL(FRedisClient, PChar(Key),block, intCmdResult, Mnd);
end;

procedure TDxRedisClient.PTTL(key: string; block: Boolean;
  intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  FRedisSdkManager.FPTTL(FRedisClient, PChar(Key),block, intCmdResult, Mnd);
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

procedure TDxRedisClient.RandomKey(block: Boolean;
  stringCmdReturn: TRedisStringCmdReturn);
var
  Mnd: PStringCmdMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method := TMethod(stringCmdReturn);
  FRedisSdkManager.FRandomKey(FRedisClient, False, block,
    stringCmdResult, Mnd);
end;

procedure TDxRedisClient.RandomKey(block: Boolean;
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
  FRedisSdkManager.FRandomKey(FRedisClient, False, block,
    stringCmdResult, Mnd);
end;

procedure TDxRedisClient.RandomKey(block: Boolean;
  stringCmdReturn: TRedisStringCmdReturnG);
var
  Mnd: PStringCmdMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method.Data := nil;
  TRedisStringCmdReturnA(Mnd^.Method.Code) := stringCmdReturn;
  FRedisSdkManager.FRandomKey(FRedisClient, False, block,
    stringCmdResult, Mnd);
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
  Mnd: PScanMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Method := TMethod(scanCmdReturn);
  Mnd^.ScanResultType := scanResultKeyStr;
  FRedisSdkManager.FScan(FRedisClient, cursor, PChar(match), count, block,
    scanCmdResult, Mnd);
end;

procedure TDxRedisClient.Scan(cursor: UInt64; match: string; count: Int64;
block: Boolean; scanCmdReturn: TRedisScanCmdReturnA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PScanMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisScanCmdReturnA(@TMethod(ATemp).Code)^ := scanCmdReturn;
  New(Mnd);
  Mnd^.Method := TMethod(ATemp);
  Mnd^.ScanResultType := scanResultKeyStr;
  FRedisSdkManager.FScan(FRedisClient, cursor, PChar(match), count, block,
    scanCmdResult, Mnd);
end;

procedure TDxRedisClient.Scan(cursor: UInt64; match: string; count: Int64;
block: Boolean; scanCmdReturn: TRedisScanCmdReturnG);
var
  Mnd: PScanMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Method.Data := nil;
  Mnd^.ScanResultType := scanResultKeyStr;
  TRedisScanCmdReturnA(Mnd^.Method.Code) := scanCmdReturn;
  FRedisSdkManager.FScan(FRedisClient, cursor, PChar(match), count, block,
    scanCmdResult, Mnd);
end;

procedure TDxRedisClient.ScanType(cursor: UInt64; match, KeyType: string;
count: Int64; block: Boolean; scanCmdReturn: TRedisScanCmdReturn);
var
  Mnd: PScanMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Method := TMethod(scanCmdReturn);
  FRedisSdkManager.FScanType(FRedisClient, cursor, PChar(match), PChar(KeyType),
    count, block, scanCmdResult, Mnd);
end;

procedure TDxRedisClient.ScanType(cursor: UInt64; match, KeyType: string;
count: Int64; block: Boolean; scanCmdReturn: TRedisScanCmdReturnA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PScanMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisScanCmdReturnA(@TMethod(ATemp).Code)^ := scanCmdReturn;
  New(Mnd);
  Mnd^.Method := TMethod(ATemp);
  Mnd^.ScanResultType := scanResultKeyStr;
  FRedisSdkManager.FScanType(FRedisClient, cursor, PChar(match), PChar(KeyType),
    count, block, scanCmdResult, Mnd);
end;

procedure TDxRedisClient.ScanType(cursor: UInt64; match, KeyType: string;
count: Int64; block: Boolean; scanCmdReturn: TRedisScanCmdReturnG);
var
  Mnd: PScanMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.ScanResultType := scanResultKeyStr;
  Mnd^.Method.Data := nil;
  TRedisScanCmdReturnA(Mnd^.Method.Code) := scanCmdReturn;
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

procedure TDxRedisClient.SetIdleTimeout(const Value: byte);
begin
  FIdleTimeout := Value;
end;

procedure TDxRedisClient.SetMaxConnAge(const Value: byte);
begin
  FMaxConnAge := Value;
end;

procedure TDxRedisClient.SetMaxRedirects(const Value: Byte);
begin
  FMaxRedirects := Value;
end;

procedure TDxRedisClient.SetMaxRetry(const Value: Byte);
begin
  FMaxRetry := Value;
end;

procedure TDxRedisClient.SetMinIdleConns(const Value: Byte);
begin
  FMinIdleConns := Value;
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

procedure TDxRedisClient.SetPoolTimeout(const Value: byte);
begin
  FPoolTimeout := Value;
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

procedure TDxRedisClient.SetReadOnly(const Value: Boolean);
begin
  FReadOnly := Value;
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

procedure TDxRedisClient.SetRouteByLatency(const Value: Boolean);
begin
  FRouteByLatency := Value;
end;

procedure TDxRedisClient.SetRouteRandomly(const Value: Boolean);
begin
  FRouteRandomly := Value;
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
block: Boolean; scanCmdReturn: TRedisScanValueCmdReturn);
var
  Mnd: PScanMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.ScanResultType := scanResultValue;
  Mnd^.Method := TMethod(scanCmdReturn);
  FRedisSdkManager.FSScan(FRedisClient, cursor, PChar(Key), PChar(match), count,
    block, scanCmdResult, Mnd);
end;

procedure TDxRedisClient.SScan(cursor: UInt64; Key, match: string; count: Int64;
block: Boolean; scanCmdReturn: TRedisScanValueCmdReturnA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PScanMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisScanValueCmdReturnA(@TMethod(ATemp).Code)^ := scanCmdReturn;
  New(Mnd);
  Mnd^.ScanResultType := scanResultValue;
  Mnd^.Method := TMethod(ATemp);
  FRedisSdkManager.FSScan(FRedisClient, cursor, PChar(Key), PChar(match), count,
    block, scanCmdResult, Mnd);
end;

procedure TDxRedisClient.SScan(cursor: UInt64; Key, match: string; count: Int64;
block: Boolean; scanCmdReturn: TRedisScanValueCmdReturnG);
var
  Mnd: PScanMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Method.Data := nil;
  Mnd^.ScanResultType := scanResultValue;
  TRedisScanValueCmdReturnA(Mnd^.Method.Code) := scanCmdReturn;
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
  pivotv,v: TValueInterface;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  pivotv.ValueLen := 0;
  pivotv.Value := PChar(pivot);
  v.ValueLen := 0;
  v.Value := PChar(Value);
  FRedisSdkManager.FLInsert(FRedisClient, PChar(Key), before, @pivotv,@v, block, intCmdResult, Mnd);
end;

procedure TDxRedisClient.LInsert(Key: string; before: Boolean;
pivot, Value: string; block: Boolean; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
  pivotv,v: TValueInterface;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  pivotv.ValueLen := 0;
  pivotv.Value := PChar(pivot);
  v.ValueLen := 0;
  v.Value := PChar(Value);
  FRedisSdkManager.FLInsert(FRedisClient, PChar(Key), before, @pivotv,@v, block, intCmdResult, Mnd);
end;

procedure TDxRedisClient.LInsert(Key: string; before: Boolean;
pivot, Value: string; block: Boolean; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
  pivotv,v: TValueInterface;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  pivotv.ValueLen := 0;
  pivotv.Value := PChar(pivot);
  v.ValueLen := 0;
  v.Value := PChar(Value);
  FRedisSdkManager.FLInsert(FRedisClient, PChar(Key), before, @pivotv,@v, block, intCmdResult, Mnd);
end;

procedure TDxRedisClient.LInsertBefore(Key: string; pivot, Value: string;
block: Boolean; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
  pivotv,v: TValueInterface;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  pivotv.ValueLen := 0;
  pivotv.Value := PChar(pivot);
  v.ValueLen := 0;
  v.Value := PChar(Value);
  FRedisSdkManager.FLInsertBefore(FRedisClient, PChar(Key), @pivotv,@V, block, intCmdResult, Mnd);
end;

procedure TDxRedisClient.LInsertBefore(Key: string; pivot, Value: string;
block: Boolean; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
  pivotv,v: TValueInterface;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  pivotv.ValueLen := 0;
  pivotv.Value := PChar(pivot);
  v.ValueLen := 0;
  v.Value := PChar(Value);
  FRedisSdkManager.FLInsertBefore(FRedisClient, PChar(Key), @pivotv,@v, block, intCmdResult, Mnd);
end;

procedure TDxRedisClient.LInsertBefore(Key: string; pivot, Value: string;
block: Boolean; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
  pivotv,v: TValueInterface;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  pivotv.ValueLen := 0;
  pivotv.Value := PChar(pivot);
  v.ValueLen := 0;
  v.Value := PChar(Value);
  FRedisSdkManager.FLInsertBefore(FRedisClient, PChar(Key), @pivotv,@v, block, intCmdResult, Mnd);
end;

procedure TDxRedisClient.LInsertAfter(Key: string; pivot, Value: string;
block: Boolean; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
  pivotv,v: TValueInterface;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  pivotv.ValueLen := 0;
  pivotv.Value := PChar(pivot);
  v.ValueLen := 0;
  v.Value := PChar(Value);
  FRedisSdkManager.FLInsertAfter(FRedisClient, PChar(Key), @pivotv,@v, block, intCmdResult, Mnd);
end;

procedure TDxRedisClient.LInsertAfter(Key: string; pivot, Value: string;
block: Boolean; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
  pivotv,v: TValueInterface;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  pivotv.ValueLen := 0;
  pivotv.Value := PChar(pivot);
  v.ValueLen := 0;
  v.Value := PChar(Value);
  FRedisSdkManager.FLInsertAfter(FRedisClient, PChar(Key), @pivotv,@v, block, intCmdResult, Mnd);
end;

procedure TDxRedisClient.LInsert(Key: string; before: Boolean; pivot,
  Value: TValueInterface; block: Boolean; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  FRedisSdkManager.FLInsert(FRedisClient, PChar(Key), before, @pivot,@Value, block, intCmdResult, Mnd);
end;

procedure TDxRedisClient.LInsert(Key: string; before: Boolean; pivot,
  Value: TValueInterface; block: Boolean; intCmdReturn: TIntCmdReturnA);
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
  FRedisSdkManager.FLInsert(FRedisClient, PChar(Key), before, @pivot,@Value, block, intCmdResult, Mnd);
end;

procedure TDxRedisClient.LInsert(Key: string; before: Boolean; pivot,
  Value: TValueInterface; block: Boolean; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  FRedisSdkManager.FLInsert(FRedisClient, PChar(Key), before, @pivot,@Value, block, intCmdResult, Mnd);
end;

procedure TDxRedisClient.LInsertAfter(Key: string; pivot, Value: string;
block: Boolean; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
  pivotv,v: TValueInterface;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  pivotv.ValueLen := 0;
  pivotv.Value := PChar(pivot);
  v.ValueLen := 0;
  v.Value := PChar(Value);
  FRedisSdkManager.FLInsertAfter(FRedisClient, PChar(Key),@pivotv,@v, block, intCmdResult, Mnd);
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

procedure TDxRedisClient.HIncrByFloat(Key, field: string; increment: Double;
  block: Boolean; floatCmdReturn: TfloatCmdReturn);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(floatCmdReturn);
  FRedisSdkManager.FHIncrByFloat(FRedisClient, PChar(Key),PChar(field), increment, block,
    floatCmdResult, Mnd);
end;

procedure TDxRedisClient.HIncrByFloat(Key, field: string; increment: Double;
  block: Boolean; floatCmdReturn: TfloatCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TfloatCmdReturn;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PfloatCmdReturnA(@TMethod(ATemp).Code)^ := floatCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FHIncrByFloat(FRedisClient, PChar(Key),PChar(field), increment, block,
    floatCmdResult, Mnd);
end;

procedure TDxRedisClient.HIncrByFloat(Key, field: string; increment: Double;
  block: Boolean; floatCmdReturn: TfloatCmdReturnG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TFloatCmdReturnA(Mnd^.Code) := floatCmdReturn;
  FRedisSdkManager.FHIncrByFloat(FRedisClient, PChar(Key),PChar(field), increment, block,
    floatCmdResult, Mnd);
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


procedure TDxRedisClient.Keys(pattern: string; block: Boolean;
  cmdReturn: TRedisScanCmdReturn);
var
  Mnd: PScanMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Method := TMethod(cmdReturn);
  Mnd^.ScanResultType := scanResultKeyStr;
  FRedisSdkManager.FKeys(FRedisClient, PChar(pattern),block, scanCmdResult, Mnd);
end;

procedure TDxRedisClient.Keys(pattern: string; block: Boolean;
  cmdReturn: TRedisScanCmdReturnA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PScanMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisScanCmdReturnA(@TMethod(ATemp).Code)^ := cmdReturn;
  New(Mnd);
  Mnd^.Method := TMethod(ATemp);
  Mnd^.ScanResultType := scanResultKeyStr;
  FRedisSdkManager.FKeys(FRedisClient, PChar(pattern),block, scanCmdResult, Mnd);
end;

procedure TDxRedisClient.Keys(pattern: string; block: Boolean;
  cmdReturn: TRedisScanCmdReturnG);
var
  Mnd: PScanMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Method.Data := nil;
  Mnd^.ScanResultType := scanResultKeyStr;
  TRedisScanCmdReturnA(Mnd^.Method.Code) := cmdReturn;
  FRedisSdkManager.FKeys(FRedisClient, PChar(pattern),block, scanCmdResult, Mnd);
end;

procedure TDxRedisClient.Sort(key: string; sort: TRedisSort; block: Boolean;
  cmdReturn: TStringSliceCmdReturn);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  FRedisSdkManager.FSort(FRedisClient, PChar(key),@sort,block, stringSliceCmdResult, Mnd);
end;

procedure TDxRedisClient.Sort(key: string; sort: TRedisSort; block: Boolean;
  cmdReturn: TStringSliceCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TStringSliceCmdReturn;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PStringSliceCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FSort(FRedisClient, PChar(key),@sort,block, stringSliceCmdResult, Mnd);
end;

procedure TDxRedisClient.Sort(key: string; sort: TRedisSort; block: Boolean;
  cmdReturn: TStringSliceCmdReturnG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TStringSliceCmdReturnA(Mnd^.Code) := CmdReturn;
  FRedisSdkManager.FSort(FRedisClient, PChar(key),@sort,block, stringSliceCmdResult, Mnd);
end;

procedure TDxRedisClient.SortStore(key,storeKey: string; sort: TRedisSort; block: Boolean;
  cmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  FRedisSdkManager.FSortStore(FRedisClient, PChar(key),PChar(storeKey),@sort,block, intCmdResult, Mnd);
end;

procedure TDxRedisClient.SortStore(key,storeKey: string; sort: TRedisSort; block: Boolean;
  cmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FSortStore(FRedisClient, PChar(key),PChar(storeKey),@sort,block, intCmdResult, Mnd);
end;

procedure TDxRedisClient.SortStore(key,storeKey: string; sort: TRedisSort; block: Boolean;
  cmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := CmdReturn;
  FRedisSdkManager.FSortStore(FRedisClient, PChar(key),PChar(storeKey),@sort,block, intCmdResult, Mnd);
end;

procedure TDxRedisClient.HKeys(key: string; block: Boolean;
  cmdReturn: TRedisScanCmdReturn);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  FRedisSdkManager.FHKeys(FRedisClient, PChar(key),block, scanCmdResult, Mnd);
end;

procedure TDxRedisClient.HKeys(key: string; block: Boolean;
  cmdReturn: TRedisScanCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisScanCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FHKeys(FRedisClient, PChar(key),block, scanCmdResult, Mnd);
end;

procedure TDxRedisClient.HKeys(key: string; block: Boolean;
  cmdReturn: TRedisScanCmdReturnG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TRedisScanCmdReturnA(Mnd^.Code) := CmdReturn;
  FRedisSdkManager.FHKeys(FRedisClient, PChar(key),block, scanCmdResult, Mnd);
end;

procedure TDxRedisClient.HVals(key: string;block: Boolean;cmdReturn: TStringSliceCmdReturn);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  FRedisSdkManager.FHVals(FRedisClient, PChar(key),block, stringSliceCmdResult, Mnd);
end;

procedure TDxRedisClient.HVals(key: string;block: Boolean;cmdReturn: TStringSliceCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PStringSliceCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FHVals(FRedisClient, PChar(key),block, stringSliceCmdResult, Mnd);
end;

procedure TDxRedisClient.HVals(key: string;block: Boolean;cmdReturn: TStringSliceCmdReturnG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TStringSliceCmdReturnA(Mnd^.Code) := CmdReturn;
  FRedisSdkManager.FHVals(FRedisClient, PChar(key),block, stringSliceCmdResult, Mnd);
end;

procedure TDxRedisClient.HRandField(key: string;count: integer;withValues,block: Boolean;cmdReturn: TStringSliceCmdReturn);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  FRedisSdkManager.FHRandField(FRedisClient, PChar(key),count,withValues,block, stringSliceCmdResult, Mnd);
end;

procedure TDxRedisClient.HRandField(key: string;count: integer;withValues,block: Boolean;cmdReturn: TStringSliceCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PStringSliceCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FHRandField(FRedisClient, PChar(key),count,withValues,block, stringSliceCmdResult, Mnd);
end;

procedure TDxRedisClient.HRandField(key: string;count: integer;withValues,block: Boolean;cmdReturn: TStringSliceCmdReturnG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TStringSliceCmdReturnA(Mnd^.Code) := CmdReturn;
  FRedisSdkManager.FHRandField(FRedisClient, PChar(key),count,withValues,block, stringSliceCmdResult, Mnd);
end;

procedure TDxRedisClient.BRPop(timeout: integer;Keys: array of string;block: Boolean;cmdReturn: TStringSliceCmdReturn);
var
  Mnd: PMethod;
  KeyStr: string;
  i: Integer;
begin
  if Length(Keys) = 0 then
    Exit;

  for i := Low(Keys) to High(Keys) do
  begin
    if i = Low(Keys) then
      KeyStr := Keys[i]
    else KeyStr := KeyStr + #10 + Keys[i];
  end;

  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  FRedisSdkManager.FBRPop(FRedisClient,timeout,PChar(KeyStr),block, stringSliceCmdResult, Mnd);
end;

procedure TDxRedisClient.BRPop(timeout: integer;Keys: array of string;block: Boolean;cmdReturn: TStringSliceCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
  KeyStr: string;
  i: Integer;
begin
  if Length(Keys) = 0 then
    Exit;

  for i := Low(Keys) to High(Keys) do
  begin
    if i = Low(Keys) then
      KeyStr := Keys[i]
    else KeyStr := KeyStr + #10 + Keys[i];
  end;
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PStringSliceCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FBRPop(FRedisClient,timeout,PChar(KeyStr),block, stringSliceCmdResult, Mnd);
end;

procedure TDxRedisClient.BRPop(timeout: integer;Keys: array of string;block: Boolean;cmdReturn: TStringSliceCmdReturnG);
var
  Mnd: PMethod;
  KeyStr: string;
  i: Integer;
begin
  if Length(Keys) = 0 then
    Exit;

  for i := Low(Keys) to High(Keys) do
  begin
    if i = Low(Keys) then
      KeyStr := Keys[i]
    else KeyStr := KeyStr + #10 + Keys[i];
  end;
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TStringSliceCmdReturnA(Mnd^.Code) := CmdReturn;
  FRedisSdkManager.FBRPop(FRedisClient,timeout,PChar(KeyStr),block, stringSliceCmdResult, Mnd);
end;

procedure TDxRedisClient.BLPop(timeout: integer;Keys: array of string;block: Boolean;cmdReturn: TStringSliceCmdReturn);
var
  Mnd: PMethod;
  KeyStr: string;
  i: Integer;
begin
  if Length(Keys) = 0 then
    Exit;

  for i := Low(Keys) to High(Keys) do
  begin
    if i = Low(Keys) then
      KeyStr := Keys[i]
    else KeyStr := KeyStr + #10 + Keys[i];
  end;

  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  FRedisSdkManager.FBLPop(FRedisClient,timeout,PChar(KeyStr),block, stringSliceCmdResult, Mnd);
end;

procedure TDxRedisClient.BLPop(timeout: integer;Keys: array of string;block: Boolean;cmdReturn: TStringSliceCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
  KeyStr: string;
  i: Integer;
begin
  if Length(Keys) = 0 then
    Exit;

  for i := Low(Keys) to High(Keys) do
  begin
    if i = Low(Keys) then
      KeyStr := Keys[i]
    else KeyStr := KeyStr + #10 + Keys[i];
  end;
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PStringSliceCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FBLPop(FRedisClient,timeout,PChar(KeyStr),block, stringSliceCmdResult, Mnd);
end;

procedure TDxRedisClient.BLPop(timeout: integer;Keys: array of string;block: Boolean;cmdReturn: TStringSliceCmdReturnG);
var
  Mnd: PMethod;
  KeyStr: string;
  i: Integer;
begin
  if Length(Keys) = 0 then
    Exit;

  for i := Low(Keys) to High(Keys) do
  begin
    if i = Low(Keys) then
      KeyStr := Keys[i]
    else KeyStr := KeyStr + #10 + Keys[i];
  end;
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TStringSliceCmdReturnA(Mnd^.Code) := CmdReturn;
  FRedisSdkManager.FBLPop(FRedisClient,timeout,PChar(KeyStr),block, stringSliceCmdResult, Mnd);
end;

procedure TDxRedisClient.LPopCount(key: string;count: integer;block: Boolean;cmdReturn: TStringSliceCmdReturn);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  FRedisSdkManager.FLPopCount(FRedisClient, PChar(key),count,block, stringSliceCmdResult, Mnd);
end;

procedure TDxRedisClient.LPopCount(key: string;count: integer;block: Boolean;cmdReturn: TStringSliceCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PStringSliceCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FLPopCount(FRedisClient, PChar(key),count,block, stringSliceCmdResult, Mnd);
end;

procedure TDxRedisClient.LPopCount(key: string;count: integer;block: Boolean;cmdReturn: TStringSliceCmdReturnG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TStringSliceCmdReturnA(Mnd^.Code) := CmdReturn;
  FRedisSdkManager.FLPopCount(FRedisClient, PChar(key),count,block, stringSliceCmdResult, Mnd);
end;

procedure TDxRedisClient.LRange(key: string;start,stop: int64;block: Boolean;cmdReturn: TStringSliceCmdReturn);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  FRedisSdkManager.FLRange(FRedisClient, PChar(key),start,stop,block, stringSliceCmdResult, Mnd);
end;

procedure TDxRedisClient.LRange(key: string;start,stop: int64;block: Boolean;cmdReturn: TStringSliceCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PStringSliceCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FLRange(FRedisClient, PChar(key),start,stop,block, stringSliceCmdResult, Mnd);
end;

procedure TDxRedisClient.LRange(key: string;start,stop: int64;block: Boolean;cmdReturn: TStringSliceCmdReturnG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TStringSliceCmdReturnA(Mnd^.Code) := CmdReturn;
  FRedisSdkManager.FLRange(FRedisClient, PChar(key),start,stop,block, stringSliceCmdResult, Mnd);
end;

procedure TDxRedisClient.ZRange(key: string;start,stop: int64;block: Boolean;cmdReturn: TStringSliceCmdReturn);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  FRedisSdkManager.FZRange(FRedisClient, PChar(key),start,stop,block, stringSliceCmdResult, Mnd);
end;

procedure TDxRedisClient.ZRange(key: string;start,stop: int64;block: Boolean;cmdReturn: TStringSliceCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PStringSliceCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FZRange(FRedisClient, PChar(key),start,stop,block, stringSliceCmdResult, Mnd);
end;

procedure TDxRedisClient.ZRange(key: string;start,stop: int64;block: Boolean;cmdReturn: TStringSliceCmdReturnG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TStringSliceCmdReturnA(Mnd^.Code) := CmdReturn;
  FRedisSdkManager.FZRange(FRedisClient, PChar(key),start,stop,block, stringSliceCmdResult, Mnd);
end;

procedure TDxRedisClient.ZRevRange(key: string;start,stop: int64;block: Boolean;cmdReturn: TStringSliceCmdReturn);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  FRedisSdkManager.FZRevRange(FRedisClient, PChar(key),start,stop,block, stringSliceCmdResult, Mnd);
end;

procedure TDxRedisClient.ZRevRange(key: string;start,stop: int64;block: Boolean;cmdReturn: TStringSliceCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PStringSliceCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FZRevRange(FRedisClient, PChar(key),start,stop,block, stringSliceCmdResult, Mnd);
end;

procedure TDxRedisClient.ZRevRange(key: string;start,stop: int64;block: Boolean;cmdReturn: TStringSliceCmdReturnG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TStringSliceCmdReturnA(Mnd^.Code) := CmdReturn;
  FRedisSdkManager.FZRevRange(FRedisClient, PChar(key),start,stop,block, stringSliceCmdResult, Mnd);
end;

procedure TDxRedisClient.ZRangeByScore(key: string;opt: TRedisRangeBy;block:Boolean;cmdReturn: TStringSliceCmdReturn);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  FRedisSdkManager.FZRangeByScore(FRedisClient, PChar(key),@opt,block, stringSliceCmdResult, Mnd);
end;

procedure TDxRedisClient.ZRangeByScore(key: string;opt: TRedisRangeBy;block:Boolean;cmdReturn: TStringSliceCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PStringSliceCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FZRangeByScore(FRedisClient, PChar(key),@opt,block, stringSliceCmdResult, Mnd);
end;

procedure TDxRedisClient.ZRangeByScore(key: string;opt: TRedisRangeBy;block:Boolean;cmdReturn: TStringSliceCmdReturnG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TStringSliceCmdReturnA(Mnd^.Code) := CmdReturn;
  FRedisSdkManager.FZRangeByScore(FRedisClient, PChar(key),@opt,block, stringSliceCmdResult, Mnd);
end;

procedure TDxRedisClient.ZRangeByLex(key: string;opt: TRedisRangeBy;block:Boolean;cmdReturn: TStringSliceCmdReturn);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  FRedisSdkManager.FZRangeByLex(FRedisClient, PChar(key),@opt,block, stringSliceCmdResult, Mnd);
end;

procedure TDxRedisClient.ZRangeByLex(key: string;opt: TRedisRangeBy;block:Boolean;cmdReturn: TStringSliceCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PStringSliceCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FZRangeByLex(FRedisClient, PChar(key),@opt,block, stringSliceCmdResult, Mnd);
end;

procedure TDxRedisClient.ZRangeByLex(key: string;opt: TRedisRangeBy;block:Boolean;cmdReturn: TStringSliceCmdReturnG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TStringSliceCmdReturnA(Mnd^.Code) := CmdReturn;
  FRedisSdkManager.FZRangeByLex(FRedisClient, PChar(key),@opt,block, stringSliceCmdResult, Mnd);
end;


procedure TDxRedisClient.SDiff(Keys: array of string;block: Boolean;cmdReturn: TStringSliceCmdReturn);
var
  Mnd: PMethod;
  KeyStr: string;
  i: Integer;
begin
  if Length(Keys) = 0 then
    Exit;

  for i := Low(Keys) to High(Keys) do
  begin
    if i = Low(Keys) then
      KeyStr := Keys[i]
    else KeyStr := KeyStr + #10 + Keys[i];
  end;

  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  FRedisSdkManager.FSDiff(FRedisClient,PChar(KeyStr),block, stringSliceCmdResult, Mnd);
end;

procedure TDxRedisClient.SDiff(Keys: array of string;block: Boolean;cmdReturn: TStringSliceCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
  KeyStr: string;
  i: Integer;
begin
  if Length(Keys) = 0 then
    Exit;

  for i := Low(Keys) to High(Keys) do
  begin
    if i = Low(Keys) then
      KeyStr := Keys[i]
    else KeyStr := KeyStr + #10 + Keys[i];
  end;
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PStringSliceCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FSDiff(FRedisClient,PChar(KeyStr),block, stringSliceCmdResult, Mnd);
end;

procedure TDxRedisClient.SDiff(Keys: array of string;block: Boolean;cmdReturn: TStringSliceCmdReturnG);
var
  Mnd: PMethod;
  KeyStr: string;
  i: Integer;
begin
  if Length(Keys) = 0 then
    Exit;

  for i := Low(Keys) to High(Keys) do
  begin
    if i = Low(Keys) then
      KeyStr := Keys[i]
    else KeyStr := KeyStr + #10 + Keys[i];
  end;
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TStringSliceCmdReturnA(Mnd^.Code) := CmdReturn;
  FRedisSdkManager.FSDiff(FRedisClient,PChar(KeyStr),block, stringSliceCmdResult, Mnd);
end;


procedure TDxRedisClient.SUnion(Keys: array of string;block: Boolean;cmdReturn: TStringSliceCmdReturn);
var
  Mnd: PMethod;
  KeyStr: string;
  i: Integer;
begin
  if Length(Keys) = 0 then
    Exit;

  for i := Low(Keys) to High(Keys) do
  begin
    if i = Low(Keys) then
      KeyStr := Keys[i]
    else KeyStr := KeyStr + #10 + Keys[i];
  end;

  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  FRedisSdkManager.FSUnion(FRedisClient,PChar(KeyStr),block, stringSliceCmdResult, Mnd);
end;

procedure TDxRedisClient.SUnion(Keys: array of string;block: Boolean;cmdReturn: TStringSliceCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
  KeyStr: string;
  i: Integer;
begin
  if Length(Keys) = 0 then
    Exit;

  for i := Low(Keys) to High(Keys) do
  begin
    if i = Low(Keys) then
      KeyStr := Keys[i]
    else KeyStr := KeyStr + #10 + Keys[i];
  end;
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PStringSliceCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FSUnion(FRedisClient,PChar(KeyStr),block, stringSliceCmdResult, Mnd);
end;

procedure TDxRedisClient.SUnion(Keys: array of string;block: Boolean;cmdReturn: TStringSliceCmdReturnG);
var
  Mnd: PMethod;
  KeyStr: string;
  i: Integer;
begin
  if Length(Keys) = 0 then
    Exit;

  for i := Low(Keys) to High(Keys) do
  begin
    if i = Low(Keys) then
      KeyStr := Keys[i]
    else KeyStr := KeyStr + #10 + Keys[i];
  end;
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TStringSliceCmdReturnA(Mnd^.Code) := CmdReturn;
  FRedisSdkManager.FSUnion(FRedisClient,PChar(KeyStr),block, stringSliceCmdResult, Mnd);
end;

procedure TDxRedisClient.SInter(Keys: array of string;block: Boolean;cmdReturn: TStringSliceCmdReturn);
var
  Mnd: PMethod;
  KeyStr: string;
  i: Integer;
begin
  if Length(Keys) = 0 then
    Exit;

  for i := Low(Keys) to High(Keys) do
  begin
    if i = Low(Keys) then
      KeyStr := Keys[i]
    else KeyStr := KeyStr + #10 + Keys[i];
  end;

  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  FRedisSdkManager.FSInter(FRedisClient,PChar(KeyStr),block, stringSliceCmdResult, Mnd);
end;

procedure TDxRedisClient.SInter(Keys: array of string;block: Boolean;cmdReturn: TStringSliceCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
  KeyStr: string;
  i: Integer;
begin
  if Length(Keys) = 0 then
    Exit;

  for i := Low(Keys) to High(Keys) do
  begin
    if i = Low(Keys) then
      KeyStr := Keys[i]
    else KeyStr := KeyStr + #10 + Keys[i];
  end;
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PStringSliceCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FSInter(FRedisClient,PChar(KeyStr),block, stringSliceCmdResult, Mnd);
end;

procedure TDxRedisClient.SInter(Keys: array of string;block: Boolean;cmdReturn: TStringSliceCmdReturnG);
var
  Mnd: PMethod;
  KeyStr: string;
  i: Integer;
begin
  if Length(Keys) = 0 then
    Exit;

  for i := Low(Keys) to High(Keys) do
  begin
    if i = Low(Keys) then
      KeyStr := Keys[i]
    else KeyStr := KeyStr + #10 + Keys[i];
  end;
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TStringSliceCmdReturnA(Mnd^.Code) := CmdReturn;
  FRedisSdkManager.FSInter(FRedisClient,PChar(KeyStr),block, stringSliceCmdResult, Mnd);
end;


procedure TDxRedisClient.SMembers(key: string;block: Boolean;cmdReturn: TStringSliceCmdReturn);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  FRedisSdkManager.FSMembers(FRedisClient, PChar(key),block, stringSliceCmdResult, Mnd);
end;

procedure TDxRedisClient.SMembers(key: string;block: Boolean;cmdReturn: TStringSliceCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PStringSliceCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FSMembers(FRedisClient, PChar(key),block, stringSliceCmdResult, Mnd);
end;

procedure TDxRedisClient.SMembers(key: string;block: Boolean;cmdReturn: TStringSliceCmdReturnG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TStringSliceCmdReturnA(Mnd^.Code) := CmdReturn;
  FRedisSdkManager.FSMembers(FRedisClient, PChar(key),block, stringSliceCmdResult, Mnd);
end;

procedure TDxRedisClient.SPopN(key: string;count: Int64; block: Boolean;cmdReturn: TStringSliceCmdReturn);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  FRedisSdkManager.FSPopN(FRedisClient, PChar(key),count,block, stringSliceCmdResult, Mnd);
end;

procedure TDxRedisClient.SPopN(key: string;count: Int64; block: Boolean;cmdReturn: TStringSliceCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PStringSliceCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FSPopN(FRedisClient, PChar(key),count,block, stringSliceCmdResult, Mnd);
end;

procedure TDxRedisClient.SPopN(key: string;count: Int64; block: Boolean;cmdReturn: TStringSliceCmdReturnG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TStringSliceCmdReturnA(Mnd^.Code) := CmdReturn;
  FRedisSdkManager.FSPopN(FRedisClient, PChar(key),count,block, stringSliceCmdResult, Mnd);
end;

procedure TDxRedisClient.SRandMemberN(key: string;count: Int64; block: Boolean;cmdReturn: TStringSliceCmdReturn);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  FRedisSdkManager.FSRandMemberN(FRedisClient, PChar(key),count,block, stringSliceCmdResult, Mnd);
end;

procedure TDxRedisClient.SRandMemberN(key: string;count: Int64; block: Boolean;cmdReturn: TStringSliceCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PStringSliceCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FSRandMemberN(FRedisClient, PChar(key),count,block, stringSliceCmdResult, Mnd);
end;

procedure TDxRedisClient.SRandMemberN(key: string;count: Int64; block: Boolean;cmdReturn: TStringSliceCmdReturnG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TStringSliceCmdReturnA(Mnd^.Code) := CmdReturn;
  FRedisSdkManager.FSRandMemberN(FRedisClient, PChar(key),count,block, stringSliceCmdResult, Mnd);
end;

procedure TDxRedisClient.ZRevRangeByScore(key: string;opt: TRedisRangeBy;block:Boolean;cmdReturn: TStringSliceCmdReturn);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  FRedisSdkManager.FZRevRangeByScore(FRedisClient, PChar(key),@opt,block, stringSliceCmdResult, Mnd);
end;

procedure TDxRedisClient.ZRevRangeByScore(key: string;opt: TRedisRangeBy;block:Boolean;cmdReturn: TStringSliceCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PStringSliceCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FZRevRangeByScore(FRedisClient, PChar(key),@opt,block, stringSliceCmdResult, Mnd);
end;

procedure TDxRedisClient.ZRevRangeByScore(key: string;opt: TRedisRangeBy;block:Boolean;cmdReturn: TStringSliceCmdReturnG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TStringSliceCmdReturnA(Mnd^.Code) := CmdReturn;
  FRedisSdkManager.FZRevRangeByScore(FRedisClient, PChar(key),@opt,block, stringSliceCmdResult, Mnd);
end;

procedure TDxRedisClient.ZRevRangeByLex(key: string;opt: TRedisRangeBy;block:Boolean;cmdReturn: TStringSliceCmdReturn);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  FRedisSdkManager.FZRevRangeByLex(FRedisClient, PChar(key),@opt,block, stringSliceCmdResult, Mnd);
end;

procedure TDxRedisClient.ZRevRangeByLex(key: string;opt: TRedisRangeBy;block:Boolean;cmdReturn: TStringSliceCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PStringSliceCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FZRevRangeByLex(FRedisClient, PChar(key),@opt,block, stringSliceCmdResult, Mnd);
end;

procedure TDxRedisClient.ZRevRangeByLex(key: string;opt: TRedisRangeBy;block:Boolean;cmdReturn: TStringSliceCmdReturnG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TStringSliceCmdReturnA(Mnd^.Code) := CmdReturn;
  FRedisSdkManager.FZRevRangeByLex(FRedisClient, PChar(key),@opt,block, stringSliceCmdResult, Mnd);
end;


procedure TDxRedisClient.ZRandMember(key: string;count: Integer; withScores,block: Boolean;cmdReturn: TStringSliceCmdReturn);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  FRedisSdkManager.FZRandMember(FRedisClient, PChar(key),count,withScores,block, stringSliceCmdResult, Mnd);
end;

procedure TDxRedisClient.ZRandMember(key: string;count: Integer; withScores,block: Boolean;cmdReturn: TStringSliceCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PStringSliceCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FZRandMember(FRedisClient, PChar(key),count,withScores,block, stringSliceCmdResult, Mnd);
end;

procedure TDxRedisClient.ZRandMember(key: string;count: Integer; withScores,block: Boolean;cmdReturn: TStringSliceCmdReturnG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TStringSliceCmdReturnA(Mnd^.Code) := CmdReturn;
  FRedisSdkManager.FZRandMember(FRedisClient, PChar(key),count,withScores,block, stringSliceCmdResult, Mnd);
end;

procedure TDxRedisClient.ZDiff(Keys: array of string;block: Boolean;cmdReturn: TStringSliceCmdReturn);
var
  Mnd: PMethod;
  KeyStr: string;
  i: Integer;
begin
  if Length(Keys) = 0 then
    Exit;

  for i := Low(Keys) to High(Keys) do
  begin
    if i = Low(Keys) then
      KeyStr := Keys[i]
    else KeyStr := KeyStr + #10 + Keys[i];
  end;

  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  FRedisSdkManager.FZDiff(FRedisClient,PChar(KeyStr),block, stringSliceCmdResult, Mnd);
end;

procedure TDxRedisClient.ZDiff(Keys: array of string;block: Boolean;cmdReturn: TStringSliceCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
  KeyStr: string;
  i: Integer;
begin
  if Length(Keys) = 0 then
    Exit;

  for i := Low(Keys) to High(Keys) do
  begin
    if i = Low(Keys) then
      KeyStr := Keys[i]
    else KeyStr := KeyStr + #10 + Keys[i];
  end;
  AtomicIncrement(FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PStringSliceCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  FRedisSdkManager.FZDiff(FRedisClient,PChar(KeyStr),block, stringSliceCmdResult, Mnd);
end;

procedure TDxRedisClient.ZDiff(Keys: array of string;block: Boolean;cmdReturn: TStringSliceCmdReturnG);
var
  Mnd: PMethod;
  KeyStr: string;
  i: Integer;
begin
  if Length(Keys) = 0 then
    Exit;

  for i := Low(Keys) to High(Keys) do
  begin
    if i = Low(Keys) then
      KeyStr := Keys[i]
    else KeyStr := KeyStr + #10 + Keys[i];
  end;
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TStringSliceCmdReturnA(Mnd^.Code) := CmdReturn;
  FRedisSdkManager.FZDiff(FRedisClient,PChar(KeyStr),block, stringSliceCmdResult, Mnd);
end;

procedure TDxRedisClient.LInsertBefore(Key: string; pivot,
  Value: TValueInterface; block: Boolean; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  FRedisSdkManager.FLInsertBefore(FRedisClient, PChar(Key), @pivot,@Value, block, intCmdResult, Mnd);
end;

procedure TDxRedisClient.LInsertBefore(Key: string; pivot,
  Value: TValueInterface; block: Boolean; intCmdReturn: TIntCmdReturnA);
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
  FRedisSdkManager.FLInsertBefore(FRedisClient, PChar(Key), @pivot,@Value, block, intCmdResult, Mnd);
end;

procedure TDxRedisClient.LInsertBefore(Key: string; pivot,
  Value: TValueInterface; block: Boolean; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  FRedisSdkManager.FLInsertBefore(FRedisClient, PChar(Key), @pivot,@Value, block, intCmdResult, Mnd);
end;

procedure TDxRedisClient.LInsertAfter(Key: string; pivot,
  Value: TValueInterface; block: Boolean; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  FRedisSdkManager.FLInsertAfter(FRedisClient, PChar(Key), @pivot,@Value, block, intCmdResult, Mnd);
end;

procedure TDxRedisClient.LInsertAfter(Key: string; pivot,
  Value: TValueInterface; block: Boolean; intCmdReturn: TIntCmdReturnA);
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
  FRedisSdkManager.FLInsertAfter(FRedisClient, PChar(Key), @pivot,@Value, block, intCmdResult, Mnd);
end;

procedure TDxRedisClient.LInsertAfter(Key: string; pivot,
  Value: TValueInterface; block: Boolean; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  FRedisSdkManager.FLInsertAfter(FRedisClient, PChar(Key),@pivot,@Value, block, intCmdResult, Mnd);
end;

end.
