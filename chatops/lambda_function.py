"""
ChatOps — forward SNS notifications to Telegram.
Set TELEGRAM_TOKEN and TELEGRAM_CHAT_ID as Lambda environment variables
(do NOT hard-code secrets in this file).
"""
import json
import os
import urllib.request

TELEGRAM_TOKEN = os.environ["TELEGRAM_TOKEN"]
TELEGRAM_CHAT_ID = os.environ["TELEGRAM_CHAT_ID"]


def _send(text):
    url = f"https://api.telegram.org/bot{TELEGRAM_TOKEN}/sendMessage"
    data = json.dumps({"chat_id": TELEGRAM_CHAT_ID, "text": text}).encode()
    req = urllib.request.Request(url, data=data, headers={"Content-Type": "application/json"})
    with urllib.request.urlopen(req) as resp:
        return resp.read().decode()


def lambda_handler(event, context):
    for record in event.get("Records", []):
        sns = record.get("Sns", {})
        subject = sns.get("Subject") or "AWS Alert"
        message = sns.get("Message", "")
        _send(f"🔔 {subject}\n\n{message}")
    return {"status": "sent"}
