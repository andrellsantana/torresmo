package br.com.torresmo;

import javax.swing.*;
import javax.swing.border.EmptyBorder;
import javax.swing.event.ChangeListener;
import java.awt.*;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;

public final class TorresmoApp {
    private static final Color FUNDO = new Color(245, 247, 251);
    private final JSpinner entradaHora = numero(8, 23);
    private final JSpinner entradaMinuto = numero(0, 59);
    private final JSpinner jornadaHora = numero(9, 48);
    private final JSpinner jornadaMinuto = numero(0, 59);
    private final JSpinner ajusteHora = numero(0, 48);
    private final JSpinner ajusteMinuto = numero(0, 59);
    private final JComboBox<String> operacao = new JComboBox<>(new String[]{"Acrescentar", "Descontar"});
    private final JLabel saida = new JLabel("—", SwingConstants.CENTER);
    private final JLabel detalhe = new JLabel(" ", SwingConstants.CENTER);
    private final JLabel erro = new JLabel(" ");

    public static void main(String[] args) {
        SwingUtilities.invokeLater(() -> new TorresmoApp().abrir());
    }

    private static JSpinner numero(int inicial, int maximo) {
        JSpinner spinner = new JSpinner(new SpinnerNumberModel(inicial, 0, maximo, 1));
        spinner.setEditor(new JSpinner.NumberEditor(spinner, "00"));
        spinner.setPreferredSize(new Dimension(78, 34));
        return spinner;
    }

    private void abrir() {
        JFrame janela = new JFrame("Torresmo • Horário de saída");
        janela.setDefaultCloseOperation(WindowConstants.EXIT_ON_CLOSE);
        JPanel painel = new JPanel();
        painel.setLayout(new BoxLayout(painel, BoxLayout.Y_AXIS));
        painel.setBackground(FUNDO);
        painel.setBorder(new EmptyBorder(28, 32, 24, 32));
        JLabel titulo = new JLabel("Quando posso sair?");
        titulo.setFont(titulo.getFont().deriveFont(Font.BOLD, 26f));
        painel.add(titulo);
        painel.add(Box.createVerticalStrut(8));
        painel.add(new JLabel("Calcule sua saída a partir da entrada e da jornada."));
        painel.add(Box.createVerticalStrut(24));
        painel.add(linha("Entrada", entradaHora, entradaMinuto));
        painel.add(linha("Jornada de trabalho", jornadaHora, jornadaMinuto));
        painel.add(linha("Ajuste na jornada", ajusteHora, ajusteMinuto));
        JPanel tipo = new JPanel(new FlowLayout(FlowLayout.LEFT, 0, 8));
        tipo.setOpaque(false);
        tipo.add(operacao);
        painel.add(tipo);
        painel.add(new JLabel("Acrescentar adia a saída; descontar antecipa a saída."));
        painel.add(Box.createVerticalStrut(20));
        JPanel resultado = new JPanel(new GridLayout(3, 1, 0, 4));
        resultado.setBackground(new Color(228, 238, 255));
        resultado.setBorder(new EmptyBorder(16, 12, 16, 12));
        resultado.add(new JLabel("HORÁRIO DE SAÍDA", SwingConstants.CENTER));
        saida.setFont(saida.getFont().deriveFont(Font.BOLD, 38f));
        resultado.add(saida);
        resultado.add(detalhe);
        painel.add(resultado);
        erro.setForeground(new Color(170, 35, 35));
        painel.add(Box.createVerticalStrut(12));
        painel.add(erro);
        for (Component componente : painel.getComponents()) {
            if (componente instanceof JComponent c) c.setAlignmentX(Component.LEFT_ALIGNMENT);
        }
        ChangeListener atualizar = e -> atualizar();
        for (JSpinner campo : campos()) campo.addChangeListener(atualizar);
        operacao.addActionListener(e -> atualizar());
        atualizar();
        janela.setContentPane(painel);
        janela.pack();
        janela.setMinimumSize(janela.getSize());
        janela.setLocationRelativeTo(null);
        janela.setVisible(true);
    }

    private JPanel linha(String nome, JSpinner hora, JSpinner minuto) {
        JPanel linha = new JPanel(new FlowLayout(FlowLayout.LEFT, 8, 8));
        linha.setOpaque(false);
        JLabel rotulo = new JLabel(nome);
        rotulo.setPreferredSize(new Dimension(165, 30));
        linha.add(rotulo);
        linha.add(hora);
        linha.add(new JLabel("h"));
        linha.add(minuto);
        linha.add(new JLabel("min"));
        hora.getAccessibleContext().setAccessibleName(nome + " em horas");
        minuto.getAccessibleContext().setAccessibleName(nome + " em minutos");
        return linha;
    }

    private JSpinner[] campos() {
        return new JSpinner[]{entradaHora, entradaMinuto, jornadaHora, jornadaMinuto, ajusteHora, ajusteMinuto};
    }

    private static int valor(JSpinner campo) { return ((Number) campo.getValue()).intValue(); }

    private void atualizar() {
        try {
            int ajuste = valor(ajusteHora) * 60 + valor(ajusteMinuto);
            if (operacao.getSelectedIndex() == 1) ajuste = -ajuste;
            var resultado = CalculadoraHorario.calcular(LocalTime.of(valor(entradaHora), valor(entradaMinuto)),
                    valor(jornadaHora) * 60 + valor(jornadaMinuto), ajuste);
            saida.setText(resultado.saida().format(DateTimeFormatter.ofPattern("HH:mm")));
            String dia = resultado.diasDepois() == 0 ? "No mesmo dia" : resultado.diasDepois() == 1
                    ? "No dia seguinte" : "Daqui a " + resultado.diasDepois() + " dias";
            detalhe.setText(dia + " • " + resultado.minutosTotais() / 60 + "h "
                    + resultado.minutosTotais() % 60 + "min após a entrada");
            erro.setText(" ");
        } catch (IllegalArgumentException ex) {
            saida.setText("—");
            detalhe.setText("Revise os valores informados");
            erro.setText(ex.getMessage());
        }
    }
}
