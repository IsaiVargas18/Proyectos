`include "probador"
module SPI_tb();
    wire clk,ckp,cph;
    wire reset;
    wire [7:0]received_data_master;
    wire [7:0]received_data_slave;


    initial begin
	    $dumpfile("test.vcd");
        $dumpvars(-1, SPI1);
    end

    SPI_Protocol SPI1(
        .clk(clk),
        .ckp(ckp),
        .cph(cph),
        .reset(reset),
        .received_data_master(received_data_master),
        .received_data_slave(received_data_slave)
        );
 
 
 
 endmodule
