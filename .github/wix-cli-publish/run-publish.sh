#!/bin/bash

echo "Running custom publish script"

echo "WIX_CLI_APP_INFO: $WIX_CLI_APP_INFO"
echo "WIX_SESSION2: $WIX_SESSION2"

# Use the src and wml folders from the shared volume so it is taken from the repo which runs the docker
rm -rf src wml
mkdir src wml

cp -R /mnt/src/* src
cp -R /mnt/wml/* wml

echo "Copied the src and wml folders from the shared volume"

curl -s -X POST "https://editor.wix.com/templates-with-cli-poc/api/poc-app/cli-access" \
            -H "Content-Type: application/json" \
            -d "{\"encodedAppData\":\"$WIX_CLI_APP_INFO\"}" \
            -o response.json

echo "Got response from the server"

# Assuming response.json is already available in the current directory
jq -r '.cliFiles[] | "\(.name) \(.content)"' response.json | while IFS= read -r line; do
    name_str=$(echo "$line" | cut -d' ' -f1)
    eval "name=$name_str"
    content=$(echo "$line" | cut -d' ' -f2-)
    mkdir -p "$(dirname "$name")" # Ensure the directory exists
    echo "$content" > "$name"
done

ls -la ~/.wix/auth/b42aec4e-9841-41c4-807c-cf2721361b90.json

CMD="wix preview --source local"

if [[ -n $PUBLISH ]]; then
  CMD="wix publish --force --source local"
fi

npm install -g ./.github/wix-cli-publish/wix_cli.tar.gz
echo "Opening dev Editor"
BROWSER_APP=$(which chromium) WIX_SESSION2="$WIX_SESSION2" wix dev --experimental-wml --headless
echo "Publish/Previewing the site"
eval $CMD
echo "Done!"
