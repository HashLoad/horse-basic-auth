unit Horse.BasicAuthentication;

interface

uses Horse, System.SysUtils, System.NetEncoding, System.Classes;

const
  AUTHORIZATION = 'authorization';

type
  THorseBasicAuthentication = reference to function(const AUsername, APassword: string): Boolean;

procedure Middleware(Req: THorseRequest; Res: THorseResponse; Next: TProc);
function HorseBasicAuthentication(const AAuthenticate: THorseBasicAuthentication; const AHeader: string = AUTHORIZATION): THorseCallback;

implementation

var
  Header: string;
  Authenticate: THorseBasicAuthentication;

function HorseBasicAuthentication(const AAuthenticate: THorseBasicAuthentication; const AHeader: string = AUTHORIZATION): THorseCallback;
begin
  Header := AHeader;
  Authenticate := AAuthenticate;
  Result := Middleware;
end;

procedure Middleware(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  LBasicAuthenticationEncode: string;
  LBasicAuthenticationDecode: TStringList;
  LIsAuthenticated: Boolean;
begin
  if not Req.Headers.TryGetValue(Header, LBasicAuthenticationEncode) and not Req.Query.TryGetValue(Header, LBasicAuthenticationEncode) then
  begin
    Res.Send('Authorization not found').Status(401);
    raise EHorseCallbackInterrupted.Create;
  end;
  if Pos('basic', LowerCase(LBasicAuthenticationEncode)) = 0 then
  begin
    Res.Send('Invalid authorization type').Status(401);
    raise EHorseCallbackInterrupted.Create;
  end;
  LBasicAuthenticationDecode := TStringList.Create;
  try
    LBasicAuthenticationDecode.Delimiter := ':';
    LBasicAuthenticationDecode.DelimitedText := TBase64Encoding.Base64.Decode(LBasicAuthenticationEncode.Replace('basic ', '', [rfIgnoreCase]));
    try
      LIsAuthenticated := Authenticate(LBasicAuthenticationDecode.Strings[0], LBasicAuthenticationDecode.Strings[1]);
    except
      on E: exception do
      begin
        Res.Send(E.Message).Status(500);
        raise EHorseCallbackInterrupted.Create;
      end;
    end;
  finally
    LBasicAuthenticationDecode.Free;
  end;
  if not LIsAuthenticated then
  begin
    Res.Send('Unauthorized').Status(401);
    raise EHorseCallbackInterrupted.Create;
  end;
  Next();
end;

end.
