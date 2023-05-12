;;;; base.lisp

(in-package #:rl-mapper)

#+win32
(progn (cffi:define-foreign-library blt:bearlibterminal
	 (t "./BearLibTerminal.dll"))
       (cffi:use-foreign-library blt:bearlibterminal))

(defparameter *dimx* 76)
(defparameter *dimy* 24)
(defparameter *pen-list* 
  '((#\# #\SPACE #\. #\+ #\/ #\< #\> #\^ #\* #\~ #\! #\$ #\% #\& #\?)
    (#\U+2550 #\U+2551 #\U+2554 #\U+2557 #\U+255A #\U+255D)
    (#\U+2560 #\U+2563 #\U+2566 #\U+2569 #\U+256C #\U+256A #\U+256B)
    (#\U+2552 #\U+2553 #\U+2555 #\U+2556 #\U+2558 #\U+2559
     #\U+255B #\U+255C #\U+255E #\U+255F #\U+2561 #\U+2562
     #\U+2564 #\U+2565 #\U+2567 #\U+2568)
    (#\U+2500 #\U2502  #\U+250C #\U+2510 #\U+2514 #\U+2518)
    (#\U+251C #\U2524  #\U+252C #\U+2534 #\U+253C)
    (#\a #\b #\c #\d #\e #\f #\g #\h #\i #\j #\k #\l #\m #\n #\o #\p #\q #\r 
     #\s #\t #\u #\v #\w #\x #\y #\z)
    (#\A #\B #\C #\D #\E #\F #\G #\H #\I #\J #\K #\L #\M #\N #\O #\P #\Q #\R
     #\S #\T #\U #\V #\W #\X #\Y #\Z)))

(defparameter *instructions* (format nil "~%INSTRUCTIONS~%------------~%Navigation: H/J/K/L/Y/U/B/N or mouse~%Draw: space or left-click~%Delete: d or right-click~%Undo: z~%Redo: r~%Outline: o (and then move mouse)~%Paint: p (and then move mouse)~%Erase (continuously): e (and then move mouse)~%Switch pen: scroll-wheel or s (left) and f (right)~%Switch pen-set: g or middle-click to switch forward, a to switch backward~%Print to REPL: w~%Print instructions: i~%Quit: escape (also prints to the REPL)~%~%Call draw-map with the keyword argument ':savedmap' to start with a saved map (text format), and/or ':extra-pens' to add a custom pen-set (formatted as a list of characters).~%~%Error and support messages are printed directly to the REPL.~%~%" ))
(defparameter *font* (asdf:system-relative-pathname "rl-mapper" "fonts/RobotoMono-Regular.ttf"))
(defparameter *font-size* 13)
(defparameter *default-color* (blt:rgba 110 160 110))
(defparameter *highlight-color* (blt:rgba 210 250 210))

(defun list-dims (list-o-strings)
  "Return the x and y dimensions of a list of strings, and the list."
  (let ((count 0))
    (dolist (line list-o-strings 
		  (values count (length list-o-strings) list-o-strings))
      (let ((stringcount (length line)))
	(when (> stringcount count) (setf count stringcount))))))
  
(defmacro cell (n) 
  `(blt:cell-char (realpart ,n) (imagpart ,n)))

(defun mouse-wheel ()
  (blt/ll:terminal-state blt/ll:+tk-mouse-wheel+))

(defun mouse-move ()
  (blt/ll:terminal-state blt/ll:+tk-mouse-move+))
