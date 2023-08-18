// Declaración del módulo y parámetros
module probador (CLK,Reset,Tarjeta_recibida,PIN,Digito,Digito_STB,Tipo_trans,Monto,Monto_STB,
               Balance_actualizado,Entregar_dinero,Fondos_insuficientes,PIN_incorrecto,Advertencia,Bloqueo 
               );
    // Declaración de entradas y salidas
    output reg CLK,Reset,Tarjeta_recibida,Digito_STB,Tipo_trans,Monto_STB;
    output reg [3:0] Digito;
    output reg [15:0] PIN;
    output reg [31:0] Monto;
    input Balance_actualizado,Entregar_dinero,Fondos_insuficientes,PIN_incorrecto,Advertencia,Bloqueo;

    initial begin
        //Se inician las variables para la prueba
        CLK = 0;
        Reset = 0;
        Monto = 0;
        Monto_STB = 0;
        Tarjeta_recibida = 0;

        //Se resetea el cajero
        #25 Reset = 1;
        #15 Reset = 0;
        
        //Se introduce la tarjeta
        #10 Tarjeta_recibida = 1;
        
        //Se carga el PIN
        #10 PIN = 16'b1111000000000000;

        //Se teclean los digitos del PIN
        
        //Prueba#1: 
        //primer PIN incorrecto
        #10 Digito = 4'b1000;
        #10 Digito_STB = 1;
        #10 Digito_STB = 0;
        #10 Digito = 4'b0000;
        #10 Digito_STB = 1;
        #10 Digito_STB = 0;
        #10 Digito = 4'b0000;
        #10 Digito_STB = 1;
        #10 Digito_STB = 0;
        #10 Digito = 4'b0000;
        #10 Digito_STB = 1;
        #10 Digito_STB = 0;

        //segundo PIN incorrecto
        #10 Digito = 4'b0100;
        #10 Digito_STB = 1;
        #10 Digito_STB = 0;
        #10 Digito = 4'b0000;
        #10 Digito_STB = 1;
        #10 Digito_STB = 0;
        #10 Digito = 4'b0000;
        #10 Digito_STB = 1;
        #10 Digito_STB = 0;
        #10 Digito = 4'b0000;
        #10 Digito_STB = 1;
        #10 Digito_STB = 0;

        //tercer PIN incorrecto
        #10 Digito = 4'b0010;
        #10 Digito_STB = 1;
        #10 Digito_STB = 0;
        #10 Digito = 4'b0000;
        #10 Digito_STB = 1;
        #10 Digito_STB = 0;
        #10 Digito = 4'b0000;
        #10 Digito_STB = 1;
        #10 Digito_STB = 0;
        #10 Digito = 4'b0000;
        #10 Digito_STB = 1;
        #10 Digito_STB = 0;

        //Se resetea para salir del bloqueo
        #25 Reset = 1;
        #15 Reset = 0;
        
        
        //Prueba#2
        //PIN correcto
        #10 Digito = 4'b1111;
        #10 Digito_STB = 1;
        #10 Digito_STB = 0;
        #10 Digito = 4'b0000;
        #10 Digito_STB = 1;
        #10 Digito_STB = 0;
        #10 Digito = 4'b0000;
        #10 Digito_STB = 1;
        #10 Digito_STB = 0;
        #10 Digito = 4'b0000;
        #10 Digito_STB = 1;
        #10 Digito_STB = 0;

        //Se relecciona hacer un deposito
        #10 Tipo_trans = 0;
        #10 Monto = 32'b111111;//se introduce el monto
        #10 Monto_STB = 1;//Señal para actualizar el monto
        #10 Monto_STB = 0;

        //Se selecciona hacer un retiro, con un monto menor al balance
        #10 Tipo_trans = 1;
        #10 Monto = 32'b011111;
        #10 Monto_STB = 1;
        #10 Monto_STB = 0;

        //Se selecciona hacer un retiro, con un monto mayor al balance
        #10 Tipo_trans = 1;
        #10 Monto = 32'b111111;
        #10 Monto_STB = 1;
        #10 Monto_STB = 0;


        #30 $finish;
    end

    always begin
        #5 CLK = !CLK;
    end
endmodule