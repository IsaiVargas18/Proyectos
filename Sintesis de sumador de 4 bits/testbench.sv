`include "probador.v"


module test;
  //Definicion de data types para la prueba de cada modulo
  //Para el Modulo sumador de 4 bits
  wire [3:0] A, B; //numeros a operar
  wire Cin,CLK,ENB;//Acarreo de entrada, reloj, enable
  wire [1:0] MODO;//Modo de operacion
  wire [3:0] Q;//Resultado de la operacion
  wire RCO;//Acarreo de salida

  
  initial begin
	  $dumpfile("test.vcd");
    $dumpvars(-1, UUT1);
  end

  // Instanciacion de los modulos bajo prueba
  Sumador UUT1 (
    .A(A),
    .B(B),
    .Cin(Cin),
    .MODO(MODO),
    .CLK(CLK),
    .ENB(ENB),
    .Q(Q),
    .RCO(RCO)
  );
  
  probador P0 (
    .A(A),
    .B(B),
    .Cin(Cin),
    .MODO(MODO),
    .CLK(CLK),
    .ENB(ENB),
    .Q(Q),
    .RCO(RCO)
  );

endmodule
  

