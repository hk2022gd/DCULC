program demo24c01;

uses
  Forms,
  Test24c01 in 'Test24c01.pas' {Frm24c01},
  drv_unit in 'drv_unit.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TFrm24c01, Frm24c01);
  Application.Run;
end.
