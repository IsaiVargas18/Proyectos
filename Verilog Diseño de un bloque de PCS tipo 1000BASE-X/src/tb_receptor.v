// Tester y testbench usado para verificar funcionamiento del receptor, pero no es dependiente del funcionamiento trabajo,
// solo usado para verificar por separado.
`include "receptor.v"

// Modulo probador del receptor parte a y b
module tester_RECEIVE (
		output reg mr_main_reset, clk, rx_even,
		output reg [9:0] SUDI,
		output reg [2:0] xmit,
        output reg RX_CLK
);

    // Reloj usado para el receptor
    always begin
        clk = 1;
        #1;
        clk = 0;
        #1;
    end

    initial begin
        mr_main_reset = 1'b0; // False
        #2;
        mr_main_reset = 1'b1; // True

        // WAIT_FOR_K
        SUDI = 10'b1100000101; // Recibe comma
        rx_even = 1;

        // RX_K
        #10;
        xmit = 3'b010; // xmit = 010 = DATA
        SUDI = 10'b0100101011; // Valor arbitrario valido de dato

        // IDLE_D
        #5;
        SUDI = 10'b1100000101; // Prueba para ir a RX_K, valor de comma

        // RX_K
        #10;
        xmit = 3'b010; // xmit = 010 = DATA
        SUDI = 10'b0100101011; // Valor arbitrario valido de dato

        // IDLE_D
        #10;
        SUDI = 10'b0010010111; // SUDI recibe /S/

        // START_OF_PACKET
        // Se empiezan a mandar datos arbitrarios
        #10;
        SUDI = 8'h01;
        #4;
        SUDI = 8'h02;
        #4;
        SUDI = 8'h03;
        #4;
        SUDI = 8'h04;
        #4;
        SUDI = 8'h42;
        #4;
        SUDI = 8'h50;
        #4;
        SUDI = 8'h9A;
        #4;
        SUDI = 8'hA6;
        #4;
        
        // Ahora se hace la prueba para finalizar y enviar /T/R/K28.5/
        SUDI = 10'b0100010111; // Llega /T/
        #4;
        SUDI = 10'b0001010111; // Llega /R/
        #4;
        SUDI = 10'b1100000101; // Llega /K28.5/

        // TRI + RRI
        #10;
        SUDI = 10'b1100000101; // Llega /K28.5/
        #50;
        $finish;
    end
endmodule

module testbench_RECEIVE;
    wire mr_main_reset, clk, rx_even;
    wire [9:0] SUDI;
	wire [2:0] xmit;
    wire RX_CLK;

    initial begin
        $dumpfile("resultados_RECEIVE.vcd");
        $dumpvars;
    end

    // Instanciar receptor
    tester_RECEIVE probador(
        .mr_main_reset(mr_main_reset),
        .clk(clk),
        .rx_even(rx_even),
		.SUDI(SUDI[9:0]),
		.xmit(xmit[2:0]),
        .RX_CLK(RX_CLK)
    );

    // Instanciar el receptor
    RECEIVE receptor(
        .mr_main_reset(mr_main_reset),
        .clk(clk),
        .rx_even(rx_even),
		.SUDI(SUDI[9:0]),
		.xmit(xmit[2:0]),
        .RX_CLK(RX_CLK)
    );

endmodule