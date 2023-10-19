#!/bin/bash

# Based on: https://medium.com/dot-debug/running-chrome-in-a-docker-container-a55e7f4da4a8

readonly G_LOG_I='[INFO]'
readonly G_LOG_W='[WARN]'
readonly G_LOG_E='[ERROR]'

launch_xvfb() {
  # Set defaults if the user did not specify envs.
  export DISPLAY=${XVFB_DISPLAY:-:1}
  local screen=${XVFB_SCREEN:-0}
  local resolution=${XVFB_RESOLUTION:-1280x1024x24}
  local timeout=${XVFB_TIMEOUT:-5}

  # Start and wait for either Xvfb to be fully up or we hit the timeout.
  Xvfb ${DISPLAY} -screen ${screen} ${resolution} &
  local loopCount=0
  until xdpyinfo -display ${DISPLAY} >/dev/null 2>&1; do
    loopCount=$((loopCount + 1))
    sleep 1
    if [ ${loopCount} -gt ${timeout} ]; then
      echo "${G_LOG_E} xvfb failed to start."
      exit 1
    fi
  done
}

launch_window_manager() {
  local timeout=${XVFB_TIMEOUT:-5}

  # Start and wait for either fluxbox to be fully up or we hit the timeout.
  fluxbox &
  local loopCount=0
  until wmctrl -m >/dev/null 2>&1; do
    loopCount=$((loopCount + 1))
    sleep 1
    if [ ${loopCount} -gt ${timeout} ]; then
      echo "${G_LOG_E} fluxbox failed to start."
      exit 1
    fi
  done
}

launch_chrome() {
  export DISPLAY=:10
  export WB_CHROME_ENDPOINT=127.0.0.1:9222

  Xvfb "$DISPLAY" -ac &

  service dbus start

  export XDG_RUNTIME_DIR=/run/user/$(id -u)

  mkdir $XDG_RUNTIME_USER

  chmod 700 $XDG_RUNTIME_DIR
  chown $(id -un):$(id -gn) $XDG_RUNTIME_DIR

  export DBUS_SESSION_BUS_ADDRESS=unix:path=$XDG_RUNTIME_DIR/bus

  dbus-daemon --session --address=$DBUS_SESSION_BUS_ADDRESS --nofork --nopidfile --syslog-only &

  google-chrome --disable-gpu --no-sandbox --disable-setuid-sandbox --remote-debugging-port=9222 &

  sleep 1
}

launch_xvfb
launch_window_manager
launch_chrome

if [[ "${WB_USE_LAMBDA_API}" == "0" ]]; then
  node app.js
  exit $?
fi

if [[ -z "${AWS_LAMBDA_RUNTIME_API}" ]]; then
  exec /usr/local/bin/aws-lambda-rie /usr/bin/npx aws-lambda-ric $1
else
  exec /usr/bin/npx aws-lambda-ric $1
fi
