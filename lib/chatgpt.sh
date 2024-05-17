#!/bin/bash
# Author           : quuixlie
# Created On       : 23.04.2024 r.
# Version          : 1.0.0
#
# Description      :
# This script contains functions for generating images and messages using ChatGPT.
# It uses the OpenAI API to generate images and messages based on the provided prompts.
#
# Licensed under GPL (see /usr/share/common-licenses/GPL for more details
# or contact # the Free Software Foundation for a copy)



function make_chatgpt_request_for_message {
    curl https://api.openai.com/v1/chat/completions \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $CHAT_GPT_API_KEY" \
        -d '{
        "model": "gpt-3.5-turbo",
        "messages": [
            {
            "role": "system",
            "content": "Your task will be to generate emails with the content requested by the user. Don'\''t reply too artificially. Refer to the photo that will be attached to the email. If a user asks you not to do it, then don'\''t do it. Output should contain in first line Subject: then the subject of the email. Second line should be empty. Then the content of the email."
            },
            {
            "role": "user",
            "content": "'"$CHAT_GPT_PROMPT_FOR_TEXT_GENERATION"'"
            }
        ],
        "temperature": 0.71,
        "max_tokens": 4096,
        "top_p": 1,
        "frequency_penalty": 0,
        "presence_penalty": 0
        }' -o /tmp/response.json
}

function extract_message_from_response {
    MESSAGE=$(jq -r '.choices[0].message.content' /tmp/response.json)
    echo "$MESSAGE" > $EMAIL_TO_SEND_PATH

    rm /tmp/response.json
}

function generate_message_using_chatgpt {
    echo "Generating message using ChatGPT..."
    make_chatgpt_request_for_message
    extract_message_from_response
}

function make_chatgpt_request_for_image {
    curl https://api.openai.com/v1/images/generations \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $CHAT_GPT_API_KEY" \
        -d '{
            "model": "dall-e-3",
            "prompt": "'"$CHAT_GPT_PROMPT_FOR_IMAGE_GENERATION"'",
            "n": 1,
            "size": "'"$CHAT_GPT_IMAGE_SIZE"'"
        }' -o /tmp/response.json
}

function extract_image_from_response {
    IMAGE_URL=$(jq -r '.data[0].url' /tmp/response.json)
    curl $IMAGE_URL -o $IMAGE_PATH

    rm /tmp/response.json
}

function generate_image_using_chatgpt {
    echo "Generating image using ChatGPT..."
    make_chatgpt_request_for_image
    echo "\n"
    echo "Extracting image from response..."
    extract_image_from_response
}