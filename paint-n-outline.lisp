;;;; paint-n-outline.lisp

(in-package #:rl-mapper)
  
(defun paint (char)
  (blt:print 0 0 "Press 'p' to finish the painting.")
  (when (and (mouse-move)
	     (eq (blt:cell-char (blt:mouse-x) (blt:mouse-y)) #\SPACE))
    (map-action (complex (blt:mouse-x) (blt:mouse-y)) char))
  (blt:refresh)
  (if (blt:key-case (blt:read) (:p))
      (blt:print 0 0 "                                 ")
      (paint char)))

(defun fix-line (newxy oldxy hash)
  (labels ((sharp-helper (a b) 
	   (and (or (null (gethash (complex a b) hash))
		    (eq (gethash (complex a b) hash) #\SPACE))
		(not (null (gethash (complex b a) hash)))
		(not (eq (gethash (complex b a) hash) #\SPACE))))
	   (extra-sharp (a b)
	     (let ((mid (- newxy (cond ((sharp-helper a b)
					(complex a b))
				       ((sharp-helper b a)
					(complex b a))
				       (t (if (zerop (random 2)) 
					      (complex a b) 
					      (complex b a)))))))
	       (setf (gethash mid hash) #\#)
	       mid)))
    (let ((diff (- newxy oldxy)))
      (case diff
	(#C(1 1) (print 1) (extra-sharp 0 1))
	(#C(-1 -1) (print 2) (extra-sharp 0 -1))
	(#C(1 -1) (print 3) (extra-sharp -1 0))
	(#C(-1 1) (print 4) (extra-sharp 1 0))))))

(defun outline (hash pen-type &optional oldxy)
  (blt:print 0 0 "Press 'w' to finish the outline.")
  (let* ((newxy (complex (blt:mouse-x) (blt:mouse-y)))
	 (midxy  (when oldxy (fix-line newxy oldxy hash)))
	 (newhash (make-hash-table)))
    (flet ((line-draw (xy) 
	     (let ((tile (prettify xy hash pen-type)))
	       (setf (gethash xy hash) tile)
	       (map-action xy (gethash xy hash) t)
	       (setf (blt:cell-char (realpart xy) (imagpart xy)) tile
		     (gethash xy newhash) (gethash xy hash)))))
      (setf (gethash newxy hash) #\#)
      (when oldxy (line-draw oldxy))
      (when midxy (line-draw midxy))
      (setf (gethash newxy newhash) (gethash newxy hash)
	    oldxy newxy)
      (blt:refresh))
    (if (blt:key-case (blt:read) (:w))
	(blt:print 0 0 "                                ")
	(outline newhash pen-type oldxy))))

(defun prettify (coord hash pen-type)
  (let ((n (gethash (+ coord #C(0 -1)) hash))
	(s (gethash (+ coord #C(0 1)) hash))
	(w (gethash (+ coord #C(-1 0)) hash))
	(e (gethash (+ coord #C(1 0)) hash)))
    (cond
      ((and n s) (nth 1 pen-type))
      ((and w e) (nth 0 pen-type))
      ((and n w) (nth 5 pen-type))
      ((and n e) (nth 4 pen-type))
      ((and s w) (nth 3 pen-type))
      ((and s e) (nth 2 pen-type))
      (t #\SPACE))))