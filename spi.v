module spi (
  input reset,
  input clock_in,
  input load,
  input unload,
  input [7:0] datain, // interface with other ip
  output reg [7:0] dataout, // interface with other ip
  output sclk, // master
  input miso, //master
  output mosi, // master
  input ssn_in, // slave
  output ssn_out // master
);

  wire cntRst, int_clk, ss;
  reg [7:0] datareg;
  reg [3:0] cntreg;

  assign mosi = datareg[7];
  assign ss = |cntreg;
  assign ssn_out = ~ss;
  assign sclk = ss & clock_in;

  always @(posedge clock_in or posedge reset) begin
    if (reset) begin
      datareg  <= 8'h00;
    end else if (load) begin
      datareg <= datain;
    end else begin
      datareg <= datareg << 1;
      if (~ssn_in)
        datareg[0] <= miso;
    end
  end

//  always_latch begin // for yosys
  always @(*) begin
    if (unload) begin
      dataout = datareg;
    end
  end

  assign cntRst = reset | (cntreg[0] & cntreg[3]);
  always @(posedge clock_in or posedge cntRst) begin
    if (cntRst) begin
      cntreg  <= 3'h0;
    end else if (ss || load) begin
      cntreg  <= cntreg + 1;
    end
  end

endmodule
