program Console;

{$MODE DELPHI}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Horse,
  Horse.BasicAuthentication, // It's necessary to use the unit
  SysUtils;

procedure GetPing(Req: THorseRequest; Res: THorseResponse);
begin
  Res.Send('Pong');
end;

procedure OnListen;
begin
  Writeln(Format('Server is runing on port %d', [THorse.Port]));
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
  // THorse.Use(HorseBasicAuthentication(MyCallbackValidation, THorseBasicAuthenticationConfig.New.Header('X-My-Header-Authorization')));

  // You can also ignore routes:
  // THorse.Use(HorseBasicAuthentication(MyCallbackValidation, THorseBasicAuthenticationConfig.New.SkipRoutes(['/ping'])));

  THorse.Get('/ping', GetPing);

  THorse.Listen(9000, OnListen);
end.
