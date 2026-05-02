function fish_prompt
    set -l last_status $status

    if contains -- --final-rendering $argv
        set_color 404747
        echo -n "❯"
        set_color normal
        return
    end

    # Línea 1 → ruta
    echo ""

    # detectar venv
    set -l in_venv 0
    if set -q VIRTUAL_ENV
        set in_venv 1
    end

    # color de ruta
    if test $in_venv -eq 1
        set_color green
    else
        set_color blue
    end

    set -l path (string replace $HOME "~" $PWD)

    # detectar rama actual
    set -l branch ""
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1
        set branch (git branch --show-current 2>/dev/null)
    end

    # imprimir ruta + rama
    if test -n "$branch"
        echo -n $path
        set_color f4c430
        echo " (󰊢 $branch)"
    else
        echo $path
    end

    # Estado git
    set -l git_unstaged 0
    set -l git_staged 0
    set -l git_ahead 0

    if git rev-parse --is-inside-work-tree >/dev/null 2>&1
        # 1) cambios sin stage (tracked)
        git diff --quiet >/dev/null 2>&1
        if test $status -ne 0
            set git_unstaged 1
        end

        # 1b) archivos untracked
        set -l untracked_count (git ls-files --others --exclude-standard 2>/dev/null | wc -l)
        if test "$untracked_count" -gt 0
            set git_unstaged 1
        end

        # 2) cambios staged pero sin commit
        git diff --cached --quiet >/dev/null 2>&1
        if test $status -ne 0
            set git_staged 1
        end

        # 3) commits locales sin push
        if git rev-parse --abbrev-ref '@{upstream}' >/dev/null 2>&1
            set -l ahead_count (git rev-list --count '@{upstream}..HEAD' 2>/dev/null)
            if test "$ahead_count" -gt 0
                set git_ahead 1
            end
        end
    end

    # icono de venv antes de las flechas
    if test $in_venv -eq 1
        set_color green
        echo -n "󰡄 "
    end

    # Flecha 1
    if test $last_status -ne 0
        set_color 404747
    else if test $git_unstaged -eq 1
        set_color e0b000
    else
        set_color 404747
    end
    echo -n "❯"

    # Flecha 2
    if test $last_status -ne 0
        set_color b30505
    else if test $git_unstaged -eq 1
        set_color f4c430
    else if test $git_staged -eq 1
        set_color f4c430
    else
        set_color 757782
    end
    echo -n "❯"

    # Flecha 3
    if test $last_status -ne 0
        set_color eb0505
    else if test $git_unstaged -eq 1
        set_color ffd95a
    else if test $git_staged -eq 1
        set_color ffd95a
    else if test $git_ahead -eq 1
        set_color ffd95a
    else
        set_color ffffff
    end
    echo -n "❯ "

    set_color normal
end
