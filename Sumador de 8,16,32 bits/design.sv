module SUMA4 (A,B,cin,cout,suma);
  input  [3:0] A,B;//Entradas de los nibbles a operar
  input cin;//Entrada del acarreo inicial
  output [3:0] suma; //Salida de la operacion de suma
  output cout;//Salida del rebase
  assign {cout,suma} = A + B + cin;//Operacion de suma
endmodule

module RESTA4 (A,B,cin,cout,resta);
  input  [3:0] A,B;//Entradas de los nibbles a operar
  input cin;//Entrada del acarreo inicial
  output [3:0] resta; //Salida de la operacion de suma
  output cout;//Salida del rebase
  assign {cout,resta} = A - B - cin;//Operacion de suma
endmodule

module Sumador(A,B,Cin,CLK,ENB,MODO,Q,RCO);
  
  input [3:0] A,B;//Entradas de los nibbles a operar
  input Cin,CLK,ENB;//Entrada del acarreo inicial, el reloj y enable
  input [1:0] MODO;//Seleccion del modo de operacion
  output reg [3:0] Q;//Salida de la operacion
  output reg RCO;//Acarreo de salida
  
  //Cables necesarios
  wire [3:0] out_suma;
  wire [3:0] out_resta;
  wire Carry1;
  wire Carry2;
  
  //instanciacion de los modulos de suma y resta
  SUMA4 sumar(.A(A), .B(B), .cin(Cin), .cout(Carry1), .suma(out_suma));
  RESTA4 resta(.A(A), .B(B), .cin(Cin), .cout(Carry2), .resta(out_resta));
  
    //Se ejecuta siempre que se tenga un flanco positivo de reloj
    always @ (posedge CLK) begin
      //Se ejecuta siempre que se tenga ENB=1
      if (ENB==1'b1) begin
        //Se asigna a la salida el resultado segun la operacion seleccionada en MODO
        case (MODO)
          2'b00: begin
            Q = Q;
          end
          2'b01: begin
            Q = out_suma;
            RCO=Carry1;
          end
          2'b10: begin
            Q = out_resta;
            RCO=Carry2;
          end
          2'b11: begin
            Q = 0;
            RCO=0;
          end
      	endcase
      end
      else begin
        Q = Q;
      end
    end
endmodule

module Sumador8(A,B,Cin,CLK,ENB,MODO,Q,RCO);
  
  input [7:0] A,B;//Entradas de los nibbles a operar
  input Cin,CLK,ENB;//Entrada del acarreo inicial, el reloj y enable
  input [1:0] MODO;//Seleccion del modo de operacion
  output reg [7:0] Q;//Salida de la operacion
  output reg RCO;//Acarreo de salida
  
  //Cables necesarios
  wire [3:0] Q1,Q2;
  wire Carry1,Carry2;
  
  //instanciacion del modulo de suma de 4 bits 2 veces para operar el total de bits
  //La salida de acarreo del primero se ingresa en el segundo
  //Se le indica cuales bits de A y B trabaja cada instanciacion
  Sumador sumador1(.A(A[3:0]), .B(B[3:0]), .Cin(Cin), .CLK(CLK), .ENB(ENB), .MODO(MODO), .Q(Q1), .RCO(Carry1));
  Sumador sumador2(.A(A[7:4]), .B(B[7:4]), .Cin(Carry1), .CLK(CLK), .ENB(ENB), .MODO(MODO), .Q(Q2), .RCO(Carry2));
  
  //Se asigna a la salida el resultado
  always @ (posedge CLK) begin
  	RCO=Carry2;
    Q = {Q2, Q1};//Se vuelven a unir los dos Q calculados
  end
endmodule

module Sumador32(A,B,Cin,CLK,ENB,MODO,Q,RCO);
  
  input [31:0] A,B;//Entradas de los nibbles a operar
  input Cin,CLK,ENB;//Entrada del acarreo inicial, el reloj y enable
  input [1:0] MODO;//Seleccion del modo de operacion
  output reg [31:0] Q;//Salida de la operacion
  output reg RCO;//Acarreo de salida
  
  //Cables necesarios
  wire [3:0] Q1,Q2,Q3,Q4,Q5,Q6,Q7,Q8;
  wire Carry1,Carry2,Carry3,Carry4,Carry5,Carry6,Carry7,Carry8;

  //instanciacion del modulo de suma de 4 bits 8 veces para operar el total de bits
  //La salida de acarreo del primero se ingresa en el segundo
  //Se le indica cuales bits de A y B trabaja cada instanciacion
  Sumador sumador1(.A(A[3:0]), .B(B[3:0]), .Cin(Cin), .CLK(CLK), .ENB(ENB), .MODO(MODO), .Q(Q1), .RCO(Carry1));
  Sumador sumador2(.A(A[7:4]), .B(B[7:4]), .Cin(Carry1), .CLK(CLK), .ENB(ENB), .MODO(MODO), .Q(Q2), .RCO(Carry2));
  Sumador sumador3(.A(A[11:8]), .B(B[11:8]), .Cin(Carry2), .CLK(CLK), .ENB(ENB), .MODO(MODO), .Q(Q3), .RCO(Carry3));
  Sumador sumador4(.A(A[15:12]), .B(B[15:12]), .Cin(Carry3), .CLK(CLK), .ENB(ENB), .MODO(MODO), .Q(Q4), .RCO(Carry4));
  Sumador sumador5(.A(A[19:16]), .B(B[19:16]), .Cin(Carry4), .CLK(CLK), .ENB(ENB), .MODO(MODO), .Q(Q5), .RCO(Carry5));
  Sumador sumador6(.A(A[23:20]), .B(B[23:20]), .Cin(Carry5), .CLK(CLK), .ENB(ENB), .MODO(MODO), .Q(Q6), .RCO(Carry6));
  Sumador sumador7(.A(A[27:24]), .B(B[27:24]), .Cin(Carry6), .CLK(CLK), .ENB(ENB), .MODO(MODO), .Q(Q7), .RCO(Carry7));
  Sumador sumador8(.A(A[31:28]), .B(B[31:28]), .Cin(Carry7), .CLK(CLK), .ENB(ENB), .MODO(MODO), .Q(Q8), .RCO(Carry8));
  
  //Se asigna a la salida el resultado
  always @ (posedge CLK) begin
  	RCO=Carry8;
    Q = {Q8, Q7, Q6, Q5, Q4, Q3, Q2, Q1};//Se vuelven a unir los dos Q calculados
  end
endmodule