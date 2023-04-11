`default_nettype none 

module start_detect 
 (input  logic SCL, SDA_negedge, clear_start, clock,
  output logic start);
  
  always_ff @(posedge clock, posedge clear_start)
    if (clear_start) start = 1'b0;
    else if (SCL & SDA_negedge) start = 1'b1;

endmodule: start_detect


module stop_detect 
 (input  logic SCL, SDA_posedge, clear_stop, clock,
  output logic stop);
  
  always_ff @(posedge clock, posedge clear_stop)
    if (clear_stop) stop = 1'b0;
    else if (SCL & SDA_posedge) stop = 1'b1;

endmodule: stop_detect


module data_input
 (input  logic SCL_posedge, SDA, enable, reset, clock,
  output logic [7:0] data_in);

  ShiftRegister_SIPO #(8) SHIFT (.serial(SDA), .clock(clock), .en(enable & SCL_posedge), 
                                 .Q(data_in), .reset);

endmodule: data_input

module count_8
 (input  logic clear, clock, en,
  output logic done,
  output logic [3:0] count);

  assign done = (count == 4'b1000);

  always_ff @(posedge clock, posedge clear)
    if (clear) count <= 4'b0000;
    else if ((count < 4'b1000) & en) count <= count + 4'b1;

endmodule: count_8


module check_addr
 (input logic [6:0] data_in,
  output logic addr_valid);

  assign addr_valid = (data_in == 7'h20);

endmodule: check_addr



module reg_sel
 (input logic [4:0] sel_in,
  input logic inc, en, clock, reset, SCL_negedge,
  output logic [4:0] sel_out);

  always_ff @(posedge clock, posedge reset) begin
    if (reset) sel_out <= 5'b00000;
    else if (en & SCL_negedge) sel_out <= sel_in;
    else if (inc & SCL_negedge) sel_out = sel_out + 5'd1;
  end

endmodule: reg_sel


module memory
 (input logic we, clock, reset, SCL_negedge,
  input logic [4:0] sel, 
  input logic [2:0] count,
  input logic [7:0] data_in,
  output logic data_out,
  output logic [7:0] reg_out,
  output logic [255:0] registers_packed);

  logic [7:0] registers [31:0];

  logic [2:0] index;
  logic [7:0] data_out_8;
  logic [5:0] i;

  integer j;
  always_comb
    for (j = 0; j < 32; j=j+1) registers_packed[(8*(j+1)-1)-:8] = registers[j];

  assign reg_out = registers[1];

  assign data_out = data_out_8[3'b111 - index];

  assign data_out_8 = registers[sel];

  always_ff @(posedge clock, posedge reset) begin
    if (reset) begin
      for (i = 6'd0; i < 6'd32; i=i+6'd1) registers[i] <= 8'b0; 
    end 
    else if (we & SCL_negedge) begin
      registers[sel] <= data_in;
    end
    else if (SCL_negedge) index <= count;
  end

endmodule: memory



module gen_output
 (input logic  send_ack, serial_out, out_en,
  output logic SDA_out);

  always_comb
    if (send_ack) SDA_out = 1'b0;
    else if (out_en && ~serial_out) SDA_out = 1'b0;
    else SDA_out = 1'b1;

endmodule: gen_output


module get_ack
  (input logic SCL_posedge, SDA, clock,
   output logic ACK);

  always_ff @(posedge clock)
    if (SCL_posedge) ACK <= ~SDA;

endmodule: get_ack


module edge_detect
  (input logic sig, clock, 
   output logic sig_posedge, sig_negedge, sig_out);

  logic prev;

  assign sig_out = prev;

  always_ff @(posedge clock) begin
    if (sig & ~prev) sig_posedge <= 1'b1;
    else sig_posedge <= 1'b0;

    if (~sig & prev) sig_negedge <= 1'b1;
    else sig_negedge <= 1'b0;

    prev <= sig;
  end

endmodule: edge_detect


//A synchronizer module to synchronize an asynchronous input to a clock
module synchronizer_edge_detect
  (input  logic async, clock,
   output logic sync, sig_posedge, sig_negedge);

  logic temp;

  DFlipFlop m1 (.D(async), .clock, .Q(temp));

  edge_detect EDGE (.sig(temp), .clock, .sig_posedge, .sig_negedge, .sig_out(sync));

endmodule: synchronizer_edge_detect