# 验证学习tcl脚本语法

set script_path [ file dirname [ file normalize [ info script ] ] ]
puts $script_path
set main_path [ file dirname $script_path ]
puts $main_path
puts "$main_path/test.tcl"