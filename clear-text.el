;;; clear-text.el --- Make you use clear text  -*- lexical-binding: t; -*-

;; Copyright (C) 2016  Chunyang Xu

;; Author: Chunyang Xu <xuchunyang56@gmail.com>
;; URL: https://github.com/xuchunyang/clear-text.el
;; Keywords: convenience
;; Version: 0.01

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Emacs port of Cleartext <https://github.com/mortenjust/cleartext-mac>

;; To use, M-x clear-text-mode or M-x global-clear-text-mode

;;; Code:

(defvar clear-text-common-words nil)

(defcustom clear-text-common-words-file
  (expand-file-name "1000-common-english-words.txt"
                    (file-name-directory
                     (or load-file-name buffer-file-name)))
  "File to common words."
  :group 'convenience
  :type 'file
  :set (lambda (var val)
         (set var val)
         (with-temp-buffer
           (insert-file-contents clear-text-common-words-file)
           (goto-char 1)
           (while (not (eobp))
             (push (buffer-substring-no-properties
                    (line-beginning-position)
                    (line-end-position))
                   clear-text-common-words)
             (forward-line 1)))))

(defun clear-text-post-self-insert-hook ()
  (let* ((pt (point))
         (this-syn (syntax-class (syntax-after (- pt 1))))
         (prev-syn (and this-syn (/= 2 this-syn)
                        (syntax-class (syntax-after (- pt 2))))))
    (when (and prev-syn (= 2 prev-syn))
      (let* ((start (save-excursion
                      (forward-word -1)
                      (point)))
             (end (- pt 1))
             (word (ignore-errors (buffer-substring-no-properties start end))))
        (when (and word
                   (> (length word) 1)
                   (not (member (downcase word) clear-text-common-words)))
          (kill-word -1))))))

;;;###autoload
(define-minor-mode clear-text-mode
  "Minor mode to make you use clear text."
  :lighter " Clear-Text"
  (if clear-text-mode
      (add-hook 'post-self-insert-hook #'clear-text-post-self-insert-hook nil 'local)
    (remove-hook 'post-self-insert-hook #'clear-text-post-self-insert-hook 'local)))

;;;###autoload
(define-globalized-minor-mode global-clear-text-mode
  clear-text-mode clear-text-mode)

(provide 'clear-text)
;;; clear-text.el ends here
