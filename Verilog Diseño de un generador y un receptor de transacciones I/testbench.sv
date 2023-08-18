`include "i2c_tester.v"
`timescale 1ns / 1ps

module i2c_tb;

	// Inputs
	wire clk;
	wire reset;
	wire [6:0] i2c_addr1;
	wire [6:0] i2c_addr2;
	wire [15:0] wr_data;
	wire start_stb;
	wire rnw;

	// Outputs
	wire [15:0] rd_data;

	wire sda_in;
    wire sda_out;
    wire sda_oe;
	wire scl;

	//archivo para guardar la prueba
    initial begin
	    $dumpfile("test.vcd");
        $dumpvars(-1,probador);
    end

	// Crear una instancia de la unidad bajo prueba (UUT)
	i2c_probador probador(
		.clk(clk),
		.reset(reset),
		.i2c_addr1(i2c_addr1),
		.i2c_addr2(i2c_addr2),
		.wr_data(wr_data),
		.start_stb(start_stb),
		.rnw(rnw),

		// Outputs
		.rd_data(rd_data),

		.sda_in(sda_in),
		.sda_out(sda_out),
		.sda_oe(sda_oe),
		.scl(scl)

	);   
endmodule
