`include "tablas.v"

// Definición de constantes
`define TRUE    1'b1
`define FALSE   1'b0

// Módulo signal_detectCHANGE para detectar cambios en la señal detectada
module signal_detectCHANGE (
    input clk,                  // Señal de reloj
    input signal_detect,        // Señal detectada actual
    output reg Signal_detectCHANGE); // Indicador de cambio en la señal detectada

    reg anterior_signal_detect;  // Señal detectada anterior
    
    always @(posedge clk) begin
        anterior_signal_detect <= signal_detect; // Actualizar la señal detectada anterior
    end
    
    always @(*) begin
        if (signal_detect == anterior_signal_detect)
            Signal_detectCHANGE = `FALSE; // No hay cambio en la señal detectada
        else
            Signal_detectCHANGE = `TRUE;  // Se ha producido un cambio en la señal detectada
    end
endmodule

module SYNCHRONIZATION (clk, mr_main_reset, mr_loopback, signal_detect, PUDI,
                        SUDI, code_sync_status, rx_even);
    input clk;                      // Entrada de reloj
    input mr_main_reset;            // Señal de reset principal
    input mr_loopback;              // Señal de bucle de retroalimentación
    input signal_detect;            // Señal de detección de señal
    input [9:0] PUDI;               // Código de grupo de 10 bits proveniente del receptor
    output reg [9:0] SUDI;          // Código de grupo de 10 bits sincronizado
    output reg code_sync_status;    // Estado de sincronización del código
    output reg rx_even;             // Indicador de paridad del código recibido

    signal_detectCHANGE sd_C (
        .clk(clk),
        .signal_detect(signal_detect),
        .Signal_detectCHANGE(Signal_detectCHANGE)
    );

    // Estados de la máquina de estados
    localparam LOSS_OF_SYNC     = 0; // Pérdida de sincronización
    localparam COMMA_DETECT_1   = 1; // Detección de coma 1
    localparam ACQUIRE_SYNC_1   = 2; // Adquisición de sincronización 1
    localparam COMMA_DETECT_2   = 3; // Detección de coma 2
    localparam ACQUIRE_SYNC_2   = 4; // Adquisición de sincronización 2
    localparam COMMA_DETECT_3   = 5; // Detección de coma 3
    localparam SYNC_ACQUIRED_1  = 6; // Sincronización adquirida 1


    wire Signal_detectCHANGE;       // Señal de cambio de detección de señal
    reg [12:0] estado, proximo_estado; // Estado actual y próximo estado de la máquina de estados
    reg COMMA_DETECT;               // Indicador de detección de coma
    reg PUDI_D;                     // Indicador de presencia de D en el código de grupo
    reg PUDI_K;                     // Indicador de presencia de K en el código de grupo
    reg PUDI_coma;                  // Indicador de presencia de coma en el código de grupo
    reg cgbad;                      // Indicador de código de grupo no válido
    reg cggood;                     // Indicador de código de grupo válido

	always @(posedge clk) begin
		// Si hay un reset principal activado o hay un cambio en la detección de señal
		// y el bucle de retroalimentación no está habilitado
		if (!mr_main_reset || (Signal_detectCHANGE && !mr_loopback)) begin
			estado = LOSS_OF_SYNC; // Cambia al estado de pérdida de sincronización
			code_sync_status = `FALSE; // Desactiva la sincronización de código
			rx_even = `FALSE; // Reinicia la variable de paridad de recepción a FALSE
		end
		else begin
			SUDI <= PUDI; // Actualiza el valor de SUDI con el valor de PUDI
			estado = proximo_estado; // Actualiza el estado actual con el próximo estado calculado
			if (COMMA_DETECT) begin // Si se detecta una coma en el código de grupo recibido
				rx_even = `TRUE; // Establece la paridad de recepción en TRUE
			end
			else begin
				rx_even = !rx_even; // Invierte el valor de la paridad de recepción
			end
		end
	end


	always @(*) begin
		// Evaluación de PUDI para determinar si es D
		case (PUDI)
			`D00_0_10b: PUDI_D = `TRUE;     // PUDI corresponde a D00_0_10b
			`D01_0_10b: PUDI_D = `TRUE;     // PUDI corresponde a D01_0_10b
			`D02_0_10b: PUDI_D = `TRUE;     // PUDI corresponde a D02_0_10b
			`D03_0_10b: PUDI_D = `TRUE;     // PUDI corresponde a D03_0_10b
			`D02_2_10b: PUDI_D = `TRUE;     // PUDI corresponde a D02_2_10b
			`D16_2_10b: PUDI_D = `TRUE;     // PUDI corresponde a D16_2_10b
			`D26_4_10b: PUDI_D = `TRUE;     // PUDI corresponde a D26_4_10b
			`D06_5_10b: PUDI_D = `TRUE;     // PUDI corresponde a D06_5_10b
			`D21_5_10b: PUDI_D = `TRUE;     // PUDI corresponde a D21_5_10b
			`D05_6_10b: PUDI_D = `TRUE;     // PUDI corresponde a D05_6_10b
			default: PUDI_D = `FALSE;       // PUDI no corresponde a ninguna opción de D
		endcase

		// Evaluación de PUDI para determinar si es K
		case (PUDI)
			`K28_0_10b: PUDI_K = `TRUE;     // PUDI corresponde a K28_0_10b
			`K28_1_10b: PUDI_K = `TRUE;     // PUDI corresponde a K28_1_10b
			`K28_2_10b: PUDI_K = `TRUE;     // PUDI corresponde a K28_2_10b
			`K28_3_10b: PUDI_K = `TRUE;     // PUDI corresponde a K28_3_10b
			`K28_4_10b: PUDI_K = `TRUE;     // PUDI corresponde a K28_4_10b
			`K28_5_10b: PUDI_K = `TRUE;     // PUDI corresponde a K28_5_10b
			`K28_6_10b: PUDI_K = `TRUE;     // PUDI corresponde a K28_6_10b
			`K28_7_10b: PUDI_K = `TRUE;     // PUDI corresponde a K28_7_10b
			`K23_7_10b: PUDI_K = `TRUE;     // PUDI corresponde a K23_7_10b
			`K27_7_10b: PUDI_K = `TRUE;     // PUDI corresponde a K27_7_10b
			`K29_7_10b: PUDI_K = `TRUE;     // PUDI corresponde a K29_7_10b
			`K30_7_10b: PUDI_K = `TRUE;     // PUDI corresponde a K30_7_10b
			default: PUDI_K = `FALSE;       // PUDI no corresponde a ninguna opción de K
		endcase

		// Evaluación de PUDI para determinar si es coma
		case (PUDI)
			`K28_1_10b: PUDI_coma = `TRUE;  // PUDI corresponde a K28_1_10b
			`K28_5_10b: PUDI_coma = `TRUE;  // PUDI corresponde a K28_5_10b
			`K28_7_10b: PUDI_coma = `TRUE;  // PUDI corresponde a K28_7_10b
			default: PUDI_coma = `FALSE;    // PUDI no corresponde a ninguna opción de coma
		endcase

		// Evaluación de condiciones para determinar el valor de cgbad
		if ((!(PUDI_D || PUDI_K)) || (PUDI_coma && rx_even)) begin
			cgbad = `TRUE;                   // Se cumple alguna de las condiciones para cgbad
			cggood = `FALSE;                 // cgbad es verdadero, por lo tanto cggood es falso
		end
		else begin
			cgbad = `FALSE;                  // No se cumple ninguna de las condiciones para cgbad
			cggood = `TRUE;                  // cgbad es falso, por lo tanto cggood es verdadero
		end

		// Evaluación del estado para determinar si COMMA_DETECT es verdadero
		if ((estado == COMMA_DETECT_1) || (estado == COMMA_DETECT_2) || (estado == COMMA_DETECT_3)) begin
			COMMA_DETECT = `TRUE;            // El estado coincide con uno de los estados de COMMA_DETECT
		end


		proximo_estado = estado; // El próximo estado se inicializa con el estado actual

		case(estado)
			LOSS_OF_SYNC: begin
				code_sync_status <= `FALSE; // Se establece el estado de sincronización del código en FALSO
				if (!PUDI_coma || (!signal_detect && !mr_loopback)) begin
					proximo_estado = LOSS_OF_SYNC; // Permanecer en el estado de pérdida de sincronización
				end
				else if (PUDI_coma && (signal_detect || mr_loopback)) begin
					proximo_estado = COMMA_DETECT_1; // Ir al estado de detección de coma 1
				end
			end
			COMMA_DETECT_1: begin
				if (PUDI_D) begin
					proximo_estado = ACQUIRE_SYNC_1; // Ir al estado de adquisición de sincronización 1
				end
				else
					proximo_estado = LOSS_OF_SYNC; // Volver al estado de pérdida de sincronización
			end
			ACQUIRE_SYNC_1: begin
				//COMMA_DETECT = `FALSE;
				if (rx_even && PUDI_coma) begin
					proximo_estado = COMMA_DETECT_2; // Ir al estado de detección de coma 2
				end
				else if (!PUDI_coma && (PUDI_D || PUDI_K)) begin
					proximo_estado = ACQUIRE_SYNC_1; // Permanecer en el estado de adquisición de sincronización 1
				end
				else if (cgbad) begin
					proximo_estado = LOSS_OF_SYNC; // Volver al estado de pérdida de sincronización
				end
			end
			COMMA_DETECT_2: begin
				if (PUDI_D) begin
					proximo_estado = ACQUIRE_SYNC_2; // Ir al estado de adquisición de sincronización 2
				end
				else
					proximo_estado = LOSS_OF_SYNC; // Volver al estado de pérdida de sincronización
			end
			ACQUIRE_SYNC_2: begin
				//COMMA_DETECT = `FALSE;
				if (rx_even && PUDI_coma) begin
					proximo_estado = COMMA_DETECT_3; // Ir al estado de detección de coma 3
				end
				else if (!PUDI_coma && (PUDI_D || PUDI_K)) begin
					proximo_estado = ACQUIRE_SYNC_2; // Permanecer en el estado de adquisición de sincronización 2
				end
				else if (cgbad) begin
					proximo_estado = LOSS_OF_SYNC; // Volver al estado de pérdida de sincronización
				end
			end
			COMMA_DETECT_3: begin
				if (PUDI_D) begin
					proximo_estado = SYNC_ACQUIRED_1; // Ir al estado de sincronización adquirida 1
				end
				else
					proximo_estado = LOSS_OF_SYNC; // Volver al estado de pérdida de sincronización
			end
			SYNC_ACQUIRED_1: begin
				code_sync_status = `TRUE; // Se establece el estado de sincronización del código en VERDADERO
				if (cggood) begin
					proximo_estado = SYNC_ACQUIRED_1; // Permanecer en el estado de sincronización adquirida 1
				end
			end
			default: 
					proximo_estado = LOSS_OF_SYNC; // Volver al estado de pérdida de sincronización si no se cumple ninguna condición anterior
		endcase
	end
endmodule