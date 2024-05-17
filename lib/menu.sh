#!/bin/bash
# Author           : quuixlie
# Created On       : 23.04.2024 r.
# Version          : 1.0.0
#
# Description      :
# This script handle the main menu and submenus.
#
# Licensed under GPL (see /usr/share/common-licenses/GPL for more details
# or contact # the Free Software Foundation for a copy)


source ./lib/utils.sh
source ./lib/gmail.sh
source ./lib/chatgpt.sh


IS_RUNNING=true


function print_logo {
    echo -e "\e[32m
 ____  _                                 _    ___
/ ___|| |_ ___  __ _  __ _ _ __   ___   / \  |_ _|
\___ \| __/ _ \/ _  |/ _  |  _ \ / _ \ / _ \  | | 
 ___) | ||  __/ (_| | (_| | | | | (_) / ___ \ | |
|____/ \__\___|\__, |\__,_|_| |_|\___/_/   \_\___|
               |___/
    \e[0m"
}

function print_main_menu {
    clear
    print_logo
    
    echo "1. Hide information"
    echo "2. Extract information"
    echo "3. Send information"
    echo "4. Exit"
}

function print_hide_information_menu {
    clear
    print_logo

    echo "1. Generate image using chatgpt (Optional)"
    echo "2. Select image path. Current path: $IMAGE_PATH"
    echo "3. Select path to message to hide. Current path: $MESSAGE_TO_HIDE_PATH"
    echo "4. Select output directory. Current path: $IMAGE_WITH_HIDDEN_MESSAGE_PATH"
    echo "5. Hide information"
    echo "6. Send information"
    echo "7. Back"
}

function print_generate_image_using_chatgpt_menu {
    clear
    print_logo

    echo "1. Set chatgpt api key. Current key: ${CHAT_GPT_API_KEY:0:10}..."
    echo "2. Set image output directory. Current path: $IMAGE_PATH"
    echo "3. Set chatgpt prompt. Current prompt: $CHAT_GPT_PROMPT_FOR_IMAGE_GENERATION"
    echo "4. Generate image"
    echo "5. Back"
}

function set_default_chatgpt_api_key {
    CHAT_GPT_API_KEY=$(grep -oP '(?<=CHAT_GPT_API_KEY=")[^"]*' ./config.sh)
}

function set_chatgpt_api_key {
    clear
    print_logo

    read -p "Enter chatgpt api key: " CHAT_GPT_API_KEY

    if ! [[ -z $CHAT_GPT_API_KEY ]]; then
        # Overwrite the value in config.sh
        sed -i "s/CHAT_GPT_API_KEY=\".*\"/CHAT_GPT_API_KEY=\"$CHAT_GPT_API_KEY\"/" ./config.sh
    else
        handle_validation_error_with_message_and_callback "ChatGPT api key cannot be empty." set_default_chatgpt_api_key
    fi
}

function check_if_file_is_png {
    if [[ ! $1 =~ \.png$ ]]; then
        return 0
    fi
    return 1
}

function check_if_file_is_jpg {
    if [[ ! $1 =~ \.jpg$ ]]; then
        return 0
    fi
    return 1
}

function check_if_path_is_valid_for_output_image_from_chatgpt {
    check_if_file_is_png $1
    is_file_png=$?
    check_if_file_is_jpg $1
    is_file_jpg=$?

    if [[ $is_file_png == 0 && $is_file_jpg == 0 ]]; then
        return 0
    else
        return 1
    fi
}

function set_default_image_output_directory {
    IMAGE_PATH=$(grep -oP '(?<=IMAGE_PATH=")[^"]*' ./config.sh)
}

function set_image_output_directory {
    clear
    print_logo

    read -p "Enter path to image output directory: " IMAGE_PATH
    check_if_path_is_valid_for_output_image_from_chatgpt $IMAGE_PATH
    condition=$?

    if [[ $condition == 1 ]]; then
        # Overwrite the value in config.sh
        sed -i "s/IMAGE_PATH=\".*\"/IMAGE_PATH=\"$IMAGE_PATH\"/" ./config.sh
    else
        handle_validation_error_with_message_and_callback "File does not exist or it's not a .jpg or .png file." set_default_image_output_directory
    fi
}

function set_default_chat_gpt_image_prompt {
    CHAT_GPT_PROMPT_FOR_IMAGE_GENERATION=$(grep -oP '(?<=CHAT_GPT_PROMPT_FOR_IMAGE_GENERATION=")[^"]*' ./config.sh)
}

function set_chat_gpt_image_prompt {
    clear
    print_logo

    read -p "Enter chatgpt prompt: " CHAT_GPT_PROMPT_FOR_IMAGE_GENERATION

    if ! [[ -z $CHAT_GPT_PROMPT_FOR_IMAGE_GENERATION ]]; then
        # Overwrite the value in config.sh
        sed -i "s/CHAT_GPT_PROMPT_FOR_IMAGE_GENERATION=\".*\"/CHAT_GPT_PROMPT_FOR_IMAGE_GENERATION=\"$CHAT_GPT_PROMPT_FOR_IMAGE_GENERATION\"/" ./config.sh
    else
        handle_validation_error_with_message_and_callback "ChatGPT prompt cannot be empty." set_default_chat_gpt_image_prompt
    fi  
}

function generate_image {
    clear
    print_logo

    if ! [[ -z $CHAT_GPT_API_KEY || -z $IMAGE_PATH || -z $CHAT_GPT_PROMPT_FOR_IMAGE_GENERATION ]]; then
        generate_image_using_chatgpt
        read -p "Press enter to continue..."
    else
        handle_validation_error_with_message_and_callback "Incomplete data. Please fill in all required fields."
    fi
}

function print_invaild_menu_option {
    clear
    print_logo

    echo -e "\e[31mInvalid menu option\e[0m"
    read -p "Press enter to continue..."
}

function handle_generate_image_using_chatgpt_menu_input {
    case $1 in
        1)
            set_chatgpt_api_key
            return 0
            ;;
        2)
            set_image_output_directory
            return 0
            ;;
        3)
            set_chat_gpt_image_prompt
            return 0
            ;;
        4)
            generate_image
            return 0
            ;;
        5)
            return 1
            ;;
        *)
            print_invaild_menu_option
            return 0
            ;;
    esac
}

function check_if_file_exists {
    if [[ ! -f $1 ]]; then
        return 0
    fi
    return 1
}

function check_if_path_is_valid_image_for_input {
    check_if_file_exists $1
    is_file_exists=$?

    # Output image from chatgpt must be .png or .jpg
    check_if_path_is_valid_for_output_image_from_chatgpt $1
    condition=$?

    
    if ! [[ $condition == 0 || $is_file_exists == 0 ]]; then
        return 1
    else
        return 0
    fi
}

function set_default_image_path {
    IMAGE_PATH=$(grep -oP '(?<=IMAGE_PATH=")[^"]*' ./config.sh)
}

function select_image_path {
    clear
    print_logo

    read -p "Enter path to image: " IMAGE_PATH
    check_if_path_is_valid_image_for_input $IMAGE_PATH
    condition=$?

    if [[ $condition == 1 ]]; then
        # Overwrite the value in config.sh
        sed -i "s/IMAGE_PATH=\".*\"/IMAGE_PATH=\"$IMAGE_PATH\"/" ./config.sh
    else
        handle_validation_error_with_message_and_callback "File does not exist or it's not a .jpg or .png file." set_default_image_path
    fi
}

function check_if_file_is_txt {
    if [[ ! $1 =~ \.txt$ ]]; then
        return 0
    fi
    return 1
}

function check_if_path_is_correct_txt_for_input {
    check_if_file_exists $1
    is_file_exists=$?
    check_if_file_is_txt $1
    is_file_txt=$?

    if ! [[ $is_file_exists == 0 || $is_file_txt == 0 ]]; then
        return 1
    else
        return 0
    fi
}

function set_default_message_to_hide_path {
    MESSAGE_TO_HIDE_PATH=$(grep -oP '(?<=MESSAGE_TO_HIDE_PATH=")[^"]*' ./config.sh)
}

function select_path_to_message_to_hide {
    clear
    print_logo

    read -p "Enter path to message to hide: " MESSAGE_TO_HIDE_PATH
    check_if_path_is_correct_txt_for_input $MESSAGE_TO_HIDE_PATH
    condition=$?

    if [[ $condition == 1 ]]; then
        # Overwrite the value in config.sh
        sed -i "s/MESSAGE_TO_HIDE_PATH=\".*\"/MESSAGE_TO_HIDE_PATH=\"$MESSAGE_TO_HIDE_PATH\"/" ./config.sh
    else
        handle_validation_error_with_message_and_callback "File does not exist or it's not a .txt file." set_default_message_to_hide_path
    fi
}

function check_if_path_is_valid_for_output_image {
    check_if_file_is_png $1
    is_file_png=$?

    if [[ $is_file_png == 1 ]]; then
        return 1
    else
        return 0
    fi
}

function set_default_output_directory {
    IMAGE_WITH_HIDDEN_MESSAGE_PATH=$(grep -oP '(?<=IMAGE_WITH_HIDDEN_MESSAGE_PATH=")[^"]*' ./config.sh)
}

function select_output_directory {
    clear
    print_logo

    read -p "Enter path to output directory: " IMAGE_WITH_HIDDEN_MESSAGE_PATH
    check_if_path_is_valid_for_output_image $IMAGE_WITH_HIDDEN_MESSAGE_PATH
    condition=$?

    if [[ $condition == 1 ]]; then
        # Overwrite the value in config.sh
        sed -i "s/IMAGE_WITH_HIDDEN_MESSAGE_PATH=\".*\"/IMAGE_WITH_HIDDEN_MESSAGE_PATH=\"$IMAGE_WITH_HIDDEN_MESSAGE_PATH\"/" ./config.sh
    else
        handle_validation_error_with_message_and_callback "File it's not a .png file." set_default_output_directory
    fi
}

function hide_message {
    python3 tools/image_steganography.py --hide --image $IMAGE_PATH --message $MESSAGE_TO_HIDE_PATH --output $IMAGE_WITH_HIDDEN_MESSAGE_PATH
}

function hide_information {
    clear
    print_logo

    if ! [[ -z $IMAGE_PATH || -z $MESSAGE_TO_HIDE_PATH || -z $IMAGE_WITH_HIDDEN_MESSAGE_PATH ]]; then
        hide_message
        read -p "Press enter to continue..."
    else
        handle_validation_error_with_message_and_callback "Incomplete data. Please fill in all required fields."
    fi
}

function print_send_information_menu {
    clear
    print_logo

    echo "1. Generate message using chatgpt (Optional)."
    echo "2. Set your email. Current email: $YOUR_GMAIL"
    echo "3. Set app password. Current password: ${GMAIL_APP_PASSWORD:0:10}..."
    echo "4. Set recipient email. Current email: $RECIPIENT_GMAIL"
    echo "5. Set path to email to send. Current path: $EMAIL_TO_SEND_PATH"
    echo "6. Set path to attachment. Current path: $ATTACHMENT_PATH"
    echo "7. Send email"
    echo "8. Back"
}

function print_generate_message_using_chatgpt_menu {
    clear
    print_logo

    echo "1. Set chatgpt api key. Current key: ${CHAT_GPT_API_KEY:0:10}..."
    echo "2. Set message output directory. Current path: $EMAIL_TO_SEND_PATH"
    echo "3. Set chatgpt prompt. Current prompt: $CHAT_GPT_PROMPT_FOR_TEXT_GENERATION"
    echo "4. Generate message"
    echo "5. Back"
}

function set_default_message_output_directory {
    EMAIL_TO_SEND_PATH=$(grep -oP '(?<=EMAIL_TO_SEND_PATH=")[^"]*' ./config.sh)
}

function set_message_output_directory {
    clear
    print_logo

    read -p "Enter path to message output directory: " EMAIL_TO_SEND_PATH
    check_if_file_is_txt $EMAIL_TO_SEND_PATH
    is_file_txt=$?

    if [[ $is_file_txt == 1 ]]; then
        # Overwrite the value in config.sh
        sed -i "s/EMAIL_TO_SEND_PATH=\".*\"/EMAIL_TO_SEND_PATH=\"$EMAIL_TO_SEND_PATH\"/" ./config.sh
    else
        handle_validation_error_with_message_and_callback "File is not a .txt file." set_default_message_output_directory
    fi
}

function set_default_chatgpt_prompt {
    CHAT_GPT_PROMPT_FOR_TEXT_GENERATION=$(grep -oP '(?<=CHAT_GPT_PROMPT_FOR_TEXT_GENERATION=")[^"]*' ./config.sh)
}

function set_chatgpt_prompt {
    clear
    print_logo

    read -p "Enter chatgpt prompt: " CHAT_GPT_PROMPT_FOR_TEXT_GENERATION

    if ! [[ -z $CHAT_GPT_PROMPT_FOR_TEXT_GENERATION ]]; then
        # Overwrite the value in config.sh
        sed -i "s/CHAT_GPT_PROMPT_FOR_TEXT_GENERATION=\".*\"/CHAT_GPT_PROMPT_FOR_TEXT_GENERATION=\"$CHAT_GPT_PROMPT_FOR_TEXT_GENERATION\"/" ./config.sh
    else
        handle_validation_error_with_message_and_callback "ChatGPT prompt cannot be empty." set_default_chatgpt_prompt
    fi
}

function generate_message {
    clear
    print_logo

    if ! [[ -z $CHAT_GPT_API_KEY || -z $EMAIL_TO_SEND_PATH || -z $CHAT_GPT_PROMPT_FOR_TEXT_GENERATION ]]; then
        generate_message_using_chatgpt
        read -p "Press enter to continue..."
    else
        handle_validation_error_with_message_and_callback "Incomplete data. Please fill in all required fields."
    fi
}

function handle_generate_message_using_chatgpt_menu_input {
    case $1 in
        1)
            set_chatgpt_api_key
            return 0
            ;;
        2)
            set_message_output_directory
            return 0
            ;;
        3)
            set_chatgpt_prompt
            return 0
            ;;
        4)
            generate_message
            return 0
            ;;
        5)
            return 1
            ;;
        *)
            print_invaild_menu_option
            return 0
            ;;
    esac
}

function set_default_your_email {
    YOUR_GMAIL=$(grep -oP '(?<=YOUR_GMAIL=")[^"]*' ./config.sh)
}

function set_your_email {
    clear
    print_logo

    read -p "Enter your email: " YOUR_GMAIL
    check_if_email_is_valid $YOUR_GMAIL
    is_email_valid=$?

    if [[ $is_email_valid == 1 ]]; then
        # Overwrite the value in config.sh
        sed -i "s/YOUR_GMAIL=\".*\"/YOUR_GMAIL=\"$YOUR_GMAIL\"/" ./config.sh
    else
        handle_validation_error_with_message_and_callback "Invalid email address. Only Gmail accounts are allowed." set_default_your_email
    fi
}

function set_default_app_password {
    GMAIL_APP_PASSWORD=$(grep -oP '(?<=GMAIL_APP_PASSWORD=")[^"]*' ./config.sh)
}

function set_app_password {
    clear
    print_logo

    read -p "Enter your app password: " GMAIL_APP_PASSWORD
    check_if_app_password_is_valid $GMAIL_APP_PASSWORD
    is_app_password_valid=$?

    if [[ $is_app_password_valid == 1 ]]; then
        # Overwrite the value in config.sh
        sed -i "s/GMAIL_APP_PASSWORD=\".*\"/GMAIL_APP_PASSWORD=\"$GMAIL_APP_PASSWORD\"/" ./config.sh
    else
        handle_validation_error_with_message_and_callback "Invalid app password." set_default_app_password
    fi
}

function set_default_recipient_email {
    RECIPIENT_GMAIL=$(grep -oP '(?<=RECIPIENT_GMAIL=")[^"]*' ./config.sh)
}

function set_recipient_email {
    clear
    print_logo

    read -p "Enter recipient email: " RECIPIENT_GMAIL
    check_if_email_is_valid $RECIPIENT_GMAIL
    is_email_valid=$?

    if [[ $is_email_valid == 1 ]]; then
        # Overwrite the value in config.sh
        sed -i "s/RECIPIENT_GMAIL=\".*\"/RECIPIENT_GMAIL=\"$RECIPIENT_GMAIL\"/" ./config.sh
    else
        handle_validation_error_with_message_and_callback "Invalid email address. Only Gmail accounts are allowed." set_default_recipient_email
    fi
}

function set_default_path_to_email_to_send {
    EMAIL_TO_SEND_PATH=$(grep -oP '(?<=EMAIL_TO_SEND_PATH=")[^"]*' ./config.sh)
}

function set_path_to_email_to_send {
    clear
    print_logo

    read -p "Enter path to email to send: " EMAIL_TO_SEND_PATH
    check_if_path_is_correct_txt_for_input $EMAIL_TO_SEND_PATH
    condition=$?

    if [[ $condition == 1 ]]; then
        # Overwrite the value in config.sh
        sed -i "s/EMAIL_TO_SEND_PATH=\".*\"/EMAIL_TO_SEND_PATH=\"$EMAIL_TO_SEND_PATH\"/" ./config.sh
    else
        handle_validation_error_with_message_and_callback "File does not exist or it's not a .txt file." set_default_path_to_email_to_send
    fi
}

function set_default_path_to_attachment {
    ATTACHMENT_PATH=$(grep -oP '(?<=ATTACHMENT_PATH=")[^"]*' ./config.sh)
}

function set_path_to_attachment {
    clear
    print_logo

    read -p "Enter path to attachment: " ATTACHMENT_PATH
    check_if_path_is_valid_for_output_image $ATTACHMENT_PATH
    condition=$?
    check_if_file_exists $ATTACHMENT_PATH
    file_exists=$?

    # Allow user to send mail without attachment
    if [[ -z $ATTACHMENT_PATH ]]; then
        # Overwrite the value in config.sh
        ATTACHMENT_PATH=""
        sed -i "s/ATTACHMENT_PATH=\".*\"/ATTACHMENT_PATH=\"$ATTACHMENT_PATH\"/" ./config.sh
        echo -e "\e[31mAttachment path set to empty.\e[0m"
        read -p "Press enter to continue..."
    elif [[ $condition == 1 && $file_exists == 1 ]]; then
        # Overwrite the value in config.sh
        sed -i "s/ATTACHMENT_PATH=\".*\"/ATTACHMENT_PATH=\"$ATTACHMENT_PATH\"/" ./config.sh
    else
        handle_validation_error_with_message_and_callback "File dosen't exists or it's not a .png file." set_default_path_to_attachment
    fi
}

function handle_send_information_menu_input {
    case $1 in
        1)
            while [[ $? == 0 ]]; do
                print_generate_message_using_chatgpt_menu
                read -p "Enter your choice: " choice
                handle_generate_message_using_chatgpt_menu_input $choice
            done
            return 0
            ;;
        2)
            set_your_email
            return 0
            ;;
        3)
            set_app_password
            return 0
            ;;
        4)
            set_recipient_email
            return 0
            ;;
        5)
            set_path_to_email_to_send
            return 0
            ;;
        6)
            set_path_to_attachment
            return 0
            ;;
        7)
            send_email
            return 0
            ;;
        8)
            return 1
            ;;
        *)
            print_invaild_menu_option
            return 0
            ;;
    esac
}

function handle_hide_information_menu_input {
    case $1 in
        1)
            while [[ $? == 0 ]]; do
                print_generate_image_using_chatgpt_menu
                read -p "Enter your choice: " choice
                handle_generate_image_using_chatgpt_menu_input $choice
            done
            return 0
            ;;
        2)
            select_image_path
            return 0
            ;;
        3)
            select_path_to_message_to_hide
            return 0
            ;;
        4)
            select_output_directory
            return 0
            ;;
        5)
            hide_information
            return 0
            ;;
        6)
            while [[ $? == 0 ]]; do
                print_send_information_menu
                read -p "Enter your choice: " choice
                handle_send_information_menu_input $choice
            done
            return 0
            ;;
        7)
            return 1
            ;;
        *)
            print_invaild_menu_option
            return 0
            ;;
    esac
}

function print_extract_information_menu {
    clear
    print_logo

    echo "1. Download unreaded emails"
    echo "2. Extract data from downloaded images"
    echo "3. Select image to extract. Current path: $IMAGE_TO_EXTRACT_PATH"
    echo "4. Select output directory. Current path: $EXTRACTED_DATA_PATH"
    echo "5. Extract information"
    echo "6. Back"
}

function extract_data {
    python3 tools/image_steganography.py --extract --image $IMAGE_TO_EXTRACT_PATH --output $EXTRACTED_DATA_PATH
}

function extract_data_from_downloaded_images {
    clear
    print_logo

    # Check if there are any images to extract
    if [[ ! -d download || ! $(find download -maxdepth 1 -type f -name "*.png") ]]; then
        handle_validation_error_with_message_and_callback "No images to extract."
    else
        # Extract data from all images
        for image in download/*.png; do
            IMAGE_TO_EXTRACT_PATH=$image
            EXTRACTED_DATA_PATH=${image%.*}.txt
            extract_data
        done
        read -p "Press enter to continue..."
    fi
}

function set_default_image_to_extract {
    IMAGE_TO_EXTRACT_PATH=$(grep -oP '(?<=IMAGE_TO_EXTRACT_PATH=")[^"]*' ./config.sh)
}

function select_image_to_extract {
    clear
    print_logo

    read -p "Enter path to image: " IMAGE_TO_EXTRACT_PATH
    check_if_path_is_valid_for_output_image $IMAGE_TO_EXTRACT_PATH
    condition=$?
    check_if_file_exists $IMAGE_TO_EXTRACT_PATH
    file_exists=$?

    # Output image is now input image
    if [[ $condition == 1 && $file_exists == 1 ]]; then
        # Overwrite the value in config.sh
        sed -i "s/IMAGE_TO_EXTRACT_PATH=\".*\"/IMAGE_TO_EXTRACT_PATH=\"$IMAGE_TO_EXTRACT_PATH\"/" ./config.sh
    else
        handle_validation_error_with_message_and_callback "File dosen't exists or it's not a .png file." set_default_image_to_extract
    fi
}

function set_default_extracted_data_path {
    EXTRACTED_DATA_PATH=$(grep -oP '(?<=EXTRACTED_DATA_PATH=")[^"]*' ./config.sh)
}

function select_extracted_data_path {
    clear
    print_logo

    read -p "Enter path to extracted data: " EXTRACTED_DATA_PATH
    check_if_file_is_txt $EXTRACTED_DATA_PATH
    is_file_txt=$?

    if [[ $is_file_txt == 1 ]]; then
        # Overwrite the value in config.sh
        sed -i "s/EXTRACTED_DATA_PATH=\".*\"/EXTRACTED_DATA_PATH=\"$EXTRACTED_DATA_PATH\"/" ./config.sh
    else
        handle_validation_error_with_message_and_callback "File is not a .txt file." set_default_extracted_data_path
    fi
}

function extract_data_from_image {
    clear
    print_logo

    if ! [[ -z $IMAGE_TO_EXTRACT_PATH || -z $EXTRACTED_DATA_PATH ]]; then
        extract_data
        read -p "Press enter to continue..."
    else
        handle_validation_error_with_message_and_callback "Incomplete data. Please fill in all required fields."
    fi
}

function handle_extract_information_menu_input {
    case $1 in
        1)
            download_unreaded_emails_images
            return 0
            ;;
        2)
            extract_data_from_downloaded_images
            return 0
            ;;
        3)
            select_image_to_extract
            return 0
            ;;
        4)
            select_extracted_data_path
            return 0
            ;;
        5)
            extract_data_from_image
            return 0
            ;;
        6)
            return 1
            ;;
        *)
            print_invaild_menu_option
            return 0
            ;;
    esac
}

function handle_main_menu_input {
    case $1 in
        1)
            while [[ $? == 0 ]]; do
                print_hide_information_menu
                read -p "Enter your choice: " choice
                handle_hide_information_menu_input $choice
            done
            return 0
            ;;
        2)
            while [[ $? == 0 ]]; do
                print_extract_information_menu
                read -p "Enter your choice: " choice
                handle_extract_information_menu_input $choice
            done
            return 0
            ;;
        3)
            while [[ $? == 0 ]]; do
                print_send_information_menu
                read -p "Enter your choice: " choice
                handle_send_information_menu_input $choice
            done
            return 0
            ;;
        4)
            clear
            IS_RUNNING=false
            return 1
            ;;
        *)
            print_invaild_menu_option
            return 0
            ;;
    esac
}