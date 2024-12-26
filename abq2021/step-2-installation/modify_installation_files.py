#!/usr/bin/python2
import os

installation_dir = input('Enter the directory of "DS.SIMULIA.Suite.2021.Linux64": ')

if not os.path.isdir(installation_dir):
    print('Installation directory not found.')
    exit(1)

# Replace all occurrences of "#!/bin/sh" with "#!/bin/bash" in all scripts
# named "*.sh" in the installation directory.
for root, dirs, files in os.walk(installation_dir):
    for file in files:
        if file.endswith('.sh'):
            path = os.path.join(root, file)
            with open(path, 'r') as f:
                script = f.read()
            script = script.replace('#!/bin/sh', '#!/bin/bash')
            with open(path, 'w') as f:
                f.write(script)

# Delete certain lines in all scripts named "Linux.sh" in the installation
# directory and fill the variable "DSY_OS_Release" with "CentOS" to bypass the
# OS check.
for root, dirs, files in os.walk(installation_dir):
    for file in files:
        if file == 'Linux.sh':
            path = os.path.join(root, file)
            with open(path, 'r') as f:
                script = f.read()
            script = script.replace(r'which lsb_release', '')
            script = script.replace(r'DSY_OS_Release=`lsb_release --short --id |sed \'s/ //g\'`', '')
            script = script.replace(r'echo "DSY_OS_Release=\""${DSY_OS_Release}"\""', '')
            script = script.replace(r'export DSY_OS_Release=${DSY_OS_Release}', r'export DSY_OS_Release=CentOS')
            with open(path, 'w') as f:
                f.write(script)

print('Installation files modified successfully.')
