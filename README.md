# horse-basic-auth

Middleware for Basic Authentication in HORSE

Sample Horse server validate basic authentication:

```delphi
uses
  Horse, Horse.BasicAuthentication, System.SysUtils;

var
  App: THorse;

begin
  App := THorse.Create(9000);

  App.Use(HorseBasicAuthentication(
    function(const AUsername, APassword: string): Boolean
    begin
      Result := AUsername.Equals('user') and APassword.Equals('password');
    end));

  App.Get('ping',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    begin
      Res.Send('pong');
    end);

  App.Start;
end.
```
