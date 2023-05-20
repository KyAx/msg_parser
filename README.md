# msg_parser

msg_parser is an IP coded in VHDL which parses a message coming from an AXI4 Stream 64bits protocol. The data comes through a certain protocol with MSG_CNT and MSG_LEN fields. The IP outputs the payload on a 256bits signal, with a length and a valid indicator. Simulations have been performed on modelsim. This IP uses a FIFO from https://github.com/campera-es/ces_util_lib.

# How to run

 - clone the project using `git clone https://github.com/KyAx/msg_parser`

- start scripts/run_sim.bat