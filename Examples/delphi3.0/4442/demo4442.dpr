program demo4442;

uses
  Forms,
  Test4442 in 'Test4442.pas' {Frm4442},
  drv_unit in 'drv_unit.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TFrm4442, Frm4442);
  Application.Run; 
 if icdev>0 then begin
 st := IC_ExitComm(icdev);
 icdev:=0 ;
 end;
end.
