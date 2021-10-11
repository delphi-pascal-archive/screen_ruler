object MainForm: TMainForm
  Left = 235
  Top = 130
  BorderIcons = []
  BorderStyle = bsNone
  Caption = 'ADP Screen Ruler'
  ClientHeight = 106
  ClientWidth = 631
  Color = clWindow
  Constraints.MinHeight = 50
  Constraints.MinWidth = 50
  Ctl3D = False
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  PopupMenu = Menu
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  OnPaint = FormPaint
  OnResize = FormResize
  PixelsPerInch = 120
  TextHeight = 19
  object DimensionLabel: TLabel
    Left = 10
    Top = 43
    Width = 137
    Height = 21
    Caption = 'DimensionLabel'
    Color = clWhite
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clMaroon
    Font.Height = -17
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentColor = False
    ParentFont = False
  end
  object Menu: TPopupMenu
    Left = 12
    Top = 8
    object mnuOnTop: TMenuItem
      AutoCheck = True
      Caption = 'Stay on TOP'
      OnClick = mnuOnTopClick
    end
    object mnuStickScreen: TMenuItem
      AutoCheck = True
      Caption = 'Screen snap'
      OnClick = mnuStickScreenClick
    end
    object mnuUnit: TMenuItem
      Caption = 'Unit'
      object mnuPixel: TMenuItem
        AutoCheck = True
        Caption = 'Pixel'
        RadioItem = True
        OnClick = mnuPixelClick
      end
      object mnuMilimeter: TMenuItem
        AutoCheck = True
        Caption = 'Milimeter'
        RadioItem = True
        OnClick = mnuMilimeterClick
      end
    end
    object mnuTickPosition: TMenuItem
      Caption = 'Tickers'
      object mnuTickLeft: TMenuItem
        AutoCheck = True
        Caption = 'Left'
        OnClick = mnuTickLeftClick
      end
      object mnutickTop: TMenuItem
        AutoCheck = True
        Caption = 'Top'
        OnClick = mnutickTopClick
      end
      object mnutickRight: TMenuItem
        AutoCheck = True
        Caption = 'Right'
        OnClick = mnutickRightClick
      end
      object mnutickBottom: TMenuItem
        AutoCheck = True
        Caption = 'Bottom'
        OnClick = mnutickBottomClick
      end
    end
    object mnuTransparency: TMenuItem
      Caption = 'Transparency'
      object mnut0: TMenuItem
        AutoCheck = True
        Caption = '0%'
        Hint = 'mnut0'
        RadioItem = True
        OnClick = mnut0Click
      end
      object mnut10: TMenuItem
        Tag = 10
        AutoCheck = True
        Caption = '10%'
        RadioItem = True
        OnClick = mnut0Click
      end
      object mnut20: TMenuItem
        Tag = 20
        AutoCheck = True
        Caption = '20%'
        RadioItem = True
        OnClick = mnut0Click
      end
      object mnut30: TMenuItem
        Tag = 30
        AutoCheck = True
        Caption = '30%'
        RadioItem = True
        OnClick = mnut0Click
      end
      object mnut40: TMenuItem
        Tag = 40
        AutoCheck = True
        Caption = '40%'
        RadioItem = True
        OnClick = mnut0Click
      end
      object mnut50: TMenuItem
        Tag = 50
        AutoCheck = True
        Caption = '50%'
        RadioItem = True
        OnClick = mnut0Click
      end
      object mnut60: TMenuItem
        Tag = 60
        AutoCheck = True
        Caption = '60%'
        RadioItem = True
        OnClick = mnut0Click
      end
    end
    object mnuAbout: TMenuItem
      Caption = 'About'
      OnClick = mnuAboutClick
    end
    object mnuExit: TMenuItem
      Caption = '&Exit'
      OnClick = mnuExitClick
    end
  end
  object AppEvents: TApplicationEvents
    OnIdle = AppEventsIdle
    Left = 48
    Top = 8
  end
end
