program demo4428;

uses
  Forms,
  Test4428 in 'Test4428.pas' {Frm4428},
  drv_unit in 'drv_unit.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TFrm4428, Frm4428);
  Application.Run; 
if icdev>0 then begin
 st := IC_ExitComm(icdev);
 icdev:=0;
 end;
  
end.
