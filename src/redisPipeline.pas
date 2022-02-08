unit redisPipeline;

interface

uses
  RedisSDK;

type
  TDxPipeClient = class
  private
    FOwner: TDxRedisClient;
    FPipeData: Pointer;
    FDbIndex: Integer;
    FTxPipeLine: Boolean;
    procedure SetTxPipeLine(const Value: Boolean);
  protected
    procedure FreePipeClient; virtual;
    function GetPipeData: Pointer; virtual;
  public
    constructor Create(Owner: TDxRedisClient);
    destructor Destroy; override;
    property TxPipeLine: Boolean read FTxPipeLine write SetTxPipeLine;
    procedure ResetOwner(Owner: TDxRedisClient);
    property PipeClient: Pointer read GetPipeData;
    property PipeData: Pointer read FPipeData;
    procedure Ping(StatusCmdReturn: TRedisStatusCmd); overload;
    procedure Ping(StatusCmdReturn: TRedisStatusCmdA); overload;
    procedure Ping(StatusCmdReturn: TRedisStatusCmdG); overload;
    procedure Select(dbIndex: Integer; StatusCmdReturn: TRedisStatusCmd); overload;
    procedure Select(dbIndex: Integer; StatusCmdReturn: TRedisStatusCmdA); overload;
    procedure Select(dbIndex: Integer; StatusCmdReturn: TRedisStatusCmdG); overload;
    procedure Rename(Key, NewKey: string; StatusCmdReturn: TRedisStatusCmd); overload;
    procedure Rename(Key, NewKey: string; StatusCmdReturn: TRedisStatusCmdA); overload;
    procedure Rename(Key, NewKey: string; StatusCmdReturn: TRedisStatusCmdG); overload;
    procedure Migrate(host, port, Key: string; db, timeout: Integer; StatusCmdReturn: TRedisStatusCmd); overload;
    procedure Migrate(host, port, Key: string; db, timeout: Integer; StatusCmdReturn: TRedisStatusCmdA); overload;
    procedure Migrate(host, port, Key: string; db, timeout: Integer; StatusCmdReturn: TRedisStatusCmdG); overload;
    procedure Restore(Key, Value: string; ttl: Integer; StatusCmdReturn: TRedisStatusCmd); overload;
    procedure Restore(Key, Value: string; ttl: Integer; StatusCmdReturn: TRedisStatusCmdA); overload;
    procedure Restore(Key, Value: string; ttl: Integer; StatusCmdReturn: TRedisStatusCmdG); overload;
    procedure RestoreReplace(Key, Value: string; ttl: Integer; StatusCmdReturn: TRedisStatusCmd); overload;
    procedure RestoreReplace(Key, Value: string; ttl: Integer; StatusCmdReturn: TRedisStatusCmdA); overload;
    procedure RestoreReplace(Key, Value: string; ttl: Integer; StatusCmdReturn: TRedisStatusCmdG); overload;
    procedure TypeCmd(Key: string; StatusCmdReturn: TRedisStatusCmd); overload;
    procedure TypeCmd(Key: string; StatusCmdReturn: TRedisStatusCmdA); overload;
    procedure TypeCmd(Key: string; StatusCmdReturn: TRedisStatusCmdG); overload;
    procedure MSet(keyValueArray: array of TKeyValue; StatusCmdReturn: TRedisStatusCmd); overload;
    procedure MSet(keyValueArray: array of TKeyValue; StatusCmdReturn: TRedisStatusCmdA); overload;
    procedure MSet(keyValueArray: array of TKeyValue; StatusCmdReturn: TRedisStatusCmdG); overload;
    procedure MSet(keyValueArray: array of TRedisKeyValue; StatusCmdReturn: TRedisStatusCmd); overload;
    procedure MSet(keyValueArray: array of TRedisKeyValue; StatusCmdReturn: TRedisStatusCmdA); overload;
    procedure MSet(keyValueArray: array of TRedisKeyValue; StatusCmdReturn: TRedisStatusCmdG); overload;
    procedure SetCmd(Key, Value: string; expiration: Integer; StatusCmdReturn: TRedisStatusCmd); overload;
    procedure SetCmd(Key, Value: string; expiration: Integer; StatusCmdReturn: TRedisStatusCmdA); overload;
    procedure SetCmd(Key, Value: string; expiration: Integer; StatusCmdReturn: TRedisStatusCmdG); overload;
    procedure SetCmd(Key: string; ValueBuffer: PByte; BufferLen, expiration: Integer; StatusCmdReturn: TRedisStatusCmd); overload;
    procedure SetCmd(Key: string; ValueBuffer: PByte; BufferLen, expiration: Integer; StatusCmdReturn: TRedisStatusCmdA); overload;
    procedure SetCmd(Key: string; ValueBuffer: PByte; BufferLen, expiration: Integer; StatusCmdReturn: TRedisStatusCmdG); overload;
    procedure SetEx(Key, Value: string; expiration: Integer; StatusCmdReturn: TRedisStatusCmd); overload;
    procedure SetEx(Key, Value: string; expiration: Integer; StatusCmdReturn: TRedisStatusCmdA); overload;
    procedure SetEx(Key, Value: string; expiration: Integer; StatusCmdReturn: TRedisStatusCmdG); overload;
    procedure SetEx(Key: string; ValueBuffer: PByte; BufferLen, expiration: Integer; StatusCmdReturn: TRedisStatusCmd); overload;
    procedure SetEx(Key: string; ValueBuffer: PByte; BufferLen, expiration: Integer; StatusCmdReturn: TRedisStatusCmdA); overload;
    procedure SetEx(Key: string; ValueBuffer: PByte; BufferLen, expiration: Integer; StatusCmdReturn: TRedisStatusCmdG); overload;
    procedure SetArgs(Key, Value: string; args: TsetArgs; StatusCmdReturn: TRedisStatusCmd); overload;
    procedure SetArgs(Key, Value: string; args: TsetArgs; StatusCmdReturn: TRedisStatusCmdA); overload;
    procedure SetArgs(Key, Value: string; args: TsetArgs; StatusCmdReturn: TRedisStatusCmdG); overload;
    procedure SetArgs(Key: string; ValueBuffer: PByte; BufferLen: Integer; args: TsetArgs; StatusCmdReturn: TRedisStatusCmd); overload;
    procedure SetArgs(Key: string; ValueBuffer: PByte; BufferLen: Integer; args: TsetArgs; StatusCmdReturn: TRedisStatusCmdA); overload;
    procedure SetArgs(Key: string; ValueBuffer: PByte; BufferLen: Integer; args: TsetArgs; StatusCmdReturn: TRedisStatusCmdG); overload;
    procedure LSet(Key: string; index: Int64; Value: string; StatusCmdReturn: TRedisStatusCmd); overload;
    procedure LSet(Key: string; index: Int64; Value: string; StatusCmdReturn: TRedisStatusCmdA); overload;
    procedure LSet(Key: string; index: Int64; Value: string; StatusCmdReturn: TRedisStatusCmdG); overload;
    procedure LSet(Key: string; index: Int64; ValueBuffer: PByte; BufferLen: Integer; StatusCmdReturn: TRedisStatusCmd); overload;
    procedure LSet(Key: string; index: Int64; ValueBuffer: PByte; BufferLen: Integer; StatusCmdReturn: TRedisStatusCmdA); overload;
    procedure LSet(Key: string; index: Int64; ValueBuffer: PByte; BufferLen: Integer; StatusCmdReturn: TRedisStatusCmdG); overload;
    procedure LTrim(Key: string; Start, stop: Int64; StatusCmdReturn: TRedisStatusCmd); overload;
    procedure LTrim(Key: string; Start, stop: Int64; StatusCmdReturn: TRedisStatusCmdA); overload;
    procedure LTrim(Key: string; Start, stop: Int64; StatusCmdReturn: TRedisStatusCmdG); overload;
    procedure ScriptFlush(StatusCmdReturn: TRedisStatusCmd); overload;
    procedure ScriptFlush(StatusCmdReturn: TRedisStatusCmdA); overload;
    procedure ScriptFlush(StatusCmdReturn: TRedisStatusCmdG); overload;
    procedure ScriptKill(StatusCmdReturn: TRedisStatusCmd); overload;
    procedure ScriptKill(StatusCmdReturn: TRedisStatusCmdA); overload;
    procedure ScriptKill(StatusCmdReturn: TRedisStatusCmdG); overload;
    procedure ScriptLoad(script: string; StatusCmdReturn: TRedisStatusCmd); overload;
    procedure ScriptLoad(script: string; StatusCmdReturn: TRedisStatusCmdA); overload;
    procedure ScriptLoad(script: string; StatusCmdReturn: TRedisStatusCmdG); overload;
    procedure Scan(cursor: UInt64; match: string; count: Int64; scanCmdReturn: TRedisScanCmdReturn); overload;
    procedure Scan(cursor: UInt64; match: string; count: Int64; scanCmdReturn: TRedisScanCmdReturnA); overload;
    procedure Scan(cursor: UInt64; match: string; count: Int64; scanCmdReturn: TRedisScanCmdReturnG); overload;
    procedure ScanType(cursor: UInt64; match, KeyType: string; count: Int64; scanCmdReturn: TRedisScanCmdReturn); overload;
    procedure ScanType(cursor: UInt64; match, KeyType: string; count: Int64; scanCmdReturn: TRedisScanCmdReturnA); overload;
    procedure ScanType(cursor: UInt64; match, KeyType: string; count: Int64; scanCmdReturn: TRedisScanCmdReturnG); overload;
    procedure SScan(cursor: UInt64; Key, match: string; count: Int64; scanCmdReturn: TRedisScanValueCmdReturn); overload;
    procedure SScan(cursor: UInt64; Key, match: string; count: Int64; scanCmdReturn: TRedisScanValueCmdReturnA); overload;
    procedure SScan(cursor: UInt64; Key, match: string; count: Int64; scanCmdReturn: TRedisScanValueCmdReturnG); overload;
    procedure HScan(cursor: UInt64; Key, match: string; count: Int64; scanCmdReturn: TRedisScanKVCmdReturn); overload;
    procedure HScan(cursor: UInt64; Key, match: string; count: Int64; scanCmdReturn: TRedisScanKVCmdReturnA); overload;
    procedure HScan(cursor: UInt64; Key, match: string; count: Int64; scanCmdReturn: TRedisScanKVCmdReturnG); overload;
    procedure ZScan(cursor: UInt64; Key, match: string; count: Int64; scanCmdReturn: TRedisScanKScoreCmdReturn); overload;
    procedure ZScan(cursor: UInt64; Key, match: string; count: Int64; scanCmdReturn: TRedisScanKScoreCmdReturnA); overload;
    procedure ZScan(cursor: UInt64; Key, match: string; count: Int64; scanCmdReturn: TRedisScanKScoreCmdReturnG); overload;
    procedure get(Key: string; stringCmdReturn: TRedisStringCmdReturn); overload;
    procedure get(Key: string; stringCmdReturn: TRedisStringCmdReturnA); overload;
    procedure get(Key: string; stringCmdReturn: TRedisStringCmdReturnG); overload;
    procedure get(Key: string; stringCmdReturn: TRedisStringCmdReturnByte); overload;
    procedure get(Key: string; stringCmdReturn: TRedisStringCmdReturnByteA); overload;
    procedure get(Key: string; stringCmdReturn: TRedisStringCmdReturnByteG); overload;

    procedure RandomKey(block: Boolean;stringCmdReturn: TRedisStringCmdReturn); overload;
    procedure RandomKey(block: Boolean;stringCmdReturn: TRedisStringCmdReturnA); overload;
    procedure RandomKey(block: Boolean;stringCmdReturn: TRedisStringCmdReturnG); overload;

    procedure GetRange(Key: string; Start, stop: Int64; stringCmdReturn: TRedisStringCmdReturn); overload;
    procedure GetRange(Key: string; Start, stop: Int64; stringCmdReturnA: TRedisStringCmdReturnA); overload;
    procedure GetRange(Key: string; Start, stop: Int64; stringCmdReturnG: TRedisStringCmdReturnG); overload;
    procedure GetRange(Key: string; Start, stop: Int64; stringCmdReturn: TRedisStringCmdReturnByte); overload;
    procedure GetRange(Key: string; Start, stop: Int64; stringCmdReturnA: TRedisStringCmdReturnByteA); overload;
    procedure GetRange(Key: string; Start, stop: Int64; stringCmdReturnG: TRedisStringCmdReturnByteG); overload;
    procedure GetSet(Key: string; Value: string; stringCmdReturn: TRedisStringCmdReturn); overload;
    procedure GetSet(Key: string; Value: string; stringCmdReturn: TRedisStringCmdReturnA); overload;
    procedure GetSet(Key: string; Value: string; stringCmdReturn: TRedisStringCmdReturnG); overload;
    procedure GetSet(Key: string; Value: PByte; ValueLen: Integer; stringCmdReturn: TRedisStringCmdReturnByte); overload;
    procedure GetSet(Key: string; Value: PByte; ValueLen: Integer; stringCmdReturn: TRedisStringCmdReturnByteA); overload;
    procedure GetSet(Key: string; Value: PByte; ValueLen: Integer; stringCmdReturn: TRedisStringCmdReturnByteG); overload;
    procedure GetEx(Key: string; expiration: Integer; stringCmdReturn: TRedisStringCmdReturn); overload;
    procedure GetEx(Key: string; expiration: Integer; stringCmdReturn: TRedisStringCmdReturnA); overload;
    procedure GetEx(Key: string; expiration: Integer; stringCmdReturn: TRedisStringCmdReturnG); overload;
    procedure GetEx(Key: string; expiration: Integer; stringCmdReturn: TRedisStringCmdReturnByte); overload;
    procedure GetEx(Key: string; expiration: Integer; stringCmdReturn: TRedisStringCmdReturnByteA); overload;
    procedure GetEx(Key: string; expiration: Integer; stringCmdReturn: TRedisStringCmdReturnByteG); overload;
    procedure GetDel(Key: string; stringCmdReturn: TRedisStringCmdReturn); overload;
    procedure GetDel(Key: string; stringCmdReturn: TRedisStringCmdReturnA); overload;
    procedure GetDel(Key: string; stringCmdReturn: TRedisStringCmdReturnG); overload;
    procedure GetDel(Key: string; stringCmdReturn: TRedisStringCmdReturnByte); overload;
    procedure GetDel(Key: string; stringCmdReturn: TRedisStringCmdReturnByteA); overload;
    procedure GetDel(Key: string; stringCmdReturn: TRedisStringCmdReturnByteG); overload;
    procedure HGet(Key, field: string; stringCmdReturn: TRedisStringCmdReturn); overload;
    procedure HGet(Key, field: string; stringCmdReturn: TRedisStringCmdReturnA); overload;
    procedure HGet(Key, field: string; stringCmdReturn: TRedisStringCmdReturnG); overload;
    procedure HGet(Key, field: string; stringCmdReturn: TRedisStringCmdReturnByte); overload;
    procedure HGet(Key, field: string; stringCmdReturn: TRedisStringCmdReturnByteA); overload;
    procedure HGet(Key, field: string; stringCmdReturn: TRedisStringCmdReturnByteG); overload;
    procedure BRPopLPush(src, dst: string; timeout: Integer; stringCmdReturn: TRedisStringCmdReturn); overload;
    procedure BRPopLPush(src, dst: string; timeout: Integer; stringCmdReturn: TRedisStringCmdReturnA); overload;
    procedure BRPopLPush(src, dst: string; timeout: Integer; stringCmdReturn: TRedisStringCmdReturnG); overload;
    procedure BRPopLPush(src, dst: string; timeout: Integer; stringCmdReturn: TRedisStringCmdReturnByte); overload;
    procedure BRPopLPush(src, dst: string; timeout: Integer; stringCmdReturn: TRedisStringCmdReturnByteA); overload;
    procedure BRPopLPush(src, dst: string; timeout: Integer; stringCmdReturn: TRedisStringCmdReturnByteG); overload;
    procedure RPopLPush(src, dst: string; stringCmdReturn: TRedisStringCmdReturn); overload;
    procedure RPopLPush(src, dst: string; stringCmdReturn: TRedisStringCmdReturnA); overload;
    procedure RPopLPush(src, dst: string; stringCmdReturn: TRedisStringCmdReturnG); overload;
    procedure RPopLPush(src, dst: string; stringCmdReturn: TRedisStringCmdReturnByte); overload;
    procedure RPopLPush(src, dst: string; stringCmdReturn: TRedisStringCmdReturnByteA); overload;
    procedure RPopLPush(src, dst: string; stringCmdReturn: TRedisStringCmdReturnByteG); overload;
    procedure LIndex(Key: string; index: Int64; stringCmdReturn: TRedisStringCmdReturn); overload;
    procedure LIndex(Key: string; index: Int64; stringCmdReturn: TRedisStringCmdReturnA); overload;
    procedure LIndex(Key: string; index: Int64; stringCmdReturn: TRedisStringCmdReturnG); overload;
    procedure LIndex(Key: string; index: Int64; stringCmdReturn: TRedisStringCmdReturnByte); overload;
    procedure LIndex(Key: string; index: Int64; stringCmdReturn: TRedisStringCmdReturnByteA); overload;
    procedure LIndex(Key: string; index: Int64; stringCmdReturn: TRedisStringCmdReturnByteG); overload;
    procedure LPop(Key: string; stringCmdReturn: TRedisStringCmdReturn); overload;
    procedure LPop(Key: string; stringCmdReturn: TRedisStringCmdReturnA); overload;
    procedure LPop(Key: string; stringCmdReturn: TRedisStringCmdReturnG); overload;
    procedure LPop(Key: string; stringCmdReturn: TRedisStringCmdReturnByte); overload;
    procedure LPop(Key: string; stringCmdReturn: TRedisStringCmdReturnByteA); overload;
    procedure LPop(Key: string; stringCmdReturn: TRedisStringCmdReturnByteG); overload;
    procedure RPop(Key: string; stringCmdReturn: TRedisStringCmdReturn); overload;
    procedure RPop(Key: string; stringCmdReturn: TRedisStringCmdReturnA); overload;
    procedure RPop(Key: string; stringCmdReturn: TRedisStringCmdReturnG); overload;
    procedure RPop(Key: string; stringCmdReturn: TRedisStringCmdReturnByte); overload;
    procedure RPop(Key: string; stringCmdReturn: TRedisStringCmdReturnByteA); overload;
    procedure RPop(Key: string; stringCmdReturn: TRedisStringCmdReturnByteG); overload;
    procedure SPop(Key: string; stringCmdReturn: TRedisStringCmdReturn); overload;
    procedure SPop(Key: string; stringCmdReturn: TRedisStringCmdReturnA); overload;
    procedure SPop(Key: string; stringCmdReturn: TRedisStringCmdReturnG); overload;
    procedure SPop(Key: string; stringCmdReturn: TRedisStringCmdReturnByte); overload;
    procedure SPop(Key: string; stringCmdReturn: TRedisStringCmdReturnByteA); overload;
    procedure SPop(Key: string; stringCmdReturn: TRedisStringCmdReturnByteG); overload;
    procedure SRandMember(Key: string; stringCmdReturn: TRedisStringCmdReturn); overload;
    procedure SRandMember(Key: string; stringCmdReturn: TRedisStringCmdReturnA); overload;
    procedure SRandMember(Key: string; stringCmdReturn: TRedisStringCmdReturnG); overload;
    procedure SRandMember(Key: string; stringCmdReturn: TRedisStringCmdReturnByte); overload;
    procedure SRandMember(Key: string; stringCmdReturn: TRedisStringCmdReturnByteA); overload;
    procedure SRandMember(Key: string; stringCmdReturn: TRedisStringCmdReturnByteG); overload;
    procedure ClientList(stringCmdReturn: TRedisStringCmdReturn); overload;
    procedure ClientList(stringCmdReturn: TRedisStringCmdReturnA); overload;
    procedure ClientList(stringCmdReturn: TRedisStringCmdReturnG); overload;
    procedure Info(sections: array of string; stringCmdReturn: TRedisStringCmdReturn); overload;
    procedure Info(sections: array of string; stringCmdReturn: TRedisStringCmdReturnA); overload;
    procedure Info(sections: array of string; stringCmdReturn: TRedisStringCmdReturnG); overload;
    procedure XAdd(stream, ID: string; MaxLen, MaxLenApprox: Int64; Value: string; stringCmdReturn: TRedisStringCmdReturn); overload;
    procedure XAdd(stream, ID: string; MaxLen, MaxLenApprox: Int64; Value: string; stringCmdReturn: TRedisStringCmdReturnA); overload;
    procedure XAdd(stream, ID: string; MaxLen, MaxLenApprox: Int64; Value: string; stringCmdReturn: TRedisStringCmdReturnG); overload;
    procedure Del(keys: array of string; intCmdReturn: TIntCmdReturn); overload;
    procedure Del(keys: array of string; intCmdReturn: TIntCmdReturnA); overload;
    procedure Del(keys: array of string; intCmdReturn: TIntCmdReturnG); overload;
    procedure Unlink(keys: array of string; intCmdReturn: TIntCmdReturn); overload;
    procedure Unlink(keys: array of string; intCmdReturn: TIntCmdReturnA); overload;
    procedure Unlink(keys: array of string; intCmdReturn: TIntCmdReturnG); overload;
    procedure Exists(keys: array of string; intCmdReturn: TIntCmdReturn); overload;
    procedure Exists(keys: array of string; intCmdReturn: TIntCmdReturnA); overload;
    procedure Exists(keys: array of string; intCmdReturn: TIntCmdReturnG); overload;
    procedure ObjectRefCount(Key: string; intCmdReturn: TIntCmdReturn); overload;
    procedure ObjectRefCount(Key: string; intCmdReturn: TIntCmdReturnA); overload;
    procedure ObjectRefCount(Key: string; intCmdReturn: TIntCmdReturnG); overload;
    procedure Touch(keys: array of string; intCmdReturn: TIntCmdReturn); overload;
    procedure Touch(keys: array of string; intCmdReturn: TIntCmdReturnA); overload;
    procedure Touch(keys: array of string; intCmdReturn: TIntCmdReturnG); overload;
    procedure Append(Key, Value: string; intCmdReturn: TIntCmdReturn); overload;
    procedure Append(Key, Value: string; intCmdReturn: TIntCmdReturnA); overload;
    procedure Append(Key, Value: string; intCmdReturn: TIntCmdReturnG); overload;
    procedure Decr(Key: string; intCmdReturn: TIntCmdReturn); overload;
    procedure Decr(Key: string; intCmdReturn: TIntCmdReturnA); overload;
    procedure Decr(Key: string; intCmdReturn: TIntCmdReturnG); overload;
    procedure DecrBy(Key: string; decrement: Int64; intCmdReturn: TIntCmdReturn); overload;
    procedure DecrBy(Key: string; decrement: Int64; intCmdReturn: TIntCmdReturnA); overload;
    procedure DecrBy(Key: string; decrement: Int64; intCmdReturn: TIntCmdReturnG); overload;
    procedure Incr(Key: string; intCmdReturn: TIntCmdReturn); overload;
    procedure Incr(Key: string; intCmdReturn: TIntCmdReturnA); overload;
    procedure Incr(Key: string; intCmdReturn: TIntCmdReturnG); overload;
    procedure IncrBy(Key: string; increment: Int64; intCmdReturn: TIntCmdReturn); overload;
    procedure IncrBy(Key: string; increment: Int64; intCmdReturn: TIntCmdReturnA); overload;
    procedure IncrBy(Key: string; increment: Int64; intCmdReturn: TIntCmdReturnG); overload;
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

    procedure StrLen(Key: string; intCmdReturn: TIntCmdReturn); overload;
    procedure StrLen(Key: string; intCmdReturn: TIntCmdReturnA); overload;
    procedure StrLen(Key: string; intCmdReturn: TIntCmdReturnG); overload;
    procedure SetRange(Key: string; offset: Int64; Value: string; intCmdReturn: TIntCmdReturn); overload;
    procedure SetRange(Key: string; offset: Int64; Value: string; intCmdReturn: TIntCmdReturnA); overload;
    procedure SetRange(Key: string; offset: Int64; Value: string; intCmdReturn: TIntCmdReturnG); overload;
    procedure GetBit(Key: string; offset: Int64; intCmdReturn: TIntCmdReturn); overload;
    procedure GetBit(Key: string; offset: Int64; intCmdReturn: TIntCmdReturnA); overload;
    procedure GetBit(Key: string; offset: Int64; intCmdReturn: TIntCmdReturnG); overload;
    procedure SetBit(Key: string; offset: Int64; Value: Integer; intCmdReturn: TIntCmdReturn); overload;
    procedure SetBit(Key: string; offset: Int64; Value: Integer; intCmdReturn: TIntCmdReturnA); overload;
    procedure SetBit(Key: string; offset: Int64; Value: Integer; intCmdReturn: TIntCmdReturnG); overload;
    procedure BitCount(Key: string; BitCount: TBitCount; intCmdReturn: TIntCmdReturn); overload;
    procedure BitCount(Key: string; BitCount: TBitCount; intCmdReturn: TIntCmdReturnA); overload;
    procedure BitCount(Key: string; BitCount: TBitCount; intCmdReturn: TIntCmdReturnG); overload;
    procedure BitOpAnd(destKey: string; keys: array of string; intCmdReturn: TIntCmdReturn); overload;
    procedure BitOpAnd(destKey: string; keys: array of string; intCmdReturn: TIntCmdReturnA); overload;
    procedure BitOpAnd(destKey: string; keys: array of string; intCmdReturn: TIntCmdReturnG); overload;
    procedure BitOpOr(destKey: string; keys: array of string; intCmdReturn: TIntCmdReturn); overload;
    procedure BitOpOr(destKey: string; keys: array of string; intCmdReturn: TIntCmdReturnA); overload;
    procedure BitOpOr(destKey: string; keys: array of string; intCmdReturn: TIntCmdReturnG); overload;
    procedure BitOpXor(destKey: string; keys: array of string; intCmdReturn: TIntCmdReturn); overload;
    procedure BitOpXor(destKey: string; keys: array of string; intCmdReturn: TIntCmdReturnA); overload;
    procedure BitOpXor(destKey: string; keys: array of string; intCmdReturn: TIntCmdReturnG); overload;
    procedure BitOpNot(destKey, Key: string; intCmdReturn: TIntCmdReturn); overload;
    procedure BitOpNot(destKey, Key: string; intCmdReturn: TIntCmdReturnA); overload;
    procedure BitOpNot(destKey, Key: string; intCmdReturn: TIntCmdReturnG); overload;
    procedure BitPos(Key: string; bit: Int64; bitPoss: array of Int64; intCmdReturn: TIntCmdReturn); overload;
    procedure BitPos(Key: string; bit: Int64; bitPoss: array of Int64; intCmdReturn: TIntCmdReturnA); overload;
    procedure BitPos(Key: string; bit: Int64; bitPoss: array of Int64; intCmdReturn: TIntCmdReturnG); overload;
    procedure HDel(Key: string; fields: array of string; intCmdReturn: TIntCmdReturn); overload;
    procedure HDel(Key: string; fields: array of string; intCmdReturn: TIntCmdReturnA); overload;
    procedure HDel(Key: string; fields: array of string; intCmdReturn: TIntCmdReturnG); overload;
    procedure HIncrBy(Key, field: string; Incr: Int64; intCmdReturn: TIntCmdReturn); overload;
    procedure HIncrBy(Key, field: string; Incr: Int64; intCmdReturn: TIntCmdReturnA); overload;
    procedure HIncrBy(Key, field: string; Incr: Int64; intCmdReturn: TIntCmdReturnG); overload;
    procedure HLen(Key: string; intCmdReturn: TIntCmdReturn); overload;
    procedure HLen(Key: string; intCmdReturn: TIntCmdReturnA); overload;
    procedure HLen(Key: string; intCmdReturn: TIntCmdReturnG); overload;
    procedure HSet(Key: string; keyValues: array of TKeyValue; intCmdReturn: TIntCmdReturn); overload;
    procedure HSet(Key: string; keyValues: array of TKeyValue; intCmdReturn: TIntCmdReturnA); overload;
    procedure HSet(Key: string; keyValues: array of TKeyValue; intCmdReturn: TIntCmdReturnG); overload;
    procedure HSet(Key: string; keyValues: array of TRedisKeyValue; intCmdReturn: TIntCmdReturn); overload;
    procedure HSet(Key: string; keyValues: array of TRedisKeyValue; intCmdReturn: TIntCmdReturnA); overload;
    procedure HSet(Key: string; keyValues: array of TRedisKeyValue; intCmdReturn: TIntCmdReturnG); overload;

    procedure LInsert(Key: string; before: Boolean; pivot, Value: string; intCmdReturn: TIntCmdReturn); overload;
    procedure LInsert(Key: string; before: Boolean; pivot, Value: string; intCmdReturn: TIntCmdReturnA); overload;
    procedure LInsert(Key: string; before: Boolean; pivot, Value: string; intCmdReturn: TIntCmdReturnG); overload;
    procedure LInsert(Key: string; before: Boolean; pivot, Value: TValueInterface; intCmdReturn: TIntCmdReturn); overload;
    procedure LInsert(Key: string; before: Boolean; pivot, Value: TValueInterface; intCmdReturn: TIntCmdReturnA); overload;
    procedure LInsert(Key: string; before: Boolean; pivot, Value: TValueInterface; intCmdReturn: TIntCmdReturnG); overload;
    procedure LInsertBefore(Key: string; pivot, Value: string; intCmdReturn: TIntCmdReturn); overload;
    procedure LInsertBefore(Key: string; pivot, Value: string; intCmdReturn: TIntCmdReturnA); overload;
    procedure LInsertBefore(Key: string; pivot, Value: string; intCmdReturn: TIntCmdReturnG); overload;
    procedure LInsertBefore(Key: string; pivot, Value: TValueInterface; intCmdReturn: TIntCmdReturn); overload;
    procedure LInsertBefore(Key: string; pivot, Value: TValueInterface; intCmdReturn: TIntCmdReturnA); overload;
    procedure LInsertBefore(Key: string; pivot, Value: TValueInterface; intCmdReturn: TIntCmdReturnG); overload;

    procedure LInsertAfter(Key: string; pivot, Value: string; intCmdReturn: TIntCmdReturn); overload;
    procedure LInsertAfter(Key: string; pivot, Value: string; intCmdReturn: TIntCmdReturnA); overload;
    procedure LInsertAfter(Key: string; pivot, Value: string; intCmdReturn: TIntCmdReturnG); overload;

    procedure LInsertAfter(Key: string; pivot, Value: TValueInterface; intCmdReturn: TIntCmdReturn); overload;
    procedure LInsertAfter(Key: string; pivot, Value: TValueInterface; intCmdReturn: TIntCmdReturnA); overload;
    procedure LInsertAfter(Key: string; pivot, Value: TValueInterface; intCmdReturn: TIntCmdReturnG); overload;


    procedure LLen(Key: string; intCmdReturn: TIntCmdReturn); overload;
    procedure LLen(Key: string; intCmdReturn: TIntCmdReturnA); overload;
    procedure LLen(Key: string; intCmdReturn: TIntCmdReturnG); overload;
    procedure LPos(Key, Value: string; args: TLPosArgs; intCmdReturn: TIntCmdReturn); overload;
    procedure LPos(Key, Value: string; args: TLPosArgs; intCmdReturn: TIntCmdReturnA); overload;
    procedure LPos(Key, Value: string; args: TLPosArgs; intCmdReturn: TIntCmdReturnG); overload;
    procedure LPush(Key: string; values: array of string; intCmdReturn: TIntCmdReturn); overload;
    procedure LPush(Key: string; values: array of string; intCmdReturn: TIntCmdReturnA); overload;
    procedure LPush(Key: string; values: array of string; intCmdReturn: TIntCmdReturnG); overload;
    procedure LPush(Key: string; values: array of TValueInterface; intCmdReturn: TIntCmdReturn); overload;
    procedure LPush(Key: string; values: array of TValueInterface; intCmdReturn: TIntCmdReturnA); overload;
    procedure LPush(Key: string; values: array of TValueInterface; intCmdReturn: TIntCmdReturnG); overload;
    procedure LPushx(Key: string; values: array of string; intCmdReturn: TIntCmdReturn); overload;
    procedure LPushx(Key: string; values: array of string; intCmdReturn: TIntCmdReturnA); overload;
    procedure LPushx(Key: string; values: array of string; intCmdReturn: TIntCmdReturnG); overload;
    procedure LPushx(Key: string; values: array of TValueInterface; intCmdReturn: TIntCmdReturn); overload;
    procedure LPushx(Key: string; values: array of TValueInterface; intCmdReturn: TIntCmdReturnA); overload;
    procedure LPushx(Key: string; values: array of TValueInterface; intCmdReturn: TIntCmdReturnG); overload;
    procedure RPush(Key: string; values: array of string; intCmdReturn: TIntCmdReturn); overload;
    procedure RPush(Key: string; values: array of string; intCmdReturn: TIntCmdReturnA); overload;
    procedure RPush(Key: string; values: array of string; intCmdReturn: TIntCmdReturnG); overload;
    procedure RPush(Key: string; values: array of TValueInterface; intCmdReturn: TIntCmdReturn); overload;
    procedure RPush(Key: string; values: array of TValueInterface; intCmdReturn: TIntCmdReturnA); overload;
    procedure RPush(Key: string; values: array of TValueInterface; intCmdReturn: TIntCmdReturnG); overload;
    procedure RPushx(Key: string; values: array of string; intCmdReturn: TIntCmdReturn); overload;
    procedure RPushx(Key: string; values: array of string; intCmdReturn: TIntCmdReturnA); overload;
    procedure RPushx(Key: string; values: array of string; intCmdReturn: TIntCmdReturnG); overload;
    procedure RPushx(Key: string; values: array of TValueInterface; intCmdReturn: TIntCmdReturn); overload;
    procedure RPushx(Key: string; values: array of TValueInterface; intCmdReturn: TIntCmdReturnA); overload;
    procedure RPushx(Key: string; values: array of TValueInterface; intCmdReturn: TIntCmdReturnG); overload;
    procedure LRem(Key: string; count: Int64; Value: TValueInterface; intCmdReturn: TIntCmdReturn); overload;
    procedure LRem(Key: string; count: Int64; Value: TValueInterface; intCmdReturn: TIntCmdReturnA); overload;
    procedure LRem(Key: string; count: Int64; Value: TValueInterface; intCmdReturn: TIntCmdReturnG); overload;
    procedure SAdd(Key: string; values: array of string; intCmdReturn: TIntCmdReturn); overload;
    procedure SAdd(Key: string; values: array of string; intCmdReturn: TIntCmdReturnA); overload;
    procedure SAdd(Key: string; values: array of string; intCmdReturn: TIntCmdReturnG); overload;
    procedure SAdd(Key: string; values: array of TValueInterface; intCmdReturn: TIntCmdReturn); overload;
    procedure SAdd(Key: string; values: array of TValueInterface; intCmdReturn: TIntCmdReturnA); overload;
    procedure SAdd(Key: string; values: array of TValueInterface; intCmdReturn: TIntCmdReturnG); overload;
    procedure SCard(Key: string; intCmdReturn: TIntCmdReturn); overload;
    procedure SCard(Key: string; intCmdReturn: TIntCmdReturnA); overload;
    procedure SCard(Key: string; intCmdReturn: TIntCmdReturnG); overload;
    procedure SDiffStore(destKey: string; keys: array of string; intCmdReturn: TIntCmdReturn); overload;
    procedure SDiffStore(destKey: string; keys: array of string; intCmdReturn: TIntCmdReturnA); overload;
    procedure SDiffStore(destKey: string; keys: array of string; intCmdReturn: TIntCmdReturnG); overload;
    procedure SInterStore(destKey: string; keys: array of string; intCmdReturn: TIntCmdReturn); overload;
    procedure SInterStore(destKey: string; keys: array of string; intCmdReturn: TIntCmdReturnA); overload;
    procedure SInterStore(destKey: string; keys: array of string; intCmdReturn: TIntCmdReturnG); overload;
    procedure SRem(Key: string; membersArr: array of string; intCmdReturn: TIntCmdReturn); overload;
    procedure SRem(Key: string; membersArr: array of string; intCmdReturn: TIntCmdReturnA); overload;
    procedure SRem(Key: string; membersArr: array of string; intCmdReturn: TIntCmdReturnG); overload;
    procedure SRem(Key: string; membersArr: array of TValueInterface; intCmdReturn: TIntCmdReturn); overload;
    procedure SRem(Key: string; membersArr: array of TValueInterface; intCmdReturn: TIntCmdReturnA); overload;
    procedure SRem(Key: string; membersArr: array of TValueInterface; intCmdReturn: TIntCmdReturnG); overload;
    procedure SUnionStore(destKey: string; keys: array of string; intCmdReturn: TIntCmdReturn); overload;
    procedure SUnionStore(destKey: string; keys: array of string; intCmdReturn: TIntCmdReturnA); overload;
    procedure SUnionStore(destKey: string; keys: array of string; intCmdReturn: TIntCmdReturnG); overload;
    procedure ZAdd(Key: string; zvalue: array of TZStrValue; intCmdReturn: TIntCmdReturn); overload;
    procedure ZAdd(Key: string; zvalue: array of TZStrValue; intCmdReturn: TIntCmdReturnA); overload;
    procedure ZAdd(Key: string; zvalue: array of TZStrValue; intCmdReturn: TIntCmdReturnG); overload;
    procedure ZAdd(Key: string; zvalue: array of TZValue; intCmdReturn: TIntCmdReturn); overload;
    procedure ZAdd(Key: string; zvalue: array of TZValue; intCmdReturn: TIntCmdReturnA); overload;
    procedure ZAdd(Key: string; zvalue: array of TZValue; intCmdReturn: TIntCmdReturnG); overload;
    procedure ZAddNX(Key: string; zvalue: array of TZStrValue; intCmdReturn: TIntCmdReturn); overload;
    procedure ZAddNX(Key: string; zvalue: array of TZStrValue; intCmdReturn: TIntCmdReturnA); overload;
    procedure ZAddNX(Key: string; zvalue: array of TZStrValue; intCmdReturn: TIntCmdReturnG); overload;
    procedure ZAddNX(Key: string; zvalue: array of TZValue; intCmdReturn: TIntCmdReturn); overload;
    procedure ZAddNX(Key: string; zvalue: array of TZValue; intCmdReturn: TIntCmdReturnA); overload;
    procedure ZAddNX(Key: string; zvalue: array of TZValue; intCmdReturn: TIntCmdReturnG); overload;
    procedure ZAddXX(Key: string; zvalue: array of TZStrValue; intCmdReturn: TIntCmdReturn); overload;
    procedure ZAddXX(Key: string; zvalue: array of TZStrValue; intCmdReturn: TIntCmdReturnA); overload;
    procedure ZAddXX(Key: string; zvalue: array of TZStrValue; intCmdReturn: TIntCmdReturnG); overload;
    procedure ZAddXX(Key: string; zvalue: array of TZValue; intCmdReturn: TIntCmdReturn); overload;
    procedure ZAddXX(Key: string; zvalue: array of TZValue; intCmdReturn: TIntCmdReturnA); overload;
    procedure ZAddXX(Key: string; zvalue: array of TZValue; intCmdReturn: TIntCmdReturnG); overload;
    procedure ZAddCh(Key: string; zvalue: array of TZStrValue; intCmdReturn: TIntCmdReturn); overload;
    procedure ZAddCh(Key: string; zvalue: array of TZStrValue; intCmdReturn: TIntCmdReturnA); overload;
    procedure ZAddCh(Key: string; zvalue: array of TZStrValue; intCmdReturn: TIntCmdReturnG); overload;
    procedure ZAddCh(Key: string; zvalue: array of TZValue; intCmdReturn: TIntCmdReturn); overload;
    procedure ZAddCh(Key: string; zvalue: array of TZValue; intCmdReturn: TIntCmdReturnA); overload;
    procedure ZAddCh(Key: string; zvalue: array of TZValue; intCmdReturn: TIntCmdReturnG); overload;
    procedure ZAddNXCh(Key: string; zvalue: array of TZStrValue; intCmdReturn: TIntCmdReturn); overload;
    procedure ZAddNXCh(Key: string; zvalue: array of TZStrValue; intCmdReturn: TIntCmdReturnA); overload;
    procedure ZAddNXCh(Key: string; zvalue: array of TZStrValue; intCmdReturn: TIntCmdReturnG); overload;
    procedure ZAddNXCh(Key: string; zvalue: array of TZValue; intCmdReturn: TIntCmdReturn); overload;
    procedure ZAddNXCh(Key: string; zvalue: array of TZValue; intCmdReturn: TIntCmdReturnA); overload;
    procedure ZAddNXCh(Key: string; zvalue: array of TZValue; intCmdReturn: TIntCmdReturnG); overload;
    procedure ZAddXXCh(Key: string; zvalue: array of TZStrValue; intCmdReturn: TIntCmdReturn); overload;
    procedure ZAddXXCh(Key: string; zvalue: array of TZStrValue; intCmdReturn: TIntCmdReturnA); overload;
    procedure ZAddXXCh(Key: string; zvalue: array of TZStrValue; intCmdReturn: TIntCmdReturnG); overload;
    procedure ZAddXXCh(Key: string; zvalue: array of TZValue; intCmdReturn: TIntCmdReturn); overload;
    procedure ZAddXXCh(Key: string; zvalue: array of TZValue; intCmdReturn: TIntCmdReturnA); overload;
    procedure ZAddXXCh(Key: string; zvalue: array of TZValue; intCmdReturn: TIntCmdReturnG); overload;
    procedure ZCard(Key: string; intCmdReturn: TIntCmdReturn); overload;
    procedure ZCard(Key: string; intCmdReturn: TIntCmdReturnA); overload;
    procedure ZCard(Key: string; intCmdReturn: TIntCmdReturnG); overload;
    procedure ZCount(Key, min, max: string; intCmdReturn: TIntCmdReturn); overload;
    procedure ZCount(Key, min, max: string; intCmdReturn: TIntCmdReturnA); overload;
    procedure ZCount(Key, min, max: string; intCmdReturn: TIntCmdReturnG); overload;
    procedure ZLexCount(Key, min, max: string; intCmdReturn: TIntCmdReturn); overload;
    procedure ZLexCount(Key, min, max: string; intCmdReturn: TIntCmdReturnA); overload;
    procedure ZLexCount(Key, min, max: string; intCmdReturn: TIntCmdReturnG); overload;
    procedure ZRemRangeByRank(Key: string; Start, stop: Int64; intCmdReturn: TIntCmdReturn); overload;
    procedure ZRemRangeByRank(Key: string; Start, stop: Int64; intCmdReturn: TIntCmdReturnA); overload;
    procedure ZRemRangeByRank(Key: string; Start, stop: Int64; intCmdReturn: TIntCmdReturnG); overload;
    procedure ZRank(Key, Member: string; intCmdReturn: TIntCmdReturn); overload;
    procedure ZRank(Key, Member: string; intCmdReturn: TIntCmdReturnA); overload;
    procedure ZRank(Key, Member: string; intCmdReturn: TIntCmdReturnG); overload;
    procedure ZRem(Key: string; membersArr: array of string; intCmdReturn: TIntCmdReturn); overload;
    procedure ZRem(Key: string; membersArr: array of string; intCmdReturn: TIntCmdReturnA); overload;
    procedure ZRem(Key: string; membersArr: array of string; intCmdReturn: TIntCmdReturnG); overload;
    procedure ZRem(Key: string; membersArr: array of TValueInterface; intCmdReturn: TIntCmdReturn); overload;
    procedure ZRem(Key: string; membersArr: array of TValueInterface; intCmdReturn: TIntCmdReturnA); overload;
    procedure ZRem(Key: string; membersArr: array of TValueInterface; intCmdReturn: TIntCmdReturnG); overload;
    procedure ZRemRangeByScore(Key, min, max: string; intCmdReturn: TIntCmdReturn); overload;
    procedure ZRemRangeByScore(Key, min, max: string; intCmdReturn: TIntCmdReturnA); overload;
    procedure ZRemRangeByScore(Key, min, max: string; intCmdReturn: TIntCmdReturnG); overload;
    procedure ZRemRangeByLex(Key, min, max: string; intCmdReturn: TIntCmdReturn); overload;
    procedure ZRemRangeByLex(Key, min, max: string; intCmdReturn: TIntCmdReturnA); overload;
    procedure ZRemRangeByLex(Key, min, max: string; intCmdReturn: TIntCmdReturnG); overload;

    // 返回秒
    procedure ttl(Key: string; intCmdReturn: TIntCmdReturn); overload;
    procedure ttl(Key: string; intCmdReturn: TIntCmdReturnA); overload;
    procedure ttl(Key: string; intCmdReturn: TIntCmdReturnG); overload;
    // 返回毫秒
    procedure pttl(Key: string; intCmdReturn: TIntCmdReturn); overload;
    procedure pttl(Key: string; intCmdReturn: TIntCmdReturnA); overload;
    procedure pttl(Key: string; intCmdReturn: TIntCmdReturnG); overload;

    procedure MGet(keys: array of string; block: Boolean;CmdReturn: TStringSliceCmdReturn); overload;
    procedure MGet(keys: array of string; block: Boolean;CmdReturn: TStringSliceCmdReturnA); overload;
    procedure MGet(keys: array of string; block: Boolean;CmdReturn: TStringSliceCmdReturnG); overload;

    procedure Expire(Key: string; expiration: Integer; CmdReturn: TBoolCmdReturn); overload;
    procedure Expire(Key: string; expiration: Integer; CmdReturn: TBoolCmdReturnA); overload;
    procedure Expire(Key: string; expiration: Integer; CmdReturn: TBoolCmdReturnG); overload;
    procedure ExpireAt(Key: string; atTime: TDateTime; CmdReturn: TBoolCmdReturn); overload;
    procedure ExpireAt(Key: string; atTime: TDateTime; CmdReturn: TBoolCmdReturnA); overload;
    procedure ExpireAt(Key: string; atTime: TDateTime; CmdReturn: TBoolCmdReturnG); overload;
    procedure PExpire(Key: string; expiration: Integer; CmdReturn: TBoolCmdReturn); overload;
    procedure PExpire(Key: string; expiration: Integer; CmdReturn: TBoolCmdReturnA); overload;
    procedure PExpire(Key: string; expiration: Integer; CmdReturn: TBoolCmdReturnG); overload;
    procedure PExpireAt(Key: string; atTime: TDateTime; CmdReturn: TBoolCmdReturn); overload;
    procedure PExpireAt(Key: string; atTime: TDateTime; CmdReturn: TBoolCmdReturnA); overload;
    procedure PExpireAt(Key: string; atTime: TDateTime; CmdReturn: TBoolCmdReturnG); overload;
    procedure Move(Key: string; db: Integer; CmdReturn: TBoolCmdReturn); overload;
    procedure Move(Key: string; db: Integer; CmdReturn: TBoolCmdReturnA); overload;
    procedure Move(Key: string; db: Integer; CmdReturn: TBoolCmdReturnG); overload;
    procedure Persist(Key: string; CmdReturn: TBoolCmdReturn); overload;
    procedure Persist(Key: string; CmdReturn: TBoolCmdReturnA); overload;
    procedure Persist(Key: string; CmdReturn: TBoolCmdReturnG); overload;
    procedure RenameNX(Key, NewKey: string; CmdReturn: TBoolCmdReturn); overload;
    procedure RenameNX(Key, NewKey: string; CmdReturn: TBoolCmdReturnA); overload;
    procedure RenameNX(Key, NewKey: string; CmdReturn: TBoolCmdReturnG); overload;
    procedure MSetNX(keyValues: array of TKeyValue; CmdReturn: TBoolCmdReturn); overload;
    procedure MSetNX(keyValues: array of TKeyValue; CmdReturn: TBoolCmdReturnA); overload;
    procedure MSetNX(keyValues: array of TKeyValue; CmdReturn: TBoolCmdReturnG); overload;
    procedure MSetNX(keyValues: array of TRedisKeyValue; CmdReturn: TBoolCmdReturn); overload;
    procedure MSetNX(keyValues: array of TRedisKeyValue; CmdReturn: TBoolCmdReturnA); overload;
    procedure MSetNX(keyValues: array of TRedisKeyValue; CmdReturn: TBoolCmdReturnG); overload;
    procedure SetNX(Key, Value: string; expiration: Integer; CmdReturn: TBoolCmdReturn); overload;
    procedure SetNX(Key, Value: string; expiration: Integer; CmdReturn: TBoolCmdReturnA); overload;
    procedure SetNX(Key, Value: string; expiration: Integer; CmdReturn: TBoolCmdReturnG); overload;
    procedure SetNX(Key: string; ValueBuffer: PByte; buffLen, expiration: Integer; CmdReturn: TBoolCmdReturn); overload;
    procedure SetNX(Key: string; ValueBuffer: PByte; buffLen, expiration: Integer; CmdReturn: TBoolCmdReturnA); overload;
    procedure SetNX(Key: string; ValueBuffer: PByte; buffLen, expiration: Integer; CmdReturn: TBoolCmdReturnG); overload;
    procedure SetXX(Key, Value: string; expiration: Integer; CmdReturn: TBoolCmdReturn); overload;
    procedure SetXX(Key, Value: string; expiration: Integer; CmdReturn: TBoolCmdReturnA); overload;
    procedure SetXX(Key, Value: string; expiration: Integer; CmdReturn: TBoolCmdReturnG); overload;
    procedure SetXX(Key: string; ValueBuffer: PByte; buffLen, expiration: Integer; CmdReturn: TBoolCmdReturn); overload;
    procedure SetXX(Key: string; ValueBuffer: PByte; buffLen, expiration: Integer; CmdReturn: TBoolCmdReturnA); overload;
    procedure SetXX(Key: string; ValueBuffer: PByte; buffLen, expiration: Integer; CmdReturn: TBoolCmdReturnG); overload;
    procedure HExists(Key, field: string; CmdReturn: TBoolCmdReturn); overload;
    procedure HExists(Key, field: string; CmdReturn: TBoolCmdReturnA); overload;
    procedure HExists(Key, field: string; CmdReturn: TBoolCmdReturnG); overload;
    procedure HMSet(Key: string; keyValues: array of TKeyValue; CmdReturn: TBoolCmdReturn); overload;
    procedure HMSet(Key: string; keyValues: array of TKeyValue; CmdReturn: TBoolCmdReturnA); overload;
    procedure HMSet(Key: string; keyValues: array of TKeyValue; CmdReturn: TBoolCmdReturnG); overload;
    procedure HMSet(Key: string; keyValues: array of TRedisKeyValue; CmdReturn: TBoolCmdReturn); overload;
    procedure HMSet(Key: string; keyValues: array of TRedisKeyValue; CmdReturn: TBoolCmdReturnA); overload;
    procedure HMSet(Key: string; keyValues: array of TRedisKeyValue; CmdReturn: TBoolCmdReturnG); overload;
    procedure HSetNX(Key, field, Value: string; CmdReturn: TBoolCmdReturn); overload;
    procedure HSetNX(Key, field, Value: string; CmdReturn: TBoolCmdReturnA); overload;
    procedure HSetNX(Key, field, Value: string; CmdReturn: TBoolCmdReturnG); overload;
    procedure HSetNX(Key, field: string; ValueBuffer: PByte; buffLen: Integer; CmdReturn: TBoolCmdReturn); overload;
    procedure HSetNX(Key, field: string; ValueBuffer: PByte; buffLen: Integer; CmdReturn: TBoolCmdReturnA); overload;
    procedure HSetNX(Key, field: string; ValueBuffer: PByte; buffLen: Integer; CmdReturn: TBoolCmdReturnG); overload;
    procedure SIsMember(Key, Value: string; CmdReturn: TBoolCmdReturn); overload;
    procedure SIsMember(Key, Value: string; CmdReturn: TBoolCmdReturnA); overload;
    procedure SIsMember(Key, Value: string; CmdReturn: TBoolCmdReturnG); overload;
    procedure SIsMember(Key: string; ValueBuffer: PByte; buffLen: Integer; CmdReturn: TBoolCmdReturn); overload;
    procedure SIsMember(Key: string; ValueBuffer: PByte; buffLen: Integer; CmdReturn: TBoolCmdReturnA); overload;
    procedure SIsMember(Key: string; ValueBuffer: PByte; buffLen: Integer; CmdReturn: TBoolCmdReturnG); overload;
    procedure SMove(source, destination, Member: string; CmdReturn: TBoolCmdReturn); overload;
    procedure SMove(source, destination, Member: string; CmdReturn: TBoolCmdReturnA); overload;
    procedure SMove(source, destination, Member: string; CmdReturn: TBoolCmdReturnG); overload;
    procedure SMove(source, destination: string; Member: PByte; memberLen: Integer; CmdReturn: TBoolCmdReturn); overload;
    procedure SMove(source, destination: string; Member: PByte; memberLen: Integer; CmdReturn: TBoolCmdReturnA); overload;
    procedure SMove(source, destination: string; Member: PByte; memberLen: Integer; CmdReturn: TBoolCmdReturnG); overload;
    procedure ClientPause(pauseTime: Integer; CmdReturn: TBoolCmdReturn); overload;
    procedure ClientPause(pauseTime: Integer; CmdReturn: TBoolCmdReturnA); overload;
    procedure ClientPause(pauseTime: Integer; CmdReturn: TBoolCmdReturnG); overload;
    procedure keys(pattern: string; CmdReturn: TRedisScanCmdReturn); overload;
    procedure keys(pattern: string; CmdReturn: TRedisScanCmdReturnA); overload;
    procedure keys(pattern: string; CmdReturn: TRedisScanCmdReturnG); overload;
    procedure Sort(Key: string; Sort: TRedisSort; CmdReturn: TStringSliceCmdReturn); overload;
    procedure Sort(Key: string; Sort: TRedisSort; CmdReturn: TStringSliceCmdReturnA); overload;
    procedure Sort(Key: string; Sort: TRedisSort; CmdReturn: TStringSliceCmdReturnG); overload;
    procedure SortStore(Key, storeKey: string; Sort: TRedisSort; CmdReturn: TIntCmdReturn); overload;
    procedure SortStore(Key, storeKey: string; Sort: TRedisSort; CmdReturn: TIntCmdReturnA); overload;
    procedure SortStore(Key, storeKey: string; Sort: TRedisSort; CmdReturn: TIntCmdReturnG); overload;
    procedure HKeys(Key: string; CmdReturn: TRedisScanCmdReturn); overload;
    procedure HKeys(Key: string; CmdReturn: TRedisScanCmdReturnA); overload;
    procedure HKeys(Key: string; CmdReturn: TRedisScanCmdReturnG); overload;
    procedure HVals(Key: string; CmdReturn: TStringSliceCmdReturn); overload;
    procedure HVals(Key: string; CmdReturn: TStringSliceCmdReturnA); overload;
    procedure HVals(Key: string; CmdReturn: TStringSliceCmdReturnG); overload;
    procedure HRandField(Key: string; count: Integer; withValues: Boolean; CmdReturn: TStringSliceCmdReturn); overload;
    procedure HRandField(Key: string; count: Integer; withValues: Boolean; CmdReturn: TStringSliceCmdReturnA); overload;
    procedure HRandField(Key: string; count: Integer; withValues: Boolean; CmdReturn: TStringSliceCmdReturnG); overload;
    procedure BRPop(timeout: Integer; keys: array of string; CmdReturn: TStringSliceCmdReturn); overload;
    procedure BRPop(timeout: Integer; keys: array of string; CmdReturn: TStringSliceCmdReturnA); overload;
    procedure BRPop(timeout: Integer; keys: array of string; CmdReturn: TStringSliceCmdReturnG); overload;
    procedure BLPop(timeout: Integer; keys: array of string; CmdReturn: TStringSliceCmdReturn); overload;
    procedure BLPop(timeout: Integer; keys: array of string; CmdReturn: TStringSliceCmdReturnA); overload;
    procedure BLPop(timeout: Integer; keys: array of string; CmdReturn: TStringSliceCmdReturnG); overload;
    procedure LPopCount(Key: string; count: Integer; CmdReturn: TStringSliceCmdReturn); overload;
    procedure LPopCount(Key: string; count: Integer; CmdReturn: TStringSliceCmdReturnA); overload;
    procedure LPopCount(Key: string; count: Integer; CmdReturn: TStringSliceCmdReturnG); overload;
    procedure LRange(Key: string; Start, stop: Int64; CmdReturn: TStringSliceCmdReturn); overload;
    procedure LRange(Key: string; Start, stop: Int64; CmdReturn: TStringSliceCmdReturnA); overload;
    procedure LRange(Key: string; Start, stop: Int64; CmdReturn: TStringSliceCmdReturnG); overload;
    procedure ZRange(Key: string; Start, stop: Int64; CmdReturn: TStringSliceCmdReturn); overload;
    procedure ZRange(Key: string; Start, stop: Int64; CmdReturn: TStringSliceCmdReturnA); overload;
    procedure ZRange(Key: string; Start, stop: Int64; CmdReturn: TStringSliceCmdReturnG); overload;
    procedure ZRevRange(Key: string; Start, stop: Int64; CmdReturn: TStringSliceCmdReturn); overload;
    procedure ZRevRange(Key: string; Start, stop: Int64; CmdReturn: TStringSliceCmdReturnA); overload;
    procedure ZRevRange(Key: string; Start, stop: Int64; CmdReturn: TStringSliceCmdReturnG); overload;
    procedure ZRangeByScore(Key: string; opt: TRedisRangeBy; CmdReturn: TStringSliceCmdReturn); overload;
    procedure ZRangeByScore(Key: string; opt: TRedisRangeBy; CmdReturn: TStringSliceCmdReturnA); overload;
    procedure ZRangeByScore(Key: string; opt: TRedisRangeBy; CmdReturn: TStringSliceCmdReturnG); overload;
    procedure ZRangeByLex(Key: string; opt: TRedisRangeBy; CmdReturn: TStringSliceCmdReturn); overload;
    procedure ZRangeByLex(Key: string; opt: TRedisRangeBy; CmdReturn: TStringSliceCmdReturnA); overload;
    procedure ZRangeByLex(Key: string; opt: TRedisRangeBy; CmdReturn: TStringSliceCmdReturnG); overload;
    procedure SDiff(keys: array of string; CmdReturn: TStringSliceCmdReturn); overload;
    procedure SDiff(keys: array of string; CmdReturn: TStringSliceCmdReturnA); overload;
    procedure SDiff(keys: array of string; CmdReturn: TStringSliceCmdReturnG); overload;
    procedure SUnion(keys: array of string; CmdReturn: TStringSliceCmdReturn); overload;
    procedure SUnion(keys: array of string; CmdReturn: TStringSliceCmdReturnA); overload;
    procedure SUnion(keys: array of string; CmdReturn: TStringSliceCmdReturnG); overload;
    procedure SInter(keys: array of string; CmdReturn: TStringSliceCmdReturn); overload;
    procedure SInter(keys: array of string; CmdReturn: TStringSliceCmdReturnA); overload;
    procedure SInter(keys: array of string; CmdReturn: TStringSliceCmdReturnG); overload;
    procedure SMembers(Key: string; CmdReturn: TStringSliceCmdReturn); overload;
    procedure SMembers(Key: string; CmdReturn: TStringSliceCmdReturnA); overload;
    procedure SMembers(Key: string; CmdReturn: TStringSliceCmdReturnG); overload;
    procedure SPopN(Key: string; count: Int64; CmdReturn: TStringSliceCmdReturn); overload;
    procedure SPopN(Key: string; count: Int64; CmdReturn: TStringSliceCmdReturnA); overload;
    procedure SPopN(Key: string; count: Int64; CmdReturn: TStringSliceCmdReturnG); overload;
    procedure SRandMemberN(Key: string; count: Int64; CmdReturn: TStringSliceCmdReturn); overload;
    procedure SRandMemberN(Key: string; count: Int64; CmdReturn: TStringSliceCmdReturnA); overload;
    procedure SRandMemberN(Key: string; count: Int64; CmdReturn: TStringSliceCmdReturnG); overload;
    procedure ZRevRangeByScore(Key: string; opt: TRedisRangeBy; CmdReturn: TStringSliceCmdReturn); overload;
    procedure ZRevRangeByScore(Key: string; opt: TRedisRangeBy; CmdReturn: TStringSliceCmdReturnA); overload;
    procedure ZRevRangeByScore(Key: string; opt: TRedisRangeBy; CmdReturn: TStringSliceCmdReturnG); overload;
    procedure ZRevRangeByLex(Key: string; opt: TRedisRangeBy; CmdReturn: TStringSliceCmdReturn); overload;
    procedure ZRevRangeByLex(Key: string; opt: TRedisRangeBy; CmdReturn: TStringSliceCmdReturnA); overload;
    procedure ZRevRangeByLex(Key: string; opt: TRedisRangeBy; CmdReturn: TStringSliceCmdReturnG); overload;
    procedure ZRandMember(Key: string; count: Integer; withScores: Boolean; CmdReturn: TStringSliceCmdReturn); overload;
    procedure ZRandMember(Key: string; count: Integer; withScores: Boolean; CmdReturn: TStringSliceCmdReturnA); overload;
    procedure ZRandMember(Key: string; count: Integer; withScores: Boolean; CmdReturn: TStringSliceCmdReturnG); overload;
    procedure ZDiff(keys: array of string; CmdReturn: TStringSliceCmdReturn); overload;
    procedure ZDiff(keys: array of string; CmdReturn: TStringSliceCmdReturnA); overload;
    procedure ZDiff(keys: array of string; CmdReturn: TStringSliceCmdReturnG); overload;
    procedure Execute(block: Boolean); overload;
    procedure Execute(block: Boolean; execReturn: TPipelineExecReturn); overload;
    procedure Execute(block: Boolean; execReturn: TPipelineExecReturnA); overload;
    procedure Execute(block: Boolean; execReturn: TPipelineExecReturnG); overload;
    property dbIndex: Integer read FDbIndex write FDbIndex; // 操作的数据库
    property Owner: TDxRedisClient read FOwner;
  end;

implementation

uses
  cmdCallBack;

type
  TDxRedisSdkManagerEx = class(TDxRedisSdkManager);

  TDxRedisClientEx = class(TDxRedisClient);
  { TDxPipeClient }

procedure TDxPipeClient.Ping(StatusCmdReturn: TRedisStatusCmd);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(StatusCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FPing(PipeClient, False, statusCmdResult, Mnd);
end;

procedure TDxPipeClient.Ping(StatusCmdReturn: TRedisStatusCmdA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PMethod;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStatusCmdA(@TMethod(ATemp).Code)^ := StatusCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FPing(PipeClient, False, statusCmdResult, Mnd);
end;

procedure TDxPipeClient.Execute(block: Boolean);
begin
  AtomicIncrement(TDxRedisClientEx(FOwner).FRunningCount, 1);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FPipeExec(PipeClient, block, nil, nil);
end;

procedure TDxPipeClient.Ping(StatusCmdReturn: TRedisStatusCmdG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TRedisStatusCmdA(Mnd^.Code) := StatusCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FPing(PipeClient, False, statusCmdResult, Mnd);
end;

procedure TDxPipeClient.pttl(Key: string; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FPTTL(PipeClient, PChar(Key), False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.pttl(Key: string; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FPTTL(PipeClient, PChar(Key), False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.pttl(Key: string; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FPTTL(PipeClient, PChar(Key), False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.TypeCmd(Key: string; StatusCmdReturn: TRedisStatusCmd);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(StatusCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FType(PipeClient, PChar(Key), False, statusCmdResult, Mnd);
end;

procedure TDxPipeClient.TypeCmd(Key: string; StatusCmdReturn: TRedisStatusCmdA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PMethod;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStatusCmdA(@TMethod(ATemp).Code)^ := StatusCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FType(PipeClient, PChar(Key), False, statusCmdResult, Mnd);
end;

procedure TDxPipeClient.Touch(keys: array of string; intCmdReturn: TIntCmdReturn);
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
    TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FTouch(PipeClient, PChar(keyList), False, intCmdResult, Mnd);
  end;

end;

procedure TDxPipeClient.Touch(keys: array of string; intCmdReturn: TIntCmdReturnA);
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

    TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FTouch(PipeClient, PChar(keyList), False, intCmdResult, Mnd);
  end;

end;

procedure TDxPipeClient.Touch(keys: array of string; intCmdReturn: TIntCmdReturnG);
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

    TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FTouch(PipeClient, PChar(keyList), False, intCmdResult, Mnd);
  end;

end;

procedure TDxPipeClient.ttl(Key: string; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FTTL(PipeClient, PChar(Key), False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.ttl(Key: string; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FTTL(PipeClient, PChar(Key), False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.ttl(Key: string; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FTTL(PipeClient, PChar(Key), False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.TypeCmd(Key: string; StatusCmdReturn: TRedisStatusCmdG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TRedisStatusCmdA(Mnd^.Code) := StatusCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FType(PipeClient, PChar(Key), False, statusCmdResult, Mnd);
end;

procedure TDxPipeClient.Unlink(keys: array of string; intCmdReturn: TIntCmdReturn);
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

    TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FUnlink(PipeClient, PChar(keyList), False, intCmdResult, Mnd);
  end;

end;

procedure TDxPipeClient.Unlink(keys: array of string; intCmdReturn: TIntCmdReturnA);
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

    TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FUnlink(PipeClient, PChar(keyList), False, intCmdResult, Mnd);
  end;

end;

procedure TDxPipeClient.Unlink(keys: array of string; intCmdReturn: TIntCmdReturnG);
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

    TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FUnlink(PipeClient, PChar(keyList), False, intCmdResult, Mnd);
  end;

end;

procedure TDxPipeClient.XAdd(stream, ID: string; MaxLen, MaxLenApprox: Int64; Value: string; stringCmdReturn: TRedisStringCmdReturn);
var
  Mnd: PStringCmdMethod;
  args: TxAddArgs;
begin
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method := TMethod(stringCmdReturn);

  args.stream := PChar(stream);
  args.ID := PChar(ID);
  args.MaxLen := MaxLen;
  args.MaxLenApprox := MaxLenApprox;
  args.VLen := 0;
  args.Value := PChar(Value);

  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FXAdd(PipeClient, @args, False, stringCmdResult, Mnd)
end;

procedure TDxPipeClient.XAdd(stream, ID: string; MaxLen, MaxLenApprox: Int64; Value: string; stringCmdReturn: TRedisStringCmdReturnA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PStringCmdMethod;
  args: TxAddArgs;
begin
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
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FXAdd(PipeClient, @args, False, stringCmdResult, Mnd)
end;

procedure TDxPipeClient.XAdd(stream, ID: string; MaxLen, MaxLenApprox: Int64; Value: string; stringCmdReturn: TRedisStringCmdReturnG);
var
  Mnd: PStringCmdMethod;
  args: TxAddArgs;
begin
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
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FXAdd(PipeClient, @args, False, stringCmdResult, Mnd)
end;

procedure TDxPipeClient.ZScan(cursor: UInt64; Key, match: string; count: Int64; scanCmdReturn: TRedisScanKScoreCmdReturn);
var
  Mnd: PScanMethod;
begin
  New(Mnd);
  Mnd^.Method := TMethod(scanCmdReturn);
  Mnd^.ScanResultType := scanResultValue;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZScan(PipeClient, cursor, PChar(Key), PChar(match), count, False, scanCmdResult, Mnd);
end;

procedure TDxPipeClient.ZScan(cursor: UInt64; Key, match: string; count: Int64; scanCmdReturn: TRedisScanKScoreCmdReturnA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PScanMethod;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisScanKScoreCmdReturnA(@TMethod(ATemp).Code)^ := scanCmdReturn;
  New(Mnd);
  Mnd^.Method := TMethod(ATemp);
  Mnd^.ScanResultType := scanResultScoreValue;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZScan(PipeClient, cursor, PChar(Key), PChar(match), count, False, scanCmdResult, Mnd);
end;

procedure TDxPipeClient.ZScan(cursor: UInt64; Key, match: string; count: Int64; scanCmdReturn: TRedisScanKScoreCmdReturnG);
var
  Mnd: PScanMethod;
begin
  New(Mnd);
  Mnd^.Method.Data := nil;
  Mnd^.ScanResultType := scanResultScoreValue;
  TRedisScanKScoreCmdReturnA(Mnd^.Method.Code) := scanCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZScan(PipeClient, cursor, PChar(Key), PChar(match), count, False, scanCmdResult, Mnd);
end;

procedure TDxPipeClient.BRPopLPush(src, dst: string; timeout: Integer; stringCmdReturn: TRedisStringCmdReturn);
var
  Mnd: PStringCmdMethod;
begin
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method := TMethod(stringCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FBRPopLPush(PipeClient, PChar(src), PChar(dst), timeout, False, False, stringCmdResult, Mnd);
end;

procedure TDxPipeClient.BRPopLPush(src, dst: string; timeout: Integer; stringCmdReturn: TRedisStringCmdReturnA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PStringCmdMethod;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStringCmdReturnA(@TMethod(ATemp).Code)^ := stringCmdReturn;
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FBRPopLPush(PipeClient, PChar(src), PChar(dst), timeout, False, False, stringCmdResult, Mnd);
end;

procedure TDxPipeClient.BRPopLPush(src, dst: string; timeout: Integer; stringCmdReturn: TRedisStringCmdReturnG);
var
  Mnd: PStringCmdMethod;
begin
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method.Data := nil;
  TRedisStringCmdReturnA(Mnd^.Method.Code) := stringCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FBRPopLPush(PipeClient, PChar(src), PChar(dst), timeout, False, False, stringCmdResult, Mnd);
end;

procedure TDxPipeClient.ClientList(stringCmdReturn: TRedisStringCmdReturn);
var
  Mnd: PStringCmdMethod;
begin
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method := TMethod(stringCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FClientList(PipeClient, False, stringCmdResult, Mnd)
end;

procedure TDxPipeClient.ClientList(stringCmdReturn: TRedisStringCmdReturnA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PStringCmdMethod;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStringCmdReturnA(@TMethod(ATemp).Code)^ := stringCmdReturn;
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FClientList(PipeClient, False, stringCmdResult, Mnd)
end;

procedure TDxPipeClient.ClientList(stringCmdReturn: TRedisStringCmdReturnG);
var
  Mnd: PStringCmdMethod;
begin
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method.Data := nil;
  TRedisStringCmdReturnA(Mnd^.Method.Code) := stringCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FClientList(PipeClient, False, stringCmdResult, Mnd)
end;

constructor TDxPipeClient.Create(Owner: TDxRedisClient);
begin
  inherited Create;
  FOwner := Owner;
end;

procedure TDxPipeClient.Del(keys: array of string; intCmdReturn: TIntCmdReturn);
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

    TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FDel(PipeClient, PChar(keyList), False, intCmdResult, Mnd);
  end;

end;

procedure TDxPipeClient.Del(keys: array of string; intCmdReturn: TIntCmdReturnA);
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

    TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FDel(PipeClient, PChar(keyList), False, intCmdResult, Mnd);
  end;

end;

procedure TDxPipeClient.Decr(Key: string; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FDecr(PipeClient, PChar(Key), False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.Decr(Key: string; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FDecr(PipeClient, PChar(Key), False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.Decr(Key: string; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FDecr(PipeClient, PChar(Key), False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.DecrBy(Key: string; decrement: Int64; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FDecrBy(PipeClient, PChar(Key), decrement, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.DecrBy(Key: string; decrement: Int64; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FDecrBy(PipeClient, PChar(Key), decrement, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.DecrBy(Key: string; decrement: Int64; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FDecrBy(PipeClient, PChar(Key), decrement, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.Incr(Key: string; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FIncr(PipeClient, PChar(Key), False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.Incr(Key: string; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FIncr(PipeClient, PChar(Key), False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.Incr(Key: string; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FIncr(PipeClient, PChar(Key), False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.StrLen(Key: string; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FStrLen(PipeClient, PChar(Key), False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.StrLen(Key: string; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FStrLen(PipeClient, PChar(Key), False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.StrLen(Key: string; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FStrLen(PipeClient, PChar(Key), False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.IncrBy(Key: string; increment: Int64; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FIncrBy(PipeClient, PChar(Key), increment, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.IncrBy(Key: string; increment: Int64; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FIncrBy(PipeClient, PChar(Key), increment, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.IncrBy(Key: string; increment: Int64; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FIncrBy(PipeClient, PChar(Key), increment, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.IncrByFloat(Key: string; increment: Double;
  block: Boolean; floatCmdReturn: TfloatCmdReturn);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(floatCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FIncrByFloat(PipeClient, PChar(Key), increment, False, floatCmdResult, Mnd);
end;

procedure TDxPipeClient.IncrByFloat(Key: string; increment: Double;
  block: Boolean; floatCmdReturn: TfloatCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TfloatCmdReturn;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PfloatCmdReturnA(@TMethod(ATemp).Code)^ := floatCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FIncrByFloat(PipeClient, PChar(Key), increment, False, floatCmdResult, Mnd);
end;

procedure TDxPipeClient.IncrByFloat(Key: string; increment: Double;
  block: Boolean; floatCmdReturn: TfloatCmdReturnG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TfloatCmdReturnA(Mnd^.Code) := floatCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FIncrByFloat(PipeClient, PChar(Key), increment, False, floatCmdResult, Mnd);
end;

procedure TDxPipeClient.Del(keys: array of string; intCmdReturn: TIntCmdReturnG);
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

    TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FDel(PipeClient, PChar(keyList), False, intCmdResult, Mnd);
  end;

end;

destructor TDxPipeClient.Destroy;
begin
  FreePipeClient;
  inherited;
end;

procedure TDxPipeClient.Exists(keys: array of string; intCmdReturn: TIntCmdReturn);
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

    TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FExists(PipeClient, PChar(keyList), False, intCmdResult, Mnd);
  end;

end;

procedure TDxPipeClient.Exists(keys: array of string; intCmdReturn: TIntCmdReturnA);
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

    TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FExists(PipeClient, PChar(keyList), False, intCmdResult, Mnd);
  end;

end;

procedure TDxPipeClient.Execute(block: Boolean; execReturn: TPipelineExecReturn);
var
  Mnd: PMethod;
begin
  AtomicIncrement(TDxRedisClientEx(FOwner).FRunningCount, 1);
  New(Mnd);
  Mnd^ := TMethod(execReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FPipeExec(PipeClient, block, PipeExecReturn, Mnd);
end;

procedure TDxPipeClient.Execute(block: Boolean; execReturn: TPipelineExecReturnA);
var
  Mnd: PMethod;
  ATemp: TPipelineExecReturn;
begin
  AtomicIncrement(TDxRedisClientEx(FOwner).FRunningCount, 1);
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PPipelineExecReturnA(@TMethod(ATemp).Code)^ := execReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FPipeExec(PipeClient, block, PipeExecReturn, Mnd);
end;

procedure TDxPipeClient.Execute(block: Boolean; execReturn: TPipelineExecReturnG);
var
  Mnd: PMethod;
begin
  AtomicIncrement(TDxRedisClientEx(FOwner).FRunningCount, 1);
  New(Mnd);
  Mnd^.Data := nil;
  TPipelineExecReturnA(Mnd^.Code) := execReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FPipeExec(PipeClient, block, PipeExecReturn, Mnd);
end;

procedure TDxPipeClient.Exists(keys: array of string; intCmdReturn: TIntCmdReturnG);
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
    TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FExists(PipeClient, PChar(keyList), False, intCmdResult, Mnd);
  end;

end;

procedure TDxPipeClient.FreePipeClient;
begin
  if (FPipeData <> nil) and (FOwner <> nil) then
  begin
    TDxRedisClientEx(FOwner).FreePipeline(Self);
    FPipeData := nil;
    FOwner := nil;
  end;
end;

procedure TDxPipeClient.get(Key: string; stringCmdReturn: TRedisStringCmdReturn);
var
  Mnd: PStringCmdMethod;
begin
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method := TMethod(stringCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FGet(PipeClient, PChar(Key), False, False, stringCmdResult, Mnd);
end;

procedure TDxPipeClient.get(Key: string; stringCmdReturn: TRedisStringCmdReturnA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PStringCmdMethod;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStringCmdReturnA(@TMethod(ATemp).Code)^ := stringCmdReturn;
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FGet(PipeClient, PChar(Key), False, False, stringCmdResult, Mnd);
end;

procedure TDxPipeClient.get(Key: string; stringCmdReturn: TRedisStringCmdReturnG);
var
  Mnd: PStringCmdMethod;
begin
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method.Data := nil;
  TRedisStringCmdReturnA(Mnd^.Method.Code) := stringCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FGet(PipeClient, PChar(Key), False, False, stringCmdResult, Mnd);
end;

procedure TDxPipeClient.get(Key: string; stringCmdReturn: TRedisStringCmdReturnByte);
var
  Mnd: PStringCmdMethod;
begin
  New(Mnd);
  Mnd^.Method := TMethod(stringCmdReturn);
  Mnd^.isByteReturn := True;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FGet(PipeClient, PChar(Key), True, False, stringCmdResult, Mnd);
end;

procedure TDxPipeClient.get(Key: string; stringCmdReturn: TRedisStringCmdReturnByteA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PStringCmdMethod;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStringCmdReturnByteA(@TMethod(ATemp).Code)^ := stringCmdReturn;
  New(Mnd);
  Mnd^.isByteReturn := True;
  Mnd^.Method := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FGet(PipeClient, PChar(Key), True, False, stringCmdResult, Mnd);
end;

procedure TDxPipeClient.GetEx(Key: string; expiration: Integer; stringCmdReturn: TRedisStringCmdReturnByte);
var
  Mnd: PStringCmdMethod;
begin
  New(Mnd);
  Mnd^.Method := TMethod(stringCmdReturn);
  Mnd^.isByteReturn := True;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FGetEx(PipeClient, PChar(Key), expiration, True, False, stringCmdResult, Mnd);
end;

procedure TDxPipeClient.GetEx(Key: string; expiration: Integer; stringCmdReturn: TRedisStringCmdReturnByteA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PStringCmdMethod;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStringCmdReturnByteA(@TMethod(ATemp).Code)^ := stringCmdReturn;
  New(Mnd);
  Mnd^.isByteReturn := True;
  Mnd^.Method := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FGetEx(PipeClient, PChar(Key), expiration, True, False, stringCmdResult, Mnd);
end;

procedure TDxPipeClient.GetDel(Key: string; stringCmdReturn: TRedisStringCmdReturnByte);
var
  Mnd: PStringCmdMethod;
begin
  New(Mnd);
  Mnd^.Method := TMethod(stringCmdReturn);
  Mnd^.isByteReturn := True;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FGetDel(PipeClient, PChar(Key), True, False, stringCmdResult, Mnd);
end;

procedure TDxPipeClient.GetDel(Key: string; stringCmdReturn: TRedisStringCmdReturnByteA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PStringCmdMethod;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStringCmdReturnByteA(@TMethod(ATemp).Code)^ := stringCmdReturn;
  New(Mnd);
  Mnd^.isByteReturn := True;
  Mnd^.Method := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FGetDel(PipeClient, PChar(Key), True, False, stringCmdResult, Mnd);
end;

procedure TDxPipeClient.GetDel(Key: string; stringCmdReturn: TRedisStringCmdReturnByteG);
var
  Mnd: PStringCmdMethod;
begin
  New(Mnd);
  Mnd^.Method.Data := nil;
  Mnd^.isByteReturn := True;
  TRedisStringCmdReturnByteA(Mnd^.Method.Code) := stringCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FGetDel(PipeClient, PChar(Key), True, False, stringCmdResult, Mnd);
end;

procedure TDxPipeClient.GetEx(Key: string; expiration: Integer; stringCmdReturn: TRedisStringCmdReturnByteG);
var
  Mnd: PStringCmdMethod;
begin
  New(Mnd);
  Mnd^.Method.Data := nil;
  Mnd^.isByteReturn := True;
  TRedisStringCmdReturnByteA(Mnd^.Method.Code) := stringCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FGetEx(PipeClient, PChar(Key), expiration, True, False, stringCmdResult, Mnd);
end;

function TDxPipeClient.GetPipeData: Pointer;
begin
  if FOwner = nil then
    Exit(nil);
  if FPipeData <> nil then
    Exit(FPipeData);
  FPipeData := TDxRedisClientEx(FOwner).NewPipeline(FTxPipeLine, Self);
  Result := FPipeData;
end;

procedure TDxPipeClient.get(Key: string; stringCmdReturn: TRedisStringCmdReturnByteG);
var
  Mnd: PStringCmdMethod;
begin
  New(Mnd);
  Mnd^.Method.Data := nil;
  Mnd^.isByteReturn := True;
  TRedisStringCmdReturnByteA(Mnd^.Method.Code) := stringCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FGet(PipeClient, PChar(Key), True, False, stringCmdResult, Mnd);
end;

procedure TDxPipeClient.GetDel(Key: string; stringCmdReturn: TRedisStringCmdReturn);
var
  Mnd: PStringCmdMethod;
begin
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method := TMethod(stringCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FGetDel(PipeClient, PChar(Key), False, False, stringCmdResult, Mnd);
end;

procedure TDxPipeClient.GetDel(Key: string; stringCmdReturn: TRedisStringCmdReturnA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PStringCmdMethod;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStringCmdReturnA(@TMethod(ATemp).Code)^ := stringCmdReturn;
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FGetDel(PipeClient, PChar(Key), False, False, stringCmdResult, Mnd);
end;

procedure TDxPipeClient.GetDel(Key: string; stringCmdReturn: TRedisStringCmdReturnG);
var
  Mnd: PStringCmdMethod;
begin
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method.Data := nil;
  TRedisStringCmdReturnA(Mnd^.Method.Code) := stringCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FGetDel(PipeClient, PChar(Key), False, False, stringCmdResult, Mnd);
end;

procedure TDxPipeClient.GetEx(Key: string; expiration: Integer; stringCmdReturn: TRedisStringCmdReturn);
var
  Mnd: PStringCmdMethod;
begin
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method := TMethod(stringCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FGetEx(PipeClient, PChar(Key), expiration, False, False, stringCmdResult, Mnd);
end;

procedure TDxPipeClient.GetEx(Key: string; expiration: Integer; stringCmdReturn: TRedisStringCmdReturnA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PStringCmdMethod;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStringCmdReturnA(@TMethod(ATemp).Code)^ := stringCmdReturn;
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FGetEx(PipeClient, PChar(Key), expiration, False, False, stringCmdResult, Mnd);
end;

procedure TDxPipeClient.GetEx(Key: string; expiration: Integer; stringCmdReturn: TRedisStringCmdReturnG);
var
  Mnd: PStringCmdMethod;
begin
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method.Data := nil;
  TRedisStringCmdReturnA(Mnd^.Method.Code) := stringCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FGetEx(PipeClient, PChar(Key), expiration, False, False, stringCmdResult, Mnd);
end;

procedure TDxPipeClient.GetRange(Key: string; Start, stop: Int64; stringCmdReturn: TRedisStringCmdReturn);
var
  Mnd: PStringCmdMethod;
begin
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method := TMethod(stringCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FGetRange(PipeClient, PChar(Key), Start, stop, False, False, stringCmdResult, Mnd);
end;

procedure TDxPipeClient.GetRange(Key: string; Start, stop: Int64; stringCmdReturnA: TRedisStringCmdReturnA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PStringCmdMethod;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStringCmdReturnA(@TMethod(ATemp).Code)^ := stringCmdReturnA;
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FGetRange(PipeClient, PChar(Key), Start, stop, False, False, stringCmdResult, Mnd);
end;

procedure TDxPipeClient.GetRange(Key: string; Start, stop: Int64; stringCmdReturnG: TRedisStringCmdReturnG);
var
  Mnd: PStringCmdMethod;
begin
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method.Data := nil;
  TRedisStringCmdReturnA(Mnd^.Method.Code) := stringCmdReturnG;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FGetRange(PipeClient, PChar(Key), Start, stop, False, False, stringCmdResult, Mnd);
end;

procedure TDxPipeClient.GetRange(Key: string; Start, stop: Int64; stringCmdReturn: TRedisStringCmdReturnByte);
var
  Mnd: PStringCmdMethod;
begin
  New(Mnd);
  Mnd^.Method := TMethod(stringCmdReturn);
  Mnd^.isByteReturn := True;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FGetRange(PipeClient, PChar(Key), Start, stop, True, False, stringCmdResult, Mnd);
end;

procedure TDxPipeClient.GetRange(Key: string; Start, stop: Int64; stringCmdReturnA: TRedisStringCmdReturnByteA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PStringCmdMethod;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStringCmdReturnByteA(@TMethod(ATemp).Code)^ := stringCmdReturnA;
  New(Mnd);
  Mnd^.isByteReturn := True;
  Mnd^.Method := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FGetRange(PipeClient, PChar(Key), Start, stop, True, False, stringCmdResult, Mnd);
end;

procedure TDxPipeClient.GetRange(Key: string; Start, stop: Int64; stringCmdReturnG: TRedisStringCmdReturnByteG);
var
  Mnd: PStringCmdMethod;
begin
  New(Mnd);
  Mnd^.isByteReturn := True;
  Mnd^.Method.Data := nil;
  TRedisStringCmdReturnByteA(Mnd^.Method.Code) := stringCmdReturnG;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FGetRange(PipeClient, PChar(Key), Start, stop, True, False, stringCmdResult, Mnd);
end;

procedure TDxPipeClient.GetSet(Key, Value: string; stringCmdReturn: TRedisStringCmdReturn);
var
  Mnd: PStringCmdMethod;
begin
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method := TMethod(stringCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FGetSet(PipeClient, PChar(Key), PChar(Value), 0, False, stringCmdResult, Mnd);
end;

procedure TDxPipeClient.GetSet(Key, Value: string; stringCmdReturn: TRedisStringCmdReturnA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PStringCmdMethod;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStringCmdReturnA(@TMethod(ATemp).Code)^ := stringCmdReturn;
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FGetSet(PipeClient, PChar(Key), PChar(Value), 0, False, stringCmdResult, Mnd);
end;

procedure TDxPipeClient.GetSet(Key, Value: string; stringCmdReturn: TRedisStringCmdReturnG);
var
  Mnd: PStringCmdMethod;
begin
  New(Mnd);
  Mnd^.isByteReturn := True;
  Mnd^.Method.Data := nil;
  TRedisStringCmdReturnA(Mnd^.Method.Code) := stringCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FGetSet(PipeClient, PChar(Key), PChar(Value), 0, False, stringCmdResult, Mnd);
end;

procedure TDxPipeClient.GetSet(Key: string; Value: PByte; ValueLen: Integer; stringCmdReturn: TRedisStringCmdReturnByte);
var
  Mnd: PStringCmdMethod;
begin
  New(Mnd);
  Mnd^.isByteReturn := True;
  Mnd^.Method := TMethod(stringCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FGetSet(PipeClient, PChar(Key), Value, ValueLen, False, stringCmdResult, Mnd);
end;

procedure TDxPipeClient.GetSet(Key: string; Value: PByte; ValueLen: Integer; stringCmdReturn: TRedisStringCmdReturnByteA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PStringCmdMethod;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStringCmdReturnByteA(@TMethod(ATemp).Code)^ := stringCmdReturn;
  New(Mnd);
  Mnd^.isByteReturn := True;
  Mnd^.Method := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FGetSet(PipeClient, PChar(Key), Value, ValueLen, False, stringCmdResult, Mnd);
end;

procedure TDxPipeClient.GetSet(Key: string; Value: PByte; ValueLen: Integer; stringCmdReturn: TRedisStringCmdReturnByteG);
var
  Mnd: PStringCmdMethod;
begin
  New(Mnd);
  Mnd^.isByteReturn := True;
  Mnd^.Method.Data := nil;
  TRedisStringCmdReturnByteA(Mnd^.Method.Code) := stringCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FGetSet(PipeClient, PChar(Key), Value, ValueLen, False, stringCmdResult, Mnd);
end;

procedure TDxPipeClient.HScan(cursor: UInt64; Key, match: string; count: Int64; scanCmdReturn: TRedisScanKVCmdReturn);
var
  Mnd: PScanMethod;
begin
  New(Mnd);
  Mnd^.Method := TMethod(scanCmdReturn);
  Mnd^.ScanResultType := scanResultKeyValue;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FHScan(PipeClient, cursor, PChar(Key), PChar(match), count, False, scanCmdResult, Mnd);
end;

procedure TDxPipeClient.HScan(cursor: UInt64; Key, match: string; count: Int64; scanCmdReturn: TRedisScanKVCmdReturnA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PScanMethod;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisScanKVCmdReturnA(@TMethod(ATemp).Code)^ := scanCmdReturn;
  New(Mnd);
  Mnd^.ScanResultType := scanResultKeyValue;
  Mnd^.Method := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FHScan(PipeClient, cursor, PChar(Key), PChar(match), count, False, scanCmdResult, Mnd);
end;

procedure TDxPipeClient.HGet(Key, field: string; stringCmdReturn: TRedisStringCmdReturn);
var
  Mnd: PStringCmdMethod;
begin
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method := TMethod(stringCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FHGet(PipeClient, PChar(Key), PChar(field), False, False, stringCmdResult, Mnd);
end;

procedure TDxPipeClient.HGet(Key, field: string; stringCmdReturn: TRedisStringCmdReturnA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PStringCmdMethod;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStringCmdReturnA(@TMethod(ATemp).Code)^ := stringCmdReturn;
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FHGet(PipeClient, PChar(Key), PChar(field), False, False, stringCmdResult, Mnd);
end;

procedure TDxPipeClient.HGet(Key, field: string; stringCmdReturn: TRedisStringCmdReturnG);
var
  Mnd: PStringCmdMethod;
begin
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method.Data := nil;
  TRedisStringCmdReturnA(Mnd^.Method.Code) := stringCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FHGet(PipeClient, PChar(Key), PChar(field), False, False, stringCmdResult, Mnd);
end;

procedure TDxPipeClient.HScan(cursor: UInt64; Key, match: string; count: Int64; scanCmdReturn: TRedisScanKVCmdReturnG);
var
  Mnd: PScanMethod;
begin
  New(Mnd);
  Mnd^.Method.Data := nil;
  Mnd^.ScanResultType := scanResultKeyValue;
  TRedisScanKVCmdReturnA(Mnd^.Method.Code) := scanCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FHScan(PipeClient, cursor, PChar(Key), PChar(match), count, False, scanCmdResult, Mnd);
end;

procedure TDxPipeClient.HSet(Key: string; keyValues: array of TKeyValue; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
  i, l: Integer;
  redisKVs: array of TRedisKeyValue;
begin
  l := Length(keyValues);
  if l = 0 then
    Exit;
  SetLength(redisKVs, l);
  for i := 0 to l - 1 do
  begin
    redisKVs[i].Key := PChar(keyValues[i].Key);
    redisKVs[i].Value.ValueLen := 0;
    redisKVs[i].Value.Value := PChar(keyValues[i].Value);
  end;

  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FHSet(PipeClient, PChar(Key), @redisKVs[0], l, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.HSet(Key: string; keyValues: array of TKeyValue; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
  i, l: Integer;
  redisKVs: array of TRedisKeyValue;
begin
  l := Length(keyValues);
  if l = 0 then
    Exit;
  SetLength(redisKVs, l);
  for i := 0 to l - 1 do
  begin
    redisKVs[i].Key := PChar(keyValues[i].Key);
    redisKVs[i].Value.ValueLen := 0;
    redisKVs[i].Value.Value := PChar(keyValues[i].Value);
  end;

  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FHSet(PipeClient, PChar(Key), @redisKVs[0], l, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.HSet(Key: string; keyValues: array of TKeyValue; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
  i, l: Integer;
  redisKVs: array of TRedisKeyValue;
begin
  l := Length(keyValues);
  if l = 0 then
    Exit;
  SetLength(redisKVs, l);
  for i := 0 to l - 1 do
  begin
    redisKVs[i].Key := PChar(keyValues[i].Key);
    redisKVs[i].Value.ValueLen := 0;
    redisKVs[i].Value.Value := PChar(keyValues[i].Value);
  end;

  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FHSet(PipeClient, PChar(Key), @redisKVs[0], l, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.HSet(Key: string; keyValues: array of TRedisKeyValue; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
  l: Integer;
begin
  l := Length(keyValues);
  if l = 0 then
    Exit;
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FHSet(PipeClient, PChar(Key), @keyValues[0], l, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.HSet(Key: string; keyValues: array of TRedisKeyValue; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
  l: Integer;
begin
  l := Length(keyValues);
  if l = 0 then
    Exit;
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FHSet(PipeClient, PChar(Key), @keyValues[0], l, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.HSet(Key: string; keyValues: array of TRedisKeyValue; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
  l: Integer;
begin
  l := Length(keyValues);
  if l = 0 then
    Exit;
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FHSet(PipeClient, PChar(Key), @keyValues[0], l, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.Info(sections: array of string; stringCmdReturn: TRedisStringCmdReturn);
var
  Mnd: PStringCmdMethod;
  section: string;
  i: Integer;
begin
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

  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FInfo(PipeClient, PChar(section), False, stringCmdResult, Mnd)
end;

procedure TDxPipeClient.Info(sections: array of string; stringCmdReturn: TRedisStringCmdReturnA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PStringCmdMethod;
  section: string;
  i: Integer;
begin
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

  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FInfo(PipeClient, PChar(section), False, stringCmdResult, Mnd)
end;

procedure TDxPipeClient.Info(sections: array of string; stringCmdReturn: TRedisStringCmdReturnG);
var
  Mnd: PStringCmdMethod;
  section: string;
  i: Integer;
begin
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

  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FInfo(PipeClient, PChar(section), False, stringCmdResult, Mnd)
end;

procedure TDxPipeClient.keys(pattern: string; CmdReturn: TRedisScanCmdReturn);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FKeys(PipeClient, PChar(pattern), False, scanCmdResult, Mnd);
end;

procedure TDxPipeClient.keys(pattern: string; CmdReturn: TRedisScanCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisScanCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FKeys(PipeClient, PChar(pattern), False, scanCmdResult, Mnd);
end;

procedure TDxPipeClient.keys(pattern: string; CmdReturn: TRedisScanCmdReturnG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TRedisScanCmdReturnA(Mnd^.Code) := CmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FKeys(PipeClient, PChar(pattern), False, scanCmdResult, Mnd);
end;

procedure TDxPipeClient.LSet(Key: string; index: Int64; Value: string; StatusCmdReturn: TRedisStatusCmd);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(StatusCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FLSet(PipeClient, PChar(Key), index, PChar(Value), 0, False, statusCmdResult, Mnd);
end;

procedure TDxPipeClient.LSet(Key: string; index: Int64; Value: string; StatusCmdReturn: TRedisStatusCmdA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PMethod;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStatusCmdA(@TMethod(ATemp).Code)^ := StatusCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FLSet(PipeClient, PChar(Key), index, PChar(Value), 0, False, statusCmdResult, Mnd);
end;

procedure TDxPipeClient.LSet(Key: string; index: Int64; Value: string; StatusCmdReturn: TRedisStatusCmdG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TRedisStatusCmdA(Mnd^.Code) := StatusCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FLSet(PipeClient, PChar(Key), index, PChar(Value), 0, False, statusCmdResult, Mnd);
end;

procedure TDxPipeClient.Migrate(host, port, Key: string; db, timeout: Integer; StatusCmdReturn: TRedisStatusCmd);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(StatusCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FMigrate(PipeClient, PChar(host), PChar(port), PChar(Key), db, timeout, False, statusCmdResult, Mnd);
end;

procedure TDxPipeClient.Migrate(host, port, Key: string; db, timeout: Integer; StatusCmdReturn: TRedisStatusCmdA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PMethod;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStatusCmdA(@TMethod(ATemp).Code)^ := StatusCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FMigrate(PipeClient, PChar(host), PChar(port), PChar(Key), db, timeout, False, statusCmdResult, Mnd);
end;

procedure TDxPipeClient.MGet(keys: array of string; block: Boolean;
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
  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FMGet(PipeClient, PChar(keystr),block, stringSliceCmdResult, Mnd);
end;

procedure TDxPipeClient.MGet(keys: array of string; block: Boolean;
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
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PStringSliceCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FMGet(PipeClient, PChar(keystr),block, stringSliceCmdResult, Mnd);
end;

procedure TDxPipeClient.MGet(keys: array of string; block: Boolean;
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
  New(Mnd);
  Mnd^.Data := nil;
  TStringSliceCmdReturnA(Mnd^.Code) := CmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FMGet(PipeClient, PChar(keystr),block, stringSliceCmdResult, Mnd);
end;

procedure TDxPipeClient.Migrate(host, port, Key: string; db, timeout: Integer; StatusCmdReturn: TRedisStatusCmdG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TRedisStatusCmdA(Mnd^.Code) := StatusCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FMigrate(PipeClient, PChar(host), PChar(port), PChar(Key), db, timeout, False, statusCmdResult, Mnd);
end;

procedure TDxPipeClient.MSet(keyValueArray: array of TKeyValue; StatusCmdReturn: TRedisStatusCmd);
var
  Mnd: PMethod;
  i, l: Integer;
  redisKVs: array of TRedisKeyValue;
begin
  l := Length(keyValueArray);
  if l = 0 then
    Exit;
  SetLength(redisKVs, l);
  for i := 0 to l - 1 do
  begin
    redisKVs[i].Key := PChar(keyValueArray[i].Key);
    redisKVs[i].Value.ValueLen := 0;
    redisKVs[i].Value.Value := PChar(keyValueArray[i].Value);
  end;

  New(Mnd);
  Mnd^ := TMethod(StatusCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FMSet(PipeClient, @redisKVs[0], l, False, statusCmdResult, Mnd);
end;

procedure TDxPipeClient.MSet(keyValueArray: array of TKeyValue; StatusCmdReturn: TRedisStatusCmdA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PMethod;
  l, i: Integer;
  redisKVs: array of TRedisKeyValue;
begin
  l := Length(keyValueArray);
  if l = 0 then
    Exit;
  SetLength(redisKVs, l);
  for i := 0 to l - 1 do
  begin
    redisKVs[i].Key := PChar(keyValueArray[i].Key);
    redisKVs[i].Value.ValueLen := 0;
    redisKVs[i].Value.Value := PChar(keyValueArray[i].Value);
  end;

  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStatusCmdA(@TMethod(ATemp).Code)^ := StatusCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FMSet(PipeClient, @redisKVs[0], l, False, statusCmdResult, Mnd);
end;

procedure TDxPipeClient.MSet(keyValueArray: array of TKeyValue; StatusCmdReturn: TRedisStatusCmdG);
var
  Mnd: PMethod;
  l, i: Integer;
  redisKVs: array of TRedisKeyValue;
begin
  l := Length(keyValueArray);
  if l = 0 then
    Exit;
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
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FMSet(PipeClient, @redisKVs[0], l, False, statusCmdResult, Mnd);
end;

procedure TDxPipeClient.MSet(keyValueArray: array of TRedisKeyValue; StatusCmdReturn: TRedisStatusCmd);
var
  Mnd: PMethod;
  l: Integer;
begin
  l := Length(keyValueArray);
  if l = 0 then
    Exit;
  New(Mnd);
  Mnd^ := TMethod(StatusCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FMSet(PipeClient, @keyValueArray[0], l, False, statusCmdResult, Mnd);
end;

procedure TDxPipeClient.MSet(keyValueArray: array of TRedisKeyValue; StatusCmdReturn: TRedisStatusCmdA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PMethod;
  l: Integer;
begin
  l := Length(keyValueArray);
  if l = 0 then
    Exit;
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStatusCmdA(@TMethod(ATemp).Code)^ := StatusCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FMSet(PipeClient, @keyValueArray[0], l, False, statusCmdResult, Mnd);
end;

procedure TDxPipeClient.MSet(keyValueArray: array of TRedisKeyValue; StatusCmdReturn: TRedisStatusCmdG);
var
  Mnd: PMethod;
  l: Integer;
begin
  l := Length(keyValueArray);
  if l = 0 then
    Exit;
  New(Mnd);
  Mnd^.Data := nil;
  TRedisStatusCmdA(Mnd^.Code) := StatusCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FMSet(PipeClient, @keyValueArray[0], l, False, statusCmdResult, Mnd);
end;

procedure TDxPipeClient.ObjectRefCount(Key: string; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FObjectRefCount(PipeClient, PChar(Key), False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.ObjectRefCount(Key: string; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FObjectRefCount(PipeClient, PChar(Key), False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.ObjectRefCount(Key: string; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FObjectRefCount(PipeClient, PChar(Key), False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.Rename(Key, NewKey: string; StatusCmdReturn: TRedisStatusCmd);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(StatusCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FRename(PipeClient, PChar(Key), PChar(NewKey), False, statusCmdResult, Mnd);
end;

procedure TDxPipeClient.Rename(Key, NewKey: string; StatusCmdReturn: TRedisStatusCmdA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PMethod;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStatusCmdA(@TMethod(ATemp).Code)^ := StatusCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FRename(PipeClient, PChar(Key), PChar(NewKey), False, statusCmdResult, Mnd);
end;

procedure TDxPipeClient.RandomKey(block: Boolean;
  stringCmdReturn: TRedisStringCmdReturn);
var
  Mnd: PStringCmdMethod;
begin
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method := TMethod(stringCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FRandomKey(PipeClient,False, False, stringCmdResult, Mnd);
end;

procedure TDxPipeClient.RandomKey(block: Boolean;
  stringCmdReturn: TRedisStringCmdReturnA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PStringCmdMethod;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStringCmdReturnA(@TMethod(ATemp).Code)^ := stringCmdReturn;
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FRandomKey(PipeClient,False, False, stringCmdResult, Mnd);
end;

procedure TDxPipeClient.RandomKey(block: Boolean;
  stringCmdReturn: TRedisStringCmdReturnG);
var
  Mnd: PStringCmdMethod;
begin
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method.Data := nil;
  TRedisStringCmdReturnA(Mnd^.Method.Code) := stringCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FRandomKey(PipeClient, False, False, stringCmdResult, Mnd);
end;

procedure TDxPipeClient.Rename(Key, NewKey: string; StatusCmdReturn: TRedisStatusCmdG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TRedisStatusCmdA(Mnd^.Code) := StatusCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FRename(PipeClient, PChar(Key), PChar(NewKey), False, statusCmdResult, Mnd);
end;

procedure TDxPipeClient.Restore(Key, Value: string; ttl: Integer; StatusCmdReturn: TRedisStatusCmd);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(StatusCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FRestore(PipeClient, PChar(Key), PChar(Key), ttl, False, statusCmdResult, Mnd);
end;

procedure TDxPipeClient.Restore(Key, Value: string; ttl: Integer; StatusCmdReturn: TRedisStatusCmdA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PMethod;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStatusCmdA(@TMethod(ATemp).Code)^ := StatusCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FRestore(PipeClient, PChar(Key), PChar(Key), ttl, False, statusCmdResult, Mnd);
end;

procedure TDxPipeClient.ResetOwner(Owner: TDxRedisClient);
begin
  if FOwner <> Owner then
  begin
    FreePipeClient;
    FOwner := Owner;
  end;
end;

procedure TDxPipeClient.Restore(Key, Value: string; ttl: Integer; StatusCmdReturn: TRedisStatusCmdG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TRedisStatusCmdA(Mnd^.Code) := StatusCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FRestore(PipeClient, PChar(Key), PChar(Key), ttl, False, statusCmdResult, Mnd);
end;

procedure TDxPipeClient.RestoreReplace(Key, Value: string; ttl: Integer; StatusCmdReturn: TRedisStatusCmd);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(StatusCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FRestoreReplace(PipeClient, PChar(Key), PChar(Key), ttl, False, statusCmdResult, Mnd);
end;

procedure TDxPipeClient.RestoreReplace(Key, Value: string; ttl: Integer; StatusCmdReturn: TRedisStatusCmdA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PMethod;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStatusCmdA(@TMethod(ATemp).Code)^ := StatusCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FRestoreReplace(PipeClient, PChar(Key), PChar(Key), ttl, False, statusCmdResult, Mnd);
end;

procedure TDxPipeClient.RestoreReplace(Key, Value: string; ttl: Integer; StatusCmdReturn: TRedisStatusCmdG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TRedisStatusCmdA(Mnd^.Code) := StatusCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FRestoreReplace(PipeClient, PChar(Key), PChar(Key), ttl, False, statusCmdResult, Mnd);
end;

procedure TDxPipeClient.RPopLPush(src, dst: string; stringCmdReturn: TRedisStringCmdReturnG);
var
  Mnd: PStringCmdMethod;
begin
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method.Data := nil;
  TRedisStringCmdReturnA(Mnd^.Method.Code) := stringCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FRPopLPush(PipeClient, PChar(src), PChar(dst), False, False, stringCmdResult, Mnd);
end;

procedure TDxPipeClient.RPopLPush(src, dst: string; stringCmdReturn: TRedisStringCmdReturnA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PStringCmdMethod;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStringCmdReturnA(@TMethod(ATemp).Code)^ := stringCmdReturn;
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FRPopLPush(PipeClient, PChar(src), PChar(dst), False, False, stringCmdResult, Mnd);
end;

procedure TDxPipeClient.RPopLPush(src, dst: string; stringCmdReturn: TRedisStringCmdReturn);
var
  Mnd: PStringCmdMethod;
begin
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method := TMethod(stringCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FRPopLPush(PipeClient, PChar(src), PChar(dst), False, False, stringCmdResult, Mnd);
end;

procedure TDxPipeClient.RPopLPush(src, dst: string; stringCmdReturn: TRedisStringCmdReturnByteG);
var
  Mnd: PStringCmdMethod;
begin
  New(Mnd);
  Mnd^.Method.Data := nil;
  Mnd^.isByteReturn := True;
  TRedisStringCmdReturnByteA(Mnd^.Method.Code) := stringCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FRPopLPush(PipeClient, PChar(src), PChar(dst), True, False, stringCmdResult, Mnd);
end;

procedure TDxPipeClient.RPopLPush(src, dst: string; stringCmdReturn: TRedisStringCmdReturnByteA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PStringCmdMethod;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStringCmdReturnByteA(@TMethod(ATemp).Code)^ := stringCmdReturn;
  New(Mnd);
  Mnd^.isByteReturn := True;
  Mnd^.Method := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FRPopLPush(PipeClient, PChar(src), PChar(dst), True, False, stringCmdResult, Mnd);
end;

procedure TDxPipeClient.RPopLPush(src, dst: string; stringCmdReturn: TRedisStringCmdReturnByte);
var
  Mnd: PStringCmdMethod;
begin
  New(Mnd);
  Mnd^.Method := TMethod(stringCmdReturn);
  Mnd^.isByteReturn := True;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FRPopLPush(PipeClient, PChar(src), PChar(dst), True, False, stringCmdResult, Mnd);
end;

procedure TDxPipeClient.ScriptFlush(StatusCmdReturn: TRedisStatusCmd);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(StatusCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FScriptFlush(PipeClient, False, statusCmdResult, Mnd);
end;

procedure TDxPipeClient.ScriptFlush(StatusCmdReturn: TRedisStatusCmdA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PMethod;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStatusCmdA(@TMethod(ATemp).Code)^ := StatusCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FScriptFlush(PipeClient, False, statusCmdResult, Mnd);
end;

procedure TDxPipeClient.Scan(cursor: UInt64; match: string; count: Int64; scanCmdReturn: TRedisScanCmdReturn);
var
  Mnd: PScanMethod;
begin
  New(Mnd);
  Mnd^.ScanResultType := scanResultKeyStr;
  Mnd^.Method := TMethod(scanCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FScan(PipeClient, cursor, PChar(match), count, False, scanCmdResult, Mnd);
end;

procedure TDxPipeClient.Scan(cursor: UInt64; match: string; count: Int64; scanCmdReturn: TRedisScanCmdReturnA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PScanMethod;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisScanCmdReturnA(@TMethod(ATemp).Code)^ := scanCmdReturn;
  New(Mnd);
  Mnd^.Method := TMethod(ATemp);
  Mnd^.ScanResultType := scanResultKeyStr;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FScan(PipeClient, cursor, PChar(match), count, False, scanCmdResult, Mnd);
end;

procedure TDxPipeClient.Scan(cursor: UInt64; match: string; count: Int64; scanCmdReturn: TRedisScanCmdReturnG);
var
  Mnd: PScanMethod;
begin
  New(Mnd);
  Mnd^.Method.Data := nil;
  Mnd^.ScanResultType := scanResultKeyStr;
  TRedisScanCmdReturnA(Mnd^.Method.Code) := scanCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FScan(PipeClient, cursor, PChar(match), count, False, scanCmdResult, Mnd);
end;

procedure TDxPipeClient.ScanType(cursor: UInt64; match, KeyType: string; count: Int64; scanCmdReturn: TRedisScanCmdReturn);
var
  Mnd: PScanMethod;
begin
  New(Mnd);
  Mnd^.Method := TMethod(scanCmdReturn);
  Mnd^.ScanResultType := scanResultKeyStr;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FScanType(PipeClient, cursor, PChar(match), PChar(KeyType), count, False, scanCmdResult, Mnd);
end;

procedure TDxPipeClient.ScanType(cursor: UInt64; match, KeyType: string; count: Int64; scanCmdReturn: TRedisScanCmdReturnA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PScanMethod;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisScanCmdReturnA(@TMethod(ATemp).Code)^ := scanCmdReturn;
  New(Mnd);
  Mnd^.Method := TMethod(ATemp);
  Mnd^.ScanResultType := scanResultKeyStr;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FScanType(PipeClient, cursor, PChar(match), PChar(KeyType), count, False, scanCmdResult, Mnd);
end;

procedure TDxPipeClient.ScanType(cursor: UInt64; match, KeyType: string; count: Int64; scanCmdReturn: TRedisScanCmdReturnG);
var
  Mnd: PScanMethod;
begin
  New(Mnd);
  Mnd^.Method.Data := nil;
  Mnd^.ScanResultType := scanResultKeyStr;
  TRedisScanCmdReturnA(Mnd^.Method.Code) := scanCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FScanType(PipeClient, cursor, PChar(match), PChar(KeyType), count, False, scanCmdResult, Mnd);
end;

procedure TDxPipeClient.ScriptFlush(StatusCmdReturn: TRedisStatusCmdG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TRedisStatusCmdA(Mnd^.Code) := StatusCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FScriptFlush(PipeClient, False, statusCmdResult, Mnd);
end;

procedure TDxPipeClient.ScriptKill(StatusCmdReturn: TRedisStatusCmd);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(StatusCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FScriptKill(PipeClient, False, statusCmdResult, Mnd);
end;

procedure TDxPipeClient.ScriptKill(StatusCmdReturn: TRedisStatusCmdA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PMethod;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStatusCmdA(@TMethod(ATemp).Code)^ := StatusCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FScriptKill(PipeClient, False, statusCmdResult, Mnd);
end;

procedure TDxPipeClient.ScriptKill(StatusCmdReturn: TRedisStatusCmdG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TRedisStatusCmdA(Mnd^.Code) := StatusCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FScriptKill(PipeClient, False, statusCmdResult, Mnd);
end;

procedure TDxPipeClient.ScriptLoad(script: string; StatusCmdReturn: TRedisStatusCmd);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(StatusCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FScriptLoad(PipeClient, PChar(script), False, statusCmdResult, Mnd);
end;

procedure TDxPipeClient.ScriptLoad(script: string; StatusCmdReturn: TRedisStatusCmdA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PMethod;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStatusCmdA(@TMethod(ATemp).Code)^ := StatusCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FScriptLoad(PipeClient, PChar(script), False, statusCmdResult, Mnd);
end;

procedure TDxPipeClient.ScriptLoad(script: string; StatusCmdReturn: TRedisStatusCmdG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TRedisStatusCmdA(Mnd^.Code) := StatusCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FScriptLoad(PipeClient, PChar(script), False, statusCmdResult, Mnd);
end;

procedure TDxPipeClient.SetArgs(Key: string; ValueBuffer: PByte; BufferLen: Integer; args: TsetArgs; StatusCmdReturn: TRedisStatusCmd);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(StatusCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSetArgs(PipeClient, PChar(Key), ValueBuffer, BufferLen, @args, False, statusCmdResult, Mnd);
end;

procedure TDxPipeClient.SetArgs(Key: string; ValueBuffer: PByte; BufferLen: Integer; args: TsetArgs; StatusCmdReturn: TRedisStatusCmdA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PMethod;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStatusCmdA(@TMethod(ATemp).Code)^ := StatusCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSetArgs(PipeClient, PChar(Key), ValueBuffer, BufferLen, @args, False, statusCmdResult, Mnd);
end;

procedure TDxPipeClient.Select(dbIndex: Integer; StatusCmdReturn: TRedisStatusCmd);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(StatusCmdReturn);
  FDbIndex := dbIndex;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSelect(PipeClient, dbIndex, statusCmdResult, Mnd);
end;

procedure TDxPipeClient.Select(dbIndex: Integer; StatusCmdReturn: TRedisStatusCmdA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PMethod;
begin
  FDbIndex := dbIndex;
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStatusCmdA(@TMethod(ATemp).Code)^ := StatusCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSelect(PipeClient, dbIndex, statusCmdResult, Mnd);
end;

procedure TDxPipeClient.Select(dbIndex: Integer; StatusCmdReturn: TRedisStatusCmdG);
var
  Mnd: PMethod;
begin
  FDbIndex := dbIndex;
  New(Mnd);
  Mnd^.Data := nil;
  TRedisStatusCmdA(Mnd^.Code) := StatusCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSelect(PipeClient, dbIndex, statusCmdResult, Mnd);
end;

procedure TDxPipeClient.SetArgs(Key: string; ValueBuffer: PByte; BufferLen: Integer; args: TsetArgs; StatusCmdReturn: TRedisStatusCmdG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TRedisStatusCmdA(Mnd^.Code) := StatusCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSetArgs(PipeClient, PChar(Key), ValueBuffer, BufferLen, @args, False, statusCmdResult, Mnd);
end;

procedure TDxPipeClient.SetArgs(Key, Value: string; args: TsetArgs; StatusCmdReturn: TRedisStatusCmd);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(StatusCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSetArgs(PipeClient, PChar(Key), PChar(Value), 0, @args, False, statusCmdResult, Mnd);
end;

procedure TDxPipeClient.SetArgs(Key, Value: string; args: TsetArgs; StatusCmdReturn: TRedisStatusCmdA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PMethod;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStatusCmdA(@TMethod(ATemp).Code)^ := StatusCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSetArgs(PipeClient, PChar(Key), PChar(Value), 0, @args, False, statusCmdResult, Mnd);
end;

procedure TDxPipeClient.SetArgs(Key, Value: string; args: TsetArgs; StatusCmdReturn: TRedisStatusCmdG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TRedisStatusCmdA(Mnd^.Code) := StatusCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSetArgs(PipeClient, PChar(Key), PChar(Value), 0, @args, False, statusCmdResult, Mnd);
end;

procedure TDxPipeClient.SetCmd(Key, Value: string; expiration: Integer; StatusCmdReturn: TRedisStatusCmd);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(StatusCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSet(PipeClient, PChar(Key), PChar(Value), 0, expiration, False, statusCmdResult, Mnd);
end;

procedure TDxPipeClient.SetCmd(Key, Value: string; expiration: Integer; StatusCmdReturn: TRedisStatusCmdA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PMethod;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStatusCmdA(@TMethod(ATemp).Code)^ := StatusCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSet(PipeClient, PChar(Key), PChar(Value), 0, expiration, False, statusCmdResult, Mnd);
end;

procedure TDxPipeClient.SetCmd(Key, Value: string; expiration: Integer; StatusCmdReturn: TRedisStatusCmdG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TRedisStatusCmdA(Mnd^.Code) := StatusCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSet(PipeClient, PChar(Key), PChar(Value), 0, expiration, False, statusCmdResult, Mnd);
end;

procedure TDxPipeClient.SetEx(Key, Value: string; expiration: Integer; StatusCmdReturn: TRedisStatusCmdG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TRedisStatusCmdA(Mnd^.Code) := StatusCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSetEx(PipeClient, PChar(Key), PChar(Value), 0, expiration, False, statusCmdResult, Mnd);
end;

procedure TDxPipeClient.SetEx(Key, Value: string; expiration: Integer; StatusCmdReturn: TRedisStatusCmdA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PMethod;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStatusCmdA(@TMethod(ATemp).Code)^ := StatusCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSetEx(PipeClient, PChar(Key), PChar(Value), 0, expiration, False, statusCmdResult, Mnd);
end;

procedure TDxPipeClient.SetEx(Key, Value: string; expiration: Integer; StatusCmdReturn: TRedisStatusCmd);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(StatusCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSetEx(PipeClient, PChar(Key), PChar(Value), 0, expiration, False, statusCmdResult, Mnd);
end;

procedure TDxPipeClient.SetEx(Key: string; ValueBuffer: PByte; BufferLen, expiration: Integer; StatusCmdReturn: TRedisStatusCmdG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TRedisStatusCmdA(Mnd^.Code) := StatusCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSetEx(PipeClient, PChar(Key), ValueBuffer, BufferLen, expiration, False, statusCmdResult, Mnd);
end;

procedure TDxPipeClient.SetEx(Key: string; ValueBuffer: PByte; BufferLen, expiration: Integer; StatusCmdReturn: TRedisStatusCmdA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PMethod;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStatusCmdA(@TMethod(ATemp).Code)^ := StatusCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSetEx(PipeClient, PChar(Key), ValueBuffer, BufferLen, expiration, False, statusCmdResult, Mnd);
end;

procedure TDxPipeClient.SetEx(Key: string; ValueBuffer: PByte; BufferLen, expiration: Integer; StatusCmdReturn: TRedisStatusCmd);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(StatusCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSetEx(PipeClient, PChar(Key), ValueBuffer, BufferLen, expiration, False, statusCmdResult, Mnd);
end;

procedure TDxPipeClient.SetRange(Key: string; offset: Int64; Value: string; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSetRange(PipeClient, PChar(Key), offset, PChar(Value), False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.SetRange(Key: string; offset: Int64; Value: string; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSetRange(PipeClient, PChar(Key), offset, PChar(Value), False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.SetRange(Key: string; offset: Int64; Value: string; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSetRange(PipeClient, PChar(Key), offset, PChar(Value), False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.SetTxPipeLine(const Value: Boolean);
begin
  if FTxPipeLine <> Value then
  begin
    if PipeClient <> nil then
      FreePipeClient;
    FTxPipeLine := Value;
  end;
end;

procedure TDxPipeClient.SetBit(Key: string; offset: Int64; Value: Integer; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSetBit(PipeClient, PChar(Key), offset, Value, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.SetBit(Key: string; offset: Int64; Value: Integer; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSetBit(PipeClient, PChar(Key), offset, Value, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.SetBit(Key: string; offset: Int64; Value: Integer; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSetBit(PipeClient, PChar(Key), offset, Value, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.GetBit(Key: string; offset: Int64; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FGetBit(PipeClient, PChar(Key), offset, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.GetBit(Key: string; offset: Int64; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FGetBit(PipeClient, PChar(Key), offset, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.GetBit(Key: string; offset: Int64; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FGetBit(PipeClient, PChar(Key), offset, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.SScan(cursor: UInt64; Key, match: string; count: Int64; scanCmdReturn: TRedisScanValueCmdReturn);
var
  Mnd: PScanMethod;
begin
  New(Mnd);
  Mnd^.Method := TMethod(scanCmdReturn);
  Mnd^.ScanResultType := scanResultValue;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSScan(PipeClient, cursor, PChar(Key), PChar(match), count, False, scanCmdResult, Mnd);
end;

procedure TDxPipeClient.SScan(cursor: UInt64; Key, match: string; count: Int64; scanCmdReturn: TRedisScanValueCmdReturnA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PScanMethod;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisScanValueCmdReturnA(@TMethod(ATemp).Code)^ := scanCmdReturn;
  New(Mnd);
  Mnd^.Method := TMethod(ATemp);
  Mnd^.ScanResultType := scanResultValue;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSScan(PipeClient, cursor, PChar(Key), PChar(match), count, False, scanCmdResult, Mnd);
end;

procedure TDxPipeClient.SScan(cursor: UInt64; Key, match: string; count: Int64; scanCmdReturn: TRedisScanValueCmdReturnG);
var
  Mnd: PScanMethod;
begin
  New(Mnd);
  Mnd^.Method.Data := nil;
  Mnd^.ScanResultType := scanResultValue;
  TRedisScanValueCmdReturnA(Mnd^.Method.Code) := scanCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSScan(PipeClient, cursor, PChar(Key), PChar(match), count, False, scanCmdResult, Mnd);
end;

procedure TDxPipeClient.SetCmd(Key: string; ValueBuffer: PByte; BufferLen, expiration: Integer; StatusCmdReturn: TRedisStatusCmd);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(StatusCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSet(PipeClient, PChar(Key), ValueBuffer, BufferLen, expiration, False, statusCmdResult, Mnd);
end;

procedure TDxPipeClient.SetCmd(Key: string; ValueBuffer: PByte; BufferLen, expiration: Integer; StatusCmdReturn: TRedisStatusCmdA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PMethod;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStatusCmdA(@TMethod(ATemp).Code)^ := StatusCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSet(PipeClient, PChar(Key), ValueBuffer, BufferLen, expiration, False, statusCmdResult, Mnd);
end;

procedure TDxPipeClient.SetCmd(Key: string; ValueBuffer: PByte; BufferLen, expiration: Integer; StatusCmdReturn: TRedisStatusCmdG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TRedisStatusCmdA(Mnd^.Code) := StatusCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSet(PipeClient, PChar(Key), ValueBuffer, BufferLen, expiration, False, statusCmdResult, Mnd);
end;

procedure TDxPipeClient.LSet(Key: string; index: Int64; ValueBuffer: PByte; BufferLen: Integer; StatusCmdReturn: TRedisStatusCmd);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(StatusCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FLSet(PipeClient, PChar(Key), index, ValueBuffer, BufferLen, False, statusCmdResult, Mnd);
end;

procedure TDxPipeClient.LSet(Key: string; index: Int64; ValueBuffer: PByte; BufferLen: Integer; StatusCmdReturn: TRedisStatusCmdA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PMethod;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStatusCmdA(@TMethod(ATemp).Code)^ := StatusCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FLSet(PipeClient, PChar(Key), index, ValueBuffer, BufferLen, False, statusCmdResult, Mnd);
end;

procedure TDxPipeClient.LIndex(Key: string; index: Int64; stringCmdReturn: TRedisStringCmdReturnG);
var
  Mnd: PStringCmdMethod;
begin
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method.Data := nil;
  TRedisStringCmdReturnA(Mnd^.Method.Code) := stringCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FLIndex(PipeClient, PChar(Key), index, False, False, stringCmdResult, Mnd);
end;

procedure TDxPipeClient.LIndex(Key: string; index: Int64; stringCmdReturn: TRedisStringCmdReturnA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PStringCmdMethod;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStringCmdReturnA(@TMethod(ATemp).Code)^ := stringCmdReturn;
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FLIndex(PipeClient, PChar(Key), index, False, False, stringCmdResult, Mnd);
end;

procedure TDxPipeClient.LIndex(Key: string; index: Int64; stringCmdReturn: TRedisStringCmdReturn);
var
  Mnd: PStringCmdMethod;
begin
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method := TMethod(stringCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FLIndex(PipeClient, PChar(Key), index, False, False, stringCmdResult, Mnd);
end;

procedure TDxPipeClient.LIndex(Key: string; index: Int64; stringCmdReturn: TRedisStringCmdReturnByteG);
var
  Mnd: PStringCmdMethod;
begin
  New(Mnd);
  Mnd^.Method.Data := nil;
  Mnd^.isByteReturn := True;
  TRedisStringCmdReturnByteA(Mnd^.Method.Code) := stringCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FLIndex(PipeClient, PChar(Key), index, True, False, stringCmdResult, Mnd);
end;

procedure TDxPipeClient.LInsert(Key: string; before: Boolean; pivot, Value: string; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
  pivotv,v: TValueInterface;
begin
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);

  pivotv.ValueLen := 0;
  pivotv.Value := PChar(pivot);
  v.ValueLen := 0;
  v.Value := PChar(Value);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FLInsert(PipeClient, PChar(Key), before, @pivotv, @V, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.LInsert(Key: string; before: Boolean; pivot, Value: string; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
  pivotv,v: TValueInterface;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);

  pivotv.ValueLen := 0;
  pivotv.Value := PChar(pivot);
  v.ValueLen := 0;
  v.Value := PChar(Value);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FLInsert(PipeClient, PChar(Key), before, @pivotv,@v, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.LInsert(Key: string; before: Boolean; pivot, Value: string; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
  pivotv,v: TValueInterface;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;

  pivotv.ValueLen := 0;
  pivotv.Value := PChar(pivot);
  v.ValueLen := 0;
  v.Value := PChar(Value);

  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FLInsert(PipeClient, PChar(Key), before, @pivotv,@v, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.LInsertBefore(Key: string; pivot, Value: string; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
  pivotv,v: TValueInterface;
begin
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  pivotv.ValueLen := 0;
  pivotv.Value := PChar(pivot);
  v.ValueLen := 0;
  v.Value := PChar(Value);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FLInsertBefore(PipeClient, PChar(Key), @pivotv,@v, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.LInsertBefore(Key: string; pivot, Value: string; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
  pivotv,v: TValueInterface;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  pivotv.ValueLen := 0;
  pivotv.Value := PChar(pivot);
  v.ValueLen := 0;
  v.Value := PChar(Value);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FLInsertBefore(PipeClient, PChar(Key), @pivotv,@v, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.LInsertBefore(Key: string; pivot, Value: string; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
  pivotv,v: TValueInterface;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  pivotv.ValueLen := 0;
  pivotv.Value := PChar(pivot);
  v.ValueLen := 0;
  v.Value := PChar(Value);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FLInsertBefore(PipeClient, PChar(Key), @pivotv,@v, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.LInsertAfter(Key: string; pivot, Value: string; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
  pivotv,v: TValueInterface;
begin
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  pivotv.ValueLen := 0;
  pivotv.Value := PChar(pivot);
  v.ValueLen := 0;
  v.Value := PChar(Value);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FLInsertAfter(PipeClient, PChar(Key), @pivotv,@v, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.LInsertAfter(Key: string; pivot, Value: string; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
  pivotv,v: TValueInterface;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  pivotv.ValueLen := 0;
  pivotv.Value := PChar(pivot);
  v.ValueLen := 0;
  v.Value := PChar(Value);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FLInsertAfter(PipeClient, PChar(Key), @pivotv,@v, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.LInsertAfter(Key: string; pivot, Value: string; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
  pivotv,v: TValueInterface;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  pivotv.ValueLen := 0;
  pivotv.Value := PChar(pivot);
  v.ValueLen := 0;
  v.Value := PChar(Value);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FLInsertAfter(PipeClient, PChar(Key), @pivotv,@v, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.LLen(Key: string; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FLLen(PipeClient, PChar(Key), False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.LLen(Key: string; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FLLen(PipeClient, PChar(Key), False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.LLen(Key: string; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FLLen(PipeClient, PChar(Key), False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.LPop(Key: string; stringCmdReturn: TRedisStringCmdReturnG);
var
  Mnd: PStringCmdMethod;
begin
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method.Data := nil;
  TRedisStringCmdReturnA(Mnd^.Method.Code) := stringCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FLPop(PipeClient, PChar(Key), False, False, stringCmdResult, Mnd);
end;

procedure TDxPipeClient.LPop(Key: string; stringCmdReturn: TRedisStringCmdReturnA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PStringCmdMethod;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStringCmdReturnA(@TMethod(ATemp).Code)^ := stringCmdReturn;
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FLPop(PipeClient, PChar(Key), False, False, stringCmdResult, Mnd);
end;

procedure TDxPipeClient.LPop(Key: string; stringCmdReturn: TRedisStringCmdReturn);
var
  Mnd: PStringCmdMethod;
begin
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method := TMethod(stringCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FLPop(PipeClient, PChar(Key), False, False, stringCmdResult, Mnd);
end;

procedure TDxPipeClient.LPop(Key: string; stringCmdReturn: TRedisStringCmdReturnByteG);
var
  Mnd: PStringCmdMethod;
begin
  New(Mnd);
  Mnd^.Method.Data := nil;
  Mnd^.isByteReturn := True;
  TRedisStringCmdReturnByteA(Mnd^.Method.Code) := stringCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FLPop(PipeClient, PChar(Key), True, False, stringCmdResult, Mnd);
end;

procedure TDxPipeClient.LPos(Key, Value: string; args: TLPosArgs; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FLPos(PipeClient, PChar(Key), PChar(Value), @args, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.LPos(Key, Value: string; args: TLPosArgs; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FLPos(PipeClient, PChar(Key), PChar(Value), @args, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.LPos(Key, Value: string; args: TLPosArgs; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FLPos(PipeClient, PChar(Key), PChar(Value), @args, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.LPush(Key: string; values: array of string; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
  i, l: Integer;
  redisKVs: array of TValueInterface;
begin
  l := Length(values);
  if l = 0 then
    Exit;
  SetLength(redisKVs, l);
  for i := 0 to l - 1 do
  begin
    redisKVs[i].ValueLen := 0;
    redisKVs[i].Value := PChar(values[i]);
  end;

  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FLPush(PipeClient, PChar(Key), @redisKVs[0], l, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.LPush(Key: string; values: array of string; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
  i, l: Integer;
  redisKVs: array of TValueInterface;
begin
  l := Length(values);
  if l = 0 then
    Exit;
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
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FLPush(PipeClient, PChar(Key), @redisKVs[0], l, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.LPush(Key: string; values: array of string; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
  i, l: Integer;
  redisKVs: array of TValueInterface;
begin
  l := Length(values);
  if l = 0 then
    Exit;
  SetLength(redisKVs, l);
  for i := 0 to l - 1 do
  begin
    redisKVs[i].ValueLen := 0;
    redisKVs[i].Value := PChar(values[i]);
  end;

  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FLPush(PipeClient, PChar(Key), @redisKVs[0], l, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.LPushx(Key: string; values: array of string; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
  i, l: Integer;
  redisKVs: array of TValueInterface;
begin
  l := Length(values);
  if l = 0 then
    Exit;
  SetLength(redisKVs, l);
  for i := 0 to l - 1 do
  begin
    redisKVs[i].ValueLen := 0;
    redisKVs[i].Value := PChar(values[i]);
  end;

  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FLPushX(PipeClient, PChar(Key), @redisKVs[0], l, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.LPushx(Key: string; values: array of string; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
  i, l: Integer;
  redisKVs: array of TValueInterface;
begin
  l := Length(values);
  if l = 0 then
    Exit;
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
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FLPushX(PipeClient, PChar(Key), @redisKVs[0], l, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.LPushx(Key: string; values: array of string; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
  i, l: Integer;
  redisKVs: array of TValueInterface;
begin
  l := Length(values);
  if l = 0 then
    Exit;
  SetLength(redisKVs, l);
  for i := 0 to l - 1 do
  begin
    redisKVs[i].ValueLen := 0;
    redisKVs[i].Value := PChar(values[i]);
  end;

  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FLPushX(PipeClient, PChar(Key), @redisKVs[0], l, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.LPop(Key: string; stringCmdReturn: TRedisStringCmdReturnByteA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PStringCmdMethod;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStringCmdReturnByteA(@TMethod(ATemp).Code)^ := stringCmdReturn;
  New(Mnd);
  Mnd^.isByteReturn := True;
  Mnd^.Method := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FLPop(PipeClient, PChar(Key), True, False, stringCmdResult, Mnd);
end;

procedure TDxPipeClient.LPop(Key: string; stringCmdReturn: TRedisStringCmdReturnByte);
var
  Mnd: PStringCmdMethod;
begin
  New(Mnd);
  Mnd^.Method := TMethod(stringCmdReturn);
  Mnd^.isByteReturn := True;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FLPop(PipeClient, PChar(Key), True, False, stringCmdResult, Mnd);
end;

procedure TDxPipeClient.RPop(Key: string; stringCmdReturn: TRedisStringCmdReturnG);
var
  Mnd: PStringCmdMethod;
begin
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method.Data := nil;
  TRedisStringCmdReturnA(Mnd^.Method.Code) := stringCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FRPop(PipeClient, PChar(Key), False, False, stringCmdResult, Mnd);
end;

procedure TDxPipeClient.RPop(Key: string; stringCmdReturn: TRedisStringCmdReturnA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PStringCmdMethod;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStringCmdReturnA(@TMethod(ATemp).Code)^ := stringCmdReturn;
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FRPop(PipeClient, PChar(Key), False, False, stringCmdResult, Mnd);
end;

procedure TDxPipeClient.RPop(Key: string; stringCmdReturn: TRedisStringCmdReturn);
var
  Mnd: PStringCmdMethod;
begin
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method := TMethod(stringCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FRPop(PipeClient, PChar(Key), False, False, stringCmdResult, Mnd);
end;

procedure TDxPipeClient.RPop(Key: string; stringCmdReturn: TRedisStringCmdReturnByteG);
var
  Mnd: PStringCmdMethod;
begin
  New(Mnd);
  Mnd^.Method.Data := nil;
  Mnd^.isByteReturn := True;
  TRedisStringCmdReturnByteA(Mnd^.Method.Code) := stringCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FRPop(PipeClient, PChar(Key), True, False, stringCmdResult, Mnd);
end;

procedure TDxPipeClient.RPop(Key: string; stringCmdReturn: TRedisStringCmdReturnByteA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PStringCmdMethod;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStringCmdReturnByteA(@TMethod(ATemp).Code)^ := stringCmdReturn;
  New(Mnd);
  Mnd^.isByteReturn := True;
  Mnd^.Method := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FRPop(PipeClient, PChar(Key), True, False, stringCmdResult, Mnd);
end;

procedure TDxPipeClient.RPop(Key: string; stringCmdReturn: TRedisStringCmdReturnByte);
var
  Mnd: PStringCmdMethod;
begin
  New(Mnd);
  Mnd^.Method := TMethod(stringCmdReturn);
  Mnd^.isByteReturn := True;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FRPop(PipeClient, PChar(Key), True, False, stringCmdResult, Mnd);
end;

procedure TDxPipeClient.SPop(Key: string; stringCmdReturn: TRedisStringCmdReturnG);
var
  Mnd: PStringCmdMethod;
begin
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method.Data := nil;
  TRedisStringCmdReturnA(Mnd^.Method.Code) := stringCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSPop(PipeClient, PChar(Key), False, False, stringCmdResult, Mnd);
end;

procedure TDxPipeClient.SPop(Key: string; stringCmdReturn: TRedisStringCmdReturnA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PStringCmdMethod;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStringCmdReturnA(@TMethod(ATemp).Code)^ := stringCmdReturn;
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSPop(PipeClient, PChar(Key), False, False, stringCmdResult, Mnd);
end;

procedure TDxPipeClient.SPop(Key: string; stringCmdReturn: TRedisStringCmdReturn);
var
  Mnd: PStringCmdMethod;
begin
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method := TMethod(stringCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSPop(PipeClient, PChar(Key), False, False, stringCmdResult, Mnd);
end;

procedure TDxPipeClient.SPop(Key: string; stringCmdReturn: TRedisStringCmdReturnByteG);
var
  Mnd: PStringCmdMethod;
begin
  New(Mnd);
  Mnd^.Method.Data := nil;
  Mnd^.isByteReturn := True;
  TRedisStringCmdReturnByteA(Mnd^.Method.Code) := stringCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSPop(PipeClient, PChar(Key), True, False, stringCmdResult, Mnd);
end;

procedure TDxPipeClient.SPop(Key: string; stringCmdReturn: TRedisStringCmdReturnByteA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PStringCmdMethod;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStringCmdReturnByteA(@TMethod(ATemp).Code)^ := stringCmdReturn;
  New(Mnd);
  Mnd^.isByteReturn := True;
  Mnd^.Method := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSPop(PipeClient, PChar(Key), True, False, stringCmdResult, Mnd);
end;

procedure TDxPipeClient.SPop(Key: string; stringCmdReturn: TRedisStringCmdReturnByte);
var
  Mnd: PStringCmdMethod;
begin
  New(Mnd);
  Mnd^.Method := TMethod(stringCmdReturn);
  Mnd^.isByteReturn := True;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSPop(PipeClient, PChar(Key), True, False, stringCmdResult, Mnd);
end;

procedure TDxPipeClient.SRandMember(Key: string; stringCmdReturn: TRedisStringCmdReturnG);
var
  Mnd: PStringCmdMethod;
begin
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method.Data := nil;
  TRedisStringCmdReturnA(Mnd^.Method.Code) := stringCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSRandMember(PipeClient, PChar(Key), False, False, stringCmdResult, Mnd);
end;

procedure TDxPipeClient.SRandMember(Key: string; stringCmdReturn: TRedisStringCmdReturnA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PStringCmdMethod;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStringCmdReturnA(@TMethod(ATemp).Code)^ := stringCmdReturn;
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSRandMember(PipeClient, PChar(Key), False, False, stringCmdResult, Mnd);
end;

procedure TDxPipeClient.SRandMember(Key: string; stringCmdReturn: TRedisStringCmdReturn);
var
  Mnd: PStringCmdMethod;
begin
  New(Mnd);
  Mnd^.isByteReturn := False;
  Mnd^.Method := TMethod(stringCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSRandMember(PipeClient, PChar(Key), False, False, stringCmdResult, Mnd);
end;

procedure TDxPipeClient.SRandMember(Key: string; stringCmdReturn: TRedisStringCmdReturnByteG);
var
  Mnd: PStringCmdMethod;
begin
  New(Mnd);
  Mnd^.Method.Data := nil;
  Mnd^.isByteReturn := True;
  TRedisStringCmdReturnByteA(Mnd^.Method.Code) := stringCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSRandMember(PipeClient, PChar(Key), True, False, stringCmdResult, Mnd);
end;

procedure TDxPipeClient.SRandMember(Key: string; stringCmdReturn: TRedisStringCmdReturnByteA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PStringCmdMethod;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStringCmdReturnByteA(@TMethod(ATemp).Code)^ := stringCmdReturn;
  New(Mnd);
  Mnd^.isByteReturn := True;
  Mnd^.Method := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSRandMember(PipeClient, PChar(Key), True, False, stringCmdResult, Mnd);
end;

procedure TDxPipeClient.SRandMember(Key: string; stringCmdReturn: TRedisStringCmdReturnByte);
var
  Mnd: PStringCmdMethod;
begin
  New(Mnd);
  Mnd^.Method := TMethod(stringCmdReturn);
  Mnd^.isByteReturn := True;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSRandMember(PipeClient, PChar(Key), True, False, stringCmdResult, Mnd);
end;

procedure TDxPipeClient.LIndex(Key: string; index: Int64; stringCmdReturn: TRedisStringCmdReturnByteA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PStringCmdMethod;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStringCmdReturnByteA(@TMethod(ATemp).Code)^ := stringCmdReturn;
  New(Mnd);
  Mnd^.isByteReturn := True;
  Mnd^.Method := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FLIndex(PipeClient, PChar(Key), index, True, False, stringCmdResult, Mnd);
end;

procedure TDxPipeClient.LIndex(Key: string; index: Int64; stringCmdReturn: TRedisStringCmdReturnByte);
var
  Mnd: PStringCmdMethod;
begin
  New(Mnd);
  Mnd^.Method := TMethod(stringCmdReturn);
  Mnd^.isByteReturn := True;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FLIndex(PipeClient, PChar(Key), index, True, False, stringCmdResult, Mnd);
end;

procedure TDxPipeClient.LSet(Key: string; index: Int64; ValueBuffer: PByte; BufferLen: Integer; StatusCmdReturn: TRedisStatusCmdG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TRedisStatusCmdA(Mnd^.Code) := StatusCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FLSet(PipeClient, PChar(Key), index, ValueBuffer, BufferLen, False, statusCmdResult, Mnd);
end;

procedure TDxPipeClient.LTrim(Key: string; Start, stop: Int64; StatusCmdReturn: TRedisStatusCmd);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(StatusCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FLTrim(PipeClient, PChar(Key), Start, stop, False, statusCmdResult, Mnd);
end;

procedure TDxPipeClient.LTrim(Key: string; Start, stop: Int64; StatusCmdReturn: TRedisStatusCmdA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PMethod;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStatusCmdA(@TMethod(ATemp).Code)^ := StatusCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FLTrim(PipeClient, PChar(Key), Start, stop, False, statusCmdResult, Mnd);
end;

procedure TDxPipeClient.LTrim(Key: string; Start, stop: Int64; StatusCmdReturn: TRedisStatusCmdG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TRedisStatusCmdA(Mnd^.Code) := StatusCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FLTrim(PipeClient, PChar(Key), Start, stop, False, statusCmdResult, Mnd);
end;

procedure TDxPipeClient.HGet(Key, field: string; stringCmdReturn: TRedisStringCmdReturnByte);
var
  Mnd: PStringCmdMethod;
begin
  New(Mnd);
  Mnd^.Method := TMethod(stringCmdReturn);
  Mnd^.isByteReturn := True;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FHGet(PipeClient, PChar(Key), PChar(field), True, False, stringCmdResult, Mnd);
end;

procedure TDxPipeClient.HGet(Key, field: string; stringCmdReturn: TRedisStringCmdReturnByteA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PStringCmdMethod;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStringCmdReturnByteA(@TMethod(ATemp).Code)^ := stringCmdReturn;
  New(Mnd);
  Mnd^.isByteReturn := True;
  Mnd^.Method := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FHGet(PipeClient, PChar(Key), PChar(field), True, False, stringCmdResult, Mnd);
end;

procedure TDxPipeClient.HGet(Key, field: string; stringCmdReturn: TRedisStringCmdReturnByteG);
var
  Mnd: PStringCmdMethod;
begin
  New(Mnd);
  Mnd^.Method.Data := nil;
  Mnd^.isByteReturn := True;
  TRedisStringCmdReturnByteA(Mnd^.Method.Code) := stringCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FHGet(PipeClient, PChar(Key), PChar(field), True, False, stringCmdResult, Mnd);
end;

procedure TDxPipeClient.HIncrBy(Key, field: string; Incr: Int64; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FHIncrBy(PipeClient, PChar(Key), PChar(field), Incr, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.HIncrBy(Key, field: string; Incr: Int64; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FHIncrBy(PipeClient, PChar(Key), PChar(field), Incr, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.HIncrBy(Key, field: string; Incr: Int64; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FHIncrBy(PipeClient, PChar(Key), PChar(field), Incr, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.HIncrByFloat(Key, field: string; increment: Double;
  block: Boolean; floatCmdReturn: TfloatCmdReturn);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(floatCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FHIncrByFloat(PipeClient, PChar(Key),PChar(field), increment, False, floatCmdResult, Mnd);
end;

procedure TDxPipeClient.HIncrByFloat(Key, field: string; increment: Double;
  block: Boolean; floatCmdReturn: TfloatCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TfloatCmdReturn;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PfloatCmdReturnA(@TMethod(ATemp).Code)^ := floatCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FHIncrByFloat(PipeClient, PChar(Key),PChar(field), increment, False, floatCmdResult, Mnd);
end;

procedure TDxPipeClient.HIncrByFloat(Key, field: string; increment: Double;
  block: Boolean; floatCmdReturn: TfloatCmdReturnG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TfloatCmdReturnA(Mnd^.Code) := floatCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FHIncrByFloat(PipeClient, PChar(Key),PChar(field), increment, False, floatCmdResult, Mnd);
end;

procedure TDxPipeClient.HLen(Key: string; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FHLen(PipeClient, PChar(Key), False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.HLen(Key: string; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FHLen(PipeClient, PChar(Key), False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.HLen(Key: string; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FHLen(PipeClient, PChar(Key), False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.BRPopLPush(src, dst: string; timeout: Integer; stringCmdReturn: TRedisStringCmdReturnByte);
var
  Mnd: PStringCmdMethod;
begin
  New(Mnd);
  Mnd^.Method := TMethod(stringCmdReturn);
  Mnd^.isByteReturn := True;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FBRPopLPush(PipeClient, PChar(src), PChar(dst), timeout, True, False, stringCmdResult, Mnd);
end;

procedure TDxPipeClient.BRPopLPush(src, dst: string; timeout: Integer; stringCmdReturn: TRedisStringCmdReturnByteA);
var
  ATemp: TRedisStatusCmd;
  Mnd: PStringCmdMethod;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisStringCmdReturnByteA(@TMethod(ATemp).Code)^ := stringCmdReturn;
  New(Mnd);
  Mnd^.isByteReturn := True;
  Mnd^.Method := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FBRPopLPush(PipeClient, PChar(src), PChar(dst), timeout, True, False, stringCmdResult, Mnd);
end;

procedure TDxPipeClient.Append(Key, Value: string; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FAppend(PipeClient, PChar(Key), PChar(Value), False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.Append(Key, Value: string; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FAppend(PipeClient, PChar(Key), PChar(Value), False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.Append(Key, Value: string; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FAppend(PipeClient, PChar(Key), PChar(Value), False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.BitCount(Key: string; BitCount: TBitCount; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FBitCount(PipeClient, PChar(Key), @BitCount, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.BitCount(Key: string; BitCount: TBitCount; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FBitCount(PipeClient, PChar(Key), @BitCount, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.BitCount(Key: string; BitCount: TBitCount; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FBitCount(PipeClient, PChar(Key), @BitCount, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.BitOpAnd(destKey: string; keys: array of string; intCmdReturn: TIntCmdReturn);
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

    TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FBitOpAnd(PipeClient, PChar(destKey), PChar(keyList), False, intCmdResult, Mnd);
  end;

end;

procedure TDxPipeClient.BitOpAnd(destKey: string; keys: array of string; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  keyList: string;
  i: Integer;
  ATemp: TIntCmdReturn;
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

    TMethod(ATemp).Data := Pointer(-1);
    TMethod(ATemp).Code := nil;
    PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
    New(Mnd);
    Mnd^ := TMethod(ATemp);
    TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FBitOpAnd(PipeClient, PChar(destKey), PChar(keyList), False, intCmdResult, Mnd);
  end;

end;

procedure TDxPipeClient.BitOpAnd(destKey: string; keys: array of string; intCmdReturn: TIntCmdReturnG);
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

    New(Mnd);
    Mnd^.Data := nil;
    TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
    TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FBitOpAnd(PipeClient, PChar(destKey), PChar(keyList), False, intCmdResult, Mnd);
  end;

end;

procedure TDxPipeClient.BitOpNot(destKey, Key: string; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FBitOpNot(PipeClient, PChar(destKey), PChar(Key), False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.BitOpNot(destKey, Key: string; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FBitOpNot(PipeClient, PChar(destKey), PChar(Key), False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.BitOpNot(destKey, Key: string; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FBitOpNot(PipeClient, PChar(destKey), PChar(Key), False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.BitOpOr(destKey: string; keys: array of string; intCmdReturn: TIntCmdReturn);
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

    New(Mnd);
    Mnd^ := TMethod(intCmdReturn);
    TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FBitOpOr(PipeClient, PChar(destKey), PChar(keyList), False, intCmdResult, Mnd);
  end;

end;

procedure TDxPipeClient.BitOpOr(destKey: string; keys: array of string; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  keyList: string;
  i: Integer;
  ATemp: TIntCmdReturn;
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

    TMethod(ATemp).Data := Pointer(-1);
    TMethod(ATemp).Code := nil;
    PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
    New(Mnd);
    Mnd^ := TMethod(ATemp);
    TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FBitOpOr(PipeClient, PChar(destKey), PChar(keyList), False, intCmdResult, Mnd);
  end;

end;

procedure TDxPipeClient.BitOpOr(destKey: string; keys: array of string; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
  keyList: string;
  i: Integer;
begin
  if Length(keys) > 0 then
  begin
    keyList := '';
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

    TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FBitOpOr(PipeClient, PChar(destKey), PChar(keyList), False, intCmdResult, Mnd);
  end;

end;

procedure TDxPipeClient.BitOpXor(destKey: string; keys: array of string; intCmdReturn: TIntCmdReturn);
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

    New(Mnd);
    Mnd^ := TMethod(intCmdReturn);
    TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FBitOpXor(PipeClient, PChar(destKey), PChar(keyList), False, intCmdResult, Mnd);
  end;

end;

procedure TDxPipeClient.BitOpXor(destKey: string; keys: array of string; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  keyList: string;
  i: Integer;
  ATemp: TIntCmdReturn;
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

    TMethod(ATemp).Data := Pointer(-1);
    TMethod(ATemp).Code := nil;
    PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
    New(Mnd);
    Mnd^ := TMethod(ATemp);
    TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FBitOpXor(PipeClient, PChar(destKey), PChar(keyList), False, intCmdResult, Mnd);
  end;

end;

procedure TDxPipeClient.BitOpXor(destKey: string; keys: array of string; intCmdReturn: TIntCmdReturnG);
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

    New(Mnd);
    Mnd^.Data := nil;
    TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
    TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FBitOpXor(PipeClient, PChar(destKey), PChar(keyList), False, intCmdResult, Mnd);
  end;

end;

procedure TDxPipeClient.HDel(Key: string; fields: array of string; intCmdReturn: TIntCmdReturn);
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

    TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FHDel(PipeClient, PChar(Key), PChar(fldList), False, intCmdResult, Mnd);
  end;

end;

procedure TDxPipeClient.HDel(Key: string; fields: array of string; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  fldList: string;
  i: Integer;
  ATemp: TIntCmdReturn;
begin
  if Length(fields) > 0 then
  begin
    fldList := '';
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
    TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FHDel(PipeClient, PChar(Key), PChar(fldList), False, intCmdResult, Mnd);
  end;

end;

procedure TDxPipeClient.HDel(Key: string; fields: array of string; intCmdReturn: TIntCmdReturnG);
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
    for i := Low(fields) to High(fields) do
    begin
      if fldList = '' then
        fldList := fields[i]
      else
        fldList := fldList + #13#10 + fields[i];
    end;

    TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FHDel(PipeClient, PChar(Key), PChar(fldList), False, intCmdResult, Mnd);
  end;

end;

procedure TDxPipeClient.BitPos(Key: string; bit: Int64; bitPoss: array of Int64; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
  l: Integer;
begin
  l := Length(bitPoss);
  if l = 0 then
    Exit;
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FBitPos(PipeClient, PChar(Key), bit, @bitPoss[0], l, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.BitPos(Key: string; bit: Int64; bitPoss: array of Int64; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
  l: Integer;
begin
  l := Length(bitPoss);
  if l = 0 then
    Exit;
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FBitPos(PipeClient, PChar(Key), bit, @bitPoss[0], l, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.BitPos(Key: string; bit: Int64; bitPoss: array of Int64; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
  l: Integer;
begin
  l := Length(bitPoss);
  if l = 0 then
    Exit;
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FBitPos(PipeClient, PChar(Key), bit, @bitPoss[0], l, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.BRPopLPush(src, dst: string; timeout: Integer; stringCmdReturn: TRedisStringCmdReturnByteG);
var
  Mnd: PStringCmdMethod;
begin
  New(Mnd);
  Mnd^.Method.Data := nil;
  Mnd^.isByteReturn := True;
  TRedisStringCmdReturnByteA(Mnd^.Method.Code) := stringCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FBRPopLPush(PipeClient, PChar(src), PChar(dst), timeout, True, False, stringCmdResult, Mnd);
end;

procedure TDxPipeClient.LPush(Key: string; values: array of TValueInterface; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
  l: Integer;
begin
  l := Length(values);
  if l = 0 then
    Exit;
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FLPush(PipeClient, PChar(Key), @values[0], l, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.LPush(Key: string; values: array of TValueInterface; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
  l: Integer;
begin
  l := Length(values);
  if l = 0 then
    Exit;
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FLPush(PipeClient, PChar(Key), @values[0], l, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.LPush(Key: string; values: array of TValueInterface; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
  l: Integer;
begin
  l := Length(values);
  if l = 0 then
    Exit;
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FLPush(PipeClient, PChar(Key), @values[0], l, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.LPushx(Key: string; values: array of TValueInterface; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
  l: Integer;
begin
  l := Length(values);
  if l = 0 then
    Exit;
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FLPushX(PipeClient, PChar(Key), @values[0], l, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.LPushx(Key: string; values: array of TValueInterface; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
  l: Integer;
begin
  l := Length(values);
  if l = 0 then
    Exit;
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FLPushX(PipeClient, PChar(Key), @values[0], l, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.LPushx(Key: string; values: array of TValueInterface; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
  l: Integer;
begin
  l := Length(values);
  if l = 0 then
    Exit;
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FLPushX(PipeClient, PChar(Key), @values[0], l, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.LRem(Key: string; count: Int64; Value: TValueInterface; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FLRem(PipeClient, PChar(Key), count, @Value, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.LRem(Key: string; count: Int64; Value: TValueInterface; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FLRem(PipeClient, PChar(Key), count, @Value, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.LRem(Key: string; count: Int64; Value: TValueInterface; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FLRem(PipeClient, PChar(Key), count, @Value, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.RPush(Key: string; values: array of string; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
  i, l: Integer;
  redisKVs: array of TValueInterface;
begin
  l := Length(values);
  if l = 0 then
    Exit;
  SetLength(redisKVs, l);
  for i := 0 to l - 1 do
  begin
    redisKVs[i].ValueLen := 0;
    redisKVs[i].Value := PChar(values[i]);
  end;

  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FRPush(PipeClient, PChar(Key), @redisKVs[0], l, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.RPush(Key: string; values: array of string; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
  i, l: Integer;
  redisKVs: array of TValueInterface;
begin
  l := Length(values);
  if l = 0 then
    Exit;
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
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FRPush(PipeClient, PChar(Key), @redisKVs[0], l, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.RPush(Key: string; values: array of string; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
  i, l: Integer;
  redisKVs: array of TValueInterface;
begin
  l := Length(values);
  if l = 0 then
    Exit;
  SetLength(redisKVs, l);
  for i := 0 to l - 1 do
  begin
    redisKVs[i].ValueLen := 0;
    redisKVs[i].Value := PChar(values[i]);
  end;

  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FRPush(PipeClient, PChar(Key), @redisKVs[0], l, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.RPush(Key: string; values: array of TValueInterface; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
  l: Integer;
begin
  l := Length(values);
  if l = 0 then
    Exit;
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FRPush(PipeClient, PChar(Key), @values[0], l, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.RPush(Key: string; values: array of TValueInterface; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
  l: Integer;
begin
  l := Length(values);
  if l = 0 then
    Exit;
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FRPush(PipeClient, PChar(Key), @values[0], l, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.RPush(Key: string; values: array of TValueInterface; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
  l: Integer;
begin
  l := Length(values);
  if l = 0 then
    Exit;
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FRPush(PipeClient, PChar(Key), @values[0], l, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.RPushx(Key: string; values: array of string; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
  i, l: Integer;
  redisKVs: array of TValueInterface;
begin
  l := Length(values);
  if l = 0 then
    Exit;
  SetLength(redisKVs, l);
  for i := 0 to l - 1 do
  begin
    redisKVs[i].ValueLen := 0;
    redisKVs[i].Value := PChar(values[i]);
  end;

  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FRPushX(PipeClient, PChar(Key), @redisKVs[0], l, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.RPushx(Key: string; values: array of string; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
  i, l: Integer;
  redisKVs: array of TValueInterface;
begin
  l := Length(values);
  if l = 0 then
    Exit;
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
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FRPushX(PipeClient, PChar(Key), @redisKVs[0], l, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.RPushx(Key: string; values: array of string; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
  i, l: Integer;
  redisKVs: array of TValueInterface;
begin
  l := Length(values);
  if l = 0 then
    Exit;
  SetLength(redisKVs, l);
  for i := 0 to l - 1 do
  begin
    redisKVs[i].ValueLen := 0;
    redisKVs[i].Value := PChar(values[i]);
  end;

  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FRPushX(PipeClient, PChar(Key), @redisKVs[0], l, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.RPushx(Key: string; values: array of TValueInterface; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
  l: Integer;
begin
  l := Length(values);
  if l = 0 then
    Exit;
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FRPushX(PipeClient, PChar(Key), @values[0], l, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.RPushx(Key: string; values: array of TValueInterface; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
  l: Integer;
begin
  l := Length(values);
  if l = 0 then
    Exit;
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FRPushX(PipeClient, PChar(Key), @values[0], l, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.RPushx(Key: string; values: array of TValueInterface; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
  l: Integer;
begin
  l := Length(values);
  if l = 0 then
    Exit;
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FRPushX(PipeClient, PChar(Key), @values[0], l, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.SAdd(Key: string; values: array of string; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
  i, l: Integer;
  redisKVs: array of TValueInterface;
begin
  l := Length(values);
  if l = 0 then
    Exit;
  SetLength(redisKVs, l);
  for i := 0 to l - 1 do
  begin
    redisKVs[i].ValueLen := 0;
    redisKVs[i].Value := PChar(values[i]);
  end;

  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSAdd(PipeClient, PChar(Key), @redisKVs[0], l, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.SAdd(Key: string; values: array of string; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
  i, l: Integer;
  redisKVs: array of TValueInterface;
begin
  l := Length(values);
  if l = 0 then
    Exit;
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
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSAdd(PipeClient, PChar(Key), @redisKVs[0], l, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.SAdd(Key: string; values: array of string; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
  i, l: Integer;
  redisKVs: array of TValueInterface;
begin
  l := Length(values);
  if l = 0 then
    Exit;
  SetLength(redisKVs, l);
  for i := 0 to l - 1 do
  begin
    redisKVs[i].ValueLen := 0;
    redisKVs[i].Value := PChar(values[i]);
  end;

  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSAdd(PipeClient, PChar(Key), @redisKVs[0], l, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.SAdd(Key: string; values: array of TValueInterface; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
  l: Integer;
begin
  l := Length(values);
  if l = 0 then
    Exit;
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSAdd(PipeClient, PChar(Key), @values[0], l, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.SAdd(Key: string; values: array of TValueInterface; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
  l: Integer;
begin
  l := Length(values);
  if l = 0 then
    Exit;
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSAdd(PipeClient, PChar(Key), @values[0], l, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.SAdd(Key: string; values: array of TValueInterface; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
  l: Integer;
begin
  l := Length(values);
  if l = 0 then
    Exit;
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSAdd(PipeClient, PChar(Key), @values[0], l, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.SCard(Key: string; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSCard(PipeClient, PChar(Key), False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.SCard(Key: string; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSCard(PipeClient, PChar(Key), False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.SCard(Key: string; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSCard(PipeClient, PChar(Key), False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.ZCard(Key: string; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZCard(PipeClient, PChar(Key), False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.ZCard(Key: string; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZCard(PipeClient, PChar(Key), False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.ZAdd(Key: string; zvalue: array of TZStrValue; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
  i: Integer;
  zv: array of TZValue;
begin
  i := Length(zvalue);
  if i = 0 then
    Exit;
  SetLength(zv, i);
  for i := Low(zvalue) to High(zvalue) do
  begin
    zv[i].Score := zvalue[i].Score;
    zv[i].Member := PChar(zvalue[i].Member);
    zv[i].MemLen := 0;
  end;

  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZAdd(PipeClient, PChar(Key), @zv[0], Length(zvalue), False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.ZAdd(Key: string; zvalue: array of TZStrValue; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  i, l: Integer;
  zv: array of TZValue;
  ATemp: TIntCmdReturn;
begin
  l := Length(zvalue);
  if l > 0 then
  begin
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
    TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZAdd(PipeClient, PChar(Key), @zv[0], l, False, intCmdResult, Mnd);
  end;

end;

procedure TDxPipeClient.ZAdd(Key: string; zvalue: array of TZStrValue; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
  i, l: Integer;
  zv: array of TZValue;
begin
  l := Length(zvalue);
  if l > 0 then
  begin
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
    TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZAdd(PipeClient, PChar(Key), @zv[0], l, False, intCmdResult, Mnd);
  end;

end;

procedure TDxPipeClient.ZCard(Key: string; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZCard(PipeClient, PChar(Key), False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.ZCount(Key, min, max: string; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZCount(PipeClient, PChar(Key), PChar(min), PChar(max), False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.ZCount(Key, min, max: string; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZCount(PipeClient, PChar(Key), PChar(min), PChar(max), False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.ZCount(Key, min, max: string; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZCount(PipeClient, PChar(Key), PChar(min), PChar(max), False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.SDiffStore(destKey: string; keys: array of string; intCmdReturn: TIntCmdReturn);
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
    for i := Low(keys) to High(keys) do
    begin
      if keyList = '' then
        keyList := keys[i]
      else
        keyList := keyList + #13#10 + keys[i];
    end;

    TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSDiffStore(PipeClient, PChar(destKey), PChar(keyList), False, intCmdResult, Mnd);
  end;

end;

procedure TDxPipeClient.SDiffStore(destKey: string; keys: array of string; intCmdReturn: TIntCmdReturnA);
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

    TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSDiffStore(PipeClient, PChar(destKey), PChar(keyList), False, intCmdResult, Mnd);
  end;

end;

procedure TDxPipeClient.SDiffStore(destKey: string; keys: array of string; intCmdReturn: TIntCmdReturnG);
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
    for i := Low(keys) to High(keys) do
    begin
      if keyList = '' then
        keyList := keys[i]
      else
        keyList := keyList + #13#10 + keys[i];
    end;

    TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSDiffStore(PipeClient, PChar(destKey), PChar(keyList), False, intCmdResult, Mnd);
  end;

end;

procedure TDxPipeClient.SInterStore(destKey: string; keys: array of string; intCmdReturn: TIntCmdReturn);
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
    for i := Low(keys) to High(keys) do
    begin
      if keyList = '' then
        keyList := keys[i]
      else
        keyList := keyList + #13#10 + keys[i];
    end;

    TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSInterStore(PipeClient, PChar(destKey), PChar(keyList), False, intCmdResult, Mnd);
  end;

end;

procedure TDxPipeClient.SInterStore(destKey: string; keys: array of string; intCmdReturn: TIntCmdReturnA);
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

    TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSInterStore(PipeClient, PChar(destKey), PChar(keyList), False, intCmdResult, Mnd);
  end;

end;

procedure TDxPipeClient.SInterStore(destKey: string; keys: array of string; intCmdReturn: TIntCmdReturnG);
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
    for i := Low(keys) to High(keys) do
    begin
      if keyList = '' then
        keyList := keys[i]
      else
        keyList := keyList + #13#10 + keys[i];
    end;

    TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSInterStore(PipeClient, PChar(destKey), PChar(keyList), False, intCmdResult, Mnd);
  end;

end;

procedure TDxPipeClient.SRem(Key: string; membersArr: array of string; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
  i, l: Integer;
  redisKVs: array of TValueInterface;
begin
  l := Length(membersArr);
  if l = 0 then
    Exit;
  SetLength(redisKVs, l);
  for i := 0 to l - 1 do
  begin
    redisKVs[i].ValueLen := 0;
    redisKVs[i].Value := PChar(membersArr[i]);
  end;

  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSRem(PipeClient, PChar(Key), @redisKVs[0], l, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.SRem(Key: string; membersArr: array of string; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
  i, l: Integer;
  redisKVs: array of TValueInterface;
begin
  l := Length(membersArr);
  if l = 0 then
    Exit;
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
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSRem(PipeClient, PChar(Key), @redisKVs[0], l, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.SRem(Key: string; membersArr: array of string; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
  i, l: Integer;
  redisKVs: array of TValueInterface;
begin
  l := Length(membersArr);
  if l = 0 then
    Exit;
  SetLength(redisKVs, l);
  for i := 0 to l - 1 do
  begin
    redisKVs[i].ValueLen := 0;
    redisKVs[i].Value := PChar(membersArr[i]);
  end;

  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSRem(PipeClient, PChar(Key), @redisKVs[0], l, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.SRem(Key: string; membersArr: array of TValueInterface; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
  l: Integer;
begin
  l := Length(membersArr);
  if l = 0 then
    Exit;
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSRem(PipeClient, PChar(Key), @membersArr[0], l, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.SRem(Key: string; membersArr: array of TValueInterface; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
  l: Integer;
begin
  l := Length(membersArr);
  if l = 0 then
    Exit;
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSRem(PipeClient, PChar(Key), @membersArr[0], l, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.SRem(Key: string; membersArr: array of TValueInterface; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
  l: Integer;
begin
  l := Length(membersArr);
  if l = 0 then
    Exit;
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSRem(PipeClient, PChar(Key), @membersArr[0], l, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.SUnionStore(destKey: string; keys: array of string; intCmdReturn: TIntCmdReturn);
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

    TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSUnionStore(PipeClient, PChar(destKey), PChar(keyList), False, intCmdResult, Mnd);
  end;

end;

procedure TDxPipeClient.SUnionStore(destKey: string; keys: array of string; intCmdReturn: TIntCmdReturnA);
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

    TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSUnionStore(PipeClient, PChar(destKey), PChar(keyList), False, intCmdResult, Mnd);
  end;

end;

procedure TDxPipeClient.SUnionStore(destKey: string; keys: array of string; intCmdReturn: TIntCmdReturnG);
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
    for i := Low(keys) to High(keys) do
    begin
      if keyList = '' then
        keyList := keys[i]
      else
        keyList := keyList + #13#10 + keys[i];
    end;

    TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSUnionStore(PipeClient, PChar(destKey), PChar(keyList), False, intCmdResult, Mnd);
  end;

end;

procedure TDxPipeClient.ZAdd(Key: string; zvalue: array of TZValue; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
  i: Integer;
begin
  i := Length(zvalue);
  if i = 0 then
    Exit;
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZAdd(PipeClient, PChar(Key), @zvalue[0], i, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.ZAdd(Key: string; zvalue: array of TZValue; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  l: Integer;
  ATemp: TIntCmdReturn;
begin
  l := Length(zvalue);
  if l > 0 then
  begin
    TMethod(ATemp).Data := Pointer(-1);
    TMethod(ATemp).Code := nil;
    PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
    New(Mnd);
    Mnd^ := TMethod(ATemp);
    TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZAdd(PipeClient, PChar(Key), @zvalue[0], l, False, intCmdResult, Mnd);
  end;

end;

procedure TDxPipeClient.ZAdd(Key: string; zvalue: array of TZValue; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
  l: Integer;
begin
  l := Length(zvalue);
  if l > 0 then
  begin
    New(Mnd);
    Mnd^.Data := nil;
    TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
    TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZAdd(PipeClient, PChar(Key), @zvalue[0], l, False, intCmdResult, Mnd);
  end;

end;

procedure TDxPipeClient.ZAddNX(Key: string; zvalue: array of TZStrValue; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
  i: Integer;
  zv: array of TZValue;
begin
  i := Length(zvalue);
  if i = 0 then
    Exit;
  SetLength(zv, i);
  for i := Low(zvalue) to High(zvalue) do
  begin
    zv[i].Score := zvalue[i].Score;
    zv[i].Member := PChar(zvalue[i].Member);
    zv[i].MemLen := 0;
  end;

  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZAddNX(PipeClient, PChar(Key), @zv[0], Length(zvalue), False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.ZAddNX(Key: string; zvalue: array of TZStrValue; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  i, l: Integer;
  zv: array of TZValue;
  ATemp: TIntCmdReturn;
begin
  l := Length(zvalue);
  if l > 0 then
  begin
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
    TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZAddNX(PipeClient, PChar(Key), @zv[0], l, False, intCmdResult, Mnd);
  end;

end;

procedure TDxPipeClient.ZAddNX(Key: string; zvalue: array of TZStrValue; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
  i, l: Integer;
  zv: array of TZValue;
begin
  l := Length(zvalue);
  if l > 0 then
  begin
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
    TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZAddNX(PipeClient, PChar(Key), @zv[0], l, False, intCmdResult, Mnd);
  end;

end;

procedure TDxPipeClient.ZAddNX(Key: string; zvalue: array of TZValue; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
  i: Integer;
begin
  i := Length(zvalue);
  if i = 0 then
    Exit;
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZAddNX(PipeClient, PChar(Key), @zvalue[0], i, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.ZAddNX(Key: string; zvalue: array of TZValue; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  l: Integer;
  ATemp: TIntCmdReturn;
begin
  l := Length(zvalue);
  if l > 0 then
  begin
    TMethod(ATemp).Data := Pointer(-1);
    TMethod(ATemp).Code := nil;
    PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
    New(Mnd);
    Mnd^ := TMethod(ATemp);
    TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZAddNX(PipeClient, PChar(Key), @zvalue[0], l, False, intCmdResult, Mnd);
  end;

end;

procedure TDxPipeClient.ZAddNX(Key: string; zvalue: array of TZValue; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
  l: Integer;
begin
  l := Length(zvalue);
  if l > 0 then
  begin
    New(Mnd);
    Mnd^.Data := nil;
    TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
    TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZAddNX(PipeClient, PChar(Key), @zvalue[0], l, False, intCmdResult, Mnd);
  end;

end;

procedure TDxPipeClient.ZAddXX(Key: string; zvalue: array of TZStrValue; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
  i: Integer;
  zv: array of TZValue;
begin
  i := Length(zvalue);
  if i = 0 then
    Exit;
  SetLength(zv, i);
  for i := Low(zvalue) to High(zvalue) do
  begin
    zv[i].Score := zvalue[i].Score;
    zv[i].Member := PChar(zvalue[i].Member);
    zv[i].MemLen := 0;
  end;

  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZAddXX(PipeClient, PChar(Key), @zv[0], Length(zvalue), False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.ZAddXX(Key: string; zvalue: array of TZStrValue; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  i, l: Integer;
  zv: array of TZValue;
  ATemp: TIntCmdReturn;
begin
  l := Length(zvalue);
  if l > 0 then
  begin
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
    TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZAddXX(PipeClient, PChar(Key), @zv[0], l, False, intCmdResult, Mnd);
  end;

end;

procedure TDxPipeClient.ZAddXX(Key: string; zvalue: array of TZStrValue; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
  i, l: Integer;
  zv: array of TZValue;
begin
  l := Length(zvalue);
  if l > 0 then
  begin
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
    TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZAddXX(PipeClient, PChar(Key), @zv[0], l, False, intCmdResult, Mnd);
  end;

end;

procedure TDxPipeClient.ZAddXX(Key: string; zvalue: array of TZValue; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
  i: Integer;
begin
  i := Length(zvalue);
  if i = 0 then
    Exit;
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZAddXX(PipeClient, PChar(Key), @zvalue[0], i, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.ZAddXX(Key: string; zvalue: array of TZValue; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  l: Integer;
  ATemp: TIntCmdReturn;
begin
  l := Length(zvalue);
  if l > 0 then
  begin
    TMethod(ATemp).Data := Pointer(-1);
    TMethod(ATemp).Code := nil;
    PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
    New(Mnd);
    Mnd^ := TMethod(ATemp);
    TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZAddXX(PipeClient, PChar(Key), @zvalue[0], l, False, intCmdResult, Mnd);
  end;

end;

procedure TDxPipeClient.ZAddXX(Key: string; zvalue: array of TZValue; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
  l: Integer;
begin
  l := Length(zvalue);
  if l > 0 then
  begin
    New(Mnd);
    Mnd^.Data := nil;
    TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
    TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZAddXX(PipeClient, PChar(Key), @zvalue[0], l, False, intCmdResult, Mnd);
  end;

end;

procedure TDxPipeClient.ZAddCh(Key: string; zvalue: array of TZStrValue; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
  i: Integer;
  zv: array of TZValue;
begin
  i := Length(zvalue);
  if i = 0 then
    Exit;
  SetLength(zv, i);
  for i := Low(zvalue) to High(zvalue) do
  begin
    zv[i].Score := zvalue[i].Score;
    zv[i].Member := PChar(zvalue[i].Member);
    zv[i].MemLen := 0;
  end;

  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZAddCh(PipeClient, PChar(Key), @zv[0], Length(zvalue), False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.ZAddCh(Key: string; zvalue: array of TZStrValue; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  i, l: Integer;
  zv: array of TZValue;
  ATemp: TIntCmdReturn;
begin
  l := Length(zvalue);
  if l > 0 then
  begin
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
    TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZAddCh(PipeClient, PChar(Key), @zv[0], l, False, intCmdResult, Mnd);
  end;

end;

procedure TDxPipeClient.ZAddCh(Key: string; zvalue: array of TZStrValue; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
  i, l: Integer;
  zv: array of TZValue;
begin
  l := Length(zvalue);
  if l > 0 then
  begin
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
    TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZAddCh(PipeClient, PChar(Key), @zv[0], l, False, intCmdResult, Mnd);
  end;

end;

procedure TDxPipeClient.ZAddCh(Key: string; zvalue: array of TZValue; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
  i: Integer;
begin
  i := Length(zvalue);
  if i = 0 then
    Exit;
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZAddCh(PipeClient, PChar(Key), @zvalue[0], i, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.ZAddCh(Key: string; zvalue: array of TZValue; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  l: Integer;
  ATemp: TIntCmdReturn;
begin
  l := Length(zvalue);
  if l > 0 then
  begin
    TMethod(ATemp).Data := Pointer(-1);
    TMethod(ATemp).Code := nil;
    PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
    New(Mnd);
    Mnd^ := TMethod(ATemp);
    TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZAddCh(PipeClient, PChar(Key), @zvalue[0], l, False, intCmdResult, Mnd);
  end;

end;

procedure TDxPipeClient.ZAddCh(Key: string; zvalue: array of TZValue; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
  l: Integer;
begin
  l := Length(zvalue);
  if l > 0 then
  begin
    New(Mnd);
    Mnd^.Data := nil;
    TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
    TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZAddCh(PipeClient, PChar(Key), @zvalue[0], l, False, intCmdResult, Mnd);
  end;

end;

procedure TDxPipeClient.ZAddNXCh(Key: string; zvalue: array of TZStrValue; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
  i: Integer;
  zv: array of TZValue;
begin
  i := Length(zvalue);
  if i = 0 then
    Exit;
  SetLength(zv, i);
  for i := Low(zvalue) to High(zvalue) do
  begin
    zv[i].Score := zvalue[i].Score;
    zv[i].Member := PChar(zvalue[i].Member);
    zv[i].MemLen := 0;
  end;

  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZAddNXCh(PipeClient, PChar(Key), @zv[0], Length(zvalue), False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.ZAddNXCh(Key: string; zvalue: array of TZStrValue; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  i, l: Integer;
  zv: array of TZValue;
  ATemp: TIntCmdReturn;
begin
  l := Length(zvalue);
  if l > 0 then
  begin
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
    TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZAddNXCh(PipeClient, PChar(Key), @zv[0], l, False, intCmdResult, Mnd);
  end;

end;

procedure TDxPipeClient.ZAddNXCh(Key: string; zvalue: array of TZStrValue; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
  i, l: Integer;
  zv: array of TZValue;
begin
  l := Length(zvalue);
  if l > 0 then
  begin
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
    TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZAddNXCh(PipeClient, PChar(Key), @zv[0], l, False, intCmdResult, Mnd);
  end;

end;

procedure TDxPipeClient.ZAddNXCh(Key: string; zvalue: array of TZValue; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
  i: Integer;
begin
  i := Length(zvalue);
  if i = 0 then
    Exit;
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZAddNXCh(PipeClient, PChar(Key), @zvalue[0], i, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.ZAddNXCh(Key: string; zvalue: array of TZValue; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  l: Integer;
  ATemp: TIntCmdReturn;
begin
  l := Length(zvalue);
  if l > 0 then
  begin
    TMethod(ATemp).Data := Pointer(-1);
    TMethod(ATemp).Code := nil;
    PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
    New(Mnd);
    Mnd^ := TMethod(ATemp);
    TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZAddNXCh(PipeClient, PChar(Key), @zvalue[0], l, False, intCmdResult, Mnd);
  end;
end;

procedure TDxPipeClient.ZAddNXCh(Key: string; zvalue: array of TZValue; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
  l: Integer;
begin
  l := Length(zvalue);
  if l > 0 then
  begin
    New(Mnd);
    Mnd^.Data := nil;
    TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
    TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZAddNXCh(PipeClient, PChar(Key), @zvalue[0], l, False, intCmdResult, Mnd);
  end;

end;

procedure TDxPipeClient.ZAddXXCh(Key: string; zvalue: array of TZStrValue; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
  i: Integer;
  zv: array of TZValue;
begin
  i := Length(zvalue);
  if i = 0 then
    Exit;
  SetLength(zv, i);
  for i := Low(zvalue) to High(zvalue) do
  begin
    zv[i].Score := zvalue[i].Score;
    zv[i].Member := PChar(zvalue[i].Member);
    zv[i].MemLen := 0;
  end;

  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZAddXXCh(PipeClient, PChar(Key), @zv[0], Length(zvalue), False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.ZAddXXCh(Key: string; zvalue: array of TZStrValue; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  i, l: Integer;
  zv: array of TZValue;
  ATemp: TIntCmdReturn;
begin
  l := Length(zvalue);
  if l > 0 then
  begin
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
    TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZAddXXCh(PipeClient, PChar(Key), @zv[0], l, False, intCmdResult, Mnd);
  end;

end;

procedure TDxPipeClient.ZAddXXCh(Key: string; zvalue: array of TZStrValue; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
  i, l: Integer;
  zv: array of TZValue;
begin
  l := Length(zvalue);
  if l > 0 then
  begin
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
    TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZAddXXCh(PipeClient, PChar(Key), @zv[0], l, False, intCmdResult, Mnd);
  end;

end;

procedure TDxPipeClient.ZAddXXCh(Key: string; zvalue: array of TZValue; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
  i: Integer;
begin
  i := Length(zvalue);
  if i = 0 then
    Exit;
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZAddXXCh(PipeClient, PChar(Key), @zvalue[0], i, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.ZAddXXCh(Key: string; zvalue: array of TZValue; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  l: Integer;
  ATemp: TIntCmdReturn;
begin
  l := Length(zvalue);
  if l > 0 then
  begin
    TMethod(ATemp).Data := Pointer(-1);
    TMethod(ATemp).Code := nil;
    PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
    New(Mnd);
    Mnd^ := TMethod(ATemp);
    TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZAddXXCh(PipeClient, PChar(Key), @zvalue[0], l, False, intCmdResult, Mnd);
  end;

end;

procedure TDxPipeClient.ZAddXXCh(Key: string; zvalue: array of TZValue; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
  l: Integer;
begin
  l := Length(zvalue);
  if l > 0 then
  begin
    New(Mnd);
    Mnd^.Data := nil;
    TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
    TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZAddXXCh(PipeClient, PChar(Key), @zvalue[0], l, False, intCmdResult, Mnd);
  end;

end;

procedure TDxPipeClient.ZLexCount(Key, min, max: string; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZLexCount(PipeClient, PChar(Key), PChar(min), PChar(max), False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.ZLexCount(Key, min, max: string; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZLexCount(PipeClient, PChar(Key), PChar(min), PChar(max), False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.ZLexCount(Key, min, max: string; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZLexCount(PipeClient, PChar(Key), PChar(min), PChar(max), False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.ZRemRangeByRank(Key: string; Start, stop: Int64; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZRemRangeByRank(PipeClient, PChar(Key), Start, stop, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.ZRemRangeByRank(Key: string; Start, stop: Int64; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZRemRangeByRank(PipeClient, PChar(Key), Start, stop, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.ZRemRangeByRank(Key: string; Start, stop: Int64; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZRemRangeByRank(PipeClient, PChar(Key), Start, stop, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.ZRank(Key, Member: string; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZRank(PipeClient, PChar(Key), PChar(Member), False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.ZRank(Key, Member: string; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZRank(PipeClient, PChar(Key), PChar(Member), False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.ZRank(Key, Member: string; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZRank(PipeClient, PChar(Key), PChar(Member), False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.ZRem(Key: string; membersArr: array of string; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
  i, l: Integer;
  redisKVs: array of TValueInterface;
begin
  l := Length(membersArr);
  if l = 0 then
    Exit;
  SetLength(redisKVs, l);
  for i := 0 to l - 1 do
  begin
    redisKVs[i].ValueLen := 0;
    redisKVs[i].Value := PChar(membersArr[i]);
  end;

  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZRem(PipeClient, PChar(Key), @redisKVs[0], l, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.ZRem(Key: string; membersArr: array of string; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
  i, l: Integer;
  redisKVs: array of TValueInterface;
begin
  l := Length(membersArr);
  if l = 0 then
    Exit;
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
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZRem(PipeClient, PChar(Key), @redisKVs[0], l, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.ZRem(Key: string; membersArr: array of string; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
  i, l: Integer;
  redisKVs: array of TValueInterface;
begin
  l := Length(membersArr);
  if l = 0 then
    Exit;
  SetLength(redisKVs, l);
  for i := 0 to l - 1 do
  begin
    redisKVs[i].ValueLen := 0;
    redisKVs[i].Value := PChar(membersArr[i]);
  end;

  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZRem(PipeClient, PChar(Key), @redisKVs[0], l, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.ZRem(Key: string; membersArr: array of TValueInterface; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
  l: Integer;
begin
  l := Length(membersArr);
  if l = 0 then
    Exit;
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZRem(PipeClient, PChar(Key), @membersArr[0], l, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.ZRem(Key: string; membersArr: array of TValueInterface; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
  l: Integer;
begin
  l := Length(membersArr);
  if l = 0 then
    Exit;
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZRem(PipeClient, PChar(Key), @membersArr[0], l, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.ZRem(Key: string; membersArr: array of TValueInterface; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
  l: Integer;
begin
  l := Length(membersArr);
  if l = 0 then
    Exit;
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZRem(PipeClient, PChar(Key), @membersArr[0], l, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.ZRemRangeByScore(Key, min, max: string; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZRemRangeByScore(PipeClient, PChar(Key), PChar(min), PChar(max), False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.ZRemRangeByScore(Key, min, max: string; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZRemRangeByScore(PipeClient, PChar(Key), PChar(min), PChar(max), False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.ZRemRangeByScore(Key, min, max: string; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZRemRangeByScore(PipeClient, PChar(Key), PChar(min), PChar(max), False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.ZRemRangeByLex(Key, min, max: string; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZRemRangeByLex(PipeClient, PChar(Key), PChar(min), PChar(max), False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.ZRemRangeByLex(Key, min, max: string; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZRemRangeByLex(PipeClient, PChar(Key), PChar(min), PChar(max), False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.ZRemRangeByLex(Key, min, max: string; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZRemRangeByLex(PipeClient, PChar(Key), PChar(min), PChar(max), False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.Expire(Key: string; expiration: Integer; CmdReturn: TBoolCmdReturn);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FExpire(PipeClient, PChar(Key), expiration, False, boolCmdResult, Mnd);
end;

procedure TDxPipeClient.Expire(Key: string; expiration: Integer; CmdReturn: TBoolCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PBoolCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FExpire(PipeClient, PChar(Key), expiration, False, boolCmdResult, Mnd);
end;

procedure TDxPipeClient.Expire(Key: string; expiration: Integer; CmdReturn: TBoolCmdReturnG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TBoolCmdReturnA(Mnd^.Code) := CmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FExpire(PipeClient, PChar(Key), expiration, False, boolCmdResult, Mnd);
end;

procedure TDxPipeClient.ExpireAt(Key: string; atTime: TDateTime; CmdReturn: TBoolCmdReturn);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FExpireAt(PipeClient, PChar(Key), atTime, False, boolCmdResult, Mnd);
end;

procedure TDxPipeClient.ExpireAt(Key: string; atTime: TDateTime; CmdReturn: TBoolCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PBoolCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FExpireAt(PipeClient, PChar(Key), atTime, False, boolCmdResult, Mnd);
end;

procedure TDxPipeClient.ExpireAt(Key: string; atTime: TDateTime; CmdReturn: TBoolCmdReturnG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TBoolCmdReturnA(Mnd^.Code) := CmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FExpireAt(PipeClient, PChar(Key), atTime, False, boolCmdResult, Mnd);
end;

procedure TDxPipeClient.PExpire(Key: string; expiration: Integer; CmdReturn: TBoolCmdReturn);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FPExpire(PipeClient, PChar(Key), expiration, False, boolCmdResult, Mnd);
end;

procedure TDxPipeClient.PExpire(Key: string; expiration: Integer; CmdReturn: TBoolCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PBoolCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FPExpire(PipeClient, PChar(Key), expiration, False, boolCmdResult, Mnd);
end;

procedure TDxPipeClient.PExpire(Key: string; expiration: Integer; CmdReturn: TBoolCmdReturnG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TBoolCmdReturnA(Mnd^.Code) := CmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FPExpire(PipeClient, PChar(Key), expiration, False, boolCmdResult, Mnd);
end;

procedure TDxPipeClient.PExpireAt(Key: string; atTime: TDateTime; CmdReturn: TBoolCmdReturn);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FPExpireAt(PipeClient, PChar(Key), atTime, False, boolCmdResult, Mnd);
end;

procedure TDxPipeClient.PExpireAt(Key: string; atTime: TDateTime; CmdReturn: TBoolCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PBoolCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FPExpireAt(PipeClient, PChar(Key), atTime, False, boolCmdResult, Mnd);
end;

procedure TDxPipeClient.PExpireAt(Key: string; atTime: TDateTime; CmdReturn: TBoolCmdReturnG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TBoolCmdReturnA(Mnd^.Code) := CmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FPExpireAt(PipeClient, PChar(Key), atTime, False, boolCmdResult, Mnd);
end;

procedure TDxPipeClient.Move(Key: string; db: Integer; CmdReturn: TBoolCmdReturn);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FMove(PipeClient, PChar(Key), db, False, boolCmdResult, Mnd);
end;

procedure TDxPipeClient.Move(Key: string; db: Integer; CmdReturn: TBoolCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PBoolCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FMove(PipeClient, PChar(Key), db, False, boolCmdResult, Mnd);
end;

procedure TDxPipeClient.Move(Key: string; db: Integer; CmdReturn: TBoolCmdReturnG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TBoolCmdReturnA(Mnd^.Code) := CmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FMove(PipeClient, PChar(Key), db, False, boolCmdResult, Mnd);
end;

procedure TDxPipeClient.Persist(Key: string; CmdReturn: TBoolCmdReturn);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FPersist(PipeClient, PChar(Key), False, boolCmdResult, Mnd);
end;

procedure TDxPipeClient.Persist(Key: string; CmdReturn: TBoolCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PBoolCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FPersist(PipeClient, PChar(Key), False, boolCmdResult, Mnd);
end;

procedure TDxPipeClient.Persist(Key: string; CmdReturn: TBoolCmdReturnG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TBoolCmdReturnA(Mnd^.Code) := CmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FPersist(PipeClient, PChar(Key), False, boolCmdResult, Mnd);
end;

procedure TDxPipeClient.RenameNX(Key, NewKey: string; CmdReturn: TBoolCmdReturn);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FRenameNX(PipeClient, PChar(Key), PChar(NewKey), False, boolCmdResult, Mnd);
end;

procedure TDxPipeClient.RenameNX(Key, NewKey: string; CmdReturn: TBoolCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PBoolCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FRenameNX(PipeClient, PChar(Key), PChar(NewKey), False, boolCmdResult, Mnd);
end;

procedure TDxPipeClient.RenameNX(Key, NewKey: string; CmdReturn: TBoolCmdReturnG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TBoolCmdReturnA(Mnd^.Code) := CmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FRenameNX(PipeClient, PChar(Key), PChar(NewKey), False, boolCmdResult, Mnd);
end;

procedure TDxPipeClient.MSetNX(keyValues: array of TKeyValue; CmdReturn: TBoolCmdReturn);
var
  Mnd: PMethod;
  i, l: Integer;
  redisKVs: array of TRedisKeyValue;
begin
  l := Length(keyValues);
  if l = 0 then
    Exit;
  SetLength(redisKVs, l);
  for i := 0 to l - 1 do
  begin
    redisKVs[i].Key := PChar(keyValues[i].Key);
    redisKVs[i].Value.Value := PChar(keyValues[i].Value);
    redisKVs[i].Value.ValueLen := 0;
  end;

  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FMSetNX(PipeClient, @redisKVs[0], l, False, boolCmdResult, Mnd);
end;

procedure TDxPipeClient.MSetNX(keyValues: array of TKeyValue; CmdReturn: TBoolCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
  i, l: Integer;
  redisKVs: array of TRedisKeyValue;
begin
  l := Length(keyValues);
  if l = 0 then
    Exit;
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
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FMSetNX(PipeClient, @redisKVs[0], l, False, boolCmdResult, Mnd);
end;

procedure TDxPipeClient.MSetNX(keyValues: array of TKeyValue; CmdReturn: TBoolCmdReturnG);
var
  Mnd: PMethod;
  i, l: Integer;
  redisKVs: array of TRedisKeyValue;
begin
  l := Length(keyValues);
  if l = 0 then
    Exit;
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
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FMSetNX(PipeClient, @redisKVs[0], l, False, boolCmdResult, Mnd);
end;

procedure TDxPipeClient.MSetNX(keyValues: array of TRedisKeyValue; CmdReturn: TBoolCmdReturn);
var
  Mnd: PMethod;
  l: Integer;
begin
  l := Length(keyValues);
  if l = 0 then
    Exit;
  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FMSetNX(PipeClient, @keyValues[0], l, False, boolCmdResult, Mnd);
end;

procedure TDxPipeClient.MSetNX(keyValues: array of TRedisKeyValue; CmdReturn: TBoolCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
  l: Integer;
begin
  l := Length(keyValues);
  if l = 0 then
    Exit;
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PBoolCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FMSetNX(PipeClient, @keyValues[0], l, False, boolCmdResult, Mnd);
end;

procedure TDxPipeClient.MSetNX(keyValues: array of TRedisKeyValue; CmdReturn: TBoolCmdReturnG);
var
  Mnd: PMethod;
  l: Integer;
begin
  l := Length(keyValues);
  if l = 0 then
    Exit;
  New(Mnd);
  Mnd^.Data := nil;
  TBoolCmdReturnA(Mnd^.Code) := CmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FMSetNX(PipeClient, @keyValues[0], l, False, boolCmdResult, Mnd);
end;

procedure TDxPipeClient.SetNX(Key, Value: string; expiration: Integer; CmdReturn: TBoolCmdReturn);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSetNX(PipeClient, PChar(Key), PChar(Value), 0, expiration, False, boolCmdResult, Mnd);
end;

procedure TDxPipeClient.SetNX(Key, Value: string; expiration: Integer; CmdReturn: TBoolCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PBoolCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSetNX(PipeClient, PChar(Key), PChar(Value), 0, expiration, False, boolCmdResult, Mnd);
end;

procedure TDxPipeClient.SetNX(Key, Value: string; expiration: Integer; CmdReturn: TBoolCmdReturnG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TBoolCmdReturnA(Mnd^.Code) := CmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSetNX(PipeClient, PChar(Key), PChar(Value), 0, expiration, False, boolCmdResult, Mnd);
end;

procedure TDxPipeClient.SetNX(Key: string; ValueBuffer: PByte; buffLen, expiration: Integer; CmdReturn: TBoolCmdReturn);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSetNX(PipeClient, PChar(Key), ValueBuffer, buffLen, expiration, False, boolCmdResult, Mnd);
end;

procedure TDxPipeClient.SetNX(Key: string; ValueBuffer: PByte; buffLen, expiration: Integer; CmdReturn: TBoolCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PBoolCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSetNX(PipeClient, PChar(Key), ValueBuffer, buffLen, expiration, False, boolCmdResult, Mnd);
end;

procedure TDxPipeClient.SetNX(Key: string; ValueBuffer: PByte; buffLen, expiration: Integer; CmdReturn: TBoolCmdReturnG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TBoolCmdReturnA(Mnd^.Code) := CmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSetNX(PipeClient, PChar(Key), ValueBuffer, buffLen, expiration, False, boolCmdResult, Mnd);
end;

procedure TDxPipeClient.SetXX(Key, Value: string; expiration: Integer; CmdReturn: TBoolCmdReturn);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSetXX(PipeClient, PChar(Key), PChar(Value), 0, expiration, False, boolCmdResult, Mnd);
end;

procedure TDxPipeClient.SetXX(Key, Value: string; expiration: Integer; CmdReturn: TBoolCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PBoolCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSetXX(PipeClient, PChar(Key), PChar(Value), 0, expiration, False, boolCmdResult, Mnd);
end;

procedure TDxPipeClient.SetXX(Key, Value: string; expiration: Integer; CmdReturn: TBoolCmdReturnG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TBoolCmdReturnA(Mnd^.Code) := CmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSetXX(PipeClient, PChar(Key), PChar(Value), 0, expiration, False, boolCmdResult, Mnd);
end;

procedure TDxPipeClient.SetXX(Key: string; ValueBuffer: PByte; buffLen, expiration: Integer; CmdReturn: TBoolCmdReturn);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSetXX(PipeClient, PChar(Key), ValueBuffer, buffLen, expiration, False, boolCmdResult, Mnd);
end;

procedure TDxPipeClient.SetXX(Key: string; ValueBuffer: PByte; buffLen, expiration: Integer; CmdReturn: TBoolCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PBoolCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSetXX(PipeClient, PChar(Key), ValueBuffer, buffLen, expiration, False, boolCmdResult, Mnd);
end;

procedure TDxPipeClient.SetXX(Key: string; ValueBuffer: PByte; buffLen, expiration: Integer; CmdReturn: TBoolCmdReturnG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TBoolCmdReturnA(Mnd^.Code) := CmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSetXX(PipeClient, PChar(Key), ValueBuffer, buffLen, expiration, False, boolCmdResult, Mnd);
end;

procedure TDxPipeClient.HExists(Key, field: string; CmdReturn: TBoolCmdReturn);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FHExists(PipeClient, PChar(Key), PChar(field), False, boolCmdResult, Mnd);
end;

procedure TDxPipeClient.HExists(Key, field: string; CmdReturn: TBoolCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PBoolCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FHExists(PipeClient, PChar(Key), PChar(field), False, boolCmdResult, Mnd);
end;

procedure TDxPipeClient.HExists(Key, field: string; CmdReturn: TBoolCmdReturnG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TBoolCmdReturnA(Mnd^.Code) := CmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FHExists(PipeClient, PChar(Key), PChar(field), False, boolCmdResult, Mnd);
end;

procedure TDxPipeClient.HMSet(Key: string; keyValues: array of TKeyValue; CmdReturn: TBoolCmdReturn);
var
  Mnd: PMethod;
  i, l: Integer;
  redisKVs: array of TRedisKeyValue;
begin
  l := Length(keyValues);
  if l = 0 then
    Exit;
  SetLength(redisKVs, l);
  for i := 0 to l - 1 do
  begin
    redisKVs[i].Key := PChar(keyValues[i].Key);
    redisKVs[i].Value.Value := PChar(keyValues[i].Value);
    redisKVs[i].Value.ValueLen := 0;
  end;

  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FHMSet(PipeClient, PChar(Key), @redisKVs[0], l, False, boolCmdResult, Mnd);
end;

procedure TDxPipeClient.HMSet(Key: string; keyValues: array of TKeyValue; CmdReturn: TBoolCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
  i, l: Integer;
  redisKVs: array of TRedisKeyValue;
begin
  l := Length(keyValues);
  if l = 0 then
    Exit;
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
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FHMSet(PipeClient, PChar(Key), @redisKVs[0], l, False, boolCmdResult, Mnd);
end;

procedure TDxPipeClient.HMSet(Key: string; keyValues: array of TKeyValue; CmdReturn: TBoolCmdReturnG);
var
  Mnd: PMethod;
  i, l: Integer;
  redisKVs: array of TRedisKeyValue;
begin
  l := Length(keyValues);
  if l = 0 then
    Exit;
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
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FHMSet(PipeClient, PChar(Key), @redisKVs[0], l, False, boolCmdResult, Mnd);
end;

procedure TDxPipeClient.HMSet(Key: string; keyValues: array of TRedisKeyValue; CmdReturn: TBoolCmdReturn);
var
  Mnd: PMethod;
  l: Integer;
begin
  l := Length(keyValues);
  if l = 0 then
    Exit;
  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FHMSet(PipeClient, PChar(Key), @keyValues[0], l, False, boolCmdResult, Mnd);
end;

procedure TDxPipeClient.HMSet(Key: string; keyValues: array of TRedisKeyValue; CmdReturn: TBoolCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
  l: Integer;
begin
  l := Length(keyValues);
  if l = 0 then
    Exit;
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PBoolCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FHMSet(PipeClient, PChar(Key), @keyValues[0], l, False, boolCmdResult, Mnd);
end;

procedure TDxPipeClient.HMSet(Key: string; keyValues: array of TRedisKeyValue; CmdReturn: TBoolCmdReturnG);
var
  Mnd: PMethod;
  l: Integer;
begin
  l := Length(keyValues);
  if l = 0 then
    Exit;
  New(Mnd);
  Mnd^.Data := nil;
  TBoolCmdReturnA(Mnd^.Code) := CmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FHMSet(PipeClient, PChar(Key), @keyValues[0], l, False, boolCmdResult, Mnd);
end;

procedure TDxPipeClient.HSetNX(Key, field, Value: string; CmdReturn: TBoolCmdReturn);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FHSetNX(PipeClient, PChar(Key), PChar(field), PChar(Value), 0, False, boolCmdResult, Mnd);
end;

procedure TDxPipeClient.HSetNX(Key, field, Value: string; CmdReturn: TBoolCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PBoolCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FHSetNX(PipeClient, PChar(Key), PChar(field), PChar(Value), 0, False, boolCmdResult, Mnd);
end;

procedure TDxPipeClient.HSetNX(Key, field, Value: string; CmdReturn: TBoolCmdReturnG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TBoolCmdReturnA(Mnd^.Code) := CmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FHSetNX(PipeClient, PChar(Key), PChar(field), PChar(Value), 0, False, boolCmdResult, Mnd);
end;

procedure TDxPipeClient.HSetNX(Key, field: string; ValueBuffer: PByte; buffLen: Integer; CmdReturn: TBoolCmdReturn);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FHSetNX(PipeClient, PChar(Key), PChar(field), ValueBuffer, buffLen, False, boolCmdResult, Mnd);
end;

procedure TDxPipeClient.HSetNX(Key, field: string; ValueBuffer: PByte; buffLen: Integer; CmdReturn: TBoolCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PBoolCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FHSetNX(PipeClient, PChar(Key), PChar(field), ValueBuffer, buffLen, False, boolCmdResult, Mnd);
end;

procedure TDxPipeClient.HSetNX(Key, field: string; ValueBuffer: PByte; buffLen: Integer; CmdReturn: TBoolCmdReturnG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TBoolCmdReturnA(Mnd^.Code) := CmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FHSetNX(PipeClient, PChar(Key), PChar(field), ValueBuffer, buffLen, False, boolCmdResult, Mnd);
end;

procedure TDxPipeClient.SIsMember(Key, Value: string; CmdReturn: TBoolCmdReturn);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSIsMember(PipeClient, PChar(Key), PChar(Value), 0, False, boolCmdResult, Mnd);
end;

procedure TDxPipeClient.SIsMember(Key, Value: string; CmdReturn: TBoolCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PBoolCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSIsMember(PipeClient, PChar(Key), PChar(Value), 0, False, boolCmdResult, Mnd);
end;

procedure TDxPipeClient.SIsMember(Key, Value: string; CmdReturn: TBoolCmdReturnG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TBoolCmdReturnA(Mnd^.Code) := CmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSIsMember(PipeClient, PChar(Key), PChar(Value), 0, False, boolCmdResult, Mnd);
end;

procedure TDxPipeClient.SIsMember(Key: string; ValueBuffer: PByte; buffLen: Integer; CmdReturn: TBoolCmdReturn);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSIsMember(PipeClient, PChar(Key), ValueBuffer, buffLen, False, boolCmdResult, Mnd);
end;

procedure TDxPipeClient.SIsMember(Key: string; ValueBuffer: PByte; buffLen: Integer; CmdReturn: TBoolCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PBoolCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSIsMember(PipeClient, PChar(Key), ValueBuffer, buffLen, False, boolCmdResult, Mnd);
end;

procedure TDxPipeClient.SIsMember(Key: string; ValueBuffer: PByte; buffLen: Integer; CmdReturn: TBoolCmdReturnG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TBoolCmdReturnA(Mnd^.Code) := CmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSIsMember(PipeClient, PChar(Key), ValueBuffer, buffLen, False, boolCmdResult, Mnd);
end;

procedure TDxPipeClient.SMove(source, destination, Member: string; CmdReturn: TBoolCmdReturn);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSMove(PipeClient, PChar(source), PChar(destination), PChar(Member), 0, False, boolCmdResult, Mnd);
end;

procedure TDxPipeClient.SMove(source, destination, Member: string; CmdReturn: TBoolCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PBoolCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSMove(PipeClient, PChar(source), PChar(destination), PChar(Member), 0, False, boolCmdResult, Mnd);
end;

procedure TDxPipeClient.SMove(source, destination, Member: string; CmdReturn: TBoolCmdReturnG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TBoolCmdReturnA(Mnd^.Code) := CmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSMove(PipeClient, PChar(source), PChar(destination), PChar(Member), 0, False, boolCmdResult, Mnd);
end;

procedure TDxPipeClient.SMove(source, destination: string; Member: PByte; memberLen: Integer; CmdReturn: TBoolCmdReturn);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSMove(PipeClient, PChar(source), PChar(destination), Member, memberLen, False, boolCmdResult, Mnd);
end;

procedure TDxPipeClient.SMove(source, destination: string; Member: PByte; memberLen: Integer; CmdReturn: TBoolCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PBoolCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSMove(PipeClient, PChar(source), PChar(destination), Member, memberLen, False, boolCmdResult, Mnd);
end;

procedure TDxPipeClient.SMove(source, destination: string; Member: PByte; memberLen: Integer; CmdReturn: TBoolCmdReturnG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TBoolCmdReturnA(Mnd^.Code) := CmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSMove(PipeClient, PChar(source), PChar(destination), Member, memberLen, False, boolCmdResult, Mnd);
end;

procedure TDxPipeClient.ClientPause(pauseTime: Integer; CmdReturn: TBoolCmdReturn);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FClientPause(PipeClient, pauseTime, False, boolCmdResult, Mnd);
end;

procedure TDxPipeClient.ClientPause(pauseTime: Integer; CmdReturn: TBoolCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PBoolCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FClientPause(PipeClient, pauseTime, False, boolCmdResult, Mnd);
end;

procedure TDxPipeClient.ClientPause(pauseTime: Integer; CmdReturn: TBoolCmdReturnG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TBoolCmdReturnA(Mnd^.Code) := CmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FClientPause(PipeClient, pauseTime, False, boolCmdResult, Mnd);
end;

procedure TDxPipeClient.Sort(Key: string; Sort: TRedisSort; CmdReturn: TStringSliceCmdReturn);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSort(PipeClient, PChar(Key), @Sort, False, stringSliceCmdResult, Mnd);
end;

procedure TDxPipeClient.Sort(Key: string; Sort: TRedisSort; CmdReturn: TStringSliceCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PStringSliceCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSort(PipeClient, PChar(Key), @Sort, False, stringSliceCmdResult, Mnd);
end;

procedure TDxPipeClient.Sort(Key: string; Sort: TRedisSort; CmdReturn: TStringSliceCmdReturnG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TStringSliceCmdReturnA(Mnd^.Code) := CmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSort(PipeClient, PChar(Key), @Sort, False, stringSliceCmdResult, Mnd);
end;

procedure TDxPipeClient.SortStore(Key, storeKey: string; Sort: TRedisSort; CmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSortStore(PipeClient, PChar(Key), PChar(storeKey), @Sort, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.SortStore(Key, storeKey: string; Sort: TRedisSort; CmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSortStore(PipeClient, PChar(Key), PChar(storeKey), @Sort, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.SortStore(Key, storeKey: string; Sort: TRedisSort; CmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := CmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSortStore(PipeClient, PChar(Key), PChar(storeKey), @Sort, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.HKeys(Key: string; CmdReturn: TRedisScanCmdReturn);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FHKeys(PipeClient, PChar(Key), False, scanCmdResult, Mnd);
end;

procedure TDxPipeClient.HKeys(Key: string; CmdReturn: TRedisScanCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PRedisScanCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FHKeys(PipeClient, PChar(Key), False, scanCmdResult, Mnd);
end;

procedure TDxPipeClient.HKeys(Key: string; CmdReturn: TRedisScanCmdReturnG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TRedisScanCmdReturnA(Mnd^.Code) := CmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FHKeys(PipeClient, PChar(Key), False, scanCmdResult, Mnd);
end;

procedure TDxPipeClient.HVals(Key: string; CmdReturn: TStringSliceCmdReturn);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FHVals(PipeClient, PChar(Key), False, stringSliceCmdResult, Mnd);
end;

procedure TDxPipeClient.HVals(Key: string; CmdReturn: TStringSliceCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PStringSliceCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FHVals(PipeClient, PChar(Key), False, stringSliceCmdResult, Mnd);
end;

procedure TDxPipeClient.HVals(Key: string; CmdReturn: TStringSliceCmdReturnG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TStringSliceCmdReturnA(Mnd^.Code) := CmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FHVals(PipeClient, PChar(Key), False, stringSliceCmdResult, Mnd);
end;

procedure TDxPipeClient.HRandField(Key: string; count: Integer; withValues: Boolean; CmdReturn: TStringSliceCmdReturn);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FHRandField(PipeClient, PChar(Key), count, withValues, False, stringSliceCmdResult, Mnd);
end;

procedure TDxPipeClient.HRandField(Key: string; count: Integer; withValues: Boolean; CmdReturn: TStringSliceCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PStringSliceCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FHRandField(PipeClient, PChar(Key), count, withValues, False, stringSliceCmdResult, Mnd);
end;

procedure TDxPipeClient.HRandField(Key: string; count: Integer; withValues: Boolean; CmdReturn: TStringSliceCmdReturnG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TStringSliceCmdReturnA(Mnd^.Code) := CmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FHRandField(PipeClient, PChar(Key), count, withValues, False, stringSliceCmdResult, Mnd);
end;

procedure TDxPipeClient.BRPop(timeout: Integer; keys: array of string; CmdReturn: TStringSliceCmdReturn);
var
  Mnd: PMethod;
  KeyStr: string;
  i: Integer;
begin
  if Length(keys) = 0 then
    Exit;

  for i := Low(keys) to High(keys) do
  begin
    if i = Low(keys) then
      KeyStr := keys[i]
    else
      KeyStr := KeyStr + #10 + keys[i];
  end;

  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FBRPop(PipeClient, timeout, PChar(KeyStr), False, stringSliceCmdResult, Mnd);
end;

procedure TDxPipeClient.BRPop(timeout: Integer; keys: array of string; CmdReturn: TStringSliceCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
  KeyStr: string;
  i: Integer;
begin
  if Length(keys) = 0 then
    Exit;

  for i := Low(keys) to High(keys) do
  begin
    if i = Low(keys) then
      KeyStr := keys[i]
    else
      KeyStr := KeyStr + #10 + keys[i];
  end;

  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PStringSliceCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FBRPop(PipeClient, timeout, PChar(KeyStr), False, stringSliceCmdResult, Mnd);
end;

procedure TDxPipeClient.BRPop(timeout: Integer; keys: array of string; CmdReturn: TStringSliceCmdReturnG);
var
  Mnd: PMethod;
  KeyStr: string;
  i: Integer;
begin
  if Length(keys) = 0 then
    Exit;

  for i := Low(keys) to High(keys) do
  begin
    if i = Low(keys) then
      KeyStr := keys[i]
    else
      KeyStr := KeyStr + #10 + keys[i];
  end;

  New(Mnd);
  Mnd^.Data := nil;
  TStringSliceCmdReturnA(Mnd^.Code) := CmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FBRPop(PipeClient, timeout, PChar(KeyStr), False, stringSliceCmdResult, Mnd);
end;

procedure TDxPipeClient.BLPop(timeout: Integer; keys: array of string; CmdReturn: TStringSliceCmdReturn);
var
  Mnd: PMethod;
  KeyStr: string;
  i: Integer;
begin
  if Length(keys) = 0 then
    Exit;

  for i := Low(keys) to High(keys) do
  begin
    if i = Low(keys) then
      KeyStr := keys[i]
    else
      KeyStr := KeyStr + #10 + keys[i];
  end;

  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FBLPop(PipeClient, timeout, PChar(KeyStr), False, stringSliceCmdResult, Mnd);
end;

procedure TDxPipeClient.BLPop(timeout: Integer; keys: array of string; CmdReturn: TStringSliceCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
  KeyStr: string;
  i: Integer;
begin
  if Length(keys) = 0 then
    Exit;

  for i := Low(keys) to High(keys) do
  begin
    if i = Low(keys) then
      KeyStr := keys[i]
    else
      KeyStr := KeyStr + #10 + keys[i];
  end;

  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PStringSliceCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FBLPop(PipeClient, timeout, PChar(KeyStr), False, stringSliceCmdResult, Mnd);
end;

procedure TDxPipeClient.BLPop(timeout: Integer; keys: array of string; CmdReturn: TStringSliceCmdReturnG);
var
  Mnd: PMethod;
  KeyStr: string;
  i: Integer;
begin
  if Length(keys) = 0 then
    Exit;

  for i := Low(keys) to High(keys) do
  begin
    if i = Low(keys) then
      KeyStr := keys[i]
    else
      KeyStr := KeyStr + #10 + keys[i];
  end;

  New(Mnd);
  Mnd^.Data := nil;
  TStringSliceCmdReturnA(Mnd^.Code) := CmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FBLPop(PipeClient, timeout, PChar(KeyStr), False, stringSliceCmdResult, Mnd);
end;

procedure TDxPipeClient.LPopCount(Key: string; count: Integer; CmdReturn: TStringSliceCmdReturn);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FLPopCount(PipeClient, PChar(Key), count, False, stringSliceCmdResult, Mnd);
end;

procedure TDxPipeClient.LPopCount(Key: string; count: Integer; CmdReturn: TStringSliceCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PStringSliceCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FLPopCount(PipeClient, PChar(Key), count, False, stringSliceCmdResult, Mnd);
end;

procedure TDxPipeClient.LPopCount(Key: string; count: Integer; CmdReturn: TStringSliceCmdReturnG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TStringSliceCmdReturnA(Mnd^.Code) := CmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FLPopCount(PipeClient, PChar(Key), count, False, stringSliceCmdResult, Mnd);
end;

procedure TDxPipeClient.LRange(Key: string; Start, stop: Int64; CmdReturn: TStringSliceCmdReturn);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FLRange(PipeClient, PChar(Key), Start, stop, False, stringSliceCmdResult, Mnd);
end;

procedure TDxPipeClient.LRange(Key: string; Start, stop: Int64; CmdReturn: TStringSliceCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PStringSliceCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FLRange(PipeClient, PChar(Key), Start, stop, False, stringSliceCmdResult, Mnd);
end;

procedure TDxPipeClient.LRange(Key: string; Start, stop: Int64; CmdReturn: TStringSliceCmdReturnG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TStringSliceCmdReturnA(Mnd^.Code) := CmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FLRange(PipeClient, PChar(Key), Start, stop, False, stringSliceCmdResult, Mnd);
end;

procedure TDxPipeClient.ZRange(Key: string; Start, stop: Int64; CmdReturn: TStringSliceCmdReturn);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZRange(PipeClient, PChar(Key), Start, stop, False, stringSliceCmdResult, Mnd);
end;

procedure TDxPipeClient.ZRange(Key: string; Start, stop: Int64; CmdReturn: TStringSliceCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PStringSliceCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZRange(PipeClient, PChar(Key), Start, stop, False, stringSliceCmdResult, Mnd);
end;

procedure TDxPipeClient.ZRange(Key: string; Start, stop: Int64; CmdReturn: TStringSliceCmdReturnG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TStringSliceCmdReturnA(Mnd^.Code) := CmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZRange(PipeClient, PChar(Key), Start, stop, False, stringSliceCmdResult, Mnd);
end;

procedure TDxPipeClient.ZRevRange(Key: string; Start, stop: Int64; CmdReturn: TStringSliceCmdReturn);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZRevRange(PipeClient, PChar(Key), Start, stop, False, stringSliceCmdResult, Mnd);
end;

procedure TDxPipeClient.ZRevRange(Key: string; Start, stop: Int64; CmdReturn: TStringSliceCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PStringSliceCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZRevRange(PipeClient, PChar(Key), Start, stop, False, stringSliceCmdResult, Mnd);
end;

procedure TDxPipeClient.ZRevRange(Key: string; Start, stop: Int64; CmdReturn: TStringSliceCmdReturnG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TStringSliceCmdReturnA(Mnd^.Code) := CmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZRevRange(PipeClient, PChar(Key), Start, stop, False, stringSliceCmdResult, Mnd);
end;

procedure TDxPipeClient.ZRangeByScore(Key: string; opt: TRedisRangeBy; CmdReturn: TStringSliceCmdReturn);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZRangeByScore(PipeClient, PChar(Key), @opt, False, stringSliceCmdResult, Mnd);
end;

procedure TDxPipeClient.ZRangeByScore(Key: string; opt: TRedisRangeBy; CmdReturn: TStringSliceCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PStringSliceCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZRangeByScore(PipeClient, PChar(Key), @opt, False, stringSliceCmdResult, Mnd);
end;

procedure TDxPipeClient.ZRangeByScore(Key: string; opt: TRedisRangeBy; CmdReturn: TStringSliceCmdReturnG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TStringSliceCmdReturnA(Mnd^.Code) := CmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZRangeByScore(PipeClient, PChar(Key), @opt, False, stringSliceCmdResult, Mnd);
end;

procedure TDxPipeClient.ZRangeByLex(Key: string; opt: TRedisRangeBy; CmdReturn: TStringSliceCmdReturn);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZRangeByLex(PipeClient, PChar(Key), @opt, False, stringSliceCmdResult, Mnd);
end;

procedure TDxPipeClient.ZRangeByLex(Key: string; opt: TRedisRangeBy; CmdReturn: TStringSliceCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PStringSliceCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZRangeByLex(PipeClient, PChar(Key), @opt, False, stringSliceCmdResult, Mnd);
end;

procedure TDxPipeClient.ZRangeByLex(Key: string; opt: TRedisRangeBy; CmdReturn: TStringSliceCmdReturnG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TStringSliceCmdReturnA(Mnd^.Code) := CmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZRangeByLex(PipeClient, PChar(Key), @opt, False, stringSliceCmdResult, Mnd);
end;

procedure TDxPipeClient.SDiff(keys: array of string; CmdReturn: TStringSliceCmdReturn);
var
  Mnd: PMethod;
  KeyStr: string;
  i: Integer;
begin
  if Length(keys) = 0 then
    Exit;

  for i := Low(keys) to High(keys) do
  begin
    if i = Low(keys) then
      KeyStr := keys[i]
    else
      KeyStr := KeyStr + #10 + keys[i];
  end;

  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSDiff(PipeClient, PChar(KeyStr), False, stringSliceCmdResult, Mnd);
end;

procedure TDxPipeClient.SDiff(keys: array of string; CmdReturn: TStringSliceCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
  KeyStr: string;
  i: Integer;
begin
  if Length(keys) = 0 then
    Exit;

  for i := Low(keys) to High(keys) do
  begin
    if i = Low(keys) then
      KeyStr := keys[i]
    else
      KeyStr := KeyStr + #10 + keys[i];
  end;

  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PStringSliceCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSDiff(PipeClient, PChar(KeyStr), False, stringSliceCmdResult, Mnd);
end;

procedure TDxPipeClient.SDiff(keys: array of string; CmdReturn: TStringSliceCmdReturnG);
var
  Mnd: PMethod;
  KeyStr: string;
  i: Integer;
begin
  if Length(keys) = 0 then
    Exit;

  for i := Low(keys) to High(keys) do
  begin
    if i = Low(keys) then
      KeyStr := keys[i]
    else
      KeyStr := KeyStr + #10 + keys[i];
  end;

  New(Mnd);
  Mnd^.Data := nil;
  TStringSliceCmdReturnA(Mnd^.Code) := CmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSDiff(PipeClient, PChar(KeyStr), False, stringSliceCmdResult, Mnd);
end;

procedure TDxPipeClient.SUnion(keys: array of string; CmdReturn: TStringSliceCmdReturn);
var
  Mnd: PMethod;
  KeyStr: string;
  i: Integer;
begin
  if Length(keys) = 0 then
    Exit;

  for i := Low(keys) to High(keys) do
  begin
    if i = Low(keys) then
      KeyStr := keys[i]
    else
      KeyStr := KeyStr + #10 + keys[i];
  end;

  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSUnion(PipeClient, PChar(KeyStr), False, stringSliceCmdResult, Mnd);
end;

procedure TDxPipeClient.SUnion(keys: array of string; CmdReturn: TStringSliceCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
  KeyStr: string;
  i: Integer;
begin
  if Length(keys) = 0 then
    Exit;

  for i := Low(keys) to High(keys) do
  begin
    if i = Low(keys) then
      KeyStr := keys[i]
    else
      KeyStr := KeyStr + #10 + keys[i];
  end;

  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PStringSliceCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSUnion(PipeClient, PChar(KeyStr), False, stringSliceCmdResult, Mnd);
end;

procedure TDxPipeClient.SUnion(keys: array of string; CmdReturn: TStringSliceCmdReturnG);
var
  Mnd: PMethod;
  KeyStr: string;
  i: Integer;
begin
  if Length(keys) = 0 then
    Exit;

  for i := Low(keys) to High(keys) do
  begin
    if i = Low(keys) then
      KeyStr := keys[i]
    else
      KeyStr := KeyStr + #10 + keys[i];
  end;

  New(Mnd);
  Mnd^.Data := nil;
  TStringSliceCmdReturnA(Mnd^.Code) := CmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSUnion(PipeClient, PChar(KeyStr), False, stringSliceCmdResult, Mnd);
end;

procedure TDxPipeClient.SInter(keys: array of string; CmdReturn: TStringSliceCmdReturn);
var
  Mnd: PMethod;
  KeyStr: string;
  i: Integer;
begin
  if Length(keys) = 0 then
    Exit;

  for i := Low(keys) to High(keys) do
  begin
    if i = Low(keys) then
      KeyStr := keys[i]
    else
      KeyStr := KeyStr + #10 + keys[i];
  end;

  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSInter(PipeClient, PChar(KeyStr), False, stringSliceCmdResult, Mnd);
end;

procedure TDxPipeClient.SInter(keys: array of string; CmdReturn: TStringSliceCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
  KeyStr: string;
  i: Integer;
begin
  if Length(keys) = 0 then
    Exit;

  for i := Low(keys) to High(keys) do
  begin
    if i = Low(keys) then
      KeyStr := keys[i]
    else
      KeyStr := KeyStr + #10 + keys[i];
  end;

  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PStringSliceCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSInter(PipeClient, PChar(KeyStr), False, stringSliceCmdResult, Mnd);
end;

procedure TDxPipeClient.SInter(keys: array of string; CmdReturn: TStringSliceCmdReturnG);
var
  Mnd: PMethod;
  KeyStr: string;
  i: Integer;
begin
  if Length(keys) = 0 then
    Exit;

  for i := Low(keys) to High(keys) do
  begin
    if i = Low(keys) then
      KeyStr := keys[i]
    else
      KeyStr := KeyStr + #10 + keys[i];
  end;

  New(Mnd);
  Mnd^.Data := nil;
  TStringSliceCmdReturnA(Mnd^.Code) := CmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSInter(PipeClient, PChar(KeyStr), False, stringSliceCmdResult, Mnd);
end;

procedure TDxPipeClient.SMembers(Key: string; CmdReturn: TStringSliceCmdReturn);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSMembers(PipeClient, PChar(Key), False, stringSliceCmdResult, Mnd);
end;

procedure TDxPipeClient.SMembers(Key: string; CmdReturn: TStringSliceCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PStringSliceCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSMembers(PipeClient, PChar(Key), False, stringSliceCmdResult, Mnd);
end;

procedure TDxPipeClient.SMembers(Key: string; CmdReturn: TStringSliceCmdReturnG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TStringSliceCmdReturnA(Mnd^.Code) := CmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSMembers(PipeClient, PChar(Key), False, stringSliceCmdResult, Mnd);
end;

procedure TDxPipeClient.SPopN(Key: string; count: Int64; CmdReturn: TStringSliceCmdReturn);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSPopN(PipeClient, PChar(Key), count, False, stringSliceCmdResult, Mnd);
end;

procedure TDxPipeClient.SPopN(Key: string; count: Int64; CmdReturn: TStringSliceCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PStringSliceCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSPopN(PipeClient, PChar(Key), count, False, stringSliceCmdResult, Mnd);
end;

procedure TDxPipeClient.SPopN(Key: string; count: Int64; CmdReturn: TStringSliceCmdReturnG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TStringSliceCmdReturnA(Mnd^.Code) := CmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSPopN(PipeClient, PChar(Key), count, False, stringSliceCmdResult, Mnd);
end;

procedure TDxPipeClient.SRandMemberN(Key: string; count: Int64; CmdReturn: TStringSliceCmdReturn);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSRandMemberN(PipeClient, PChar(Key), count, False, stringSliceCmdResult, Mnd);
end;

procedure TDxPipeClient.SRandMemberN(Key: string; count: Int64; CmdReturn: TStringSliceCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PStringSliceCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSRandMemberN(PipeClient, PChar(Key), count, False, stringSliceCmdResult, Mnd);
end;

procedure TDxPipeClient.SRandMemberN(Key: string; count: Int64; CmdReturn: TStringSliceCmdReturnG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TStringSliceCmdReturnA(Mnd^.Code) := CmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FSRandMemberN(PipeClient, PChar(Key), count, False, stringSliceCmdResult, Mnd);
end;

procedure TDxPipeClient.ZRevRangeByScore(Key: string; opt: TRedisRangeBy; CmdReturn: TStringSliceCmdReturn);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZRevRangeByScore(PipeClient, PChar(Key), @opt, False, stringSliceCmdResult, Mnd);
end;

procedure TDxPipeClient.ZRevRangeByScore(Key: string; opt: TRedisRangeBy; CmdReturn: TStringSliceCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PStringSliceCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZRevRangeByScore(PipeClient, PChar(Key), @opt, False, stringSliceCmdResult, Mnd);
end;

procedure TDxPipeClient.ZRevRangeByScore(Key: string; opt: TRedisRangeBy; CmdReturn: TStringSliceCmdReturnG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TStringSliceCmdReturnA(Mnd^.Code) := CmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZRevRangeByScore(PipeClient, PChar(Key), @opt, False, stringSliceCmdResult, Mnd);
end;

procedure TDxPipeClient.ZRevRangeByLex(Key: string; opt: TRedisRangeBy; CmdReturn: TStringSliceCmdReturn);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZRevRangeByLex(PipeClient, PChar(Key), @opt, False, stringSliceCmdResult, Mnd);
end;

procedure TDxPipeClient.ZRevRangeByLex(Key: string; opt: TRedisRangeBy; CmdReturn: TStringSliceCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PStringSliceCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZRevRangeByLex(PipeClient, PChar(Key), @opt, False, stringSliceCmdResult, Mnd);
end;

procedure TDxPipeClient.ZRevRangeByLex(Key: string; opt: TRedisRangeBy; CmdReturn: TStringSliceCmdReturnG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TStringSliceCmdReturnA(Mnd^.Code) := CmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZRevRangeByLex(PipeClient, PChar(Key), @opt, False, stringSliceCmdResult, Mnd);
end;

procedure TDxPipeClient.ZRandMember(Key: string; count: Integer; withScores: Boolean; CmdReturn: TStringSliceCmdReturn);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZRandMember(PipeClient, PChar(Key), count, withScores, False, stringSliceCmdResult, Mnd);
end;

procedure TDxPipeClient.ZRandMember(Key: string; count: Integer; withScores: Boolean; CmdReturn: TStringSliceCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PStringSliceCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZRandMember(PipeClient, PChar(Key), count, withScores, False, stringSliceCmdResult, Mnd);
end;

procedure TDxPipeClient.ZRandMember(Key: string; count: Integer; withScores: Boolean; CmdReturn: TStringSliceCmdReturnG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TStringSliceCmdReturnA(Mnd^.Code) := CmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZRandMember(PipeClient, PChar(Key), count, withScores, False, stringSliceCmdResult, Mnd);
end;

procedure TDxPipeClient.ZDiff(keys: array of string; CmdReturn: TStringSliceCmdReturn);
var
  Mnd: PMethod;
  KeyStr: string;
  i: Integer;
begin
  if Length(keys) = 0 then
    Exit;

  for i := Low(keys) to High(keys) do
  begin
    if i = Low(keys) then
      KeyStr := keys[i]
    else
      KeyStr := KeyStr + #10 + keys[i];
  end;

  New(Mnd);
  Mnd^ := TMethod(CmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZDiff(PipeClient, PChar(KeyStr), False, stringSliceCmdResult, Mnd);
end;

procedure TDxPipeClient.ZDiff(keys: array of string; CmdReturn: TStringSliceCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
  KeyStr: string;
  i: Integer;
begin
  if Length(keys) = 0 then
    Exit;

  for i := Low(keys) to High(keys) do
  begin
    if i = Low(keys) then
      KeyStr := keys[i]
    else
      KeyStr := KeyStr + #10 + keys[i];
  end;

  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PStringSliceCmdReturnA(@TMethod(ATemp).Code)^ := CmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZDiff(PipeClient, PChar(KeyStr), False, stringSliceCmdResult, Mnd);
end;

procedure TDxPipeClient.ZDiff(keys: array of string; CmdReturn: TStringSliceCmdReturnG);
var
  Mnd: PMethod;
  KeyStr: string;
  i: Integer;
begin
  if Length(keys) = 0 then
    Exit;

  for i := Low(keys) to High(keys) do
  begin
    if i = Low(keys) then
      KeyStr := keys[i]
    else
      KeyStr := KeyStr + #10 + keys[i];
  end;

  New(Mnd);
  Mnd^.Data := nil;
  TStringSliceCmdReturnA(Mnd^.Code) := CmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FZDiff(PipeClient, PChar(KeyStr), False, stringSliceCmdResult, Mnd);
end;

procedure TDxPipeClient.LInsert(Key: string; before: Boolean; pivot,
  Value: TValueInterface; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FLInsert(PipeClient, PChar(Key), before, @pivot, @Value, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.LInsert(Key: string; before: Boolean; pivot,
  Value: TValueInterface; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FLInsert(PipeClient, PChar(Key), before, @pivot,@Value, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.LInsert(Key: string; before: Boolean; pivot,
  Value: TValueInterface; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FLInsert(PipeClient, PChar(Key), before, @pivot,@Value, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.LInsertBefore(Key: string; pivot,
  Value: TValueInterface; intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FLInsertBefore(PipeClient, PChar(Key), @pivot,@Value, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.LInsertBefore(Key: string; pivot,
  Value: TValueInterface; intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FLInsertBefore(PipeClient, PChar(Key), @pivot,@Value, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.LInsertBefore(Key: string; pivot,
  Value: TValueInterface; intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FLInsertBefore(PipeClient, PChar(Key), @pivot,@Value, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.LInsertAfter(Key: string; pivot, Value: TValueInterface;
  intCmdReturn: TIntCmdReturn);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^ := TMethod(intCmdReturn);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FLInsertAfter(PipeClient, PChar(Key), @pivot,@Value, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.LInsertAfter(Key: string; pivot, Value: TValueInterface;
  intCmdReturn: TIntCmdReturnA);
var
  Mnd: PMethod;
  ATemp: TIntCmdReturn;
begin
  TMethod(ATemp).Data := Pointer(-1);
  TMethod(ATemp).Code := nil;
  PIntCmdReturnA(@TMethod(ATemp).Code)^ := intCmdReturn;
  New(Mnd);
  Mnd^ := TMethod(ATemp);
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FLInsertAfter(PipeClient, PChar(Key), @pivot,@Value, False, intCmdResult, Mnd);
end;

procedure TDxPipeClient.LInsertAfter(Key: string; pivot, Value: TValueInterface;
  intCmdReturn: TIntCmdReturnG);
var
  Mnd: PMethod;
begin
  New(Mnd);
  Mnd^.Data := nil;
  TIntCmdReturnA(Mnd^.Code) := intCmdReturn;
  TDxRedisSdkManagerEx(FOwner.RedisSdkManager).FLInsertAfter(PipeClient, PChar(Key), @pivot,@Value, False, intCmdResult, Mnd);
end;

end.

