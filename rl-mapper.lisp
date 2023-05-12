;;;; rl-mapper (press 'i' for instructions)

(in-package #:rl-mapper)

(defun tick (xy pen-set pen extra-pens)
  (let* ((pen-list (if extra-pens (cons extra-pens *pen-list*) *pen-list*))
	 (pens (1- (length (nth pen-set pen-list)))))
    (labels ((pen-right () (if (< pen pens) (incf pen) (setf pen 0)))
	     (pen-left () (if (zerop pen) 
			      (setf pen (1- (length (nth pen-set pen-list))))
			      (decf pen))))
      (display-stuff xy pen-set pen-list pen)
      (blt:key-case 
       (blt:read) 
       (:escape (setf xy 'quit))
       (:f (pen-right))
       (:mouse-scroll (cond ((plusp (mouse-wheel)) (pen-right))
			    ((minusp (mouse-wheel)) (pen-left))))
       (:s (pen-left))
       ((or :g :mouse-middle) 
	(if (= pen-set (1- (length pen-list)))
	    (setf pen-set 0) 
	    (incf pen-set))
	(when (> pen (1- (length (nth pen-set pen-list))))
	  (setf pen 0)))
       (:a 
	(if (zerop pen-set)
	    (setf pen-set (1- (length pen-list)))
	    (decf pen-set))
	(when (> pen (1- (length (nth pen-set pen-list))))
	  (setf pen 0)))
       (:w (print-it))
       (:p (paint (nth pen (nth pen-set pen-list))))
       (:e (paint #\SPACE t))
       (:space (map-action xy (nth pen (nth pen-set pen-list))))
       (:mouse-left (map-action (complex (blt:mouse-x) (blt:mouse-y))
				(nth pen (nth pen-set pen-list))))
       (:mouse-right (map-action (complex (blt:mouse-x) (blt:mouse-y))
			   #\SPACE))
       (:d (setf (cell xy) #\SPACE))
       (:k (incf xy #C( 0 -1))) (:j (incf xy #C(0  1)))
       (:h (incf xy #C(-1  0))) (:l (incf xy #C(1  0)))
       (:y (incf xy #C(-1 -1))) (:u (incf xy #C(1 -1)))
       (:i (format t "~&~A" *instructions*))
       (:o (if (or (= pen-set 1)
		     (= pen-set 4))
	     (outline (make-hash-table) (nth pen-set *pen-list*))
	     (format t "You need to pick pen-set 1 or 4 first.~%")))
       (:z (undo))
       (:r (redo))
       (:b (incf xy #C(-1  1))) (:n (incf xy #C(1  1))))
      (cond ((eq xy 'quit) (print-it))
	    (t (setf (blt:layer) 1)
	       (setf (blt:color) *highlight-color*
		     (cell xy) (nth pen (nth pen-set pen-list))
		     (cell (complex (blt:mouse-x) (blt:mouse-y)))
		     (nth pen (nth pen-set pen-list))
		     (blt:color) *default-color*
		     (blt:layer) 0)
	       (tick xy pen-set pen extra-pens))))))

(defun display-stuff (xy pen-set pen-list pen)
    (blt:print 0 0 (format nil "~a" (nth pen-set pen-list)))
    (blt:print (1+ (* pen 2)) 1 "-")
    (blt:refresh)
    (blt:print 0 0 "                                                                          ")
    (blt:print (1+ (* pen 2)) 1 " ")
    (setf (blt:layer) 1
	  (cell xy) #\SPACE
	  (cell (complex (blt:mouse-x) (blt:mouse-y))) #\SPACE
	  (blt:layer) 0))

(defun print-it ()
  (dotimes (y *dimy*)
    (dotimes (x *dimx* (terpri))
      (format t "~A" (or (blt:cell-char x y) #\SPACE)))))

(defun rl-mapper (&key savedmap extra-pens)
  (blt:with-terminal
    (blt:set "window.title = RL-Mapper")
    (blt:set "input.filter = keyboard, mouse")
    (blt:set "input.mouse-cursor = false")
    (blt:set "font: ~A, size=~A" *font* *font-size*) 
    (setf (blt:color) *default-color*)
    (if savedmap
	(multiple-value-bind (xdim ydim lines) 
	    (list-dims (uiop:read-file-lines savedmap))
	  (setf *dimx* xdim *dimy* ydim)
	  (blt:set "window.size = ~AX~A" *dimx* *dimy*)
	  (dotimes (line *dimy*) 
	    (dotimes (pos (length (nth line lines)))
	      (setf (cell (complex pos line))
		    (char (nth line lines) pos)))))
	(progn (blt:set "window.size = ~AX~A" *dimx* *dimy*)
	       (dotimes (x *dimx*)
		 (dotimes (y *dimy*)
		   (setf (cell (complex x y)) #\SPACE)))))
    (tick (complex 1 2) 0 0 extra-pens)))
