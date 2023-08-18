module Sumador(A,B,Cin,CLK,ENB,MODO,Q,RCO);
  
  input [3:0] A,B;//Entradas de los nibbles a operar
  input Cin,CLK,ENB;//Entrada del acarreo inicial, el reloj y enable
  input [1:0] MODO;//Seleccion del modo de operacion
  output reg [3:0] Q;//Salida de la operacion
  output reg RCO;//Acarreo de salida

  
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
            {RCO,Q} = A + B + Cin;
          end
          2'b10: begin
            {RCO,Q} = A - B - Cin;
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

