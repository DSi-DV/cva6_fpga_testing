module stream_demux #(
  parameter integer N_OUP = 1,
  /// Dependent parameters, DO NOT OVERRIDE!
  localparam integer LOG_N_OUP = $clog2(N_OUP)
) (
  input  logic                  inp_valid_i,
  output logic                  inp_ready_o,

  input  logic  [LOG_N_OUP-1:0] oup_sel_i,

  output logic  [N_OUP-1:0]     oup_valid_o,
  input  logic  [N_OUP-1:0]     oup_ready_i
);

  always_comb begin
    oup_valid_o = '0;
    oup_valid_o[oup_sel_i] = inp_valid_i;
  end
  assign inp_ready_o = oup_ready_i[oup_sel_i];

endmodule
