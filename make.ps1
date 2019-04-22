.\rgbasm.exe -o main.o main.asm
if($?) { .\rgblink.exe -o gameboygame.gb main.o }
if($?) { .\rgbfix.exe -v -p 0 gameboygame.gb }
if($?) { .\bgb64.exe gameboygame.gb }