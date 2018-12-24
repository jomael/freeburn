object BurnForm: TBurnForm
  Left = 421
  Top = 134
  Width = 384
  Height = 451
  Caption = 'CD Burner Info'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Gauge1: TGauge
    Left = 15
    Top = 182
    Width = 348
    Height = 17
    Progress = 0
  end
  object Label1: TLabel
    Left = 15
    Top = 165
    Width = 46
    Height = 13
    Caption = 'CD Buffer'
  end
  object Gauge2: TGauge
    Left = 15
    Top = 274
    Width = 349
    Height = 21
    ForeColor = clNavy
    Progress = 0
  end
  object Label2: TLabel
    Left = 13
    Top = 257
    Width = 66
    Height = 13
    Caption = 'Percent Done'
  end
  object Label3: TLabel
    Left = 14
    Top = 305
    Width = 133
    Height = 13
    Caption = 'Burner Buffer Size : 2048 kb'
  end
  object Label4: TLabel
    Left = 14
    Top = 328
    Width = 134
    Height = 13
    Caption = 'Burner Free Buffer : 2048 kb'
  end
  object Label5: TLabel
    Left = 12
    Top = 8
    Width = 37
    Height = 13
    Caption = 'Log File'
  end
  object Label6: TLabel
    Left = 16
    Top = 205
    Width = 65
    Height = 13
    Caption = 'CD File Buffer'
  end
  object Gauge3: TGauge
    Left = 15
    Top = 222
    Width = 349
    Height = 17
    ForeColor = clNavy
    Progress = 0
  end
  object ListBox1: TListBox
    Left = 11
    Top = 25
    Width = 357
    Height = 123
    ItemHeight = 13
    TabOrder = 0
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 403
    Width = 376
    Height = 19
    Panels = <>
    SimplePanel = True
  end
end
