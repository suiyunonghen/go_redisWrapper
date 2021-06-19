# go_redisWrapper
go-redis wrapper sdk  delphi
将go-redis包装成动态库，然后提供给delphi使用，目前支持一些常用命令，同时也支持pipeline管道，所有的命令都是通过回调函数处理
# 用法
## CreateSdkManager
> 使用之前，必须先建立SDK管理器
```pascal
  SdkManager := TDxRedisSdkManager.Create();
  SdkManager.OnLog := redisLog;
  SdkManager.DllPath := 'dllredis.dll';    
```

## 创建redis的一个使用客户端，所有发送命令都通过这个来处理
```pascal
//创建一个redisClient
  Result := TDxRedisClient.Create;
  Result.ConStyle := RedisConSentinel;  //指定为哨兵模式，目前暂时不支持集群模式    
  Result.UserName := "如果是哨兵模式，这里是主服务名";  
  Result.Password := "redis密码";
  Result.Address := "192.168.3.12:4234;192.168.3.13:4234;192.168.3.15:4234"; //哨兵就是哨兵地址列表，使用;分割，如果是单机，就一个地址
  Result.DefaultDBIndex := 10;  //默认数据库索引
  Result.DialTimeout := 15;   //连接超时时间15秒
  Result.ReadTimeout := 30;   //读取超时时间，秒
  Result.WriteTimeout := 30;  //写入超时时间，秒  
  Result.MaxRetry := 1;    //最大重试次数
  Result.RedisSdkManager := SdkManager;  //指定绑定到哪个SDK  
```

## 使用命令
```pascal
  client.Ping(procedure(CmdResult: string;
    IsErrResult: Boolean)
    begin
      if IsErrResult then
        Showmessage('ping发生错误：'+cmdResult)
      else ShowMessage('执行成功：'+cmdResult);
    end);
```

## 管道用法
```pascal
  pipe := TDxPipeClient.create(Self);
  pipe.TxPipe := true; //事务性管道
  pipe.Select(10, procedure(CmdResult: string;IsErrResult: Boolean)
    begin
      if IsErrResult then
        Showmessage('select发生错误：'+cmdResult)
      else ShowMessage('select执行成功：'+cmdResult);
    end);
  pipe.Scan(0,'*',10000,procedure(keys: array of string;cursor: UInt64; errMsg: string)
    begin
      if errMsg <> '' then
        Showmessage('scan发生错误:'+errMsg)
       else 
       begin
          if cursor <> 0 then
            client.ScanType(cursor,'*','',10000,False,scanReturn);
          Showmessage('返回了keys:')
        end;
    end);
  pipe.Execute(False,procedure(errMsg: string)
    begin
      Pipe.Free;
    end);
```
