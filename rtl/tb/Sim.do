transcript on
if {[file exists work]} {
	vdel -lib work -all
}
vlib work
vlog -sv 
vsim -c TBtop


# Добавление сигналов в окно Wave (опционально, для отладки, если запускаете с GUI или для логов)
# add wave -r *


# Запуск симуляции на определенное время или до конца
run -all
