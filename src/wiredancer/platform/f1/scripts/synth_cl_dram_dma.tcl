# Amazon FPGA Hardware Development Kit
#
# Copyright 2016 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Amazon Software License (the "License"). You may not use
# this file except in compliance with the License. A copy of the License is
# located at
#
#    http://aws.amazon.com/asl/
#
# or in the "license" file accompanying this file. This file is distributed on
# an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, express or
# implied. See the License for the specific language governing permissions and
# limitations under the License.

#Param needed to avoid clock name collisions
set_param sta.enableAutoGenClkNamePersistence 0
set CL_MODULE $CL_MODULE
set VDEFINES $VDEFINES

create_project -in_memory -part [DEVICE_TYPE] -force

########################################
## Generate clocks based on Recipe
########################################

puts "AWS FPGA: ([clock format [clock seconds] -format %T]) Calling aws_gen_clk_constraints.tcl to generate clock constraints from developer's specified recipe.";

source $HDK_SHELL_DIR/build/scripts/aws_gen_clk_constraints.tcl

#############################
## Read design files
#############################

#Convenience to set the root of the RTL directory
set ENC_SRC_DIR $CL_DIR/build/src_post_encryption
set TARGET_DIR $CL_DIR/build/src_post_encryption
set UNUSED_TEMPLATES_DIR $HDK_SHELL_DESIGN_DIR/interfaces

puts "AWS FPGA: ([clock format [clock seconds] -format %T]) Reading developer's Custom Logic files post encryption.";

#---- User would replace this section -----

# Reading the .sv and .v files, as proper designs would not require
# reading .v, .vh, nor .inc files

# read_verilog -sv [glob $ENC_SRC_DIR/*.?v]

#---- End of section replaced by User ----

puts "AWS FPGA: Reading AWS Shell design";

#Read AWS Design files
read_verilog -sv [ list \
  $HDK_SHELL_DESIGN_DIR/lib/lib_pipe.sv \
  $HDK_SHELL_DESIGN_DIR/lib/bram_2rw.sv \
  $HDK_SHELL_DESIGN_DIR/lib/flop_fifo.sv \
  $HDK_SHELL_DESIGN_DIR/sh_ddr/synth/sync.v \
  $HDK_SHELL_DESIGN_DIR/sh_ddr/synth/flop_ccf.sv \
  $HDK_SHELL_DESIGN_DIR/sh_ddr/synth/ccf_ctl.v \
  $HDK_SHELL_DESIGN_DIR/sh_ddr/synth/mgt_acc_axl.sv  \
  $HDK_SHELL_DESIGN_DIR/sh_ddr/synth/mgt_gen_axl.sv  \
  $HDK_SHELL_DESIGN_DIR/sh_ddr/synth/sh_ddr.sv \
  $HDK_SHELL_DESIGN_DIR/interfaces/cl_ports.vh
]

file copy -force $UNUSED_TEMPLATES_DIR/unused_sh_bar1_template.inc        $CL_DIR/design
file copy -force $UNUSED_TEMPLATES_DIR/unused_flr_template.inc            $CL_DIR/design
file copy -force $UNUSED_TEMPLATES_DIR/unused_cl_sda_template.inc         $CL_DIR/design
file copy -force $UNUSED_TEMPLATES_DIR/unused_apppf_irq_template.inc      $CL_DIR/design

read_verilog -sv $CL_DIR/design/cl_dram_dma.sv
# read_verilog -sv $CL_DIR/design/cl_hello_world_defines.vh
# read_verilog -sv $CL_DIR/design/cl_id_defines.vh

read_verilog -sv $CL_DIR/design/areset_sync.sv
read_verilog -sv $CL_DIR/design/simple_dual_port_ram.sv
read_verilog -sv $CL_DIR/design/showahead_fifo.sv
read_verilog -sv $CL_DIR/design/dual_clock_showahead_fifo.sv
read_verilog -sv $CL_DIR/design/wd_pkg.sv
read_verilog -sv $CL_DIR/design/pcie_inorder.sv
read_verilog -sv $CL_DIR/design/pcie_tr_ext.sv
read_verilog -sv $CL_DIR/design/tid_inorder.sv
read_verilog -sv $CL_DIR/design/key_store.sv
read_verilog -sv $CL_DIR/design/dma_result.sv
read_verilog -sv $CL_DIR/design/sha512_pre.sv
read_verilog -sv $CL_DIR/design/sha512_sch.sv
read_verilog -sv $CL_DIR/design/sha512_msgseq.sv
read_verilog -sv $CL_DIR/design/sha512_round.sv
read_verilog -sv $CL_DIR/design/sha512_block.sv
read_verilog -sv $CL_DIR/design/sha512_modq.sv
read_verilog -sv $CL_DIR/design/sha512_modq_meta.sv
read_verilog -sv $CL_DIR/design/mul_wide.sv
read_verilog -sv $CL_DIR/design/schl_cpu_instr_rom.sv
read_verilog -sv $CL_DIR/design/schl_cpu.sv
read_verilog -sv $CL_DIR/design/ed25519_add_modp.sv
read_verilog -sv $CL_DIR/design/ed25519_sub_modp.sv
read_verilog -sv $CL_DIR/design/ed25519_mul_modp.sv
read_verilog -sv $CL_DIR/design/ed25519_point_add.sv
read_verilog -sv $CL_DIR/design/ed25519_point_dbl.sv
read_verilog -sv $CL_DIR/design/ed25519_sigverify_dsdp_mul.sv
read_verilog -sv $CL_DIR/design/ed25519_sigverify_ecc.sv
read_verilog -sv $CL_DIR/design/ed25519_sigverify_0.sv
read_verilog -sv $CL_DIR/design/ed25519_sigverify_1.sv
read_verilog -sv $CL_DIR/design/ed25519_sigverify_2.sv
read_verilog -sv $CL_DIR/design/top_f1.sv


puts "AWS FPGA: Reading IP blocks";

#Read DDR IP
read_ip [ list \
  $HDK_SHELL_DESIGN_DIR/ip/ddr4_core/ddr4_core.xci
]

#Read IP for axi register slices
read_ip [ list \
  $HDK_SHELL_DESIGN_DIR/ip/src_register_slice/src_register_slice.xci \
  $HDK_SHELL_DESIGN_DIR/ip/dest_register_slice/dest_register_slice.xci \
  $HDK_SHELL_DESIGN_DIR/ip/axi_clock_converter_0/axi_clock_converter_0.xci \
  $HDK_SHELL_DESIGN_DIR/ip/axi_register_slice/axi_register_slice.xci \
  $HDK_SHELL_DESIGN_DIR/ip/axi_register_slice_light/axi_register_slice_light.xci
]

#Read IP for virtual jtag / ILA/VIO
read_ip [ list \
  $HDK_SHELL_DESIGN_DIR/ip/cl_debug_bridge/cl_debug_bridge.xci \
  $HDK_SHELL_DESIGN_DIR/ip/ila_1/ila_1.xci \
  $HDK_SHELL_DESIGN_DIR/ip/ila_vio_counter/ila_vio_counter.xci \
  $HDK_SHELL_DESIGN_DIR/ip/vio_0/vio_0.xci
]

# Additional IP's that might be needed if using the DDR
read_bd [ list \
  $HDK_SHELL_DESIGN_DIR/ip/cl_axi_interconnect/cl_axi_interconnect.bd
]

puts "AWS FPGA: Reading AWS constraints";

#Read all the constraints
#
#  cl_clocks_aws.xdc  - AWS auto-generated clock constraint.   ***DO NOT MODIFY***
#  cl_ddr.xdc         - AWS provided DDR pin constraints.      ***DO NOT MODIFY***
#  cl_synth_user.xdc  - Developer synthesis constraints.
read_xdc [ list \
   $CL_DIR/build/constraints/cl_clocks_aws.xdc \
   $HDK_SHELL_DIR/build/constraints/cl_ddr.xdc \
   $HDK_SHELL_DIR/build/constraints/cl_synth_aws.xdc \
   $CL_DIR/build/constraints/cl_synth_user.xdc
]

#Do not propagate local clock constraints for clocks generated in the SH
set_property USED_IN {synthesis implementation OUT_OF_CONTEXT} [get_files cl_clocks_aws.xdc]
set_property PROCESSING_ORDER EARLY  [get_files cl_clocks_aws.xdc]

########################
# CL Synthesis
########################
puts "AWS FPGA: ([clock format [clock seconds] -format %T]) Start design synthesis.";

update_compile_order -fileset sources_1
puts "\nRunning synth_design for $CL_MODULE $CL_DIR/build/scripts \[[clock format [clock seconds] -format {%a %b %d %H:%M:%S %Y}]\]"
# eval [concat synth_design -include_dirs "{$CL_DIR/design}" -top $CL_MODULE -verilog_define XSDB_SLV_DIS $VDEFINES -part [DEVICE_TYPE] -mode out_of_context $synth_options -directive $synth_directive -strategy strategy]
eval [concat synth_design -verilog_define PATH_TO_INSTR_ROM_MIF=\"$CL_DIR/design/schl_cpu_instr_rom.mif\" -include_dirs "{$CL_DIR/design}" -top $CL_MODULE -verilog_define XSDB_SLV_DIS $VDEFINES -part [DEVICE_TYPE] -mode out_of_context $synth_options -directive $synth_directive]

set failval [catch {exec grep "FAIL" failfast.csv}]
if { $failval==0 } {
	puts "AWS FPGA: FATAL ERROR--Resource utilization error; check failfast.csv for details"
	exit 1
}

#read_xdc $CL_DIR/build/constraints/cl_pnr_user.xdc

puts "AWS FPGA: ([clock format [clock seconds] -format %T]) writing post synth checkpoint.";
write_checkpoint -force $CL_DIR/build/checkpoints/${timestamp}.CL.post_synth.dcp

close_project
#Set param back to default value
set_param sta.enableAutoGenClkNamePersistence 1
