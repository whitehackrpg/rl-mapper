;;;; do-undo.lisp

(in-package #:rl-mapper)

(let ((undo ())
      (redo ()))
  (defun map-action (xy char &optional no-draw)
    (push (list (cons xy char) 
		(cons xy (cell xy)))
	  undo)
    (unless no-draw (setf (cell xy) char))
    (setf redo ()))
  
  (defun undo ()
    (let ((action (pop undo)))
      (unless (null action)
	(push action redo)
	(setf (cell (caadr action)) (cdadr action)))))

  (defun redo ()
    (let ((action (pop redo)))
      (unless (null action)
	(push action undo)
	(setf (cell (caar action)) (cdar action))))))
