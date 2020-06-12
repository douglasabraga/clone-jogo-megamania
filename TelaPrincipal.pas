unit TelaPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Imaging.pngimage, Vcl.ExtCtrls,
  Vcl.StdCtrls, Vcl.Grids, ArquivosUnit, Vcl.MPlayer;

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
    lblQntdWave: TLabel;
    lblQntdNavesDestruidas: TLabel;
    pnlEnergiaRed: TPanel;
    TGeraFase: TTimer;
    Label1: TLabel;
    Label2: TLabel;
    TAtualizaEnergia: TTimer;
    btnJogar: TButton;
    btnControles: TButton;
    btnInstrucoes: TButton;
    pnlMenu: TPanel;
    lblSaudacao: TLabel;
    Memo1: TMemo;
    lblCriadorDoGame: TLabel;
    TMusic: TTimer;

    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormCreate(Sender: TObject);

    procedure TimerAnimacaoTiroTimer(Sender: TObject);
    procedure TimerLiberacaoTiroTimer(Sender: TObject);
    procedure TMoverTimer(Sender: TObject);
    procedure TCriadorTimer(Sender: TObject);
    procedure TGeraFaseTimer(Sender: TObject);
    procedure TAtualizaEnergiaTimer(Sender: TObject);
    procedure TMusicTimer(Sender: TObject);

    function  VerificaColisao(O1, O2 : TControl):boolean;

    procedure comMunicao();
    procedure semMunicao();
    procedure atualizaVida();

    function  setTag(tag : integer):integer;
    function  setCorEnemy(tag : integer):string;

    procedure MenuPrincipal();
    procedure telaFimJogo();
    procedure btnJogarClick(Sender: TObject);
    procedure btnInstrucoesClick(Sender: TObject);
    procedure btnControlesClick(Sender: TObject);
    procedure inicializaMemo(lerArq:boolean; diretorio : string);
    procedure habilitaBotoesMenu(op : boolean);


  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  faseAtual: integer;
  endGame: boolean;
  life: integer;
  pontuacao: integer;
  navesDestruidasPorWave: integer;
  totalNavesDestruidas: integer;
  NumeroNaves: integer;
  geradorNaves: integer;
  energia: integer;
//  energiaRed: integer;
  tm: TMediaPlayer;
  tmFundo: TMediaPlayer;
implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);

begin
    Randomize;
    faseAtual              := 1;
    NumeroNaves            := 3;
    life                   := 5;
//    energiaRed             := 0;
    totalNavesDestruidas   := 0;
    navesDestruidasPorWave := 0;
    pontuacao              := 0;
    DoubleBuffered         := true;
    endGame                := false;

//    tm:=TMediaPlayer.Create(Form1);
//    tm.Parent:=Form1;
//    tm.Visible:=false;
//    tm.FileName:='sounds/som_explosion (online-audio-converter.com).mp3';

    tmFundo:=TMediaPlayer.Create(Form1);
    tmFundo.Parent:=Form1;
    tmFundo.Visible:=false;
    tmFundo.FileName:='sounds\som_menu (online-audio-converter.com).mp3';
    tmFundo.Open;
    tmFundo.Play;

    MenuPrincipal;
end;

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);

  var incremento : integer;

begin

  if not endGame then
  begin

    incremento := 20;

    case key of
      VK_LEFT  : nave.Left := nave.Left - incremento;
      VK_RIGHT : nave.Left := nave.Left + incremento;
    end;

      pnlEnergiaRed.Left  := pnlEnergiaRed.Left  - 1;
      pnlEnergiaRed.Width := pnlEnergiaRed.Width + 1;

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
      t.Tag     := setTag(10 + Random(7));
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
   if (Tag >= 16) and (faseAtual >= 15) then
       begin
         Result:=16;
       end
   //Nave Inimiga de cor verde
   else if (Tag >= 13) and (faseAtual >= 10) then
       begin
         Result:=13;
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
   else if Tag <= 13 then
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
  if pnlEnergiaRed.Left > painelEnergia.Left + painelEnergia.Width - 3 then
  begin
   pnlEnergiaRed.Left  := painelEnergia.Left + painelEnergia.Width - 3;
   pnlEnergiaRed.Width := 3;
  end;

  if pnlEnergiaRed.Left <= painelEnergia.Left then
  begin
    pnlEnergiaRed.Left := painelEnergia.Left;
//    endGame := true;
    telaFimJogo;
  end
end;

procedure TForm1.TGeraFaseTimer(Sender: TObject);
begin
   if (NumeroNaves - navesDestruidasPorWave = 0) then
   begin
      geradorNaves:= 0;
      navesDestruidasPorWave:=0;
      faseAtual := faseAtual+1;
      NumeroNaves:= faseAtual*(1 + Random(3));
      lblQntdWave.Caption:=string.Parse(faseAtual);
      pnlEnergiaRed.Enabled:=false;
      pnlEnergiaRed.Width:=3;
      pnlEnergiaRed.Left:=579;
   end;
end;


procedure TForm1.TimerAnimacaoTiroTimer(Sender: TObject);
begin
   fire.Top := fire.top-5;
   //Sair da tela
   if((fire.Top < -100)) then comMunicao();
end;


procedure TForm1.TimerLiberacaoTiroTimer(Sender: TObject);
begin
  if((GetKeyState(VK_SPACE) < 0) and (not fire.Enabled) and not(endGame) ) then
  begin
      fire.Left := nave.Left + 26;
      fire.Top := nave.top - 20;
      semMunicao();
//      energiaRed:=energiaRed+15;
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
               Timage(form1.Components[i]).Top := Timage(form1.Components[i]).Top + 1;
               if Timage(form1.Components[i]).Top > form1.Height then
               begin
                  Timage(form1.Components[i]).Top    := -20;
                  Timage(form1.Components[i]).Left   := Random(form1.Width - 50);
                  //Decremento de 10 de energia na nave aliada
                  pnlEnergiaRed.Left  := pnlEnergiaRed.Left  - 5;
                  pnlEnergiaRed.Width := pnlEnergiaRed.Width + 5;
               end;

               VerificaColisao(fire, TImage(form1.Components[i]));

               if TImage(form1.Components[i]).Visible then
                 VerificaColisao(nave, TImage(form1.Components[i]));
            end;
         end;
       end;
   end;
end;

procedure TForm1.TMusicTimer(Sender: TObject);
begin
  tmFundo.FileName:='sounds\som_menu (online-audio-converter.com).mp3';
  tmFundo.Open;
  tmFundo.Play;
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
          //decrementra vida inimiga
          o2.Tag:=o2.Tag-1;
          //mutacao
          Timage(o2).Picture.LoadFromFile(setCorEnemy(o2.Tag));
          //inimigo destruido
          if o2.Tag < 10 then
          begin
            o2.Visible := false;
            o2.Enabled := false;

//            TMusic.
//            tm.Open;
//            tm.Play;

            navesDestruidasPorWave:=navesDestruidasPorWave+1;
            totalNavesDestruidas:=totalNavesDestruidas+1;
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

//          tm.FileName:='sounds/som_explosion.wav';
//          tm.Open;
//          tm.Play;

          navesDestruidasPorWave:=navesDestruidasPorWave+1;
          totalNavesDestruidas:=totalNavesDestruidas+1;
        end;

//        tm.FileName:='sounds/som_explosion.wav';

        lblQntdNavesDestruidas.Caption:=string.Parse(TotalNavesDestruidas);
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

     telaFimJogo;

     //Fechar painel de status do jogo

   end;
end;

procedure TForm1.comMunicao();
begin
  fire.left := form1.Left - 1000;
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

///RENDERIZA��O DO MENU

procedure TForm1.habilitaBotoesMenu(op : boolean);
begin
  btnJogar.Visible:=op;
  btnControles.Visible:=op;
  btnInstrucoes.Visible:=op;
end;

procedure TForm1.MenuPrincipal();
begin
  habilitaBotoesMenu(true);
  pnlMenu.Visible:=true;
end;

procedure TForm1.btnJogarClick(Sender: TObject);
begin
    //Habilitar Jogo
    TMover.Enabled := true;
    TCriador.Enabled := true;
    TimerLiberacaoTiro.Enabled :=true;
    TGeraFase.Enabled:= true;
    //TAtualizaEnergia.Enabled:=true;
    Panel1.Visible:=true;
    Panel1.Enabled:=true;
    nave.Visible:=true;
    nave.Enabled:=true;
    nave.Top:=526;
    nave.Left:=314;

    //Desabilitar Menu
    habilitaBotoesMenu(false);
    pnlMenu.Visible:=false;
    Memo1.Visible:=false;
end;

procedure TForm1.btnControlesClick(Sender: TObject);
begin
   inicializaMemo(true, 'arq/arq_controles.txt');
end;

procedure TForm1.btnInstrucoesClick(Sender: TObject);
begin
   inicializaMemo(true, 'arq/arq_historia.txt');
end;

procedure TForm1.inicializaMemo(lerArq:boolean; diretorio:string);
begin
   pnlMenu.Visible:=false;
   Memo1.WantReturns:=true;
   Memo1.Left := pnlMenu.Left;
   Memo1.Top:=pnlMenu.Top;
   Memo1.Width:=pnlMenu.Width;
   Memo1.Height:=pnlMenu.Height;
   if lerArq then Memo1.lines.LoadFromFile(diretorio);
   Memo1.Visible:=true;
end;

procedure TForm1.telaFimJogo();
begin
   inicializaMemo(false, '');
   Memo1.Font.Size:=20;
   Memo1.ScrollBars:=ssNone;
   Memo1.Text:=#13+#10+#13+#10+'              GAME OVER';
   Memo1.Text:=Memo1.Text+#13+#10+#13+#10+'       Voc� obteve: ';
   Memo1.Text:=Memo1.Text+string.Parse(pontuacao) + ' pts';
   Memo1.Text:=Memo1.Text+#13+#10+'       Foi at� a wave: ';
   Memo1.Text:=Memo1.Text+string.Parse(faseAtual);
   Memo1.Text:=Memo1.Text+#13+#10+'       Naves abatidas: ';
   Memo1.Text:=Memo1.Text+string.Parse(totalNavesDestruidas);

   endGame := true;
   TMusic.Enabled:=false;
   tmFundo.Enabled:=false;
   Panel1.Visible:=false;
   nave.Visible:=false;
end;

end.
