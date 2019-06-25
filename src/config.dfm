object Form1: TForm1
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'SMWF Config'
  ClientHeight = 463
  ClientWidth = 229
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDefault
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label_VideoMode: TLabel
    Left = 24
    Top = 16
    Width = 56
    Height = 13
    Caption = 'Video mode'
  end
  object Label_AAMode: TLabel
    Left = 24
    Top = 80
    Width = 56
    Height = 13
    Caption = 'Anti-aliasing'
  end
  object Label_Texture: TLabel
    Left = 24
    Top = 144
    Width = 84
    Height = 13
    Caption = 'Texture resolution'
  end
  object Label1: TLabel
    Left = 24
    Top = 272
    Width = 105
    Height = 13
    Caption = 'No shader 2.0 support'
  end
  object AdapterBox: TComboBox
    Left = 24
    Top = 40
    Width = 185
    Height = 21
    ItemHeight = 13
    TabOrder = 0
  end
  object AAbox: TComboBox
    Left = 24
    Top = 104
    Width = 185
    Height = 21
    ItemHeight = 13
    TabOrder = 1
  end
  object TextureBox: TComboBox
    Left = 24
    Top = 168
    Width = 185
    Height = 21
    ItemHeight = 13
    TabOrder = 2
  end
  object CheckBox_Windowed: TCheckBox
    Left = 24
    Top = 200
    Width = 185
    Height = 17
    Caption = 'Windowed mode'
    TabOrder = 3
  end
  object Button_Lang: TButton
    Left = 24
    Top = 304
    Width = 185
    Height = 25
    Caption = 'Nyelv/Language'
    TabOrder = 6
    OnClick = Button_LangClick
  end
  object Button_Save: TButton
    Left = 24
    Top = 336
    Width = 185
    Height = 25
    Caption = 'Save'
    TabOrder = 7
    OnClick = Button_SaveClick
  end
  object Button_Play: TButton
    Left = 24
    Top = 368
    Width = 185
    Height = 25
    Caption = 'Play'
    TabOrder = 8
    OnClick = Button_PlayClick
  end
  object Button_Quit: TButton
    Left = 24
    Top = 400
    Width = 185
    Height = 25
    Caption = 'Quit'
    TabOrder = 9
    OnClick = Button_QuitClick
  end
  object CheckBox_Normals: TCheckBox
    Left = 24
    Top = 224
    Width = 169
    Height = 17
    Caption = 'Normal maps'
    TabOrder = 4
  end
  object CheckBox_Oldterrain: TCheckBox
    Left = 24
    Top = 248
    Width = 161
    Height = 17
    Caption = 'Old terrain'
    TabOrder = 5
  end
end
