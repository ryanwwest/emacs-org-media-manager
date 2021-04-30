(require 'seq)

;; toggle word-wrap: global-visual-line-mode

(defun zk-media-garbage-collect ()
  "Search files starting with 'img' in the zk media subfolder against all org files to determine which have no mappings from org->image file. Mark these images with 'to-delete-<date>'. Next check all files that start with 'to-delete'; if <date> has passed, delete files"
  (interactive)

  (setq zkpath "/Users/ryanwest/n/zk/t/")
  (setq zkmediadir "zkmedia")
  (setq gcdir "/garbage-collected/")

  (setq orphans (get-orphan-zkmedia-files zkpath zkmediadir))
  (setq count 0)
  (dolist (orphan orphans)
        (setq count (+ count 1))
        (setq foldername (concat zkpath zkmediadir gcdir))
        (if (not (file-exists-p foldername))
        (mkdir foldername))
        (setq orphanAbsoluteFilename (concat zkpath zkmediadir "/" orphan))
        (rename-file orphanAbsoluteFilename (concat foldername orphan))
    )
  (message "Moved %i files to garbage-collected media folder" count)
  )

(defun get-orphan-zkmedia-files (zkDirPath zkMediaDir)
  (setq orgFiles (directory-files zkDirPath t))
  (setq imgFiles (directory-files (concat zkDirPath zkMediaDir) nil "^img*"))
  ;; (setq a '())
  (dolist (orgf orgFiles imgFiles)
    (unless (file-directory-p orgf)
        (setq foundImgFiles (which-strings-in-file? imgFiles orgf))
        ;; (push (length imgFiles) a)
        ;; remove found images from images without a pointer yet, then use that
        ;; new variable in next iteration. at end of loop, return final new var
        (setq imgFiles (seq-difference imgFiles foundImgFiles))
        ))
        ;; (dolist (found foundImgFiles imgFiles)
        ;;   (message imgFiles)
        ;;   (delete found imgFiles)
        ;;   )))
  )

(defun which-strings-in-file? (strings fPath)
  "see if any of the given string exists in the given file; return a list of the strings that are found"
  (setq found '())
  (with-temp-buffer
    ;; load file into temp buffer
    (insert-file-contents fPath)
    ;; save current point to use another in temp buffer
    (save-excursion
      ;; todo add dolist for each str in strs
      (dolist (str strings)
        ;; set point to beginning of buffer so entire buffer is searched each time
        (goto-char (point-min))
        (if (search-forward str nil t)
            ;; for each string found, push that string to a list to return
            (push str found))
        ))
    found
    ))


(defun zk-insert-clipboard-image ()
  "If the clipboard contains an image, save it to a time stamped file in the
  media sub-directory and insert an org link to this file."
  (interactive)

(setq foldername "zkmedia/")
(if (not (file-exists-p foldername))
  (mkdir foldername))

(setq imgName (concat "img-" (format-time-string "%Y-%m-%d-%H-%M-%S") ".png"))
(setq imgPath (concat foldername imgName))
;; (call-process "import" nil nil nil imgPath)
(setq relativeFilename (concat "./" imgPath))

;; if process returns a 0 (meaning file was created), add link
(if (eq 0 (call-process "pngpaste" nil nil nil relativeFilename))
    (insert (concat "[[" relativeFilename "]]"))
  (message "no picture data found in clipboard"))
(org-display-inline-images)
)
