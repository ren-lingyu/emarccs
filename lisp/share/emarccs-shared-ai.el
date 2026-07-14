;;; emarccs-shared-ai.el -*- lexical-binding: t; -*-
;;; commentary:
;;; code:

;; gptel
(use-package gptel
  :config
  (setq gptel-directives
        (append gptel-directives
                '((translation . "You are a LLM working in Emacs as a specialized bilingual translation assistant specialized in academic STEM(such as phyics and mathematics) content. 
When the user provides a text input, your sole task is to perform a direct, precise, and context-free translation between Chinese and English.
The following rules must be strictly obeyed: 
1. If the input is in Chinese, translate it into English.
2. If the input is in English, translate it into Chinese.
3. Do not add any explanations, commentary, or additional text beyond the translated output.
4. Maintain the original tone (formal, casual, etc.) and intent of the input.
5. Output only the translated text without leading marks before the output message."))))
  ;; (gptel-make-ollama "Ollama"
  ;;   :host "localhost:11434"
  ;;   :stream t
  ;;   :models '(gemma3n:e4b
  ;;          deepseek-v3.2:cloud
  ;;          qwen3.5:cloud
  ;;          qwen3-coder-next:cloud))
  (gptel-make-gh-copilot "Copilot")
  (setq gptel-backend
        (gptel-make-ollama "Ollama"             ;Any name of your choosing
          :host "localhost:11434"               ;Where it's running
          :stream t                             ;Stream responses
          :models '(gemma4:e4b
                    phi4-mini-reasoning:3.8b
                    deepseek-v3.2:cloud
                    qwen2.5:7b
                    qwen3.5:cloud
                    qwen3-coder-next:cloud
                    gemini-3-flash-preview:cloud)))
  (setq gptel-model 'deepseek-v3.2:cloud))

;; superchat
(use-package superchat
  :config
  (setq superchat-data-directory (locate-user-emacs-file "superchat/"))
  (setq superchat-lang "中文") ; or "English", "Francais", etc.
  (setq superchat-response-timeout 60)
  (setq superchat-completion-check-delay 2))

;; ellama
(use-package ellama
  :disabled
  :bind ("C-c e" . ellama)
  ;; send last message in chat buffer with C-c C-c
  :hook (org-ctrl-c-ctrl-c-hook . ellama-chat-send-last-message)
  :init (setopt ellama-auto-scroll t)
  :config
  ;; show ellama context in header line in all buffers
  (ellama-context-header-line-global-mode +1)
  ;; show ellama session id in header line in all buffers
  (ellama-session-header-line-global-mode +1)
  (setq ellama-language "中文"))

(provide 'emarccs-shared-ai)
;;; emarccs-shared-ai.el ends here
