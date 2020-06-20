#!/usr/bin/env bash
# skc.sh - (S)SH (K)ey (C)reator

## Functions/Variables/Arrays

## General purpose confirmation
## Allows a set number of attempts
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

# empty_var_check "USER"
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

# Check for running ssh-agent and start if desired

empty_var_check SSH_AUTH_SOCK

if [[ $? -eq 0 ]]; then
  confirm "ssh-agent not running / \$SSH_AUTH_SOCK is empty! Would you like to start ssh-agent?"
  if [[ $? -eq 0 ]]; then
    agent_pid="$(echo $(eval $(ssh-agent)) | cut -f3 -d' ')"
  fi
fi
echo $agent_pid

# Check for added keys
# start if not running
# add created keys to agent

# Check permissions on .ssh dir and contents
# .ssh - 700 or 755?
# .pub keys - 644
# private keys - 600
# home dir - 750 (not writeable by group/others)
# ~/.ssh/known_hosts - 600
# ~/.ssh/authorized_keys - 600

# Check ~/.ssh/known_hosts?

# Check ~/.ssh/authorized_keys?

# Point at a config file?

# Check if keys in ssh config exist?

# Check if remote servers support Ed25519 keys?
# Check if remote servers support password auth?

# Audit connected servers? Edit ssh config file to best practices?

# Store passphrase/key in Vault
