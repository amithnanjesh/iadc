vsim -coverage work.tb_an_control_ana
#add wave -r *
do wave.do
toggle add -r *
onbreak {resume}
run -all
toggle report

