Disassembled code of the CL300 controller from the IVT Greenline Compact 8 heat pump (year of production: circa 2000)

Out of curiosity I tried to disassemble code of the mentioned controller.

The hardware (electronics of the controller) is not so much complicated - main MCU is Philips 80C552, most of the
controlled/checked hardware is connected via buffer CMOS logic. The pomp has a simple panel to control it, the
communication here is with a couple of shift registers.

It's an old pump and controller (I think it's impossible to buy a new one these days), so I assume I don't violate
any copyrights with publishing this.

The main reason for this was to see:
  * how the algorithm to control the compressor/pumps was implemented  (still don't know ;) )
  * what the "Givarfel" error means in practice (also still don't know ;) )
  * how to use the serial pomp in this controller (this one at least the code helped me to understand the communication)

The code is compatible with the "asem51" assembler: http://plit.de/asem-51/

Unfortunately, the MCS-51 environment is new to me (privately, I always used other architectures for all MCU projects),
so I'm not sure what is the "industrial standard" for this (except Keil products). Plus it's an old and obsolete
architecture so it's hard to find something new for this. ;)
