# Torresmo — calculadora de horário de saída

Aplicação desktop Java Swing. Informe a entrada, a jornada (padrão: 9 horas)
e um ajuste em horas e minutos. Acrescentar adia a saída; descontar antecipa.
O resultado atualiza automaticamente e indica a mudança de dia.
Intervalos não são adicionados automaticamente: inclua-os no acréscimo se necessário.

## Compilar e testar

Requer JDK 17 ou superior, sem dependências externas.

```sh
bash build.sh
```

O script executa os testes e gera `build/torresmo.jar`.
Se necessário, defina `JAVA_HOME` apontando para seu JDK.

## Executar

O arquivo pronto para uso está em [`dist/torresmo.jar`](dist/torresmo.jar).
No GitHub, abra esse arquivo e clique em **Download raw file** para baixá-lo.
Execute o arquivo baixado com `java -jar torresmo.jar`.

Em um computador com interface gráfica e Java 17 ou superior:

```sh
java -jar build/torresmo.jar
```

No Windows, o JAR também pode ser executado com `javaw -jar build/torresmo.jar`.
O cálculo usa horário local, sem datas ou fusos. Os valores valem para a sessão
atual e não são salvos ao fechar a janela.
