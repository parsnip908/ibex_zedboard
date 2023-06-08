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
import_file "${workroot}/../src/lowrisc_ibex_top_zedboard_0.1/imports/other/characterLib.coe"
import_file "${workroot}/../src/lowrisc_ibex_top_zedboard_0.1/imports/other/init_sequence.coe"
puts "coeDone"
import_ip "C:/Users/pkhar/Documents/2022-23_School_Work/EEC181/ibex_zedboard/examples/fpga/zedboard/ip/charLib/charLib.xci"
import_ip "C:/Users/pkhar/Documents/2022-23_School_Work/EEC181/ibex_zedboard/examples/fpga/zedboard/ip/init_sequence_rom/init_sequence_rom.xci"
import_ip "C:/Users/pkhar/Documents/2022-23_School_Work/EEC181/ibex_zedboard/examples/fpga/zedboard/ip/pixel_buffer/pixel_buffer.xci"
puts "xciDone"

# C:/Users/pkhar/Documents/2022-23_School_Work/EEC181/ibex_zedboard/examples/fpga/zedboard/
# ${workroot}/../src/lowrisc_ibex_top_zedboard_0.1/other/
# C:\Users\pkhar\Documents\2022-23_School_Work\EEC181\ibex_zedboard\build\lowrisc_ibex_top_zedboard_0.1\synth-vivado\lowrisc_ibex_top_zedboard_0.1.srcs\sources_1\imports\other
# C:\Users\pkhar\Documents\2022-23_School_Work\EEC181\ibex_zedboard\build\lowrisc_ibex_top_zedboard_0.1\src\lowrisc_ibex_top_zedboard_0.1\other