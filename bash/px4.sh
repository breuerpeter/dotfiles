alias cdpx='cd ~/code/px4/'

mpx() {(
    set -e
    local target=${@-px4_fmu-v5x_altaxv2}
    cdpx
    ./Tools/docker_run.sh "make $target"
    cp "build/$target/compile_commands.json" .
)}
