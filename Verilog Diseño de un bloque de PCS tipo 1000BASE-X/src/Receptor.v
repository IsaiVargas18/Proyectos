`include "tablas.v"
`define TRUE  1'b1
`define FALSE 1'b0

///////////////// DECODE 36.2.5.1.4 Functions /////////////////
    // Módulo para decodificar los grupos de códigos
    module DECODE (
        input [9:0] code_group_10b_recibido,
        output reg [7:0] code_group_8b
    );

    always @(code_group_10b_recibido) begin
        //valid code-groups
        if (code_group_10b_recibido == `D00_0_10b)
            code_group_8b = `D00_0_08b; // D0.0
        else if (code_group_10b_recibido == `D01_0_10b)
            code_group_8b = `D01_0_08b; // D1.0
        else if (code_group_10b_recibido == `D02_0_10b)
            code_group_8b = `D02_0_08b; // D2.0
        else if (code_group_10b_recibido == `D03_0_10b)
            code_group_8b = `D03_0_08b; // D3.0
        else if (code_group_10b_recibido == `D02_2_10b)
            code_group_8b = `D02_2_08b; // D2.2
        else if (code_group_10b_recibido == `D16_2_10b)
            code_group_8b = `D16_2_08b; // D16.2
        else if (code_group_10b_recibido == `D26_4_10b)
            code_group_8b = `D26_4_08b; // D26.4
        else if (code_group_10b_recibido == `D06_5_10b)
            code_group_8b = `D06_5_08b; // D6.5
        else if (code_group_10b_recibido == `D21_5_10b)
            code_group_8b = `D21_5_08b; // D21.5
        else if (code_group_10b_recibido == `D05_6_10b)
            code_group_8b = `D05_6_08b; // D05.6

        //special code-groups
        else if (code_group_10b_recibido == `K28_0_10b)
            code_group_8b = `K28_0_08b; // K28.0
        else if (code_group_10b_recibido == `K28_1_10b)
            code_group_8b = `K28_1_08b; // K28.1
        else if (code_group_10b_recibido == `K28_2_10b)
            code_group_8b = `K28_2_08b; // K28.2
        else if (code_group_10b_recibido == `K28_3_10b)
            code_group_8b = `K28_3_08b; // K28.3
        else if (code_group_10b_recibido == `K28_4_10b)
            code_group_8b = `K28_4_08b; // K28.4
        else if (code_group_10b_recibido == `K28_5_10b)
            code_group_8b = `K28_5_08b; // K28.5
        else if (code_group_10b_recibido == `K28_6_10b)
            code_group_8b = `K28_6_08b; // K28.6
        else if (code_group_10b_recibido == `K28_7_10b)
            code_group_8b = `K28_7_08b; // K28.7
        else if (code_group_10b_recibido == `K23_7_10b)
            code_group_8b = `K23_7_08b; // K23.7 /R/
        else if (code_group_10b_recibido == `K27_7_10b)
            code_group_8b = `K27_7_08b; // K27.7 /S/
        else if (code_group_10b_recibido == `K29_7_10b)
            code_group_8b = `K29_7_08b; // K29.7 /T/
        else if (code_group_10b_recibido == `K30_7_10b)
            code_group_8b = `K30_7_08b; // K30.7 /V/
	end
	endmodule

///////////////// RECEPTOR /////////////////
	module RECEIVE (
		input mr_main_reset, clk, rx_even,
		input [9:0] SUDI,
		input [2:0] xmit,
		output reg RX_DV, RX_ER, receiving, RX_CLK,
        output reg [7:0] RXD );

    //ESTADOS
	localparam WAIT_FOR_K          = 0;
	localparam RX_K                = 1;
	localparam IDLE_D              = 2;
    localparam xmit_DATA           = 3'b010;
    localparam START_OF_PACKET     = 3;
    localparam RECEIVE             = 4; 
	
    //variables internas
		reg [6:0] state;
		reg [6:0] nxt_state;
		reg [9:0] SUDI_XOR_COMMA;
        reg [3:0] i;
        reg [3:0] acumulador = 0;
        reg [3:0] carrier_detect;
        reg SUDI_D;
		wire [7:0] code_group_8b;

        // Para la parte b del receptor
        reg [2:0] preamble_octet;
        reg [19:0] check_end;
        reg [2:0] preamble_octet_new; 

		//DECODE(X)
		DECODE decoding (
			.code_group_10b_recibido(SUDI), 
			.code_group_8b(code_group_8b)
		);

		always @(posedge clk) begin
			if (!mr_main_reset) begin
				state = WAIT_FOR_K;
				RX_CLK = 0;
				RX_DV = `FALSE;
				RX_ER = `FALSE;
				RXD = 8'h00;
                preamble_octet = 3'h0;
                check_end = 20'h0; 
			end
			else begin
				state <= nxt_state;
				RX_CLK <= !RX_CLK;
                check_end <= {check_end[9:0], SUDI}; // Usado para detectar estado de terminacion /T/R/K28.5/
                preamble_octet_new <= preamble_octet + 3'h1; 
			end
		end

		always @(*) begin

        case (SUDI)
            `D00_0_10b: SUDI_D = `TRUE;
            `D01_0_10b: SUDI_D = `TRUE;
            `D02_0_10b: SUDI_D = `TRUE;
            `D03_0_10b: SUDI_D = `TRUE;
            `D02_2_10b: SUDI_D = `TRUE;
            `D16_2_10b: SUDI_D = `TRUE;
            `D26_4_10b: SUDI_D = `TRUE;
            `D06_5_10b: SUDI_D = `TRUE;
            `D21_5_10b: SUDI_D = `TRUE;
            `D05_6_10b: SUDI_D = `TRUE;
            default: SUDI_D = `FALSE;
        endcase		

		//PCS receive state
        nxt_state = state;
		case(state)
			// WAIT_FOR_K
			WAIT_FOR_K: begin
				receiving = `FALSE;
				RX_DV = `FALSE;
				RX_ER = `FALSE;
				if  (SUDI == `K28_5_10b && rx_even) begin //SUDI([/K28.5/] * EVEN)
                    nxt_state = RX_K; 
                end
			end
			
			// RX_K
			RX_K: begin
				receiving = `FALSE;
				RX_DV = `FALSE;
				RX_ER = `FALSE;
				RXD = 0;
				if ((xmit != xmit_DATA && SUDI_D && (SUDI != `D21_5_10b && SUDI != `D02_2_10b)) ||
					(xmit == xmit_DATA && (SUDI != `D21_5_10b && SUDI != `D02_2_10b))) begin 
					nxt_state = IDLE_D;
                end
			end

			// IDLE_D
			IDLE_D: begin
				SUDI_XOR_COMMA = SUDI ^ `K28_5_10b;

                // CARRIER_DETECT
                /* 
                La función carrier_detect detecta el operador cuando:
                    a) Existe una diferencia de dos o más bits entre [/x/] y ambas codificaciones /K28.5/
                    b) Existe una diferencia de dos a nueve bits entre [/x/] y el /K28.5/ esperado.
                    Valores: VERDADERO; Se detecta portador.
                    FALSO; No se detecta el portador. 
                */
                // Cálculo de la suma de bits
                for (i = 0; i < 9; i = i + 1) begin
                    acumulador = acumulador + SUDI_XOR_COMMA[i];
                end
                carrier_detect = acumulador;

				if ((xmit == xmit_DATA && carrier_detect < 2) || SUDI == `K28_5_10b) begin
					nxt_state = RX_K;
                end

				else if (xmit == xmit_DATA && carrier_detect >= 2) begin
					receiving = `TRUE;

					if (SUDI == `K27_7_10b) begin 
						nxt_state = START_OF_PACKET;
                    end
				end

				// FALSE_CARRIER
				else begin
					RX_ER = `TRUE;
					RXD = 8'b00001110;
						
					if (SUDI == `K28_5_10b && rx_even) begin
						nxt_state = RX_K;
                    end
				end
			end

			// Estados de START_OF_PACKET
			START_OF_PACKET: begin
				preamble_octet = preamble_octet_new;
				RX_DV = `TRUE;
				RXD =  7'h55; // Estipulado por la clausula, 0101 01010

				if (preamble_octet == 3'h7) begin 
					nxt_state = RECEIVE;
					preamble_octet = 3'h0;
				end
			end

			// Estados de RECEIVE
			RECEIVE: begin
                // Como no hay errores, se siguen mandando datos hasta se que se reciba la secuencia de terminacion que es /T/R/K28.5/
					// RX_DATA
					if (SUDI_D)
						RXD = code_group_8b;

					// TRI + RRI
					if (check_end == {`K29_7_10b, `K23_7_10b} && SUDI == `K28_5_10b && rx_even)
						nxt_state = RX_K; // Volver al receptor parte a
			end

			default: nxt_state = WAIT_FOR_K;
		endcase
		end
    endmodule