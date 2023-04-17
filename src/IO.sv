`default_nettype none

module IO
 (input  logic clock, reset,
  input  logic [9:0] data_in,
  input  logic [8*`REGCOUNT-1:0] registers_packed,
  output logic [10:0] data_out);

  logic PWM1, PWM2;
  logic [7:0] reg_out;

  assign reg_out = registers_packed[8*(1)+7 -: 8];
  assign data_out[10:3] = reg_out;

  PWM_out PWM_DRIVER (.registers_packed, .clock, .PWM1, .PWM2, .reset);
  assign data_out[2:1] = {PWM2, PWM1};

endmodule: IO


module PWM_out
 (input  logic [8*`REGCOUNT-1:0] registers_packed,
  input  logic clock, reset,
  output logic PWM1, PWM2);

  logic [15:0] PWM1H, PWM1T, PWM2H, PWM2T;
  logic [7:0] PWM1_div, PWM2_div;


  assign PWM1H = registers_packed[8*('h5)+7 -: 16];
  assign PWM1T = registers_packed[8*('h7)+7 -: 16];
  assign PWM1_div = registers_packed[8*('h8)+7 -: 8];
  assign PWM2H = registers_packed[8*('ha)+7 -: 16];
  assign PWM2T = registers_packed[8*('hc)+7 -: 16];
  assign PWM2_div = registers_packed[8*('hd)+7 -: 8];
  //assign PWM2 = 1'b0;
  //assign PWM1 = 1'b0;
  PWM P1 (.clock, .PWM_out(PWM1), .PWMH(PWM1H), .PWMT(PWM1T), .PWM_div(PWM1_div), .reset);
  PWM P2 (.clock, .PWM_out(PWM2), .PWMH(PWM2H), .PWMT(PWM2T), .PWM_div(PWM2_div), .reset);

endmodule: PWM_out



module PWM
 (input  logic clock, reset,
  input  logic [15:0] PWMH, PWMT,
  input  logic [7:0] PWM_div,
  output logic PWM_out);

  logic [15:0] counter2;
  logic [7:0] counter1;

  always_comb
    if ((counter2 < PWMH) && (PWM_div != 8'b0))
      PWM_out = 1'b1;
    else
      PWM_out = 1'b0;

  always_ff @(posedge clock, posedge reset) begin
    if (reset) begin
      counter1 <= 8'b0;
      counter2 <= 16'b1;
    end
    else if (counter1 >= PWM_div) begin
      if (counter2 >= PWMT) counter2 <= 16'b0;
      else counter2 <= counter2 + 16'b1;
      counter1 <= 8'b1;
    end
    else counter1 <= counter1 + 8'b1;
  end
 

endmodule: PWM

  