// ==============================================================
// Generated by Vitis HLS v2023.2
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
// ==============================================================

`timescale 1 ns / 1 ps 

(* CORE_GENERATION_INFO="conv_conv,hls_ip_2023_2,{HLS_INPUT_TYPE=cxx,HLS_INPUT_FLOAT=0,HLS_INPUT_FIXED=0,HLS_INPUT_PART=xc7z010-clg400-1,HLS_INPUT_CLOCK=10.000000,HLS_INPUT_ARCH=dataflow,HLS_SYN_CLOCK=8.222600,HLS_SYN_LAT=-1,HLS_SYN_TPT=-1,HLS_SYN_MEM=30,HLS_SYN_DSP=0,HLS_SYN_FF=3110,HLS_SYN_LUT=6436,HLS_VERSION=2023_2}" *)

module conv (
        s_axi_control_AWVALID,
        s_axi_control_AWREADY,
        s_axi_control_AWADDR,
        s_axi_control_WVALID,
        s_axi_control_WREADY,
        s_axi_control_WDATA,
        s_axi_control_WSTRB,
        s_axi_control_ARVALID,
        s_axi_control_ARREADY,
        s_axi_control_ARADDR,
        s_axi_control_RVALID,
        s_axi_control_RREADY,
        s_axi_control_RDATA,
        s_axi_control_RRESP,
        s_axi_control_BVALID,
        s_axi_control_BREADY,
        s_axi_control_BRESP,
        ap_clk,
        ap_rst_n,
        interrupt,
        m_axi_gmem_AWVALID,
        m_axi_gmem_AWREADY,
        m_axi_gmem_AWADDR,
        m_axi_gmem_AWID,
        m_axi_gmem_AWLEN,
        m_axi_gmem_AWSIZE,
        m_axi_gmem_AWBURST,
        m_axi_gmem_AWLOCK,
        m_axi_gmem_AWCACHE,
        m_axi_gmem_AWPROT,
        m_axi_gmem_AWQOS,
        m_axi_gmem_AWREGION,
        m_axi_gmem_AWUSER,
        m_axi_gmem_WVALID,
        m_axi_gmem_WREADY,
        m_axi_gmem_WDATA,
        m_axi_gmem_WSTRB,
        m_axi_gmem_WLAST,
        m_axi_gmem_WID,
        m_axi_gmem_WUSER,
        m_axi_gmem_ARVALID,
        m_axi_gmem_ARREADY,
        m_axi_gmem_ARADDR,
        m_axi_gmem_ARID,
        m_axi_gmem_ARLEN,
        m_axi_gmem_ARSIZE,
        m_axi_gmem_ARBURST,
        m_axi_gmem_ARLOCK,
        m_axi_gmem_ARCACHE,
        m_axi_gmem_ARPROT,
        m_axi_gmem_ARQOS,
        m_axi_gmem_ARREGION,
        m_axi_gmem_ARUSER,
        m_axi_gmem_RVALID,
        m_axi_gmem_RREADY,
        m_axi_gmem_RDATA,
        m_axi_gmem_RLAST,
        m_axi_gmem_RID,
        m_axi_gmem_RUSER,
        m_axi_gmem_RRESP,
        m_axi_gmem_BVALID,
        m_axi_gmem_BREADY,
        m_axi_gmem_BRESP,
        m_axi_gmem_BID,
        m_axi_gmem_BUSER
);

parameter    C_S_AXI_CONTROL_DATA_WIDTH = 32;
parameter    C_S_AXI_CONTROL_ADDR_WIDTH = 6;
parameter    C_S_AXI_DATA_WIDTH = 32;
parameter    C_M_AXI_GMEM_ID_WIDTH = 1;
parameter    C_M_AXI_GMEM_ADDR_WIDTH = 64;
parameter    C_M_AXI_GMEM_DATA_WIDTH = 256;
parameter    C_M_AXI_GMEM_AWUSER_WIDTH = 1;
parameter    C_M_AXI_GMEM_ARUSER_WIDTH = 1;
parameter    C_M_AXI_GMEM_WUSER_WIDTH = 1;
parameter    C_M_AXI_GMEM_RUSER_WIDTH = 1;
parameter    C_M_AXI_GMEM_BUSER_WIDTH = 1;
parameter    C_M_AXI_GMEM_USER_VALUE = 0;
parameter    C_M_AXI_GMEM_PROT_VALUE = 0;
parameter    C_M_AXI_GMEM_CACHE_VALUE = 3;
parameter    C_M_AXI_DATA_WIDTH = 32;

parameter C_S_AXI_CONTROL_WSTRB_WIDTH = (32 / 8);
parameter C_S_AXI_WSTRB_WIDTH = (32 / 8);
parameter C_M_AXI_GMEM_WSTRB_WIDTH = (256 / 8);
parameter C_M_AXI_WSTRB_WIDTH = (32 / 8);

input   s_axi_control_AWVALID;
output   s_axi_control_AWREADY;
input  [C_S_AXI_CONTROL_ADDR_WIDTH - 1:0] s_axi_control_AWADDR;
input   s_axi_control_WVALID;
output   s_axi_control_WREADY;
input  [C_S_AXI_CONTROL_DATA_WIDTH - 1:0] s_axi_control_WDATA;
input  [C_S_AXI_CONTROL_WSTRB_WIDTH - 1:0] s_axi_control_WSTRB;
input   s_axi_control_ARVALID;
output   s_axi_control_ARREADY;
input  [C_S_AXI_CONTROL_ADDR_WIDTH - 1:0] s_axi_control_ARADDR;
output   s_axi_control_RVALID;
input   s_axi_control_RREADY;
output  [C_S_AXI_CONTROL_DATA_WIDTH - 1:0] s_axi_control_RDATA;
output  [1:0] s_axi_control_RRESP;
output   s_axi_control_BVALID;
input   s_axi_control_BREADY;
output  [1:0] s_axi_control_BRESP;
input   ap_clk;
input   ap_rst_n;
output   interrupt;
output   m_axi_gmem_AWVALID;
input   m_axi_gmem_AWREADY;
output  [C_M_AXI_GMEM_ADDR_WIDTH - 1:0] m_axi_gmem_AWADDR;
output  [C_M_AXI_GMEM_ID_WIDTH - 1:0] m_axi_gmem_AWID;
output  [7:0] m_axi_gmem_AWLEN;
output  [2:0] m_axi_gmem_AWSIZE;
output  [1:0] m_axi_gmem_AWBURST;
output  [1:0] m_axi_gmem_AWLOCK;
output  [3:0] m_axi_gmem_AWCACHE;
output  [2:0] m_axi_gmem_AWPROT;
output  [3:0] m_axi_gmem_AWQOS;
output  [3:0] m_axi_gmem_AWREGION;
output  [C_M_AXI_GMEM_AWUSER_WIDTH - 1:0] m_axi_gmem_AWUSER;
output   m_axi_gmem_WVALID;
input   m_axi_gmem_WREADY;
output  [C_M_AXI_GMEM_DATA_WIDTH - 1:0] m_axi_gmem_WDATA;
output  [C_M_AXI_GMEM_WSTRB_WIDTH - 1:0] m_axi_gmem_WSTRB;
output   m_axi_gmem_WLAST;
output  [C_M_AXI_GMEM_ID_WIDTH - 1:0] m_axi_gmem_WID;
output  [C_M_AXI_GMEM_WUSER_WIDTH - 1:0] m_axi_gmem_WUSER;
output   m_axi_gmem_ARVALID;
input   m_axi_gmem_ARREADY;
output  [C_M_AXI_GMEM_ADDR_WIDTH - 1:0] m_axi_gmem_ARADDR;
output  [C_M_AXI_GMEM_ID_WIDTH - 1:0] m_axi_gmem_ARID;
output  [7:0] m_axi_gmem_ARLEN;
output  [2:0] m_axi_gmem_ARSIZE;
output  [1:0] m_axi_gmem_ARBURST;
output  [1:0] m_axi_gmem_ARLOCK;
output  [3:0] m_axi_gmem_ARCACHE;
output  [2:0] m_axi_gmem_ARPROT;
output  [3:0] m_axi_gmem_ARQOS;
output  [3:0] m_axi_gmem_ARREGION;
output  [C_M_AXI_GMEM_ARUSER_WIDTH - 1:0] m_axi_gmem_ARUSER;
input   m_axi_gmem_RVALID;
output   m_axi_gmem_RREADY;
input  [C_M_AXI_GMEM_DATA_WIDTH - 1:0] m_axi_gmem_RDATA;
input   m_axi_gmem_RLAST;
input  [C_M_AXI_GMEM_ID_WIDTH - 1:0] m_axi_gmem_RID;
input  [C_M_AXI_GMEM_RUSER_WIDTH - 1:0] m_axi_gmem_RUSER;
input  [1:0] m_axi_gmem_RRESP;
input   m_axi_gmem_BVALID;
output   m_axi_gmem_BREADY;
input  [1:0] m_axi_gmem_BRESP;
input  [C_M_AXI_GMEM_ID_WIDTH - 1:0] m_axi_gmem_BID;
input  [C_M_AXI_GMEM_BUSER_WIDTH - 1:0] m_axi_gmem_BUSER;

(* shreg_extract = "no" *) reg    ap_rst_reg_2;
(* shreg_extract = "no" *) reg    ap_rst_reg_1;
(* shreg_extract = "no" *) reg    ap_rst_n_inv;
wire   [63:0] input_r;
wire   [63:0] filter;
wire   [63:0] output_r;
wire    ap_start;
wire    ap_ready;
wire    ap_done;
wire    ap_continue;
wire    ap_idle;
wire    gmem_AWREADY;
wire    gmem_WREADY;
wire    gmem_ARREADY;
wire    gmem_RVALID;
wire   [255:0] gmem_RDATA;
wire    gmem_RLAST;
wire   [0:0] gmem_RID;
wire   [8:0] gmem_RFIFONUM;
wire   [0:0] gmem_RUSER;
wire   [1:0] gmem_RRESP;
wire    gmem_BVALID;
wire   [1:0] gmem_BRESP;
wire   [0:0] gmem_BID;
wire   [0:0] gmem_BUSER;
wire    Block_entry1735_proc116_U0_ap_start;
wire    Block_entry1735_proc116_U0_ap_done;
wire    Block_entry1735_proc116_U0_ap_continue;
wire    Block_entry1735_proc116_U0_ap_idle;
wire    Block_entry1735_proc116_U0_ap_ready;
wire    Block_entry1735_proc116_U0_m_axi_gmem_AWVALID;
wire   [63:0] Block_entry1735_proc116_U0_m_axi_gmem_AWADDR;
wire   [0:0] Block_entry1735_proc116_U0_m_axi_gmem_AWID;
wire   [31:0] Block_entry1735_proc116_U0_m_axi_gmem_AWLEN;
wire   [2:0] Block_entry1735_proc116_U0_m_axi_gmem_AWSIZE;
wire   [1:0] Block_entry1735_proc116_U0_m_axi_gmem_AWBURST;
wire   [1:0] Block_entry1735_proc116_U0_m_axi_gmem_AWLOCK;
wire   [3:0] Block_entry1735_proc116_U0_m_axi_gmem_AWCACHE;
wire   [2:0] Block_entry1735_proc116_U0_m_axi_gmem_AWPROT;
wire   [3:0] Block_entry1735_proc116_U0_m_axi_gmem_AWQOS;
wire   [3:0] Block_entry1735_proc116_U0_m_axi_gmem_AWREGION;
wire   [0:0] Block_entry1735_proc116_U0_m_axi_gmem_AWUSER;
wire    Block_entry1735_proc116_U0_m_axi_gmem_WVALID;
wire   [255:0] Block_entry1735_proc116_U0_m_axi_gmem_WDATA;
wire   [31:0] Block_entry1735_proc116_U0_m_axi_gmem_WSTRB;
wire    Block_entry1735_proc116_U0_m_axi_gmem_WLAST;
wire   [0:0] Block_entry1735_proc116_U0_m_axi_gmem_WID;
wire   [0:0] Block_entry1735_proc116_U0_m_axi_gmem_WUSER;
wire    Block_entry1735_proc116_U0_m_axi_gmem_ARVALID;
wire   [63:0] Block_entry1735_proc116_U0_m_axi_gmem_ARADDR;
wire   [0:0] Block_entry1735_proc116_U0_m_axi_gmem_ARID;
wire   [31:0] Block_entry1735_proc116_U0_m_axi_gmem_ARLEN;
wire   [2:0] Block_entry1735_proc116_U0_m_axi_gmem_ARSIZE;
wire   [1:0] Block_entry1735_proc116_U0_m_axi_gmem_ARBURST;
wire   [1:0] Block_entry1735_proc116_U0_m_axi_gmem_ARLOCK;
wire   [3:0] Block_entry1735_proc116_U0_m_axi_gmem_ARCACHE;
wire   [2:0] Block_entry1735_proc116_U0_m_axi_gmem_ARPROT;
wire   [3:0] Block_entry1735_proc116_U0_m_axi_gmem_ARQOS;
wire   [3:0] Block_entry1735_proc116_U0_m_axi_gmem_ARREGION;
wire   [0:0] Block_entry1735_proc116_U0_m_axi_gmem_ARUSER;
wire    Block_entry1735_proc116_U0_m_axi_gmem_RREADY;
wire    Block_entry1735_proc116_U0_m_axi_gmem_BREADY;

// power-on initialization
initial begin
#0 ap_rst_reg_2 = 1'b1;
#0 ap_rst_reg_1 = 1'b1;
#0 ap_rst_n_inv = 1'b1;
end

conv_control_s_axi #(
    .C_S_AXI_ADDR_WIDTH( C_S_AXI_CONTROL_ADDR_WIDTH ),
    .C_S_AXI_DATA_WIDTH( C_S_AXI_CONTROL_DATA_WIDTH ))
control_s_axi_U(
    .AWVALID(s_axi_control_AWVALID),
    .AWREADY(s_axi_control_AWREADY),
    .AWADDR(s_axi_control_AWADDR),
    .WVALID(s_axi_control_WVALID),
    .WREADY(s_axi_control_WREADY),
    .WDATA(s_axi_control_WDATA),
    .WSTRB(s_axi_control_WSTRB),
    .ARVALID(s_axi_control_ARVALID),
    .ARREADY(s_axi_control_ARREADY),
    .ARADDR(s_axi_control_ARADDR),
    .RVALID(s_axi_control_RVALID),
    .RREADY(s_axi_control_RREADY),
    .RDATA(s_axi_control_RDATA),
    .RRESP(s_axi_control_RRESP),
    .BVALID(s_axi_control_BVALID),
    .BREADY(s_axi_control_BREADY),
    .BRESP(s_axi_control_BRESP),
    .ACLK(ap_clk),
    .ARESET(ap_rst_n_inv),
    .ACLK_EN(1'b1),
    .input_r(input_r),
    .filter(filter),
    .output_r(output_r),
    .ap_start(ap_start),
    .interrupt(interrupt),
    .ap_ready(ap_ready),
    .ap_done(ap_done),
    .ap_continue(ap_continue),
    .ap_idle(ap_idle)
);

conv_gmem_m_axi #(
    .CONSERVATIVE( 1 ),
    .USER_MAXREQS( 70 ),
    .MAX_READ_BURST_LENGTH( 16 ),
    .MAX_WRITE_BURST_LENGTH( 16 ),
    .C_M_AXI_ID_WIDTH( C_M_AXI_GMEM_ID_WIDTH ),
    .C_M_AXI_ADDR_WIDTH( C_M_AXI_GMEM_ADDR_WIDTH ),
    .C_M_AXI_DATA_WIDTH( C_M_AXI_GMEM_DATA_WIDTH ),
    .C_M_AXI_AWUSER_WIDTH( C_M_AXI_GMEM_AWUSER_WIDTH ),
    .C_M_AXI_ARUSER_WIDTH( C_M_AXI_GMEM_ARUSER_WIDTH ),
    .C_M_AXI_WUSER_WIDTH( C_M_AXI_GMEM_WUSER_WIDTH ),
    .C_M_AXI_RUSER_WIDTH( C_M_AXI_GMEM_RUSER_WIDTH ),
    .C_M_AXI_BUSER_WIDTH( C_M_AXI_GMEM_BUSER_WIDTH ),
    .C_USER_VALUE( C_M_AXI_GMEM_USER_VALUE ),
    .C_PROT_VALUE( C_M_AXI_GMEM_PROT_VALUE ),
    .C_CACHE_VALUE( C_M_AXI_GMEM_CACHE_VALUE ),
    .USER_RFIFONUM_WIDTH( 9 ),
    .USER_DW( 256 ),
    .USER_AW( 64 ),
    .NUM_READ_OUTSTANDING( 16 ),
    .NUM_WRITE_OUTSTANDING( 16 ))
gmem_m_axi_U(
    .AWVALID(m_axi_gmem_AWVALID),
    .AWREADY(m_axi_gmem_AWREADY),
    .AWADDR(m_axi_gmem_AWADDR),
    .AWID(m_axi_gmem_AWID),
    .AWLEN(m_axi_gmem_AWLEN),
    .AWSIZE(m_axi_gmem_AWSIZE),
    .AWBURST(m_axi_gmem_AWBURST),
    .AWLOCK(m_axi_gmem_AWLOCK),
    .AWCACHE(m_axi_gmem_AWCACHE),
    .AWPROT(m_axi_gmem_AWPROT),
    .AWQOS(m_axi_gmem_AWQOS),
    .AWREGION(m_axi_gmem_AWREGION),
    .AWUSER(m_axi_gmem_AWUSER),
    .WVALID(m_axi_gmem_WVALID),
    .WREADY(m_axi_gmem_WREADY),
    .WDATA(m_axi_gmem_WDATA),
    .WSTRB(m_axi_gmem_WSTRB),
    .WLAST(m_axi_gmem_WLAST),
    .WID(m_axi_gmem_WID),
    .WUSER(m_axi_gmem_WUSER),
    .ARVALID(m_axi_gmem_ARVALID),
    .ARREADY(m_axi_gmem_ARREADY),
    .ARADDR(m_axi_gmem_ARADDR),
    .ARID(m_axi_gmem_ARID),
    .ARLEN(m_axi_gmem_ARLEN),
    .ARSIZE(m_axi_gmem_ARSIZE),
    .ARBURST(m_axi_gmem_ARBURST),
    .ARLOCK(m_axi_gmem_ARLOCK),
    .ARCACHE(m_axi_gmem_ARCACHE),
    .ARPROT(m_axi_gmem_ARPROT),
    .ARQOS(m_axi_gmem_ARQOS),
    .ARREGION(m_axi_gmem_ARREGION),
    .ARUSER(m_axi_gmem_ARUSER),
    .RVALID(m_axi_gmem_RVALID),
    .RREADY(m_axi_gmem_RREADY),
    .RDATA(m_axi_gmem_RDATA),
    .RLAST(m_axi_gmem_RLAST),
    .RID(m_axi_gmem_RID),
    .RUSER(m_axi_gmem_RUSER),
    .RRESP(m_axi_gmem_RRESP),
    .BVALID(m_axi_gmem_BVALID),
    .BREADY(m_axi_gmem_BREADY),
    .BRESP(m_axi_gmem_BRESP),
    .BID(m_axi_gmem_BID),
    .BUSER(m_axi_gmem_BUSER),
    .ACLK(ap_clk),
    .ARESET(ap_rst_n_inv),
    .ACLK_EN(1'b1),
    .I_ARVALID(Block_entry1735_proc116_U0_m_axi_gmem_ARVALID),
    .I_ARREADY(gmem_ARREADY),
    .I_ARADDR(Block_entry1735_proc116_U0_m_axi_gmem_ARADDR),
    .I_ARLEN(Block_entry1735_proc116_U0_m_axi_gmem_ARLEN),
    .I_RVALID(gmem_RVALID),
    .I_RREADY(Block_entry1735_proc116_U0_m_axi_gmem_RREADY),
    .I_RDATA(gmem_RDATA),
    .I_RFIFONUM(gmem_RFIFONUM),
    .I_AWVALID(Block_entry1735_proc116_U0_m_axi_gmem_AWVALID),
    .I_AWREADY(gmem_AWREADY),
    .I_AWADDR(Block_entry1735_proc116_U0_m_axi_gmem_AWADDR),
    .I_AWLEN(Block_entry1735_proc116_U0_m_axi_gmem_AWLEN),
    .I_WVALID(Block_entry1735_proc116_U0_m_axi_gmem_WVALID),
    .I_WREADY(gmem_WREADY),
    .I_WDATA(Block_entry1735_proc116_U0_m_axi_gmem_WDATA),
    .I_WSTRB(Block_entry1735_proc116_U0_m_axi_gmem_WSTRB),
    .I_BVALID(gmem_BVALID),
    .I_BREADY(Block_entry1735_proc116_U0_m_axi_gmem_BREADY)
);

conv_Block_entry1735_proc116 Block_entry1735_proc116_U0(
    .ap_clk(ap_clk),
    .ap_rst(ap_rst_n_inv),
    .ap_start(Block_entry1735_proc116_U0_ap_start),
    .ap_done(Block_entry1735_proc116_U0_ap_done),
    .ap_continue(Block_entry1735_proc116_U0_ap_continue),
    .ap_idle(Block_entry1735_proc116_U0_ap_idle),
    .ap_ready(Block_entry1735_proc116_U0_ap_ready),
    .input_r(input_r),
    .m_axi_gmem_AWVALID(Block_entry1735_proc116_U0_m_axi_gmem_AWVALID),
    .m_axi_gmem_AWREADY(gmem_AWREADY),
    .m_axi_gmem_AWADDR(Block_entry1735_proc116_U0_m_axi_gmem_AWADDR),
    .m_axi_gmem_AWID(Block_entry1735_proc116_U0_m_axi_gmem_AWID),
    .m_axi_gmem_AWLEN(Block_entry1735_proc116_U0_m_axi_gmem_AWLEN),
    .m_axi_gmem_AWSIZE(Block_entry1735_proc116_U0_m_axi_gmem_AWSIZE),
    .m_axi_gmem_AWBURST(Block_entry1735_proc116_U0_m_axi_gmem_AWBURST),
    .m_axi_gmem_AWLOCK(Block_entry1735_proc116_U0_m_axi_gmem_AWLOCK),
    .m_axi_gmem_AWCACHE(Block_entry1735_proc116_U0_m_axi_gmem_AWCACHE),
    .m_axi_gmem_AWPROT(Block_entry1735_proc116_U0_m_axi_gmem_AWPROT),
    .m_axi_gmem_AWQOS(Block_entry1735_proc116_U0_m_axi_gmem_AWQOS),
    .m_axi_gmem_AWREGION(Block_entry1735_proc116_U0_m_axi_gmem_AWREGION),
    .m_axi_gmem_AWUSER(Block_entry1735_proc116_U0_m_axi_gmem_AWUSER),
    .m_axi_gmem_WVALID(Block_entry1735_proc116_U0_m_axi_gmem_WVALID),
    .m_axi_gmem_WREADY(gmem_WREADY),
    .m_axi_gmem_WDATA(Block_entry1735_proc116_U0_m_axi_gmem_WDATA),
    .m_axi_gmem_WSTRB(Block_entry1735_proc116_U0_m_axi_gmem_WSTRB),
    .m_axi_gmem_WLAST(Block_entry1735_proc116_U0_m_axi_gmem_WLAST),
    .m_axi_gmem_WID(Block_entry1735_proc116_U0_m_axi_gmem_WID),
    .m_axi_gmem_WUSER(Block_entry1735_proc116_U0_m_axi_gmem_WUSER),
    .m_axi_gmem_ARVALID(Block_entry1735_proc116_U0_m_axi_gmem_ARVALID),
    .m_axi_gmem_ARREADY(gmem_ARREADY),
    .m_axi_gmem_ARADDR(Block_entry1735_proc116_U0_m_axi_gmem_ARADDR),
    .m_axi_gmem_ARID(Block_entry1735_proc116_U0_m_axi_gmem_ARID),
    .m_axi_gmem_ARLEN(Block_entry1735_proc116_U0_m_axi_gmem_ARLEN),
    .m_axi_gmem_ARSIZE(Block_entry1735_proc116_U0_m_axi_gmem_ARSIZE),
    .m_axi_gmem_ARBURST(Block_entry1735_proc116_U0_m_axi_gmem_ARBURST),
    .m_axi_gmem_ARLOCK(Block_entry1735_proc116_U0_m_axi_gmem_ARLOCK),
    .m_axi_gmem_ARCACHE(Block_entry1735_proc116_U0_m_axi_gmem_ARCACHE),
    .m_axi_gmem_ARPROT(Block_entry1735_proc116_U0_m_axi_gmem_ARPROT),
    .m_axi_gmem_ARQOS(Block_entry1735_proc116_U0_m_axi_gmem_ARQOS),
    .m_axi_gmem_ARREGION(Block_entry1735_proc116_U0_m_axi_gmem_ARREGION),
    .m_axi_gmem_ARUSER(Block_entry1735_proc116_U0_m_axi_gmem_ARUSER),
    .m_axi_gmem_RVALID(gmem_RVALID),
    .m_axi_gmem_RREADY(Block_entry1735_proc116_U0_m_axi_gmem_RREADY),
    .m_axi_gmem_RDATA(gmem_RDATA),
    .m_axi_gmem_RLAST(gmem_RLAST),
    .m_axi_gmem_RID(gmem_RID),
    .m_axi_gmem_RFIFONUM(gmem_RFIFONUM),
    .m_axi_gmem_RUSER(gmem_RUSER),
    .m_axi_gmem_RRESP(gmem_RRESP),
    .m_axi_gmem_BVALID(gmem_BVALID),
    .m_axi_gmem_BREADY(Block_entry1735_proc116_U0_m_axi_gmem_BREADY),
    .m_axi_gmem_BRESP(gmem_BRESP),
    .m_axi_gmem_BID(gmem_BID),
    .m_axi_gmem_BUSER(gmem_BUSER),
    .filter(filter),
    .output_r(output_r)
);

always @ (posedge ap_clk) begin
    ap_rst_n_inv <= ap_rst_reg_1;
end

always @ (posedge ap_clk) begin
    ap_rst_reg_1 <= ap_rst_reg_2;
end

always @ (posedge ap_clk) begin
    ap_rst_reg_2 <= ~ap_rst_n;
end

assign Block_entry1735_proc116_U0_ap_continue = ap_continue;

assign Block_entry1735_proc116_U0_ap_start = ap_start;

assign ap_done = Block_entry1735_proc116_U0_ap_done;

assign ap_idle = Block_entry1735_proc116_U0_ap_idle;

assign ap_ready = Block_entry1735_proc116_U0_ap_ready;

assign gmem_BID = 1'd0;

assign gmem_BRESP = 2'd0;

assign gmem_BUSER = 1'd0;

assign gmem_RID = 1'd0;

assign gmem_RLAST = 1'b0;

assign gmem_RRESP = 2'd0;

assign gmem_RUSER = 1'd0;

endmodule //conv
