unit cmdCallBack;

interface
uses Winapi.Windows,System.SysUtils,System.Classes,RedisSDK,redisPipeline,qstring;

type
  TLogData = record
    logLevel: TRedisLogLevel;
    logMsg: string;
  end;

  PLogData = ^TLogData;

  TRedisStatusResult = record
    IsErrResult: Boolean;
    client: Pointer;
    params: Pointer;
    CmdResult: string;
  end;
  PRedisStatusResult = ^TRedisStatusResult;

  TScanResultType = (
    scanResultErr,
    scanResultKeyStr,	                  //返回Key字符串列表\r\n区分
    scanResultKeyValue,					  //2表示keyValue 数组
    scanResultValue,						  // valueInterface数组
    scanResultScoreValue          // TScoreValue 数组
  );

  TRedisScanResult = record
    resultType: TScanResultType;
    cursor: UInt64;
    client: Pointer;
    params: Pointer;
    keys: array of string;
    ErrMsg: string;
    values: array of TValueInterface;
    KeyValues: array of TKeyValueEx;
    ScoreValues: array of TScoreValue;
  end;

  PRedisScanResult = ^TRedisScanResult;

  TRedisStringByteResult = record
    IsErrResult: Boolean;
    strValue: string;
    client: Pointer;
    params: Pointer;
    Buffer: PByte;
    BufferLen: Integer;
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

  TScanMethod = record
    ScanResultType: TScanResultType;
    Method: TMethod;
  end;
  PScanMethod = ^TScanMethod;


  TRedisIntResult = record
    client: Pointer;
    params: Pointer;
    errMsg: string;
    case Boolean of
    true: (CmdResult: Int64);
    false: (floatResult: Double);
  end;
  PRedisIntResult = ^TRedisIntResult;

  TRedisStringSliceCmdResult = record
    client: Pointer;
    params: Pointer;
    errMsg: string;
    values: array of TValueInterface;
  end;
  PRedisStringSliceCmdResult = ^TRedisStringSliceCmdResult;

procedure LogProc(Data: Pointer; logLevel: Integer; logMsg: PChar); stdcall;
procedure statusCmdResult(redisClient, params: Pointer; CmdResult: PChar;IsErrResult: Boolean); stdcall;
procedure stringCmdResult(redisClient, params: Pointer; CmdResult: Pointer;resultLen: Integer; IsErrResult: Boolean); stdcall;
procedure intCmdResult(redisClient, params: Pointer; intResult: Int64;errMsg: PChar); stdcall;
procedure floatCmdResult(redisClient, params: Pointer; floatResult: double;errMsg: PChar); stdcall;
procedure PipeExecReturn(pipeClient,params: Pointer;errMsg: PChar);stdcall;
procedure scanCmdResult(redisClient, params: Pointer; results: Pointer;ValuesLen: Integer;cursor: Int64; resultType: Byte); stdcall;
procedure boolCmdResult(redisClient, params: Pointer; intResult: Int64;errMsg: PChar); stdcall;

procedure stringSliceCmdResult(redisClient, params: Pointer;resultSlice: PValueInterface;sliceLen: Integer;errMsg: Pchar);stdcall;
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
    strResult^.BufferLen := resultLen;
    if IsErrResult then
    begin
      strResult^.Buffer := nil;
      strResult^.strValue := StrPas(PChar(CmdResult));
    end
    else
    begin
      if not strMethod^.isByteReturn or (resultLen = 0) then
      begin
        strResult^.Buffer := nil;
        strResult^.strValue := StrPas(PChar(CmdResult))
      end
      else
      begin
        strResult^.Buffer := GetMemory(resultLen);
        Move(CmdResult^, strResult^.Buffer^, resultLen);
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

procedure floatCmdResult(redisClient, params: Pointer; floatResult: double;errMsg: PChar); stdcall;
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
    intCmdResult^.floatResult := floatResult;
    intCmdResult^.params := params;
    intCmdResult^.errMsg := StrPas(errMsg);
    TDxRedisSdkManagerEx(rClient.RedisSdkManager).PostRedisMsg(MC_FloatCmd, intCmdResult);
  end
  else
  begin
    if PMethod(params)^.Code <> nil then
    begin
      if PMethod(params)^.Data = nil then
        TfloatCmdReturnG(PMethod(params)^.Code)(floatResult, StrPas(errMsg))
      else if PMethod(params)^.Data = Pointer(-1) then
      begin
        TfloatCmdReturnA(PMethod(params)^.Code)(floatResult, StrPas(errMsg));
        PMethod(params)^.Code := nil;
      end
      else
        TfloatCmdReturn(PMethod(params)^)(redisClient, floatResult, StrPas(errMsg));
    end;
    Dispose(params);
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

procedure boolCmdResult(redisClient, params: Pointer; intResult: Int64;errMsg: PChar); stdcall;
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
    TDxRedisSdkManagerEx(rClient.RedisSdkManager).PostRedisMsg(MC_BoolCmd, intCmdResult);
  end
  else
  begin
    if PMethod(params)^.Code <> nil then
    begin
      if PMethod(params)^.Data = nil then
        TBoolCmdReturnG(PMethod(params)^.Code)(intResult=1, StrPas(errMsg))
      else if PMethod(params)^.Data = Pointer(-1) then
      begin
        TBoolCmdReturnA(PMethod(params)^.Code)(intResult=1, StrPas(errMsg));
        PMethod(params)^.Code := nil;
      end
      else
        TBoolCmdReturn(PMethod(params)^)(redisClient, intResult=1, StrPas(errMsg));
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

procedure scanCmdResult(redisClient, params: Pointer; results: Pointer;ValuesLen: Integer;cursor: Int64; resultType: Byte); stdcall;
var
  rClient: TDxRedisClient;
  pipeClient: TDxPipeClient;
  errMsg: string;
  keyArray: array of string;
  value: array of TValueInterface;
  keyValue: array of TKeyValueEx;
  scoreValue: array of TScoreValue;
  i,l: Integer;
  p: PChar;
  scanCmdResult: PRedisScanResult;
  resultSlice: PValueInterface;
  keySlice: PRedisKeyValue;
  scoreSlice: PRedisScoreValue;
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
    scanCmdResult^.resultType := TScanResultType(resultType);
    scanCmdResult^.params := params;
    case TScanResultType(resultType) of
    scanResultErr: scanCmdResult^.ErrMsg := StrPas(PChar(results));
    scanResultKeyValue:
      begin
        SetLength(scanCmdResult^.KeyValues, ValuesLen);
        keySlice := results;
        for i := 0 to ValuesLen - 1 do
        begin
          scanCmdResult^.keyValues[i].Key := StrPas(keySlice^.Key);
          scanCmdResult^.keyValues[i].value.ValueLen := keySlice^.Value.ValueLen;
          scanCmdResult^.keyValues[i].value.Value := GetMemory(keySlice^.Value.ValueLen);
          Move(keySlice^.Value.Value^,scanCmdResult^.keyValues[i].Value.Value^,keySlice^.Value.ValueLen);
          Inc(keySlice);
        end;
      end;
    scanResultKeyStr:
      begin
        errMsg := qstring.Utf8Decode(results,ValuesLen);
        SetLength(scanCmdResult^.keys, 4);
        l := 0;
        p := PChar(errMsg);
        repeat
          scanCmdResult^.keys[l] := DecodeTokenW(p, #13#10, #0, False);
          Inc(l);
          if (l = Length(scanCmdResult^.keys)) and (p^ <> #0) then
            SetLength(scanCmdResult^.keys, l + 4);
        until p^ = #0;
        SetLength(scanCmdResult^.keys, l);
      end;
    scanResultScoreValue:
      begin
        scoreSlice := results;
        SetLength(scanCmdResult^.ScoreValues, ValuesLen);
        for i := 0 to ValuesLen - 1 do
        begin
          scanCmdResult^.ScoreValues[i].key := StrPas(scoreSlice^.key);
          scanCmdResult^.ScoreValues[i].score := scoreSlice^.score;
          Inc(scoreSlice);
        end;
      end;
    scanResultValue:
      begin
        SetLength(scanCmdResult^.values, ValuesLen);
        resultSlice := results;
        for i := 0 to ValuesLen - 1 do
        begin
          scanCmdResult^.values[i].ValueLen := resultSlice^.ValueLen;
          scanCmdResult^.values[i].Value := GetMemory(resultSlice^.ValueLen);
          Move(resultSlice^.Value^,scanCmdResult^.values[i].Value^,resultSlice^.ValueLen);
          Inc(resultSlice);
        end;
      end;
    end;
    scanCmdResult^.cursor := cursor;
    TDxRedisSdkManagerEx(rclient.RedisSdkManager).PostRedisMsg(MC_ScanCmd, scanCmdResult);
  end
  else
  begin
    if PScanMethod(params)^.Method.Code <> nil then
    begin
      case TScanResultType(resultType) of
      scanResultErr:
        begin
          errMsg := StrPas(PChar(results));
          case PScanMethod(params)^.ScanResultType of
          scanResultKeyStr:
            begin
              SetLength(keyArray, 0);
              if PScanMethod(params)^.Method.Data = nil then
                TRedisScanCmdReturnG(PScanMethod(params)^.Method.Code)(keyArray, cursor, errMsg)
              else if PScanMethod(params)^.Method.Data = Pointer(-1) then
              begin
                TRedisScanCmdReturnA(PScanMethod(params)^.Method.Code)(keyArray, cursor, errMsg);
                PScanMethod(params)^.Method.Code := nil;
              end
              else
                TRedisScanCmdReturn(PScanMethod(params)^.Method)(redisClient, keyArray, cursor, errMsg);
            end;
          scanResultValue:
            begin
              SetLength(value, 0);
              if PScanMethod(params)^.Method.Data = nil then
                TRedisScanValueCmdReturnG(PScanMethod(params)^.Method.Code)(value,cursor, errMsg)
              else if PScanMethod(params)^.Method.Data = Pointer(-1) then
              begin
                TRedisScanValueCmdReturnA(PScanMethod(params)^.Method.Code)(value,cursor, errMsg);
                PScanMethod(params)^.Method.Code := nil;
              end
              else
                TRedisScanValueCmdReturn(PScanMethod(params)^.Method)(redisClient, value,cursor, errMsg);
            end;
          scanResultScoreValue:
            begin
              SetLength(scoreValue,0);
              if PScanMethod(params)^.Method.Data = nil then
                TRedisScanKScoreCmdReturnG(PScanMethod(params)^.Method.Code)(scoreValue,cursor, errMsg)
              else if PScanMethod(params)^.Method.Data = Pointer(-1) then
              begin
                TRedisScanKScoreCmdReturnA(PScanMethod(params)^.Method.Code)(scoreValue,cursor, errMsg);
                PScanMethod(params)^.Method.Code := nil;
              end
              else
                TRedisScanKScoreCmdReturn(PScanMethod(params)^.Method)(redisClient, scoreValue,cursor, errMsg);
            end;
          scanResultKeyValue:
            begin
              SetLength(keyValue,0);
              if PScanMethod(params)^.Method.Data = nil then
                TRedisScanKvCmdReturnG(PScanMethod(params)^.Method.Code)(keyValue,cursor, errMsg)
              else if PScanMethod(params)^.Method.Data = Pointer(-1) then
              begin
                TRedisScanKvCmdReturnA(PScanMethod(params)^.Method.Code)(keyValue,cursor, errMsg);
                PScanMethod(params)^.Method.Code := nil;
              end
              else
                TRedisScanKvCmdReturn(PScanMethod(params)^.Method)(redisClient, keyValue,cursor, errMsg);
            end;
          end;
        end;
      scanResultKeyValue:
        begin
          SetLength(keyValue, ValuesLen);
          keySlice := results;
          for i := 0 to ValuesLen - 1 do
          begin
            keyValue[i].Key := StrPas(keySlice^.Key);
            keyValue[i].value.ValueLen := keySlice^.Value.ValueLen;
            keyValue[i].value.Value := keySlice^.Value.Value;
            Inc(keySlice);
          end;
          if PScanMethod(params)^.Method.Data = nil then
            TRedisScanKVCmdReturnG(PScanMethod(params)^.Method.Code)(keyValue,cursor, errMsg)
          else if PScanMethod(params)^.Method.Data = Pointer(-1) then
          begin
            TRedisScanKVCmdReturnA(PScanMethod(params)^.Method.Code)(keyValue,cursor, errMsg);
            PScanMethod(params)^.Method.Code := nil;
          end
          else
            TRedisScanKVCmdReturn(PScanMethod(params)^.Method)(redisClient, keyValue,cursor, errMsg);
        end;
      scanResultKeyStr:
        begin
          errMsg := '';
          SetLength(keyArray, 4);
          l := 0;
          p := results;
          repeat
            keyArray[l] := DecodeTokenW(p, #13#10, #0, False);
            Inc(l);
            if (l = Length(keyArray)) and (p^ <> #0) then
              SetLength(keyArray, l + 4);
          until p^ = #0;
          SetLength(keyArray, l);
          if PScanMethod(params)^.Method.Data = nil then
            TRedisScanCmdReturnG(PScanMethod(params)^.Method.Code)(keyArray, cursor, errMsg)
          else if PScanMethod(params)^.Method.Data = Pointer(-1) then
          begin
            TRedisScanCmdReturnA(PScanMethod(params)^.Method.Code)(keyArray, cursor, errMsg);
            PScanMethod(params)^.Method.Code := nil;
          end
          else
            TRedisScanCmdReturn(PScanMethod(params)^.Method)(redisClient, keyArray, cursor, errMsg);
        end;
      scanResultScoreValue:
        begin
          scoreSlice := results;
          if PScanMethod(params)^.ScanResultType = scanResultScoreValue then
          begin
            SetLength(scoreValue, ValuesLen);
            for i := 0 to ValuesLen - 1 do
            begin
              scoreValue[i].key := StrPas(scoreSlice^.key);
              scoreValue[i].score := scoreSlice^.score;
              Inc(scoreSlice);
            end;
            if PScanMethod(params)^.Method.Data = nil then
              TRedisScanKScoreCmdReturnG(PScanMethod(params)^.Method.Code)(scoreValue,cursor, errMsg)
            else if PScanMethod(params)^.Method.Data = Pointer(-1) then
            begin
              TRedisScanKScoreCmdReturnA(PScanMethod(params)^.Method.Code)(scoreValue,cursor, errMsg);
              PScanMethod(params)^.Method.Code := nil;
            end
            else
              TRedisScanKScoreCmdReturn(PScanMethod(params)^.Method)(redisClient, scoreValue,cursor, errMsg);
          end;
        end;
      scanResultValue:
        begin
          resultSlice := results;
          if PScanMethod(params)^.ScanResultType = scanResultKeyStr then
          begin
            SetLength(keyArray, ValuesLen);
            for i := 0 to ValuesLen - 1 do
            begin
              keyArray[i] := qstring.Utf8Decode(resultSlice^.Value,resultSlice^.ValueLen);
              Inc(resultSlice);
            end;
            if PScanMethod(params)^.Method.Data = nil then
              TRedisScanCmdReturnG(PScanMethod(params)^.Method.Code)(keyArray, cursor, errMsg)
            else if PScanMethod(params)^.Method.Data = Pointer(-1) then
            begin
              TRedisScanCmdReturnA(PScanMethod(params)^.Method.Code)(keyArray, cursor, errMsg);
              PScanMethod(params)^.Method.Code := nil;
            end
            else
              TRedisScanCmdReturn(PScanMethod(params)^.Method)(redisClient, keyArray, cursor, errMsg);
          end
          else if PScanMethod(params)^.ScanResultType = scanResultValue then
          begin
            SetLength(value, ValuesLen);
            for i := 0 to ValuesLen - 1 do
            begin
              value[i].ValueLen := resultSlice^.ValueLen;
              value[i].Value := resultSlice^.Value;
              Inc(resultSlice);
            end;
            if PScanMethod(params)^.Method.Data = nil then
              TRedisScanValueCmdReturnG(PScanMethod(params)^.Method.Code)(value,cursor, errMsg)
            else if PScanMethod(params)^.Method.Data = Pointer(-1) then
            begin
              TRedisScanValueCmdReturnA(PScanMethod(params)^.Method.Code)(value,cursor, errMsg);
              PScanMethod(params)^.Method.Code := nil;
            end
            else
              TRedisScanValueCmdReturn(PScanMethod(params)^.Method)(redisClient, value,cursor, errMsg);
          end;
        end;
      end;
    end;
    Dispose(params);
  end;
  if pipeClient = nil then
    AtomicDecrement(TDxRedisClientEx(rclient).FRunningCount, 1);
end;

procedure stringSliceCmdResult(redisClient, params: Pointer;resultSlice: PValueInterface;sliceLen: Integer;errMsg: Pchar);stdcall;
var
  rClient: TDxRedisClient;
  pipeClient: TDxPipeClient;
  err: string;
  i: Integer;
  values: array of TValueInterface;
  CmdResult: PRedisStringSliceCmdResult;
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

  err := StrPas(errMsg);
  if GetCurrentThreadId <> MainThreadID then
  begin
    New(CmdResult);
    CmdResult^.client := redisClient;
    CmdResult^.errMsg := err;
    CmdResult^.params := params;
    SetLength(CmdResult^.values,sliceLen);
    for i := 0 to sliceLen - 1 do
    begin
      CmdResult^.values[i].ValueLen := resultSlice^.ValueLen;
      CmdResult^.values[i].Value := GetMemory(resultSlice^.ValueLen);
      Move(resultSlice^.Value^,CmdResult^.values[i].Value^,resultSlice^.ValueLen);
      Inc(resultSlice);
    end;
    TDxRedisSdkManagerEx(rclient.RedisSdkManager).PostRedisMsg(MC_StringSliceCmd, CmdResult);
  end
  else
  begin
    if PMethod(params)^.Code <> nil then
    begin
      SetLength(values,sliceLen);
      Move(resultSlice^,values[0],SizeOf(TValueInterface) * sliceLen);
      if PMethod(params)^.Data = nil then
        TStringSliceCmdReturnG(PMethod(params)^.Code)(values,err)
      else if PMethod(params)^.Data = Pointer(-1) then
      begin
        TStringSliceCmdReturnA(PMethod(params)^.Code)(values,err);
        PMethod(params)^.Code := nil;
      end
      else
        TStringSliceCmdReturn(PMethod(params)^)(redisClient, values,err);
    end;
    Dispose(params);
  end;
  if pipeClient = nil then
    AtomicDecrement(TDxRedisClientEx(rclient).FRunningCount, 1);
end;

end.
