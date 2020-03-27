program Settings;

uses
  Forms,
  main in 'main.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'SMWF Settings';
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
