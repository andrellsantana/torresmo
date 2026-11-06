/* Clipper / Harbour: cadastro local em DBF, sem dependencias externas. */
#include "set.ch"

PROCEDURE Main( cDiretorio, cModo )
   LOCAL cOpcao := Space( 1 )
   LOCAL nId
   LOCAL GetList := {}
   LOCAL aEstrutura := { { 'ID', 'N', 8, 0 }, ;
      { 'NOME', 'C', 80, 0 }, { 'EMAIL', 'C', 100, 0 }, ;
      { 'TELEFONE', 'C', 25, 0 }, { 'CIDADE', 'C', 60, 0 } }

   SET DATE BRITISH
   SET CENTURY ON
   SET DELETED ON
   SET CONFIRM ON
   IF Empty( cDiretorio )
      cDiretorio := 'dados'
   ENDIF
   IF ! hb_DirExists( cDiretorio ) .AND. hb_DirCreate( cDiretorio ) != 0
      ? 'Nao foi possivel criar a pasta de dados.'
      ErrorLevel( 1 )
      RETURN
   ENDIF
   cDiretorio := hb_DirSepAdd( cDiretorio )
   IF ! File( cDiretorio + 'pessoas.dbf' )
      dbCreate( cDiretorio + 'pessoas.dbf', aEstrutura, 'DBFNTX' )
   ENDIF
   dbUseArea( .T., 'DBFNTX', cDiretorio + 'pessoas.dbf', 'PESSOAS', .F., .F. )
   IF ! Used()
      ? 'Nao foi possivel abrir o cadastro. Feche outra instancia e tente novamente.'
      ErrorLevel( 1 )
      RETURN
   ENDIF
   IF cModo == '--test'
      Testar()
      dbCloseAll()
      RETURN
   ENDIF

   DO WHILE cOpcao != '0'
      CLEAR SCREEN
      ? 'TORRESMO - CADASTRO DE PESSOAS'
      ? Replicate( '=', 42 )
      ? '1 - Incluir pessoa'
      ? '2 - Listar / pesquisar por nome'
      ? '3 - Editar pessoa pelo codigo'
      ? '4 - Excluir pessoa pelo codigo'
      ? '0 - Sair'
      ?
      cOpcao := Space( 1 )
      @ 10, 0 SAY 'Opcao: ' GET cOpcao PICTURE '9'
      READ
      IF LastKey() == 27
         EXIT
      ENDIF
      DO CASE
      CASE cOpcao == '1'
         Editar( .T. )
      CASE cOpcao == '2'
         Listar()
      CASE cOpcao == '3' .OR. cOpcao == '4'
         nId := 0
         CLEAR SCREEN
         @ 2, 0 SAY 'Codigo da pessoa: ' GET nId PICTURE '99999999'
         READ
         IF LastKey() != 27
            LOCATE FOR PESSOAS->ID == nId
            IF Found()
               IF cOpcao == '3'
                  Editar( .F. )
               ELSEIF Alert( 'Excluir ' + AllTrim( PESSOAS->NOME ) + '?', { 'Cancelar', 'Excluir' } ) == 2
                  DELETE
                  dbCommit()
               ENDIF
            ELSE
               Alert( 'Pessoa nao encontrada.' )
            ENDIF
         ENDIF
      ENDCASE
   ENDDO
   dbCloseAll()
   CLEAR SCREEN
   ? 'Cadastro salvo. Ate logo!'
RETURN

PROCEDURE Editar( lNovo )
   LOCAL cNome := IIf( lNovo, Space( 80 ), PESSOAS->NOME )
   LOCAL cEmail := IIf( lNovo, Space( 100 ), PESSOAS->EMAIL )
   LOCAL cTelefone := IIf( lNovo, Space( 25 ), PESSOAS->TELEFONE )
   LOCAL cCidade := IIf( lNovo, Space( 60 ), PESSOAS->CIDADE )
   LOCAL GetList := {}
   CLEAR SCREEN
   ? 'PESSOA - ESC cancela; Enter avanca; Ctrl+W conclui'
   @ 3, 0 SAY 'Nome:     ' GET cNome PICTURE '@S60' VALID ! Empty( cNome )
   @ 5, 0 SAY 'Email:    ' GET cEmail PICTURE '@S60' VALID EmailValido( cEmail )
   @ 7, 0 SAY 'Telefone: ' GET cTelefone PICTURE '@S25'
   @ 9, 0 SAY 'Cidade:   ' GET cCidade PICTURE '@S60'
   READ
   IF LastKey() == 27
      RETURN
   ENDIF
   IF Empty( cNome ) .OR. ! EmailValido( cEmail )
      Alert( 'Informe o nome e um email valido (ou deixe o email vazio).' )
      RETURN
   ENDIF
   IF Alert( 'Salvar pessoa?', { 'Salvar', 'Cancelar' } ) == 1
      IF lNovo
         IF ProximoId() > 99999999
            Alert( 'Limite de codigos atingido.' )
            RETURN
         ENDIF
         APPEND BLANK
         REPLACE ID WITH ProximoId()
      ENDIF
      REPLACE NOME WITH AllTrim( cNome ), EMAIL WITH AllTrim( cEmail ), ;
         TELEFONE WITH AllTrim( cTelefone ), CIDADE WITH AllTrim( cCidade )
      dbCommit()
   ENDIF
RETURN

FUNCTION EmailValido( cEmail )
   LOCAL nArroba
   cEmail := AllTrim( cEmail )
   IF Empty( cEmail )
      RETURN .T.
   ENDIF
   nArroba := At( '@', cEmail )
RETURN nArroba > 1 .AND. nArroba < Len( cEmail ) .AND. ;
   At( '@', SubStr( cEmail, nArroba + 1 ) ) == 0 .AND. ;
   At( '.', SubStr( cEmail, nArroba + 2 ) ) > 0 .AND. !( ' ' $ cEmail )

FUNCTION ProximoId()
   LOCAL nRegistro := RecNo(), nMax := 0
   LOCAL lDeletados := Set( _SET_DELETED, .F. )
   dbGoTop()
   DO WHILE ! Eof()
      nMax := Max( nMax, PESSOAS->ID )
      dbSkip()
   ENDDO
   Set( _SET_DELETED, lDeletados )
   dbGoTo( nRegistro )
RETURN nMax + 1

PROCEDURE Listar()
   LOCAL cBusca := Space( 80 ), nLinha := 5
   LOCAL GetList := {}
   CLEAR SCREEN
   @ 1, 0 SAY 'Nome (vazio lista todos): ' GET cBusca PICTURE '@S45'
   READ
   IF LastKey() == 27
      RETURN
   ENDIF
   cBusca := Upper( AllTrim( cBusca ) )
   @ 3, 0 SAY 'CODIGO   NOME                           TELEFONE'
   dbGoTop()
   DO WHILE ! Eof()
      IF Empty( cBusca ) .OR. cBusca $ Upper( PESSOAS->NOME )
         @ nLinha, 0 SAY Str( PESSOAS->ID, 8 ) + ' ' + PadR( Left( PESSOAS->NOME, 30 ), 30 ) + ' ' + AllTrim( PESSOAS->TELEFONE )
         nLinha++
         IF nLinha >= MaxRow() - 2
            @ MaxRow() - 1, 0 SAY 'Qualquer tecla continua; ESC volta ao menu.'
            IF Inkey( 0 ) == 27
               RETURN
            ENDIF
            CLEAR SCREEN
            nLinha := 3
         ENDIF
      ENDIF
      dbSkip()
   ENDDO
   @ Min( nLinha + 1, MaxRow() ), 0 SAY 'Fim da lista. Pressione uma tecla.'
   Inkey( 0 )
RETURN

PROCEDURE Testar()
   LOCAL nId
   IF LastRec() != 0
      ? 'Teste exige uma pasta de dados vazia.'
      ErrorLevel( 1 )
      RETURN
   ENDIF
   nId := ProximoId()
   APPEND BLANK
   REPLACE ID WITH nId, NOME WITH 'Maria Silva', EMAIL WITH 'maria@example.com'
   dbCommit()
   dbCloseArea()
   dbUseArea( .T., 'DBFNTX', hb_ArgV( 1 ) + hb_ps() + 'pessoas.dbf', 'PESSOAS', .F., .F. )
   LOCATE FOR PESSOAS->ID == nId
   Exigir( Found() .AND. AllTrim( PESSOAS->NOME ) == 'Maria Silva', 'inclusao e persistencia' )
   REPLACE CIDADE WITH 'Sao Paulo'
   dbCommit()
   Exigir( AllTrim( PESSOAS->CIDADE ) == 'Sao Paulo', 'edicao' )
   DELETE
   dbCommit()
   Exigir( ProximoId() == nId + 1, 'codigo nao reutiliza excluidos' )
   dbGoTop()
   Exigir( Eof(), 'exclusao oculta registro' )
   Exigir( EmailValido( '' ) .AND. EmailValido( 'a@b.com' ) .AND. ;
      ! EmailValido( 'invalido' ) .AND. ! EmailValido( 'a@@b.com' ), 'validacao de email' )
   ? '5 testes passaram.'
RETURN

PROCEDURE Exigir( lCondicao, cTeste )
   IF ! lCondicao
      ? 'FALHOU: ' + cTeste
      ErrorLevel( 1 )
      QUIT
   ENDIF
RETURN
