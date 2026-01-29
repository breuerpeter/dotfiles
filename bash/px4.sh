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
	local -a env_pairs=()
	for arg in "$@"; do
		if [[ "$arg" == *=* ]]; then
			env_pairs+=("$arg")
		else
			[[ "$arg" == *r* ]] && remote=true
			[[ "$arg" == *s* ]] && stay=true
		fi
	done

	local -a exec_cmd=(make px4_sitl newton_astro)
	if $stay; then
		exec_cmd=(bash -lc 'trap : INT; make px4_sitl newton_astro; exec bash')
	fi

	local -a docker_exec_cmd=(docker exec -it)
	for pair in "${env_pairs[@]}"; do
		docker_exec_cmd+=(-e "$pair")
	done
	docker_exec_cmd+=(px4-sitl-newton "${exec_cmd[@]}")

	local cp_cmd="cp $HOME/code/px4/build/px4_sitl_default/compile_commands.json $HOME/code/px4/"

	if $remote; then
		printf -v exec_str '%q ' "${docker_exec_cmd[@]}"
		exec_str=${exec_str% }
		local cmd="cd ~/code/px4-docker/docker && docker compose up px4-sitl-newton -d && $exec_str; $cp_cmd"
		ssh -t black "mavp2p udps:0.0.0.0:14550 tcps:0.0.0.0:5760 > /dev/null 2>&1 & $cmd"
	else
		cd ~/code/px4-docker/docker && docker compose up px4-sitl-newton -d && "${docker_exec_cmd[@]}"
		$cp_cmd
	fi
}
