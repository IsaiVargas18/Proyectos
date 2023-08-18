`ifndef TABLAS_CODE_GROUPS
    `define TABLAS_CODE_GROUPS

    // TABLA DE VALID SPECIAL CODE GROUPS
    `define K28_0_08b 8'h1C
    `define K28_1_08b 8'h3C
    `define K28_2_08b 8'h5C
    `define K28_3_08b 8'h7C
    `define K28_4_08b 8'h9C
    `define K28_5_08b 8'hBC // /COMMA/
    `define K28_6_08b 8'hDC
    `define K28_7_08b 8'hFC
    `define K23_7_08b 8'hF7 // /R/
    `define K27_7_08b 8'hFB // /S/
    `define K29_7_08b 8'hFD // /T/
    `define K30_7_08b 8'hFE // /V/

    `define K28_0_10b 10'b11_0000_1011
    `define K28_1_10b 10'b11_0000_0110
    `define K28_2_10b 10'b11_0000_1010
    `define K28_3_10b 10'b11_0000_1100
    `define K28_4_10b 10'b11_0000_1101
    `define K28_5_10b 10'b11_0000_0101 // /COMMA/
    `define K28_6_10b 10'b11_0000_1001
    `define K28_7_10b 10'b11_0000_0111
    `define K23_7_10b 10'b00_0101_0111 // /R/
    `define K27_7_10b 10'b00_1001_0111 // /S/
    `define K29_7_10b 10'b01_0001_0111 // /T/
    `define K30_7_10b 10'b10_0001_0111 // /V/

    // TABLA DE VALID DATA CODE GROUPS
    `define D00_0_08b 8'h00
    `define D01_0_08b 8'h01
    `define D02_0_08b 8'h02
    `define D03_0_08b 8'h03
    `define D02_2_08b 8'h42
    `define D16_2_08b 8'h50
    `define D26_4_08b 8'h9A
    `define D06_5_08b 8'hA6
    `define D21_5_08b 8'hB5

    `define D05_6_08b 8'hC5

    // rx_code-group<9:0> (en modulo como code_group_10b_recibido)
    `define D00_0_10b 10'b10_0111_0100 // 00
    `define D01_0_10b 10'b01_1101_0100 // 01
    `define D02_0_10b 10'b10_1101_0100 // 02
    `define D03_0_10b 10'b11_0001_1011 // 03
    `define D02_2_10b 10'b10_1101_0101 // 42
    `define D16_2_10b 10'b01_1011 0101 // 50
    `define D26_4_10b 10'b01_0110_1101 // 9A
    `define D06_5_10b 10'b01_1001_1010 // A6
    `define D21_5_10b 10'b10_1010_1010 // B5
    `define D05_6_10b 10'b10_1001_0110 // C5
`endif
