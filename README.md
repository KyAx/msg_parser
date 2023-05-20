# msg_parser

msg_parser is an IP coded in VHDL which parses a message coming from an AXI4 Stream 64bits protocol. The data comes through a certain protocol with MSG_CNT and MSG_LEN fields. The IP outputs the payload on a 256bits signal, with a length and a valid indicator. Simulations have been performed on modelsim. This IP uses a FIFO from https://github.com/campera-es/ces_util_lib.

# How to run

 - clone the project using `git clone https://github.com/KyAx/msg_parser`

- If you do have modelsim, you can start the simulation with `scripts/msim_compil.bat`  
(If you don't have modelsim, there is a free and fast installation version here : https://www.intel.com/content/www/us/en/software-kit/750368/modelsim-intel-fpgas-standard-edition-software-version-18-1.html)