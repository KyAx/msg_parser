# msg_parser

msg_parser is an IP coded in VHDL which parses a message coming from an AXI4 Stream 64bits protocol. The data comes through a certain protocol with MSG_CNT and MSG_LEN fields. The IP outputs the payload on a 256bits signal, with a length and a valid indicator. This IP uses a FIFO from https://github.com/campera-es/ces_util_lib. Simulations have been performed on Modelsim.
This design is provided with a selfcheck test with differents samples recorded in a csv file. This selfcheck process returns [OK] or [ERROR] in Modelsim console.

# Directory tree

- `doc/` contains the architecture diagram, the exercise statement and the answers to the questions
- `scripts/` contains scripts to compile and start modelsim
- `sim/` contains testbench, waves, input samples csv
- `src/` contains VHDL files

# How to run

- Clone the project using `git clone https://github.com/KyAx/msg_parser`

- If you do have modelsim, you can start the simulation with `scripts/msim_compil.bat`  (If you don't have modelsim, there is a free and fast installation version here : https://www.intel.com/content/www/us/en/software-kit/750368/modelsim-intel-fpgas-standard-edition-software-version-18-1.html)

- `scripts/msim_clean.bat` can be used to clean the directory by removing the modelsim folder created by the `msim_compil.bat` script.  

- In case there is a problem on compilation on the testbench, go to Modelsim: Compile > Compile Options > Use VHDL 1076-2008. 