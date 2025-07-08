LPORT ?= 8080

stager: stager.bin
	msfvenom -p - -a x64 --platform Linux -f elf -o stager < stager.bin

stager.bin: stager.asm
	nasm -fbin -DLPORT=$(LPORT) -o stager.bin stager.asm

clean:
	rm -f stager stager.bin

.PHONY: clean
