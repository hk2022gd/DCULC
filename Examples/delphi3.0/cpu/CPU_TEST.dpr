program CPU_TEST;

uses
  Forms,
  cpu_unit in 'cpu_unit.pas' {Form1},
  declare_unit in 'declare_unit.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
