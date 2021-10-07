program Console;

{$MODE DELPHI}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Horse,
  Horse.BasicAuthentication, // It's necessary to use the unit
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
  // Here inside you can access your database and validate if username and password are valid
  Result := AUsername.Equals('user') and APassword.Equals('password');
end;

begin
  // It's necessary to add the middleware in the Horse:
  THorse.Use(HorseBasicAuthentication(DoLogin));

  // The default header for receiving credentials is "Authorization".
  // You can change, if necessary:
  // THorse.Use(HorseBasicAuthentication(MyCallbackValidation, 'X-My-Header-Authorization'));

  THorse.Get('/ping', GetPing);

  THorse.Listen(9000, OnListen);
end.
