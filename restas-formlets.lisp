;;;; restas-formlets.lisp

(in-package #:restas-formlets)

;;; "restas-formlets" goes here. Hacks and glory await!

(defmacro define-formlet ((name &key general-validation (submit "Submit")) (&rest fields) &rest on-success)
  "Converts a terse declaration form into the corresponding object and validation handler."
  ;;; the flet function converts a terse declaration into the corresponding make-instance declaration
  (let* ((field-names (mapcar #'car fields))
	 (field-objects (mapcar (lambda (f) (apply #'define-field f)) fields))
	 (enctype (if (every (lambda (f) (not (eq (cadr f) 'file))) fields)
		      "application/x-www-form-urlencoded" 
		      "multipart/form-data")))
    (multiple-value-bind (gen-val-fn gen-err-msg) (split-validation-list general-validation) 
      `(progn 
         ;;; declare formlet instance
	 (defparameter ,name
	   (make-instance 'formlet
			  :name ',name :submit ,submit :enctype ,enctype
			  :validation-functions ,(when general-validation `(list ,@gen-val-fn)) 
			  :error-messages ,(when general-validation `(list ,@gen-err-msg))
			  :fields (list ,@field-objects)
			  :on-success (lambda ,field-names (progn ,@on-success))))
	 
         ;;; declare validation handler
	 (restas:define-route ,(intern (format nil "VALIDATE-~a" name)) (,(format nil "/validate-~(~a~)" name) :method :post)
	   (let* ((formlet-values (post-value ,name (post-parameters*)))
		  (formlet-return-values (loop for f in (restas-formlets::fields ,name) ;;the values list, less password values
					    for v in formlet-values
					    unless (eq (type-of f) 'password) collect v
					    else collect nil)))
	     (multiple-value-bind (result errors) (validate ,name formlet-values)
	       (if result
		   (apply (restas-formlets::on-success ,name) formlet-values) ;; if everything's ok, send the user on
		   (progn
		     (setf (session-value :formlet-values) formlet-return-values
			   (session-value :formlet-errors) errors
			   (session-value :formlet-name) ',name)
		     (redirect (referer)))))))))))
