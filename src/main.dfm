object Form1: TForm1
  Left = 100
  Top = 100
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  ClientHeight = 410
  ClientWidth = 410
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Arial Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 16
  object Label_VideoMode: TLabel
    Left = 22
    Top = 3
    Width = 67
    Height = 16
    Caption = 'Resolution'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Arial Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label_AAMode: TLabel
    Left = 254
    Top = 140
    Width = 79
    Height = 16
    Caption = 'Anti-aliasing'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Arial Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label_Texture: TLabel
    Left = 22
    Top = 139
    Width = 95
    Height = 16
    Caption = 'Texture quality'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Arial Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label_Shader: TLabel
    Left = 24
    Top = 232
    Width = 353
    Height = 33
    Alignment = taCenter
    AutoSize = False
    Caption = 'Your device does not support Shader 2.0'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -17
    Font.Name = 'Arial Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Layout = tlCenter
  end
  object Label_Lang: TLabel
    Left = 249
    Top = 4
    Width = 64
    Height = 16
    Caption = 'Language'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Arial Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object AdapterBox: TComboBox
    Left = 22
    Top = 24
    Width = 187
    Height = 24
    ItemHeight = 16
    TabOrder = 0
  end
  object AAbox: TComboBox
    Left = 254
    Top = 160
    Width = 99
    Height = 24
    ItemHeight = 16
    TabOrder = 7
  end
  object TextureBox: TComboBox
    Left = 22
    Top = 160
    Width = 187
    Height = 24
    ItemHeight = 16
    TabOrder = 4
  end
  object CheckBox_Windowed: TCheckBox
    Left = 22
    Top = 56
    Width = 139
    Height = 21
    Caption = 'Windowed mode'
    TabOrder = 1
  end
  object Button_Lang: TButton
    Left = 249
    Top = 24
    Width = 96
    Height = 25
    Caption = 'English'
    TabOrder = 6
    OnClick = Button_LangClick
  end
  object Button_Save: TButton
    Left = 216
    Top = 280
    Width = 169
    Height = 57
    Caption = 'Save settings'
    TabOrder = 8
    OnClick = Button_SaveClick
  end
  object Button_Play: TButton
    Left = 22
    Top = 280
    Width = 163
    Height = 113
    Caption = 'Play'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -24
    Font.Name = 'Arial Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 9
    OnClick = Button_PlayClick
  end
  object Button_Quit: TButton
    Left = 216
    Top = 360
    Width = 167
    Height = 34
    Caption = 'Quit'
    TabOrder = 10
    OnClick = Button_QuitClick
  end
  object CheckBox_Normals: TCheckBox
    Left = 22
    Top = 192
    Width = 187
    Height = 21
    Caption = 'Normal maps'
    TabOrder = 5
  end
  object CheckBox_Oldterrain: TCheckBox
    Left = 22
    Top = 98
    Width = 119
    Height = 21
    Caption = 'Old terrain'
    TabOrder = 3
  end
  object CheckBox_Vsync: TCheckBox
    Left = 22
    Top = 77
    Width = 119
    Height = 21
    Caption = 'VSync'
    TabOrder = 2
  end
end
