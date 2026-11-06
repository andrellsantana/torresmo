package br.com.torresmo;

import java.time.LocalTime;

public class CalculadoraHorarioTest {
    public static void main(String[] args) {
        verificar("08:00", 540, 0, "17:00", 0);
        verificar("08:15", 540, 90, "18:45", 0);
        verificar("08:15", 540, -75, "16:00", 0);
        verificar("22:30", 540, 0, "07:30", 1);
        verificar("15:00", 540, 0, "00:00", 1);
        verificar("08:00", 540, -540, "08:00", 0);
        verificar("23:45", 2880, 30, "00:15", 3);
        rejeitar(0, 0);
        rejeitar(540, -541);
        System.out.println("9 testes passaram.");
    }

    private static void verificar(String entrada, int jornada, int ajuste, String saida, long dias) {
        var resultado = CalculadoraHorario.calcular(LocalTime.parse(entrada), jornada, ajuste);
        if (!resultado.saida().equals(LocalTime.parse(saida)) || resultado.diasDepois() != dias
                || resultado.minutosTotais() != jornada + ajuste) throw new AssertionError(resultado);
    }

    private static void rejeitar(int jornada, int ajuste) {
        try {
            CalculadoraHorario.calcular(LocalTime.NOON, jornada, ajuste);
        } catch (IllegalArgumentException esperado) { return; }
        throw new AssertionError("Deveria rejeitar duração inválida");
    }
}
