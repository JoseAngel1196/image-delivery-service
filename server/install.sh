#!/bin/bash

# Constants
PYTHON_VERSION=3.8.6


# Install Pyenv
output=$(brew ls --formula pyenv 2>&1)
if [[ $output == *"Error"* ]];then
  printf "${GREEN}Installing pyenv package...\n"
  brew install pyenv
  printf '\n# Pyenv Init\nif command -v pyenv 1>/dev/null 2>&1; then\n  eval "$(pyenv init -)"\nfi\n# Add Pyenv to $PATH\nexport PATH="$(pyenv root)/shims:$PATH"' >> $BASH_FILE
  source $BASH_FILE
else
    printf "${GREEN}pyenv package already installed...\n"
fi

# Install pyenv-virtualenv
output=$(brew ls --formula pyenv-virtualenv 2>&1)
if [[ $output == *"Error"* ]];then
  printf "${GREEN}Installing pyenv-virtualenv package...\n"
  brew install pyenv-virtualenv
  printf "\neval \"\$(pyenv init -)\"\neval \"\$(pyenv virtualenv-init -)\"" >> $BASH_FILE
  source $BASH_FILE
else
    printf "${GREEN}pyenv-virtualenv package already installed...\n"
fi

# Install Python Version
if [[ ! $(pyenv versions | grep $PYTHON_VERSION) ]];then
  printf "${GREEN}Installing python version $PYTHON_VERSION...\n"
  pyenv install $PYTHON_VERSION
else
    printf "${GREEN}Python $PYTHON_VERSION already installed...\n"
fi

# Create Virtual Env
if [[ ! $(pyenv virtualenvs | grep newton) ]];then
  printf "${GREEN}Creating newton virtualenv...\n"
  pyenv virtualenv $PYTHON_VERSION newton &> /dev/null
else
    printf "${GREEN}Virtualenv newton exists...\n"
fi

if [[ ! $(brew list pre-commit) ]]; then
    printf "${GREEN}Installing pre-commit...\n"
    brew install pre-commit
fi

printf "${GREEN}Installing pre-commit hooks...\n"
pre-commit install --install-hooks --hook-type pre-commit --hook-type pre-push

if [[ ! $(brew list redis) ]]; then
    printf "${GREEN}Installing redis...\n"
    brew install redis
fi

if [[ ! $(brew list --cask chromedriver) ]]; then
    printf "${GREEN}Installing chromedriver...\n"
    brew install --cask chromedriver
fi
xattr -d com.apple.quarantine $(brew list --cask chromedriver | awk '{print $3}')
# replace $cdc_ in chromedriver with $god_ to avoid selenium detection on some sites
perl -pi -e 's/cdc_/god_/g' $(brew list --cask chromedriver | awk '{print $3}')

if [[ ! -f ".env" ]]; then
    printf "${GREEN}Creating .env file...\n"
    cp .env.example .env
fi

if [[ ! -f "_scripts/cli_runner/config.json" ]]; then
    printf "${GREEN}Creating CLI Runner config...\n"
    cp _scripts/cli_runner/config.example.json _scripts/cli_runner/config.json
fi

printf "${GREEN}\n======================\nInstallation complete!\n======================\n"