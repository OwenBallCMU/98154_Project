`default_nettype none

module chipInterface (
    input logic clk100, // 100MHz clock
    input logic reset_n, // Active-low reset
    input logic SCL_in, SDA_in, i2c_reset,
    input logic [7:0] parallel_in,
    output logic [1:0] PWM,
    output logic [7:0] led,
    output logic SDA_out
);

logic [31:0] counter;
logic clock;
logic [11:0] io_in, io_out;

always_ff @(posedge clk100)
        if (~reset_n) begin
            counter <= '0;
            clock <= 1'b0;
        end 
        else begin
            counter <= counter + 1;
            if (counter == 50) begin
                clock <= ~clock;
                counter <= '0;
            end
        end

  
assign io_in = {parallel_in, 2'b0, SDA_in, SCL_in};
assign led = io_out[11:4];
assign PWM = io_out[3:2];
assign SDA_out = io_out[0];

my_chip CHIP (.io_in, .io_out, .clock, .reset(i2c_reset));

endmodule: chipInterface


/*
module chipInterface (
    input logic clk100, // 100MHz clock
    input logic reset_n, // Active-low reset
    input logic SCL_in, SDA_in, i2c_reset,
    input logic [7:0] parallel_in,
    output logic [1:0] PWM,
    output logic [7:0] led,
    output logic SDA_out
);

    logic [31:0] counter;
    logic [7:0] reg_out;
    logic [8*`REGCOUNT-1:0] registers_packed;
    logic clock, SDA_out_temp, in_wait;

    logic [10:0] data_out;

    always_ff @(posedge clk100)
        if (~reset_n) begin
            counter <= '0;
            clock <= 1'b0;
        end 
        else begin
            counter <= counter + 1;
            if (counter == 50) begin
                clock <= ~clock;
                counter <= '0;
            end
        end


    I2C M1 (.SCL_in, .SDA_in, .clock, .reset(i2c_reset), .SDA_out(SDA_out_temp), .reg_out, .in_wait, .registers_packed, .parallel_in);

    IO  M2 (.registers_packed, .data_out, .clock, .reset(i2c_reset));

    assign SDA_out = ~SDA_out_temp;
    //assign led = reg_out;
    assign led = data_out[10:3];

    assign PWM = data_out[2:1];

endmodule: chipInterface
*/
