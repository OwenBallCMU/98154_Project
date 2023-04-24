`default_nettype none

module I2C
 (input  logic SCL_in, SDA_in, clock, reset,
  input  logic [7:0] parallel_in,
  output logic SDA_out, in_wait,
  output logic [7:0] reg_out,
  output logic [8*`REGCOUNT-1:0] registers_packed);

  logic SCL_sync, SDA_sync, counted_8, clear_counter, start, stop, clear_start;
  logic clear_stop, addr_valid, clear_mem, in_enable, send_ack, we, out_en, ACK;
  logic SCL_posedge, SCL_negedge, SDA_posedge, SDA_negedge; 
  logic [7:0] data_in;
  logic reg_sel_en, reg_sel_inc, data_out;
  logic [4:0] reg_sel_latched;
  logic [3:0] count;

  synchronizer_edge_detect S1 (.async(SCL_in), .sync(SCL_sync), .clock, .sig_posedge(SCL_posedge), .sig_negedge(SCL_negedge));
  synchronizer_edge_detect S2 (.async(SDA_in), .sync(SDA_sync), .clock, .sig_posedge(SDA_posedge), .sig_negedge(SDA_negedge));

  gen_output OUT (.send_ack, .serial_out(data_out), .out_en, .SDA_out);

  count_8 COUNT (.clock, .en(SCL_posedge), .done(counted_8), .clear(clear_counter), .count);

  start_detect START (.start, .clock, .SCL(SCL_sync), .SDA_negedge, .clear_start(clear_start | reset));
  stop_detect  STOP  (.stop,  .clock, .SCL(SCL_sync), .SDA_posedge, .clear_stop(clear_stop | reset));

  data_input IN_REG (.clock, .SCL_posedge, .SDA(SDA_sync), .enable(in_enable), .data_in, .reset);

  check_addr ADDR (.data_in(data_in[7:1]), .addr_valid);

  reg_sel REG(.reset, .clock, .SCL_negedge, .sel_out(reg_sel_latched), .sel_in(data_in[4:0]), .en(reg_sel_en), .inc(reg_sel_inc));

  memory MEM (.we, .clock, .SCL_negedge, .reset, .sel(reg_sel_latched), .count(count[2:0]), 
              .data_in(data_in[7:0]), .data_out, .reg_out, .registers_packed, .parallel_in);

  get_ack READ_ACK (.clock, .SCL_posedge, .SDA(SDA_sync), .ACK);

  FSM M (.*);

endmodule: I2C


