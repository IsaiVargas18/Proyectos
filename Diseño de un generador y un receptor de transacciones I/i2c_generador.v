`timescale 1ns / 1ps
module i2c_generador(
	//Se definen los inputs y auputs segun el enunciado
	input wire clk,
	input wire reset,
	input wire start_stb,
	input wire rnw, // inducacion de si se va a leer o escribir
	input wire [6:0] i2c_addr1, //dirreccion del receptor al que se quiere enviar
	input sda_in, //sda de receptor a generador
	input wire [15:0] wr_data, //salida del receptor, data que se debe escribir

	output wire scl,//Reloj a 25%
	output sda_out,//salida de generador
	output reg sda_oe,// inducacion de quien controla el bus
	output reg [15:0] rd_data //salida del generador, data que se debe leer
	);

	//Se instancian algunos parametros para los estados
	localparam IDLE = 0;//estado de reposo
	localparam START = 1;//estado de inicio
	localparam ADDRESS = 2;//estado de envio de la direccion
	localparam READ_ACK = 3;//estado de lectura de A
	localparam WRITE_DATA = 4;//estado de escritura
	localparam WRITE_ACK = 5;//estado de escritura de A
	localparam READ_DATA = 6;//estado de lectura
	localparam READ_ACK2 = 7;//estado de lectura del segundo A
    localparam WRITE_ACK2 = 8;//estado de escritura del se segundo A
	localparam STOP = 9;// estado de parada

	localparam DIVIDE_BY = 4;//varibale para la division del clk

	reg byte_counter=0;//contador del byte de datos que se esta enviando o recibiendo
	reg sda_o;//salida de sda
	reg scl_enable = 0;// habilitador de scl
	reg i2c_clk = 1;// reloj a 25%
	reg [7:0] state;// registro de estado
	reg [7:0] saved_i2c_addr;// registro de la dirreccion y rnw
	reg [7:0] counter;//Contador para la lectura y escritura
	reg [7:0] counter2 = 0;//contador para realizar scl a 25%
	reg [7:0] data_in;// Byte que se esta recibiendo
    wire [7:0] wr_data1 = wr_data[7:0];//primer byte que se envia 
    wire [7:0] wr_data2 = wr_data[15:8];// segundo byte que se envia
    reg [15:0] rd_data_slave_to_master;//data que se leyo
  
	assign scl = (scl_enable == 0 ) ? 1 : i2c_clk;//asigancion del scl cuando le corresponde encenderse
	assign sda_out = (sda_oe == 1) ? sda_o : 0;// asigancion de sda_out con sda_o cuando el generador controla el bus
	
	//se divide el reloj principal entre 4
	always @(posedge clk) begin
		if (counter2 == (DIVIDE_BY/2) - 1) begin
			i2c_clk <= ~i2c_clk;
			counter2 <= 0;
		end
		else counter2 <= counter2 + 1;
	end 
	
	//se analiza cuando se debe habilitar scl
	always @(negedge i2c_clk, negedge reset) begin
		if(reset == 0) begin
			scl_enable <= 0;
		end 
		else begin
			if ((state == IDLE) || (state == START) || (state == STOP)) begin
				scl_enable <= 0;
			end else begin
				scl_enable <= 1;
			end
		end
	end

	//logica de estados
	always @(posedge i2c_clk, negedge reset) begin
		//si no hay reset las salidas se ponen en 0
		if(reset == 0) begin
			state <= IDLE;
			counter <= 0;
			counter2 <= 0;
            rd_data <= 0;
            rd_data_slave_to_master <= 0;
            sda_o <= 0;
            sda_oe <= 0;
            data_in <= 0;
		end		
		else begin
			case(state)
				//estado de reposo
				IDLE: begin
                    rd_data = 16'b1010101010101010;//se establece el rd_data a leer en caso de entrar en el estado de lectura
					if (start_stb) begin//si se tiene la señal de inicio se pasa al estado de start
                        sda_o <= 1;//se levanta sda_o para indicar la condicion de inicio
						saved_i2c_addr <= {i2c_addr1, rnw};//se une la dirreccion y el rnw
                        state <= START;// se pasa al estado de start
					end
					else state <= IDLE;//si no se recibe la señal de inicio de continua en reposo
				end

				//estado de start
				START: begin
					counter <= 7;//Se inicia el contador
                    state <= ADDRESS;//se pasa al estado de enviar la dirreccion y el rnw
				end

				//estado de envio de dirreccion y rnw
				ADDRESS: begin
					if (counter == 0) begin //si ya se envio todo la dirreccion y el rnw se pasa a comprobar el A
						state <= READ_ACK;
					end 
					else counter <= counter - 1;//se disminuye el contador que recorre la dirreccion a enviar
				end

				//estado de lectura de A
				READ_ACK: begin //se lee el A, si este correcto se verifica si se quiere leer o escribir
					if ((sda_in == 0) ) begin
						counter <= 7;//se reinicia el contador de data a enviar o recibir
						if(saved_i2c_addr[0] == 0) state <= WRITE_DATA;// si rnw=0 se quiere escribir
						else state <= READ_DATA;//si rnw=1 se quiere leer
					end else state <= STOP;// si A es 1 no se recibio correctamente la dirreccion, se para la transmision
				end

				//estado de escritura
				WRITE_DATA: begin
					//Se envia el primer byte y se compuebra el A
                    if (byte_counter == 0 && counter == 0) begin
                        state <= READ_ACK;
                        byte_counter <= 1;
                    end
					
					//Se envia el segundo byte y comprueba el segundo A
                    if(byte_counter == 1 &&counter == 0) begin
						state <= READ_ACK2;
                        byte_counter <= 0;
					end 
					else counter <= counter - 1;//se disminuye el contador que recorre el byte a escribir
				end

				//estado de lectura del segundo A
				READ_ACK2: begin //si se recibe correcto el A se pasa stop
					if ((sda_in == 0) && (start_stb == 1)) state <= IDLE;
					else state <= STOP;
				end

				//estado de lectura
				READ_DATA: begin
					data_in[counter] <= sda_in;//se agrega a data_in el byte que se esta leyendo
					//cuando se lee el primer byte se pasa al segundo
                    if (byte_counter == 0 && counter == 0) begin
                        state <= WRITE_ACK;//se escibe el A de que se leyo el primer byte
                        byte_counter <= 1;
                    end
                    if(byte_counter == 1 &&counter == 0) begin
                        rd_data_slave_to_master[7:0] = data_in;//Se agrega el sgundo byte leido
						state <= WRITE_ACK2;//se escribe el A de que se leyo el segundo byte
                        byte_counter <= 0;
					end 
					else counter <= counter - 1;//se disminuye el contador que recorre el byte a leer
				end
				
				//estado de escritura del primer A
				WRITE_ACK: begin
                    counter <= 7;
					state <= READ_DATA;
				end

				//estado de escritura del segundo A y paso el estado de stop
                WRITE_ACK2: begin
					if ((sda_o == 0) && (start_stb == 1)) state <= IDLE;
					else state <= STOP;
				end

				//estado de stop
				STOP: begin
					state <= IDLE;
				end
			endcase
		end
	end
	
	//acciones adicionales a realizar en cada estado
	always @(negedge i2c_clk, negedge reset) begin
		if(reset == 0) begin
			sda_oe <= 0;
			sda_o <= 0;
		end 
        else begin
			case(state)
				//estado de start
				START: begin
					sda_oe <= 1;
				end
				
				//estado de envio de dirreccion y rnw
				ADDRESS: begin
					sda_o <= saved_i2c_addr[counter];//Se envian un bit a la vez la dirrecion
				end
				
				//estado de lectura de A
				READ_ACK: begin
					sda_oe <= 0;//se le da el control de bus al receptor
                    sda_o <= 0;//se pone sda_out en bajo
				end
				
				//estado de escritura
				WRITE_DATA: begin 
					sda_oe <= 1;//el generador tiene el control del bus
                    if (byte_counter == 0) sda_o <= wr_data1[counter];// se envia por sda_out el primer byte
                    else sda_o <= wr_data2[counter];// se envia por sda_out el segundo byte
				end
				
				//estado de escritura del primer A
				WRITE_ACK: begin
					sda_oe <= 1;
					sda_o <= 0;//se escribe el A
				end

				//estado de escritura del segundo A y paso el estado de stop
                WRITE_ACK2: begin
					sda_oe <= 1;
					sda_o <= 0;//se escribe el A
				end
				
				//estado de lectura
				READ_DATA: begin
					sda_oe <= 0;//se le da el control de bus al receptor
                    sda_o <= 0;
                    rd_data_slave_to_master[15:8] = data_in;//se guarda el primer byte leido		
				end
				
				//estado de lectura del segundo A
                READ_ACK2: begin
					sda_oe <= 0;//se le da el control de bus al receptor
                    sda_o <= 1;
				end

				//estado de stop
				STOP: begin
					sda_oe <= 1;//el generador tiene el control del bus
					sda_o <= 1;//Se crea la condicion de parada
				end
			endcase
		end
	end
endmodule