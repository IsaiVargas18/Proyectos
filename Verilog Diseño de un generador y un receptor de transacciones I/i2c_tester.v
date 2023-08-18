`include "i2c_generador.v"
`include "i2c_receptor.v"
`timescale 1ns / 1ps

module i2c_probador(clk,reset,i2c_addr1,i2c_addr2,start_stb,rnw, rd_data,wr_data,sda_in,sda_out,sda_oe,scl);

	// Inputs
	output reg clk;
	output reg reset=1;
	output reg [6:0] i2c_addr1;//dirreccion a la que se quiere enviar
	output reg [6:0] i2c_addr2;//dirreccion del receptor
	
	output reg start_stb=0;//señal del cpu de inicio
	output reg rnw;//indicador de escritura o lectura

	// Outputs
	output wire [15:0] rd_data;//data a leer
    output wire [15:0] wr_data;//data a escribir

	output wire sda_in;//entrada del generador de lo que se lee
    output wire sda_out;//salida del generador de lo que se escribe
    output wire sda_oe;//inducador de control del bus
	output wire scl;//reloj a 25%

	// Crear una instancia de la unidad bajo prueba (UUT)
	i2c_generador master (
		.clk(clk), 
		.reset(reset), 
		.i2c_addr1(i2c_addr1), 
		.wr_data(wr_data), 
		.start_stb(start_stb), 
		.rnw(rnw), 
		.rd_data(rd_data), 
		.sda_in(sda_in),
        .sda_out(sda_out),
        .sda_oe(sda_oe),  
		.scl(scl)
	);
		
	i2c_receptor slave (
        .clk(clk), 
		.reset(reset), 
		.i2c_addr2(i2c_addr2),
        .rd_data(rd_data), 
        .wr_data(wr_data),
        .sda_in(sda_in),
        .sda_out(sda_out), 
        .sda_oe(sda_oe),  
        .scl(scl)
    );
	
	//reloj principal
	initial begin
		clk = 0;
		forever begin
			clk = #1 ~clk;
		end		
	end

	initial begin
		clk = 0;//se incia el reloj

	//////////prueba1//////////
	//prueba de esritura
		reset = 0;
		// Espere 100 ns para que finalice el restablecimiento
		#100;
		reset = 1;	

		i2c_addr1 = 7'b0111111;//dirreccion a la que se quiere escribir (carne B88263), dirreccion 63=0111111
		i2c_addr2 = 7'b0111111;//dirrecion del receptor
		rnw = 0;//indicacion de que se quiere escribir
		start_stb = 1;//strobe de inicio
		#10;
		start_stb = 0;	
		#250//se da un tiempo para que se complete la transaccion

	//////////prueba2//////////
	//prueba de lectura
        reset = 0;
		#100;// Espere 100 ns para que finalice el restablecimiento
		reset = 1;		
		i2c_addr1 = 7'b0111111;//dirreccion a la que se quiere leer (carne B88263), dirreccion 63=0111111
		i2c_addr2 = 7'b0111111;//dirrecion del receptor
		rnw = 1;//indicacion de que se quiere leer
		start_stb = 1;//strobe de inicio
		#10;
		start_stb = 0;	
		#250//se da un tiempo para que se complete la transaccion

	//////////prueba3//////////
	//prueba de dirrecion distinta
		reset = 0;
		#100;// Espere 100 ns para que finalice el restablecimiento
		reset = 1;		
		i2c_addr1 = 7'b0111111;//dirreccion a la que se quiere escribir (carne B88263), dirreccion 63=0111111
		i2c_addr2 = 7'b0101111;//dirrecion del receptor (distinta a la que se quiere leer)
		rnw = 1;//indicacion de que se quiere leer
		start_stb = 1;//strobe de inicio
		#10;
		start_stb = 0;	
		#250//se da un tiempo para que se complete la transaccion
		$finish;
		
	end      
endmodule