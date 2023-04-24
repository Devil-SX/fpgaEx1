# 这里要使用相对路径，使用Modelsim读取脚本，（这种写法的）绝对路径会发生改变
# set script_path [ file dirname [ file normalize [ info script ] ] ]
# set main_path [ file dirname $script_path ]

set main_path . 
# 这个由调用的地方决定 
set rtl_path "$main_path/rtl"
set src [list "$rtl_path/src/uart_rx_op.v" "$rtl_path/src/clk_divider.v"]
set tb "$rtl_path/tb/uart_rx_op_tb.v"
set top_level work.uart_rx_op_tb

if {[file isdirectory ./work]} {
    vdel -lib ./work -all
}
vlib work
vmap -c
vmap work ./work

vlog -work work {*}$src $tb
# 这里使用{*}$src，是因为src是一个list，需要将list中的每个元素都传递给vlog
vsim $top_level
view wave
add wave *
run -all
wave zoom full