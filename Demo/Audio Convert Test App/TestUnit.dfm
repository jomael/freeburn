object Form1: TForm1
  Left = 286
  Top = 217
  Width = 639
  Height = 386
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 5
    Top = 5
    Width = 88
    Height = 25
    Caption = 'Add Wav Track'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 184
    Top = 6
    Width = 75
    Height = 25
    Caption = 'Save Track'
    TabOrder = 1
    OnClick = Button2Click
  end
  object TrackListBox: TListBox
    Left = 8
    Top = 111
    Width = 615
    Height = 237
    ItemHeight = 13
    TabOrder = 2
  end
  object Button3: TButton
    Left = 272
    Top = 6
    Width = 75
    Height = 25
    Caption = 'Refresh'
    TabOrder = 3
    OnClick = Button3Click
  end
  object Button4: TButton
    Left = 6
    Top = 41
    Width = 86
    Height = 25
    Caption = 'Wav 2 MP3'
    TabOrder = 4
    OnClick = Button4Click
  end
  object Button5: TButton
    Left = 6
    Top = 70
    Width = 86
    Height = 25
    Caption = 'MP3 2 Wav'
    TabOrder = 5
    OnClick = Button5Click
  end
  object OpenDialog1: TOpenDialog
    Left = 499
    Top = 9
  end
  object SaveDialog1: TSaveDialog
    Left = 435
    Top = 10
  end
end
