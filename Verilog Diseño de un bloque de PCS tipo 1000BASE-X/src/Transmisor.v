    `include "tablas.v" //archivo con las tablas de los code-gruops
    `define TRUE  1'b1
    `define FALSE 1'b0
    
    // Se desplaza el valor de 1 para hacer una codificacion de one hot de los estados
    `define OS_T             9'd1
    `define OS_R             9'd2
    `define OS_I             9'd3
    `define OS_D             9'd4
    `define OS_S             9'd5
    `define OS_V             9'd6
    `define OS_LI            9'd7

//Modulos para PCS transmit ordered set
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
            input [8:0] x_in, // Entrada
            output reg [8:0] return);

            always @(*) begin
                if (!TX_EN && TX_ER && TXD[7:0] != 8'h0F) return = `OS_V; // If [TX_EN=FALSE and TX_ER=TRUE and TXD != (0000 1111)], return /V/
                else if (TX_EN && TX_ER) return = `OS_V;                  // Else if [TX_EN=TRUE * TX_ER=TRUE], return /V/                
                else return = x_in;                                       // Else return x.
            end
        endmodule

        //Maquina de estados PCS transmit ordered set
        module TRANSMIT_OS (
            //Inputs
            input mr_main_reset,           // Señal de reset principal
            input GTX_CLK,                 // Señal de reloj
            input [7:0] TXD,               // Datos de transmisión
            input TX_EN,                   // Habilitación de transmisión
            input TX_ER,                   // Error de transmisión
            input receiving,               // Indicador de recepción
            input TX_OSET_indicate,        // Indicador de conjunto de órdenes de transmisión
            input tx_even,                 // Señal de paridad para los datos de transmisión
            input [2:0] xmit,              // Estado actual de transmisión

            //outputs
            output reg [6:0] tx_o_set,      // Conjunto de órdenes de transmisión generado
            output reg COL,                // Indicador de colisión
            output reg transmitting,       // Indicador de transmisión en progreso
            output reg [9:0] PUDR // Grupo de código de transmisión
            );

            // Parametros para la maquina PCS transmit ordered set
            localparam xmit_IDLE = 3'h1;               // Asignando el valor de xmit = IDLE
            localparam xmit_DATA = 3'h2;               // Asignando el valor de xmit = DATA
            
            //  ESTADOS DE TX ordered set codificados
            localparam TX_TEST_XMIT        = 8'b00000001;         
            localparam IDLE                = 8'b00000010;                 
            localparam XMIT_DATA           = 8'b00000100;            
            localparam START_OF_PACKET     = 8'b00001000;      
            localparam TX_PACKET           = 8'b00010000;            
            localparam END_OF_PACKET_NOEXT = 8'b00100000;  
            localparam EPD2_NOEXT          = 8'b01000000;           
            localparam EPD3                = 8'b10000000;                 

            //XMITCHANGE
            XMITCHANGE xmit_C (
                .clk(GTX_CLK),
                .xmit(xmit),
                .xmit_change_out(xmit_change_out)
            );

            //VOID(X)
            VOID void (
                .x_in(`OS_D),
                .TX_EN(TX_EN),
                .TX_ER(TX_ER),
                .TXD(TXD[7:0]),
                .return(tx_set_void)
            );

            // variables internas de TX ordered set
            wire xmit_change_out;
            wire [8:0] tx_set_void;
            reg [7:0] estado_actual;
            reg [7:0] estado_siguiente;


            always @(posedge GTX_CLK) begin
                if (!mr_main_reset || (xmit_change_out && TX_OSET_indicate && !tx_even)) begin
                    estado_actual <= TX_TEST_XMIT;
                    transmitting = `FALSE;
                    COL = `FALSE;
                end else
                    estado_actual <= estado_siguiente;
            end

            always @(*) begin
                // para garantizar el comportamiento del DFF
                estado_siguiente = estado_actual;

                // implementación de la máquina de estados
                // de acuerdo al diagrama ASM
                case(estado_actual)
                
                    // TX_TEST_XMIT
                    TX_TEST_XMIT: begin
                        transmitting = `FALSE;
                        COL = `FALSE;

                        if (xmit == xmit_IDLE || (xmit == xmit_DATA && (TX_EN || TX_ER)))
                            estado_siguiente = IDLE;
                        
                        if (xmit == xmit_DATA && !TX_EN && !TX_ER)
                            estado_siguiente = XMIT_DATA;
                    end

                    // IDLE
                    IDLE: begin
                        tx_o_set = `OS_I; // /I/

                        if (xmit == xmit_DATA && TX_OSET_indicate && !TX_EN && !TX_ER)
                            estado_siguiente = XMIT_DATA;
                    end

                    // XMIT_DATA
                    XMIT_DATA: begin
                        tx_o_set = `OS_I; // /I/

                        if (!TX_EN && TX_OSET_indicate)
                            estado_siguiente = XMIT_DATA;
                        
                        if (TX_EN && !TX_ER && TX_OSET_indicate)
                            estado_siguiente = START_OF_PACKET;
                    end

                    // START_OF_PACKET
                    START_OF_PACKET: begin
                        transmitting = `TRUE;
                        COL = receiving;
                        tx_o_set = `OS_S; // /S/

                        if (TX_OSET_indicate) estado_siguiente = TX_PACKET; // condicion de salto de estado
                    end

                    // TX_PACKET
                    TX_PACKET: begin

                        if (TX_EN) begin
                            COL = receiving;
                            tx_o_set = tx_set_void; // VOID(/D/)   
                        end

                        if (!TX_EN && !TX_ER) estado_siguiente = END_OF_PACKET_NOEXT; // condicion de salto de estado
                    end

                    // END_OF_PACKET_NOEXT
                    END_OF_PACKET_NOEXT: begin
                        COL = `FALSE;
                        tx_o_set = `OS_T; // /T/
                        
                        if (!tx_even) transmitting = `FALSE;

                        if (TX_OSET_indicate) estado_siguiente = EPD2_NOEXT; // condicion de salto de estadp
                    end

                    // Bloque de EPD2_NOEXT
                    EPD2_NOEXT: begin
                        transmitting = `FALSE;
                        tx_o_set = `OS_R; // Toma el valor de /R/ (carrier extend)

                        if (!tx_even && TX_OSET_indicate) begin
                            estado_siguiente = XMIT_DATA;
                        end else
                            estado_siguiente = EPD3;
                    end

                    // Bloque de EPD3
                    EPD3: begin
                        tx_o_set = `OS_R; // Toma el valor de /R/

                        if (TX_OSET_indicate)
                            estado_siguiente = XMIT_DATA;
                    end

                    // default
                    default:
                        estado_siguiente = TX_TEST_XMIT; // condicion de excepcion, salto al estado inicial
                endcase
            end
        endmodule

//Modulos para PCS transmit code-group
    //Este módulo codifica un código de grupo de 8 bits en un código de grupo de 10 bits.
    module ENCODE (
        input [7:0] code_group_8b_recibido,
        output reg [9:0] code_group_10b
    );

    always @(code_group_8b_recibido) begin
        //valid code-groups
        if (code_group_8b_recibido == `D00_0_08b)
            code_group_10b = `D00_0_10b; // D0.0
        else if (code_group_8b_recibido == `D01_0_08b)
            code_group_10b = `D01_0_10b; // D1.0
        else if (code_group_8b_recibido == `D02_0_08b)
            code_group_10b = `D02_0_10b; // D2.0
        else if (code_group_8b_recibido == `D03_0_08b)
            code_group_10b = `D03_0_10b; // D3.0
        else if (code_group_8b_recibido == `D02_2_08b)
            code_group_10b = `D02_2_10b; // D2.2
        else if (code_group_8b_recibido == `D16_2_08b)
            code_group_10b = `D16_2_10b; // D16.2
        else if (code_group_8b_recibido == `D26_4_08b)
            code_group_10b = `D26_4_10b; // D26.4
        else if (code_group_8b_recibido == `D06_5_08b)
            code_group_10b = `D06_5_10b; // D6.5
        else if (code_group_8b_recibido == `D21_5_08b)
            code_group_10b = `D21_5_10b; // D21.5
        else if (code_group_8b_recibido == `D05_6_08b)
            code_group_10b = `D05_6_10b; // D05.6

        //special code-groups
        else if (code_group_8b_recibido == `K28_0_08b)
            code_group_10b = `K28_0_10b; // K28.0
        else if (code_group_8b_recibido == `K28_1_08b)
            code_group_10b = `K28_1_10b; // K28.1
        else if (code_group_8b_recibido == `K28_2_08b)
            code_group_10b = `K28_2_10b; // K28.2
        else if (code_group_8b_recibido == `K28_3_08b)
            code_group_10b = `K28_3_10b; // K28.3
        else if (code_group_8b_recibido == `K28_4_08b)
            code_group_10b = `K28_4_10b; // K28.4
        else if (code_group_8b_recibido == `K28_5_08b)
            code_group_10b = `K28_5_10b; // K28.5
        else if (code_group_8b_recibido == `K28_6_08b)
            code_group_10b = `K28_6_10b; // K28.6
        else if (code_group_8b_recibido == `K28_7_08b)
            code_group_10b = `K28_7_10b; // K28.7
        else if (code_group_8b_recibido == `K23_7_08b)
            code_group_10b = `K23_7_10b; // K23.7 /R/
        else if (code_group_8b_recibido == `K27_7_08b)
            code_group_10b = `K27_7_10b; // K27.7 /S/
        else if (code_group_8b_recibido == `K29_7_08b)
            code_group_10b = `K29_7_10b; // K29.7 /T/
        else if (code_group_8b_recibido == `K30_7_08b)
            code_group_10b = `K30_7_10b; // K30.7 /V/
	end
	endmodule

    //Maquina de estados PCS transmit code-group 
    module TRANSMIT_CG (
        input mr_main_reset,           // Señal de reinicio principal
        input GTX_CLK,                 // Reloj de transmisión
        input [6:0] tx_o_set,           // Conjunto de salida de transmisión
        input [7:0] TXD,               // Datos de transmisión
        output reg tx_even,            // Bit de paridad de transmisión
        output reg TX_OSET_indicate,   // Indicador de conjunto de salida de transmisión
        output reg [9:0] PUDR // Código de grupo de transmisión
        );

        // variables internas de TX code group
        wire [9:0] TXD_encoded;   // Datos de transmisión codificados
        reg [1:0] state;          // Estado actual de la máquina de estados
        reg [1:0] nxt_state;      // Próximo estado de la máquina de estados

        localparam GENERATE_CODE_GROUPS = 3'b001;
        localparam IDLE_I2B = 3'b010;
        localparam DATA_G0 = 3'b100;

        // función ENCODE(X)
        ENCODE encoding (
            .code_group_8b_recibido(TXD),
            .code_group_10b(TXD_encoded)
        );

        always @(posedge GTX_CLK) begin
            if (!mr_main_reset) begin
                state <= GENERATE_CODE_GROUPS;
                TX_OSET_indicate <= `FALSE;
            end
            else
                state <= nxt_state;
        end

        always @(*) begin
            // para garantizar el comportamiento del DFF
            nxt_state = state;

            TX_OSET_indicate = `FALSE;
            // implementación de la máquina de estados 
            // de acuerdo al diagrama ASM
            case(state)
                // GENERATE_CODE_GROUPS
                GENERATE_CODE_GROUPS: begin
                    if (tx_o_set == `OS_I) begin
                        tx_even = `TRUE;
                        PUDR = `K28_5_10b; // /K28.5/
                        nxt_state = IDLE_I2B;
                    end

                    /*else if (tx_o_set == `OS_D) begin
                            PUDR = `D00_0_10b;
                            nxt_state = DATA_G0;
                        end

                    else if (tx_o_set == `OS_D) begin
                            PUDR = `D01_0_10b;
                            nxt_state = DATA_G0;
                        end

                    else if (tx_o_set == `OS_D) begin
                            PUDR = `D02_0_10b;
                            nxt_state = DATA_G0;
                        end
                            
                    else if (tx_o_set == `OS_D) begin
                            PUDR = `D03_0_10b;
                            nxt_state = DATA_G0;
                        end

                    else if (tx_o_set == `OS_D) begin
                            PUDR = `D02_2_10b; 
                            nxt_state = DATA_G0;
                        end

                    else if (tx_o_set == `OS_D) begin
                            PUDR = `D02_2_10b; 
                            nxt_state = DATA_G0;
                        end

                    else if (tx_o_set == `OS_D) begin
                            PUDR = `D16_2_10b;  
                            nxt_state = DATA_G0;
                        end

                    else if (tx_o_set == `OS_D) begin
                            PUDR = `D26_4_10b;  
                            nxt_state = DATA_G0;
                        end

                            
                    else if (tx_o_set == `OS_D) begin
                            PUDR = `D06_5_10b;  
                            nxt_state = DATA_G0;
                        end

                    else if (tx_o_set == `OS_D) begin
                            PUDR = `D21_5_10b;  
                            nxt_state = DATA_G0;
                        end       
                                   
                            
                    else if (tx_o_set == `OS_D) begin
                            PUDR = `D05_6_10b; 
                            nxt_state = DATA_G0;
                        end*/
                    
                    else 
                    begin
                        TX_OSET_indicate = `TRUE;
                        tx_even = !tx_even;
                        
                        if (tx_o_set == `OS_R)
                            PUDR = `K23_7_10b; // /R/

                        if (tx_o_set == `OS_S)
                            PUDR = `K27_7_10b; // /S/

                        if (tx_o_set == `OS_T)
                            PUDR = `K29_7_10b; // /T/

                        if (tx_o_set == `OS_V)
                            PUDR = `K30_7_10b; // /V/

                        if (tx_o_set == `OS_D)
                            PUDR = TXD_encoded; 
                    end
                end

               /* //DATA_GO
                DATA_G0: begin
                    PUDR = TXD_encoded;
                    TX_OSET_indicate = `TRUE;
                    tx_even = !tx_even;
                end*/

                // IDLE_I2B
                IDLE_I2B: begin
                    tx_even = `FALSE;
                    TX_OSET_indicate = `TRUE;
                    PUDR = `D16_2_10b; // /D16.2/
                    nxt_state = GENERATE_CODE_GROUPS;
                end

                default : nxt_state = GENERATE_CODE_GROUPS;
            endcase
        end
    endmodule

//Modulo para instanciar transmit ordered set y transmit code-group
    //O sea se unen ambas maquinas de estados
    module TRANSMIT (
        input mr_main_reset,
        input GTX_CLK,
        input [7:0] TXD,
        input TX_EN,
        input TX_ER,
        input receiving,
        input [2:0] xmit,
        output COL,
        output transmitting,
        output [9:0] PUDR);


        // variables internas de TX
        wire TX_OSET_indicate;
        wire [6:0] tx_o_set;
        wire tx_even;

        TRANSMIT_OS ordered_set (
            // entradas de TX ordered set
            .mr_main_reset(mr_main_reset),
            .GTX_CLK(GTX_CLK),
            .TXD(TXD[7:0]),
            .TX_EN(TX_EN),
            .TX_ER(TX_ER),
            .tx_even(tx_even),
            .receiving(receiving),
            .TX_OSET_indicate(TX_OSET_indicate),
            .xmit(xmit[2:0]),

            // salidas de TX ordered set
            .tx_o_set(tx_o_set),
            .COL(COL),
            .transmitting(transmitting)
        );

        TRANSMIT_CG code_group (
            // entradas de TX code group
            .mr_main_reset(mr_main_reset),
            .GTX_CLK(GTX_CLK),
            .tx_o_set(tx_o_set),
            .TXD(TXD[7:0]),

            // salidas de TX code group
            .tx_even(tx_even),
            .TX_OSET_indicate(TX_OSET_indicate),
            .PUDR(PUDR[9:0])
        );
    endmodule