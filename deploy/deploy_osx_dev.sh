# check root permissions
if [[ $UID != 0 ]]; then
    echo "Please start the script as root or sudo!"
    exit 1
fi

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR
cd ..

echo "This will script will do everything you need to get askbot going but may impact your dev environment."
echo "If you aren't confident that you can handle any issues which arise from running this script THEN DO NOT RUN IT!"
echo "This script will try not to hose your environment but it is only a script and cannot promise that it won't."

xcode-select -p >/dev/null 2>&1 || { \
	echo "Installing xcode..."
	xcode-select --install
	xcode-select -p >/dev/null 2>&1 || { \
		echo "XCode Command Line tools did not install successfully."
		echo "Please install it yourself and run this script again"
		exit 1
	}
}

command -v brew >/dev/null 2>&1 || { \
	echo "Installing homebrew..."
	ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go)"
	echo "Please ensure that \"/usr/local/bin\" is on your PATH."

	command -v brew >/dev/null 2>&1 || { \
		echo "Homebrew did not install successfully."
		echo "Please install it yourself and run this script again"
		exit 1
	}
}

PY_VERSION=`python -c 'import sys; print(sys.version_info[0:2])' | sed -E 's/[\(\)\, ]+//g'`
if [ $PY_VERSION -eq 27 ]; then
	echo "Python 2.7 required.	Installing Python 2.7.5 using pyenv..."
	brew install pyenv
	command -v pyenv >/dev/null 2>&1 || { \
		echo "pyenv did not install successfully"
		echo "Please install it yourself and run this script again"
		exit 1
	}
	pyenv install 2.7.5
	pyenv local 2.7.5

	PY_VERSION=`python -c 'import sys; print(sys.version_info[0:2])' | sed -E 's/[\(\)\, ]+//g'`
	if [ $PY_VERSION -ne 27 ]; then
		echo "Python 2.7 did not install successfully."
		echo "Please install it yourself and run this script again"
		python -c 'import sys; print(sys.version_info[0:2])'
		exit 1
	fi
fi

command -v easy_install >/dev/null 2>&1 || { \
	echo "Installing easy_install..."
	wget https://bitbucket.org/pypa/setuptools/raw/bootstrap/ez_setup.py -O - | python
	
	command -v easy_install >/dev/null 2>&1 || { \
		echo "easy_install did not install successfully."
		echo "Please install it yourself and run this script again"
		exit 1
	}
}

command -v pip >/dev/null 2>&1 || { \
	echo "Installing pip..."
	easy_install pip

	command -v pip >/dev/null 2>&1 || { \
		echo "pip did not install successfully."
		echo "Please install it yourself and run this script again"
		exit 1
	}
}

echo "OSX specific environment setup complete.  Moving on to deploy..."
bash $DIR/global/dev_deploy.sh
