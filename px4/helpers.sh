# shellcheck shell=bash
PX4_DIR="${PX4_DIR:-$HOME/code/px4}"
alias cdpx='cd $PX4_DIR'

mpx() {
	if [[ $# -eq 0 ]]; then
		echo "Usage: mpx <NuttX target>"
		echo "Example: mpx px4_fmu-v5x"
		return 1
	fi
	local DOCKER_DIR="$PX4_DIR/Tools/simulation/newton/px4-newton-bridge/docker"
	local build=false
	local make_args=()
	for arg in "$@"; do
		if [[ "$arg" == "--build" ]]; then
			build=true
		else
			make_args+=("$arg")
		fi
	done

	local compose_args=(-f "$DOCKER_DIR/docker-compose.yaml")
	if $build; then
		compose_args+=(-f "$DOCKER_DIR/docker-compose.build.yaml")
	fi

	local run_args=(run --rm --user "$(id -u):$(id -g)")
	$build && run_args+=(--build)

	local prev_dir="$PWD"
	cd "$DOCKER_DIR" && PX4_DIR="$PX4_DIR" docker compose "${compose_args[@]}" "${run_args[@]}" px4-firmware make "${make_args[@]}"
	cd "$prev_dir" || return

	cp "$PX4_DIR/build/$build_dir_name/compile_commands.json" "$PX4_DIR/" 2>/dev/null
}

mpxs() {
	if [[ $# -eq 0 ]]; then
		echo "Usage: mpxs <SITL target> [--build]"
		echo "Example: mpxs astro_max"
		return 1
	fi
	local model="$1"
	shift 1

	local build=false
	for arg in "$@"; do
		[[ "$arg" == "--build" ]] && build=true
	done

	if $build; then
		local DOCKER_DIR="$PX4_DIR/Tools/simulation/newton/px4-newton-bridge/docker"
		cd "$DOCKER_DIR" && PX4_DIR="$PX4_DIR" \
			docker compose -f docker-compose.yaml -f docker-compose.build.yaml \
			build px4-sitl-newton
		cd - > /dev/null
	fi

	"$PX4_DIR/Tools/simulation/newton/px4-newton-bridge/run_docker.sh" "$model"
}

mavtcp() {
# Start MAVLink router that allows connecting local GCS to remote PX4 instance
# Requires `mavp2p` on the remote server
	if ! command -v mavp2p > /dev/null; then
		echo "mavp2p not found"
		return 1
	fi
	mavp2p udps:0.0.0.0:14550 tcps:0.0.0.0:5760 > /dev/null 2>&1 &
	echo "MAVLink router started"
}
