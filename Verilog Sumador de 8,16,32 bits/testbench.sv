`include "probador.v"

module test;
  //Definicion de data types para la prueba de cada modulo
  //Para el Modulo sumador de 4 bits
  wire [3:0] A, B; //numeros a operar
  wire Cin,CLK,ENB;//Acarreo de entrada, reloj, enable
  wire [1:0] MODO;//Modo de operacion
  wire [3:0] Q;//Resultado de la operacion
  wire RCO;//Acarreo de salida
  
  //Para el Modulo sumador de 8 bits
  wire [7:0] A8, B8; //numeros a operar de 8 bits 
  wire [7:0] Q8;//Resultado de la operacion de 8 bits 
  wire RCO8;//Acarreo de salida de la operacion de 8 bits
  
  //Para el Modulo sumador de 32 bits
  wire [31:0] A32, B32; //numeros a operar de 32 bits
  wire [31:0] Q32;//Resultado de la operacion de 32 bits
  wire RCO32;//Acarreo de salida de la operacion de 32 bits

  
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
  
  Sumador8 UUT2 (
    .A(A8),
    .B(B8),
    .Cin(Cin),
    .MODO(MODO),
    .CLK(CLK),
    .ENB(ENB),
    .Q(Q8),
    .RCO(RCO8)
  );
  
  Sumador32 UUT3 (
    .A(A32),
    .B(B32),
    .Cin(Cin),
    .MODO(MODO),
    .CLK(CLK),
    .ENB(ENB),
    .Q(Q32),
    .RCO(RCO32)
  );
  
  probador P0 (
    .A(A),
    .B(B),
    .Cin(Cin),
    .MODO(MODO),
    .CLK(CLK),
    .ENB(ENB),
    .Q(Q),
    .RCO(RCO),
    .A8(A8),
    .B8(B8),
    .Q8(Q8),
    .RCO8(RCO8),
    .A32(A32),
    .B32(B32),
    .Q32(Q32),
    .RCO32(RCO32)
  );

  

endmodule
  

