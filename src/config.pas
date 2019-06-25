
unit config;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Direct3d9, ShellApi;

type
  TForm1 = class(TForm)
    Label_VideoMode: TLabel;
    Label_AAMode: TLabel;
    AAbox: TComboBox;
    Button_Lang: TButton;
    Button_Save: TButton;
    Button_Play: TButton;
    Button_Quit: TButton;
    AdapterBox: TComboBox;
    CheckBox_Windowed: TCheckBox;
    CheckBox_Normals: TCheckBox;
    TextureBox: TComboBox;
    Label_Texture: TLabel;
    CheckBox_Oldterrain: TCheckBox;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure Button_LangClick(Sender: TObject);
    procedure Button_SaveClick(Sender: TObject);
    procedure Button_PlayClick(Sender: TObject);
    procedure Button_QuitClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  g_pD3D: IDirect3D9 = nil;
  modes : array of D3DDISPLAYMODE;
  samplings : array of integer;
  LanguageId: integer = -1;
  shader2:boolean;

const
  TEXTURE_LOW_LEG=0;
  TEXTURE_MED_LEG=1;
  TEXTURE_HIGH_LEG=2;

  TEXTURE_COLOR=99;
  TEXTURE_SUPERLOW=100;
  TEXTURE_LOW=101;
  TEXTURE_MED=102;
  TEXTURE_HIGH=103;
  TEXTURE_VERYHIGH=104;
  

implementation

{$R *.dfm}

procedure setUiLanguage(lang:Single);
var
i:integer;
begin
if (lang = LANG_HUNGARIAN) then
  begin
    Form1.Label_VideoMode.Caption := 'Videó mód';
    Form1.Label_AAMode.Caption := 'Élsimítás';
    Form1.Label_Texture.Caption := 'Textúra felbontás';
    Form1.CheckBox_Windowed.Caption := 'Futtatás ablakban';
    Form1.Button_Save.Caption := 'Mentés';
    Form1.Button_Play.Caption := 'Indítás';
    Form1.Button_Quit.Caption := 'Kilépés';
    Form1.CheckBox_Oldterrain.Caption := 'Régi terep';
    Form1.Label1.Caption := 'Nincs shader 2.0 támogatás';

    i:=Form1.TextureBox.ItemIndex;
    Form1.TextureBox.Items.Clear;
    Form1.TextureBox.Items.Add('Nagyon magas');
    Form1.TextureBox.Items.Add('Magas');
    Form1.TextureBox.Items.Add('Közepes');
    Form1.TextureBox.Items.Add('Alacsony');
    Form1.TextureBox.Items.Add('Szuper alacsony');
    Form1.TextureBox.Items.Add('Színek');
    Form1.TextureBox.SetTextBuf(PAnsiChar(Form1.TextureBox.Items.Strings[i]));
    Form1.TextureBox.ItemIndex:=i;
  end
  else
  begin
    Form1.Label_VideoMode.Caption := 'Video mode';
    Form1.Label_AAMode.Caption := 'Anit-aliasing';
    Form1.Label_Texture.Caption := 'Texture resolution';
    Form1.CheckBox_Windowed.Caption := 'Windowed mode';
    Form1.Button_Save.Caption := 'Save';
    Form1.Button_Play.Caption := 'Play';
    Form1.Button_Quit.Caption := 'Quit';
    Form1.CheckBox_Oldterrain.Caption := 'Old terrain';
    Form1.Label1.Caption := 'No shader 2.0 support';

    i:=Form1.TextureBox.ItemIndex;
    Form1.TextureBox.Items.Clear;
    Form1.TextureBox.Items.Add('Very high');
    Form1.TextureBox.Items.Add('High');
    Form1.TextureBox.Items.Add('Medium');
    Form1.TextureBox.Items.Add('Low');
    Form1.TextureBox.Items.Add('Super low');
    Form1.TextureBox.Items.Add('Colors');
    Form1.TextureBox.SetTextBuf(PAnsiChar(Form1.TextureBox.Items.Strings[i]));
    Form1.TextureBox.ItemIndex:=i;
  end
end;

procedure save;
var
Lines: TStrings;
begin
   Lines := TStringList.Create;
  try
  begin
    Lines.Add('width='+IntToStr(modes[Form1.AdapterBox.ItemIndex].width));
    Lines.Add('height='+IntToStr(modes[Form1.AdapterBox.ItemIndex].height));
    Lines.Add('multisampling='+IntToStr(samplings[Form1.AAbox.ItemIndex]));

    if Form1.CheckBox_Windowed.Checked then
      Lines.Add('windowed=1')
    else
      Lines.Add('windowed=0');

    if Form1.CheckBox_Normals.Checked then
      Lines.Add('normals=1')
    else
      Lines.Add('normals=0');

    if Form1.CheckBox_Oldterrain.Checked then
      Lines.Add('oldterrain=1')
    else
      Lines.Add('oldterrain=0');

    Lines.Add('langid='+IntToStr(LanguageId));

    case Form1.TextureBox.ItemIndex of
    0: Lines.Add('texture_res='+IntToStr(TEXTURE_VERYHIGH));
    1: Lines.Add('texture_res='+IntToStr(TEXTURE_HIGH));
    2: Lines.Add('texture_res='+IntToStr(TEXTURE_MED));
    3: Lines.Add('texture_res='+IntToStr(TEXTURE_LOW));
    4: Lines.Add('texture_res='+IntToStr(TEXTURE_SUPERLOW));
    5: Lines.Add('texture_res='+IntToStr(TEXTURE_COLOR));
    end;

    Lines.SaveToFile('data/video.ini');
  end;
 finally
  Lines.Clear;
 end;

end;

procedure load;
var
fil:TextFile;
line,l2:string;
width,height,multisampling,texture_res:integer;
windowed,normals,oldterrain:boolean;
i:integer;
begin

if FileExists('data/video.ini') then
begin
  assignfile(fil,'data/video.ini');
  reset(fil);

  while not eof(fil) do
  begin
  ReadLn(fil,line);
  l2 := copy(line,1,pos('=',line)-1);

  if (l2 = 'width') then width := strtoint(copy(line,pos('=',line)+1,length(line)));
  if (l2 = 'height') then height := strtoint(copy(line,pos('=',line)+1,length(line)));

  if (l2 = 'multisampling') then multisampling := strtoint(copy(line,pos('=',line)+1,length(line)));
  if (l2 = 'windowed') then windowed := strtoint(copy(line,pos('=',line)+1,length(line)))=1;
  if (l2 = 'normals') then normals := strtoint(copy(line,pos('=',line)+1,length(line)))=1;
  if (l2 = 'oldterrain') then oldterrain := strtoint(copy(line,pos('=',line)+1,length(line)))=1;
  if (l2 = 'langid') then LanguageId := strtoint(copy(line,pos('=',line)+1,length(line)));

  if (l2 = 'texture_res') then texture_res := strtoint(copy(line,pos('=',line)+1,length(line)));

  if texture_res = TEXTURE_LOW_LEG then texture_res:= TEXTURE_LOW;
  if texture_res = TEXTURE_MED_LEG then texture_res:= TEXTURE_MED;
  if texture_res = TEXTURE_HIGH_LEG then texture_res:= TEXTURE_HIGH;

  end;

  closefile(fil);

  setUiLanguage(LanguageId);

  for i:=0 to length(modes) do
  begin
    if (modes[i].Width = width) and (modes[i].Height = height) then  Form1.AdapterBox.ItemIndex :=i;
  end;

  for i:=0 to length(samplings) do
  begin
    if (samplings[i] = multisampling) then  Form1.AAbox.ItemIndex :=i;
  end;

  case texture_res of
  TEXTURE_VERYHIGH : Form1.TextureBox.ItemIndex:=0;
  TEXTURE_HIGH     : Form1.TextureBox.ItemIndex:=1;
  TEXTURE_MED      : Form1.TextureBox.ItemIndex:=2;
  TEXTURE_LOW      : Form1.TextureBox.ItemIndex:=3;
  TEXTURE_SUPERLOW : Form1.TextureBox.ItemIndex:=4;
  TEXTURE_COLOR    : Form1.TextureBox.ItemIndex:=5;
  end;

  Form1.CheckBox_Windowed.Checked := windowed;
  Form1.CheckBox_Normals.Checked := normals and shader2;
  Form1.CheckBox_Oldterrain.Checked := oldterrain or not shader2;

end
else
begin
  LanguageId:=GetSystemDefaultLangID and $3FF;
  SetUiLanguage(LanguageId);
  Form1.CheckBox_Normals.Checked := true;
end;

end;

procedure TForm1.FormCreate(Sender: TObject);
var
adapternum:cardinal;
mode:D3DDISPLAYMODE;
i,ii:integer;
j:_D3DMULTISAMPLE_TYPE;
caps:D3DCAPS9;
begin

  g_pD3D := Direct3DCreate9(D3D_SDK_VERSION);
  adapternum := g_pD3D.GetAdapterModeCount(D3DADAPTER_DEFAULT,D3DFMT_X8R8G8B8);

  g_pD3D.GetDeviceCaps(D3DADAPTER_DEFAULT,D3DDEVTYPE_HAL,caps);
  shader2:=caps.PixelShaderVersion>D3DPS_VERSION(2,0);

  CheckBox_Normals.Enabled := shader2;
  CheckBox_Oldterrain.Enabled := shader2;

  if shader2 then Label1.Hide;


  SetLength(modes,adapternum);

  ii:= 0;
  for i:=0 to adapternum-1 do
  begin
    g_pD3D.EnumAdapterModes(D3DADAPTER_DEFAULT,D3DFMT_X8R8G8B8,i,mode);
    if ( mode.Width >= 800) then
    begin
     modes[ii] := mode;
     ii := ii+1;
     AdapterBox.Items.Add(Concat(IntToStr(mode.Width),'x',IntToStr(mode.Height),' ',IntToStr(mode.RefreshRate),'Hz'));
    end;
  end;

  ii:= 0;
  for j:=D3DMULTISAMPLE_NONE to High(_D3DMULTISAMPLE_TYPE) do
    begin
    if g_pD3D.CheckDeviceMultiSampleType( D3DADAPTER_DEFAULT,
                                        D3DDEVTYPE_HAL,
                                        D3DFMT_X8R8G8B8,
                                        true,
                                        j,
                                        nil) = D3D_OK then
      begin
        if (integer(j) = 0) then
          AAbox.Items.Add('-')
          else
          AAbox.Items.Add(IntToStr(integer(j))+'x');
        SetLength(samplings,ii+1);
        samplings[ii] := integer(j);
        ii:= ii +1;
      end;
    end;

  AdapterBox.ItemIndex := 0;
  AAbox.ItemIndex := 0;
  TextureBox.ItemIndex := 0;

  load;

end;



procedure TForm1.Button_LangClick(Sender: TObject);
begin

if (LanguageId = 14) then
begin
  LanguageId := 9;
  SetUiLanguage(LanguageId);
end
else
begin
  LanguageId := 14;
  SetUiLanguage(LanguageId);
end;

end;

procedure TForm1.Button_SaveClick(Sender: TObject);
begin

Save;
g_pD3D := nil;

end;

procedure TForm1.Button_PlayClick(Sender: TObject);
begin
Save;
g_pD3D := nil;
ShellExecute(handle,'open',PChar('stickman.exe'), '','',SW_SHOWDEFAULT);

end;

procedure TForm1.Button_QuitClick(Sender: TObject);
begin
Close;
end;

end.

