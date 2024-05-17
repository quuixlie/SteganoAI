# Author           : quuixlie
# Created On       : 24.04.2024 r.
# Version          : 1.0.0
#
# Description      :
# This script hides a message in an image using steganography.
# The message is hidden in the least significant bit of the image pixels.
# Additional encryption is used to secure the message. It supports Unicode.
#
# Licensed under GPL (see /usr/share/common-licenses/GPL for more details
# or contact # the Free Software Foundation for a copy)

import argparse
import os
import cv2
import numpy as np
import datetime
import hashlib
from cryptography.fernet import Fernet


encryption_key = b'rnIvkv2UkRPM03bWBTTDjrAB3hyhMEz0fB1rnOqvB_I='

def main():
    parser = argparse.ArgumentParser(description="""Hide a message in an image using steganography.
    The message is hidden in the least significant bit of the image pixels. 
    Additional encryption and manipulation is used to secure the message.""")
    parser.add_argument('--hide', action='store_true', help='hide message in image')
    parser.add_argument('--extract', action='store_true', help='extract message from image')
    parser.add_argument('--image', type=str, help='argument takes path to image with .png or .jpg extension')
    parser.add_argument('--message', type=str, help='argument takes path to text file with message to be hidden')
    parser.add_argument('--output', type=str, help='argument takes path to output with appropriate extension (depends on the selected option [--hide --- .png | --extract --- .txt])')
    args = parser.parse_args()
    check_args(args.hide, args.extract, args.image, args.message, args.output)

    if args.hide:
        hide_message(args.image, args.message, args.output)
        print("Message hidden successfully")
    elif args.extract:
        extract_message(args.image, args.output)
        print("Message extracted successfully")
    
def check_args(hide, extract, image_path, message_path, output_path):
    if hide and (not extract):
        if image_path is None:
            print("Please provide path to image using --image")
            exit(1)
        if not (os.path.exists(image_path)):
            print("Image path does not exist")
            exit(1)
        if not (image_path.endswith('.png') or image_path.endswith('.jpg')):
            print("Image must be of type .png or .jpg")
            exit(1)
        if message_path is None:
            print("Please provide path to message using --message")
            exit(1)
        if not (os.path.exists(message_path)):
            print("Message path does not exist")
            exit(1)
        if not (message_path.endswith('.txt')):
            print("Message must be of type .txt")
            exit(1)
        if output_path is None:
            print("Please provide path to output using --output")
            exit(1)
        if not (output_path.endswith('.png')):
            print("Output must be of type .png")
            exit(1)
    elif extract and (not hide):
        if image_path is None:
            print("Please provide path to image using --image")
            exit(1)
        if not (os.path.exists(image_path)):
            print("Image path does not exist")
            exit(1)
        if not (image_path.endswith('.png')):
            print("Image must be of type .png")
            exit(1)
        if output_path is None:
            print("Please provide path to output using --output")
            exit(1)
        if not (output_path.endswith('.txt')):
            print("Output must be of type .txt")
            exit(1)
    elif hide and extract:
        print("Please select only one option: --hide or --extract")
        exit(1)
    elif not hide and not extract:
        print("Please select an option: --hide or --extract")
        exit(1) 

def hide_message(image_path, message_path, output_path):
    image = open_image(image_path)
    height, width, channels = get_image_dimensions(image)
    red_channel, green_channel, blue_channel = get_rgb_channels(image)
    message = open_message(message_path)
    message = encrypt_message(message)
    binary_message = message_to_binary(message)
    binary_message = binary_message + '1' * 32
    binary_message_length = len(binary_message)

    if binary_message_length > height * width * channels:
        print("Message is too long to be hidden in the image")
        exit(1)

    red_channel, green_channel, blue_channel = hide_binary_message_in_channels(red_channel, green_channel, blue_channel, binary_message, height, width, channels)
    image = merge_channels_to_image(red_channel, green_channel, blue_channel, height, width)
    cv2.imwrite(output_path, image)

def open_image(image_path):
    image = cv2.imread(image_path)
    return image

def get_image_dimensions(image):
    height, width, channels = image.shape
    return height, width, channels    

def get_rgb_channels(image):
    red_channel = image[:,:,0]
    green_channel = image[:,:,1]
    blue_channel = image[:,:,2]
    return red_channel, green_channel, blue_channel

def open_message(message_path):
    with open(message_path, 'r') as file:
        message = file.read()
    return message

def encrypt_message(message):
    f = Fernet(encryption_key)
    encrypted_message = f.encrypt(message.encode()).decode()

    return encrypted_message

def message_to_binary(message):
    binary_message = ''.join(format(ord(char), '032b') for char in message)
    return binary_message

def hide_binary_message_in_channels(red_channel, green_channel, blue_channel, binary_message, height, width, channels):
    binary_message_length = len(binary_message)
    binary_message_index = 0

    for i in range(channels):
        for j in range(height):
            for k in range(width):
                if binary_message_index < binary_message_length:
                    if i == 0:
                        red_channel[j, k] = red_channel[j, k] & 0b11111110 | int(binary_message[binary_message_index])
                    elif i == 1:
                        green_channel[j, k] = green_channel[j, k] & 0b11111110 | int(binary_message[binary_message_index])
                    elif i == 2:
                        blue_channel[j, k] = blue_channel[j, k] & 0b11111110 | int(binary_message[binary_message_index])
                    binary_message_index += 1
                else:
                    return red_channel, green_channel, blue_channel


def merge_channels_to_image(red_channel, green_channel, blue_channel, height, width):
    image = np.zeros((height, width, 3), np.uint8)
    image[:,:,0] = red_channel
    image[:,:,1] = green_channel
    image[:,:,2] = blue_channel
    return image

def extract_message(image_path, output_path):
    image = open_image(image_path)
    height, width, channels = get_image_dimensions(image)
    red_channel, green_channel, blue_channel = get_rgb_channels(image)
    binary_message = extract_binary_message_from_channels(red_channel, green_channel, blue_channel, height, width, channels)
    message = binary_to_message(binary_message)
    message = decrypt_message(message)
    save_message_to_file(message, output_path)

def extract_binary_message_from_channels(red_channel, green_channel, blue_channel, height, width, channels):
    binary_message = ""
    for i in range(channels):
        for j in range(height):
            for k in range(width):
                if len(binary_message) % 32 == 0 and binary_message[-32:] == '1' * 32:
                    return binary_message[:-32]
                if i == 0:
                    binary_message += str(red_channel[j, k] & 1)
                elif i == 1:
                    binary_message += str(green_channel[j, k] & 1)
                elif i == 2:
                    binary_message += str(blue_channel[j, k] & 1)
    return binary_message

def decrypt_message(message):
    f = Fernet(encryption_key)
    decrypted_message = f.decrypt(message.encode()).decode()
    return decrypted_message

def save_message_to_file(message, output_path):
    with open(output_path, 'w') as file:
        file.write(message)

def binary_to_message(binary_message):
    message = ""
    for i in range(0, len(binary_message), 32):
        char = chr(int(binary_message[i:i+32], 2))
        message += char
    return message

if __name__ == "__main__":
    main()
