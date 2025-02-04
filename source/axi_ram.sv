`include "axi/typedef.svh"
`include "axi/assign.svh"

module axi_ram #(
    parameter logic [63:0] MEM_BASE = 'h1000,
    parameter int          MEM_SIZE = 18,
    parameter type         req_t    = soc_pkg::s_req_t,
    parameter type         resp_t   = soc_pkg::s_resp_t
) (
    input  logic  clk_i,
    input  logic  arst_ni,
    input  req_t  req_i,
    output resp_t resp_o
);

  localparam int IW = $bits(req_i.aw.id);
  localparam int AW = MEM_SIZE;
  localparam int DW = $bits(req_i.w.data);
  localparam int UW = $bits(resp_o.r.user);

  `AXI_TYPEDEF_ALL(axi, logic [AW-1:0], logic [IW-1:0], logic [DW-1:0], logic [DW/8-1:0],
                   logic [UW-1:0])
  `AXI_LITE_TYPEDEF_ALL(axil, logic [AW-1:0], logic [DW-1:0], logic [DW/8-1:0])

  axi_req_t   axi_req;
  axi_resp_t  axi_resp;
  axil_req_t  axil_req_pre_mem;
  axil_resp_t axil_resp_pre_mem;
  axil_req_t  axil_req;
  axil_resp_t axil_resp;

  assign axi_req.aw.id     = req_i.aw.id;
  assign axi_req.aw.addr   = (req_i.aw.addr - MEM_BASE);
  assign axi_req.aw.len    = req_i.aw.len;
  assign axi_req.aw.size   = req_i.aw.size;
  assign axi_req.aw.burst  = req_i.aw.burst;
  assign axi_req.aw.lock   = req_i.aw.lock;
  assign axi_req.aw.cache  = req_i.aw.cache;
  assign axi_req.aw.prot   = req_i.aw.prot;
  assign axi_req.aw.qos    = req_i.aw.qos;
  assign axi_req.aw.region = req_i.aw.region;
  assign axi_req.aw.atop   = req_i.aw.atop;
  assign axi_req.aw.user   = req_i.aw.user;
  assign axi_req.aw_valid  = req_i.aw_valid;
  assign resp_o.aw_ready   = axi_resp.aw_ready;
  assign axi_req.w.data    = req_i.w.data;
  assign axi_req.w.strb    = req_i.w.strb;
  assign axi_req.w.last    = req_i.w.last;
  assign axi_req.w.user    = req_i.w.user;
  assign axi_req.w_valid   = req_i.w_valid;
  assign resp_o.w_ready    = axi_resp.w_ready;
  assign resp_o.b.id       = axi_resp.b.id;
  assign resp_o.b.resp     = axi_resp.b.resp;
  assign resp_o.b.user     = axi_resp.b.user;
  assign resp_o.b_valid    = axi_resp.b_valid;
  assign axi_req.b_ready   = req_i.b_ready;
  assign axi_req.ar.id     = req_i.ar.id;
  assign axi_req.ar.addr   = (req_i.ar.addr - MEM_BASE);
  assign axi_req.ar.len    = req_i.ar.len;
  assign axi_req.ar.size   = req_i.ar.size;
  assign axi_req.ar.burst  = req_i.ar.burst;
  assign axi_req.ar.lock   = req_i.ar.lock;
  assign axi_req.ar.cache  = req_i.ar.cache;
  assign axi_req.ar.prot   = req_i.ar.prot;
  assign axi_req.ar.qos    = req_i.ar.qos;
  assign axi_req.ar.region = req_i.ar.region;
  assign axi_req.ar.user   = req_i.ar.user;
  assign axi_req.ar_valid  = req_i.ar_valid;
  assign resp_o.ar_ready   = axi_resp.ar_ready;
  assign resp_o.r.id       = axi_resp.r.id;
  assign resp_o.r.data     = axi_resp.r.data;
  assign resp_o.r.resp     = axi_resp.r.resp;
  assign resp_o.r.last     = axi_resp.r.last;
  assign resp_o.r.user     = axi_resp.r.user;
  assign resp_o.r_valid    = axi_resp.r_valid;
  assign axi_req.r_ready   = req_i.r_ready;

  axi_to_axi_lite #(
      .AxiAddrWidth   (AW),
      .AxiDataWidth   (DW),
      .AxiIdWidth     (IW),
      .AxiUserWidth   (UW),
      .AxiMaxWriteTxns(4),
      .AxiMaxReadTxns (4),
      .FullBW         (0),
      .FallThrough    (0),
      .full_req_t     (axi_req_t),
      .full_resp_t    (axi_resp_t),
      .lite_req_t     (axil_req_t),
      .lite_resp_t    (axil_resp_t)
  ) u_converter (
      .clk_i     (clk_i),
      .rst_ni    (arst_ni),
      .test_i    ('0),
      .slv_req_i (axi_req),
      .slv_resp_o(axi_resp),
      .mst_req_o (axil_req_pre_mem),
      .mst_resp_i(axil_resp_pre_mem)
  );

  axi_fifo #(
      .Depth      (32'd1),
      .FallThrough(1'b0),
      .aw_chan_t  (axil_aw_chan_t),
      .w_chan_t   (axil_w_chan_t),
      .b_chan_t   (axil_b_chan_t),
      .ar_chan_t  (axil_ar_chan_t),
      .r_chan_t   (axil_r_chan_t),
      .axi_req_t  (axil_req_t),
      .axi_resp_t (axil_resp_t)
  ) u_fifo (
      .clk_i(clk_i),
      .rst_ni(arst_ni),
      .test_i('0),
      .slv_req_i(axil_req_pre_mem),
      .slv_resp_o(axil_resp_pre_mem),
      .mst_req_o(axil_req),
      .mst_resp_i(axil_resp)
  );

  logic serving_read;
  logic serving_write;

  assign serving_read = axil_req.ar_valid & axil_resp.ar_ready
                      & axil_resp.r_valid & axil_req.r_ready;

  assign serving_write = axil_req.aw_valid & axil_resp.aw_ready
                       & axil_req.w_valid & axil_resp.w_ready
                       & axil_resp.b_valid & axil_req.b_ready
                       & ~serving_read;

  assign axil_resp.aw_ready = axil_req.aw_valid & axil_req.w_valid & axil_req.b_ready;
  assign axil_resp.w_ready = axil_resp.aw_ready;
  assign axil_resp.b_valid = axil_resp.aw_ready;
  assign axil_resp.ar_ready = axil_req.ar_valid & axil_req.r_ready;
  assign axil_resp.r_valid = axil_resp.ar_ready;

  // logic [(1+AW-3)-1:0] mem_addr;
  logic [AW-3:0] mem_addr;

  assign mem_addr = serving_write
                  ? {axil_req.aw.prot[1], axil_req.aw.addr[AW-1:3]}
                  : {axil_req.ar.prot[1], axil_req.ar.addr[AW-1:3]};

  assign axil_resp.r.resp = '0;
  assign axil_resp.b.resp = '0;

  block_memory #(
      .VERIF_ONLY(1),
      .RESETTABLE(0),
      .ADDR_WIDTH(AW-2),
      .DATA_WIDTH(DW),
      .NUM_ROW   (1024),
      .NUM_COL   ((DW+31)/32)
  ) u_mem (
      .clk_i(clk_i),
      .arst_ni(arst_ni),
      .addr_i(mem_addr),
      .wdata_i(axil_req.w.data),
      .be_i(axil_req.w.strb),
      .we_i(serving_write),
      .rdata_o(axil_resp.r.data)
  );

`ifdef SIMULATION

  function automatic void write_mem(input logic [63:0] addr, input logic [7:0] data);
    if (u_mem.VERIF_ONLY) begin
      u_mem.g_vip.mem[addr] = data;
    end else begin
      // TODO
    end
  endfunction

  function automatic logic [7:0] read_mem(input logic [63:0] addr);
    if (u_mem.VERIF_ONLY) begin
      return u_mem.g_vip.mem[addr];
    end else begin
      // TODO
    end
  endfunction

`endif

endmodule
