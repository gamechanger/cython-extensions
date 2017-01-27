[Cython](http://cython.org/) allows you to write c extensions for python. Instead of interpreting python code, you can compile a python file using cython
and run compiled c for the functions you need to run. 

This repos is where we store all cython extensions used in GameChanger's production code. These have generally been designed to make certain parts of the code
run more efficiently then before.