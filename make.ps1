.\rgbasm.exe -o main.o main.asm
.\rgblink.exe -o hello-world.gb main.o
.\rgbfix.exe -v -p 0 hello-world.gb