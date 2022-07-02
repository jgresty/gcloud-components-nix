#!/usr/bin/env nix-shell
#! nix-shell -i bash -p jq curl nixfmt

VERSION="392.0.0"
BASE_URL="https://dl.google.com/dl/cloudsdk/channels/rapid/"
DATA=$(curl "${BASE_URL}components-v${VERSION}.json")

function genPkgs() {
    local nixsys="${1}"
    local gosys="${2}"

    echo "$nixsys = {"

    jq -r --arg sys "-$gosys" --arg url "$BASE_URL" '.components[] 
        | select(.id | endswith($sys)) 
        | "\(.id | split($sys)[0]) = {
            src = {
                url = \"\($url)\(.data.source)\";
                sha256 = \"\(.data.checksum)\";
            };
            version = \"\(.version.version_string)\";
        };"
        ' <<<"$DATA" | cat

    echo "};"
}

{
    cat <<EOF
# DO NOT EDIT! This file is generated automatically by update.sh
{ }:
{
  version = "${VERSION}";
  googleCloudSdkComponents = {
EOF
    genPkgs "x86_64-linux" "linux-x86_64"
    genPkgs "x86_64-darwin" "darwin-x86_64"
    genPkgs "aarch64-linux" "linux-arm"
    genPkgs "aarch64-darwin" "darwin-arm"
    genPkgs "i686-linux" "linux-x86"
    echo "};}"

} >data.nix

nixfmt data.nix
