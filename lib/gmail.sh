#!/bin/bash
# Author           : quuixlie
# Created On       : 23.04.2024 r.
# Version          : 1.0.0
#
# Description      :
# This script contains functions for sending emails using Gmail.
# It uses the Gmail API to send emails with attachments.
# If you want to change Gmail to another email provider, you need to change the script and tools/gmail_scrap.py.
#
# Licensed under GPL (see /usr/share/common-licenses/GPL for more details
# or contact # the Free Software Foundation for a copy)


function check_if_email_is_valid {
    if [[ ! $1 =~ ^[a-zA-Z0-9._%+-]+@gmail\.com$ ]]; then
        return 0
    fi
    return 1
}

function check_if_app_password_is_valid {
    if [[ ! $1 =~  ^([a-zA-Z0-9]{4}\ ){3}[a-zA-Z0-9]{4}$ ]]; then
        return 0
    fi
    return 1
}

function extract_subject_and_body_from_email {
    # Subject is the first line after the Subject: to the first empty line
    EMAIL_SUBJECT=$(sed -n 's/Subject: \(.*\)/\1/p' $EMAIL_TO_SEND_PATH)

    # Body is everything from first empty line to the end
    EMAIL_BODY=$(sed -n '/^$/,$p' $EMAIL_TO_SEND_PATH | sed '1d')
}

function send_email_using_curl {
    echo "Sending email..."

    # Create a MIME message with the attachment
    {
        echo "To: $RECIPIENT_GMAIL"
        echo "From: $YOUR_GMAIL"
        echo "Subject: $EMAIL_SUBJECT"
        echo "MIME-Version: 1.0"
        echo 'Content-Type: multipart/mixed; boundary="GvXjxJ+pjyke8COw"'
        echo "--GvXjxJ+pjyke8COw"
        echo "Content-Type: text/plain"
        echo
        echo "$EMAIL_BODY"
        if [[ -n $ATTACHMENT_PATH ]]; then
            echo "--GvXjxJ+pjyke8COw"
            echo "Content-Type: application/octet-stream; name=\"$ATTACHMENT_PATH\""
            echo "Content-Disposition: attachment; filename=\"$ATTACHMENT_PATH\""
            echo "Content-Transfer-Encoding: base64"
            echo
            base64 $ATTACHMENT_PATH
        fi
        echo "--GvXjxJ+pjyke8COw--"
    } > /tmp/message.mime

    # Send the email using curl with the MIME message as the input
    curl --url 'smtps://smtp.gmail.com:465' --ssl-reqd \
        --mail-from "$YOUR_GMAIL" --mail-rcpt "$RECIPIENT_GMAIL" \
        --user "$YOUR_GMAIL:$GMAIL_APP_PASSWORD" \
        --upload-file /tmp/message.mime

    # Remove the MIME message file
    rm /tmp/message.mime
}

function ask_user_to_confirm_data {
    clear
    print_logo

    echo "Email to: $RECIPIENT_GMAIL"
    echo "Subject: $EMAIL_SUBJECT"
    echo "Body:"
    echo "$EMAIL_BODY"
    if [[ -n $ATTACHMENT_PATH ]]; then
        echo "Attachment: $ATTACHMENT_PATH"
    fi
    read -p "Is this information correct? Enter y/n: " choice

    if [[ $choice == "y" ]]; then
        clear
        print_logo

        send_email_using_curl
        read -p "Press enter to continue..."
    fi
}

function send_email {
    clear
    print_logo

    if ! [[ -z $RECIPIENT_GMAIL || -z $EMAIL_TO_SEND_PATH ]]; then
        extract_subject_and_body_from_email
        ask_user_to_confirm_data
    else
        handle_validation_error_with_message_and_callback "Recipient email or email to send path is not set."
    fi
}

function download_unreaded_emails_images {
    clear
    print_logo

    if [[ ! -d download ]]; then
        mkdir download
    fi

    # Download all unreaded emails
    python3 tools/gmail_scrap.py --email $YOUR_GMAIL --app_password "$GMAIL_APP_PASSWORD" --num_elements $NUMBER_OF_UNREAD_EMAILS_TO_FETCH --output download

    read -p "Press enter to continue..."
}