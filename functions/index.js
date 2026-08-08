const functions = require('firebase-functions');
const admin = require('firebase-admin');
const nodemailer = require('nodemailer');

admin.initializeApp();
const db = admin.firestore();

const GMAIL_USER = process.env.GMAIL_USER || functions.config().gmail?.user;
const GMAIL_APP_PASS =
  process.env.GMAIL_APP_PASS || functions.config().gmail?.pass;

const mailTransporter =
  GMAIL_USER && GMAIL_APP_PASS
    ? nodemailer.createTransport({
        host: 'smtp.gmail.com',
        port: 587,
        secure: false,
        auth: {user: GMAIL_USER, pass: GMAIL_APP_PASS},
      })
    : null;

function getDocId(uid, token) {
  return uid + '_' + token.replace(/[^a-zA-Z0-9_-]/g, '_');
}

async function ensurePreferencesDoc(uid) {
  const doc = db.collection('notificationPreferences').doc(uid);
  const snap = await doc.get();
  if (!snap.exists) {
    const userSnap = await db.collection('users').doc(uid).get();
    const email = userSnap.exists ? userSnap.data().email || '' : '';
    await doc.set({
      pushEnabled: true,
      emailEnabled: true,
      deadlineReminders: true,
      newScholarships: true,
      email,
      deviceTokens: {},
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    return {pushEnabled: true, emailEnabled: true, deadlineReminders: true, newScholarships: true, email};
  }
  return snap.data();
}

async function sendFcmToUser(uid, title, body, data) {
  try {
    const prefSnap = await db.collection('notificationPreferences').doc(uid).get();
    if (!prefSnap.exists) return;
    const prefs = prefSnap.data();
    if (!prefs.pushEnabled) return;

    if (data.type === 'new_scholarship' && !prefs.newScholarships) return;

    const tokens = Object.keys(prefs.deviceTokens || {});
    if (tokens.length === 0) return;

    const message = {
      tokens,
      notification: {title, body},
      data,
    };

    const response = await admin.messaging().sendEachForMulticast(message);
    if (response.failureCount > 0) {
      const invalidTokens = [];
      response.responses.forEach((resp, idx) => {
        if (!resp.success && resp.error) {
          if (
            resp.error.code === 'messaging/invalid-registration-token' ||
            resp.error.code === 'messaging/registration-token-not-registered'
          ) {
            invalidTokens.push(tokens[idx]);
          }
        }
      });
      if (invalidTokens.length > 0) {
        const prefsRef = db.collection('notificationPreferences').doc(uid);
        const updatedTokens = {...prefs.deviceTokens};
        invalidTokens.forEach((t) => delete updatedTokens[t]);
        await prefsRef.update({deviceTokens: updatedTokens});
      }
    }
  } catch (e) {
    console.error('sendFcmToUser error:', e);
  }
}

async function sendEmailToUser(uid, subject, htmlBody) {
  if (!mailTransporter) return;
  try {
    const prefSnap = await db.collection('notificationPreferences').doc(uid).get();
    if (!prefSnap.exists) return;
    const prefs = prefSnap.data();
    if (!prefs.emailEnabled) return;
    if (!prefs.email) return;

    await mailTransporter.sendMail({
      from: `"NextGen Scholars" <${GMAIL_USER}>`,
      to: prefs.email,
      subject,
      html: htmlBody,
    });
  } catch (e) {
    console.error('sendEmailToUser error:', e);
  }
}

async function notifyUser(uid, title, body, data) {
  await sendFcmToUser(uid, title, body, data);
  const bnm = data.type === 'new_scholarship' ? 'New Scholarship Available' : 'Application Update';
  await sendEmailToUser(uid, bnm, `<h2>${title}</h2><p>${body}</p>`);
}

exports.registerDeviceToken = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'You must be logged in.');
  }
  const uid = context.auth.uid;
  const {token, platform} = data;
  if (!token) {
    throw new functions.https.HttpsError('invalid-argument', 'Token is required.');
  }

  const prefsRef = db.collection('notificationPreferences').doc(uid);
  const snap = await prefsRef.get();
  if (!snap.exists) {
    await ensurePreferencesDoc(uid);
  }

  await prefsRef.set(
    {
      deviceTokens: {
        [token]: {
          platform: platform || 'android',
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        },
      },
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    },
    {merge: true},
  );

  return {success: true};
});

exports.getNotificationPreferences = functions.https.onCall(async (_data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'You must be logged in.');
  }
  const uid = context.auth.uid;
  const prefs = await ensurePreferencesDoc(uid);
  return {
    pushEnabled: prefs.pushEnabled ?? true,
    emailEnabled: prefs.emailEnabled ?? true,
    deadlineReminders: prefs.deadlineReminders ?? true,
    newScholarships: prefs.newScholarships ?? true,
    email: prefs.email || '',
  };
});

exports.updateNotificationPreferences = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'You must be logged in.');
  }
  const uid = context.auth.uid;
  const allowed = ['pushEnabled', 'emailEnabled', 'deadlineReminders', 'newScholarships', 'email'];
  const update = {};
  for (const key of allowed) {
    if (data[key] !== undefined) {
      update[key] = data[key];
    }
  }
  if (Object.keys(update).length === 0) {
    throw new functions.https.HttpsError('invalid-argument', 'No valid fields to update.');
  }

  update.updatedAt = admin.firestore.FieldValue.serverTimestamp();
  await db.collection('notificationPreferences').doc(uid).set(update, {merge: true});

  return {success: true};
});

exports.pushNewScholarship = functions.firestore
  .document('scholarships/{scholarshipId}')
  .onCreate(async (snap) => {
    const data = snap.data();
    const titleEn = data.titleEn || data.title || 'New Scholarship';
    const bodyEn = data.university
      ? `New scholarship at ${data.university} in ${data.country || ''}`
      : 'A new scholarship is now available.';

    const userPrefsSnap = await db.collection('notificationPreferences').get();
    const promises = [];
    userPrefsSnap.forEach((doc) => {
      const uid = doc.id;
      const prefs = doc.data();
      if (prefs.pushEnabled && prefs.newScholarships) {
        promises.push(
          sendFcmToUser(
            uid,
            `New Scholarship: ${titleEn}`,
            bodyEn,
            {type: 'new_scholarship', referenceId: snap.id},
          ),
        );
      }
      if (prefs.emailEnabled && prefs.newScholarships && prefs.email) {
        promises.push(
          sendEmailToUser(
            uid,
            `New Scholarship: ${titleEn}`,
            `<h2>${titleEn}</h2><p>${bodyEn}</p>`,
          ),
        );
      }
    });
    await Promise.allSettled(promises);
  });

exports.pushNewApplication = functions.firestore
  .document('applications/{applicationId}')
  .onCreate(async (snap) => {
    const data = snap.data();
    const userId = data.userId;
    const title = data.scholarshipTitle || data.title || 'Scholarship';

    await db.collection('notifications').add({
      title: 'Application Submitted',
      titleKm: 'បានដាក់ពាក្យរួចរាល់',
      body: `Your application for "${title}" has been received.`,
      bodyKm: `ពាក្យសុំរបស់អ្នកសម្រាប់ "${title}" ត្រូវបានទទួលហើយ។`,
      type: 'new_application',
      targetUserId: userId,
      referenceId: snap.id,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      readBy: [],
      dismissedBy: [],
    });

    if (userId) {
      await sendFcmToUser(
        userId,
        'Application Submitted',
        `Your application for "${title}" has been received.`,
        {type: 'application_status', referenceId: snap.id},
      );
    }
  });

exports.pushApplicationUpdate = functions.firestore
  .document('applications/{applicationId}')
  .onUpdate(async (change) => {
    const before = change.before.data();
    const after = change.after.data();
    if (!before || !after) return;
    if (before.status === after.status) return;

    const userId = after.userId;
    if (!userId) return;

    const statusMap = {
      pending: 'Pending',
      reviewing: 'Under Review',
      accepted: 'Accepted',
      rejected: 'Not Selected',
      interview: 'Interview Scheduled',
    };
    const statusMapKm = {
      pending: 'កំពុងរង់ចាំ',
      reviewing: 'កំពុងពិនិត្យ',
      accepted: 'បានទទួល',
      rejected: 'មិនត្រូវបានជ្រើសរើស',
      interview: 'បានកំណត់ពេលសម្ភាសន៍',
    };
    const statusEn = statusMap[after.status] || after.status;
    const statusKm = statusMapKm[after.status] || after.status;
    const title = after.scholarshipTitle || after.title || 'Application';

    await db.collection('notifications').add({
      title: `Application ${statusEn}`,
      titleKm: `ពាក្យសុំ ${statusKm}`,
      body: `Your application for "${title}" is now: ${statusEn}`,
      bodyKm: `ពាក្យសុំរបស់អ្នកសម្រាប់ "${title}" ឥឡូវនេះ: ${statusKm}`,
      type: 'application_status',
      targetUserId: userId,
      referenceId: change.after.id,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      readBy: [],
      dismissedBy: [],
    });

    await notifyUser(
      userId,
      `Application ${statusEn}`,
      `Your application for "${title}" is now: ${statusEn}`,
      {type: 'application_status', referenceId: change.after.id},
    );
  });

exports.sendDeadlineReminders = functions.pubsub
  .schedule('0 8 * * *')
  .timeZone('Asia/Phnom_Penh')
  .onRun(async () => {
    const now = admin.firestore.Timestamp.now();
    const threeDaysFromNow = new Date(now.toMillis() + 3 * 24 * 60 * 60 * 1000);
    const threeDaysTs = admin.firestore.Timestamp.fromDate(threeDaysFromNow);

    const snap = await db
      .collection('scholarships')
      .where('isActive', '==', true)
      .where('deadline', '>', now)
      .where('deadline', '<=', threeDaysTs)
      .get();

    if (snap.empty) return;

    const userPrefsSnap = await db.collection('notificationPreferences').get();

    for (const doc of snap.docs) {
      const scholarship = doc.data();
      const deadlineDate = scholarship.deadline.toDate().toLocaleDateString('en-US', {
        year: 'numeric',
        month: 'long',
        day: 'numeric',
      });
      const titleEn = scholarship.titleEn || scholarship.title || 'Scholarship';
      const titleKm = scholarship.titleKm || '';

      const promises = [];
      userPrefsSnap.forEach((prefDoc) => {
        const uid = prefDoc.id;
        const prefs = prefDoc.data();
        if (!prefs.deadlineReminders) return;

        if (prefs.pushEnabled) {
          promises.push(
            sendFcmToUser(
              uid,
              `Deadline Approaching: ${titleEn}`,
              `The deadline for "${titleEn}" is on ${deadlineDate}. Apply now!`,
              {type: 'deadline_reminder', referenceId: doc.id},
            ),
          );
        }
        if (prefs.emailEnabled && prefs.email) {
          promises.push(
            sendEmailToUser(
              uid,
              `Deadline Approaching: ${titleEn}`,
              `<h2>${titleEn}</h2><p>The deadline for this scholarship is on <strong>${deadlineDate}</strong>.</p><p>Don't miss out — apply now!</p>`,
            ),
          );
        }
      });

      await db.collection('notifications').add({
        title: `Deadline Approaching: ${titleEn}`,
        titleKm: `ជិតផុតកំណត់: ${titleKm}`,
        body: `The deadline for "${titleEn}" is on ${deadlineDate}. Apply now!`,
        bodyKm: `កាលបរិច្ឆេទផុតកំណត់សម្រាប់ "${titleKm}" គឺ ${deadlineDate}។ សូមដាក់ពាក្យឥឡូវនេះ!`,
        type: 'deadline_reminder',
        targetUserId: null,
        referenceId: doc.id,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        readBy: [],
        dismissedBy: [],
      });

      await Promise.allSettled(promises);
    }
  });
