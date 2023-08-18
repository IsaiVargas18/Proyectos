`timescale 1ns / 1ps
module i2c_receptor(
    input clk,
    input reset,
    input [6:0] i2c_addr2,//dirreccion del receptor
    input [15:0] rd_data,//salida del generador, data que se debe leer
    input sda_out,//salida de generador
    input scl,//Reloj a 25%
    input sda_oe,// inducacion de quien controla el bus

	output sda_in,//salida sda de receptor a generador
    output reg [15:0] wr_data //salida del receptor, data que se debe escribir
	);
	
	//Se instancian algunos parametros para los estados
	localparam READ_ADDR = 0;//lectura de la dirreccion
	localparam SEND_ACK = 1;//enviar pimer A
	localparam READ_DATA = 2;//lectura
	localparam WRITE_DATA = 3;//escritura
	localparam SEND_ACK2 = 4;//enviar segundo A
	localparam READ_ACK = 5;//leer primer A
	localparam READ_ACK2 = 6;//leer segundo A
	
	reg sda_o = 0;//salida de sda_in
	reg start = 0;//registro para saber si se recibio la condicion de start
	reg byte_counter=0;//contador del byte de datos que se esta enviando o recibiendo
	reg [7:0] addr;// registro de la dirreccion recibida
	reg [7:0] counter;//Contador para la lectura y escritura
	reg [7:0] state = 0;// registro de estado
	reg [7:0] data_in;// Byte que se esta recibiendo
	wire [7:0] rd_data1 = rd_data[7:0];//primer byte que se recibe
    wire [7:0] rd_data2 = rd_data[15:8];//primer byte que se recibe
	reg [15:0] wr_data_master_to_slave;//data que se escribio

	assign sda_in = (sda_oe == 0) ? sda_o : 0;// asigancion de sda_in con sda_o cuando el receptor controla el bus
	

	//analisis de la señal de sda_out para ver si se tiene la condicion de start o stop
	always @( posedge sda_out) begin
		if ((start == 0) && (scl == 1)) begin
			start <= 1;	
			counter <= 7;
		end
	end
	
	always @( negedge sda_out) begin
		if ((start == 1) && (scl == 1)) begin
			state <= READ_ADDR;
			start <= 0;
		end
	end
	
	//logica de estados
	always @(posedge scl, negedge reset) begin
		if(reset == 0) begin//si no hay reset las salidas se ponen en 0
			counter <= 0;
            wr_data <= 0;
            wr_data_master_to_slave <= 0;
			sda_o <= 0;
			data_in <= 0;
		end	
		if (start == 1) begin //si se recibio al condicon de start se pasa a leer o escribir
			case(state)
				//lectura de la dirrecion
				READ_ADDR: begin //se lee la dirrecion enviada
					wr_data = 16'b1100110011001100;//se establece el wr_data
					addr[counter] <= sda_out;//se guardan los bits de la dirreccion y el rnw
					if(counter == 0) state <= SEND_ACK;//se envia A 
					else counter <= counter - 1;//se disminuye el contador que recorre la dirreccion a recibida			
				end
				
				//comprbacion de la dirreccion
				SEND_ACK: begin
					if(addr[7:1] == i2c_addr2) begin//si la dirrecion es correcta se lee el rnw adjunto
						counter <= 7;//se reinicia el contador de data a enviar o recibir
						if(addr[0] == 0) begin 
							state <= READ_DATA;//si rnw=o se quiere leer
						end
						else state <= WRITE_DATA;// si rnw=1 se quiere escribir
					end
				end
				
				//estado de lectura
				READ_DATA: begin
					data_in[counter] <= sda_out;//se agrega a data_in el byte que se esta leyendo
					//cuando se lee el primer byte se pasa al segundo
					if (byte_counter == 0 && counter == 0) begin//se escibe el A de que se leyo el primer byte
                        state <= SEND_ACK;//se escibe el A de que se leyo el primer byte
                        byte_counter <= 1;
                    end
                    else if(byte_counter == 1 &&counter == 0) begin//Se agrega el sgundo byte leido
						wr_data_master_to_slave[7:0] <= data_in;
						state <= SEND_ACK2;//se escribe el A de que se leyo el segundo byte
						byte_counter <= 0;
					end
					else counter <= counter - 1;//se disminuye el contador que recorre el byte a leer
				end
				
				//estado de escritura del primer A
				SEND_ACK2: begin
					state <= READ_ADDR;					
				end
				
				//estado de escritura
				WRITE_DATA: begin
					//Se envia el primer byte y se compuebra el A
					if (byte_counter == 0 && counter == 0) begin
                        state <= READ_ACK;
                        byte_counter <= 1;
                    end
					//Se envia el segundo byte y comprueba el segundo A
                    if(byte_counter == 1 && counter == 0) begin
						state <= READ_ACK2;
					end 
					if(counter!=0) counter <= counter - 1;//se disminuye el contador que recorre el byte a escribir
				end

				//estado de lectura de A
				READ_ACK: begin//se lee el A, si este correcto se verifica si se quiere leer o escribir
					counter <= 7;//Se inicia el contador
					if ((sda_out == 0)) state <= WRITE_DATA;
					else state <= READ_ADDR;
				end

				//estado de lectura del segundo A
				READ_ACK2: begin
					if ((sda_out == 1)) state <= READ_ADDR;
					else state <= READ_ADDR;
				end
				
			endcase
		end
	end
	
	always @(negedge scl) begin
		case(state)
			//estado de escritura del primer A
			SEND_ACK: begin
				sda_o <= 0;	//se escribe el A
			end
			
			//estado de lectura
			READ_DATA: begin
				sda_o <= 0;
				wr_data_master_to_slave[15:8] <= data_in;//se guarda el primer byte leido
			end
			
			//estado de escritura
			WRITE_DATA: begin
				if (byte_counter == 0) sda_o <= rd_data1[counter];// se envia por sda_in el primer byte
                else sda_o <= rd_data2[counter];// se envia por sda_in el segundo byte
			end
			
			//estado de escritura del segundo A
			SEND_ACK2: begin
				sda_o <= 0;//se escribe el A
			end
		endcase
	end
endmodule