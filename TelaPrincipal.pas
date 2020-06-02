unit TelaPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Imaging.pngimage, Vcl.ExtCtrls,
  Vcl.StdCtrls;

type
  TForm1 = class(TForm)

    Panel1: TPanel;
    painelEnergia: TPanel;
    labelEnergia: TLabel;

    life1: TImage;
    life2: TImage;
    life3: TImage;
    life4: TImage;
    life5: TImage;
    nave: TImage;
    fire: TImage;
    fireStatus: TImage;

    TMover: TTimer;
    TCriador: TTimer;
    TimerLiberacaoTiro: TTimer;
    TimerAnimacaoTiro: TTimer;

    pontos: TLabel;
    lblAux: TLabel;
    lblAux2: TLabel;
    pnlEnergiaRed: TPanel;
    TGeraFase: TTimer;

    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure TimerAnimacaoTiroTimer(Sender: TObject);
    procedure TimerLiberacaoTiroTimer(Sender: TObject);
    procedure TMoverTimer(Sender: TObject);
    procedure TCriadorTimer(Sender: TObject);

    procedure comMunicao();
    procedure semMunicao();
    procedure atualizaVida();

    function  VerificaColisao(O1, O2 : TControl):boolean;
    procedure TGeraFaseTimer(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  faseAtual: integer;
  Form1: TForm1;
  bateu : boolean;
  life: integer;
  pontuacao: integer;
  navesDestruidas: integer;
  NumeroNaves : integer;
  geradorNaves: integer;
  energia : integer;
  energiaRed: integer;

implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
begin
   fire.Left:= -50;
   NumeroNaves:=3;
   life :=5;
   energia:= 400;
   energiaRed:=0;
   navesDestruidas:=0;
   pontuacao:=0;
   DoubleBuffered := true;
   bateu          := false;
end;

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);

  var incremento : integer;

begin

  if not bateu then
  begin

    incremento := 10;

    case key of

      VK_LEFT  : nave.Left := nave.Left - incremento;
      VK_RIGHT : nave.Left := nave.Left + incremento;


    end;

    energiaRed:=energiaRed+3;

    if (nave.Left < -20) then
        nave.Left := -20;

    if (nave.Left > 710) then
        nave.Left := 710;

    end;
end;


procedure TForm1.TCriadorTimer(Sender: TObject);
  var t : TImage; aux : integer;
  begin
   inc(geradorNaves);
   if not(bateu) and (geradorNaves <= NumeroNaves) then
   begin
      t         := TImage.Create(Form1);
      t.Parent  := form1;
      t.Picture.LoadFromFile('img/enemyBlack.png');
      t.Top     := -20;
      t.Stretch := true;
      t.Height  := 55;
      t.Width   := 65;
      t.Left    := Random(Form1.Width - 50);
      t.Tag     := 1;
   end;
end;

procedure TForm1.TGeraFaseTimer(Sender: TObject);
begin
   if (navesDestruidas - NumeroNaves = 0) then
   begin
      geradorNaves:= 0;
      navesDestruidas:=0;
      faseAtual := faseAtual+1;
      lblAux.Caption:=string.Parse(faseAtual);
   end;

end;

//Animação do tiro
procedure TForm1.TimerAnimacaoTiroTimer(Sender: TObject);
begin
   fire.Top := fire.top-5;
   if((fire.Top < -100)) then comMunicao();
end;

// liberação do tiro
procedure TForm1.TimerLiberacaoTiroTimer(Sender: TObject);
begin
  if((GetKeyState(VK_SPACE) < 0)and (not fire.Enabled)) then
  begin
      ////POSICAO INICIAL SAIDA DO TIRO////////////////////
      fire.Left := nave.Left+26;
      fire.Top := nave.top-20;
      semMunicao();
      energiaRed:=energiaRed+20;
  end;


end;

procedure TForm1.TMoverTimer(Sender: TObject);
var i : integer;
begin
    //PAINEL DE ENERGIA/////////// TIMER /////////////
    if energiaRed >= 20 then
      begin
        if pnlEnergiaRed.Visible and (pnlEnergiaRed.Left>painelEnergia.Left) then
        begin
          pnlEnergiaRed.Left:=pnlEnergiaRed.Left - 3;
          pnlEnergiaRed.Width:=pnlEnergiaRed.Width + 3;
          energiaRed:=0;
        end
        else
        begin
          pnlEnergiaRed.Visible:=True;
          energiaRed:=0;
        end;
        if pnlEnergiaRed.Left<=painelEnergia.Left then
        begin
          bateu:=true;
        end;

      end;
    /////////////////////////////////////////

   if not bateu then
   begin
       for i := 0 to form1.ComponentCount-1 do
       begin
         if form1.Components[i] is Timage then
         begin
            if Timage(form1.Components[i]).tag = 1 then
            begin
               Timage(form1.Components[i]).Top := Timage(form1.Components[i]).Top + 1;
               if Timage(form1.Components[i]).Top > form1.Height then
               begin
                  Timage(form1.Components[i]).Top    := -20;
                  Timage(form1.Components[i]).Left   := Random(form1.Width - 50);
               end;

               VerificaColisao(nave, TImage(form1.Components[i]));
               VerificaColisao(fire, TImage(form1.Components[i]));
            end;
         end;
       end;
   end;
end;

function TForm1.VerificaColisao(O1, O2 : TControl): boolean;
var topo, baixo, esquerda, direita : boolean;
    //VAR PONTUACAO///////////////////
    aux : integer;
    concatenar : string;
    /////////////////////////////////
begin
    topo     := false;
    baixo    := false;
    esquerda := false;
    direita  := false;

//    label2.Caption := '';

    if (O1.Top >= O2.top ) and (O1.top  <= O2.top  + O2.Height) then
    begin
       topo := true;
//       label2.Caption := label2.Caption+ 'Topo, ';
    end;

    if (O1.left >= O2.left) and (O1.left <= O2.left + O2.Width ) then
    begin
      esquerda := true;
//      label2.Caption := label2.Caption+ ' Esquerda, ';
    end;

    if (O1.top + O1.Height >= O2.top ) and (O1.top + O1.Height  <= O2.top + O2.Height) then
    begin
      baixo := true;
//      label2.Caption := label2.Caption+ ' Baixo, ';
    end;

    if (O1.left + O1.Width >= O2.left ) and (O1.left + O1.Width  <= O2.left + O2.Width) then
    begin
      direita := true;
//      label2.Caption := label2.Caption+ ' Direita ';
    end;

    if (topo or baixo) and (esquerda or direita) then
    begin
      if o2.Visible then
      begin
       //Colisão tiro aliado e nave inimiga
        if o1.Tag = 5 then
        begin
          fire.Left:= -50;
          comMunicao();
          ////PONTUACAO////////// PROCEDURE //////////////////
          pontuacao:=pontuacao+250;
          concatenar:= '';
          aux:= length(pontos.Caption) - length(string.Parse(pontuacao));

          while aux > 0 do
          begin
            concatenar:=concatenar + '0';
            aux:=aux-1;

            if aux=0 then
              pontos.Caption:= concatenar + string.Parse(pontuacao);

          end;
          //////////////////////////////////////////////////////////

        end;

       //Colisão nave aliada e nave inimiga
       if o1.Tag = 0 then atualizaVida();
       navesDestruidas:=navesDestruidas+1;
       lblAux2.Caption:=string.Parse(navesDestruidas);
      end;
      o2.Visible := false;
      o2.Enabled := false;
    end;

    VerificaColisao := (topo or baixo) and (esquerda or direita);
end;

procedure TForm1.atualizaVida();
begin
   life := life - 1;
   if life = 4 then
   begin
     life5.Visible := false;
   end;
   if life = 3 then
   begin
     life4.Visible := false;
   end;
   if life = 2 then
   begin
     life3.Visible := false;
   end;
   if life = 1 then
   begin
     life2.Visible := false;
   end;
   if life = 0 then
   begin
     life1.Visible := false;
     bateu := true;
   end;
end;

procedure TForm1.comMunicao();
begin
  fire.Visible:=false;
  fire.Enabled:=false;
  fireStatus.Visible:=true;
  TimerAnimacaoTiro.Enabled:=false;
end;

procedure TForm1.semMunicao();
begin
  fire.Visible:=true;
  fire.Enabled:=true;
  fireStatus.Visible:=false;
  TimerAnimacaoTiro.Enabled:=true;
end;

end.
