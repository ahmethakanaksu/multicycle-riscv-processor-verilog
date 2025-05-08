`timescale 1ns/1ps

`define BELLEK_ADRES    32'h8000_0000
`define VERI_BIT        32
`define ADRES_BIT       32
`define YAZMAC_SAYISI   32

module islemci (
    input                       clk,
    input                       rst,
    output  [`ADRES_BIT-1:0]    bellek_adres,
    input   [`VERI_BIT-1:0]     bellek_oku_veri,
    output  [`VERI_BIT-1:0]     bellek_yaz_veri,
    output                      bellek_yaz
   
);

localparam GETIR        = 2'd0;
localparam COZYAZMACOKU = 2'd1;
localparam YURUTGERIYAZ = 2'd2;

reg [1:0] simdiki_asama_r;
reg [`VERI_BIT-1:0] yazmac_obegi [0:`YAZMAC_SAYISI-1];
reg [`ADRES_BIT-1:0] ps_r;
reg ilerle_cmb;

// Benim tanýmladýklarým
reg [31:0] buyruk;
reg [6:0] iskodu, is7;
reg [2:0] is3;
reg [4:0] hy, ky1, ky2;
reg signed [31:0] imm;
reg signed [31:0] num1_r, num2_r, result_r;

reg yazmaca_yazacak_mi, bellege_yazacak_mi, atlayacak_mi, jal_mi, lw_mi;
reg [31:0] bellek_adres_r, bellek_yaz_veri_r;


reg [2:0] amb_islemi;
localparam ADD = 3'd0;
localparam SUB = 3'd1;
localparam AND = 3'd2;
localparam OR = 3'd3;
localparam XOR = 3'd4;
localparam BEQ = 3'd5;


initial begin
    yazmac_obegi[0] = 0;
    imm = 0;
    yazmaca_yazacak_mi = 1'b0;
    bellege_yazacak_mi = 1'b0;
    atlayacak_mi = 1'b0;
    jal_mi = 1'b0;
    lw_mi = 1'b0;
    ps_r <= `BELLEK_ADRES;
end

always @(*) begin
    case (simdiki_asama_r)
        GETIR: begin
            bellek_adres_r = ps_r;
            buyruk = bellek_oku_veri;
            iskodu = buyruk[6:0];
            is7 = buyruk[31:25];
            is3 = buyruk[14:12];
            hy = buyruk[11:7];
            ky2 = buyruk[24:20];
            ky1 = buyruk[19:15];
            imm = 0;
            atlayacak_mi = 1'b0;
            jal_mi = 1'b0;
            lw_mi = 1'b0;
            ilerle_cmb=1'b1;
        end
        
        COZYAZMACOKU: begin
            case (iskodu)
                // ADD, SUB, OR, AND, XOR
                7'b0110011: begin
                    num1_r = yazmac_obegi[ky1];
                    num2_r = yazmac_obegi[ky2];
                    yazmaca_yazacak_mi = 1'b1;
                    bellege_yazacak_mi = 1'b0;
                    atlayacak_mi = 1'b0;
                    
                    case (is3)
                        // ADD, SUB
                        3'b000: begin
                            case (is7)
                                // ADD
                                7'b0000000: begin
                                    amb_islemi = ADD;
                                end
                                
                                //SUB
                                7'b0100000: begin
                                    amb_islemi = SUB;
                                end
                            endcase
                        end
                        
                        // OR
                        3'b110: begin
                            amb_islemi = OR;
                        end
                        
                        // AND
                        3'b111: begin
                            amb_islemi = AND;
                        end
                        
                        // XOR
                        3'b100: begin
                            amb_islemi = XOR;
                        end
                    endcase
                end
                
                // BEQ
                7'b1100011: begin
                    num1_r = yazmac_obegi[ky1];
                    num2_r = yazmac_obegi[ky2];
                    imm[12] = buyruk[31];
                    imm[10:5] = buyruk[30:25];
                    imm[4:1] = buyruk[11:8];
                    imm[11] = buyruk[7];
                    if (buyruk[31] == 1'b1) begin
                        imm[31:13] = 19'b1111_1111_1111_1111_111;
                    end
                    yazmaca_yazacak_mi = 1'b0;
                    bellege_yazacak_mi = 1'b0;
                    
                    case (is3)
                        // BEQ
                        3'b000: begin
                            amb_islemi = BEQ;
                        end
                        
                       
                    endcase
                end
                
                // LUI
                7'b0110111: begin
                    imm[31:12] = buyruk[31:12];
                    num1_r = 0;
                    num2_r = imm;
                    yazmaca_yazacak_mi = 1'b1;
                    bellege_yazacak_mi = 1'b0;
                    atlayacak_mi = 1'b0;
                    amb_islemi = ADD;
                end
                
                // AUIPC
                7'b0010111: begin
                    imm[31:12] = buyruk[31:12];
                    num1_r = ps_r;
                    num2_r = imm;
                    yazmaca_yazacak_mi = 1'b1;
                    bellege_yazacak_mi = 1'b0;
                    atlayacak_mi = 1'b0;
                    amb_islemi = ADD;
                end
                
                // JAL 
                7'b1101111: begin
                    imm[20] = buyruk[31];
                    imm[10:1] = buyruk[30:21];
                    imm[11] = buyruk[20];
                    imm[19:12] = buyruk[19:12];
                    if (buyruk[31] == 1'b1) begin
                        imm[31:21] = 11'b1111_1111_111;
                    end
                    num1_r = ps_r -4;
                    num2_r = imm;
                    yazmaca_yazacak_mi = 1'b1;
                    bellege_yazacak_mi = 1'b0;
                    atlayacak_mi = 1'b1;
                    jal_mi = 1'b1;
                    amb_islemi = ADD;
                end
                
                // JALR 
                7'b1100111: begin
                    imm[11:0] = buyruk[31:20];
                    if (buyruk[31] == 1'b1) begin
                        imm[31:12] = 20'b1111_1111_1111_1111_1111;
                    end
                    num1_r = yazmac_obegi[ky1];
                    num2_r = imm;
                    yazmaca_yazacak_mi = 1'b1;
                    bellege_yazacak_mi = 1'b0;
                    atlayacak_mi = 1'b1;
                    jal_mi = 1'b1;
                    amb_islemi = ADD;
                end
                
                // LW 
                7'b0000011: begin
                    imm[11:0] = buyruk[31:20];
                    if (buyruk[31] == 1'b1) begin
                        imm[31:12] = 20'b1111_1111_1111_1111_1111;
                    end
                    num1_r = yazmac_obegi[ky1];
                    num2_r = imm;
                    yazmaca_yazacak_mi = 1'b1;
                    bellege_yazacak_mi = 1'b0;
                    atlayacak_mi = 1'b0;
                    lw_mi = 1'b1;
                    amb_islemi = ADD;
                end
                
                // SW
                7'b0100011: begin
                    imm[11:5] = buyruk[31:25];
                    imm[4:0] = buyruk[11:7];
                    if (buyruk[31] == 1'b1) begin
                        imm[31:12] = 20'b1111_1111_1111_1111_1111;
                    end
                    num1_r = yazmac_obegi[ky1];
                    num2_r= imm;
                    yazmaca_yazacak_mi = 1'b0;
                    bellege_yazacak_mi = 1'b1;
                    atlayacak_mi = 1'b0;
                    amb_islemi = ADD;
                end
                
                // ADDI
                7'b0010011: begin
                    imm[11:0] = buyruk[31:20];
                    if (buyruk[31] == 1'b1) begin
                        imm[31:12] = 20'b1111_1111_1111_1111_1111;
                    end
                    num1_r = yazmac_obegi[ky1];
                    num2_r = imm;
                    yazmaca_yazacak_mi = 1'b1;
                    bellege_yazacak_mi = 1'b0;
                    atlayacak_mi = 1'b0;
                    amb_islemi = ADD;
                end
            endcase
            
            ilerle_cmb=1'b1;
        end
        
        YURUTGERIYAZ: begin
            case (amb_islemi)
                ADD: begin
                    result_r = num1_r + num2_r;
                end
                
                SUB: begin
                    result_r = num1_r - num2_r;
                end
                
                AND: begin
                    result_r = num1_r & num2_r;
                end
                
                OR: begin
                    result_r = num1_r | num2_r;
                end
                
                XOR: begin
                    result_r = num1_r ^ num2_r;
                end
                
                BEQ: begin
                    if (num1_r == num2_r) begin
                        result_r = ps_r-4  + imm;
                        atlayacak_mi = 1'b1;
                    end
                end
                
                
                
                
            endcase
            
            if (yazmaca_yazacak_mi) begin
                if (jal_mi) begin
                    yazmac_obegi[hy] = num1_r;
                end
                else if (lw_mi) begin
                    bellek_adres_r = result_r;
                    yazmac_obegi[hy] = bellek_oku_veri;
                end
                else begin
                    yazmac_obegi[hy] = result_r;
                end
            end
            
            if (bellege_yazacak_mi) begin
                bellek_adres_r = result_r;
                bellek_yaz_veri_r = yazmac_obegi[ky2];
            end
            
            if (atlayacak_mi) begin
                ps_r = result_r;
            end
        end
    endcase
    
    ilerle_cmb=1'b1;
end

always @(posedge clk) begin
    if (rst) begin
        bellek_adres_r <= `BELLEK_ADRES;
        simdiki_asama_r <= GETIR;
        yazmac_obegi[0] = 0;
        imm = 0;
        yazmaca_yazacak_mi = 1'b0;
        bellege_yazacak_mi = 1'b0;
        atlayacak_mi = 1'b0;
        jal_mi = 1'b0;
        lw_mi = 1'b0;
        ps_r <= `BELLEK_ADRES;
    end
    else begin
        case (simdiki_asama_r)
            GETIR: begin
                simdiki_asama_r <= COZYAZMACOKU;
                ps_r <= ps_r + 4;
            end
            
            COZYAZMACOKU: begin
                simdiki_asama_r <= YURUTGERIYAZ;
            end
            
            YURUTGERIYAZ: begin
                simdiki_asama_r <= GETIR;
            end
        endcase
    end
end

assign bellek_adres = bellek_adres_r;
assign bellek_yaz_veri = bellek_yaz_veri_r;
assign bellek_yaz = bellege_yazacak_mi;


endmodule
