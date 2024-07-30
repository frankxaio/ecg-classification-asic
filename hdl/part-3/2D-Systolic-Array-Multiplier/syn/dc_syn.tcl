#################### Specifying Library & DC_Setup ##########################
set_app_var designer "Ming-Hong Xiao"
set_app_var company "ELE. CGU."
set_app_var search_path "./\
                         /opt/Synopsys/Synplify2015/libraries/syn \
                         /opt/Synopsys/Synplify2015/minpower/syn \
                         /opt/Synopsys/Synplify2015/dw/syn_ver \
                         /opt/Synopsys/Synplify2015/dw/sim_ver \
                         /opt/Foundary_Library/TSMC90/aci/sc-x/synopsys \
                         $search_path"
set_app_var link_library "fast.db \
                          fast_leakage.db \
                          fastz.db slow.db \
                          typical.db \
                          typical_leakage.db"
set_app_var target_library "fast.db \
                            fast_leakage.db \
                            fastz.db \
                            slow.db \
                            typical.db \
                            typical_leakage.db"
set_app_var symbol_library "generic.sdb"
set_app_var synthetic_library "fast.db \
                               fast_leakage.db \
                               fastz.db \
                               slow.db \
                               typical.db \
                               typical_leakage.db"

set_min_lib slow.db -min fast.db
# set_min_lib tpz973gvwc.db -min tpz973gvbc.db

# set hdlin_translate_off_skip_text "TRUE"
# set edifout_netlist_only "TRUE"
# set verilogout_no_tri true
# set plot_command {lpr -Plp}

history keep 100
alias h history

#################### Sourcing Design ##########################

set mydesign topSystolicArray 
# sh rm -rf ./Elm
# sh mkdir ./Elm
# define_design_lib Elm -path ./Elm

analyze -format sverilog ../rtl/$mydesign\.sv
analyze -format sverilog ../rtl/pe.sv
analyze -format sverilog ../rtl/systolicArray.sv

# elaborate $mydesign -architecture sverilog -library Elm
elaborate $mydesign 

#################### Set the current_design ##########################
current_design $mydesign
link
uniquify


#################### Setting Clock Constraints ##########################
create_clock -name clk -period 19 [get_ports i_clk]
set_dont_touch_network [get_clocks i_clk]
set_fix_hold [get_clocks i_clk]
set_clock_uncertainty 0.1 [get_clocks i_clk]
set_input_transition 0.5 [all_inputs]
set_clock_transition 0.1 [all_clocks]
#set_input_delay 0 [all_inputs]
#set_output_delay 0 [all_outputs]

#################### Setting Design Environment ##########################
set_operating_conditions -min_library fast -min fast -max_library slow -max slow
set_wire_load_model -name tsmc90_wl10 -library slow
set_wire_load_mode top

# set_load [load_of "tpz973gvwc/PD00BCG/I"] [all_outputs]
# set_drive [drive_of "tpz973gvwc/PDIDGZ/C"] [all_inputs]
set_drive 5 [all_inputs]
set_load 30 [all_outputs]

#################### Setting DRC Constraint ##########################
set_max_area 0
#set_max_fanout 2 [all_inputs]

set_max_fanout 6 $mydesign
set_fix_multiple_port_nets -all -buffer_constants [get_designs "*"]
check_design

#################### Compile the Design ##########################
#compile -map_effort medium -area_effort medium
compile -boundary_optimization

current_design [get_designs $mydesign]

remove_unconnected_ports -blast_buses [get_cells * -hier]
set bus_inference_style {%s[%d]}
set bus_naming_style {%s[%d]}
set hdlout_internal_busses true
change_names -hierarchy -rule verilog

define_name_ruls name_rule -allowed {a-z A-Z 0-9 _} -max_length 256 -type cell 
define_name_ruls name_rule -allowed {a-z A-Z 0-9 _[]} -max_length 256 -type net 
define_name_ruls name_rule -map {{"\\*cell\\*" "cell"}}
define_name_ruls name_rule -case_insensitive
change_names -hierarchy -rules name_rule

report_constraint -all_violators 
report_timing 
report_area 
report_power 
report_reference

write -format verilog -hierarchy -output "$mydesign\.vg"
write_sdf -version 1.7 $mydesign\.sdf
write_sdc -version 1.9 $mydesign\.sdc

# exit

