cd ..
del %1
arj a %1 library\pc_obj\obj.dat  library\pc_asm\gen.dat
arj a %1 library\msx_obj\obj.dat library\msx_asm\gen.dat
arj a %1 library\*.*
cd library
