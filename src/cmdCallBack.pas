unit cmdCallBack;

interface
uses Winapi.Windows,System.SysUtils,System.Classes,utils_buffer, RedisSDK,redisPipeline,qstring;

type
  TLogData = record
    logLevel: TRedisLogLevel;
    logMsg: string;
  end;

  PLogData = ^TLogData;

  TRedisStatusResult = record
    IsErrResult: Boolean;
    client: TDxRedisClient;
    params: Pointer;
    CmdResult: string;
  end;

  PRedisStatusResult = ^TRedisStatusResult;

  TRedisScanResult = record
    IsErrResult: Boolean;
    cursor: UInt64;
    client: TDxRedisClient;
    params: Pointer;
    keys: string;
  end;

  PRedisScanResult = ^TRedisScanResult;

  TRedisStringByteResult = record
    IsErrResult: Boolean;
    strValue: string;
    client: TDxRedisClient;
    params: Pointer;
    Buffer: PMemoryBlock;
  end;

  PRedisStringByteResult = ^TRedisStringByteResult;

  TStringCmdMethod = record
    isByteReturn: Boolean;
    Method: TMethod;
  end;

  PStringCmdMethod = ^TStringCmdMethod;

  TSelectCmdMethod = record
    DBIndex: Byte;
    Method: TMethod;
  end;

  PSelectCmdMethod = ^TSelectCmdMethod;

  TRedisIntResult = record
    client: TDxRedisClient;
    params: Pointer;
    CmdResult: Int64;
    errMsg: string;
  end;

  PRedisIntResult = ^TRedisIntResult;
procedure LogProc(Data: Pointer; logLevel: Integer; logMsg: PChar); stdcall;
procedure statusCmdResult(redisClient, params: Pointer; CmdResult: PChar;IsErrResult: Boolean); stdcall;
procedure stringCmdResult(redisClient, params: Pointer; CmdResult: Pointer;resultLen: Integer; IsErrResult: Boolean); stdcall;
procedure intCmdResult(redisClient, params: Pointer; intResult: Int64;errMsg: PChar); stdcall;
procedure PipeExecReturn(pipeClient,params: Pointer;errMsg: PChar);stdcall;
procedure scanCmdResult(redisClient, params: Pointer; keys: PChar;cursor: Int64; IsErrResult: Boolean); stdcall;
implementation

type
  TDxRedisSdkManagerEx = class(TDxRedisSdkManager);
  TDxRedisClientEx = class(TDxRedisClient);

procedure LogProc(Data: Pointer; logLevel: Integer; logMsg: PChar); stdcall;
var
  redisManager: TDxRedisSdkManagerEx absolute Data;
  logData: PLogData;
  logCallBack: TRedisLogEvent;
begin
  if GetCurrentThreadId <> MainThreadID then
  begin
    New(logData);
    logData^.logLevel := TRedisLogLevel(logLevel);
    logData^.logMsg := StrPas(logMsg);
    logCallBack := redisManager.DoRedisLogEvent;
    redisManager.PostRedisMsg(MC_Log, logData);
  end
  else if Assigned(redisManager.FOnLog) then
    redisManager.FOnLog(redisManager, TRedisLogLevel(logLevel), StrPas(logMsg));
end;

procedure statusCmdResult(redisClient, params: Pointer; CmdResult: PChar;IsErrResult: Boolean); stdcall;
var
  rClient: TDxRedisClient;
  pipeClient: TDxPipeClient;
  statusCmdResult: PRedisStatusResult;
begin
  if TObject(redisClient).InheritsFrom(TDxRedisClient) then
  begin
    rClient := redisClient;
    pipeClient := nil;
  end
  else
  begin
    pipeClient := redisClient;
    rClient := pipeClient.Owner;
  end;
  if GetCurrentThreadId <> MainThreadID then
  begin
    New(statusCmdResult);
    statusCmdResult^.client := redisClient;
    statusCmdResult^.IsErrResult := IsErrResult;
    statusCmdResult^.params := params;
    statusCmdResult^.CmdResult := StrPas(CmdResult);
    TDxRedisSdkManagerEx(rClient.RedisSdkManager).PostRedisMsg(MC_StatusCmd, statusCmdResult);
  end
  else
  begin
    if PMethod(params)^.Code <> nil then
    begin
      if PMethod(params)^.Data = nil then
        TRedisStatusCmdG(PMethod(params)^.Code)(StrPas(CmdResult), IsErrResult)
      else if PMethod(params)^.Data = Pointer(-1) then
      begin
        TRedisStatusCmdA(PMethod(params)^.Code)(StrPas(CmdResult), IsErrResult);
        TRedisStatusCmdA(PMethod(params)^.Code) := nil;
      end
      else
        TRedisStatusCmd(PMethod(params)^)(redisClient, StrPas(CmdResult),
          IsErrResult);
    end;
    Dispose(params);
  end;
  if pipeClient = nil then
    AtomicDecrement(TDxRedisClientEx(rclient).FRunningCount, 1);
end;

procedure stringCmdResult(redisClient, params: Pointer; CmdResult: Pointer;resultLen: Integer; IsErrResult: Boolean); stdcall;
var
  strResult: PRedisStringByteResult;
  rClient: TDxRedisClient;
  pipeClient: TDxPipeClient;
  block: PMemoryBlock;
  strMethod: PStringCmdMethod;
  errMsg: string;
begin
  if TObject(redisClient).InheritsFrom(TDxRedisClient) then
  begin
    rClient := redisClient;
    pipeClient := nil;
  end
  else
  begin
    pipeClient := redisClient;
    rClient := pipeClient.Owner;
  end;
  strMethod := params;
  if GetCurrentThreadId <> MainThreadID then
  begin
    New(strResult);
    strResult^.client := redisClient;
    strResult^.IsErrResult := IsErrResult;
    strResult^.params := params;
    if IsErrResult then
      strResult^.strValue := StrPas(PChar(CmdResult))
    else
    begin
      if not strMethod^.isByteReturn or (resultLen = 0) then
      begin
        strResult^.Buffer := nil;
        strResult^.strValue := StrPas(PChar(CmdResult))
      end
      else
      begin
        block := GetMemBlock(CalcMemType(resultLen));
        block^.DataLen := resultLen;
        Move(CmdResult^, block^.Memory^, resultLen);
        strResult^.Buffer := block;
      end;
    end;
    TDxRedisSdkManagerEx(rclient.RedisSdkManager).PostRedisMsg(MC_StringCmd, strResult);
  end
  else
  begin
    if strMethod^.Method.Code <> nil then
    begin
      if strMethod^.isByteReturn then
      begin
        if IsErrResult then
          errMsg := StrPas(PChar(CmdResult))
        else
          errMsg := '';
        if strMethod^.Method.Data = nil then
          TRedisStringCmdReturnByteG(strMethod^.Method.Code)
            (CmdResult, resultLen, errMsg)
        else if strMethod^.Method.Data = Pointer(-1) then
        begin
          TRedisStringCmdReturnByteA(strMethod^.Method.Code)
            (CmdResult, resultLen, errMsg);
          TRedisStringCmdReturnByteA(strMethod^.Method.Code) := nil;
        end
        else
          TRedisStringCmdReturnByte(strMethod^.Method)
            (redisClient, CmdResult, resultLen, errMsg);
      end
      else
      begin
        if strMethod^.Method.Data = nil then
          TRedisStringCmdReturnG(strMethod^.Method.Code)
            (StrPas(PChar(CmdResult)), IsErrResult)
        else if strMethod^.Method.Data = Pointer(-1) then
        begin
          TRedisStringCmdReturnA(strMethod^.Method.Code)
            (StrPas(PChar(CmdResult)), IsErrResult);
          TRedisStringCmdReturnA(strMethod^.Method.Code) := nil;
        end
        else
          TRedisStringCmdReturn(strMethod^.Method)
            (redisClient, StrPas(PChar(CmdResult)), IsErrResult);
      end;
    end;
    Dispose(strMethod);
  end;
  if pipeClient = nil then
    AtomicDecrement(TDxRedisClientEx(rclient).FRunningCount, 1);
end;

procedure intCmdResult(redisClient, params: Pointer; intResult: Int64;errMsg: PChar); stdcall;
var
  intCmdResult: PRedisIntResult;
  rClient: TDxRedisClient;
  pipeClient: TDxPipeClient;
begin
  if TObject(redisClient).InheritsFrom(TDxRedisClient) then
  begin
    rClient := redisClient;
    pipeClient := nil;
  end
  else
  begin
    pipeClient := redisClient;
    rClient := pipeClient.Owner;
  end;
  if GetCurrentThreadId <> MainThreadID then
  begin
    New(intCmdResult);
    intCmdResult^.client := redisClient;
    intCmdResult^.CmdResult := intResult;
    intCmdResult^.params := params;
    intCmdResult^.errMsg := StrPas(errMsg);
    TDxRedisSdkManagerEx(rClient.RedisSdkManager).PostRedisMsg(MC_IntCmd, intCmdResult);
  end
  else
  begin
    if PMethod(params)^.Code <> nil then
    begin
      if PMethod(params)^.Data = nil then
        TIntCmdReturnG(PMethod(params)^.Code)(intResult, StrPas(errMsg))
      else if PMethod(params)^.Data = Pointer(-1) then
      begin
        TIntCmdReturnA(PMethod(params)^.Code)(intResult, StrPas(errMsg));
        PMethod(params)^.Code := nil;
      end
      else
        TIntCmdReturn(PMethod(params)^)(redisClient, intResult, StrPas(errMsg));
    end;
    Dispose(params);
  end;
  if pipeClient = nil then
    AtomicDecrement(TDxRedisClientEx(rclient).FRunningCount, 1);
end;

procedure PipeExecReturn(pipeClient,params: Pointer;errMsg: PChar);stdcall;
var
  pClient: TDxPipeClient absolute pipeClient;
  statusCmdResult: PRedisStatusResult;
  rclient: TDxRedisClient;
begin
  rclient := pClient.Owner;
  if GetCurrentThreadId <> MainThreadID then
  begin
    New(statusCmdResult);
    statusCmdResult^.client := pipeClient;
    statusCmdResult^.CmdResult := StrPas(errMsg);
    statusCmdResult^.IsErrResult := statusCmdResult^.CmdResult <> '';
    statusCmdResult^.params := params;
    TDxRedisSdkManagerEx(rclient.RedisSdkManager).PostRedisMsg(MC_pipeCmd, statusCmdResult);
  end
  else
  begin
    if PMethod(params)^.Code <> nil then
    begin
      if PMethod(params)^.Data = nil then
        TPipelineExecReturnG(PMethod(params)^.Code)(StrPas(errMsg))
      else if PMethod(params)^.Data = Pointer(-1) then
      begin
        TPipelineExecReturnA(PMethod(params)^.Code)(StrPas(errMsg));
        PMethod(params)^.Code := nil;
      end
      else
        TPipelineExecReturn(PMethod(params)^)(pClient, StrPas(errMsg));
    end;
    Dispose(params);
  end;
  AtomicDecrement(TDxRedisClientEx(rclient).FRunningCount, 1);
end;

procedure scanCmdResult(redisClient, params: Pointer; keys: PChar;cursor: Int64; IsErrResult: Boolean); stdcall;
var
  rClient: TDxRedisClient;
  pipeClient: TDxPipeClient;
  errMsg: string;
  keyArray: array of string;
  l: Integer;
  p: PChar;
  scanCmdResult: PRedisScanResult;
begin
  if TObject(redisClient).InheritsFrom(TDxRedisClient) then
  begin
    rClient := redisClient;
    pipeClient := nil;
  end
  else
  begin
    pipeClient := redisClient;
    rClient := pipeClient.Owner;
  end;
  if GetCurrentThreadId <> MainThreadID then
  begin
    New(scanCmdResult);
    scanCmdResult^.client := redisClient;
    scanCmdResult^.IsErrResult := IsErrResult;
    scanCmdResult^.params := params;
    scanCmdResult^.keys := StrPas(keys);
    scanCmdResult^.cursor := cursor;
    TDxRedisSdkManagerEx(rclient.RedisSdkManager).PostRedisMsg(MC_ScanCmd, scanCmdResult);
  end
  else
  begin
    if PMethod(params)^.Code <> nil then
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
      if PMethod(params)^.Data = nil then
        TRedisScanCmdReturnG(PMethod(params)^.Code)(keyArray, cursor, errMsg)
      else if PMethod(params)^.Data = Pointer(-1) then
      begin
        TRedisScanCmdReturnA(PMethod(params)^.Code)(keyArray, cursor, errMsg);
        TRedisScanCmdReturnA(PMethod(params)^.Code) := nil;
      end
      else
        TRedisScanCmdReturn(PMethod(params)^)(redisClient, keyArray, cursor, errMsg);
    end;
    Dispose(params);
  end;
  if pipeClient = nil then
    AtomicDecrement(TDxRedisClientEx(rclient).FRunningCount, 1);
end;

end.
