alias cdpx='cd ~/code/px4/'

mpx() {(
    set -e
    local target=${@-px4_fmu-v5x_altaxv2}
    cdpx
    ./Tools/docker_run.sh "make $target"
    cp "build/$target/compile_commands.json" .
)}

mpxs() {
	local remote=false stay=false
	for arg in "$@"; do
		[[ "$arg" == *r* ]] && remote=true
		[[ "$arg" == *s* ]] && stay=true
	done

	local exec_cmd="make px4_sitl newton_astro"
	$stay && exec_cmd='bash -c "trap : INT; make px4_sitl newton_astro; exec bash"'

	local cmd="cd ~/code/px4-docker/docker && docker compose up px4-sitl-newton -d && docker exec -it px4-sitl-newton $exec_cmd"

	if $remote; then
		ssh -t black "mavp2p udps:0.0.0.0:14550 tcps:0.0.0.0:5760 > /dev/null 2>&1 & $cmd"
	else
		eval "$cmd"
	fi
}
