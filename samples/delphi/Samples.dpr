program Samples;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  Horse,
  Horse.BasicAuthentication, // It's necessary to use the unit
  System.SysUtils;

begin
  // It's necessary to add the middleware in the Horse:
  THorse.Use(HorseBasicAuthentication(
    function(const AUsername, APassword: string): Boolean
    begin
      // Here inside you can access your database and validate if username and password are valid
      Result := AUsername.Equals('user') and APassword.Equals('password');
    end));

  // The default header for receiving credentials is "Authorization".
  // You can change, if necessary:
  // THorse.Use(HorseBasicAuthentication(MyCallbackValidation, 'X-My-Header-Authorization'));

  THorse.Get('/ping',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    begin
      Res.Send('pong');
    end);

  THorse.Listen(9000);
end.
