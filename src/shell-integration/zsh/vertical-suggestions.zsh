[[ -o interactive ]] || return 0
(( ${+functions[_vertical_suggest_redraw]} || ${+functions[_zsh_autosuggest_start]} || ${+functions[_autocomplete__main]} )) && return 0

autoload -Uz add-zle-hook-widget
zmodload zsh/parameter || return 0
typeset -g _vertical_suggest_suffix='' _vertical_suggest_prefix=''
typeset -gi _vertical_suggest_searching=0

_vertical_suggest_clear() {
    [[ -n $_vertical_suggest_suffix && $POSTDISPLAY == "$_vertical_suggest_suffix" ]] && POSTDISPLAY=''
    region_highlight=( "${(@)region_highlight:#*memo=vertical-suggestions}" )
    _vertical_suggest_suffix=''
    _vertical_suggest_prefix=''
    return 0
}

_vertical_suggest_eligible() {
    [[ $CONTEXT == start && $KEYMAP == (main|emacs|viins) && $CURSOR -eq ${#BUFFER} &&
       ${REGION_ACTIVE:-0} == 0 && $_vertical_suggest_searching == 0 && -n $BUFFER &&
       $BUFFER != [[:space:]]* && $BUFFER != *[[:cntrl:]]* && ${#BUFFER} -le 512 ]] &&
        (( ! ${+functions[_zsh_autosuggest_start]} && ! ${+functions[_autocomplete__main]} ))
}

_vertical_suggest_redraw() {
    emulate -L zsh
    _vertical_suggest_clear
    _vertical_suggest_eligible && [[ -z $POSTDISPLAY ]] || return 0

    local candidate
    integer event lower=$(( HISTCMD - 1000 ))
    (( lower < 1 )) && lower=1
    for (( event=HISTCMD-1; event>=lower; event-- )); do
        candidate=${history[$event]-}
        [[ $candidate == "$BUFFER"?* && $candidate != *[[:cntrl:]]* && ${#candidate} -le 512 ]] || continue
        _vertical_suggest_prefix=$BUFFER
        _vertical_suggest_suffix=${candidate[$(( ${#BUFFER} + 1 )),-1]}
        POSTDISPLAY=$_vertical_suggest_suffix
        region_highlight+=("${#BUFFER} ${#candidate} fg=8 memo=vertical-suggestions")
        break
    done
    return 0
}

_vertical_suggest_search_update() {
    _vertical_suggest_searching=1
    _vertical_suggest_clear
}

_vertical_suggest_search_exit() {
    _vertical_suggest_searching=0
    _vertical_suggest_clear
}

_vertical_suggest_tab() {
    if _vertical_suggest_eligible && [[ -n $_vertical_suggest_suffix &&
        $BUFFER == "$_vertical_suggest_prefix" && $POSTDISPLAY == "$_vertical_suggest_suffix" ]]; then
        BUFFER+=$_vertical_suggest_suffix
        CURSOR=${#BUFFER}
        _vertical_suggest_clear
    else
        _vertical_suggest_clear
        builtin zle ".vertical-original-${WIDGET#vertical-suggest-}" -- "$@"
    fi
}

_vertical_suggest_install() {
    emulate -L zsh
    local keymap binding original
    local -a words
    for keymap in emacs viins main; do
        binding=$(builtin bindkey -M "$keymap" '^I') || continue
        words=( ${(z)binding} )
        (( ${#words} == 2 )) || continue
        original=${(Q)words[2]}
        [[ $original == (undefined-key|vertical-suggest-*) ]] && continue
        builtin zle -A "$original" ".vertical-original-$keymap" || continue
        builtin zle -N "vertical-suggest-$keymap" _vertical_suggest_tab
        builtin bindkey -M "$keymap" '^I' "vertical-suggest-$keymap"
    done
    add-zle-hook-widget line-pre-redraw _vertical_suggest_redraw
    add-zle-hook-widget line-finish _vertical_suggest_search_exit
    add-zle-hook-widget isearch-update _vertical_suggest_search_update
    add-zle-hook-widget isearch-exit _vertical_suggest_search_exit
}

_vertical_suggest_install
unset -f _vertical_suggest_install
