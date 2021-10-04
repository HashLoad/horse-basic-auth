program Console;

{$MODE DELPHI}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Horse,
  Horse.BasicAuthentication,
  SysUtils;

procedure GetPing(Req: THorseRequest; Res: THorseResponse; Next: TNextProc);
begin
  Res.Send('Pong');
end;

procedure OnListen(Horse: THorse);
begin
  Writeln(Format('Server is runing on %s:%d', [Horse.Host, Horse.Port]));
end;

function DoLogin(const AUsername, APassword: string): Boolean;
begin
  Result := AUsername.Equals('user') and APassword.Equals('password');
end;

begin
  THorse.Use(HorseBasicAuthentication(DoLogin));

  THorse.Get('/ping', GetPing);

  THorse.Listen(9000, OnListen);
end.
