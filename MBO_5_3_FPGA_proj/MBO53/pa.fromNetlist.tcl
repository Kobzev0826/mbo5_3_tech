
# PlanAhead Launch Script for Post-Synthesis floorplanning, created by Project Navigator

create_project -name MBO53 -dir "C:/Users/User/Documents/GitHub/mbo5_3_tech/MBO_5_3_FPGA_proj/MBO53/planAhead_run_2" -part xc3s500efg320-5
set_property design_mode GateLvl [get_property srcset [current_run -impl]]
set_property edif_top_file "C:/Users/User/Documents/GitHub/mbo5_3_tech/MBO_5_3_FPGA_proj/MBO53/MBO_53_top_cs.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {C:/Users/User/Documents/GitHub/mbo5_3_tech/MBO_5_3_FPGA_proj/MBO53} {ipcore_dir} }
add_files [list {ipcore_dir/Eth_RAM_120_data.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {ipcore_dir/Eth_RAM_ARP.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {ipcore_dir/Eth_RAM_headers.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {ipcore_dir/Eth_RAM_holder.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {ipcore_dir/Eth_RAM_udp.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {ipcore_dir/fifo_25_12_5.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {ipcore_dir/fifo_acp.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {ipcore_dir/fifo_compression_base.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {ipcore_dir/FIFO_CONV_IN.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {ipcore_dir/FIFO_CONV_OUT.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {ipcore_dir/fifo_doll.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {ipcore_dir/MEM_OPORA_LCHM.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {ipcore_dir/RAM_control_data.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {ipcore_dir/ROM_UART_DATA.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {ipcore_dir/sum.ncf}] -fileset [get_property constrset [current_run]]
set_property target_constrs_file "MBO53.ucf" [current_fileset -constrset]
add_files [list {MBO53.ucf}] -fileset [get_property constrset [current_run]]
link_design
