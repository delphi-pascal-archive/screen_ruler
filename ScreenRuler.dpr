program ScreenRuler;

uses
  Forms,
  main in 'main.pas' {MainForm},
  UAbout in 'UAbout.pas' {AboutBox};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Screen RULER';
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
