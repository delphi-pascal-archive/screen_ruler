unit UAbout;

interface

uses
  Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, Messages, shellapi;

type
  TAboutBox = class(TForm)
    Panel1: TPanel;
    ProductName: TLabel;
    OKButton: TButton;
    lblURL: TLabel;
    ProgramIcon: TImage;
    StaticText1: TStaticText;
    Label1: TLabel;
    procedure lblURLClick(Sender: TObject);
    procedure StaticText1Click(Sender: TObject);
  private
  public
    class procedure ShowMe;
  end;

var
  AboutBox: TAboutBox;

implementation
{$R *.dfm}

procedure ChangeColor(Sender : TObject; Msg : Integer);
begin
 if Sender is TLabel Then
 begin
   if (Msg = CM_MOUSELEAVE) then
   begin
     (Sender As TLabel).Font.Color:=clWindowText;
     (Sender As TLabel).Font.Style:=(Sender As TLabel).Font.Style - [fsUnderline] ;
   end;
   if (Msg = CM_MOUSEENTER) then
   begin
     (Sender As TLabel).Font.Color:=clBlue;
     (Sender As TLabel).Font.Style:=(Sender As TLabel).Font.Style + [fsUnderline] ;
   end;
 end;
end;     

procedure TAboutBox.lblURLClick(Sender: TObject);
begin
  ShellExecute(Handle, 'open',PChar(lblURL.Caption),nil,nil,SW_SHOWNORMAL);
end;

class procedure TAboutBox.ShowMe;
begin
  with TAboutBox.Create(nil) do
  try
    ShowModal;
  finally
    Free;
  end;
end;

procedure TAboutBox.StaticText1Click(Sender: TObject);
begin
  ShellExecute(Handle, 'open','mailto:delphi.guide@about.com?subject=About Delphi Programming: RULER',nil,nil,SW_SHOWNORMAL);
end;


end.

