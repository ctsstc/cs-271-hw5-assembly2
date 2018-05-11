all: hw5

hw5.o: hw5.asm
	nasm -f elf32 -g -F stabs hw5.asm
	
hw5: hw5.o
	ld -m elf_i386 -o hw5 hw5.o


rebuild: b

a: hw5.asm
	nasm -f elf32 -g -F stabs hw5.asm
	
b: a
	ld -m elf_i386 -o hw5 hw5.o


clean:
	rm *.o hw5