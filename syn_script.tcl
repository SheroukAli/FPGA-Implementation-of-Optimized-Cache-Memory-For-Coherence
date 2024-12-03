					
########################### Define Top Module ############################
                                                   
set top_module System_top

##################### Define Working Library Directory ######################
                                                   
define_design_lib work -path ./work

################## Design Compiler Library Files #setup ######################

puts "###########################################"
puts "#      #setting Design Libraries           #"
puts "###########################################"

#Add the path of the libraries to the search_path variable
lappend search_path /home/IC/tsmc_fb_cl013g_sc/aci/sc-m/synopsys


#lappend search_path /home/IC/Labs/project_final/std_cells

lappend search_path /home/IC/Labs/project_final/rtl



set SSLIB "scmetro_tsmc_cl013g_rvt_ss_1p08v_125c.db"
set TTLIB "scmetro_tsmc_cl013g_rvt_tt_1p2v_25c.db"
set FFLIB "scmetro_tsmc_cl013g_rvt_ff_1p32v_m40c.db"

## Standard Cell libraries 
set target_library [list $SSLIB $TTLIB $FFLIB]

## Standard Cell & Hard Macros libraries 
set link_library [list * $SSLIB $TTLIB $FFLIB]  

######################## Reading RTL Files #################################

puts "###########################################"
puts "#             Reading RTL Files           #"
puts "###########################################"

set file_format verilog

read_file -format $file_format LRU_of_Cache2.v
read_file -format $file_format LRU.v
read_file -format $file_format L2_cache.v
read_file -format $file_format Main_memory.v

read_file -format $file_format Controller.v
read_file -format $file_format Experiment_1.v
read_file -format $file_format P1_cache.v
read_file -format $file_format P2_cache.v
read_file -format $file_format System_top.v

###################### Defining toplevel ###################################

current_design $top_module

link
check_design

####### Mapping and Optimization  ####
compile

######  Write out Design  #####
write_file -format verilog -output System_top.v
write_file -format verilog -hierarchy -output netlists/$System_top.ddc
write_file -format verilog -hierarchy -output netlists/$System_top.v
write_sdf  sdf/$System_top.sdf
write_sdc  -nosplit sdc/$System_top.sdc


#gui_start
