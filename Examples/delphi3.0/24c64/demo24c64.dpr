program demo24c64;

uses
  Forms,
  Test24c64 in 'Test24c64.pas' {Frm24c64},
  drv_unit in 'drv_unit.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TFrm24c64, Frm24c64);
  Application.Run;
  if icdev>0 then begin
 st := IC_ExitComm(icdev);
 icdev:=0;
 end;
end.
