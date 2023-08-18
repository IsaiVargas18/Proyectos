`include "Functions.v"

////////// Probador XMITCHANGE //////////
module tester_XMITCHANGE (
    output reg GTX_CLK,     // Salida del reloj
    output reg [2:0] xmit); // Estado actual de transmisión
    
    // Reloj
    always begin
        GTX_CLK = 1'b0; #1;
        GTX_CLK = 1'b1; #1;
    end

    initial begin
        // Prueba #1
        xmit = 3'b001;
        #10;
        xmit = 3'b010;
        #10;
        xmit = 3'b001;
        #20;
        $finish;
    end
endmodule

////////// Probador VOID //////////
module tester_VOID (
    output reg [7:0] TXD,  // transmit data
    output reg TX_EN,      // transmit enable
    output reg TX_ER,      // transmit coding error
    output reg [8:0] x_in  // Parametro de VOID
    );
    

    initial begin
        x_in = 7;
        // Prueba #1 primer if (deberia poner OS_V = 64 en return)
        TX_EN = 1'b0;  // !TX_EN
        TX_ER = 1'b1;  // TX_ER
        TXD = 8'h00;   // TXD[7:0] != 8'h0F
        #10;

        // Prueba #2 primer if (deberia poner x_in = 7 en return)
        TX_EN = 1'b0;  // !TX_EN
        TX_ER = 1'b1;  // TX_ER
        TXD = 8'h0F;   // TXD[7:0] != 8'h0F
        #10;

        // Prueba #3 else if (deberia poner OS_V = 64 en return)
        TX_EN = 1'b1;  // TX_EN
        TX_ER = 1'b1;  // TX_ER
        #10;

        // Prueba #4 else (deberia poner x_in = 7 en return)
        TX_EN = 1'b1;  // TX_EN
        TX_ER = 1'b0;  // !TX_ER
        #10;
        $finish;
    end
endmodule

////////// Testbench //////////
module testbench_funtions;
    wire GTX_CLK;      // Señal de reloj
    wire TX_EN;        // transmit enable
    wire TX_ER;        // transmit coding error
    wire [7:0] TXD;    // transmit data
    wire [2:0] xmit;   // Estado actual de transmisión
    wire [8:0] x_in;   // Parametro de VOID
    wire [8:0] return; //return del void

    // Intanciacion de los probadores
    tester_XMITCHANGE probador_XMITCHANGE (
        .GTX_CLK      (GTX_CLK),  
        .xmit         (xmit[2:0])
    );

    
    tester_VOID probador_VOID (
        .TX_EN        (TX_EN),
        .TX_ER        (TX_ER),
        .TXD          (TXD[7:0]),
        .x_in         (x_in)
    );

    // Instanciacion de las unidades bajo prueba
    XMITCHANGE xmit_DUT (
            .clk(GTX_CLK),
            .xmit(xmit),
            .xmit_change_out(xmit_change_out)
    );

    VOID void_DUT (
        .x_in(x_in),
        .TX_EN(TX_EN),
        .TX_ER(TX_ER),
        .TXD(TXD[7:0]),
        .return(return)
    );

    initial begin
        $dumpfile("tb_TX.vcd");
        $dumpvars;
    end
endmodule