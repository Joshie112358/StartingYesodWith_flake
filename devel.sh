# TODO: Fix crazy reloading.

ghcid --command '(echo ":l app/DevelMain.hs" && cat) | cabal v2-repl' --test 'update' --warnings
