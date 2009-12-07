(recentf-mode 1)
; tool bar を消す。
(tool-bar-mode 0)
;; menu bar を消す。
(menu-bar-mode -1)

(line-number-mode t) ; 行番号
(column-number-mode t) ; 桁番号
(setq default-tab-width 4)
(setq indent-line-function 'indent-relative-maybe) ; 前と同じ行の幅にインデント

;;Color
(if window-system (progn
   (set-background-color "RoyalBlue4")
   (set-foreground-color "LightGray")
   (set-cursor-color "Gray")
))

;;; フレームパラメータ初期値の設定
(setq default-frame-alist
      (append (list
               ;; サイズ
               '(width . 80)  ; 横幅(桁数)
               '(height . 47) ; 高さ(行数)
               '(top . 0)    ; フレーム左上角 y 座標
               ;;'(left . 10)   ; フレーム左上角 x 座標
               ;; 背景と文字の色
               '(background-color . "RoyalBlue4")
               '(foreground-color . "LightGray")
               '(cursor-color . "Gray")
               ;; スクロールバー
               '(vertical-scroll-bars . right)
               ;; フォント
;;              '(font . "default-fontset")
;;              '(ime-font . "default-japanese-jisx0208")
               )
              default-frame-alist))

(set-frame-parameter (selected-frame) 'active-alpha 0.9)
(set-frame-parameter (selected-frame) 'inactive-alpha 0.8)
(setq default-frame-alist
      (append (list
               '(alpha . (85 25))
               ) default-frame-alist))
;(add-to-list 'default-frame-alist '(active-alpha . 0.9)
;(add-to-list 'default-frame-alist '(inactive-alpha . 0.8))

(defvar my-ignore-blst             ; 移動の際に無視するバッファのリスト
  '("*Help*" "*Compile-Log*" "*Mew completions*" "*Completions*"
    "*Shell Command Output*" "*Apropos*" "*Buffer List*"))
(defvar my-visible-blst nil)       ; 移動開始時の buffer list を保存
(defvar my-bslen 15)               ; buffer list 中の buffer name の最大長
(defvar my-blist-display-time 2)   ; buffer list の表示時間
(defface my-cbface                 ; buffer list 中で current buffer を示す face
  '((t (:foreground "wheat" :underline t))) nil)

(defun my-visible-buffers (blst)
  (if (eq blst nil) '()
    (let ((bufn (buffer-name (car blst))))
      (if (or (= (aref bufn 0) ? ) (member bufn my-ignore-blst))
          ;; ミニバッファと無視するバッファには移動しない
          (my-visible-buffers (cdr blst))
        (cons (car blst) (my-visible-buffers (cdr blst)))))))

(defun my-show-buffer-list (prompt spliter)
  (let* ((len (string-width prompt))
         (str (mapconcat
               (lambda (buf)
                 (let ((bs (copy-sequence (buffer-name buf))))
                   (when (> (string-width bs) my-bslen) ;; 切り詰め 
                     (setq bs (concat (substring bs 0 (- my-bslen 2)) "..")))
                   (setq len (+ len (string-width (concat bs spliter))))
                   (when (eq buf (current-buffer)) ;; 現在のバッファは強調表示
                     (put-text-property 0 (length bs) 'face 'my-cbface bs))
                   (cond ((>= len (frame-width)) ;; frame 幅で適宜改行
                          (setq len (+ (string-width (concat prompt bs spliter))))
                          (concat "\n" (make-string (string-width prompt) ? ) bs))
                         (t bs))))
               my-visible-blst spliter)))
    (let (message-log-max)
      (message "%s" (concat prompt str))
      (when (sit-for my-blist-display-time) (message nil)))))

(defun my-operate-buffer (pos)
  (unless (window-minibuffer-p (selected-window));; ミニバッファ以外で
    (unless (eq last-command 'my-operate-buffer)
      ;; 直前にバッファを切り替えてなければバッファリストを更新
      (setq my-visible-blst (my-visible-buffers (buffer-list))))
    (let* ((blst (if pos my-visible-blst (reverse my-visible-blst))))
      (switch-to-buffer (or (cadr (memq (current-buffer) blst)) (car blst))))
    (my-show-buffer-list (if pos "[-->] " "[<--] ") (if pos " > "  " < " )))
  (setq this-command 'my-operate-buffer))

(global-set-key [?\C-,] (lambda () (interactive) (my-operate-buffer nil)))
(global-set-key [?\C-.] (lambda () (interactive) (my-operate-buffer t)))
(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(cua-mode t nil (cua-base))
 '(transient-mark-mode t))
(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 )

(setq auto-mode-alist
      (append
       '(
	 ("\\.h$"    . c++-mode)
	 ("\\.hpp$"  . c++-mode)
	 ("\\.txt$"  . text-mode)
	 ("\\.message$" . text-mode)
	 ("\\.htm" . html-helper-mode)
	 ("\\.asp" . html-helper-mode)
	 ("\\.shtml$" . html-helper-mode)
	 ("\\.php" . html-helper-mode)
	 ) auto-mode-alist))


(require 'epa-setup)

(add-to-list 'load-path (expand-file-name "~/.emacs.d"))
(add-to-list 'load-path (expand-file-name "~/.emacs.d/auto-install/"))
(require 'auto-install)
(setq auto-install-directory "~/.emacs.d/auto-install/")
(auto-install-update-emacswiki-package-name t)
(auto-install-compatibility-setup)

(require 'anything)
(require 'anything-config)
(add-to-list 'anything-sources 'anything-c-source-emacs-commands)
(define-key global-map (kbd "C-;") 'anything)
(setq anything-sources
    '(anything-c-source-buffers+
	anything-c-source-colors
	anything-c-source-recentf
	anything-c-source-emacs-commands
	anything-c-source-emacs-functions
	anything-c-source-files-in-current-dir
	))
