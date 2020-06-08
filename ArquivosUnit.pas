unit ArquivosUnit;

interface

uses
  SysUtils;

function ler_do_arquivo(nome_arquivo: String): String;
procedure escrever_no_arquivo(nome_arquivo, conteudo: String; adicionar: Boolean);

implementation

// Utilidade que lê todo um arquivo para uma string
function ler_do_arquivo(nome_arquivo: String): String;
var
  arq: TextFile;
  leitura: String;
begin
  // Parta do pressuposto de que o arquivo não existe
  Result := '';
  // Se o arquivo existir
  if(FileExists(nome_arquivo) = True) then
  begin
    // Associe o arquivo
    AssignFile(arq, nome_arquivo);
    // Leia-o desde o início
    Reset(arq);
    // Enquanto não chegar ao fim
    while(Eof(arq) = False) do
    begin
      // Leia tudo, linha por linha
      Readln(arq, leitura);
      Result := Result + leitura;
    end;
    // Feche o arquivo ao fim
    CloseFile(arq);
  end;
end;

// Escreve conteúdo em um arquivo, tratanto de sua existência (ou não) e da adição de conteúdo
procedure escrever_no_arquivo(nome_arquivo, conteudo: String; adicionar: Boolean);
var
  arq: TextFile;
begin
  // Se o arquivo existir
  if(FileExists(nome_arquivo) = True) then
  begin
    // Associe o arquivo
    AssignFile(arq, nome_arquivo);
    // Abra de acordo com o modo de adição pedido
    if(adicionar = True) then
      Append(arq)
    else
      Rewrite(arq);
    // Escreva o conteúdo repassado no arquivo
    Writeln(arq, conteudo);
    // Feche o arquivo
    CloseFile(arq);
  end
  else
  begin
    // Se o arquivo não existir, crie-o, escreva o conteúdo e feche-o
    AssignFile(arq, nome_arquivo);
    Rewrite(arq);
    Writeln(arq, conteudo);
    CloseFile(arq);
  end;
end;

end.
