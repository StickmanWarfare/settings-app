unit main;

interface

uses
  Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  StdCtrls,
  Direct3d9,
  ShellApi,
  Registry;

const
  PROG_VER='1.1.0';

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
    CheckBox_Vsync: TCheckBox;
    Label_Shader: TLabel;
    Label_Lang: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button_LangClick(Sender: TObject);
    procedure Button_SaveClick(Sender: TObject);
    procedure Button_PlayClick(Sender: TObject);
    procedure Button_QuitClick(Sender: TObject);
    procedure LoadFormPositionFromRegistry;
    procedure SaveFormPositionToRegistry;
  end;

var
  Form1: TForm1;
  g_pD3D: IDirect3D9 = nil;
  modes : array of D3DDISPLAYMODE;
  samplings : array of integer;
  LanguageId: integer = -1;
  shader2:boolean;

const
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
Form1.CheckBox_Vsync.Caption := 'VSync';
if (lang = LANG_HUNGARIAN) then
  begin
    Form1.Label_VideoMode.Caption := 'Felbont�s';
    Form1.Label_AAMode.Caption := '�lsim�t�s';
    Form1.Label_Texture.Caption := 'Text�ra min�s�g';
    Form1.CheckBox_Windowed.Caption := 'Futtat�s ablakban';
    Form1.CheckBox_Normals.Caption := '3D Text�r�k';
    Form1.Button_Save.Caption := 'Be�ll�t�sok ment�se';
    Form1.Button_Play.Caption := 'J�t�k ind�t�sa';
    Form1.Button_Quit.Caption := 'Kil�p�s';
    Form1.Button_Lang.Caption := 'Magyar';
    Form1.Label_Lang.Caption := 'Nyelv';
    Form1.CheckBox_Oldterrain.Caption := 'R�gi terep';
    Form1.Label_Shader.Caption := 'Az eszk�z nem t�mogatja a Shader 2.0-t';

    i:=Form1.TextureBox.ItemIndex;
    Form1.TextureBox.Items.Clear;
    Form1.TextureBox.Items.Add('Nagyon magas');
    Form1.TextureBox.Items.Add('Magas');
    Form1.TextureBox.Items.Add('K�zepes');
    Form1.TextureBox.Items.Add('Alacsony');
    Form1.TextureBox.Items.Add('Szuper alacsony');
    Form1.TextureBox.Items.Add('Sz�nek');
    Form1.TextureBox.SetTextBuf(PAnsiChar(Form1.TextureBox.Items.Strings[i]));
    Form1.TextureBox.ItemIndex:=i;
  end
  else
  begin
    Form1.Label_VideoMode.Caption := 'Resolution';
    Form1.Label_AAMode.Caption := 'Anti-aliasing';
    Form1.Label_Texture.Caption := 'Texture quality';
    Form1.CheckBox_Windowed.Caption := 'Windowed mode';
    Form1.CheckBox_Normals.Caption := '3D Textures (Normal maps)';
    Form1.Button_Save.Caption := 'Save settings';
    Form1.Button_Play.Caption := 'Play';
    Form1.Button_Quit.Caption := 'Quit';
    Form1.Button_Lang.Caption := 'English';
    Form1.Label_Lang.Caption := 'Language';
    Form1.CheckBox_Oldterrain.Caption := 'Old terrain';
    Form1.Label_Shader.Caption := 'Your device does not support Shader 2.0';

    i:=Form1.TextureBox.ItemIndex;
    Form1.TextureBox.Items.Clear;
    Form1.TextureBox.Items.Add('Very high');
    Form1.TextureBox.Items.Add('High');
    Form1.TextureBox.Items.Add('Medium');
    Form1.TextureBox.Items.Add('Low');
    Form1.TextureBox.Items.Add('Super low');
    Form1.TextureBox.Items.Add('Only Colors');
    Form1.TextureBox.SetTextBuf(PAnsiChar(Form1.TextureBox.Items.Strings[i]));
    Form1.TextureBox.ItemIndex:=i;
  end;

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

    if Form1.CheckBox_Vsync.Checked then
      Lines.Add('vsync=1')
    else
      Lines.Add('vsync=0');

    Lines.Add('langid='+IntToStr(LanguageId));

    case Form1.TextureBox.ItemIndex of
    0: Lines.Add('texture_res='+IntToStr(TEXTURE_VERYHIGH));
    1: Lines.Add('texture_res='+IntToStr(TEXTURE_HIGH));
    2: Lines.Add('texture_res='+IntToStr(TEXTURE_MED));
    3: Lines.Add('texture_res='+IntToStr(TEXTURE_LOW));
    4: Lines.Add('texture_res='+IntToStr(TEXTURE_SUPERLOW));
    5: Lines.Add('texture_res='+IntToStr(TEXTURE_COLOR));
    end;

    if not (DirectoryExists('data')) then
      if not (CreateDir('data')) then
        raise Exception.Create('Cannot create data directory.');

    if not (DirectoryExists('data/cfg')) then
      if not (CreateDir('data/cfg')) then
        raise Exception.Create('Cannot create data/cfg directory.');

    Lines.SaveToFile('data/cfg/graphics.cfg');
  end;
 finally
  Lines.Clear;
 end;

end;

procedure load;
var
  fil:TextFile;
  line,l2:string;
  width,height:cardinal;
  multisampling,texture_res:integer;
  windowed,normals,oldterrain,vsync:boolean;
  i:integer;
begin
  width:=0;
  height:=0;
  multisampling:=0;
  texture_res:=0;
  windowed:=false;
  normals:=true;
  oldterrain:=false;
  vsync:=false;

if FileExists('data/cfg/graphics.cfg') then
begin
  assignfile(fil,'data/cfg/graphics.cfg');
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
  if (l2 = 'vsync') then vsync := strtoint(copy(line,pos('=',line)+1,length(line)))=1;
  if (l2 = 'langid') then LanguageId := strtoint(copy(line,pos('=',line)+1,length(line)));

  if (l2 = 'texture_res') then texture_res := strtoint(copy(line,pos('=',line)+1,length(line)));

  end;

  closefile(fil);

  setUiLanguage(LanguageId);

  if (width <> 0) and (width <> 0) then
  for i:=0 to length(modes) do
  begin
    if (modes[i].Width = width) and (modes[i].Height = height) then  Form1.AdapterBox.ItemIndex :=i;
  end;

  if multisampling <> 0 then
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
  Form1.CheckBox_Vsync.Checked := vsync;

end
else
begin
  LanguageId:=GetSystemDefaultLangID and $3FF;
  SetUiLanguage(LanguageId);
  Form1.CheckBox_Normals.Checked := true;
  Form1.TextureBox.ItemIndex:=0;
  for i:=0 to length(modes) do
    if (modes[i].Width = cardinal(getSystemMetrics(0))) and (modes[i].Height = cardinal(getSystemMetrics(1))) then
    begin
      Form1.AdapterBox.ItemIndex :=i;
      break;
    end;
end;

end;

procedure TForm1.FormCreate(Sender: TObject);
var
adapternum:cardinal;
mode:D3DDISPLAYMODE;
i,ii,x:integer;
found:boolean;
j:_D3DMULTISAMPLE_TYPE;
caps:D3DCAPS9;
begin
  LoadFormPositionFromRegistry;
  Caption := Application.Title+' '+PROG_VER;

  g_pD3D := Direct3DCreate9(D3D_SDK_VERSION);
  adapternum := g_pD3D.GetAdapterModeCount(D3DADAPTER_DEFAULT,D3DFMT_X8R8G8B8);

  g_pD3D.GetDeviceCaps(D3DADAPTER_DEFAULT,D3DDEVTYPE_HAL,caps);
  shader2:=caps.PixelShaderVersion>D3DPS_VERSION(2,0);

  CheckBox_Normals.Enabled := shader2;
  CheckBox_Oldterrain.Enabled := shader2;

  if shader2 then Label_Shader.Hide;

  SetLength(modes,adapternum);

  ii:= 0;
  for i:=0 to adapternum-1 do
  begin
    g_pD3D.EnumAdapterModes(D3DADAPTER_DEFAULT,D3DFMT_X8R8G8B8,i,mode);
    if mode.Width >= 800 then
    begin
     found:=false;
     for x:=0 to ii-1 do
     begin
       with modes[x] do
       if (mode.Width = Width) and (mode.Height = Height) then
       begin
         found:=true;
         break;
       end;
     end;
     if not found then
     begin
       modes[ii] := mode;
       ii := ii+1;
       AdapterBox.Items.Add(Concat(IntToStr(mode.Width),'x',IntToStr(mode.Height)));
     end;
    end;
  end;
  AdapterBox.ItemIndex := 0;

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
          AAbox.Items.Add('Off')
          else
          AAbox.Items.Add(IntToStr(integer(j))+'x');
        SetLength(samplings,ii+1);
        samplings[ii] := integer(j);
        ii:= ii +1;
      end;
    end;
  AAbox.ItemIndex := 0;

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

procedure TForm1.SaveFormPositionToRegistry;
var
  r: TRegistry;
begin
  r := TRegistry.Create;
  try
    r.RootKey := HKEY_CURRENT_USER;
    if r.OpenKey('\Software\Stickman\SettingsApp\Window', True) then
    begin
      r.WriteInteger('PosTop', Top);
      r.WriteInteger('PosLeft', Left);
      r.CloseKey;
    end;
  finally
    r.Free;
  end;
end;

procedure TForm1.LoadFormPositionFromRegistry;
var
  r: TRegistry;
begin
  r := TRegistry.Create;
  try
    r.RootKey := HKEY_CURRENT_USER;
    r.Access := KEY_READ;
    if r.OpenKey('\Software\Stickman\SettingsApp\Window', False) then
    begin
      try
        Top := r.ReadInteger('PosTop');
        Left := r.ReadInteger('PosLeft');
      except
      end;
      r.CloseKey;
    end;
  finally
    r.Free;
  end;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
SaveFormPositionToRegistry;
end;

end.

