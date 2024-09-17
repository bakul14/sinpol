`timescale 1us / 1ns

module sinpol_test();

/// Global constants
localparam M_PI = 3.1415926535;
localparam SIN_AMPL = 10000;
localparam FREQ_DIVIDER = 64;

// Set basic clock as a 10 MHz square wave signal
reg clk;
initial clk = 0;
always #0.05 clk = ~clk;

// Generate reset signal at begin of the simulation
reg reset;
initial begin
  reset = 1;
  #0.1;
  reset = 0;
end

// The 7-order Taylor-polynomial function to calculate sin() 
function real sin(input real radian);
real targetAngle, y, y2, y3, y5, y7, sum, sign;
  begin
    sign = 1.0;
    targetAngle = radian;
    while (targetAngle > M_PI / 2.0) begin
      targetAngle = targetAngle - M_PI;
      sign = -1.0 * sign;
    end
    y = targetAngle * 2 / M_PI;
    y2 = y * y;
    y3 = y * y2;
    y5 = y3 * y2;
    y7 = y5 * y2;
    sum = (1.570794 * y) - (0.645962 * y3) + (0.079692 * y5) - (0.004681712 * y7);
    sin = sign * sum;
  end
endfunction

//generate requested "freq" digital
integer requestedFrequency;
reg [31:0]cnt;
reg resolver;
always @(posedge clk or posedge reset)
begin
  if(reset) begin
    cnt <= 0;
    resolver <= 1'b0;
  end
  else if (cnt >= (10000000 / (requestedFrequency * FREQ_DIVIDER) - 1) ) begin
    cnt <= 0;
    resolver <= 1'b1;
  end
  else begin
    cnt <= cnt + 1;
    resolver <= 1'b0;
  end
end

//generate requested "freq" sinus
real monotonicTime;
reg unsigned [15:0]sinValue;
always @(posedge resolver)
begin
  sinValue <= sin(monotonicTime) * SIN_AMPL;
  monotonicTime  <= monotonicTime + (M_PI * 2 / FREQ_DIVIDER);
end

initial
begin
  $dumpfile("out.vcd");
  $dumpvars(0,sinpol_test);

  monotonicTime = 0;

  // Set different frequencies to validate generated sin()
  requestedFrequency=500;
  #10000;
  requestedFrequency=1000;
  #10000;
  requestedFrequency=1500;
  #10000;

  $finish;
end
endmodule