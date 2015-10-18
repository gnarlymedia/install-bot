#!/bin/bash
# Carter installation script
echo "---Installing---"
echo
echo "---Testing for nvm installation..."
if [ -f ~/.nvm/nvm.sh ];
then
    nvm_test_exit_code=0
    echo "---Nvm is installed---"
    echo
    echo "---Sourcing nvm shell script..."
    . ~/.nvm/nvm.sh
    echo "---Nvm shell script sourced---"
else
    nvm_test_exit_code=1
    echo "---Nvm not installed, installing..."
    curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.29.0/install.sh | bash
    nvm_installation_exit_code=$?
    if [ nvm_installation_exit_code -eq 0 ]
    then
        echo "---Nvm successfully installed---"
        echo
        echo "---Sourcing nvm shell script..."
        . ~/.nvm/nvm.sh
        echo "---Nvm shell script sourced---"
    else
        echo "---Nvm installation failed---" >&2
    fi
fi
echo

if [ nvm_test_exit_code == 0 ] || [ nvm_installation_exit_code = 0 ]
then
    #proceed with nvm
    if [ -f .nvmrc ];
    then
        echo "---.nvmrc file found---"
        node_version=$(<.nvmrc)
        echo "---Installing correct version of node..."
        nvm install
        echo "---Version $node_version of node has been installed---"
        echo
    else
        global_node_version="$(node -v)"
        echo "---.nvmrc file not found, using global node, version: $global_node_version---"
     fi
fi

echo "---Installing node modules..."
npm install
echo
npm_installation_exit_code=$?
# echo "npm_installation_exit_code:" $npm_installation_exit_code
if [ $npm_installation_exit_code -eq 1 ]
then
     echo "---node modules successfully installed---"
else
     echo "---Node modules installation failed, trying with sudo..." >&2
     sudo npm install
    if [ $? -eq 0 ]
    then
        echo "---node modules successfully installed---"
    else
        echo "---Node modules installation failed, please try manually once this script has finished..." >&2
    fi
fi
echo

echo "---Checking for composer.json file..."
if [ -f composer.json ];
then
    echo "---composer.json file found---"
    echo
    echo "---Checking for composer..."
    hash composer 2>/dev/null || { echo >&2 "Composer is required, but it's not installed. Please install then try again. Aborting."; exit 1; }
    echo "---Installing composer dependencies..."
    composer install
    if [ $? -eq 0 ]
    then
        echo "---Composer dependencies installed---"
    else
        echo "---Composer dependencies installation failed, trying with sudo..." >&2
        sudo composer install
        if [ $? -eq 0 ]
            then
            echo "---Composer dependencies successfully installed---"
        else
            echo "---Composer dependencies installation failed, please try manually once this script has finished..." >&2
        fi
    fi
else
    echo "---composer.json file not found---"
fi
echo
echo "---All done, you're good to go!---"
