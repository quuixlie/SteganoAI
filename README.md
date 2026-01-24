## SteganoAI – Project Description

**SteganoAI** is a Bash-based tool designed to enable secure hiding, sending, and extracting of secret messages using image steganography techniques. The project combines classical steganography with modern artificial intelligence capabilities by integrating ChatGPT, which assists in generating images and message content, as well as automating the overall communication workflow.

<img width="1919" height="1079" alt="image" src="https://github.com/user-attachments/assets/e64b067b-b640-485c-a559-24bf29cd6bce" />

The application operates through an interactive, menu-driven interface and provides four main functionalities: hiding information, extracting information, sending information via email, and exiting the program.

### Key Features

* **Hiding Information in Images**

  * Selecting an existing image or generating a new one using ChatGPT based on a user-defined prompt
  * Embedding text messages into image files (`.png`, `.jpg`)
  * Configurable input and output paths
  * Option to directly send the image with hidden data via email

* **Extracting Hidden Information**

  * Extracting hidden messages from `.png` images
  * Automatically downloading unread emails containing image attachments
  * Batch extraction of data from all images in a designated download directory
  * Saving extracted messages to text files

* **Sending Information**

  * Generating email messages using ChatGPT
  * Configuring email credentials (Gmail support)
  * Attaching images containing hidden information
  * Sending emails after explicit user confirmation

* **ChatGPT Integration**

  * AI-based image generation from text prompts
  * Automated generation of email message content
  * User-provided ChatGPT API key support

### Architecture and Technologies

* Main application written in **Bash**
* Supporting tools implemented in **Python** (located in the `tools/` directory)
* Application configuration stored in `config.sh`
* Email communication via SMTP (Gmail)
* Distributed under the **GNU General Public License (GPL)**

### Use Cases

SteganoAI can be used for:

* Secure transmission of confidential information
* Demonstrating and learning image steganography techniques
* Educational and research projects in cybersecurity
* Exploring AI integration within Linux-based automation tools

### Author and License

The project was created by **quuixly** and is released under the **GNU GPL** license, allowing modification and redistribution under the terms of free and open-source software.

<img width="1919" height="1079" alt="image" src="https://github.com/user-attachments/assets/49014fa9-ec72-490a-ab61-380b6ad6a098" />
<img width="1919" height="1079" alt="image" src="https://github.com/user-attachments/assets/67782452-7f4e-45ab-a689-38af5d861d01" />
<img width="1919" height="1079" alt="image" src="https://github.com/user-attachments/assets/823713d4-be8a-4f2d-b905-190630e877dc" />
