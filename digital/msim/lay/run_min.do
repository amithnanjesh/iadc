add wave /tb_an_control_ana/u_control/*
toggle add -r /tb_an_control_ana/u_control/*
vcd file an_control-min.vcd
vcd add -r /tb_an_control_ana/u_control/*
onbreak {resume}
run -all
toggle report -all
vcd flush
