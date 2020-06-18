#!/usr/bin/env bash
# skc.sh - (S)SH (K)ey (C)reator

## Functions/Variables/Arrays

testy="abc123"

empty_var_check () {
# -z "${var+x}" also catches var='', other solutions don't
    for var in "$@"; do
        echo $var
        if [[ -z "${var+x}" ]]; then
            echo "\${${var}} is unset!"
        else
            echo "\${${var}} is set to ${var}"
        fi
    done 
}

# Check for ssh-agent

empty_var_check "$@"

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
