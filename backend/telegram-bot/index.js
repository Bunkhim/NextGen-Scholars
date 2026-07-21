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
            "🎓 *Welcome to Scholarship App Support!*\n\n" +
            "I'm your virtual assistant. I can help you with:\n\n" +
            "📚 Browse scholarships\n" +
            "📋 Check application status\n" +
            "❓ Answer common questions\n" +
            "💬 Connect you with our support team\n\n" +
            "Use the menu below or type a question!",
        help:
            "📖 *Available Commands:*\n\n" +
            "/start – Welcome & main menu\n" +
            "/faq – Frequently Asked Questions\n" +
            "/scholarships – Browse latest scholarships\n" +
            "/status `<app_id>` – Check application status\n" +
            "/contact – Contact support team\n" +
            "/language – Switch language\n" +
            "/help – Show this message",
        faqTitle: "❓ *Frequently Asked Questions*\n\nSelect a topic:",
        faq: [
            {
                q: "How do I apply for a scholarship?",
                a:
                    "1️⃣ Open the Scholarship App\n" +
                    "2️⃣ Browse scholarships on Discover\n" +
                    "3️⃣ Tap a scholarship to view details\n" +
                    "4️⃣ Click \"Apply Now\"\n" +
                    "5️⃣ Complete your profile if needed\n\n" +
                    "✅ Make sure your profile is complete before applying!",
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
                    "Go to *Profile → My Applications*. You'll see all your applications with status:\n\n" +
                    "🟡 Pending – Under review\n" +
                    "🟢 Accepted – Congratulations!\n" +
                    "🔴 Rejected – Try other scholarships\n" +
                    "🟣 Interview – Check your email",
            },
            {
                q: "How do I update my profile?",
                a:
                    "Go to *Profile → Edit Profile*. You can update your personal info, " +
                    "photo, education details, and interests.",
            },
            {
                q: "What if my application is rejected?",
                a:
                    "Don't give up! 💪\n\n" +
                    "• Review the scholarship requirements\n" +
                    "• Improve your profile\n" +
                    "• Apply to other scholarships\n" +
                    "• New scholarships are added regularly!",
            },
        ],
        contactMsg:
            "💬 *Contact Our Support Team*\n\n" +
            "📧 Email: choubkhunrithy@gmail.com\n" +
            "📞 Phone: +855 31 228 7763\n" +
            "🕐 Hours: Mon-Fri, 8AM - 5PM (Cambodia Time)\n\n" +
            "Or type your message here and our team will respond!",
        agentForward:
            "✅ Your message has been forwarded to our support team. " +
            "We'll respond within 24 hours.\n\n" +
            "Email choubkhunrithy@gmail.com for urgent matters.",
        statusNotFound:
            "❌ Application not found. Please check your Application ID.\n\n" +
            "Find it in: *Profile → My Applications → Details*",
        statusFound:
            "📋 *Application Status*\n\n" +
            "🆔 ID: `{id}`\n" +
            "📚 Scholarship: {scholarship}\n" +
            "📊 Status: {status}\n" +
            "📅 Applied: {date}",
        noScholarships: "No active scholarships found. Check back soon! 🔔",
        scholarshipItem:
            "🎓 *{title}*\n🏫 {university}\n🌍 {country}\n" +
            "📅 Deadline: {deadline}\n💰 {funding}\n",
        scholarshipsTitle:
            "📚 *Latest Scholarships*\n\nHere are the latest opportunities:",
        languageSwitch: "🌐 *Choose your language:*",
        languageSet: "✅ Language set to *English*",
        unknownMsg:
            "🤔 I'm not sure I understand. Here's what I can help with:\n\n" +
            "• Type /faq for common questions\n" +
            "• Type /scholarships to browse\n" +
            "• Type /contact to reach our team\n\n" +
            "Or simply type your question!",
        mainMenu: "📋 *Main Menu*\n\nWhat would you like to do?",
        btnFaq: "❓ FAQ",
        btnScholarships: "📚 Scholarships",
        btnStatus: "📊 Check Status",
        btnContact: "💬 Contact",
        btnLanguage: "🌐 Language",
        btnHelp: "❓ Help",
        askStatusId:
            "Please send your *Application ID*.\n\n" +
            "Find it in: *Profile → My Applications → Details*",
        writePrompt: "✍️ Please type your message...",
        writeBtn: "✍️ Write a message",
        replyFromSupport: "📩 *Reply from Support Team:*",
    },
    km: {
        welcome:
            "🎓 *សូមស្វាគមន៍មកកាន់ Scholarship App Support!*\n\n" +
            "ខ្ញុំជាជំនួយការនិម្មិត។ ខ្ញុំអាចជួយអ្នកក្នុង:\n\n" +
            "📚 រុករកអាហារូបករណ៍\n" +
            "📋 ពិនិត្យស្ថានភាពពាក្យសុំ\n" +
            "❓ ឆ្លើយសំណួរទូទៅ\n" +
            "💬 ភ្ជាប់អ្នកជាមួយក្រុមជំនួយ\n\n" +
            "សូមប្រើមឺនុយខាងក្រោម ឬវាយសំណួរ!",
        help:
            "📖 *ពាក្យបញ្ជាដែលមាន:*\n\n" +
            "/start – សូមស្វាគមន៍ និងមឺនុយ\n" +
            "/faq – សំណួរដែលសួរជារឿយៗ\n" +
            "/scholarships – រុករកអាហារូបករណ៍\n" +
            "/status `<app_id>` – ពិនិត្យស្ថានភាពពាក្យ\n" +
            "/contact – ទាក់ទងក្រុមជំនួយ\n" +
            "/language – ប្តូរភាសា\n" +
            "/help – បង្ហាញសារនេះ",
        faqTitle:
            "❓ *សំណួរដែលសួរជារឿយៗ*\n\nជ្រើសរើសប្រធានបទ:",
        faq: [
            {
                q: "តើខ្ញុំដាក់ពាក្យសុំអាហារូបករណ៍ដោយរបៀបណា?",
                a:
                    "1️⃣ បើកកម្មវិធី Scholarship App\n" +
                    "2️⃣ រុករកអាហារូបករណ៍នៅទំព័រស្វែងរក\n" +
                    "3️⃣ ចុចលើអាហារូបករណ៍ដើម្បីមើលព័ត៌មានលម្អិត\n" +
                    "4️⃣ ចុច \"ដាក់ពាក្យឥឡូវ\"\n" +
                    "5️⃣ បំពេញប្រវត្តិរូបប្រសិនបើចាំបាច់\n\n" +
                    "✅ សូមប្រាកដថាប្រវត្តិរូបពេញលេញមុនពេលដាក់ពាក្យ!",
            },
            {
                q: "តើខ្ញុំអាចដាក់ពាក្យអាហារូបករណ៍ច្រើនបានទេ?",
                a:
                    "បាន! អ្នកអាចដាក់ពាក្យអាហារូបករណ៍ច្រើនតាមដែលអ្នកមានលក្ខណៈគ្រប់គ្រាន់។ " +
                    "ពាក្យសុំនីមួយៗត្រូវបានតាមដានដាច់ដោយឡែក។",
            },
            {
                q: "តើខ្ញុំតាមដានស្ថានភាពពាក្យសុំដោយរបៀបណា?",
                a:
                    "ទៅកាន់ *ប្រវត្តិរូប → ពាក្យសុំរបស់ខ្ញុំ*។ អ្នកនឹងឃើញពាក្យសុំទាំងអស់ជាមួយស្ថានភាព:\n\n" +
                    "🟡 កំពុងរង់ចាំ – កំពុងពិនិត្យ\n" +
                    "🟢 ទទួលយក – សូមអបអរសាទរ!\n" +
                    "🔴 មិនត្រូវជ្រើស – សូមព្យាយាមអាហារូបករណ៍ផ្សេង\n" +
                    "🟣 សម្ភាសន៍ – ពិនិត្យអ៊ីមែល",
            },
            {
                q: "តើខ្ញុំធ្វើបច្ចុប្បន្នភាពប្រវត្តិរូបដោយរបៀបណា?",
                a:
                    "ទៅកាន់ *ប្រវត្តិរូប → កែប្រវត្តិរូប*។ " +
                    "អ្នកអាចធ្វើបច្ចុប្បន្នភាពព័ត៌មានផ្ទាល់ខ្លួន រូបថត និងវិស័យដែលចាប់អារម្មណ៍។",
            },
            {
                q: "តើខ្ញុំគួរធ្វើអ្វីប្រសិនបើពាក្យសុំមិនត្រូវជ្រើស?",
                a:
                    "កុំខកចិត្ត! 💪\n\n" +
                    "• ពិនិត្យមើលតម្រូវការអាហារូបករណ៍\n" +
                    "• កែលម្អប្រវត្តិរូបរបស់អ្នក\n" +
                    "• ដាក់ពាក្យអាហារូបករណ៍ផ្សេងទៀត\n" +
                    "• អាហារូបករណ៍ថ្មីត្រូវបានបន្ថែមជានិច្ច!",
            },
        ],
        contactMsg:
            "💬 *ទាក់ទងក្រុមជំនួយរបស់យើង*\n\n" +
            "📧 អ៊ីមែល: choubkhunrithy@gmail.com\n" +
            "📞 ទូរស័ព្ទ: +855 31 228 7763\n" +
            "🕐 ម៉ោង: ច័ន្ទ-សុក្រ, 8AM - 5PM\n\n" +
            "ឬវាយសាររបស់អ្នកនៅទីនេះ ហើយក្រុមនឹងឆ្លើយតប!",
        agentForward:
            "✅ សាររបស់អ្នកត្រូវបានផ្ញើទៅក្រុមជំនួយរបស់យើងហើយ។ " +
            "យើងនឹងឆ្លើយតបក្នុងរយៈពេល 24 ម៉ោង!\n\n" +
            "អ៊ីមែលមក choubkhunrithy@gmail.com សម្រាប់រឿងប្រាប់។",
        statusNotFound:
            "❌ រកមិនឃើញពាក្យសុំ។ សូមពិនិត្យលេខសម្គាល់ពាក្យសុំរបស់អ្នក។\n\n" +
            "រកវានៅ: *ប្រវត្តិរូប → ពាក្យសុំរបស់ខ្ញុំ → ព័ត៌មានលម្អិត*",
        statusFound:
            "📋 *ស្ថានភាពពាក្យសុំ*\n\n" +
            "🆔 លេខ: `{id}`\n" +
            "📚 អាហារូបករណ៍: {scholarship}\n" +
            "📊 ស្ថានភាព: {status}\n" +
            "📅 ថ្ងៃដាក់ពាក្យ: {date}",
        noScholarships:
            "មិនមានអាហារូបករណ៍សកម្មនៅពេលនេះ។ សូមពិនិត្យមើលម្តងទៀត! 🔔",
        scholarshipItem:
            "🎓 *{title}*\n🏫 {university}\n🌍 {country}\n" +
            "📅 កំណត់ផុតកំណត់: {deadline}\n💰 {funding}\n",
        scholarshipsTitle:
            "📚 *អាហារូបករណ៍ថ្មីៗ*\n\nនេះគឺជាអាហារូបករណ៍ថ្មីៗ:",
        languageSwitch: "🌐 *ជ្រើសរើសភាសារបស់អ្នក:*",
        languageSet:
            "✅ ភាសាត្រូវបានកំណត់ជា *ភាសាខ្មែរ*",
        unknownMsg:
            "🤔 ខ្ញុំមិនច្បាស់។ នេះគឺអ្វីដែលខ្ញុំអាចជួយ:\n\n" +
            "• វាយ /faq សម្រាប់សំណួរទូទៅ\n" +
            "• វាយ /scholarships ដើម្បីរុករក\n" +
            "• វាយ /contact ដើម្បីទាក់ទងក្រុម\n\n" +
            "ឬវាយសំណួររបស់អ្នក ហើយខ្ញុំនឹងព្យាយាមជួយ!",
        mainMenu:
            "📋 *មឺនុយជាច្រើស*\n\nតើអ្នកចង់ធ្វើអ្វី?",
        btnFaq: "❓ សំណួរជារឿយៗ",
        btnScholarships: "📚 អាហារូបករណ៍",
        btnStatus:
            "📊 ពិនិត្យស្ថានភាព",
        btnContact: "💬 ទាក់ទង",
        btnLanguage: "🌐 ភាសា",
        btnHelp: "❓ ជំនួយ",
        askStatusId:
            "សូមផ្ញើ *លេខសម្គាល់ពាក្យសុំ*។\n\n" +
            "រកវានៅ: *ប្រវត្តិរូប → ពាក្យសុំរបស់ខ្ញុំ → ព័ត៌មានលម្អិត*",
        writePrompt:
            "✍️ សូមវាយសាររបស់អ្នក...",
        writeBtn:
            "✍️ សរសេរសារ",
        replyFromSupport:
            "📩 *ឆ្លើយតបពីក្រុមជំនួយ:*",
    },
};

// Status emoji mapping
const STATUS_EMOJI = {
    pending: "🟡 Pending",
    reviewing: "🔵 Under Review",
    accepted: "🟢 Accepted",
    rejected: "🔴 Not Selected",
    interview: "🟣 Interview",
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
    rows.push([{ text: "⬅️ Back", callback_data: "main_menu" }]);
    return { inline_keyboard: rows };
}

function languageKeyboard() {
    return {
        inline_keyboard: [
            [
                { text: "🇬🇧 English", callback_data: "lang_en" },
                {
                    text: "🇰🇭 ភាសាខ្មែរ",
                    callback_data: "lang_km",
                },
            ],
            [{ text: "⬅️ Back", callback_data: "main_menu" }],
        ],
    };
}

// Smart keyword auto-reply
function findAutoReply(text, lang) {
    const lower = text.toLowerCase();
    const rules = [
        {
            patterns: ["how to apply", "apply", "ដាក់ពាក្យ"],
            faqIndex: 0,
        },
        {
            patterns: ["multiple", "many", "ច្រើន"],
            faqIndex: 1,
        },
        {
            patterns: ["track", "status", "ស្ថានភាព", "តាមដាន"],
            faqIndex: 2,
        },
        {
            patterns: ["profile", "update", "edit", "ប្រវត្តិរូប", "កែ"],
            faqIndex: 3,
        },
        {
            patterns: ["reject", "not selected", "failed", "មិនត្រូវជ្រើស"],
            faqIndex: 4,
        },
    ];

    for (const rule of rules) {
        if (rule.patterns.some((p) => lower.includes(p))) {
            return MESSAGES[lang].faq[rule.faqIndex].a;
        }
    }

    // Greetings
    const greetings = ["hello", "hi", "hey", "good morning", "សួស្តី"];
    if (greetings.some((g) => lower.includes(g))) {
        return lang === "km"
            ? "👋 សួស្តី! តើខ្ញុំអាចជួយអ្វីអ្នកនៅថ្ងៃនេះ?"
            : "👋 Hello! How can I help you today?";
    }

    // Thanks
    const thanks = ["thank", "thanks", "អរគុណ"];
    if (thanks.some((t) => lower.includes(t))) {
        return lang === "km"
            ? "😊 អរគុណ! សូមសួរប្រសិនបើអ្នកត្រូវការអ្វីផ្សេងទៀត។"
            : "😊 You're welcome! Feel free to ask if you need anything else.";
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
                                [{ text: "⬅️ Back to FAQ", callback_data: "faq" }],
                                [{ text: "🏠 Main Menu", callback_data: "main_menu" }],
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
                            [{ text: "⬅️ Back", callback_data: "main_menu" }],
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
                            [{ text: "⬅️ Back", callback_data: "main_menu" }],
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
                            [{ text: "🏠 Main Menu", callback_data: "main_menu" }],
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
                                            text: "🏠 Main Menu",
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
                        [{ text: "🏠 Main Menu", callback_data: "main_menu" }],
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
                    [{ text: "📲 Open App", url: "https://scholarshipapp.com" }],
                    [{ text: "🏠 Main Menu", callback_data: "main_menu" }],
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
                        [{ text: "🔄 Try Again", callback_data: "check_status" }],
                        [{ text: "🏠 Main Menu", callback_data: "main_menu" }],
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
                    [{ text: "🔄 Check Another", callback_data: "check_status" }],
                    [{ text: "🏠 Main Menu", callback_data: "main_menu" }],
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
                    [{ text: "🏠 Main Menu", callback_data: "main_menu" }],
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
                                [{ text: "🏠 Main Menu", callback_data: "main_menu" }],
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
