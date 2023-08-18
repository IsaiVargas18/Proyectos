/////////////////// Defines necesarios /////////////////// 
    `include "tablas.v" //archivo con las tablas de los code-gruops
    `define TRUE  1'b1
    `define FALSE 1'b0
    `define sll(bits, x) (bits<<x)
    `define Constants_size 9
    `define First_os            `Constants_size'h1
    `define OS_T             `sll(`First_os, 1)
    `define OS_R             `sll(`First_os, 2)
    `define OS_I             `sll(`First_os, 3)
    `define OS_D             `sll(`First_os, 4)
    `define OS_S             `sll(`First_os, 5)
    `define OS_V             `sll(`First_os, 6)
    `define OS_LI            `sll(`First_os, 7)

/////////////////// 36.2.5.1.4 Functions ///////////////////
    // La función se establece en la detección de cambio de estado de la variable xmit
    module XMITCHANGE (
        input clk,                    // Entrada de reloj
        input [2:0] xmit,             // Señal de cambio de estado
        output reg xmit_change_out);  // Bandera de si hubo cambio o no

        reg [2:0] xmit_old;

        always @(posedge clk ) xmit_old <= xmit;       // Se guarda el valor de xmit en cada flanco positivo de clk

        always @(*) begin
            if (xmit == xmit_old)            // Se compara el xmit anterior y el actual
                xmit_change_out = `FALSE;    // FALSE; An xmit variable state change has not been detected (default).
            else xmit_change_out = `TRUE;    // TRUE; An xmit variable state change has been detected.
        end
    endmodule
    
    // VOID(x) Pone an la salida V o la entrada, dependiendo de TX_EN, TX_ER y TXD
    module VOID (
        input TX_EN,       // transmit enable
        input TX_ER,       // transmit data
        input [7:0] TXD,   // transmit coding error
        input [`Constants_size-1:0] x_in, // Entrada
        output reg [`Constants_size-1:0] return);

        always @(*) begin
            if (!TX_EN && TX_ER && TXD[7:0] != 8'h0F) return = `OS_V; // If [TX_EN=FALSE and TX_ER=TRUE and TXD != (0000 1111)], return /V/
            else if (TX_EN && TX_ER) return = `OS_V;                  // Else if [TX_EN=TRUE * TX_ER=TRUE], return /V/                
            else return = x_in;                                       // Else return x.
        end
    endmodule