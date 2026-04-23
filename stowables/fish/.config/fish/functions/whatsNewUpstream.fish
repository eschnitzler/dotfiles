function whatsNewUpstream
    set BRANCH (git symbolic-ref --short HEAD)
    git fetch

    git log HEAD..origin/"$BRANCH"

    if test "$argv[1]" = "--diff"; or test "$argv[1]" = "-d"
        git difftool HEAD...origin/"$BRANCH"
    end
    if test "$argv[1]" = "--patch"; or test "$argv[1]" = "-p"
        git log -p HEAD..origin/"$BRANCH"
    end
end
