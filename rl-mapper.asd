;;;; rl-mapper.asd

(asdf:defsystem #:rl-mapper
  :description "A collection of helper tools for the tabletop role-playing game Whitehack."
  :author "Christian Mehrstam <whitehackrpg@gmail.com>"
  :license  "MIT"
  :serial t
  :depends-on (#:cl-blt)
  :components ((:file "package")
	       (:file "base")
	       (:file "do-undo")
	       (:file "paint-n-outline")
	       (:file "rl-mapper")))

