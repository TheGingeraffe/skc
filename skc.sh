#!/usr/bin/env bash
# skc.sh - (S)SH (K)ey (C)reator

## Functions/Variables/Arrays

# General purpose confirmation
# Allows a set number of attempts
confirm() {

	conf_msg="${1}"
	invld_msg="${2}"

	attempts="3"
	counter="0"

	while [[ ${counter} -lt ${attempts} ]]; do
		read -r -n 1 -p "${conf_msg:-Continue?} [y/n]: " REPLY
		case ${REPLY} in
		[yY])
			echo
			return 0
			;;
		[nN])
			echo
			return 1
			;;
		*)
			printf " \033[31m %s \n\033[0m" "${invld_msg:-invalid input}"
			;;
		esac
		counter="$((counter + 1))"
	done

}

# Checks an arbitrary list of strings to see if they are set/unset
# returns 1 if set, 0 if unset
# usage: empty_var_check "USER"
empty_var_check() {
	for var in "${@}"; do
		if [[ -v "${var}" ]]; then
			echo "${var} is set!"
			return 1
		else
			echo "${var} is not set!"
		fi
	done
}

# Checks a file or dir permissions
# Usage: perm_check <file or dir> <octal permissions>
perm_check() {
	# Checks for existence before storing current permissions and returns 1 if check fails
	if [[ -e ${1} ]]; then
		permission_var="$(stat -c "%a" "${1}")"
	else
		echo "${1} does not exist or is not readable!"
		return 1
	fi

	if [[ "${permission_var}" = "${2}" ]]; then
		echo "Permissions for ${1} are correctly set to ${permission_var}!"
	else
		confirm "Permissions for ${1} are ${permission_var} when they should be ${2}! Would you like to modify permissions?"
		if [[ $? -eq 0 ]]; then
			chmod ${2} ${1}
		fi
	fi
}

## ssh-keygen wrapper
## creates an ed25519 keypair with some args then attempts to copy it over
# ssh_key_manage <remote_user> <host/IP> <optional keyname>

ssh_key_manage() {
	if [[ -e /home/${USER}/.ssh/${3:-$1@$2}.key ]]; then
		echo "/home/${USER}/.ssh/${3:-$1@$2}.key already exists!"
		return 1
	fi
	ssh-keygen -t ed25519 -q -N "" -f "/home/${USER}/.ssh/${3:-$1@$2}.key"
	ssh-copy-id -i "/home/${USER}/.ssh/${3:-$1@$2}.key.pub" "${1}@${2}"
}

# if [[ $# = 0]]; then
# set some arguments
# fi

# home dir - 750 (not writeable by group/others)

perm_check "/home/${USER}" "750"

# Check permissions on .ssh dir and contents
# .ssh - 700

perm_check "/home/${USER}/.ssh" "700"

# .pub keys - 644
# Readable by all

for pub_key in $(find /home/${USER}/.ssh -type f -iname '*.key.pub'); do
	perm_check "${pub_key}" "644"
done

# private keys - 600
# Readable/writable only to user

for priv_key in $(find /home/${USER}/.ssh -type f -iname '*.key'); do
	perm_check "${priv_key}" "600"
done

# ~/.ssh/known_hosts - 600
# Readable/writable only to user

perm_check "/home/${USER}/.ssh/known_hosts" "600"

# ~/.ssh/authorized_keys - 600
# Readable/writable only to user

perm_check "/home/${USER}/.ssh/authorized_keys" "600"

# ~/.ssh/config - 600
# Readable/writable only to user

perm_check "/home/${USER}/.ssh/config" "600"

# TODO Check if keys in ssh config exist?
# TODO Check ~/.ssh/authorized_keys?
# Check for rsa/other weak stuff and replace with ed25519
# TODO Check if remote servers support Ed25519 keys?

# ssh_key_manage <user> <host/IP> <optional keyname>

# ssh_key_manage "$@"

# Check for running ssh-agent
empty_var_check SSH_AUTH_SOCK

# Asks to start ssh-agent if $SSH_AUTH_SOCK unset

if [[ $? -eq 0 ]]; then
	confirm "ssh-agent not running / \$SSH_AUTH_SOCK is empty! Would you like to start ssh-agent?"
fi

# Starts ssh-agent and stores PID

if [[ $? -eq 0 ]]; then
	agent_pid="$(echo $(eval $(ssh-agent)) | cut -f3 -d' ')"
fi

# ssh-add -l
# Check for keys in /home/${USER}/.ssh that are not added to agent and ask to add

## TODO split into main.sh/common.sh/etc.