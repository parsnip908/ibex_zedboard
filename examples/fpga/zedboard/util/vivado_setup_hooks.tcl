# Copyright lowRISC contributors.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

# Setup hook scripts, to be called at various stages during the build process
# See Xilinx UG 894 ("Using Tcl Scripting") for documentation.

# fusesoc-generated workroot containing the Vivado project file
set workroot [pwd]
set vlogparam_list [get_property generic [get_filesets sources_1]]
set FPGAPowerAnalysis [regexp {FPGAPowerAnalysis} $vlogparam_list]
if {$FPGAPowerAnalysis == 1} {
        set_property STEPS.WRITE_BITSTREAM.TCL.PRE "${workroot}/vivado_hook_write_bitstream_pre.tcl" [get_runs impl_1]
}

puts "hello!!"
puts [pwd]
import_file "C:/Users/pkhar/Documents/hw/hw.srcs/sources_1/imports/src/other/characterLib.coe"
import_file "C:/Users/pkhar/Documents/hw/hw.srcs/sources_1/imports/src/other/init_sequence.coe"
puts "coeDone"
import_ip "C:/Users/pkhar/Documents/hw/hw.srcs/sources_1/ip/charLib/charLib.xci"
import_ip "C:/Users/pkhar/Documents/hw/hw.srcs/sources_1/ip/init_sequence_rom/init_sequence_rom.xci"
import_ip "C:/Users/pkhar/Documents/hw/hw.srcs/sources_1/ip/pixel_buffer/pixel_buffer.xci"