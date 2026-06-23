# Scholarship App - Telegram Support Bot

## Overview
Firebase Cloud Function that powers a bilingual (EN/KM) Telegram support bot with:
- Automated FAQ responses
- Scholarship browsing from Firestore
- Application status checking
- Support ticket creation with admin reply capability
- Smart keyword-based auto-replies

## Setup

### 1. Create Telegram Bot
1. Open Telegram and search for **@BotFather**
2. Send `/newbot` and follow the prompts
3. Save the **bot token** returned by BotFather
4. (Optional) Set commands:
   ```
   /setcommands
   start - Welcome & main menu
   help - Available commands
   faq - Frequently Asked Questions
   scholarships - Browse scholarships
   status - Check application status
   contact - Contact support
   language - Switch language
   ```

### 2. Install Dependencies
```bash
cd functions
npm install
```

### 3. Configure Bot Token
```bash
firebase functions:config:set telegram.token="YOUR_BOT_TOKEN"
```

### 4. Deploy
```bash
firebase deploy --only functions
```

### 5. Set Webhook
After deployment, set the Telegram webhook to your function URL:
```bash
curl -X POST "https://api.telegram.org/botYOUR_BOT_TOKEN/setWebhook" \
  -H "Content-Type: application/json" \
  -d '{"url": "https://REGION-PROJECT_ID.cloudfunctions.net/telegramWebhook"}'
```

Replace:
- `YOUR_BOT_TOKEN` with your actual bot token
- `REGION` with your Firebase region (e.g., `us-central1`)
- `PROJECT_ID` with your Firebase project ID

## Firestore Collections

### `telegram_users`
Stores user preferences and state.
| Field | Type | Description |
|-------|------|-------------|
| chatId | number | Telegram chat ID |
| firstName | string | User's first name |
| language | string | `en` or `km` |
| state | string | Current conversation state |
| lastMessageAt | timestamp | Last interaction |

### `support_tickets`
Stores support messages from users.
| Field | Type | Description |
|-------|------|-------------|
| chatId | number | Telegram chat ID |
| message | string | User's support message |
| status | string | `open` / `responded` |
| platform | string | `telegram` |
| response | string | Admin reply (triggers bot notification) |
| createdAt | timestamp | When ticket was created |
| respondedAt | timestamp | When admin replied |

## Admin Reply Flow
1. User sends a support message via the bot
2. Message is saved to `support_tickets` collection with status `open`
3. Admin views the ticket in Firebase Console (or admin panel)
4. Admin writes their reply in the `response` field
5. The `replyToTicket` Cloud Function triggers automatically
6. Bot sends the reply back to the user on Telegram

## Architecture
```
User (Telegram) → Telegram API → Cloud Function (webhook)
                                      ↓
                                  Firestore
                                      ↑
Admin (Firebase Console) → Update ticket → Cloud Function (onUpdate)
                                              ↓
                                         Telegram API → User
```
