set file $1
set top_level work.$2

if {[file isdirectory ./work]} {
    vdel -lib ./work -all
}
vlib work
vmap -c
vmap work ./work

vlog $file
vsim $top_level
view wave
add wave *
run -all
wave zoom full