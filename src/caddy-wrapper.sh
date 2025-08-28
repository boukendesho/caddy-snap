#!/bin/sh -eux

cli() {
  # Grab the first argument and drop it from the input
  arg="$1"
  shift 1

  case $arg in
    # Users can update caddy with additional plugins or modules at runtime. The
    # caddy binary needs to be mutable in this case.
    add-package)
      [ -e "${SNAP_COMMON}/caddy-mod" ] || {
        cp -f "${SNAP}/usr/bin/caddy" "${SNAP_COMMON}/caddy-mod"
        _caddy="${SNAP_COMMON}/caddy-mod"
      }

      $_caddy "$arg" "$@"

      for mod in "$@"; do
        snapctl set "module.${mod##*/}"="$mod"

        mod_count=$(snapctl get modules)

        snapctl set modules=$((mod_count + 1))
      done
      snapctl set modified=true        ;;
    remove-package)
      for mod in "$@"; do
        mod_count="$(snapctl get modules)"

        $_caddy "$arg" "$mod"

        snapctl unset "module.${mod##*/}"
        snapctl set modules=$((mod_count - 1))
      done

     # If no modules are in the list, we've removed all the modules. Go back to
     # the normal caddy binary
      [ "$(snapctl get modules)" -gt 0 ] || {
        snapctl unset modified; snapctl unset module
      }

      rm -f "${SNAP_COMMON}/caddy-mod" ;;
    *) $_caddy "$arg" "$@"             ;;
  esac
}

# Avoid downtime when restarting the service
reload() {
  $_caddy reload --config "${SNAP_COMMON}/caddy.json"
}

# This runs the caddy server
run() {
  $_caddy run \
    --config  "${SNAP_COMMON}/caddy.json" \
    --pidfile "${SNAP_COMMON}/caddy.pid"
}

# Must be root to write to $$SNAP_COMMON
[ "$(id -u)" = 0 ] || {
  echo "Please run caddy as root!"
  exit 0
}

# If the user has modified the caddy binary via modules, use it instead
_caddy="${SNAP}/usr/bin/caddy"
[ "$(snapctl get modified)" = "true" ] && _caddy="${SNAP_COMMON}/caddy-mod"

"$@"
