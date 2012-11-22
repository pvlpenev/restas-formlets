;;;; package.lisp

(defpackage #:restas-formlets
  (:use #:cl #:formlets #:hunchentoot)
  (:shadowing-import-from #:formlets
			  #:define-field
			  #:SPLIT-VALIDATION-LIST
			  #:fields
			  #:on-success)
  (:shadow #:define-formlet)
  (:export :formlet :formlet-field 
	   :hidden :text :textarea :password :file :checkbox :select :radio-set :checkbox-set :multi-select
 	   :*public-key* :*private-key* :recaptcha
	   :validate :show :post-value :show-formlet :define-formlet
	   :longer-than? :shorter-than? :matches? :mismatches? :file-type? :file-smaller-than? :not-blank? :same-as? :picked-more-than? :picked-fewer-than? :picked-exactly?))

