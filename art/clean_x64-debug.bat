@echo off
color 0a
cd ..
echo CLEANING GAME
haxelib run lime clean windows -debug
echo.
echo done.
pause