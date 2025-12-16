vlib lib_control_rtl
vmap work ./lib_control_rtl

vcom -work work  +cover +acc -fsmdebug -O1 ../../src/rtl/an_control_2024.vhd
vcom -work work  +cover +acc ../../src/tb/an_analog_simple_err.vhd
vcom -work work  +cover +acc ../../src/tb/tb_an_control_ana_2024.vhd

