# Cadastro de pessoas — Clipper / Harbour

Aplicacao de terminal para macOS, escrita em `.prg` com sintaxe Clipper e
compilada com Harbour. Inclui inclusao, pesquisa por nome, edicao e exclusao
pelo codigo. Campos: nome obrigatorio, email opcional, telefone e cidade.
A edicao mostra todos os campos. Codigos sao automaticos e nao reutilizados.

## Instalar no Mac

1. Instale o [Homebrew](https://brew.sh), caso ainda nao tenha.
2. No Terminal, execute:

```sh
xcode-select --install
brew install harbour
```

Se as ferramentas de desenvolvimento ja estiverem instaladas, nao e necessario
repetir `xcode-select --install`.

3. Baixe o repositorio pelo GitHub (**Code → Download ZIP**), extraia e abra
   um Terminal dentro da pasta `cadastro-pessoas`.
4. Compile e execute:

```sh
bash compilar.sh
bash iniciar.command
```

A compilacao e feita no proprio Mac, tanto Intel quanto Apple Silicon.
Depois da primeira compilacao, tambem pode abrir `iniciar.command` com dois cliques.
Se houver bloqueio do macOS, use **Abrir Mesmo Assim** em Privacidade e Seguranca
somente depois de verificar a origem dos arquivos.

## Uso e armazenamento

- Escolha a opcao do menu e pressione Enter.
- Enter avanca entre campos; Ctrl+W conclui; Esc cancela.
- Email vazio e permitido. Um email preenchido recebe verificacao basica de formato.
- A exclusao pede confirmacao e marca o registro como excluido no DBF.
- O cadastro e local, para uma instancia por vez. Feche a aplicacao antes de
  abrir outra instancia ou copiar os dados.
- Pelo inicializador, os dados ficam em
  `~/Library/Application Support/Torresmo/Pessoas/pessoas.dbf`.
- Para backup, feche o cadastro e copie essa pasta. Para restaurar, substitua-a
  por sua copia com o programa fechado.
- Nao envie dados pessoais ao GitHub. Os DBFs sao ignorados pelo Git.
- O terminal usa a codificacao do sistema. Os rotulos usam ASCII para maior
  compatibilidade; confira nomes acentuados no seu Terminal antes do uso real.

Para usar outra pasta de dados:

```sh
./cadastro /caminho/para/pasta
```

## Testes

O modo de testes usa uma pasta temporaria exclusiva; nao utilize dados reais:

```sh
pasta_teste=$(mktemp -d)
./cadastro "$pasta_teste" --test
```

Verifica inclusao e persistencia apos reabrir o DBF, edicao, exclusao,
nao reutilizacao de codigo excluido e validacao de email.
