OMEGARPG_SERVER_CONFIG=${OMEGARPG_SERVER_CONFIG:-"$HOME/.OmegaRPG/settings/orpg_serversettings.json"}
echo "using config $OMEGARPG_SERVER_CONFIG"
TMP_HOME="$(mktemp -d --suffix "-orpg")"
mkdir -p "$TMP_HOME"/.OmegaRPG/settings
cp "$OMEGARPG_SERVER_CONFIG" "$TMP_HOME/.OmegaRPG/settings/orpg_serversettings.json"
HOME="$TMP_HOME" OmegaRPG-Server-CLI
