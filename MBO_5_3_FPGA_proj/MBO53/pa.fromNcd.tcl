
# PlanAhead Launch Script for Post PAR Floorplanning, created by Project Navigator

create_project -name MBO53 -dir "E:/Xilinx/projects/mbo5_3_tech/MBO_5_3_FPGA_proj/MBO53/planAhead_run_2" -part xc3s500efg320-5
set srcset [get_property srcset [current_run -impl]]
set_property design_mode GateLvl $srcset
set_property edif_top_file "E:/Xilinx/projects/mbo5_3_tech/MBO_5_3_FPGA_proj/MBO53/MBO_53_top.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {E:/Xilinx/projects/mbo5_3_tech/MBO_5_3_FPGA_proj/MBO53} {ipcore_dir} }
add_files [list {ipcore_dir/fifo_25_12_5.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {ipcore_dir/fifo_acp.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {ipcore_dir/fifo_compression_base.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {ipcore_dir/FIFO_CONV_IN.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {ipcore_dir/FIFO_CONV_OUT.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {ipcore_dir/fifo_doll.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {ipcore_dir/MEM_OPORA_LCHM.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {ipcore_dir/sum.ncf}] -fileset [get_property constrset [current_run]]
set_property target_constrs_file "MBO_53_top.ucf" [current_fileset -constrset]
add_files [list {MBO_53_top.ucf}] -fileset [get_property constrset [current_run]]
link_design
read_xdl -file "E:/Xilinx/projects/mbo5_3_tech/MBO_5_3_FPGA_proj/MBO53/MBO_53_top.ncd"
if {[catch {read_twx -name results_1 -file "E:/Xilinx/projects/mbo5_3_tech/MBO_5_3_FPGA_proj/MBO53/MBO_53_top.twx"} eInfo]} {
   puts "WARNING: there was a problem importing \"E:/Xilinx/projects/mbo5_3_tech/MBO_5_3_FPGA_proj/MBO53/MBO_53_top.twx\": $eInfo"
}
