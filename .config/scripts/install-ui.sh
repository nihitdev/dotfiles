#!/usr/bin/env bash

# Dependency-free interactive terminal UI for the Kairo installer.

ui_active=false
ui_compact=false
ui_cursor_hidden=false
ui_alt_screen=false
UI_RESET=$'\033[0m'
UI_BOLD=$'\033[1m'
UI_DIM=$'\033[2m'
UI_CYAN=$'\033[38;5;81m'
UI_GREEN=$'\033[38;5;114m'
UI_YELLOW=$'\033[38;5;221m'
UI_RED=$'\033[38;5;203m'
UI_PURPLE=$'\033[38;5;183m'
UI_WHITE=$'\033[38;5;255m'
UI_SURFACE=$'\033[48;5;236m'
UI_REVERSE=$'\033[7m'
UI_STAGE_LABELS=('Preparing' 'Backup' 'Packages' 'Dotfiles' 'Shells' 'Caches' 'Validate')
UI_KEY=''

ui_read_key() {
    local first second char sequence='' count=0
    UI_KEY=''
    IFS= read -rsn1 first || return 1
    case "$first" in
        '') UI_KEY=enter ;;
        ' ') UI_KEY=space ;;
        q | Q) UI_KEY=quit ;;
        a | A) UI_KEY=all ;;
        n | N) UI_KEY=none ;;
        y | Y) UI_KEY=yes ;;
        j) UI_KEY=down ;;
        k) UI_KEY=up ;;
        $'\e')
            # Arrow, function-key, and mouse events all begin with Escape.
            # Wait long enough for the next byte instead of treating a
            # partially delivered sequence as a cancellation.
            if ! IFS= read -rsn1 -t 0.25 second; then
                UI_KEY=escape
                return 0
            fi
            sequence=$second
            if [[ $second == '[' || $second == O ]]; then
                while ((count < 32)); do
                    if ! IFS= read -rsn1 -t 0.10 char; then break; fi
                    sequence+=$char
                    ((count++)) || true
                    # CSI arrows end in A-D, function keys commonly in ~,
                    # and SGR mouse reports in M/m. Consume the whole event.
                    [[ $char == [A-DF-HMm~] ]] && break
                done
                if [[ $sequence == '[M' ]]; then
                    # Legacy X10 mouse protocol appends three coordinate bytes.
                    for ((count=0; count<3; count++)); do
                        IFS= read -rsn1 -t 0.10 char || break
                        sequence+=$char
                    done
                fi
            fi
            case "$sequence" in
                '[A' | 'OA') UI_KEY=up ;;
                '[B' | 'OB') UI_KEY=down ;;
                '[5~') UI_KEY=page_up ;;
                '[6~') UI_KEY=page_down ;;
                '[H' | 'OH' | '[1~') UI_KEY=home ;;
                '[F' | 'OF' | '[4~') UI_KEY=end ;;
                '[<'*M | '[<'*m | '[M'*) UI_KEY=mouse ;;
                *) UI_KEY=ignore ;;
            esac
            ;;
        *) UI_KEY=ignore ;;
    esac
}

ui_start() {
    local rows columns
    ui_active=true
    rows=$(tput lines 2>/dev/null || printf '24')
    columns=$(tput cols 2>/dev/null || printf '80')
    ((rows < 32 || columns < 72)) && ui_compact=true
    printf '\033[?1049h\033[?25l'
    ui_alt_screen=true
    ui_cursor_hidden=true
}

ui_restore() {
    # End a synchronized update if a signal interrupted a frame.
    $ui_active && printf '\033[?2026l'
    $ui_cursor_hidden && printf '\033[?25h'
    $ui_alt_screen && printf '\033[?1049l'
    ui_cursor_hidden=false
    ui_alt_screen=false
    ui_active=false
}

ui_clear() {
    printf '\033[2J\033[H'
}

ui_center() {
    local text=$1 columns padding=0
    columns=$(tput cols 2>/dev/null || printf '80')
    ((${#text} < columns)) && padding=$(((columns - ${#text}) / 2))
    printf '%*s%s\n' "$padding" '' "$text"
}

ui_center_styled() {
    local style=$1 text=$2 columns padding=0
    columns=$(tput cols 2>/dev/null || printf '80')
    ((${#text} < columns)) && padding=$(((columns - ${#text}) / 2))
    printf '%*s%s%s%s\n' "$padding" '' "$style" "$text" "$UI_RESET"
}

ui_width() {
    local columns
    columns=$(tput cols 2>/dev/null || printf '80')
    ((columns > 84)) && columns=84
    ((columns < 40)) && columns=40
    printf '%d' "$((columns - 4))"
}

ui_rule() {
    local width rule
    width=$(ui_width)
    printf -v rule '%*s' "$width" ''
    printf '%s%s%s\n' "$UI_DIM" "${rule// /─}" "$UI_RESET"
}

ui_section() {
    printf '%s%s%s  %s%s%s\n' "$UI_PURPLE" '◆' "$UI_RESET" "$UI_BOLD" "$1" "$UI_RESET"
}

ui_kv() {
    printf '  %s%-14s%s %s\n' "$UI_DIM" "$1" "$UI_RESET" "$2"
}

ui_footer() {
    printf '\n'
    ui_rule
    printf '%s%s%s\n' "$UI_DIM" "$1" "$UI_RESET"
}

ui_heading() {
    local clear_screen=${1:-true}
    if [[ $clear_screen == true ]]; then
        ui_clear
    else
        # Repaint in place. Avoiding a full erase prevents visible flashes
        # while navigating lists on slower terminals and remote sessions.
        # Kitty and other modern terminals buffer synchronized updates; older
        # terminals safely ignore this private mode.
        printf '\033[?2026h\033[H'
    fi
    if $ui_compact; then
        printf '%s%s◆ KAIRO%s\n%sArch-first dotfiles installer%s\n' \
            "$UI_BOLD" "$UI_CYAN" "$UI_RESET" "$UI_DIM" "$UI_RESET"
        ui_rule
        printf '\n'
    else
        ui_center_styled "${UI_CYAN}${UI_BOLD}" '██╗  ██╗ █████╗ ██╗██████╗  ██████╗ '
        ui_center_styled "${UI_CYAN}${UI_BOLD}" '██║ ██╔╝██╔══██╗██║██╔══██╗██╔═══██╗'
        ui_center_styled "${UI_CYAN}${UI_BOLD}" '█████╔╝ ███████║██║██████╔╝██║   ██║'
        ui_center_styled "${UI_CYAN}${UI_BOLD}" '██╔═██╗ ██╔══██║██║██╔══██╗██║   ██║'
        ui_center_styled "${UI_CYAN}${UI_BOLD}" '██║  ██╗██║  ██║██║██║  ██║╚██████╔╝'
        ui_center_styled "${UI_CYAN}${UI_BOLD}" '╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═╝ ╚═════╝ '
        printf '\n'
        ui_center_styled "$UI_DIM" 'Arch-first development environment installer'
        printf '\n'
    fi
}

ui_card() {
    ui_section "$1"
    printf '\n  %s\n' "$2"
    printf '\n'
}

ui_stage() {
    local current=$1 total=$2 label=$3 index marker connector
    printf '\n'
    for ((index=1; index<=total; index++)); do
        if ((index < current)); then marker="${UI_GREEN}●${UI_RESET}"
        elif ((index == current)); then marker="${UI_CYAN}◆${UI_RESET}"
        else marker="${UI_DIM}○${UI_RESET}"; fi
        printf '%b' "$marker"
        if ((index < total)); then
            ((index < current)) && connector="${UI_GREEN}━━${UI_RESET}" || connector="${UI_DIM}──${UI_RESET}"
            printf '%b' "$connector"
        fi
    done
    printf '  %s%s[%d/%d]%s %s\n' "$UI_BOLD" "$UI_WHITE" "$current" "$total" "$UI_RESET" "$label"
    if ! $ui_compact; then
        printf '%s' "$UI_DIM"
        for ((index=0; index<total; index++)); do printf '%-6.6s' "${UI_STAGE_LABELS[index]}"; done
        printf '%s\n' "$UI_RESET"
    fi
}

ui_status() {
    local kind=$1 message=$2 icon color
    case "$kind" in
        ok) icon='✓'; color=$UI_GREEN ;;
        changed) icon='↻'; color=$UI_CYAN ;;
        skip) icon='○'; color=$UI_DIM ;;
        warn) icon='!'; color=$UI_YELLOW ;;
        error) icon='✗'; color=$UI_RED ;;
        *) icon='·'; color=$UI_RESET ;;
    esac
    printf '%s%s%s %s\n' "$color" "$icon" "$UI_RESET" "$message"
}

ui_run_spinner() {
    local label=$1 log status frame=0
    shift
    local -a frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
    log=$(mktemp)
    "$@" >"$log" 2>&1 &
    local command_pid=$!
    while kill -0 "$command_pid" 2>/dev/null; do
        printf '\r%s%s%s %s' "$UI_CYAN" "${frames[frame]}" "$UI_RESET" "$label"
        frame=$(((frame + 1) % ${#frames[@]}))
        sleep 0.08
    done
    if wait "$command_pid"; then
        status=0
        printf '\r\033[2K%s✓%s %s\n' "$UI_GREEN" "$UI_RESET" "$label"
    else
        status=$?
        printf '\r\033[2K%s✗%s %s\n' "$UI_RED" "$UI_RESET" "$label"
        sed 's/^/  /' "$log" >&2
    fi
    rm -f -- "$log"
    return "$status"
}

ui_wait_for_enter() {
    ui_footer 'Enter  continue    Q / Esc  cancel'
    ui_read_key || return 1
    printf '\n'
    case "$UI_KEY" in
        enter) return 0 ;;
        quit | escape) return 1 ;;
        *) return 0 ;;
    esac
}

ui_confirm() {
    local prompt=$1
    printf '%s?%s %s %s[y/N]%s ' "$UI_YELLOW" "$UI_RESET" "$prompt" "$UI_DIM" "$UI_RESET"
    ui_read_key || return 1
    printf '\n'
    [[ $UI_KEY == yes ]]
}

ui_select_modules() {
    local -n names_ref=$1 labels_ref=$2 categories_ref=$3 selected_ref=$4
    local cursor=0 index count=${#names_ref[@]} previous_category=''
    local rows page_size start end selected_count
    ui_clear
    while true; do
        ui_heading false
        selected_count=0
        for ((index=0; index<count; index++)); do [[ ${selected_ref[index]} == true ]] && ((selected_count++)) || true; done
        ui_section 'Choose your modules'
        printf '  %s%d selected%s\n' "$UI_GREEN" "$selected_count" "$UI_RESET"
        rows=$(tput lines 2>/dev/null || printf '24')
        page_size=$((rows - 10))
        ((page_size < 6)) && page_size=6
        ((page_size > count)) && page_size=$count
        start=$((cursor / page_size * page_size))
        end=$((start + page_size))
        ((end > count)) && end=$count
        previous_category=''
        for ((index=start; index<end; index++)); do
            if [[ ${categories_ref[index]} != "$previous_category" ]]; then
                previous_category=${categories_ref[index]}
                printf '\n  %s%s%s\n' "$UI_PURPLE" "$previous_category" "$UI_RESET"
            fi
            if ((index == cursor)); then printf '%s%s  › %s' "$UI_SURFACE" "$UI_BOLD" "$UI_RESET"; else printf '    '; fi
            if [[ ${selected_ref[index]} == true ]]; then
                printf '%s●%s %-20s' "$UI_GREEN" "$UI_RESET" "${labels_ref[index]}"
            else
                printf '%s○%s %-20s' "$UI_DIM" "$UI_RESET" "${labels_ref[index]}"
            fi
            ((index == cursor)) && printf '%s' "$UI_RESET"
            printf '\n'
        done
        ((count > page_size)) && printf '\n%s%d–%d of %d modules%s\n' "$UI_DIM" "$((start + 1))" "$end" "$count" "$UI_RESET"
        ui_footer '↑/↓ or j/k  move    Space  toggle    A  all    N  none    Enter  review'
        # Remove remnants only after the new frame has been painted.
        printf '\033[J\033[?2026l'
        ui_read_key || return 1
        case "$UI_KEY" in
            space) [[ ${selected_ref[cursor]} == true ]] && selected_ref[cursor]=false || selected_ref[cursor]=true ;;
            all) for ((index=0; index<count; index++)); do selected_ref[index]=true; done ;;
            none) for ((index=0; index<count; index++)); do selected_ref[index]=false; done ;;
            quit | escape) return 1 ;;
            enter) return 0 ;;
            up) ((cursor > 0)) && ((cursor--)) || true ;;
            down) ((cursor + 1 < count)) && ((cursor++)) || true ;;
            page_up) cursor=$((cursor - page_size)); ((cursor < 0)) && cursor=0 ;;
            page_down) cursor=$((cursor + page_size)); ((cursor >= count)) && cursor=$((count - 1)) ;;
            home) cursor=0 ;;
            end) cursor=$((count - 1)) ;;
            mouse | ignore) continue ;;
        esac
    done
}

ui_success() {
    local details=$1 title=${2:-INSTALLATION COMPLETE}
    ui_heading
    ui_center_styled "${UI_GREEN}${UI_BOLD}" "✓  $title"
    printf '\n'
    ui_rule
    printf '\n%s\n' "$details"
}

ui_failure() {
    ui_heading
    ui_center_styled "${UI_RED}${UI_BOLD}" '✗  INSTALLATION FAILED'
    printf '\n'
    ui_rule
    printf '\n%s%s%s\n' "$UI_RED" "$1" "$UI_RESET" >&2
}
