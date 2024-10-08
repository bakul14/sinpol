`timescale 1ns / 100ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.09.2024 22:18:22
// Design Name: 
// Module Name: Cordic
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module sinpol(master_clk,angle,Xin,Yin,Xout,Yout);
parameter BW = 32;
localparam iter = BW;
input master_clk;
input signed [31:0] angle;
input signed [BW-1:0] Xin;
input signed [BW-1:0] Yin;
output signed [BW:0] Xout;
output signed [BW:0] Yout;
wire signed [31:0] arctan[0:30];
assign arctan[0] = 32'b00100000000000000000000000000000;
assign arctan[1] = 32'b00010010111001000000010100011110;
assign arctan[2] = 32'b00001001111110110011100001011011;
assign arctan[3] = 32'b00000101000100010001000111010100;
assign arctan[4] = 32'b00000010100010110000110101000011;
assign arctan[5] = 32'b00000001010001011101011111100001;
assign arctan[6] = 32'b00000000101000101111011000011110;
assign arctan[7] = 32'b00000000010100010111110001010101;
assign arctan[8] = 32'b00000000001010001011111001010011;
assign arctan[9] = 32'b00000000000101000101111100101111;
assign arctan[10] = 32'b00000000000010100010111110011000;
assign arctan[11] = 32'b00000000000001010001011111001100;
assign arctan[12] = 32'b00000000000000101000101111100110;
assign arctan[13] = 32'b00000000000000010100010111110011;
assign arctan[14] = 32'b00000000000000001010001011111010;
assign arctan[15] = 32'b00000000000000000101000101111101;
assign arctan[16] = 32'b00000000000000000010100010111110;
assign arctan[17] = 32'b00000000000000000001010001011111;
assign arctan[18] = 32'b00000000000000000000101000110000;
assign arctan[19] = 32'b00000000000000000000010100011000;
assign arctan[20] = 32'b00000000000000000000001010001100;
assign arctan[21] = 32'b00000000000000000000000101000110;
assign arctan[22] = 32'b00000000000000000000000010100011;
assign arctan[23] = 32'b00000000000000000000000001010001;
assign arctan[24] = 32'b00000000000000000000000000101001;
assign arctan[25] = 32'b00000000000000000000000000010100;
assign arctan[26] = 32'b00000000000000000000000000001010;
assign arctan[27] = 32'b00000000000000000000000000000101;
assign arctan[28] = 32'b00000000000000000000000000000011;
assign arctan[29] = 32'b00000000000000000000000000000001;
assign arctan[30] = 32'b00000000000000000000000000000001;
reg signed [BW:0] X [0:iter-1];
reg signed [BW:0] Y [0:iter-1];
reg signed [31:0] Z [0:iter-1];
wire [1:0] quadrant;
assign quadrant=angle[31:30];

always @(posedge master_clk) begin
  case(quadrant)
    2'b00,2'b11: begin
      X[0] <= Xin;
      Y[0] <= Yin;
      Z[0] <= angle;
    end
    2'b01: begin
      X[0] <= -Yin;
      Y[0] <= Xin;
      Z[0] <= {2'b00,angle[29:0]};
    end
    2'b10: begin
      X[0] <= Yin;
      Y[0] <= -Xin;
      Z[0] <= {2'b11,angle[29:0]};
    end
  endcase
end

genvar i;
generate
  for(i = 0; i < (iter - 1); i = i + 1) begin: XYZ
    wire Z_sign;
    wire [BW:0] X_shr,Y_shr;
    assign X_shr = X[i]>>>(i);
    assign Y_shr = Y[i]>>>(i);
    assign Z_sign = Z[i][31];
    always @(posedge master_clk) begin
      X[i+1] <= Z_sign ? X[i] + Y_shr     : X[i] - Y_shr;
      Y[i+1] <= Z_sign ? Y[i] - X_shr     : Y[i] + X_shr;
      Z[i+1] <= Z_sign ? Z[i] + arctan[i] : Z[i] - arctan[i];
    end
  end
endgenerate

assign Xout = X[iter-1];
assign Yout = Y[iter-1];
endmodule