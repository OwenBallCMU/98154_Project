`default_nettype none

module my_chip (
    input logic [11:0] io_in, // Inputs to your chip
    output logic [11:0] io_out, // Outputs from your chip
    input logic clock,
    input logic reset // Important: Reset is ACTIVE-HIGH
);
    
    logic SCL_in, SDA_in, SDA_out;
    logic [7:0] reg_out;
    logic [255:0] registers_packed;
    logic clock, SDA_out_temp, in_wait;

    logic [10:0] data_out;
    logic [9:0] data_in;

    assign SCL_in = io_in[0];
    assign SDA_in = io_in[1];
    I2C M1 (.SCL_in, .SDA_in, .clock, .reset, .SDA_out(SDA_out_temp), .reg_out, .in_wait, .registers_packed);

    IO  M2 (.registers_packed, .data_in, .data_out, .clock, .reset);

    assign SDA_out = ~SDA_out_temp;

    assign io_out[11:1] = data_out;
    assign io_out[0] = SDA_out; 


endmodule
