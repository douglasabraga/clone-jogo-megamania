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
    Label1: TLabel;
    Label2: TLabel;
    TAtualizaEnergia: TTimer;

    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure TimerAnimacaoTiroTimer(Sender: TObject);
    procedure TimerLiberacaoTiroTimer(Sender: TObject);
    procedure TMoverTimer(Sender: TObject);
    procedure TCriadorTimer(Sender: TObject);
    procedure TGeraFaseTimer(Sender: TObject);
    procedure TAtualizaEnergiaTimer(Sender: TObject);

    procedure comMunicao();
    procedure semMunicao();
    procedure atualizaVida();

    function  VerificaColisao(O1, O2 : TControl):boolean;
    function  setTag(tag : integer):integer;
    function  setCorEnemy(tag : integer):string;


  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  faseAtual: integer;
  Form1: TForm1;
  endGame : boolean;
  life: integer;
  pontuacao: integer;
  navesDestruidasPorWave: integer;
  NumeroNaves : integer;
  geradorNaves: integer;
  energia : integer;
  energiaRed: integer;

implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
begin
   Randomize;
   faseAtual:=1;
   fire.Left:= -50;
   NumeroNaves:=3;
   life :=5;
   energia:= 400;
   energiaRed:=0;
   navesDestruidasPorWave:=0;
   pontuacao:=0;
   DoubleBuffered := true;
   endGame          := false;
end;

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);

  var incremento : integer;

begin

  if not endGame then
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
   if not(endGame) and (geradorNaves <= NumeroNaves) then
   begin
      t         := TImage.Create(Form1);
      t.Parent  := form1;
//      t.Picture.LoadFromFile(corNave(10 + Random(7)));
      t.Tag     := setTag(10 + Random(7));
//      t.Tag     := setTag(17);
      t.Picture.LoadFromFile(setCorEnemy(t.Tag));
      t.Top     := -20;
      t.Stretch := true;
      t.Height  := 55;
      t.Width   := 65;
      t.Left    := Random(Form1.Width - 50);

   end;
end;

function TForm1.setTag(tag : integer):integer;
begin
   //Nave Inimiga de cor laranja
   if (Tag >= 16) and (faseAtual >= 15) and
      (1 + Random(100) <= faseAtual+(1 + Random(faseAtual+10))) then
       begin
         Result:=16;
       end
   //Nave Inimiga de cor verde
   else if (Tag >= 12) and (faseAtual >= 10) and
      (1 + Random(100) <= faseAtual+(1 + Random(faseAtual+10))) then
       begin
         Result:=12;
       end
   //Nave Inimiga de cor cinza
   else
     Result:=10;
end;

function TForm1.setCorEnemy(tag : integer):string;
begin
   if Tag = 10 then
   begin
     Result:='img/enemyBlack.png';
   end
   else if Tag <= 12 then
   begin
     Result:='img/enemyGreen.png';
   end
   else
   begin
     Result:='img/enemyRed.png';
   end;
end;

procedure TForm1.TAtualizaEnergiaTimer(Sender: TObject);
begin
  //zerar energia perdida
   if pnlEnergiaRed.Left>=580 then
     pnlEnergiaRed.Left:=581;

   if energiaRed >= 15 then
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
        endGame:=true;
      end;

    end;
end;

procedure TForm1.TGeraFaseTimer(Sender: TObject);
begin
   if (NumeroNaves - navesDestruidasPorWave = 0) then
   begin
      geradorNaves:= 0;
      navesDestruidasPorWave:=0;
      faseAtual := faseAtual+1;
      NumeroNaves:= faseAtual*(1 + Random(3));
      lblAux.Caption:=string.Parse(faseAtual);
      pnlEnergiaRed.Enabled:=false;
      pnlEnergiaRed.Width:=3;
      pnlEnergiaRed.Left:=579;
   end;
end;


procedure TForm1.TimerAnimacaoTiroTimer(Sender: TObject);
begin
   fire.Top := fire.top-5;
   if((fire.Top < -100)) then comMunicao();
end;


procedure TForm1.TimerLiberacaoTiroTimer(Sender: TObject);
begin
  if((GetKeyState(VK_SPACE) < 0) and (not fire.Enabled) and not(endGame) ) then
  begin
      fire.Left := nave.Left+26;
      fire.Top := nave.top-20;
      semMunicao();
      energiaRed:=energiaRed+20;
  end;
end;

procedure TForm1.TMoverTimer(Sender: TObject);
var i : integer;
begin
   if not endGame then
   begin
       for i := 0 to form1.ComponentCount-1 do
       begin
         if form1.Components[i] is Timage then
         begin
            if Timage(form1.Components[i]).tag > 9 then
            begin
               if (Timage(form1.Components[i]).Tag = 10)  and (faseAtual > 9) then
                  begin
                    Timage(form1.Components[i]).Top := Timage(form1.Components[i]).Top + 2;
                  end
                  else
                    Timage(form1.Components[i]).Top := Timage(form1.Components[i]).Top + 1;
               if Timage(form1.Components[i]).Top > form1.Height then
               begin
               //Decremento de 10 de energia na nave aliada
                  pnlEnergiaRed.Left:=pnlEnergiaRed.Left-5;
                  pnlEnergiaRed.Width:=pnlEnergiaRed.Width+5;

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
       //Colis�o tiro aliado e nave inimiga
        if o1.Tag = 5 then
        begin
          comMunicao();
          o2.Tag:=o2.Tag-1;
          Timage(o2).Picture.LoadFromFile(setCorEnemy(o2.Tag));
          if o2.Tag < 10 then
          begin
            o2.Visible := false;
            o2.Enabled := false;
            navesDestruidasPorWave:=navesDestruidasPorWave+1;

//            if pnlEnergiaRed.Visible and (pnlEnergiaRed.Left>painelEnergia.Left) then
               pnlEnergiaRed.Left := pnlEnergiaRed.Left+9;
               pnlEnergiaRed.Width := pnlEnergiaRed.Width-9;
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
        end;

       //Colis�o nave aliada e nave inimiga
        if o1.Tag = 0 then
        begin
          atualizaVida();
          o2.Visible := false;
          o2.Enabled := false;
          navesDestruidasPorWave:=navesDestruidasPorWave+1;
        end;


        lblAux2.Caption:=string.Parse(navesDestruidasPorWave);
      end;

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
     endGame := true;
   end;
end;

procedure TForm1.comMunicao();
begin
  fire.left := form1.Width - 100;
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
