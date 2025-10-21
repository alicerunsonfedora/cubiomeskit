#! /bin/sh
set -e

if [[ "$(uname -m)" == arm64 ]]
then
    export PATH="/opt/homebrew/bin:$PATH"
fi

(killall 'CubiomesKitAdwaitaDemo' || true) 2>/dev/null

cd ..
swift run -c debug --traits Adwaita