#!/usr/bin/env bash

set -euo pipefail

OLD_VERSION=$(yj -tj < builder.toml | jq -r '.lifecycle.uri | capture(".+/v(?<version>[\\d]+\\.[\\d]+\\.[\\d]+)/.+") | .version')

update-lifecycle-dependency \
  --builder-toml builder.toml \
  --version "${VERSION}"

git add builder.toml
git checkout -- .

if [ "$(echo "$OLD_VERSION" | awk -F '.' '{print $1}')" != "$(echo "$VERSION" | awk -F '.' '{print $1}')" ]; then
  LABEL="semver:major"
elif [ "$(echo "$OLD_VERSION" | awk -F '.' '{print $2}')" != "$(echo "$VERSION" | awk -F '.' '{print $2}')" ]; then
  LABEL="semver:minor"
else
  LABEL="semver:patch"
fi

echo "::set-output name=old-version::${OLD_VERSION}"
echo "::set-output name=new-version::${VERSION}"
echo "::set-output name=version-label::${LABEL}"
