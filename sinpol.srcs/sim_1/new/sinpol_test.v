`timescale 1us / 1ns

module sinpol_test();

/// Global constants
localparam M_PI = 3.1415926535;
localparam SIN_AMPL = 10000;

//assume basic clock is 10Mhz
reg clk;
initial clk=0;
always
  #0.05 clk = ~clk;

// make reset signal at begin of simulation
reg reset;
initial
begin
  reset = 1;
  #0.1;
  reset = 0;
end

// function calculating sinus
function real sin;
input x;
real x;
real x1, y, y2, y3, y5, y7, sum, sign;
  begin
    sign = 1.0;
    x1 = x;
    if (x1 < 0) begin
      x1 = -x1;
      sign = -1.0;
    end
    while (x1 > M_PI / 2.0) begin
      x1 = x1 - M_PI;
      sign = -1.0 * sign;
    end
    y = x1 * 2 / M_PI;
    y2 = y * y;
    y3 = y * y2;
    y5 = y3 * y2;
    y7 = y5 * y2;
    sum = (1.570794 * y) - (0.645962 * y3) + (0.079692 * y5) - (0.004681712 * y7);
    sin = sign * sum;
  end
endfunction

//generate requested "freq" digital
integer freq;
reg [31:0]cnt;
reg cnt_edge;
always @(posedge clk or posedge reset)
begin
  if(reset) begin
    cnt <=0;
    cnt_edge <= 1'b0;
  end
  else if( cnt>=(10000000/(freq*64)-1) ) begin
    cnt<=0;
    cnt_edge <= 1'b1;
  end
  else begin
    cnt<=cnt+1;
    cnt_edge <= 1'b0;
  end
end

//generate requested "freq" sinus
real monotonicTime;
reg signed [15:0]sinValue;
always @(posedge cnt_edge)
begin
  sinValue <= sin(monotonicTime) * SIN_AMPL;
  monotonicTime  <= monotonicTime + (M_PI * 2 / 64);
end

initial
begin
  $dumpfile("out.vcd");
  $dumpvars(0,sinpol_test);
  monotonicTime = 0;

  freq=500;
  #10000;
  freq=1000;
  #10000;
  freq=1500;
  #10000;

  $finish;
end
endmodule