  # ------------------------------------------------------------
  # INSTANT PROMPT
  # ------------------------------------------------------------

  typeset -g POWERLEVEL9K_INSTANT_PROMPT=verbose

  # ------------------------------------------------------------
  # HOT RELOAD
  # ------------------------------------------------------------

  typeset -g POWERLEVEL9K_DISABLE_HOT_RELOAD=true

  (( ! $+functions[p10k] )) || p10k reload
}

# ------------------------------------------------------------
# CONFIG
# ------------------------------------------------------------

typeset -g POWERLEVEL9K_CONFIG_FILE=${${(%):-%x}:a}

(( ${#p10k_config_opts} )) && setopt ${p10k_config_opts[@]}
'builtin' 'unset' 'p10k_config_opts'
