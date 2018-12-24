object Form1: TForm1
  Left = 251
  Top = 120
  Width = 682
  Height = 667
  Caption = 'ISO9660 Test Application'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object StatusBar1: TStatusBar
    Left = 0
    Top = 600
    Width = 674
    Height = 19
    Panels = <>
    SimplePanel = False
  end
  object Panel1: TPanel
    Left = 0
    Top = 434
    Width = 674
    Height = 166
    Align = alBottom
    BevelInner = bvRaised
    BevelOuter = bvLowered
    TabOrder = 1
    object mem_DebugOut: TMemo
      Left = 2
      Top = 2
      Width = 670
      Height = 162
      Align = alClient
      BorderStyle = bsNone
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Pitch = fpFixed
      Font.Style = []
      ParentFont = False
      ReadOnly = True
      ScrollBars = ssVertical
      TabOrder = 0
    end
  end
  object tv_Directory: TTreeView
    Left = 0
    Top = 27
    Width = 674
    Height = 407
    Align = alClient
    Images = ImageList1
    Indent = 19
    PopupMenu = PopupMenu1
    RightClickSelect = True
    TabOrder = 2
    OnChange = tv_DirectoryChange
    OnDblClick = tv_DirectoryDblClick
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 674
    Height = 27
    Align = alTop
    TabOrder = 3
    object Label1: TLabel
      Left = 14
      Top = 6
      Width = 49
      Height = 13
      Caption = 'Volume ID'
    end
    object VolIDEdit: TEdit
      Left = 68
      Top = 2
      Width = 209
      Height = 21
      TabOrder = 0
      Text = 'Test ISO'
    end
  end
  object MainMenu1: TMainMenu
    Left = 303
    Top = 51
    object mm_File: TMenuItem
      Caption = 'File'
      object NewISOImage1: TMenuItem
        Caption = 'New ISO Image'
        OnClick = Image1Click
      end
      object sm_File_Open: TMenuItem
        Caption = 'Open Image'
        OnClick = sm_File_OpenClick
      end
      object sm_File_SaveAs: TMenuItem
        Caption = 'Save Image As'
        OnClick = sm_File_SaveAsClick
      end
      object sm_File_Close: TMenuItem
        Caption = 'Close Image'
        Enabled = False
        OnClick = sm_File_CloseClick
      end
      object sm_File_Break1: TMenuItem
        Caption = '-'
      end
      object sm_File_Quit: TMenuItem
        Caption = 'Quit'
        OnClick = sm_File_QuitClick
      end
    end
    object New1: TMenuItem
      Caption = 'Functions'
      object CheckDirs1: TMenuItem
        Caption = 'Add Files / Dirs'
        OnClick = CheckDirs1Click
      end
    end
    object CreateTestImage1: TMenuItem
      Caption = 'Create Test Image'
      object CreateTestImageAndSavetodisk1: TMenuItem
        Caption = 'Create Test Image And Save to disk'
        OnClick = CreateTestImageAndSavetodisk1Click
      end
    end
  end
  object dlg_OpenImage: TOpenDialog
    DefaultExt = '.iso'
    Filter = 'ISO9660 Images (*.iso)|*.iso|All Files (*.*)|*.*'
    Title = 'Select image to open....'
    Left = 468
    Top = 91
  end
  object SaveDialog1: TSaveDialog
    DefaultExt = '.iso'
    Left = 465
    Top = 40
  end
  object ImageList1: TImageList
    Left = 309
    Top = 167
    Bitmap = {
      494C010103000400040010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000001000000001002000000000000010
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000080808000C0C0
      C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
      C000C0C0C0000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FFFFFF00FFFFFF000000000000BFBF0000FF0000FFFF00000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000808080000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000C0C0C0000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF00FFFFFF00FFFFFF000000000000BFBF0000FF0000FFFF0000BFBF
      0000000000000000000000000000000000000000000000000000808080008080
      8000808080008080800080808000808080008080800080808000808080008080
      8000808080008080800000000000000000000000000000000000808080000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000C0C0C0000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008080
      800000000000FFFFFF00FFFFFF000000000000BFBF0000FF0000BFBF00000000
      000000000000000000000000000000000000000000000000000080808000FFFF
      FF0000FFFF00C0C0C00000FFFF00C0C0C00000FFFF00C0C0C00000FFFF00C0C0
      C00000FFFF008080800000000000000000000000000000000000808080000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000C0C0C0000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00008080800000000000FFFFFF000000000000BFBF0080808000000000000000
      0000FFFF0000FFFF000000000000000000000000000080808000FFFFFF0000FF
      FF00C0C0C00000FFFF00C0C0C00000FFFF00C0C0C00000FFFF00C0C0C00000FF
      FF00C0C0C0000000000080808000000000000000000000000000808080000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000C0C0C0000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000080808000000000000000000000000000BFBF000000FFFF0000FF
      000000FF000000BFBF0000000000000000000000000080808000FFFFFF00C0C0
      C00000FFFF00C0C0C00000FFFF00C0C0C00000FFFF00C0C0C00000FFFF00C0C0
      C000808080000000000080808000000000000000000000000000808080000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000C0C0C0000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000808080008080
      8000808080008080800000000000000000000000000000000000FF00FF00FF00
      FF00FF00FF00FF00FF00000000000000000080808000FFFFFF00C0C0C00000FF
      FF00C0C0C00000FFFF00C0C0C00000FFFF00C0C0C00000FFFF00C0C0C00000FF
      FF00000000008080800080808000000000000000000000000000808080000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000C0C0C0000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FF00FF00FF00
      FF00FF00FF00FF00FF0000000000000000000000000000000000808080008080
      80008080800080808000000000000000000080808000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008080
      800000000000C0C0C00080808000000000000000000000000000808080000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000C0C0C0000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000BFBF0000FF
      000000FF000000FFFF0080808000000000000000000000000000808080000000
      0000000000000000000000000000000000008080800080808000808080008080
      8000808080008080800080808000808080008080800080808000808080008080
      80008080800000FFFF0080808000000000000000000000000000808080000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000C0C0C0000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFF0000FFFF
      000000000000BFBF00008080800000BFBF0000000000FFFFFF00000000008080
      8000000000000000000000000000000000000000000080808000FFFFFF00C0C0
      C00000FFFF00C0C0C00000FFFF00C0C0C00000FFFF00C0C0C00000FFFF00C0C0
      C00000FFFF00C0C0C00080808000000000000000000000000000808080000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000C0C0C0000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000BFBF000000FF000000BFBF0000000000FFFFFF00FFFFFF000000
      0000808080000000000000000000000000000000000080808000FFFFFF0000FF
      FF00C0C0C00000FFFF00C0C0C00000FFFF00C0C0C000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0080808000000000000000000000000000808080000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000BFBF0000FFFF000000FF000000BFBF0000000000FFFFFF00FFFFFF00FFFF
      FF00000000000000000000000000000000000000000080808000FFFFFF00C0C0
      C00000FFFF00C0C0C00000FFFF00C0C0C000FFFFFF0080808000808080008080
      8000808080008080800080808000000000000000000000000000808080000000
      000000000000000000000000000000000000000000008080800000000000C0C0
      C000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FFFF000000FF000000BFBF0000000000FFFFFF00FFFFFF000000
      000000000000000000000000000000000000000000000000000080808000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008080800000000000000000000000
      0000000000000000000000000000000000000000000000000000808080000000
      0000000000000000000000000000000000000000000080808000C0C0C0000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008080
      8000808080008080800080808000808080000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000808080000000
      0000000000000000000000000000000000000000000080808000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000808080008080
      8000808080008080800080808000808080008080800000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000100000000100010000000000800000000000000000000000
      000000000000000000000000FFFFFF00FFFFFFFFC0030000F81FFFFFC0030000
      E107E000DFF30000D10BC000DFF30000C91BC000DFF30000B5318000DFF30000
      BA018000DFF3000081810000DFF3000081810000DFF30000805D0000DFF30000
      88AD8000DFF30000D8938000DF830000D08B8001DFA70000E087C07FDF8F0000
      F81FE0FFDF9F0000FFFFFFFFC03F000000000000000000000000000000000000
      000000000000}
  end
  object PopupMenu1: TPopupMenu
    Left = 306
    Top = 107
    object CreateDirctory1: TMenuItem
      Caption = 'Create Directory'
      OnClick = CreateDirctory1Click
    end
    object AddFile1: TMenuItem
      Caption = 'Add File'
      OnClick = AddFile1Click
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object DeleteDirectory1: TMenuItem
      Caption = 'Delete Directory'
      OnClick = DeleteDirectory1Click
    end
  end
  object OpenDialog2: TOpenDialog
    DefaultExt = '*.*'
    Filter = 'Any File (*.*)|*.*'
    Left = 470
    Top = 145
  end
end
