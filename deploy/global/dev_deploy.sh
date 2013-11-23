# check root permissions
if [[ $UID != 0 ]]; then
    echo "Please start the script as root or sudo!"
    exit 1
fi

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR/../..

echo "Checking for required setup..."
PY_VERSION=`python -c 'import sys; print(sys.version_info[0:2])' | sed -E 's/[\(\)\, ]+//g'`
if [ $PY_VERSION -ne 27 ]; then
	echo "\tPython 2.7 required.  Please install and restart this script..."
	exit 1
fi

command -v pip >/dev/null 2>&1 || { \
	echo "\tpip required.  Please install and restart this script..."
	exit 1
}

command -v virtualenv >/dev/null 2>&1 || { \
	echo "Installing virtualenv..."
	pip install virtualenv virtualenvwrapper
	command -v virtualenv >/dev/null 2>&1 || { \
		echo "\tvirtualenv could not install. Please install and restart this script..."
		exit 1
	}
}

virtualenv venv_bit_talk
CURRENT_DIR=`pwd`
echo "Add the following to your .bashrc, .bash_profile, .login, or .profile to activate the bit_talk virtualenv environment..."
echo "alias bit_talk='source $CURRENT_DIR/venv_bit_talk/bin/activate;cd $CURRENT_DIR;'"
source venv_bit_talk/bin/activate

echo "Environment verified.  Moving on to setup."
pip install -r ./askbot_requirements_dev.txt

echo "Creating askbot project..."
python setup.py develop

# This is kind of FUBAR, but askbot-setup seems to prompt no matter how you call it.  The options in the 
# settings file specified below fill in all of the prompts from askbot-setup.  The command line 
# options which are specified here are ones that must be specified on the command line.  Basically,
# at this time, it is impossible to put the parameters to askbot setup in one place.
touch /tmp/askbot-setup.settings
echo "./btc_project" >> /tmp/askbot-setup.settings
echo "yes" >> /tmp/askbot-setup.settings
echo "2" >> /tmp/askbot-setup.settings
echo "dev_db.sql" >> /tmp/askbot-setup.settings
echo "yes" >> /tmp/askbot-setup.settings
cat /tmp/askbot-setup.settings | askbot-setup --db-user=admin --db-password=admin --domain=example.com
rm /tmp/askbot-setup.settings

cd btc_project
echo "no" | python manage.py syncdb
python manage.py migrate askbot
python manage.py migrate django_authopenid
