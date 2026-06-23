require('dotenv').config();
const express = require("express");
const cors = require("cors");
const admin = require("firebase-admin");

// ── Firebase Admin Init ─────────────────────────────────────────────────────
const serviceAccountJson = process.env.FIREBASE_SERVICE_ACCOUNT;
if (!serviceAccountJson) {
    console.error("FIREBASE_SERVICE_ACCOUNT env var is required.");
    process.exit(1);
}
const serviceAccount = JSON.parse(serviceAccountJson);
admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
const db = admin.firestore();

// ── Brevo (Sendinblue) HTTP API ─────────────────────────────────────────────
// Set BREVO_API_KEY env var on Render (get it from https://app.brevo.com → SMTP & API → API Keys)
const BREVO_API_KEY = process.env.BREVO_API_KEY;
if (!BREVO_API_KEY) {
    console.error("BREVO_API_KEY env var is required.");
    process.exit(1);
}

async function sendEmailViaBrevo(to, subject, htmlContent) {
    const response = await fetch("https://api.brevo.com/v3/smtp/email", {
        method: "POST",
        headers: {
            "accept": "application/json",
            "api-key": BREVO_API_KEY,
            "content-type": "application/json",
        },
        body: JSON.stringify({
            sender: { name: "NextGen Scholars", email: "choubkhunrithy@gmail.com" },
            to: [{ email: to }],
            subject,
            htmlContent,
        }),
    });
    if (!response.ok) {
        const err = await response.text();
        throw new Error(`Brevo API error ${response.status}: ${err}`);
    }
    return response.json();
}

// ── Express App ─────────────────────────────────────────────────────────────
const app = express();
app.use(cors());
app.use(express.json());

// Health check
app.get("/", (_req, res) => {
    res.json({ status: "ok", service: "Scholarship Email & SMS OTP" });
});

// ═══════════════════════════════════════════════════════════════════════════
// POST /api/send-otp
// Body: { "email": "user@example.com" }
// ═══════════════════════════════════════════════════════════════════════════
app.post("/api/send-otp", async (req, res) => {
    try {
        const email = (req.body.email || "").trim().toLowerCase();

        // Validate email
        if (!email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
            return res.status(400).json({ error: "Invalid email address." });
        }

        // Rate-limit: max 5 OTPs per email per hour (simple query, filter in code)
        const recent = await db
            .collection("email_otps")
            .where("email", "==", email)
            .get();

        const oneHourAgo = Date.now() - 3600000;
        const recentCount = recent.docs.filter((doc) => {
            const ts = doc.data().createdAt;
            return ts && ts.toMillis() > oneHourAgo;
        }).length;

        if (recentCount >= 5) {
            return res
                .status(429)
                .json({ error: "Too many OTP requests. Try again later." });
        }

        // Generate 6-digit code
        const code = String(Math.floor(100000 + Math.random() * 900000));
        const expiresAt = admin.firestore.Timestamp.fromMillis(
            Date.now() + 5 * 60 * 1000
        );

        // Store in Firestore
        await db.collection("email_otps").add({
            email,
            code,
            verified: false,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            expiresAt,
        });

        // Send email via Brevo HTTP API
        await sendEmailViaBrevo(email, "Your Verification Code — NextGen Scholars", `
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
      `);

        console.log(`OTP sent to ${email}`);
        return res.json({ success: true });
    } catch (err) {
        console.error("send-otp error:", err.message, err.stack);
        return res.status(500).json({ error: `Internal server error: ${err.message}` });
    }
});

// ═══════════════════════════════════════════════════════════════════════════
// POST /api/verify-otp
// Body: { "email": "user@example.com", "code": "123456" }
// ═══════════════════════════════════════════════════════════════════════════
app.post("/api/verify-otp", async (req, res) => {
    try {
        const email = (req.body.email || "").trim().toLowerCase();
        const code = (req.body.code || "").trim();

        if (!email || !code || code.length !== 6) {
            return res
                .status(400)
                .json({ error: "Email and 6-digit code are required." });
        }

        const now = admin.firestore.Timestamp.now();

        // Find matching, unverified OTP (simple query, check expiry in code)
        const snapshot = await db
            .collection("email_otps")
            .where("email", "==", email)
            .where("code", "==", code)
            .where("verified", "==", false)
            .get();

        // Filter for non-expired entries
        const validDoc = snapshot.docs.find((doc) => {
            const data = doc.data();
            return data.expiresAt && data.expiresAt.toMillis() > Date.now();
        });

        if (!validDoc) {
            return res.status(404).json({ error: "Invalid or expired OTP code." });
        }

        // Mark as verified
        await validDoc.ref.update({ verified: true });

        console.log(`OTP verified for ${email}`);
        return res.json({ success: true });
    } catch (err) {
        console.error("verify-otp error:", err);
        return res.status(500).json({ error: "Internal server error." });
    }
});

// ═══════════════════════════════════════════════════════════════════════════
// POST /api/send-sms-otp
// Body: { "phone": "+85531228xxxx" }
// ═══════════════════════════════════════════════════════════════════════════
app.post("/api/send-sms-otp", async (req, res) => {
    try {
        const phone = (req.body.phone || "").trim();

        // Validate phone (must start with + and have at least 8 digits)
        if (!phone || !/^\+\d{8,15}$/.test(phone)) {
            return res.status(400).json({ error: "Invalid phone number." });
        }

        // Rate-limit: max 5 OTPs per phone per hour
        const recent = await db
            .collection("sms_otps")
            .where("phone", "==", phone)
            .get();

        const oneHourAgo = Date.now() - 3600000;
        const recentCount = recent.docs.filter((doc) => {
            const ts = doc.data().createdAt;
            return ts && ts.toMillis() > oneHourAgo;
        }).length;

        if (recentCount >= 5) {
            return res
                .status(429)
                .json({ error: "Too many OTP requests. Try again later." });
        }

        // Generate 6-digit code
        const code = String(Math.floor(100000 + Math.random() * 900000));
        const expiresAt = admin.firestore.Timestamp.fromMillis(
            Date.now() + 5 * 60 * 1000
        );

        // Store in Firestore
        await db.collection("sms_otps").add({
            phone,
            code,
            verified: false,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            expiresAt,
        });

        // Send SMS via Brevo Transactional SMS API
        const smsResponse = await fetch("https://api.brevo.com/v3/transactionalSMS/sms", {
            method: "POST",
            headers: {
                "accept": "application/json",
                "api-key": BREVO_API_KEY,
                "content-type": "application/json",
            },
            body: JSON.stringify({
                type: "transactional",
                unicodeEnabled: true,
                sender: "NextGenSch",
                recipient: phone,
                content: `Your NextGen Scholars verification code is: ${code}. Valid for 5 minutes.`,
            }),
        });

        if (!smsResponse.ok) {
            const err = await smsResponse.text();
            console.error(`Brevo SMS API error ${smsResponse.status}: ${err}`);
            return res.status(500).json({ error: "Failed to send SMS. Please try again." });
        }

        console.log(`SMS OTP sent to ${phone}`);
        return res.json({ success: true });
    } catch (err) {
        console.error("send-sms-otp error:", err.message, err.stack);
        return res.status(500).json({ error: `Internal server error: ${err.message}` });
    }
});

// ═══════════════════════════════════════════════════════════════════════════
// POST /api/verify-sms-otp
// Body: { "phone": "+85531228xxxx", "code": "123456" }
// ═══════════════════════════════════════════════════════════════════════════
app.post("/api/verify-sms-otp", async (req, res) => {
    try {
        const phone = (req.body.phone || "").trim();
        const code = (req.body.code || "").trim();

        if (!phone || !code || code.length !== 6) {
            return res
                .status(400)
                .json({ error: "Phone and 6-digit code are required." });
        }

        // Find matching, unverified OTP
        const snapshot = await db
            .collection("sms_otps")
            .where("phone", "==", phone)
            .where("code", "==", code)
            .where("verified", "==", false)
            .get();

        // Filter for non-expired entries
        const validDoc = snapshot.docs.find((doc) => {
            const data = doc.data();
            return data.expiresAt && data.expiresAt.toMillis() > Date.now();
        });

        if (!validDoc) {
            return res.status(404).json({ error: "Invalid or expired OTP code." });
        }

        // Mark as verified
        await validDoc.ref.update({ verified: true });

        console.log(`SMS OTP verified for ${phone}`);
        return res.json({ success: true });
    } catch (err) {
        console.error("verify-sms-otp error:", err);
        return res.status(500).json({ error: "Internal server error." });
    }
});

// ═══════════════════════════════════════════════════════════════════════════
// POST /api/reset-password
// Body: { "email": "user@example.com", "newPassword": "NewPass@123" }
// Uses Firebase Admin SDK to update the user's password directly.
// ═══════════════════════════════════════════════════════════════════════════
app.post("/api/reset-password", async (req, res) => {
    try {
        const email = (req.body.email || "").trim().toLowerCase();
        const newPassword = (req.body.newPassword || "").trim();

        if (!email || !newPassword) {
            return res.status(400).json({ error: "Email and newPassword are required." });
        }
        if (newPassword.length < 8) {
            return res.status(400).json({ error: "Password must be at least 8 characters." });
        }

        // Look up Firebase Auth user by email
        let userRecord;
        try {
            userRecord = await admin.auth().getUserByEmail(email);
        } catch (err) {
            if (err.code === "auth/user-not-found") {
                return res.status(404).json({ error: "No account found with this email." });
            }
            throw err;
        }

        // Update password via Admin SDK (no re-authentication required)
        await admin.auth().updateUser(userRecord.uid, { password: newPassword });

        console.log(`Password reset for ${email}`);
        return res.json({ success: true });
    } catch (err) {
        console.error("reset-password error:", err.message, err.stack);
        return res.status(500).json({ error: `Internal server error: ${err.message}` });
    }
});

// ── Start Server ────────────────────────────────────────────────────────────
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Email & SMS OTP server running on port ${PORT}`);
});
