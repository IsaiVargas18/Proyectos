module cajero (CLK,Reset,Tarjeta_recibida,PIN,Digito,Digito_STB,Tipo_trans,Monto,Monto_STB,
               Balance_actualizado,Entregar_dinero,Fondos_insuficientes,PIN_incorrecto,Advertencia,Bloqueo
            );
    input CLK,Reset,Tarjeta_recibida,Digito_STB,Tipo_trans,Monto_STB;
    input [3:0] Digito;
    input [15:0] PIN;
    input [31:0] Monto;

    output reg Balance_actualizado,Entregar_dinero,Fondos_insuficientes,PIN_incorrecto,Advertencia,Bloqueo;


    // Estados
    parameter ESPERA_TARJETA = 3'b000; //valor que representa el estado inicial de la máquina de estados (000).
    parameter VERIFICACION_PIN = 3'b001; //valor que representa el estado en el que se verifica el número PIN ingresado (001).
    parameter SELECCION_TRANSACCION = 3'b010; //valor que representa el estado en el que se selecciona el tipo de transacción a realizar (010).
    parameter DEPOSITO = 3'b011; //valor que representa el estado en el que se realiza una transacción de depósito (011).
    parameter RETIRO = 3'b100; //valor que representa el estado en el que se realiza una transacción de retiro (100).
    parameter BLOQUEADO = 3'b101; //valor que representa el estado en el que la tarjeta ha sido bloqueada (101).


    // Declaración de los registros internos
    reg [63:0] Balance; //registro de 64 bits que representa el balance actual del usuario.
    integer intentos_pin; //registro de enteros que lleva la cuenta de los intentos de PIN incorrectos.


    // Declaración de las señales internas
    reg [15:0] PIN_teclado; //registro de 16 bits que almacena el número PIN ingresado por el usuario en el teclado.


    // Definición de la máquina de estados
    reg [2:0] estado_actual;
    reg [2:0] estado_prox;

    always @ (posedge CLK) begin
            //Con en Reset se envian todos los valores a 0
            if (Reset) begin
                estado_actual        <= ESPERA_TARJETA;
                Balance_actualizado  <= 1'b0;
                Entregar_dinero      <= 1'b0;
                Fondos_insuficientes <= 1'b0;
                PIN_incorrecto       <= 1'b0;
                Advertencia          <= 1'b0;
                Bloqueo              <= 1'b0;
                PIN_teclado          <= 16'b0;
                Balance              <= 64'b0;
                intentos_pin         = 0;
            end
            else begin
                estado_actual <= estado_prox;
                //Registro desplazante para guardar los digetos del PIN
                if (Digito_STB) begin
                    PIN_teclado[3:0] <= Digito;
                    PIN_teclado[7:4] <= PIN_teclado[3:0];
                    PIN_teclado[11:8] <= PIN_teclado[7:4];
                    PIN_teclado[15:12] <= PIN_teclado[11:8];   
                end
            end
    end
               
    //Definir lógica combinacional
    //Case de los estados
    always @ (*) begin
        case (estado_actual)
            //Se inicia esperando la tarjeta, si se recibe esta se pasa a verificar el PIN
            ESPERA_TARJETA: begin
                if (Tarjeta_recibida) begin
                    estado_prox <= VERIFICACION_PIN;
                end
                else estado_prox <= ESPERA_TARJETA;
            end
            VERIFICACION_PIN: begin
                //si el PIN es incorrecto se levanta la señal y se aumenta en 1 el numero de intentos  
                if (PIN_teclado != PIN) begin
                    PIN_incorrecto <= 1'b1;
                    intentos_pin = intentos_pin + 1;
                //Dado que el PIN_teclado se actualiza 4 veces, una con cada vez que se ingresa un digito
                //se tiene que si se introdujo 8 veces mal los digitos del pin se levanta la advertencia
                if (intentos_pin == 8) begin
                    Advertencia <= 1'b1;
                    estado_prox <= VERIFICACION_PIN;
                end
                //se tiene que si se introdujo 12 veces mal los digitos del pin se levanta el bloqueo
                //ademas se va al estado de bloqueado
                if (intentos_pin == 12) begin
                    Bloqueo <= 1'b1;
                    estado_prox <= BLOQUEADO;
                end end
                //Si se introduce bien el pin se pasa al estado se seleccion de transaccion
                if (PIN_teclado == PIN) begin
                    PIN_incorrecto <= 1'b0;
                    estado_prox <= SELECCION_TRANSACCION;
                end 
                //else estado_prox <= VERIFICACION_PIN;
            end

            BLOQUEADO: begin
                // en este estado de bloqueo solo se puede salir utilizando la señal de reset
                if (Reset == 0) begin
                    if (Reset == 1) begin
                        estado_prox <= ESPERA_TARJETA;
                    end
                end
                else estado_prox <= BLOQUEADO;
            end

            SELECCION_TRANSACCION: begin
                //Si Tipo_trans = 0, se va al estado de deposito
                if (Tipo_trans == 0) begin
                    estado_prox <= DEPOSITO;
                end
                //Si Tipo_trans = 1, se va al estado de retiro
                else if (Tipo_trans == 1) begin
                    estado_prox <= RETIRO;
                end
                else estado_prox <= SELECCION_TRANSACCION;
            end

            DEPOSITO: begin
                //Si se tiene la señal de Monto_STB se actualiza el balance
                if (Monto_STB == 1) begin
                    Balance = Balance + Monto;
                    Balance_actualizado <= 1'b1;
                    estado_prox <= SELECCION_TRANSACCION;
                end
                else begin
                    Balance_actualizado = 1'b0;
                    estado_prox <= SELECCION_TRANSACCION;
                end
            end
            RETIRO: begin
                //Si se tiene la señal de Monto_STB y Monto <= Balance  se actualiza el balance y se da el dinero
                if (Monto_STB == 1) begin
                    if (Monto <= Balance) begin
                        Balance = Balance - Monto;
                        Balance_actualizado = 1'b1;
                        Entregar_dinero = 1'b1;
                        estado_prox <= SELECCION_TRANSACCION;
                    end 
                    //Si se tiene la señal de Monto_STB y Monto > Balance se activa Fondos_insuficientes
                    else begin
                        Fondos_insuficientes <= 1'b1;
                        Balance_actualizado = 1'b0;
                        Entregar_dinero = 1'b0;
                        estado_prox <= SELECCION_TRANSACCION;
                    end
                end
                else begin
                    Balance_actualizado = 1'b0;
                    estado_prox <= SELECCION_TRANSACCION;
                end
                
            end
            default: begin
                estado_prox <= ESPERA_TARJETA;
            end
        endcase
    end
endmodule