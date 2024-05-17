#!/bin/bash
# Author           : quuixlie
# Created On       : 23.04.2024 r.
# Version          : 1.0.0
#
# Description      :
# This script contains utility functions used in other scripts.
#
# Licensed under GPL (see /usr/share/common-licenses/GPL for more details
# or contact # the Free Software Foundation for a copy)


function handle_validation_error_with_message_and_callback {
    clear
    print_logo
    echo -e "\e[31m$1\e[0m"
    if [[ -n $2 ]]; then
        $2
    fi
    read -p "Press enter to continue..."
}