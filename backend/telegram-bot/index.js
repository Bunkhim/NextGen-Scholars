/**
 * Scholarship App - Telegram Support Bot
 *
 * Firebase Cloud Function providing:
 *  1. Webhook endpoint for Telegram Bot API
 *  2. Automated FAQ responses
 *  3. Live-agent handoff (stores queries in Firestore)
 *  4. Bilingual support (English + Khmer)
 *  5. Scholarship browsing via bot
 *  6. Application status checking
 *
 * Commands:
 *   /start          - Welcome & main menu
 *   /help           - Available commands
 *   /faq            - FAQ
 *   /scholarships   - Browse scholarships
 *   /status <id>    - Check application status
 *   /contact        - Contact support
 *   /language       - Switch language
 */

const functions = require("firebase-functions");
const admin = require("firebase-admin");
const TelegramBot = require("node-telegram-bot-api");

admin.initializeApp();
const db = admin.firestore();

// Bot token from environment variable (.env file) or Firebase config (legacy)
const BOT_TOKEN =
    process.env.TELEGRAM_BOT_TOKEN || functions.config().telegram?.token;

// =========================================================================
// MESSAGES
// =========================================================================
const MESSAGES = {
    en: {
        welcome:
            "\ud83c\udf93 *Welcome to Scholarship App Support!*\n\n" +
            "I'm your virtual assistant. I can help you with:\n\n" +
            "\ud83d\udcda Browse scholarships\n" +
            "\ud83d\udccb Check application status\n" +
            "\u2753 Answer common questions\n" +
            "\ud83d\udcac Connect you with our support team\n\n" +
            "Use the menu below or type a question!",
        help:
            "\ud83d\udcd6 *Available Commands:*\n\n" +
            "/start \u2013 Welcome & main menu\n" +
            "/faq \u2013 Frequently Asked Questions\n" +
            "/scholarships \u2013 Browse latest scholarships\n" +
            "/status `<app_id>` \u2013 Check application status\n" +
            "/contact \u2013 Contact support team\n" +
            "/language \u2013 Switch language\n" +
            "/help \u2013 Show this message",
        faqTitle: "\u2753 *Frequently Asked Questions*\n\nSelect a topic:",
        faq: [
            {
                q: "How do I apply for a scholarship?",
                a:
                    "1\ufe0f\u20e3 Open the Scholarship App\n" +
                    "2\ufe0f\u20e3 Browse scholarships on Discover\n" +
                    "3\ufe0f\u20e3 Tap a scholarship to view details\n" +
                    "4\ufe0f\u20e3 Click \"Apply Now\"\n" +
                    "5\ufe0f\u20e3 Complete your profile if needed\n\n" +
                    "\u2705 Make sure your profile is complete before applying!",
            },
            {
                q: "Can I apply for multiple scholarships?",
                a:
                    "Yes! You can apply to as many scholarships as you qualify for. " +
                    "Each application is tracked separately in \"My Applications\".",
            },
            {
                q: "How do I track my application?",
                a:
                    "Go to *Profile \u2192 My Applications*. You'll see all your applications with status:\n\n" +
                    "\ud83d\udfe1 Pending \u2013 Under review\n" +
                    "\ud83d\udfe2 Accepted \u2013 Congratulations!\n" +
                    "\ud83d\udd34 Rejected \u2013 Try other scholarships\n" +
                    "\ud83d\udfe3 Interview \u2013 Check your email",
            },
            {
                q: "How do I update my profile?",
                a:
                    "Go to *Profile \u2192 Edit Profile*. You can update your personal info, " +
                    "photo, education details, and interests.",
            },
            {
                q: "What if my application is rejected?",
                a:
                    "Don't give up! \ud83d\udcaa\n\n" +
                    "\u2022 Review the scholarship requirements\n" +
                    "\u2022 Improve your profile\n" +
                    "\u2022 Apply to other scholarships\n" +
                    "\u2022 New scholarships are added regularly!",
            },
        ],
        contactMsg:
            "\ud83d\udcac *Contact Our Support Team*\n\n" +
            "\ud83d\udce7 Email: choubkhunrithy@gmail.com\n" +
            "\ud83d\udcde Phone: +855 31 228 7763\n" +
            "\ud83d\udd50 Hours: Mon-Fri, 8AM - 5PM (Cambodia Time)\n\n" +
            "Or type your message here and our team will respond!",
        agentForward:
            "\u2705 Your message has been forwarded to our support team. " +
            "We'll respond within 24 hours.\n\n" +
            "Email choubkhunrithy@gmail.com for urgent matters.",
        statusNotFound:
            "\u274c Application not found. Please check your Application ID.\n\n" +
            "Find it in: *Profile \u2192 My Applications \u2192 Details*",
        statusFound:
            "\ud83d\udccb *Application Status*\n\n" +
            "\ud83c\udd94 ID: `{id}`\n" +
            "\ud83d\udcda Scholarship: {scholarship}\n" +
            "\ud83d\udcca Status: {status}\n" +
            "\ud83d\udcc5 Applied: {date}",
        noScholarships: "No active scholarships found. Check back soon! \ud83d\udd14",
        scholarshipItem:
            "\ud83c\udf93 *{title}*\n\ud83c\udfeb {university}\n\ud83c\udf0d {country}\n" +
            "\ud83d\udcc5 Deadline: {deadline}\n\ud83d\udcb0 {funding}\n",
        scholarshipsTitle:
            "\ud83d\udcda *Latest Scholarships*\n\nHere are the latest opportunities:",
        languageSwitch: "\ud83c\udf10 *Choose your language:*",
        languageSet: "\u2705 Language set to *English*",
        unknownMsg:
            "\ud83e\udd14 I'm not sure I understand. Here's what I can help with:\n\n" +
            "\u2022 Type /faq for common questions\n" +
            "\u2022 Type /scholarships to browse\n" +
            "\u2022 Type /contact to reach our team\n\n" +
            "Or simply type your question!",
        mainMenu: "\ud83d\udccb *Main Menu*\n\nWhat would you like to do?",
        btnFaq: "\u2753 FAQ",
        btnScholarships: "\ud83d\udcda Scholarships",
        btnStatus: "\ud83d\udcca Check Status",
        btnContact: "\ud83d\udcac Contact",
        btnLanguage: "\ud83c\udf10 Language",
        btnHelp: "\u2753 Help",
        askStatusId:
            "Please send your *Application ID*.\n\n" +
            "Find it in: *Profile \u2192 My Applications \u2192 Details*",
        writePrompt: "\u270d\ufe0f Please type your message...",
        writeBtn: "\u270d\ufe0f Write a message",
        replyFromSupport: "\ud83d\udce9 *Reply from Support Team:*",
    },
    km: {
        welcome:
            "\ud83c\udf93 *\u179f\u17bc\u1798\u179f\u17d2\u179c\u17b6\u1782\u1798\u1793\u17cd\u1798\u1780\u1780\u17b6\u1793\u17cb Scholarship App Support!*\n\n" +
            "\u1781\u17d2\u1789\u17bb\u17c6\u1787\u17b6\u1787\u17c6\u1793\u17bd\u1799\u1780\u17b6\u179a\u1793\u17b7\u1798\u17d2\u1798\u17b7\u178f\u17d4 \u1781\u17d2\u1789\u17bb\u17c6\u17a2\u17b6\u1785\u1787\u17bd\u1799\u17a2\u17d2\u1793\u1780\u1780\u17d2\u1793\u17bb\u1784:\n\n" +
            "\ud83d\udcda \u179a\u17bb\u1780\u179a\u1780\u17a2\u17b6\u17a0\u17b6\u179a\u17bc\u1794\u1780\u179a\u178e\u17cd\n" +
            "\ud83d\udccb \u1796\u17b7\u1793\u17b7\u178f\u17d2\u1799\u179f\u17d2\u1790\u17b6\u1793\u1797\u17b6\u1796\u1796\u17b6\u1780\u17d2\u1799\u179f\u17bb\u17c6\n" +
            "\u2753 \u1786\u17d2\u179b\u17be\u1799\u179f\u17c6\u178e\u17bd\u179a\u1791\u17bc\u1791\u17c5\n" +
            "\ud83d\udcac \u1797\u17d2\u1787\u17b6\u1794\u17cb\u17a2\u17d2\u1793\u1780\u1787\u17b6\u1798\u17bd\u1799\u1780\u17d2\u179a\u17bb\u1798\u1787\u17c6\u1793\u17bd\u1799\n\n" +
            "\u179f\u17bc\u1798\u1794\u17d2\u179a\u17be\u1798\u17ba\u1793\u17bb\u1799\u1781\u17b6\u1784\u1780\u17d2\u179a\u17c4\u1798 \u17ac\u179c\u17b6\u1799\u179f\u17c6\u178e\u17bd\u179a!",
        help:
            "\ud83d\udcd6 *\u1796\u17b6\u1780\u17d2\u1799\u1794\u1789\u17d2\u1787\u17b6\u178a\u17c2\u179b\u1798\u17b6\u1793:*\n\n" +
            "/start \u2013 \u179f\u17bc\u1798\u179f\u17d2\u179c\u17b6\u1782\u1798\u1793\u17cd \u1793\u17b7\u1784\u1798\u17ba\u1793\u17bb\u1799\n" +
            "/faq \u2013 \u179f\u17c6\u178e\u17bd\u179a\u178a\u17c2\u179b\u179f\u17bd\u179a\u1787\u17b6\u179a\u17bf\u1799\u17d7\n" +
            "/scholarships \u2013 \u179a\u17bb\u1780\u179a\u1780\u17a2\u17b6\u17a0\u17b6\u179a\u17bc\u1794\u1780\u179a\u178e\u17cd\n" +
            "/status `<app_id>` \u2013 \u1796\u17b7\u1793\u17b7\u178f\u17d2\u1799\u179f\u17d2\u1790\u17b6\u1793\u1797\u17b6\u1796\u1796\u17b6\u1780\u17d2\u1799\n" +
            "/contact \u2013 \u1791\u17b6\u1780\u17cb\u1791\u1784\u1780\u17d2\u179a\u17bb\u1798\u1787\u17c6\u1793\u17bd\u1799\n" +
            "/language \u2013 \u1794\u17d2\u178f\u17bc\u179a\u1797\u17b6\u179f\u17b6\n" +
            "/help \u2013 \u1794\u1784\u17d2\u17a0\u17b6\u1789\u179f\u17b6\u179a\u1793\u17c1\u17c7",
        faqTitle:
            "\u2753 *\u179f\u17c6\u178e\u17bd\u179a\u178a\u17c2\u179b\u179f\u17bd\u179a\u1787\u17b6\u179a\u17bf\u1799\u17d7*\n\n\u1787\u17d2\u179a\u17be\u179f\u179a\u17be\u179f\u1794\u17d2\u179a\u1792\u17b6\u1793\u1794\u1791:",
        faq: [
            {
                q: "\u178f\u17be\u1781\u17d2\u1789\u17bb\u17c6\u178a\u17b6\u1780\u17cb\u1796\u17b6\u1780\u17d2\u1799\u179f\u17bb\u17c6\u17a2\u17b6\u17a0\u17b6\u179a\u17bc\u1794\u1780\u179a\u178e\u17cd\u178a\u17c4\u1799\u179a\u1794\u17c0\u1794\u178e\u17b6?",
                a:
                    "1\ufe0f\u20e3 \u1794\u17be\u1780\u1780\u1798\u17d2\u1798\u179c\u17b7\u1792\u17b8 Scholarship App\n" +
                    "2\ufe0f\u20e3 \u179a\u17bb\u1780\u179a\u1780\u17a2\u17b6\u17a0\u17b6\u179a\u17bc\u1794\u1780\u179a\u178e\u17cd\u1793\u17c5\u1791\u17c6\u1796\u17d0\u179a\u179f\u17d2\u179c\u17c2\u1784\u179a\u1780\n" +
                    "3\ufe0f\u20e3 \u1785\u17bb\u1785\u179b\u17be\u17a2\u17b6\u17a0\u17b6\u179a\u17bc\u1794\u1780\u179a\u178e\u17cd\u178a\u17be\u1798\u17d2\u1794\u17b8\u1798\u17be\u179b\u1796\u17d0\u178f\u17cc\u1798\u17b6\u1793\u179b\u1798\u17d2\u17a2\u17b7\u178f\n" +
                    "4\ufe0f\u20e3 \u1785\u17bb\u1785 \"\u178a\u17b6\u1780\u17cb\u1796\u17b6\u1780\u17d2\u1799\u17a5\u17a1\u17bc\u179c\"\n" +
                    "5\ufe0f\u20e3 \u1794\u17c6\u1796\u17c1\u1789\u1794\u17d2\u179a\u179c\u178f\u17d2\u178f\u17b7\u179a\u17bc\u1794\u1794\u17d2\u179a\u179f\u17b7\u1793\u1794\u17be\u1785\u17b6\u17c6\u1794\u17b6\u1785\u17cb\n\n" +
                    "\u2705 \u179f\u17bc\u1798\u1794\u17d2\u179a\u17b6\u1780\u178a\u1790\u17b6\u1794\u17d2\u179a\u179c\u178f\u17d2\u178f\u17b7\u179a\u17bc\u1794\u1796\u17c1\u1789\u179b\u17c1\u1789\u1798\u17bb\u1793\u1796\u17c1\u179b\u178a\u17b6\u1780\u17cb\u1796\u17b6\u1780\u17d2\u1799!",
            },
            {
                q: "\u178f\u17be\u1781\u17d2\u1789\u17bb\u17c6\u17a2\u17b6\u1785\u178a\u17b6\u1780\u17cb\u1796\u17b6\u1780\u17d2\u1799\u17a2\u17b6\u17a0\u17b6\u179a\u17bc\u1794\u1780\u179a\u178e\u17cd\u1785\u17d2\u179a\u17be\u1793\u1794\u17b6\u1793\u1791\u17c1?",
                a:
                    "\u1794\u17b6\u1793! \u17a2\u17d2\u1793\u1780\u17a2\u17b6\u1785\u178a\u17b6\u1780\u17cb\u1796\u17b6\u1780\u17d2\u1799\u17a2\u17b6\u17a0\u17b6\u179a\u17bc\u1794\u1780\u179a\u178e\u17cd\u1785\u17d2\u179a\u17be\u1793\u178f\u17b6\u1798\u178a\u17c2\u179b\u17a2\u17d2\u1793\u1780\u1798\u17b6\u1793\u179b\u1780\u17d2\u1781\u178e\u17c8\u1782\u17d2\u179a\u1794\u17cb\u1782\u17d2\u179a\u17b6\u1793\u17cb\u17d4 " +
                    "\u1796\u17b6\u1780\u17d2\u1799\u179f\u17bb\u17c6\u1793\u17b8\u1798\u17bd\u1799\u17d7\u178f\u17d2\u179a\u17bc\u179c\u1794\u17b6\u1793\u178f\u17b6\u1798\u178a\u17b6\u1793\u178a\u17b6\u1785\u17cb\u178a\u17c4\u1799\u17a1\u17c2\u1780\u17d4",
            },
            {
                q: "\u178f\u17be\u1781\u17d2\u1789\u17bb\u17c6\u178f\u17b6\u1798\u178a\u17b6\u1793\u179f\u17d2\u1790\u17b6\u1793\u1797\u17b6\u1796\u1796\u17b6\u1780\u17d2\u1799\u179f\u17bb\u17c6\u178a\u17c4\u1799\u179a\u1794\u17c0\u1794\u178e\u17b6?",
                a:
                    "\u1791\u17c5\u1780\u17b6\u1793\u17cb *\u1794\u17d2\u179a\u179c\u178f\u17d2\u178f\u17b7\u179a\u17bc\u1794 \u2192 \u1796\u17b6\u1780\u17d2\u1799\u179f\u17bb\u17c6\u179a\u1794\u179f\u17cb\u1781\u17d2\u1789\u17bb\u17c6*\u17d4 \u17a2\u17d2\u1793\u1780\u1793\u17b9\u1784\u1783\u17be\u1789\u1796\u17b6\u1780\u17d2\u1799\u179f\u17bb\u17c6\u1791\u17b6\u17c6\u1784\u17a2\u179f\u17cb\u1787\u17b6\u1798\u17bd\u1799\u179f\u17d2\u1790\u17b6\u1793\u1797\u17b6\u1796:\n\n" +
                    "\ud83d\udfe1 \u1780\u17c6\u1796\u17bb\u1784\u179a\u1784\u17cb\u1785\u17b6\u17c6 \u2013 \u1780\u17c6\u1796\u17bb\u1784\u1796\u17b7\u1793\u17b7\u178f\u17d2\u1799\n" +
                    "\ud83d\udfe2 \u1791\u1791\u17bd\u179b\u1799\u1780 \u2013 \u179f\u17bc\u1798\u17a2\u1794\u17a2\u179a\u179f\u17b6\u1791\u179a!\n" +
                    "\ud83d\udd34 \u1798\u17b7\u1793\u178f\u17d2\u179a\u17bc\u179c\u1787\u17d2\u179a\u17be\u179f \u2013 \u179f\u17bc\u1798\u1796\u17d2\u1799\u17b6\u1799\u17b6\u1798\u17a2\u17b6\u17a0\u17b6\u179a\u17bc\u1794\u1780\u179a\u178e\u17cd\u1795\u17d2\u179f\u17c1\u1784\n" +
                    "\ud83d\udfe3 \u179f\u1798\u17d2\u1797\u17b6\u179f\u1793\u17cd \u2013 \u1796\u17b7\u1793\u17b7\u178f\u17d2\u1799\u17a2\u17ca\u17b8\u1798\u17c2\u179b",
            },
            {
                q: "\u178f\u17be\u1781\u17d2\u1789\u17bb\u17c6\u1792\u17d2\u179c\u17be\u1794\u1785\u17d2\u1785\u17bb\u1794\u17d2\u1794\u1793\u17d2\u1793\u1797\u17b6\u1796\u1794\u17d2\u179a\u179c\u178f\u17d2\u178f\u17b7\u179a\u17bc\u1794\u178a\u17c4\u1799\u179a\u1794\u17c0\u1794\u178e\u17b6?",
                a:
                    "\u1791\u17c5\u1780\u17b6\u1793\u17cb *\u1794\u17d2\u179a\u179c\u178f\u17d2\u178f\u17b7\u179a\u17bc\u1794 \u2192 \u1780\u17c2\u1794\u17d2\u179a\u179c\u178f\u17d2\u178f\u17b7\u179a\u17bc\u1794*\u17d4 " +
                    "\u17a2\u17d2\u1793\u1780\u17a2\u17b6\u1785\u1792\u17d2\u179c\u17be\u1794\u1785\u17d2\u1785\u17bb\u1794\u17d2\u1794\u1793\u17d2\u1793\u1797\u17b6\u1796\u1796\u17d0\u178f\u17cc\u1798\u17b6\u1793\u1795\u17d2\u1791\u17b6\u179b\u17cb\u1781\u17d2\u179b\u17bd\u1793 \u179a\u17bc\u1794\u1790\u178f \u1793\u17b7\u1784\u179c\u17b7\u179f\u17d0\u1799\u178a\u17c2\u179b\u1785\u17b6\u1794\u17cb\u17a2\u17b6\u179a\u1798\u17d2\u1798\u178e\u17cd\u17d4",
            },
            {
                q: "\u178f\u17be\u1781\u17d2\u1789\u17bb\u17c6\u1782\u17bd\u179a\u1792\u17d2\u179c\u17be\u17a2\u17d2\u179c\u17b8\u1794\u17d2\u179a\u179f\u17b7\u1793\u1794\u17be\u1796\u17b6\u1780\u17d2\u1799\u179f\u17bb\u17c6\u1798\u17b7\u1793\u178f\u17d2\u179a\u17bc\u179c\u1787\u17d2\u179a\u17be\u179f?",
                a:
                    "\u1780\u17bb\u17c6\u1781\u1780\u1785\u17b7\u178f\u17d2\u178f! \ud83d\udcaa\n\n" +
                    "\u2022 \u1796\u17b7\u1793\u17b7\u178f\u17d2\u1799\u1798\u17be\u179b\u178f\u1798\u17d2\u179a\u17bc\u179c\u1780\u17b6\u179a\u17a2\u17b6\u17a0\u17b6\u179a\u17bc\u1794\u1780\u179a\u178e\u17cd\n" +
                    "\u2022 \u1780\u17c2\u179b\u1798\u17d2\u17a2\u1794\u17d2\u179a\u179c\u178f\u17d2\u178f\u17b7\u179a\u17bc\u1794\u179a\u1794\u179f\u17cb\u17a2\u17d2\u1793\u1780\n" +
                    "\u2022 \u178a\u17b6\u1780\u17cb\u1796\u17b6\u1780\u17d2\u1799\u17a2\u17b6\u17a0\u17b6\u179a\u17bc\u1794\u1780\u179a\u178e\u17cd\u1795\u17d2\u179f\u17c1\u1784\u1791\u17c0\u178f\n" +
                    "\u2022 \u17a2\u17b6\u17a0\u17b6\u179a\u17bc\u1794\u1780\u179a\u178e\u17cd\u1790\u17d2\u1798\u17b8\u178f\u17d2\u179a\u17bc\u179c\u1794\u17b6\u1793\u1794\u1793\u17d2\u1790\u17c2\u1798\u1787\u17b6\u1793\u17b7\u1785\u17d2\u1785!",
            },
        ],
        contactMsg:
            "\ud83d\udcac *\u1791\u17b6\u1780\u17cb\u1791\u1784\u1780\u17d2\u179a\u17bb\u1798\u1787\u17c6\u1793\u17bd\u1799\u179a\u1794\u179f\u17cb\u1799\u17be\u1784*\n\n" +
            "\ud83d\udce7 \u17a2\u17ca\u17b8\u1798\u17c2\u179b: choubkhunrithy@gmail.com\n" +
            "\ud83d\udcde \u1791\u17bc\u179a\u179f\u17d0\u1796\u17d2\u1791: +855 31 228 7763\n" +
            "\ud83d\udd50 \u1798\u17c9\u17c4\u1784: \u1785\u17d0\u1793\u17d2\u1791-\u179f\u17bb\u1780\u17d2\u179a, 8AM - 5PM\n\n" +
            "\u17ac\u179c\u17b6\u1799\u179f\u17b6\u179a\u179a\u1794\u179f\u17cb\u17a2\u17d2\u1793\u1780\u1793\u17c5\u1791\u17b8\u1793\u17c1\u17c7 \u17a0\u17be\u1799\u1780\u17d2\u179a\u17bb\u1798\u1793\u17b9\u1784\u1786\u17d2\u179b\u17be\u1799\u178f\u1794!",
        agentForward:
            "\u2705 \u179f\u17b6\u179a\u179a\u1794\u179f\u17cb\u17a2\u17d2\u1793\u1780\u178f\u17d2\u179a\u17bc\u179c\u1794\u17b6\u1793\u1795\u17d2\u1789\u17be\u1791\u17c5\u1780\u17d2\u179a\u17bb\u1798\u1787\u17c6\u1793\u17bd\u1799\u179a\u1794\u179f\u17cb\u1799\u17be\u1784\u17a0\u17be\u1799\u17d4 " +
            "\u1799\u17be\u1784\u1793\u17b9\u1784\u1786\u17d2\u179b\u17be\u1799\u178f\u1794\u1780\u17d2\u1793\u17bb\u1784\u179a\u1799\u17c8\u1796\u17c1\u179b 24 \u1798\u17c9\u17c4\u1784!\n\n" +
            "\u17a2\u17ca\u17b8\u1798\u17c2\u179b\u1798\u1780 choubkhunrithy@gmail.com \u179f\u1798\u17d2\u179a\u17b6\u1794\u17cb\u179a\u17bf\u1784\u1794\u17d2\u179a\u17b6\u1794\u17cb\u17d4",
        statusNotFound:
            "\u274c \u179a\u1780\u1798\u17b7\u1793\u1783\u17be\u1789\u1796\u17b6\u1780\u17d2\u1799\u179f\u17bb\u17c6\u17d4 \u179f\u17bc\u1798\u1796\u17b7\u1793\u17b7\u178f\u17d2\u1799\u179b\u17c1\u1781\u179f\u1798\u17d2\u1782\u17b6\u179b\u17cb\u1796\u17b6\u1780\u17d2\u1799\u179f\u17bb\u17c6\u179a\u1794\u179f\u17cb\u17a2\u17d2\u1793\u1780\u17d4\n\n" +
            "\u179a\u1780\u179c\u17b6\u1793\u17c5: *\u1794\u17d2\u179a\u179c\u178f\u17d2\u178f\u17b7\u179a\u17bc\u1794 \u2192 \u1796\u17b6\u1780\u17d2\u1799\u179f\u17bb\u17c6\u179a\u1794\u179f\u17cb\u1781\u17d2\u1789\u17bb\u17c6 \u2192 \u1796\u17d0\u178f\u17cc\u1798\u17b6\u1793\u179b\u1798\u17d2\u17a2\u17b7\u178f*",
        statusFound:
            "\ud83d\udccb *\u179f\u17d2\u1790\u17b6\u1793\u1797\u17b6\u1796\u1796\u17b6\u1780\u17d2\u1799\u179f\u17bb\u17c6*\n\n" +
            "\ud83c\udd94 \u179b\u17c1\u1781: `{id}`\n" +
            "\ud83d\udcda \u17a2\u17b6\u17a0\u17b6\u179a\u17bc\u1794\u1780\u179a\u178e\u17cd: {scholarship}\n" +
            "\ud83d\udcca \u179f\u17d2\u1790\u17b6\u1793\u1797\u17b6\u1796: {status}\n" +
            "\ud83d\udcc5 \u1790\u17d2\u1784\u17c3\u178a\u17b6\u1780\u17cb\u1796\u17b6\u1780\u17d2\u1799: {date}",
        noScholarships:
            "\u1798\u17b7\u1793\u1798\u17b6\u1793\u17a2\u17b6\u17a0\u17b6\u179a\u17bc\u1794\u1780\u179a\u178e\u17cd\u179f\u1780\u1798\u17d2\u1798\u1793\u17c5\u1796\u17c1\u179b\u1793\u17c1\u17c7\u17d4 \u179f\u17bc\u1798\u1796\u17b7\u1793\u17b7\u178f\u17d2\u1799\u1798\u17be\u179b\u1798\u17d2\u178f\u1784\u1791\u17c0\u178f! \ud83d\udd14",
        scholarshipItem:
            "\ud83c\udf93 *{title}*\n\ud83c\udfeb {university}\n\ud83c\udf0d {country}\n" +
            "\ud83d\udcc5 \u1780\u17c6\u178e\u178f\u17cb\u1795\u17bb\u178f\u1780\u17c6\u178e\u178f\u17cb: {deadline}\n\ud83d\udcb0 {funding}\n",
        scholarshipsTitle:
            "\ud83d\udcda *\u17a2\u17b6\u17a0\u17b6\u179a\u17bc\u1794\u1780\u179a\u178e\u17cd\u1790\u17d2\u1798\u17b8\u17d7*\n\n\u1793\u17c1\u17c7\u1782\u17ba\u1787\u17b6\u17a2\u17b6\u17a0\u17b6\u179a\u17bc\u1794\u1780\u179a\u178e\u17cd\u1790\u17d2\u1798\u17b8\u17d7:",
        languageSwitch: "\ud83c\udf10 *\u1787\u17d2\u179a\u17be\u179f\u179a\u17be\u179f\u1797\u17b6\u179f\u17b6\u179a\u1794\u179f\u17cb\u17a2\u17d2\u1793\u1780:*",
        languageSet:
            "\u2705 \u1797\u17b6\u179f\u17b6\u178f\u17d2\u179a\u17bc\u179c\u1794\u17b6\u1793\u1780\u17c6\u178e\u178f\u17cb\u1787\u17b6 *\u1797\u17b6\u179f\u17b6\u1781\u17d2\u1798\u17c2\u179a*",
        unknownMsg:
            "\ud83e\udd14 \u1781\u17d2\u1789\u17bb\u17c6\u1798\u17b7\u1793\u1785\u17d2\u1794\u17b6\u179f\u17cb\u17d4 \u1793\u17c1\u17c7\u1782\u17ba\u17a2\u17d2\u179c\u17b8\u178a\u17c2\u179b\u1781\u17d2\u1789\u17bb\u17c6\u17a2\u17b6\u1785\u1787\u17bd\u1799:\n\n" +
            "\u2022 \u179c\u17b6\u1799 /faq \u179f\u1798\u17d2\u179a\u17b6\u1794\u17cb\u179f\u17c6\u178e\u17bd\u179a\u1791\u17bc\u1791\u17c5\n" +
            "\u2022 \u179c\u17b6\u1799 /scholarships \u178a\u17be\u1798\u17d2\u1794\u17b8\u179a\u17bb\u1780\u179a\u1780\n" +
            "\u2022 \u179c\u17b6\u1799 /contact \u178a\u17be\u1798\u17d2\u1794\u17b8\u1791\u17b6\u1780\u17cb\u1791\u1784\u1780\u17d2\u179a\u17bb\u1798\n\n" +
            "\u17ac\u179c\u17b6\u1799\u179f\u17c6\u178e\u17bd\u179a\u179a\u1794\u179f\u17cb\u17a2\u17d2\u1793\u1780 \u17a0\u17be\u1799\u1781\u17d2\u1789\u17bb\u17c6\u1793\u17b9\u1784\u1796\u17d2\u1799\u17b6\u1799\u17b6\u1798\u1787\u17bd\u1799!",
        mainMenu:
            "\ud83d\udccb *\u1798\u17ba\u1793\u17bb\u1799\u1787\u17b6\u1785\u17d2\u179a\u17be\u179f*\n\n\u178f\u17be\u17a2\u17d2\u1793\u1780\u1785\u1784\u17cb\u1792\u17d2\u179c\u17be\u17a2\u17d2\u179c\u17b8?",
        btnFaq: "\u2753 \u179f\u17c6\u178e\u17bd\u179a\u1787\u17b6\u179a\u17bf\u1799\u17d7",
        btnScholarships: "\ud83d\udcda \u17a2\u17b6\u17a0\u17b6\u179a\u17bc\u1794\u1780\u179a\u178e\u17cd",
        btnStatus:
            "\ud83d\udcca \u1796\u17b7\u1793\u17b7\u178f\u17d2\u1799\u179f\u17d2\u1790\u17b6\u1793\u1797\u17b6\u1796",
        btnContact: "\ud83d\udcac \u1791\u17b6\u1780\u17cb\u1791\u1784",
        btnLanguage: "\ud83c\udf10 \u1797\u17b6\u179f\u17b6",
        btnHelp: "\u2753 \u1787\u17c6\u1793\u17bd\u1799",
        askStatusId:
            "\u179f\u17bc\u1798\u1795\u17d2\u1789\u17be *\u179b\u17c1\u1781\u179f\u1798\u17d2\u1782\u17b6\u179b\u17cb\u1796\u17b6\u1780\u17d2\u1799\u179f\u17bb\u17c6*\u17d4\n\n" +
            "\u179a\u1780\u179c\u17b6\u1793\u17c5: *\u1794\u17d2\u179a\u179c\u178f\u17d2\u178f\u17b7\u179a\u17bc\u1794 \u2192 \u1796\u17b6\u1780\u17d2\u1799\u179f\u17bb\u17c6\u179a\u1794\u179f\u17cb\u1781\u17d2\u1789\u17bb\u17c6 \u2192 \u1796\u17d0\u178f\u17cc\u1798\u17b6\u1793\u179b\u1798\u17d2\u17a2\u17b7\u178f*",
        writePrompt:
            "\u270d\ufe0f \u179f\u17bc\u1798\u179c\u17b6\u1799\u179f\u17b6\u179a\u179a\u1794\u179f\u17cb\u17a2\u17d2\u1793\u1780...",
        writeBtn:
            "\u270d\ufe0f \u179f\u179a\u179f\u17c1\u179a\u179f\u17b6\u179a",
        replyFromSupport:
            "\ud83d\udce9 *\u1786\u17d2\u179b\u17be\u1799\u178f\u1794\u1796\u17b8\u1780\u17d2\u179a\u17bb\u1798\u1787\u17c6\u1793\u17bd\u1799:*",
    },
};

// Status emoji mapping
const STATUS_EMOJI = {
    pending: "\ud83d\udfe1 Pending",
    reviewing: "\ud83d\udd35 Under Review",
    accepted: "\ud83d\udfe2 Accepted",
    rejected: "\ud83d\udd34 Not Selected",
    interview: "\ud83d\udfe3 Interview",
};

// =========================================================================
// HELPERS
// =========================================================================

async function getUserLang(chatId) {
    try {
        const doc = await db.collection("telegram_users").doc(String(chatId)).get();
        return doc.exists && doc.data().language ? doc.data().language : "en";
    } catch (_) {
        return "en";
    }
}

async function setUserLang(chatId, lang) {
    await db
        .collection("telegram_users")
        .doc(String(chatId))
        .set(
            {
                language: lang,
                updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            },
            { merge: true }
        );
}

function mainMenuKeyboard(lang) {
    const m = MESSAGES[lang];
    return {
        inline_keyboard: [
            [
                { text: m.btnFaq, callback_data: "faq" },
                { text: m.btnScholarships, callback_data: "scholarships" },
            ],
            [
                { text: m.btnStatus, callback_data: "check_status" },
                { text: m.btnContact, callback_data: "contact" },
            ],
            [
                { text: m.btnLanguage, callback_data: "language" },
                { text: m.btnHelp, callback_data: "help" },
            ],
        ],
    };
}

function faqKeyboard(lang) {
    const faqs = MESSAGES[lang].faq;
    const rows = faqs.map((faq, i) => [
        {
            text: (i + 1) + ". " + faq.q.substring(0, 40) + "...",
            callback_data: "faq_" + i,
        },
    ]);
    rows.push([{ text: "\u2b05\ufe0f Back", callback_data: "main_menu" }]);
    return { inline_keyboard: rows };
}

function languageKeyboard() {
    return {
        inline_keyboard: [
            [
                { text: "\ud83c\uddec\ud83c\udde7 English", callback_data: "lang_en" },
                {
                    text: "\ud83c\uddf0\ud83c\udded \u1797\u17b6\u179f\u17b6\u1781\u17d2\u1798\u17c2\u179a",
                    callback_data: "lang_km",
                },
            ],
            [{ text: "\u2b05\ufe0f Back", callback_data: "main_menu" }],
        ],
    };
}

// Smart keyword auto-reply
function findAutoReply(text, lang) {
    const lower = text.toLowerCase();
    const rules = [
        {
            patterns: ["how to apply", "apply", "\u178a\u17b6\u1780\u17cb\u1796\u17b6\u1780\u17d2\u1799"],
            faqIndex: 0,
        },
        {
            patterns: ["multiple", "many", "\u1785\u17d2\u179a\u17be\u1793"],
            faqIndex: 1,
        },
        {
            patterns: ["track", "status", "\u179f\u17d2\u1790\u17b6\u1793\u1797\u17b6\u1796", "\u178f\u17b6\u1798\u178a\u17b6\u1793"],
            faqIndex: 2,
        },
        {
            patterns: ["profile", "update", "edit", "\u1794\u17d2\u179a\u179c\u178f\u17d2\u178f\u17b7\u179a\u17bc\u1794", "\u1780\u17c2"],
            faqIndex: 3,
        },
        {
            patterns: ["reject", "not selected", "failed", "\u1798\u17b7\u1793\u178f\u17d2\u179a\u17bc\u179c\u1787\u17d2\u179a\u17be\u179f"],
            faqIndex: 4,
        },
    ];

    for (const rule of rules) {
        if (rule.patterns.some((p) => lower.includes(p))) {
            return MESSAGES[lang].faq[rule.faqIndex].a;
        }
    }

    // Greetings
    const greetings = ["hello", "hi", "hey", "good morning", "\u179f\u17bd\u179f\u17d2\u178f\u17b8"];
    if (greetings.some((g) => lower.includes(g))) {
        return lang === "km"
            ? "\ud83d\udc4b \u179f\u17bd\u179f\u17d2\u178f\u17b8! \u178f\u17be\u1781\u17d2\u1789\u17bb\u17c6\u17a2\u17b6\u1785\u1787\u17bd\u1799\u17a2\u17d2\u179c\u17b8\u17a2\u17d2\u1793\u1780\u1793\u17c5\u1790\u17d2\u1784\u17c3\u1793\u17c1\u17c7?"
            : "\ud83d\udc4b Hello! How can I help you today?";
    }

    // Thanks
    const thanks = ["thank", "thanks", "\u17a2\u179a\u1782\u17bb\u178e"];
    if (thanks.some((t) => lower.includes(t))) {
        return lang === "km"
            ? "\ud83d\ude0a \u17a2\u179a\u1782\u17bb\u178e! \u179f\u17bc\u1798\u179f\u17bd\u179a\u1794\u17d2\u179a\u179f\u17b7\u1793\u1794\u17be\u17a2\u17d2\u1793\u1780\u178f\u17d2\u179a\u17bc\u179c\u1780\u17b6\u179a\u17a2\u17d2\u179c\u17b8\u1795\u17d2\u179f\u17c1\u1784\u1791\u17c0\u178f\u17d4"
            : "\ud83d\ude0a You're welcome! Feel free to ask if you need anything else.";
    }

    return null;
}

// =========================================================================
// WEBHOOK HANDLER
// =========================================================================
exports.telegramWebhook = functions.https.onRequest(async (req, res) => {
    if (req.method !== "POST") {
        res.status(200).send("Telegram Bot is running");
        return;
    }

    const bot = new TelegramBot(BOT_TOKEN);
    const body = req.body;

    try {
        // Handle callback queries (inline buttons)
        if (body.callback_query) {
            const cb = body.callback_query;
            const chatId = cb.message.chat.id;
            const data = cb.data;
            const lang = await getUserLang(chatId);
            const m = MESSAGES[lang];

            await bot.answerCallbackQuery(cb.id);

            if (data === "main_menu") {
                await bot.sendMessage(chatId, m.mainMenu, {
                    parse_mode: "Markdown",
                    reply_markup: mainMenuKeyboard(lang),
                });
            } else if (data === "faq") {
                await bot.sendMessage(chatId, m.faqTitle, {
                    parse_mode: "Markdown",
                    reply_markup: faqKeyboard(lang),
                });
            } else if (data.startsWith("faq_")) {
                const idx = parseInt(data.split("_")[1], 10);
                const faq = m.faq[idx];
                if (faq) {
                    await bot.sendMessage(chatId, "*" + faq.q + "*\n\n" + faq.a, {
                        parse_mode: "Markdown",
                        reply_markup: {
                            inline_keyboard: [
                                [{ text: "\u2b05\ufe0f Back to FAQ", callback_data: "faq" }],
                                [{ text: "\ud83c\udfe0 Main Menu", callback_data: "main_menu" }],
                            ],
                        },
                    });
                }
            } else if (data === "scholarships") {
                await handleScholarships(bot, chatId, lang);
            } else if (data === "check_status") {
                await bot.sendMessage(chatId, m.askStatusId, {
                    parse_mode: "Markdown",
                    reply_markup: {
                        inline_keyboard: [
                            [{ text: "\u2b05\ufe0f Back", callback_data: "main_menu" }],
                        ],
                    },
                });
                await db
                    .collection("telegram_users")
                    .doc(String(chatId))
                    .set({ state: "awaiting_status_id" }, { merge: true });
            } else if (data === "contact") {
                await bot.sendMessage(chatId, m.contactMsg, {
                    parse_mode: "Markdown",
                    reply_markup: {
                        inline_keyboard: [
                            [{ text: m.writeBtn, callback_data: "write_message" }],
                            [{ text: "\u2b05\ufe0f Back", callback_data: "main_menu" }],
                        ],
                    },
                });
            } else if (data === "write_message") {
                await db
                    .collection("telegram_users")
                    .doc(String(chatId))
                    .set({ state: "awaiting_support_message" }, { merge: true });
                await bot.sendMessage(chatId, m.writePrompt, {
                    parse_mode: "Markdown",
                });
            } else if (data === "language") {
                await bot.sendMessage(chatId, m.languageSwitch, {
                    parse_mode: "Markdown",
                    reply_markup: languageKeyboard(),
                });
            } else if (data === "lang_en") {
                await setUserLang(chatId, "en");
                await bot.sendMessage(chatId, MESSAGES.en.languageSet, {
                    parse_mode: "Markdown",
                    reply_markup: mainMenuKeyboard("en"),
                });
            } else if (data === "lang_km") {
                await setUserLang(chatId, "km");
                await bot.sendMessage(chatId, MESSAGES.km.languageSet, {
                    parse_mode: "Markdown",
                    reply_markup: mainMenuKeyboard("km"),
                });
            } else if (data === "help") {
                await bot.sendMessage(chatId, m.help, {
                    parse_mode: "Markdown",
                    reply_markup: {
                        inline_keyboard: [
                            [{ text: "\ud83c\udfe0 Main Menu", callback_data: "main_menu" }],
                        ],
                    },
                });
            }

            res.status(200).send("OK");
            return;
        }

        // Handle text messages
        if (body.message && body.message.text) {
            const msg = body.message;
            const chatId = msg.chat.id;
            const text = msg.text.trim();
            const lang = await getUserLang(chatId);
            const m = MESSAGES[lang];

            // Save user info
            await db
                .collection("telegram_users")
                .doc(String(chatId))
                .set(
                    {
                        chatId,
                        firstName: msg.from.first_name || "",
                        lastName: msg.from.last_name || "",
                        username: msg.from.username || "",
                        lastMessageAt: admin.firestore.FieldValue.serverTimestamp(),
                    },
                    { merge: true }
                );

            // Commands
            if (text === "/start") {
                await bot.sendMessage(chatId, m.welcome, {
                    parse_mode: "Markdown",
                    reply_markup: mainMenuKeyboard(lang),
                });
            } else if (text === "/help") {
                await bot.sendMessage(chatId, m.help, { parse_mode: "Markdown" });
            } else if (text === "/faq") {
                await bot.sendMessage(chatId, m.faqTitle, {
                    parse_mode: "Markdown",
                    reply_markup: faqKeyboard(lang),
                });
            } else if (text === "/scholarships") {
                await handleScholarships(bot, chatId, lang);
            } else if (text.startsWith("/status")) {
                const parts = text.split(" ");
                if (parts.length > 1) {
                    await handleStatusCheck(bot, chatId, parts.slice(1).join(" "), lang);
                } else {
                    await bot.sendMessage(chatId, m.askStatusId, {
                        parse_mode: "Markdown",
                    });
                    await db
                        .collection("telegram_users")
                        .doc(String(chatId))
                        .set({ state: "awaiting_status_id" }, { merge: true });
                }
            } else if (text === "/contact") {
                await bot.sendMessage(chatId, m.contactMsg, {
                    parse_mode: "Markdown",
                    reply_markup: {
                        inline_keyboard: [
                            [{ text: m.writeBtn, callback_data: "write_message" }],
                        ],
                    },
                });
            } else if (text === "/language") {
                await bot.sendMessage(chatId, m.languageSwitch, {
                    parse_mode: "Markdown",
                    reply_markup: languageKeyboard(),
                });
            } else {
                // Check user state for context
                const userDoc = await db
                    .collection("telegram_users")
                    .doc(String(chatId))
                    .get();
                const userState = userDoc.exists ? userDoc.data().state : null;

                if (userState === "awaiting_status_id") {
                    await db
                        .collection("telegram_users")
                        .doc(String(chatId))
                        .set({ state: null }, { merge: true });
                    await handleStatusCheck(bot, chatId, text, lang);
                } else if (userState === "awaiting_support_message") {
                    await db
                        .collection("telegram_users")
                        .doc(String(chatId))
                        .set({ state: null }, { merge: true });
                    await handleSupportMessage(bot, chatId, msg, text, lang);
                } else {
                    // Try auto-reply
                    const autoReply = findAutoReply(text, lang);
                    if (autoReply) {
                        await bot.sendMessage(chatId, autoReply, {
                            parse_mode: "Markdown",
                            reply_markup: {
                                inline_keyboard: [
                                    [
                                        {
                                            text: "\ud83c\udfe0 Main Menu",
                                            callback_data: "main_menu",
                                        },
                                    ],
                                ],
                            },
                        });
                    } else {
                        await bot.sendMessage(chatId, m.unknownMsg, {
                            parse_mode: "Markdown",
                            reply_markup: mainMenuKeyboard(lang),
                        });
                    }
                }
            }
        }
    } catch (error) {
        console.error("Bot error:", error);
    }

    res.status(200).send("OK");
});

// =========================================================================
// SCHOLARSHIP LISTING
// =========================================================================
async function handleScholarships(bot, chatId, lang) {
    const m = MESSAGES[lang];
    try {
        const snapshot = await db
            .collection("scholarships")
            .where("isActive", "==", true)
            .orderBy("deadline", "asc")
            .limit(5)
            .get();

        if (snapshot.empty) {
            await bot.sendMessage(chatId, m.noScholarships, {
                reply_markup: {
                    inline_keyboard: [
                        [{ text: "\ud83c\udfe0 Main Menu", callback_data: "main_menu" }],
                    ],
                },
            });
            return;
        }

        let text = m.scholarshipsTitle + "\n\n";
        snapshot.docs.forEach((doc) => {
            const d = doc.data();
            const title =
                lang === "km" && d.titleKm ? d.titleKm : d.titleEn || d.title || "Untitled";
            const deadline = d.deadline
                ? new Date(
                    d.deadline.seconds ? d.deadline.seconds * 1000 : d.deadline
                ).toLocaleDateString()
                : "N/A";
            text += m.scholarshipItem
                .replace("{title}", title)
                .replace("{university}", d.university || "N/A")
                .replace("{country}", d.country || "N/A")
                .replace("{deadline}", deadline)
                .replace("{funding}", d.fundingType || "N/A");
            text += "\n";
        });

        await bot.sendMessage(chatId, text, {
            parse_mode: "Markdown",
            reply_markup: {
                inline_keyboard: [
                    [{ text: "\ud83d\udcf2 Open App", url: "https://scholarshipapp.com" }],
                    [{ text: "\ud83c\udfe0 Main Menu", callback_data: "main_menu" }],
                ],
            },
        });
    } catch (error) {
        console.error("Scholarship fetch error:", error);
        await bot.sendMessage(chatId, m.noScholarships);
    }
}

// =========================================================================
// APPLICATION STATUS CHECK
// =========================================================================
async function handleStatusCheck(bot, chatId, appId, lang) {
    const m = MESSAGES[lang];
    try {
        let doc = await db.collection("applications").doc(appId.trim()).get();

        if (!doc.exists) {
            const snapshot = await db
                .collection("applications")
                .where("applicationId", "==", appId.trim())
                .limit(1)
                .get();
            if (!snapshot.empty) doc = snapshot.docs[0];
        }

        if (!doc || !doc.exists) {
            await bot.sendMessage(chatId, m.statusNotFound, {
                parse_mode: "Markdown",
                reply_markup: {
                    inline_keyboard: [
                        [{ text: "\ud83d\udd04 Try Again", callback_data: "check_status" }],
                        [{ text: "\ud83c\udfe0 Main Menu", callback_data: "main_menu" }],
                    ],
                },
            });
            return;
        }

        const data = doc.data();
        const status = STATUS_EMOJI[data.status] || data.status || "Unknown";
        const appliedDate = data.appliedAt
            ? new Date(data.appliedAt.seconds * 1000).toLocaleDateString()
            : "N/A";
        const scholarship = data.scholarshipTitle || data.title || "N/A";

        const response = m.statusFound
            .replace("{id}", doc.id)
            .replace("{scholarship}", scholarship)
            .replace("{status}", status)
            .replace("{date}", appliedDate);

        await bot.sendMessage(chatId, response, {
            parse_mode: "Markdown",
            reply_markup: {
                inline_keyboard: [
                    [{ text: "\ud83d\udd04 Check Another", callback_data: "check_status" }],
                    [{ text: "\ud83c\udfe0 Main Menu", callback_data: "main_menu" }],
                ],
            },
        });
    } catch (error) {
        console.error("Status check error:", error);
        await bot.sendMessage(chatId, m.statusNotFound, {
            parse_mode: "Markdown",
        });
    }
}

// =========================================================================
// SUPPORT MESSAGE FORWARDING
// =========================================================================
async function handleSupportMessage(bot, chatId, msg, text, lang) {
    const m = MESSAGES[lang];
    try {
        await db.collection("support_tickets").add({
            chatId,
            firstName: msg.from.first_name || "",
            lastName: msg.from.last_name || "",
            username: msg.from.username || "",
            message: text,
            status: "open",
            platform: "telegram",
            language: lang,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            respondedAt: null,
            response: null,
        });

        await bot.sendMessage(chatId, m.agentForward, {
            parse_mode: "Markdown",
            reply_markup: {
                inline_keyboard: [
                    [{ text: "\ud83c\udfe0 Main Menu", callback_data: "main_menu" }],
                ],
            },
        });
    } catch (error) {
        console.error("Support message error:", error);
        await bot.sendMessage(chatId, m.contactMsg, { parse_mode: "Markdown" });
    }
}

// =========================================================================
// ADMIN REPLY TRIGGER
// When admin updates a support_ticket doc with a "response" field,
// this function sends that reply back to the Telegram user.
// =========================================================================
exports.replyToTicket = functions.firestore
    .document("support_tickets/{ticketId}")
    .onUpdate(async (change) => {
        const before = change.before.data();
        const after = change.after.data();

        if (!before.response && after.response && after.chatId) {
            const bot = new TelegramBot(BOT_TOKEN);
            const lang = after.language || "en";
            const m = MESSAGES[lang];

            try {
                await bot.sendMessage(
                    after.chatId,
                    m.replyFromSupport + "\n\n" + after.response,
                    {
                        parse_mode: "Markdown",
                        reply_markup: {
                            inline_keyboard: [
                                [{ text: m.writeBtn, callback_data: "write_message" }],
                                [{ text: "\ud83c\udfe0 Main Menu", callback_data: "main_menu" }],
                            ],
                        },
                    }
                );

                await change.after.ref.update({
                    status: "responded",
                    respondedAt: admin.firestore.FieldValue.serverTimestamp(),
                });
            } catch (error) {
                console.error("Reply to ticket error:", error);
            }
        }
    });

// =========================================================================
// REAL-TIME NOTIFICATIONS
// =========================================================================

/**
 * When admin creates a new scholarship → notify all app users (broadcast).
 * Writes a document to the `notifications` collection with targetUserId = null
 * so every user sees it.
 */
exports.onNewScholarship = functions.firestore
    .document("scholarships/{scholarshipId}")
    .onCreate(async (snap) => {
        const data = snap.data();
        if (!data || data.isActive === false) return;

        const titleEn = data.titleEn || data.title || "New Scholarship";
        const titleKm = data.titleKm || titleEn;
        const university = data.university || "";
        const country = data.country || "";

        try {
            await db.collection("notifications").add({
                title: `New Scholarship: ${titleEn}`,
                titleKm: `អាហារូបករណ៍ថ្មី: ${titleKm}`,
                body: `${titleEn} at ${university}${country ? ", " + country : ""} is now available. Apply before the deadline!`,
                bodyKm: `${titleKm} នៅ ${university}${country ? ", " + country : ""} ឥឡូវអាចដាក់ពាក្យបាន។ សូមដាក់ពាក្យមុនកំណត់ផុតកំណត់!`,
                type: "new_scholarship",
                targetUserId: null, // broadcast to all users
                referenceId: snap.id,
                createdAt: admin.firestore.FieldValue.serverTimestamp(),
                readBy: [],
            });
            console.log(`Notification created for new scholarship: ${titleEn}`);
        } catch (error) {
            console.error("onNewScholarship notification error:", error);
        }
    });

/**
 * When a user submits a new application → notify admins.
 * Writes a document to the `notifications` collection with type 'new_application'.
 * Admin app filters by type to show admin-relevant notifications.
 */
exports.onNewApplication = functions.firestore
    .document("applications/{applicationId}")
    .onCreate(async (snap) => {
        const data = snap.data();
        if (!data) return;

        const scholarshipTitle = data.scholarshipTitle || "Unknown";
        const university = data.university || "";
        const userId = data.userId || "";

        // Fetch the user's display name from the users collection
        let userName = "A user";
        try {
            if (userId) {
                const userDoc = await db.collection("users").doc(userId).get();
                if (userDoc.exists) {
                    const u = userDoc.data();
                    userName = u.displayName || u.name || u.email || "A user";
                }
            }
        } catch (_) { }

        try {
            await db.collection("notifications").add({
                title: `New Application: ${scholarshipTitle}`,
                titleKm: `ពាក្យសុំថ្មី: ${scholarshipTitle}`,
                body: `${userName} applied for "${scholarshipTitle}" at ${university}.`,
                bodyKm: `${userName} បានដាក់ពាក្យសុំ "${scholarshipTitle}" នៅ ${university}។`,
                type: "new_application",
                targetUserId: null, // visible to admins (admin app filters by type)
                referenceId: snap.id,
                createdAt: admin.firestore.FieldValue.serverTimestamp(),
                readBy: [],
            });
            console.log(`Notification created for new application by ${userName}`);
        } catch (error) {
            console.error("onNewApplication notification error:", error);
        }
    });

// =========================================================================
// EMAIL OTP — Send & Verify
// =========================================================================

// Nodemailer (Gmail SMTP) — set GMAIL_USER and GMAIL_APP_PASS in .env / functions config
const nodemailer = require("nodemailer");
const GMAIL_USER = process.env.GMAIL_USER;
const GMAIL_APP_PASS = process.env.GMAIL_APP_PASS;
const mailTransporter = (GMAIL_USER && GMAIL_APP_PASS)
    ? nodemailer.createTransport({ host: "smtp.gmail.com", port: 587, secure: false, auth: { user: GMAIL_USER, pass: GMAIL_APP_PASS } })
    : null;

/**
 * sendEmailOTP — callable Cloud Function
 * Generates a 6-digit code, stores in Firestore with 5-min TTL, emails it.
 *
 * Input:  { email: "user@example.com" }
 * Output: { success: true }
 */
exports.sendEmailOTP = functions.https.onCall(async (data, context) => {
    const email = (data.email || "").trim().toLowerCase();
    if (!email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
        throw new functions.https.HttpsError("invalid-argument", "Invalid email address.");
    }

    // Rate-limit: max 5 OTPs per email per hour
    const oneHourAgo = admin.firestore.Timestamp.fromMillis(Date.now() - 3600000);
    const recent = await db.collection("email_otps")
        .where("email", "==", email)
        .where("createdAt", ">", oneHourAgo)
        .get();
    if (recent.size >= 5) {
        throw new functions.https.HttpsError("resource-exhausted", "Too many OTP requests. Try again later.");
    }

    // Generate 6-digit code
    const code = String(Math.floor(100000 + Math.random() * 900000));
    const expiresAt = admin.firestore.Timestamp.fromMillis(Date.now() + 5 * 60 * 1000); // 5 minutes

    // Store in Firestore
    await db.collection("email_otps").add({
        email,
        code,
        verified: false,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        expiresAt,
    });

    // Send email via Nodemailer (Gmail SMTP)
    if (!mailTransporter) {
        console.error("Gmail credentials not configured.");
        throw new functions.https.HttpsError("failed-precondition", "Email service not configured.");
    }

    await mailTransporter.sendMail({
        from: `"NextGen Scholars" <${GMAIL_USER}>`,
        to: email,
        subject: "Your Verification Code — NextGen Scholars",
        html: `
            <div style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; max-width: 480px; margin: 0 auto; padding: 32px;">
                <div style="text-align: center; margin-bottom: 24px;">
                    <div style="display: inline-block; background: linear-gradient(135deg, #1976D2, #2196F3); border-radius: 16px; padding: 14px; margin-bottom: 12px;">
                        <span style="font-size: 28px;">🎓</span>
                    </div>
                    <h2 style="color: #1a1a2e; margin: 0;">NextGen Scholars</h2>
                </div>
                <p style="color: #555; font-size: 15px; line-height: 1.6;">
                    Your verification code is:
                </p>
                <div style="text-align: center; margin: 24px 0;">
                    <div style="display: inline-block; background: #f0f7ff; border: 2px solid #2196F3; border-radius: 12px; padding: 16px 32px; letter-spacing: 8px; font-size: 32px; font-weight: 700; color: #1976D2;">
                        ${code}
                    </div>
                </div>
                <p style="color: #888; font-size: 13px; text-align: center;">
                    This code expires in <strong>5 minutes</strong>.<br/>
                    If you didn't request this, please ignore this email.
                </p>
            </div>
        `,
    });

    console.log(`Email OTP sent to ${email}`);
    return { success: true };
});

/**
 * verifyEmailOTP — callable Cloud Function
 * Checks the code against Firestore, marks as verified.
 *
 * Input:  { email: "user@example.com", code: "123456" }
 * Output: { success: true }
 */
exports.verifyEmailOTP = functions.https.onCall(async (data, context) => {
    const email = (data.email || "").trim().toLowerCase();
    const code = (data.code || "").trim();

    if (!email || !code || code.length !== 6) {
        throw new functions.https.HttpsError("invalid-argument", "Email and 6-digit code are required.");
    }

    const now = admin.firestore.Timestamp.now();

    // Find matching, unexpired, unverified OTP
    const snapshot = await db.collection("email_otps")
        .where("email", "==", email)
        .where("code", "==", code)
        .where("verified", "==", false)
        .where("expiresAt", ">", now)
        .orderBy("expiresAt", "desc")
        .limit(1)
        .get();

    if (snapshot.empty) {
        throw new functions.https.HttpsError("not-found", "Invalid or expired OTP code.");
    }

    // Mark as verified
    await snapshot.docs[0].ref.update({ verified: true });

    console.log(`Email OTP verified for ${email}`);
    return { success: true };
});
