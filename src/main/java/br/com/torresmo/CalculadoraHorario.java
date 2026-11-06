package br.com.torresmo;

import java.time.LocalTime;

/** Cálculo independente da interface, com duração em minutos. */
public final class CalculadoraHorario {
    private CalculadoraHorario() {}

    public record Resultado(LocalTime saida, long diasDepois, long minutosTotais) {}

    public static Resultado calcular(LocalTime entrada, int jornadaMinutos, int ajusteMinutos) {
        if (entrada == null) throw new IllegalArgumentException("Informe o horário de entrada.");
        if (jornadaMinutos <= 0) throw new IllegalArgumentException("A jornada deve ser maior que zero.");
        long total = (long) jornadaMinutos + ajusteMinutos;
        if (total < 0) throw new IllegalArgumentException("O desconto não pode superar a jornada.");
        long minutoSaida = entrada.getHour() * 60L + entrada.getMinute() + total;
        return new Resultado(LocalTime.of((int) (minutoSaida % 1440) / 60,
                (int) (minutoSaida % 60)), minutoSaida / 1440, total);
    }
}
