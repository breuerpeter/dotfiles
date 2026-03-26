# shellcheck shell=bash
PX4_DIR="${PX4_DIR:-$HOME/code/px4}"
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCKER_DIR="$PROJECT_DIR/src/test/docker"
alias cdpx='cd $PX4_DIR'

_mpx_run() {
	local container="$1"
	shift 1

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
	if nvidia-smi &>/dev/null; then
		compose_args+=(-f "$DOCKER_DIR/docker-compose.gpu.yaml")
	fi
	if $build; then
		compose_args+=(-f "$DOCKER_DIR/docker-compose.build.yaml")
	fi

	local run_args=(run --rm --user "$(id -u):$(id -g)")
	$build && run_args+=(--build)

	local prev_dir="$PWD"
	cd "$DOCKER_DIR" && PX4_DIR="$PX4_DIR" docker compose "${compose_args[@]}" "${run_args[@]}" "$container" make "${make_args[@]}"
	# Go back to starting dir after exiting container
	cd "$prev_dir" || return
	# Post-build: copy compile_commands.json for clangd and exclude .cache from git
	cp "$PX4_DIR/build/$build_dir_name/compile_commands.json" "$PX4_DIR/" 2>/dev/null
	grep -qxF '.cache/' "$PX4_DIR/.git/info/exclude" 2>/dev/null || echo '.cache/' >> "$PX4_DIR/.git/info/exclude"
}

mpx() {
	if [[ $# -eq 0 ]]; then
		echo "Usage: mpx <NuttX target>"
		echo "Example: mpx px4_fmu-v5x"
		return 1
	fi
	_mpx_run px4-firmware "$@"
}

mpxs() {
	if [[ $# -eq 0 ]]; then
		echo "Usage: mpxs <SITL target>"
		echo "Example: mpxs astro_max"
		return 1
	fi
	local model="$1"
	shift 1
	if [[ "${HEADLESS:-0}" != "1" ]] && ! pgrep -x rerun &>/dev/null; then
		rerun &>/dev/null &
		disown
	fi
	_mpx_run px4-sitl "$@" px4_sitl_newton "newton_$model"
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
