`include "probador.v"
//`include "design.sv"
                                        
// Testbench Code Goes here
module me_tb;

    wire CLK,Reset,Tarjeta_recibida,Digito_STB,Tipo_trans,Monto_STB;
    wire [3:0] Digito;
    wire [15:0] PIN;
    wire [31:0] Monto;
    wire Balance_actualizado,Entregar_dinero,Fondos_insuficientes,PIN_incorrecto,Advertencia,Bloqueo;

    initial begin
        $dumpfile("test.vcd");
        $dumpvars(-1, cajero2);
    end

    cajero cajero2 (
        .CLK (CLK),
        .Reset (Reset),
        .Tarjeta_recibida(Tarjeta_recibida),
        .PIN(PIN),
        .Digito(Digito),
        .Digito_STB(Digito_STB),
        .Tipo_trans(Tipo_trans),
        .Monto(Monto),
        .Monto_STB(Monto_STB),
        .Balance_actualizado(Balance_actualizado),
        .Entregar_dinero(Entregar_dinero),
        .Fondos_insuficientes(Fondos_insuficientes),
        .PIN_incorrecto(PIN_incorrecto),
        .Advertencia(Advertencia),
        .Bloqueo(Bloqueo)
    );

    probador PROB_cajero2 (
        .CLK (CLK),
        .Reset (Reset),
        .Tarjeta_recibida(Tarjeta_recibida),
        .PIN(PIN),
        .Digito(Digito),
        .Digito_STB(Digito_STB),
        .Tipo_trans(Tipo_trans),
        .Monto(Monto),
        .Monto_STB(Monto_STB),
        .Balance_actualizado(Balance_actualizado),
        .Entregar_dinero(Entregar_dinero),
        .Fondos_insuficientes(Fondos_insuficientes),
        .PIN_incorrecto(PIN_incorrecto),
        .Advertencia(Advertencia),
        .Bloqueo(Bloqueo)
    );
endmodule