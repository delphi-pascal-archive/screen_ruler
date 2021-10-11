unit main;

interface

uses
  inifiles, Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, StdCtrls, ExtCtrls, AppEvnts;

type
  TTickSize = record
    SmallTick,
    MediumTick,
    LargeTick,
    BigTick: integer;
    SmallText,
    LargeText : integer;
  end;

  TPixelPerMM = record
    x,y : single;
  end;

  TRulerUnit = (ruPixel = 1, ruMilimeter = 2);

  TTickPositionOption = (tpTop, tpRight, tpBottom, tpLeft);
  TTickPosition = set of TTickPositionOption;

  TPixelMMConverter = class
  private
    class procedure PixelsPerMM(canvas:TCanvas; var x,y:single);
    class function Pixel2MM_H(const Value : integer) : integer;
    class function Pixel2MM_W(const Value : integer) : integer;
  end;

  TMainForm = class(TForm)
    Menu: TPopupMenu;
    mnuOnTop: TMenuItem;
    mnuTransparency: TMenuItem;
    DimensionLabel: TLabel;
    mnuExit: TMenuItem;
    AppEvents: TApplicationEvents;
    mnut10: TMenuItem;
    mnut20: TMenuItem;
    mnut40: TMenuItem;
    mnut50: TMenuItem;
    mnut60: TMenuItem;
    mnut0: TMenuItem;
    mnuTickPosition: TMenuItem;
    mnutickTop: TMenuItem;
    mnutickRight: TMenuItem;
    mnutickBottom: TMenuItem;
    mnuTickLeft: TMenuItem;
    mnut30: TMenuItem;
    mnuAbout: TMenuItem;
    mnuStickScreen: TMenuItem;
    mnuUnit: TMenuItem;
    mnuPixel: TMenuItem;
    mnuMilimeter: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure mnuExitClick(Sender: TObject);
    procedure AppEventsIdle(Sender: TObject; var Done: Boolean);
    procedure mnuOnTopClick(Sender: TObject);
    procedure mnut0Click(Sender: TObject);
    procedure mnutickTopClick(Sender: TObject);
    procedure mnutickRightClick(Sender: TObject);
    procedure mnutickBottomClick(Sender: TObject);
    procedure mnuTickLeftClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure mnuAboutClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure mnuStickScreenClick(Sender: TObject);
    procedure mnuPixelClick(Sender: TObject);
    procedure mnuMilimeterClick(Sender: TObject);
  private
    fTickPosition: TTickPosition;
    fTransparency: integer;
    fRulerUnit: TRulerUnit;
    procedure SetTickPosition(const Value: TTickPosition);
    procedure SetTransparency(const Value: integer);
    procedure SetRulerUnit(const Value: TRulerUnit);
  private
    BorderXWidth : integer;
    BorderYWidth : integer;
    procedure WMNCHitTest(var Msg: TWMNCHitTest); message wm_NCHitTest;
    procedure WMNCRButtonDown(var Message : TWMNCRButtonDown); message WM_NCRBUTTONDOWN;
    procedure WMDisplayChange(var message:TMessage); message WM_DISPLAYCHANGE;

    procedure DrawHorizontalTicker;
    procedure DrawVerticalTicker;

    procedure LoadSettings;
    procedure SaveSettings;

    procedure ApplyTransparency;

    property TickPosition : TTickPosition read fTickPosition write SetTickPosition;

    property RulerUnit : TRulerUnit read fRulerUnit write SetRulerUnit;
    property Transparency : integer read fTransparency write SetTransparency;
  protected

    procedure CreateParams (var Params: TCreateParams); override;
  public

  end;

var
  MainForm: TMainForm;

  PixelPerMM : TPixelPerMM;

implementation
{$R *.dfm}
uses UAbout;

procedure TMainForm.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  //no border BUT resizable
  Params.ExStyle := Params.ExStyle or WS_EX_STATICEDGE;
  Params.Style := Params.Style or WS_SIZEBOX;
end;

procedure TMainForm.WMNCHitTest(var Msg: TWMNCHitTest);
begin
  //move the form by dragging from inside the client area - this kils mouse click processing - solved with    WM_NCRBUTTONDOWN
  inherited;
  if Msg.Result = htClient then begin
    Msg.Result := htCaption;
  end;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  TPixelMMConverter.PixelsPerMM(Canvas,PixelPerMM.x, PixelPerMM.y);

  RulerUnit := ruPixel;
  Transparency := 30;

  //Remove TitleBar/Caption
  SetWindowLong(Handle, GWL_STYLE, GetWindowLong( Handle, GWL_STYLE ) and not WS_CAPTION) ;
  ClientHeight := Height;

  DoubleBuffered := true;
  BorderStyle := bsNone;

  BorderXWidth := GetSystemMetrics(SM_CXBORDER);
  BorderYWidth := GetSystemMetrics(SM_CYBORDER);

  DimensionLabel.Top := Self.ClientHeight div 2 - DimensionLabel.Height div 2;
  DimensionLabel.Left := Self.ClientWidth div 2 - DimensionLabel.Width div 2;


  LoadSettings;

end;

procedure TMainForm.WMNCRButtonDown(var Message: TWMNCRButtonDown);
begin
  //after messing with WMNCHitTest the form does not respond to mouse clicks .. make it respond again...
  Menu.Popup(Mouse.CursorPos.X, Mouse.CursorPos.Y);
end;

procedure TMainForm.FormPaint(Sender: TObject);
begin
  if (tpTop in TickPosition) OR (tpBottom in TickPosition) then
  begin
    DrawHorizontalTicker;
  end;
  if (tpLeft in TickPosition) OR (tpRight in TickPosition) then
  begin
    DrawVerticalTicker;
  end;
end; //FormPaint

procedure TMainForm.FormResize(Sender: TObject);
var
  h,w : integer;
  umark:string;
begin
  //place it in the center
  DimensionLabel.Top := Self.ClientHeight div 2 - DimensionLabel.Height div 2;
  DimensionLabel.Left := Self.ClientWidth div 2 - DimensionLabel.Width div 2;

  h := 0; w:= 0;
  case RulerUnit of
    ruPixel:
    begin
      h:= ClientHeight;
      w:= ClientWidth;
      umark := 'px';
    end;
    ruMilimeter:
    begin
      h:= TPixelMMConverter.Pixel2MM_H(ClientHeight);
      w:= TPixelMMConverter.Pixel2MM_H(ClientWidth);
      umark := 'mm';
    end;
  end;
  DimensionLabel.Caption := Format('W: %d %s %s H: %d %s',[w, umark, #13#10, h, umark]);
end;

procedure TMainForm.mnuExitClick(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.AppEventsIdle(Sender: TObject;
  var Done: Boolean);
begin
  Refresh;  //Repaint ...
end;


procedure TMainForm.SetTickPosition(const Value: TTickPosition);
begin
  fTickPosition := Value;

  mnutickTop.Checked := tpTop in TickPosition;
  mnutickBottom.Checked := tpBottom in TickPosition;
  mnuTickLeft.Checked := tpLeft in TickPosition;
  mnutickRight.Checked := tpRight in TickPosition;

end;

procedure TMainForm.SetRulerUnit(const Value: TRulerUnit);
begin
  fRulerUnit := Value;

  mnuPixel.Checked := Value = ruPixel;
  mnuMilimeter.Checked := Value = ruMilimeter;

  //refresh
  FormResize(self);
end;


procedure TMainForm.DrawHorizontalTicker;
var
  Y : integer;
  TickSize : TTickSize;

  procedure DoDraw(Y :integer; TickSize : TTickSize);
  var
    i, j:integer;
    tw:integer; //text width
    marker : string;
    tick : integer;
    dummy : integer;
  begin
    tick := 0;
    for i := 1 to ClientWidth do
    begin
      if RulerUnit = ruMilimeter then
      begin
        dummy := TPixelMMConverter.Pixel2MM_H(i);
        if dummy = tick then Continue;
        tick := dummy;
      end
      else
        tick := i;

      j := i - BorderXWidth;
      Canvas.MoveTo(j,Y);
      if (tick mod 2) = 0 then
      begin
        Canvas.LineTo(j,TickSize.SmallTick);
      end;

      if (tick mod 100) = 0 then
      begin
        Canvas.LineTo(j,TickSize.BigTick);
        Canvas.Font.Style := Canvas.Font.Style + [fsBold] - [fsItalic];
        marker := Format('%d',[tick]);
        tw := Canvas.TextWidth(marker);
        Canvas.TextOut(j  - (tw div 2),TickSize.SmallText,marker);
      end
      else
      begin
        if (tick mod 50) = 0 then
        begin
          Canvas.LineTo(j,TickSize.LargeTick);
          Canvas.Font.Style := Canvas.Font.Style - [fsBold, fsItalic] ;
          marker := Format('%d',[tick]);
          tw := Canvas.TextWidth(marker);
          Canvas.TextOut(j  - (tw div 2),TickSize.LargeText,marker);
        end
        else
        begin
          if (tick mod 10) = 0 then
          begin
            Canvas.LineTo(j,TickSize.MediumTick);
            if RulerUnit = ruMilimeter then
            begin
              Canvas.Font.Style := Canvas.Font.Style + [fsItalic] - [fsBold];
              marker := Format('%d',[tick]);
              tw := Canvas.TextWidth(marker);
              Canvas.TextOut(j  - (tw div 2),TickSize.LargeText,marker);
            end;
          end
        end;
      end;
    end;
  end; //DoDraw
begin
  if tpTop in TickPosition then
  begin
    y := 0;
    TickSize.SmallTick := 5;
    TickSize.MediumTick := 8;
    TickSize.LargeTick := 12;
    TickSize.BigTick := 15;

    TickSize.SmallText := TickSize.BigTick + 5;
    TickSize.LargeText := TickSize.LargeTick + 5;

    DoDraw(Y,TickSize);
  end;

  if tpBottom in TickPosition then
  begin
    y := ClientHeight;
    TickSize.SmallTick := ClientHeight-5;
    TickSize.MediumTick := ClientHeight-8;
    TickSize.LargeTick := ClientHeight-12;
    TickSize.BigTick := ClientHeight-15;

    TickSize.SmallText := TickSize.BigTick - 15;
    TickSize.LargeText := TickSize.LargeTick - 20;

    DoDraw(Y,TickSize);
  end;

end; //DrawHorizontalTicker


procedure TMainForm.DrawVerticalTicker;
var
  X : integer;
  TickSize : TTickSize;

  procedure DoDraw(X :integer; TickSize : TTickSize);
  var
    i, j:integer;
    tw:integer; //text width
    marker : string;
    tick : integer;
    dummy : integer;
  begin
    tick := 0;
    for i := 1 to ClientHeight do
    begin
      if RulerUnit = ruMilimeter then
      begin
        dummy := TPixelMMConverter.Pixel2MM_W(i);
        if dummy = tick then Continue;
        tick := dummy;
      end
      else
        tick := i;

      j := i - BorderYWidth;
      Canvas.MoveTo(X,j);
      if (tick mod 2) = 0 then
      begin
        Canvas.LineTo(TickSize.SmallTick,j);
      end;

      if (tick mod 100) = 0 then
      begin
        Canvas.LineTo(TickSize.BigTick,j);
        Canvas.Font.Style := Canvas.Font.Style + [fsBold] - [fsItalic];
        marker := Format('%d',[tick]);
        tw := Canvas.TextHeight(marker);
        Canvas.TextOut(TickSize.SmallText, j - (tw div 2),marker);
      end
      else
      begin
        if (tick mod 50) = 0 then
        begin
          Canvas.LineTo(TickSize.LargeTick,j);
          Canvas.Font.Style := Canvas.Font.Style - [fsBold, fsItalic];
          marker := Format('%d',[tick]);
          tw := Canvas.TextWidth(marker);
          Canvas.TextOut(TickSize.LargeText, j - (tw div 2),marker);
        end
        else
        begin
          if (tick mod 10) = 0 then
          begin
            Canvas.LineTo(TickSize.MediumTick,j);
            if RulerUnit = ruMilimeter then
            begin
              Canvas.Font.Style := Canvas.Font.Style + [fsItalic] - [fsBold];
              marker := Format('%d',[tick]);
              tw := Canvas.TextWidth(marker);
              Canvas.TextOut(TickSize.LargeText, j  - (tw div 2),marker);
            end;
          end
        end;
      end;
    end;
  end; //DoDraw
begin
  if tpLeft in TickPosition then
  begin
    x := 0;
    TickSize.SmallTick := 5;
    TickSize.MediumTick := 8;
    TickSize.LargeTick := 12;
    TickSize.BigTick := 15;

    TickSize.SmallText := TickSize.BigTick;
    TickSize.LargeText := TickSize.LargeTick;

    DoDraw(X,TickSize);
  end;

  if tpRight in TickPosition then
  begin
    x := ClientWidth;
    TickSize.SmallTick := ClientWidth-5;
    TickSize.MediumTick := ClientWidth-8;
    TickSize.LargeTick := ClientWidth-12;
    TickSize.BigTick := ClientWidth-15;

    TickSize.SmallText := TickSize.BigTick - 27;
    TickSize.LargeText := TickSize.LargeTick - 22;

    DoDraw(X,TickSize);
  end;
end; //DrawVerticalTicker


(* POPUP MENU CLICKS START *)

procedure TMainForm.mnuStickScreenClick(Sender: TObject);
begin
  Self.ScreenSnap := mnuStickScreen.Checked;
end;

procedure TMainForm.mnuOnTopClick(Sender: TObject);
begin
  if mnuOnTop.Checked then
    Self.FormStyle := fsStayOnTop
  else
    Self.FormStyle := fsNormal;

end;



procedure TMainForm.mnut0Click(Sender: TObject);
begin
  if NOT (Sender is TMenuItem) then Exit;


  Transparency := (Sender as TMenuItem).Tag;

  ApplyTransparency;
end;

procedure TMainForm.mnutickTopClick(Sender: TObject);
begin
  if mnutickTop.Checked then
    TickPosition := TickPosition + [tpTop]
  else
    TickPosition := TickPosition - [tpTop];
end;

procedure TMainForm.mnutickRightClick(Sender: TObject);
begin
  if mnutickRight.Checked then
    TickPosition := TickPosition + [tpRight]
  else
    TickPosition := TickPosition - [tpRight];
end;

procedure TMainForm.mnutickBottomClick(Sender: TObject);
begin
  if mnutickBottom.Checked then
    TickPosition := TickPosition + [tpBottom]
  else
    TickPosition := TickPosition - [tpBottom];
end;

procedure TMainForm.mnuTickLeftClick(Sender: TObject);
begin
  if mnuTickLeft.Checked then
    TickPosition := TickPosition + [tpLeft]
  else
    TickPosition := TickPosition - [tpLeft];
end;

procedure TMainForm.mnuPixelClick(Sender: TObject);
begin
  RulerUnit := ruPixel;
end;

procedure TMainForm.mnuMilimeterClick(Sender: TObject);
begin
  RulerUnit := ruMilimeter;
end;
(* POPUP MENU CLICKS STOP *)


procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word;  Shift: TShiftState);
var
  delta : integer;
begin
  //Arrow keys move the ruler 5 five pixels, CTRL+Arrow Key moves it 1 pixel and CTRL+Shift+ArrowKey resizes it

  if ssCTRL in Shift then
    delta := 5
  else
    delta := 1;

  if ssShift in Shift then
  begin //resize
    if Key = vk_LEFT then begin Left := Left - delta; width := width + delta; end;
    if Key = vk_RIGHT then begin left := Left + delta; width := width - delta; end;
    if Key = vk_UP then begin top := top - delta; height := height + delta; end;
    if Key = vk_DOWN then begin top := top + delta; height := height - delta; end;
  end
  else
  begin //move
    if Key = vk_LEFT then Left := Left - delta;
    if Key = vk_RIGHT then left := Left + delta;
    if Key = vk_UP then top := top - delta;
    if Key = vk_DOWN then top := top + delta;
  end;

end;

procedure TMainForm.mnuAboutClick(Sender: TObject);
begin
  TAboutBox.ShowMe;
end;

procedure TMainForm.LoadSettings;
var
  IniFile : TIniFile;
begin
  IniFile := TIniFile.Create(ChangeFileExt(Application.ExeName,'.ini'));
  try
    Top := IniFile.ReadInteger('Placement','Top', Top);
    Left := IniFile.ReadInteger('Placement','Left', Left);
    Width := IniFile.ReadInteger('Placement','Width', Width);
    Height := IniFile.ReadInteger('Placement','Height', Height);

    mnuOnTop.Checked := IniFile.ReadBool('Options','OnTop',mnuOnTop.Checked);
    mnuOnTopClick(self);

    mnuStickScreen.Checked := IniFile.ReadBool('Options','Snap',mnuStickScreen.Checked);
    mnuStickScreenClick(self);

    Transparency := IniFile.ReadInteger('Options','Transparency', Transparency);
    ApplyTransparency;

    RulerUnit := TRulerUnit(IniFile.ReadInteger('Options','Unit',Integer(RulerUnit)));

    TickPosition := [];
    if IniFile.ReadBool('Options','TickerTop',tpTop in TickPosition) then TickPosition := TickPosition + [tpTop];
    if IniFile.ReadBool('Options','TickerRight',tpRight in TickPosition) then TickPosition := TickPosition + [tpRight];
    if IniFile.ReadBool('Options','TickerBottom',tpBottom in TickPosition) then TickPosition := TickPosition + [tpBottom];
    if IniFile.ReadBool('Options','TickerLeft',tpLeft in TickPosition) then TickPosition := TickPosition + [tpLeft];

    if TickPosition = [] then TickPosition := [tpTop];

  finally
    IniFile.Free;
  end;
end;

procedure TMainForm.SaveSettings;
var
  IniFile : TIniFile;
begin
  IniFile := TIniFile.Create(ChangeFileExt(Application.ExeName,'.ini'));
  try
    IniFile.WriteInteger('Placement','Top', Top);
    IniFile.WriteInteger('Placement','Left', Left);
    IniFile.WriteInteger('Placement','Width', Width);
    IniFile.WriteInteger('Placement','Height', Height);

    IniFile.WriteBool('Options','OnTop',mnuOnTop.Checked);
    IniFile.WriteBool('Options','Snap',mnuStickScreen.Checked);

    IniFile.WriteInteger('Options','Transparency',Transparency);

    IniFile.WriteInteger('Options','Unit',Integer(RulerUnit));

    IniFile.WriteBool('Options','TickerTop',tpTop in TickPosition);
    IniFile.WriteBool('Options','TickerRight',tpRight in TickPosition);
    IniFile.WriteBool('Options','TickerBottom',tpBottom in TickPosition);
    IniFile.WriteBool('Options','TickerLeft',tpLeft in TickPosition);

  finally
    IniFile.Free;
  end;
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SaveSettings;
end;



procedure TMainForm.ApplyTransparency;
begin
  if Transparency = 0 then
  begin
    AlphaBlend := false;
  end
  else
  begin
    AlphaBlend := true;
    AlphaBlendValue := 255 - Trunc((255 * Transparency) / 100);
  end;
end;

procedure TMainForm.SetTransparency(const Value: integer);
var
  i:integer;
begin
  fTransparency := Value;

  for i:= 0 to -1 + mnuTransparency.Count do
  begin
    if mnuTransparency.Items[i].Tag = Value then
    begin
      mnuTransparency.Items[i].Checked := true;
      Break;
    end;
  end;
end;

procedure TMainForm.WMDisplayChange(var message: TMessage);
begin
  //recalculate if screen display changes
  TPixelMMConverter.PixelsPerMM(Canvas,PixelPerMM.x, PixelPerMM.y);
end;

{ TPixelMMConverter }

class function TPixelMMConverter.Pixel2MM_H(const Value: integer): integer;
begin
  result := trunc(value / PixelPerMM.x)
end;

class function TPixelMMConverter.Pixel2MM_W(const Value: integer): integer;
begin
  result := trunc(value / PixelPerMM.y)
end;

class procedure TPixelMMConverter.PixelsPerMM(canvas: TCanvas; var x, y: single);
var
   h:HDC;
   hres,vres,hsiz,vsiz:integer;
begin
   h:=canvas.handle;
   hres := GetDeviceCaps(h,HORZRES);   {display width in pixels}
   vres := GetDeviceCaps(h,VERTRES);   {display height in pixels}
   hsiz := GetDeviceCaps(h,HORZSIZE);  {display width in mm}
   vsiz := GetDeviceCaps(h,VERTSIZE);  {display height in mm}
   x := hres/hsiz;
   y := vres/vsiz;
end;



end.
