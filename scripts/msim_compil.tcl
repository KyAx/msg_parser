

# Compiling every files

set library_file_list {
                           work  {
						   
						   
						   				../../sim/csv_file_reader_pkg.vhd
										
						   				../../src/fifo/ces_util_pkg.vhd
						   				../../src/fifo/ces_util_ram_crw_crw.vhd
										../../src/fifo/ces_util_ram_cr_cw_ratio.vhd
										../../src/fifo/ces_util_ccd_resync.vhd
										../../src/fifo/ces_util_fifo.vhd
										
										../../src/msg_parser.vhd
										
										../../sim/msg_parser_tb.vhd


										   }
}
set top_level              work.msg_parser_tb

# After sourcing the script from ModelSim for the
# first time use these commands to recompile.

proc r  {} {uplevel #0 source ../msim_compil.tcl}
proc rr {} {global last_compile_time
            set last_compile_time 0
            r                            }
proc q  {} {quit -force                  }

#Does this installation support Tk?
set tk_ok 1
if [catch {package require Tk}] {set tk_ok 0}

# Prefer a fixed point font for the transcript
set PrefMain(font) {Courier 10 roman normal}

# Compile out of date files
set time_now [clock seconds]
if [catch {set last_compile_time}] {
  set last_compile_time 0
}
foreach {library file_list} $library_file_list {
  vlib $library
  vmap work $library
  foreach file $file_list {
    if { $last_compile_time < [file mtime $file] } {
      if [regexp {.vhdl?$} $file] {
        vcom -2008 $file
      } else {
        vlog $file
      }
      set last_compile_time 0
    }
  }
}
set last_compile_time $time_now

# Load the simulation
eval vsim $top_level

do ../../sim/msg_parser_tb.do

# Run the simulation
run 4us -all 

puts {
  Script commands are:

  r = Recompile changed and dependent files
 rr = Recompile everything
  q = Quit without confirmation
}

