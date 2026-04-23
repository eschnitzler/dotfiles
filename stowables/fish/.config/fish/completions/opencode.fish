###-begin-opencode-completions-###
#
# Fish completion script for opencode
#
function __opencode_completions
    set -l tokens (commandline -opc)
    opencode --get-yargs-completions $tokens
end

complete -c opencode -f -a '(__opencode_completions)'
###-end-opencode-completions-###

