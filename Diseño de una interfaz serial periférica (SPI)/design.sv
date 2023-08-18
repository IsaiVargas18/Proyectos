module SPI_Master_Transmitter(clk,reset,sck,cs,mosi,miso,ckp,cph,data1);
    parameter data_length =8;
	
  	//entradas y salidas del modulo transmisor
    input clk;
    input reset;
    input miso;
    input ckp,cph;
    output reg sck=0;
    output reg cs =1;
    output reg mosi=0;
    output reg[data_length-1:0] data1;

	
  	//Parametros para los estados
    localparam RDY=2'b00; 
    localparam START =2'b01;
    localparam TRANSMIT=2'b10;
    localparam STOP=2'b11;

    reg [1:0] state = RDY;
    reg [7:0] clkdiv = 0;
    reg [data_length-1:0] data_temp=0;
    

    reg[7:0] index=data_length-1;
  	reg[7:0] carne=8'b00001000; //numero 8 del carne
    
    reg previous_clk;
  	reg previous_ckp;
  	reg previous_cph;

  /*always @(posedge clk) begin
        // Almacenar los valores anteriores de clk, ckp y cph
        previous_clk <= clk;
        previous_ckp <= ckp;
        previous_cph <= cph;

    // Generar la señal de reloj sck de acuerdo con las especificaciones
    
        if (previous_clk == 1'b0 && clk == 1'b1) begin
            if (previous_ckp == 1'b0) begin
                if (previous_cph == 1'b0)
                    sck <= 1'b1; // Transición en flanco creciente
                else
                    sck <= 1'b0; // Transición en flanco decreciente
            end
            else begin
                if (previous_cph == 1'b0)
                    sck <= 1'b0; // Transición en flanco creciente
                else
                    sck <= 1'b1; // Transición en flanco decreciente
            end
        end
    end*/
  
  
  	// Generar la señal de reloj sck de acuerdo con las especificaciones de 25%
    always @ (posedge clk) begin
            if(clkdiv == 8'd3) begin
                clkdiv<=0;
                sck<= ~sck;
            end
            else clkdiv <= clkdiv + 1;   
    end

    
	//segun el flanco de sck dado se cambia de un estado a otro
    always @(sck) begin
        case(state)
          	//estado inicial idle, se pasa al siguiente estado si se tiene un reset
            RDY:
                begin
                    if(reset==1) begin
                        state <= START;
                        index <= data_length-1;
                    end
                    else begin
                        //state <= RDY;
                        cs <= 0;
                        mosi <= 0;
                        sck <= 0;
                    end
                end
          	//Estado de iniciar, se inicia la transmision
            START:
                begin
                    cs <= 0;
                    mosi <= carne[index];
                    index <= index-1;
                    state <= TRANSMIT;
                end
			//Se transmiten los demas digitos del primer numero a transmitir
            TRANSMIT:
                begin
                  if(index==0) begin //cuando se transmite el primer numero se cambia el numero a transmitir
                        mosi<=carne[index];
                        state <=STOP;
                        carne=8'b00000010; //Se cambia a transmitir el 2 del carne

                    end
                    else begin
                      mosi<=carne[index];//Se transmite in bit a la vez por mosi
                        
                        index <= index-1;
                      data_temp[index] <= miso;//Se recibe un bit a la vez por miso
                        
                    end
                end
			//Se detiene la transmision
            STOP:
                begin
                    data1 <= data_temp;//Se agregan los numeros obtenidos a travez de mosi a una salida
                    //Se reinician las variables temporales para recibir y transmitir el siguiente numero
                  	data_temp <= 0;
                    index <= data_length-1;
                    cs <= 1;
                    state <= RDY;
                end
        endcase
    end
endmodule

module SPI_Slave_receiver(sck,ss,mosi,miso,data);

    parameter data_length=8;
  	//entradas y salidas del modulo
    input sck;
    input ss;
    input mosi;
    output reg miso=0;
    output reg[data_length-1:0] data;

	//parametros para los estados
    localparam RDY=2'b00; 
    localparam START =2'b01;
    localparam RECEIVE=2'b10;
    localparam STOP=2'b11;

    reg[1:0] state=RDY;
    reg [data_length-1:0] data_temp=0;
    reg[7:0] index=data_length-1;
  	reg[7:0] carne=8'b00000110; //numero 6 del carne

    always@(sck) begin
        case(state)
            RDY:
              	if(!ss)//Se empieza a recibir los digitos solo si se tiene la senal cs o ss
                    begin
                        data_temp[index]<= mosi;
                        index <= index - 1;
                        state <= RECEIVE;
                    end
            START:
                begin
                  	miso <= carne[index];//Se inicia la transmision
                    index <= index-1;
                    state <= RECEIVE;
                end
            RECEIVE:        
                    begin
                        if(index==0) begin
                            state <= STOP;
                        end
                        else 
                          	miso<=carne[index];//Se transmiten los demas digitos
                            index <= index-1;
                      	data_temp[index] <= mosi;//Se reciben los digitos
                    end
            STOP:
                    begin
                        data <= data_temp;//Una vez recibidos todos los digitos se pasa al siguiente numero
                        data_temp <= 0;
                        carne=8'b00000011;//se cambia a transmitir el numero 3 del carne
                        index <= data_length-1;
                        state <= RDY;
                    end
        endcase
    end
endmodule



