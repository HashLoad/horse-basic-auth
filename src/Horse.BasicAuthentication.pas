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
const
  UNAUTHORIZED = 'Unauthorized';
var
  LBasicAuthenticationEncode: string;
  LBasicAuthenticationDecode: TStringList;
begin
  if not Req.Headers.TryGetValue(Header, LBasicAuthenticationEncode) and not Req.Query.TryGetValue(Header, LBasicAuthenticationEncode) then
  begin
    Res.Send('Basic Authentication not found').Status(401);
    raise EHorseCallbackInterrupted.Create;
  end;
  LBasicAuthenticationDecode := TStringList.Create;
  try
    LBasicAuthenticationDecode.Delimiter := ':';
    LBasicAuthenticationDecode.DelimitedText := TBase64Encoding.Base64.Decode(LBasicAuthenticationEncode.Replace('basic ', '', [rfIgnoreCase]));
    try
      if not Authenticate(LBasicAuthenticationDecode.Strings[0], LBasicAuthenticationDecode.Strings[1]) then
        Res.Send(UNAUTHORIZED).Status(401);
      Next();
    except
      on E: exception do
      begin
        if E.InheritsFrom(EHorseCallbackInterrupted) then
          raise EHorseCallbackInterrupted(E);
        Res.Send(UNAUTHORIZED).Status(401);
        raise EHorseCallbackInterrupted.Create;
      end;
    end;
  finally
    LBasicAuthenticationDecode.Free;
  end;
end;

end.
