# Author           : quuixlie
# Created On       : 24.04.2024 r.
# Version          : 1.0.0
#
# Description      :
# This script downloads attachments from the latest and unreaded emails in your Gmail inbox.
#
# Licensed under GPL (see /usr/share/common-licenses/GPL for more details
# or contact # the Free Software Foundation for a copy)

import argparse
import imaplib
import email
import os


def main():
    parser = argparse.ArgumentParser(description="""Download attachments from the latest emails in your Gmail inbox.""")
    parser.add_argument("--email", type=str, help="Gmail email address")
    parser.add_argument("--app_password", type=str, help="Gmail app password")
    parser.add_argument("--num_elements", type=int, help="Number of emails to download attachments from")
    parser.add_argument("--output", type=str, help="Output folder to save attachments")
    args = parser.parse_args()
    check_args(args.email, args.app_password, args.num_elements, args.output)

    download_attachments(args.email, args.app_password, args.num_elements, args.output)

def check_args(email, app_password, num_elements, output):
    if email is None:
        print("Please provide Gmail email address using --email")
        exit(1)
    if app_password is None:
        print("Please provide Gmail app password using --app_password")
        exit(1)
    if num_elements is None:
        print("Please provide number of emails to download attachments from using --num_elements")
        exit(1)
    if output is None:
        print("Please provide output folder using --output")
        exit(1)

    if not (os.path.exists(output)):
        print("Output folder does not exist. Creating the folder...")
        os.makedirs(output)

def download_attachments(USERNAME, APP_PASSWORD, NUM_EMAILS, OUTPUT_FOLDER):
    print("Downloading attachments from the unreaded emails in your Gmail inbox to the folder:", OUTPUT_FOLDER)
    # Connect to Gmail IMAP server
    imap_server = imaplib.IMAP4_SSL("imap.gmail.com")
    imap_server.login(USERNAME, APP_PASSWORD)
    imap_server.select("INBOX")

    # Search for unseen emails
    status, email_ids = imap_server.search(None, "UNSEEN")
    email_ids = email_ids[0].split()

    # Get the latest 10 email IDs
    latest_email_ids = email_ids[-min(NUM_EMAILS, len(email_ids)):]

    if (len(latest_email_ids) == 0):
        print("No new emails with attachments found")

    # Fetch email messages and extract attachments
    for email_id in latest_email_ids:
        status, email_data = imap_server.fetch(email_id, "(RFC822)")
        raw_email = email_data[0][1]
        msg = email.message_from_bytes(raw_email)
        
        # Iterate over email parts
        for part in msg.walk():
            # Check if the part is an attachment
            if part.get_content_maintype() == "multipart" or part.get("Content-Disposition") is None:
                continue
            
            # Check if the part has a filename
            filename = part.get_filename()
            if filename:
                filepath = os.path.join(os.path.expanduser(OUTPUT_FOLDER), "id" + str(int(email_id)) + filename)
                # Save the attachment to a file
                with open(filepath, "wb") as fp:
                    fp.write(part.get_payload(decode=True))
                print(f"Downloaded attachment: {filename}. Date of email: {msg['Date']}")

    # Logout and close connection
    imap_server.logout()

if __name__ == "__main__":
    main()