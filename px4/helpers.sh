# shellcheck shell=bash
HELPERS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PX4_DIR="${PX4_DIR:-$HOME/code/px4}"
NEWTON_DIR="${NEWTON_DIR:-$HOME/code/newton-air-internal}"
alias cdpx='cd $PX4_DIR'

# Build (and optionally flash) a NuttX firmware target in the px4-nuttx container
mpx() {
	if [[ $# -eq 0 ]]; then
		echo "Usage: mpx <NuttX target> [make args...] [--build]"
		echo "Example: mpx px4_fmu-v5x_altaxv2"
		echo "         mpx px4_fmu-v5x_altaxv2 upload   # build + flash over USB"
		echo "         mpx px4_fmu-v3_altaxv1 --build   # rebuild the image first"
		return 1
	fi
	local build=false
	local make_args=()
	for arg in "$@"; do
		if [[ "$arg" == "--build" ]]; then
			build=true
		else
			make_args+=("$arg")
		fi
	done

	# The image entrypoint starts as root, creates a user with LOCAL_USER_ID and drops
	# to it (so build artifacts are owned by us) — do NOT pass --user, which would block
	# the entrypoint's usermod.
	local run_args=(run --rm -e LOCAL_USER_ID="$(id -u)")
	$build && run_args+=(--build)

	PX4_DIR="$PX4_DIR" docker compose \
		-f "$HELPERS_DIR/docker/docker-compose.yml" \
		"${run_args[@]}" px4-nuttx make "${make_args[@]}" || return

	# Refresh compile_commands.json for the target just built (first make arg).
	cp "$PX4_DIR/build/${make_args[0]}/compile_commands.json" "$PX4_DIR/" 2>/dev/null
}

# Run PX4 SITL in the newton-air-internal px4-sitl container
mpxs() {
	if [[ $# -eq 0 ]]; then
		echo "Usage: mpxs <model> [--build]"
		echo "Example: mpxs astro_max"
		return 1
	fi
	local model="$1"
	shift 1
	[[ "$model" == none_* ]] || model="none_$model"

	local build=false
	for arg in "$@"; do
		[[ "$arg" == "--build" ]] && build=true
	done

	local compose=(-f "$NEWTON_DIR/docker/docker-compose.yml")
	if $build; then
		PX4_DIR="$PX4_DIR" docker compose "${compose[@]}" build px4-sitl || return
	fi
	PX4_DIR="$PX4_DIR" docker compose "${compose[@]}" run --rm px4-sitl make px4_sitl "$model"
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
