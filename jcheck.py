import os
import subprocess
import psutil
import re

def check_java():
    try:
        output = subprocess.check_output(['java', '-version'], stderr=subprocess.STDOUT)
        return True
    except subprocess.CalledProcessError:
        return False

def get_java_path():
    java_home = os.environ.get('JAVA_HOME')
    if java_home:
        return java_home
    else:
        return subprocess.check_output(['which', 'java']).decode().strip()

def check_java_embedded_or_set_as_environment():
    java_home = get_java_path()
    if 'embedded' in java_home.lower() or 'environment' in java_home.lower():
        return True
    else:
        return False

def check_java_running():
    for proc in psutil.process_iter(['name']):
        if 'java' in proc.info['name'].lower():
            return True
    return False

def get_java_version():
    version_output = subprocess.check_output(['java', '-version'], stderr=subprocess.STDOUT).decode()
    version_regex = r'\"(\d+\.\d+).*\"'
    version_match = re.search(version_regex, version_output)
    if version_match:
        return version_match.group(1)
    else:
        return None

if check_java():
    print("Java is installed on your system.")
    print("The path of the Java installation is:", get_java_path())
    if check_java_embedded_or_set_as_environment():
        print("Java is embedded or set as an environment.")
    else:
        print("Java is not embedded or set as an environment.")
    if check_java_running():
        print("Java is running as a process.")
    else:
        print("Java is not running as a process.")
    java_version = get_java_version()
    if java_version:
        print("The version of Java found is:", java_version)
    else:
        print("Could not determine the version of Java.")
else:
    print("Java is not installed on your system.")
