object Form1: TForm1
  Left = 331
  Top = 191
  Width = 516
  Height = 197
  Caption = 'Test BIN to ISO'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object binedit: TEdit
    Left = 25
    Top = 21
    Width = 396
    Height = 21
    TabOrder = 0
    Text = 'C:\'
  end
  object isoedit: TEdit
    Left = 25
    Top = 49
    Width = 396
    Height = 21
    TabOrder = 1
    Text = 'C:\'
  end
  object Button1: TButton
    Left = 425
    Top = 21
    Width = 75
    Height = 21
    Caption = 'Bin File'
    TabOrder = 2
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 24
    Top = 87
    Width = 75
    Height = 25
    Caption = 'Convert'
    TabOrder = 3
    OnClick = Button2Click
  end
  object ProgressBar1: TProgressBar
    Left = 106
    Top = 88
    Width = 315
    Height = 23
    Min = 0
    Max = 100
    TabOrder = 4
  end
  object BitBtn1: TBitBtn
    Left = 24
    Top = 114
    Width = 75
    Height = 25
    Caption = 'Cancel'
    TabOrder = 5
    OnClick = BitBtn1Click
  end
  object OpenDialog1: TOpenDialog
    DefaultExt = '.bin'
    Filter = 'BIN Files (*.bin)|*.bin|All Files (*.*)|*.*'
    Left = 320
    Top = 7
  end
end
