# rl-mapper
A tool to draw rogue-like maps. It used to be part of whiteshell, but I decided it could be its own project.

* Clone the repository and softlink it in your quicklisp/local-projects directory. 
* Do the same with Steve Losh's CL-BLT (https://docs.stevelosh.com/cl-blt/). 
* Install BearLibTerminal on your computer (https://github.com/tommyettinger/BearLibTerminal). 

Then:

```
(ql:quickload :rl-mapper)
(in-package :rl-mapper)
```

Now you can use the functions in the REPL:

https://user-images.githubusercontent.com/130791778/235418561-29cb987e-004c-453c-b4be-7990cabe8d8c.mp4


