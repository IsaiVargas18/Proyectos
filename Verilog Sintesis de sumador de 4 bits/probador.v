module probador(A,B,Cin,CLK,ENB,MODO,Q,RCO);
  
  
  output [3:0] A,B;//Entradas de los nibbles a operar

  output Cin,CLK,ENB;//Entrada del acarreo inicial, el reloj y enable
  output [1:0] MODO;//Seleccion del modo de operacion
  input [3:0] Q;//Salida de la operacion
  input RCO;//Acarreo de salida de la operacion de 4 bits

  
 
  //Definicion de data types para la prueba de cada modulo
  
  reg [3:0] A, B; //numeros a operar de 4 bits
  reg Cin,CLK,ENB;//Acarreo de entrada, reloj, enable
  reg [1:0] MODO;//Modo de operacion
  wire [3:0] Q;//Resultado de la operacion de 4 bits
  wire RCO;//Acarreo de salida de la operacion de 4 bits


  always #20 CLK <= ~CLK;//Reloj
  // Estimulos: definicion de las señales a aplicar
  initial begin 
    CLK=0;

/////////////////Pruebas para el modulo sumador de 4 bits/////////////////

    //Prueba #1, suma de 4 bits.
    $display("Prueba #1, suma de 4 bits.");
    //Establecer MODO[1:0]=11 para limpiar el contador.
    MODO=2'b11;
    
    //Poner ENB=1.
    ENB=1;

    //Enviar flanco activo en CLK. Con esto se pone el contador a cero.
    repeat(2) @(posedge CLK);

    //Se imprimen en terminal los resultados despues de limpiar
    $display("Operando A: %b", A);
    $display("Operando B: %b", B);
    $display("Acarreo de entrada: %b", Cin);
    $display("ENB = %b", ENB);
    $display("Resultado de la operacion %b: %b",MODO, Q);
    $display("Rebase: %b",RCO);
    $display("");

    //Se ingresan valores de A, B y Acarreo de entrada
    A=4'b1110;
    B=4'b1001;
    Cin=0;
    //Establecer MODO[1:0]=01. Pone modo de suma.
    MODO=2'b01;

    //Enviar flanco activo en CLK. El estado de contador debería pasar a Q=A+B.
    repeat(2) @(posedge CLK);
    
    //Se imprimen en terminal los resultados despues de hacer la suma
    $display("Operando A: %b", A);
    $display("Operando B: %b", B);
    $display("Acarreo de entrada: %b", Cin);
    $display("ENB = %b", ENB);
    $display("Resultado de la operacion %b: %b",MODO, Q);
    $display("Rebase: %b",RCO);
    $display("");
    
    //Se modifican los valores de A, B y Acarreo de entrada
    A=4'b0110;
    B=4'b1001;
    Cin=1;
    //Se envia un nuevo flanco positovo de reloj para se realice la nueva suma
    repeat(2) @(posedge CLK);

    //Se imprimen en terminal los resultados despues de hacer la nueva suma
    $display("Operando A: %b", A);
    $display("Operando B: %b", B);
    $display("Acarreo de entrada: %b", Cin);
    $display("ENB = %b", ENB);
    $display("Resultado de la operacion %b: %b",MODO, Q);
    $display("Rebase: %b",RCO);
    $display("");

    //Prueba #2, resta de 4 bits.
    $display("Prueba #2, resta de 4 bits.");
    //Establecer MODO[1:0]=11 para limpiar el contador.
    MODO=2'b11;
    
    //Poner ENB=1.
    ENB=1;

    //Enviar flanco activo en CLK. Con esto se pone el contador a cero.
    repeat(2) @(posedge CLK);

    //Se imprimen en terminal los resultados despues de limpiar
    $display("Operando A: %b", A);
    $display("Operando B: %b", B);
    $display("Acarreo de entrada: %b", Cin);
    $display("ENB = %b", ENB);
    $display("Resultado de la operacion %b: %b",MODO, Q);
    $display("Rebase: %b",RCO);
    $display("");

    //Se ingresan valores de A, B y Acarreo de entrada
    A=4'b1110;
    B=4'b1001;
    Cin=0;

    //Establecer MODO[1:0]=10. Pone modo de resta.
    MODO=2'b10;

    //Enviar flanco activo en CLK. El estado de contador debería pasar a Q=A+B.
    repeat(2) @(posedge CLK);
    
    //Se imprimen en terminal los resultados despues de hacer la suma
    $display("Operando A: %b", A);
    $display("Operando B: %b", B);
    $display("Acarreo de entrada: %b", Cin);
    $display("ENB = %b", ENB);
    $display("Resultado de la operacion %b: %b",MODO, Q);
    $display("Rebase: %b",RCO);
    $display("");

    //Prueba #3, mantener el valor en modo 00.
    $display("Prueba #3, mantener el valor en modo 00.");
    A=4'b1110;
    B=4'b1001;
    Cin=0;
    //Establecer MODO[1:0]=01. Pone modo de suma.
    MODO=2'b01;
    //Enviar flanco activo en CLK. El estado de contador debería pasar a Q=A+B.
    repeat(2) @(posedge CLK);
    
    //Se imprimen en terminal los resultados despues de hacer la suma
    $display("Operando A: %b", A);
    $display("Operando B: %b", B);
    $display("Acarreo de entrada: %b", Cin);
    $display("ENB = %b", ENB);
    $display("Resultado de la operacion %b: %b",MODO, Q);
    $display("Rebase: %b",RCO);
    $display("");

    //Establecer MODO[1:0]=00. Pone modo de mantener valor de Q.
    MODO=2'b00;
    //Envian varios flancos activos en CLK. El estado de contador mantenerse.
    repeat(20) @(posedge CLK);
    
    //Se imprimen en terminal los resultados despues de hacer la suma
    $display("Operando A: %b", A);
    $display("Operando B: %b", B);
    $display("Acarreo de entrada: %b", Cin);
    $display("ENB = %b", ENB);
    $display("Resultado de la operacion %b: %b",MODO, Q);
    $display("Rebase: %b",RCO);
    $display("");

    //Prueba #4, mantener el valor cuando ENB = 0.
    $display("Prueba #4, mantener el valor cuando ENB = 0.");
    A=4'b1110;
    B=4'b1001;
    Cin=0;
    ENB=1;
    //Establecer MODO[1:0]=01. Pone modo de suma.
    MODO=2'b01;
    //Enviar flanco activo en CLK. El estado de contador debería pasar a Q=A+B.
    repeat(2) @(posedge CLK);
    
    //Se imprimen en terminal los resultados despues de hacer la suma
    $display("Operando A: %b", A);
    $display("Operando B: %b", B);
    $display("Acarreo de entrada: %b", Cin);
    $display("ENB = %b", ENB);
    $display("Resultado de la operacion %b: %b",MODO, Q);
    $display("Rebase: %b",RCO);
    $display("");

    //Se cambia el ENB
    ENB=0;

    //Se imprimen en terminal los resultados despues de cambiar ENB
    $display("Operando A: %b", A);
    $display("Operando B: %b", B);
    $display("Acarreo de entrada: %b", Cin);
    $display("ENB = %b", ENB);
    $display("Resultado de la operacion %b: %b",MODO, Q);
    $display("Rebase: %b",RCO);
    $display("");

    //Prueba #5, limpiar el contador.
    $display("Prueba #5, limpiar el contador.");
    A=4'b1110;
    B=4'b1001;
    Cin=0;
    ENB=1;
    //Establecer MODO[1:0]=01. Pone modo de suma.
    MODO=2'b01;
    //Enviar flanco activo en CLK. El estado de contador debería pasar a Q=A+B.
    repeat(2) @(posedge CLK);
    
    //Se imprimen en terminal los resultados despues de hacer la suma
    $display("Operando A: %b", A);
    $display("Operando B: %b", B);
    $display("Acarreo de entrada: %b", Cin);
    $display("ENB = %b", ENB);
    $display("Resultado de la operacion %b: %b",MODO, Q);
    $display("Rebase: %b",RCO);
    $display("");

    //Establecer MODO[1:0]=11. Pone modo de limpiar.
    MODO=2'b11;
    //Envian varios flancos activos en CLK. El estado de contador limpiarse.
    repeat(2) @(posedge CLK);
    
    //Se imprimen en terminal los resultados despues de hacer la limpeza
    $display("Operando A: %b", A);
    $display("Operando B: %b", B);
    $display("Acarreo de entrada: %b", Cin);
    $display("ENB = %b", ENB);
    $display("Resultado de la operacion %b: %b",MODO, Q);
    $display("Rebase: %b",RCO);
    $display("");
    
    
    $finish;
  end

endmodule