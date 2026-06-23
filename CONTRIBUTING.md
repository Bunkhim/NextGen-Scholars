# Contributing to Scholarship App / វិធីរួមចំណែកក្នុង Scholarship App

## How to Pull Pushed Code to Your Machine / របៀបទាញកូដដែល Push មកលើ Machine

When a teammate pushes new code to the repository, you need to **pull** those changes to keep your local copy up to date.

នៅពេលមិត្តរួមក្រុម push កូដថ្មីទៅ repository អ្នកត្រូវ **pull** ការផ្លាស់ប្ដូរទាំងនោះ ដើម្បីធ្វើឱ្យ copy ក្នុងម៉ាស៊ីនរបស់អ្នកទាន់សម័យ។

---

### Step 1: Make Sure You Have the Repository Cloned / ជំហានទី ១: ប្រាកដថាអ្នកបាន Clone Repository

If you have not cloned the project yet, run:

```bash
git clone https://github.com/ChoubKhunrithy/scholarship_app.git
cd scholarship_app
```

> បើអ្នកមិនទាន់ clone project នៅឡើយ សូម run:
>
> ```bash
> git clone https://github.com/ChoubKhunrithy/scholarship_app.git
> cd scholarship_app
> ```

---

### Step 2: Check Your Current Branch / ជំហានទី ២: ពិនិត្យ Branch បច្ចុប្បន្ន

```bash
git status
git branch
```

Make sure you are on the correct branch (usually `main`).

> ប្រាកដថាអ្នកស្ថិតនៅលើ branch ត្រឹមត្រូវ (ជាធម្មតា `main`)។

---

### Step 3: Fetch and Pull the Latest Changes / ជំហានទី ៣: Fetch និង Pull ការផ្លាស់ប្ដូរថ្មីបំផុត

```bash
# Option A – Pull directly (fetch + merge in one command)
# ជម្រើស A – Pull ផ្ទាល់ (fetch + merge ក្នុងពាក្យបញ្ជាតែមួយ)
git pull origin main

# Option B – Fetch first, then merge (more control)
# ជម្រើស B – Fetch ជាមុន រួចហើយ merge ( មានការគ្រប់គ្រងច្រើនជាង)
git fetch origin
git merge origin/main
```

> - `git pull origin main` — ទាញការផ្លាស់ប្ដូរចុងក្រោយពី branch `main` ហើយ merge ចូលក្នុង branch ក្នុងម៉ាស៊ីនរបស់អ្នក។
> - `git fetch origin` — ទាញការផ្លាស់ប្ដូរពី GitHub ប៉ុន្តែ **មិន** merge ជាមួយនឹង code ក្នុងម៉ាស៊ីនរបស់អ្នកភ្លាមៗ។
> - `git merge origin/main` — merge ការផ្លាស់ប្ដូរដែល fetch មកហើយ។

---

### Step 4: Resolve Merge Conflicts (if any) / ជំហានទី ៤: ដោះស្រាយ Merge Conflicts (បើមាន)

If Git reports conflicts, open the affected files and look for the conflict markers:

```
<<<<<<< HEAD
Your local code
=======
Incoming code from the remote
>>>>>>> origin/main
```

1. Edit the file to keep the correct code
2. Remove the conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`)
3. Stage the resolved file:

```bash
git add <filename>
```

4. Complete the merge:

```bash
git commit
```

> បើ Git រាយការ conflicts សូមបើកឯកសារដែលមាន conflict ហើយដោះស្រាយវា:
>
> ១. កែឯកសារ ដោយរក្សាទុককូដដែលត្រឹមត្រូវ
> ២. លុប conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`)
> ៣. Stage ឯកសារដែលបានដោះស្រាយ:
>
> ```bash
> git add <filename>
> ```
>
> ៤. បញ្ចប់ merge:
>
> ```bash
> git commit
> ```

---

### Step 5: Install/Update Dependencies / ជំហានទី ៥: ដំឡើង/ធ្វើបច្ចុប្បន្នភាព Dependencies

After pulling, always update your dependencies in case `pubspec.yaml` changed:

```bash
flutter pub get
```

> បន្ទាប់ពី pull ជានិច្ចសូម update dependencies ក្នុងករណីដែល `pubspec.yaml` ត្រូវបានផ្លាស់ប្ដូរ:
>
> ```bash
> flutter pub get
> ```

---

### Quick Reference / សង្ខេបរហ័ស

| Command / ពាក្យបញ្ជា | What it does / អ្វីដែលវាធ្វើ |
|---|---|
| `git clone <url>` | Copy repo to your machine / Copy repo មកម៉ាស៊ីន |
| `git pull origin main` | Pull latest changes / Pull ការផ្លាស់ប្ដូរថ្មី |
| `git fetch origin` | Download changes without merging / Download ការផ្លាស់ប្ដូរដោយមិន merge |
| `git merge origin/main` | Merge fetched changes / Merge ការផ្លាស់ប្ដូរ |
| `git status` | Show current state / បង្ហាញស្ថានភាពបច្ចុប្បន្ន |
| `git branch` | List branches / រាយ branches |
| `flutter pub get` | Update Flutter packages / ធ្វើបច្ចុប្បន្នភាព Flutter packages |

---

## How to Confirm (Review & Merge) a Pull Request / របៀប Confirm Pull Request

### Step 1: Open the Pull Request / ជំហានទី ១: បើក Pull Request

1. Go to the repository on GitHub: [github.com/ChoubKhunrithy/scholarship_app](https://github.com/ChoubKhunrithy/scholarship_app)
2. Click **"Pull requests"** tab
3. Click on the PR you want to review

> ១. ចូលទៅកាន់ repository នៅលើ GitHub: [github.com/ChoubKhunrithy/scholarship_app](https://github.com/ChoubKhunrithy/scholarship_app)
> ២. ចុចលើ tab **"Pull requests"**
> ៣. ចុចលើ PR ដែលអ្នកចង់ review

---

### Step 2: Review the Changes / ជំហានទី ២: Review ការផ្លាស់ប្ដូរ

1. Click the **"Files changed"** tab to see all code changes
2. Review each file:
   - Green lines (+) = new code added
   - Red lines (-) = code removed
3. If you have comments, click the **"+"** button on any line to leave a review comment
4. Check that the changes are correct and don't break anything

> ១. ចុចលើ tab **"Files changed"** ដើម្បីមើលការផ្លាស់ប្ដូរកូដទាំងអស់
> ២. Review ឯកសារនីមួយៗ:
>    - បន្ទាត់ពណ៌បៃតង (+) = កូដថ្មីដែលបានបន្ថែម
>    - បន្ទាត់ពណ៌ក្រហម (-) = កូដដែលបានដកចេញ
> ៣. បើមាន comment ចុចប៊ូតុង **"+"** នៅលើបន្ទាត់ណាមួយ ដើម្បីសរសេរ review comment
> ៤. ពិនិត្យថា ការផ្លាស់ប្ដូរត្រូវ ហើយមិនបង្កបញ្ហាអ្វី

---

### Step 3: Check CI Status / ជំហានទី ៣: ពិនិត្យ CI Status

1. Scroll down to the bottom of the PR page
2. Look for status checks (✅ green = passed, ❌ red = failed)
3. All checks should pass before merging

> ១. រំកិលចុះក្រោមនៅខាងចុងទំព័រ PR
> ២. រកមើល status checks (✅ បៃតង = ជោគជ័យ, ❌ ក្រហម = បរាជ័យ)
> ៣. ការត្រួតពិនិត្យទាំងអស់គួរជោគជ័យមុនពេល merge

---

### Step 4: Mark as Ready (if Draft) / ជំហានទី ៤: Mark as Ready (បើជា Draft)

If the PR is a **draft**, you need to mark it as ready first:

1. Click the **"Ready for review"** button at the bottom of the PR page

> បើ PR ជា **draft** ត្រូវ mark វាថា ready ជាមុនសិន:
> ១. ចុចប៊ូតុង **"Ready for review"** នៅខាងក្រោមទំព័រ PR

---

### Step 5: Approve the PR / ជំហានទី ៥: Approve Pull Request

1. Click the **"Files changed"** tab
2. Click the green **"Review changes"** button (top right)
3. Select **"Approve"** ✅
4. (Optional) Add a comment like "Looks good!" or "LGTM"
5. Click **"Submit review"**

> ១. ចុចលើ tab **"Files changed"**
> ២. ចុចប៊ូតុងពណ៌បៃតង **"Review changes"** (ខាងស្ដាំខាងលើ)
> ៣. ជ្រើសរើស **"Approve"** ✅
> ៤. (ជាជម្រើស) បន្ថែម comment ដូចជា "Looks good!" ឬ "LGTM"
> ៥. ចុច **"Submit review"**

---

### Step 6: Merge the PR / ជំហានទី ៦: Merge Pull Request

1. Go back to the **"Conversation"** tab
2. Click the green **"Merge pull request"** button
3. Choose a merge method:
   - **Create a merge commit** – keeps all commits (recommended)
   - **Squash and merge** – combines all commits into one
   - **Rebase and merge** – replays commits on top of base branch
4. Click **"Confirm merge"**
5. (Optional) Click **"Delete branch"** to clean up

> ១. ត្រឡប់ទៅ tab **"Conversation"**
> ២. ចុចប៊ូតុងពណ៌បៃតង **"Merge pull request"**
> ៣. ជ្រើសរើសវិធី merge:
>    - **Create a merge commit** – រក្សាទុក commits ទាំងអស់ (ណែនាំ)
>    - **Squash and merge** – បញ្ចូល commits ទាំងអស់ជាមួយ
>    - **Rebase and merge** – replay commits ពីលើ base branch
> ៤. ចុច **"Confirm merge"**
> ៥. (ជាជម្រើស) ចុច **"Delete branch"** ដើម្បីសម្អាត

---

## PR Review Checklist / បញ្ជីត្រួតពិនិត្យ PR

Before confirming any PR, make sure: / មុនពេល confirm PR ណាមួយ សូមពិនិត្យ:

- [ ] **Code review** – All changed files have been reviewed / ឯកសារដែលផ្លាស់ប្ដូរត្រូវបាន review ទាំងអស់
- [ ] **No conflicts** – The PR has no merge conflicts / PR គ្មាន merge conflicts
- [ ] **CI passes** – All automated checks pass (if any) / ការត្រួតពិនិត្យស្វ័យប្រវត្តិជោគជ័យ
- [ ] **Tested** – Changes have been tested locally or in CI / ការផ្លាស់ប្ដូរត្រូវបាន test
- [ ] **Documentation** – README or docs updated if needed / ឯកសារត្រូវបានធ្វើបច្ចុប្បន្នភាព
- [ ] **No secrets** – No API keys, passwords, or secrets in the code / គ្មាន API keys ឬ passwords ក្នុងកូដ

---

## Development Workflow / ដំណើរការអភិវឌ្ឍន៍

### Creating a New Feature / បង្កើត Feature ថ្មី

```bash
# 1. Make sure your local main is up to date / ប្រាកដថា main ក្នុងម៉ាស៊ីនរបស់អ្នកទាន់សម័យ
git checkout main
git pull origin main

# 2. Create a branch / បង្កើត branch
git checkout -b feature/my-feature

# 3. Make your changes / ធ្វើការផ្លាស់ប្ដូរ
# ... edit files ...

# 4. Stage and commit / Stage និង commit
git add .
git commit -m "feat: add my feature"

# 5. Push the branch / Push branch
git push origin feature/my-feature

# 6. Open a Pull Request on GitHub / បើក Pull Request នៅលើ GitHub
```

### Running the App Locally / ដំណើរការ App ក្នុងម៉ាស៊ីន

```bash
# Install dependencies / ដំឡើង dependencies
flutter pub get

# Run the app / ដំណើរការ app
flutter run

# Run analysis / ដំណើរការ analysis
flutter analyze
```

### Running the OTP Server / ដំណើរការ OTP Server

```bash
cd email-otp-server
npm install
npm start
```

### Deploying Cloud Functions / Deploy Cloud Functions

```bash
cd functions
npm install
firebase deploy --only functions
```

---

## Branch Naming Convention / គោលការណ៍ដាក់ឈ្មោះ Branch

| Prefix | Purpose / គោលបំណង |
|--------|---------------------|
| `feature/` | New feature / Feature ថ្មី |
| `fix/` | Bug fix / ជួសជុល bug |
| `docs/` | Documentation changes / ផ្លាស់ប្ដូរឯកសារ |
| `refactor/` | Code refactoring / Refactor កូដ |
| `hotfix/` | Urgent production fix / ជួសជុលបន្ទាន់ |

---

## Commit Message Convention / គោលការណ៍សរសេរ Commit Message

```
<type>: <short description>

Examples:
feat: add scholarship search filter
fix: resolve login OTP timeout issue
docs: update README with project structure
refactor: extract scholarship card widget
```

| Type | Description / ការពិពណ៌នា |
|------|---------------------------|
| `feat` | New feature / Feature ថ្មី |
| `fix` | Bug fix / ជួសជុល bug |
| `docs` | Documentation / ឯកសារ |
| `refactor` | Code refactoring / Refactor កូដ |
| `test` | Tests / ការ test |
| `chore` | Maintenance / ថែទាំ |
