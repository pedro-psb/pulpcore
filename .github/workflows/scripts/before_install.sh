#!/usr/bin/env bash

# WARNING: DO NOT EDIT!
#
# This file was generated by plugin_template, and is managed by it. Please use
# './plugin-template --github pulpcore' to update this file.
#
# For more info visit https://github.com/pulp/plugin_template

# make sure this script runs at the repo root
cd "$(dirname "$(realpath -e "$0")")"/../../..

set -mveuo pipefail

if [ "${GITHUB_REF##refs/heads/}" = "${GITHUB_REF}" ]
then
  BRANCH_BUILD=0
else
  BRANCH_BUILD=1
  BRANCH="${GITHUB_REF##refs/heads/}"
fi
if [ "${GITHUB_REF##refs/tags/}" = "${GITHUB_REF}" ]
then
  TAG_BUILD=0
else
  TAG_BUILD=1
  BRANCH="${GITHUB_REF##refs/tags/}"
fi

COMMIT_MSG=$(git log --format=%B --no-merges -1)
export COMMIT_MSG

COMPONENT_VERSION=$(sed -ne "s/\s*version.*=.*['\"]\(.*\)['\"][\s,]*/\1/p" setup.py)

mkdir .ci/ansible/vars || true
echo "---" > .ci/ansible/vars/main.yaml
echo "legacy_component_name: pulpcore" >> .ci/ansible/vars/main.yaml
echo "component_name: core" >> .ci/ansible/vars/main.yaml
echo "component_version: '${COMPONENT_VERSION}'" >> .ci/ansible/vars/main.yaml

export PRE_BEFORE_INSTALL=$PWD/.github/workflows/scripts/pre_before_install.sh
export POST_BEFORE_INSTALL=$PWD/.github/workflows/scripts/post_before_install.sh

if [ -f $PRE_BEFORE_INSTALL ]; then
  source $PRE_BEFORE_INSTALL
fi

if [[ -n $(echo -e $COMMIT_MSG | grep -P "Required PR:.*") ]]; then
  echo "The Required PR mechanism has been removed. Consider adding a scm requirement to requirements.txt."
  exit 1
fi

if [ "$GITHUB_EVENT_NAME" = "pull_request" ] || [ "${BRANCH_BUILD}" = "1" -a "${BRANCH}" != "main" ]
then
  echo $COMMIT_MSG | sed -n -e 's/.*CI Base Image:\s*\([-_/[:alnum:]]*:[-_[:alnum:]]*\).*/ci_base: "\1"/p' >> .ci/ansible/vars/main.yaml
fi


cd ..

git clone --depth=1 https://github.com/pulp/pulp-openapi-generator.git

# Intall requirements for ansible playbooks
pip install docker netaddr boto3 ansible

for i in {1..3}
do
  ansible-galaxy collection install "amazon.aws:1.5.0" && s=0 && break || s=$? && sleep 3
done
if [[ $s -gt 0 ]]
then
  echo "Failed to install amazon.aws"
  exit $s
fi

cd pulpcore

if [[ "$TEST" = "lowerbounds" ]]; then
  python3 .ci/scripts/calc_deps_lowerbounds.py > lowerbounds_requirements.txt
  mv lowerbounds_requirements.txt requirements.txt
fi

if [ -f $POST_BEFORE_INSTALL ]; then
  source $POST_BEFORE_INSTALL
fi
