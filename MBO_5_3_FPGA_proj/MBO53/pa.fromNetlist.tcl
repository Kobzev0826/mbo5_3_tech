
# PlanAhead Launch Script for Post-Synthesis pin planning, created by Project Navigator

create_project -name MBO53 -dir "C:/Users/user/Documents/Projects/MBO53/planAhead_run_1" -part xc3s500efg320-5
set_property design_mode GateLvl [get_property srcset [current_run -impl]]
set_property edif_top_file "C:/Users/user/Documents/Projects/MBO53/MBO_53_top.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {C:/Users/user/Documents/Projects/MBO53} {ipcore_dir} }
add_files [list {ipcore_dir/fifo_25_12_5.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {ipcore_dir/fifo_acp.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {ipcore_dir/fifo_compression_base.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {ipcore_dir/FIFO_CONV_IN.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {ipcore_dir/FIFO_CONV_OUT.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {ipcore_dir/fifo_doll.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {ipcore_dir/MEM_OPORA_LCHM.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {ipcore_dir/sum.ncf}] -fileset [get_property constrset [current_run]]
set_param project.pinAheadLayout  yes
set_property target_constrs_file "MBO_53_top.ucf" [current_fileset -constrset]
add_files [list {MBO_53_top.ucf}] -fileset [get_property constrset [current_run]]
link_design
