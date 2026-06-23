/// ============================================================
/// ALL USER-VISIBLE TEXT STRINGS — Scholarship App
/// Organized by source file with descriptive camelCase keys.
/// ============================================================
library;

class AppStrings {
  AppStrings._();

  // ────────────────────────────────────────────────────────────
  // 1. main.dart
  // ────────────────────────────────────────────────────────────
  static const String appTitle = 'NextGen Scholars';

  // ────────────────────────────────────────────────────────────
  // 2. splash_screen.dart — NO user-visible strings
  // ────────────────────────────────────────────────────────────

  // ────────────────────────────────────────────────────────────
  // 3. onboarding_screen.dart
  // ────────────────────────────────────────────────────────────
  // Page titles
  static const String onboardingTitle1 = 'Welcome to NextGen Scholars';
  static const String onboardingTitle2 = 'Discovered';
  static const String onboardingTitle3 = 'Join us now';
  // Page descriptions
  static const String onboardingDescription1 =
      'Discover new learning opportunities and connect with fellow scholarship holders to enhance your educational journey!';
  static const String onboardingDescription2 =
      'Unlock the full potential of your learning with personalized recommendations, progress tracking, and a vibrant community!';
  static const String onboardingDescription3 =
      'Join us today and start your learning journey. Our easy to use platform is designed to help you succeed!';
  // Buttons
  static const String onboardingNextButton = 'Next';
  static const String onboardingGetStartedButton = 'Get Started';

  // ────────────────────────────────────────────────────────────
  // 4. login_screen.dart
  // ────────────────────────────────────────────────────────────
  // Header
  static const String loginWelcomeTitle = 'Welcome Back!';
  static const String loginSubtitle = 'Log in to continue your journey';
  // Form labels
  static const String loginEmailLabel = 'Email';
  static const String loginPasswordLabel = 'Password';
  // Form hints
  static const String loginEmailHint = 'Enter your email address';
  static const String loginPasswordHint = 'Enter your password';
  // Accessibility
  static const String loginShowPassword = 'Show password';
  static const String loginHidePassword = 'Hide password';
  // Validation
  static const String loginEmailRequired = 'Email is required';
  static const String loginEmailInvalid = 'Please enter a valid email address';
  static const String loginPasswordRequired = 'Password is required';
  static const String loginPasswordMinLength =
      'Password must be at least 8 characters';
  // Buttons & links
  static const String loginButton = 'Log In';
  static const String loginForgotPassword = 'Forgot Password?';
  static const String loginOrContinueWith = 'Or continue with';
  static const String loginNoAccount = "Don't have an account? ";
  static const String loginSignUp = 'Sign Up';
  // Messages / SnackBars
  static const String loginSuccess = 'Login successful!';
  // loginWelcomeUser uses interpolation: 'Welcome, $userName!'
  static const String loginFailed = 'Login failed. Please try again.';
  static const String loginGoogleSigningIn = 'Signing in with Google...';
  static const String loginGoogleCancelled = 'Google Sign-In was cancelled';
  static const String loginAuthFailed = 'Authentication failed';
  static const String loginEmailExistsDifferentMethod =
      'Email already exists with different sign-in method';
  static const String loginInvalidCredentials = 'Invalid credentials';
  static const String loginGoogleFailed =
      'Failed to sign in with Google. Please try again.';
  static const String loginFacebookSigningIn = 'Signing in with Facebook...';
  static const String loginFacebookCancelled = 'Facebook Sign-In was cancelled';
  static const String loginFacebookFailed =
      'Failed to sign in with Facebook. Please try again.';
  static const String loginFacebookSignInSuccess =
      'Successfully signed in with Facebook!';

  // ────────────────────────────────────────────────────────────
  // 5. register_screen.dart
  // ────────────────────────────────────────────────────────────
  // Header
  static const String registerTitle = 'Register';
  static const String registerSubtitle = 'Please enter your detail to sign in';
  // Form labels
  static const String registerFullNameLabel = 'Full Name';
  static const String registerEmailLabel = 'Email';
  static const String registerPhoneLabel = 'Phone Number';
  static const String registerPasswordLabel = 'Password';
  static const String registerConfirmPasswordLabel = 'Confirm Password';
  // Form hints
  static const String registerFullNameHint = 'Enter your full name';
  static const String registerEmailHint = 'Enter your email';
  static const String registerPhoneHint = 'Enter phone number';
  static const String registerPasswordHint = 'Enter your password';
  static const String registerConfirmPasswordHint = 'Confirm your password';
  // Toggle
  static const String registerUsePhoneInstead = 'Use phone number instead';
  static const String registerUseEmailInstead = 'Use email address instead';
  // Validation
  static const String registerNameRequired = 'Please enter name.';
  static const String registerEmailRequired = 'Please enter email address.';
  static const String registerEmailInvalid =
      'Please enter a valid email address.';
  static const String registerPhoneRequired = 'Please enter phone number.';
  static const String registerPhoneInvalid =
      'Please enter a valid phone number.';
  static const String registerPasswordInvalid =
      'Password must be at least 8 characters long and include uppercase, lowercase, number, and special character.';
  static const String registerConfirmPasswordRequired =
      'Please confirm password again.';
  static const String registerPasswordsMismatch = 'Passwords do not match.';
//
// Buttons & links
// registerButton:                      'Register'
// registerAlreadyHaveAccount:          'Already have an account? '
// registerLoginLink:                   'Log In'

// ──────────────────────────────────────────────────────────────
// 5. forget_password_screen.dart
// ──────────────────────────────────────────────────────────────
// Header
// forgotPasswordTitle:                 'Forgot Password'
// forgotPasswordResetTitle:            'Reset Your Password'
// forgotPasswordDescription:           "Enter your phone number and we'll send you a verification code"
//
// Form
// forgotPasswordPhoneLabel:            'Phone Number'
// forgotPasswordPhoneHint:             '12 345 678'
// forgotPasswordSelectCountry:         'Select Country'
//
// Validation
// forgotPasswordPhoneRequired:         'Phone number is required'
// forgotPasswordPhoneDigitsOnly:       'Phone number must contain only digits'
// forgotPasswordPhoneLength:           'Phone number must be 8–12 digits'
// forgotPasswordRemoveLeadingZero:     'Remove leading 0 from phone number'
//
// Buttons
// forgotPasswordSendButton:            'Send Verification Code'
//
// Dialogs / messages
// forgotPasswordSuccess:               'Success!'

// ──────────────────────────────────────────────────────────────
// 6. verify_email_screen.dart
// ──────────────────────────────────────────────────────────────
// Header
// verifyCodeTitle:                     'Verify Code'
// verifyCodeSubtitle:                  'Enter Verification Code'
// verifyCodeSentTo:                    'We sent a 6-digit code to'
//
// Buttons
// verifyCodeButton:                    'Verify Code'
// verifyCodeResend:                    'Resend Code'
//
// Messages
// verifyCodeEnterAllDigits:            'Please enter all 6 digits'
// verifyCodeIncorrect:                 'Incorrect code. Please try again.'
// verifyCodeSuccess:                   'OTP verified successfully!'
// verifyCodeNewCodeSent:               'A new code has been sent'
// verifyCodeDidntReceive:              "Didn't receive the code?"
// verifyCodeResendIn:                  'Resend in ${seconds}s'

// ──────────────────────────────────────────────────────────────
// 7. homescreens.dart
// ──────────────────────────────────────────────────────────────
// App
// homeAppTitle:                        'Scholarship App'
//
// Hero section
// homeScholarshipBrand:                'Scholarship'
// homeFindYourFuture:                  'Find Your Future'
// homeGoodMorning:                     'Good Morning 👋'
// homeGoodAfternoon:                   'Good Afternoon ☀️'
// homeGoodEvening:                     'Good Evening 🌆'
// homeGoodNight:                       'Good Night 🌙'
// homeUserName:                        'Khunrithy'
// homeStudentBadge:                    'Student'
// homeProfileButton:                   'Profile'
//
// Search
// homeSearchHint:                      'Search scholarships...'
// searchResultTitle:                   'Search Results'
// searchNewSearch:                     'New Search'
//
// Quick actions
// homeQuickActionsTitle:               'Quick Actions'
// homeActionDiscover:                  'Discover'
// homeActionMatch:                     'Match'
// homeActionSaved:                     'Saved'
// homeActionFillInfo:                  'Fill Info'
//
// Section header
// homeLatestScholarships:              'Latest Scholarships'
// homeSeeAll:                          'See All'
//
// Scholarship cards (mock data)
// homeScholarship1Title:               'Full Scholarship to MIT'
// homeScholarship1University:          'MIT'
// homeScholarship1Location:            'United States'
// homeScholarship1Type:                'Full Scholarship'
// homeScholarship1Deadline:            'Mar 30, 2026'
// homeScholarship2Title:               'Engineering Excellence Award'
// homeScholarship2University:          'Stanford'
// homeScholarship2Location:            'USA'
// homeScholarship2Type:                'Partial'
// homeScholarship2Deadline:            'Apr 15, 2026'
//
// Banner slides
// homeBannerTitle1:                    'Scholarship Opportunities'
// homeBannerSubtitle1:                 'Find your chance to study abroad'
// homeBannerTitle2:                    'Achieve Your Dreams'
// homeBannerSubtitle2:                 'Get world-class education'
// homeBannerTitle3:                    'Start Learning Today'
// homeBannerSubtitle3:                 'Many opportunities awaiting you'
//
// Bottom nav
// homeNavHome:                         'Home'
// homeNavChat:                         'Chat'
// homeNavMenu:                         'Menu'

// ──────────────────────────────────────────────────────────────
// 8. discover_screen.dart
// ──────────────────────────────────────────────────────────────
// Header
// discoverTitle:                       'Discover'
// discoverSubtitle:                    'Find your dream scholarship'
// discoverSearchHint:                  'Search scholarships...'
//
// Categories
// discoverCategoriesTitle:             'Categories'
// discoverCategoriesSeeAll:            'See all'
// discoverCategoryAll:                 'All'
// discoverCategoryTechnology:          'Technology'
// discoverCategoryScience:             'Science'
// discoverCategoryBusiness:            'Business'
// discoverCategoryArt:                 'Art'
//
// Scholarships list
// discoverAvailableTitle:              'Available Scholarships'
// discoverFoundCount:                  '${scholarships.length} found'
//
// Card labels
// discoverEducationLevel:              'Education level'
// discoverType:                        'Type'
// discoverNumberOfPlaces:              'Number of places'
// discoverStudyAt:                     'Study at'
// discoverReceiptDate:                 'Receipt date'
// discoverDeadline:                    'Deadline'

// ──────────────────────────────────────────────────────────────
// 9. search_filter_screen.dart
// ──────────────────────────────────────────────────────────────
// Header
// searchTitle:                         'Scholarship Finder'
// searchHint:                          'Search by major, country, University'
//
// Sections
// searchRecentTitle:                   'Recent'
// searchPopularTitle:                  'Popular Searches'
// searchFilterTitle:                   'Filter'
// searchCountryLabel:                  'Country'
// searchScholarshipTypeLabel:          'Scholarship Type'
// searchApplyFiltersButton:            'Apply Filters'
//
// Recent searches
// searchRecent1:                       'Computer Science'
// searchRecent2:                       'Engineering'
// searchRecent3:                       'Business'
//
// Popular searches
// searchPopular1:                      'STEM'
// searchPopular2:                      'Medical'
// searchPopular3:                      'Full Scholarship'
// searchPopular4:                      'USA'
//
// Filter countries
// searchCountryUS:                     'United States'
// searchCountryUK:                     'United Kingdom'
// searchCountryJapan:                  'Japan'
// searchCountryAustralia:              'Australia'
// searchCountrySingapore:              'Singapore'
//
// Filter types
// searchTypeFullScholarship:           'Full Scholarship'
// searchTypePartialScholarship:        'Partial Scholarship'
// searchTypeTuitionOnly:               'Tuition Only'

// ──────────────────────────────────────────────────────────────
// 10. filter_result_screen.dart
// ──────────────────────────────────────────────────────────────
// Header
// filterResultTitle:                   'Search Result'
// filterResultFoundCount:              'Found ${count} Scholarship(s)'
//
// Empty state
// filterResultNoResults:               'No Results Found'
// filterResultTryAdjusting:            'Try adjusting your filters\nor search with different keywords'
// filterResultNewSearch:               'New Search'
//
// Active filter chips (mock data)
// filterChipComputerScience:           'Computer Science'
// filterChipUnitedState:               'United State'
// filterChipFullScholarships:          'Full Scholarships'

// ──────────────────────────────────────────────────────────────
// 11. profile_screen.dart
// ──────────────────────────────────────────────────────────────
// Profile info
// profileUserName:                     'Choub Khunrithy'
// profileManageSubtitle:               'Manage your scholarships'
// profileEditButton:                   'Edit Profile'
//
// Stats
// profileSavedLabel:                   'Saved'
// profileAppliedLabel:                 'Applied'
//
// Account section
// profileAccountSettings:              'Account Settings'
// profileFieldOfStudy:                 'Computer Science'
// profileNotifications:                'Notifications'
// profileMyApplications:               'My Applications'
// profileHelpSupport:                  'Help & Support'
// profileSettings:                     'Settings'
//
// Logout
// profileLogout:                       'Logout'
// profileLogoutConfirm:                'Are you sure you want to logout?'
// profileLogoutCancel:                 'Cancel'

// ──────────────────────────────────────────────────────────────
// 12. editProfile.dart
// ──────────────────────────────────────────────────────────────
// Header
// editProfileTitle:                    'Edit Profile'
// editProfileSaveButton:               'Save'
// editProfileChangePhoto:              'Change Photo'
//
// Form labels
// editProfileFullNameLabel:            'Full Name'
// editProfileEmailLabel:               'Email'
// editProfilePhoneLabel:               'Phone'
// editProfileDobLabel:                 'Date of Birth'
// editProfileCountryLabel:             'Country'
//
// Form hints
// editProfileFullNameHint:             'Enter your full name'
// editProfileEmailHint:                'Enter your email'
// editProfilePhoneHint:                'Enter your phone number'
// editProfileDobHint:                  'MM/DD/YYYY'
// editProfileCountryHint:              'Enter your country'
//
// Interest fields
// editProfileInterestedFieldsTitle:    'Interested Fields'
// editProfileInterestedFieldsSubtitle: 'Select the fields that interest you'
// editProfileInterestArt:              'Art'
// editProfileInterestMedical:          'Medical'
// editProfileInterestFullScholarship:  'Full Scholarship'
// editProfileInterestUSA:              'USA'
//
// Messages
// editProfileSaveSuccess:              'Profile Saved Successfully!'
// editProfileCamera:                   'Camera'
// editProfileGallery:                  'Gallery'

// ──────────────────────────────────────────────────────────────
// 13. settings_screen.dart
// ──────────────────────────────────────────────────────────────
// Title
// settingsTitle:                       'Settings'
//
// Notification section
// settingsNotificationsSection:        'Notifications'
// settingsPushNotifications:           'Push Notifications'
// settingsEmailNotifications:          'Email Notifications'
// settingsDeadlineReminders:           'Deadline Reminders'
// settingsNewScholarships:             'New Scholarships'
//
// App settings section
// settingsAppSettingsSection:          'App Settings'
// settingsLanguage:                    'Language'
// settingsNotificationSound:           'Notification Sound'
// settingsDarkMode:                    'Dark Mode'
//
// About section
// settingsAboutSection:                'About'
// settingsPrivacyPolicy:               'Privacy Policy'
// settingsTermsOfService:              'Terms of Service'
// settingsHelpSupport:                 'Help & Support'
// settingsRateApp:                     'Rate App'
// settingsVersion:                     'Version 1.0.0'
//
// Dialogs
// settingsSelectLanguage:              'Select Language'
// settingsSelectNotificationSound:     'Notification Sound'
// settingsOpeningPage:                 'Opening $page...'
//
// Language list
// settingsLanguageEnglish:             'English'
// settingsLanguageKhmer:               'ខ្មែរ'
// settingsLanguageChinese:             '中文'
// settingsLanguageJapanese:            'Japanese'
// settingsLanguageFrench:              'French'
//
// Sound list
// settingsSoundDefault:                'Default'
// settingsSoundSilent:                 'Silent'
// settingsSoundVibrateOnly:            'Vibrate only'
// settingsSoundChime:                  'Chime'

// ──────────────────────────────────────────────────────────────
// 14. notification_screen.dart
// ──────────────────────────────────────────────────────────────
// Header
// notificationTitle:                   'Notifications'
// notificationUnreadCount:             '$unreadCount unread'
// notificationMarkAllRead:             'Mark all read'
//
// Empty state
// notificationEmpty:                   'No notifications yet'
// notificationAllCaughtUp:             "You're all caught up!"
//
// Mock notification titles
// notificationDeadlineTitle:           'Application Deadline Approaching'
// notificationNewScholarshipTitle:     'New Scholarship Available'
// notificationSubmittedTitle:          'Application Submitted'
// notificationCompleteProfileTitle:    'Complete your Profile'
//
// Mock notification subtitles
// notificationDeadlineSubtitle:        'MIT Scholarship deadline in 3 days'
// notificationNewScholarshipSubtitle:  'Stanford Engineering Scholarship'
// notificationSubmittedSubtitle:       'Your application to Oxford has been submitted'
// notificationCompleteProfileSubtitle: 'Add your Document to improve your chance'
//
// Mock notification times
// notificationTime1:                   '2 hours ago'
// notificationTime2:                   '5 hours ago'
// notificationTime3:                   '1 day ago'
// notificationTime4:                   '2 days ago'

// ──────────────────────────────────────────────────────────────
// 15. saved_scholarship_screen.dart
// ──────────────────────────────────────────────────────────────
// Header
// savedTitle:                          'Saved Scholarships'
// savedSortByDeadline:                 'Sort by Deadline'
// savedSortByName:                     'Sort by Name'
// savedCount:                          '$count Saved'
//
// Snackbar
// savedRemoved:                        'Scholarship removed from saved'
// savedUndo:                           'UNDO'
//
// Card
// savedDeadline:                       'Deadline: $date'
// savedDaysLeft:                       '${days}d left'
//
// Empty state
// savedEmpty:                          'No Saved Scholarships'
// savedEmptyMessage:                   "Start saving scholarships to keep track of opportunities you're interested in"
// savedExploreButton:                  'Explore Scholarships'

// ──────────────────────────────────────────────────────────────
// 16. scholarship_detail_screen.dart
// ──────────────────────────────────────────────────────────────
// Header
// detailTitle:                         'Scholarship Details'
//
// Scholarship info (mock data)
// detailScholarshipTitle:              'Full Scholarship for Computer Science'
// detailScholarshipLocation:           'RUPP, Cambodia'
// detailDeadlineLabel:                 'Application Deadline'
// detailDeadlineDate:                  'March-15-2026'
// detailDaysRemaining:                 '60 day remaining'
//
// Sections
// detailAboutTitle:                    'About this scholarship'
// detailAboutDescription:              'This scholarship provides full financial support for outstanding students pursuing a degree in Computer Science at the Royal University of Phnom Penh (RUPP). It covers tuition fees, monthly living allowances, and access to academic resources throughout the program duration.'
//
// Benefits
// detailBenefitsTitle:                 'Scholarship Benefits'
// detailBenefit1:                      '- Tuition'
// detailBenefit2:                      '- Monthly allowance'
// detailBenefit3:                      '- Research support'
// detailBenefit4:                      '- Printing costs'
//
// Eligibility
// detailEligibilityTitle:              'Eligibility Requirements'
// detailRequirement1:                  'Must be a Cambodian citizen'
// detailRequirement2:                  'GPA of 3.0 or higher'
// detailRequirement3:                  'Enrolled in a Computer Science program'
// detailRequirement4:                  'Demonstrated financial need'
//
// Required Documents
// detailDocumentsTitle:                'Required Documents'
// detailDocument1:                     'Official transcripts'
// detailDocument2:                     'Letter of recommendation'
// detailDocument3:                     'Personal statement'
// detailDocument4:                     'Proof of enrollment'
//
// Button
// detailApplyButton:                   'Apply'

// ──────────────────────────────────────────────────────────────
// 17. personal_info_screen.dart
// ──────────────────────────────────────────────────────────────
// AppBar
// personalInfoAppBar:                  'Fill Personal Information'
//
// Section
// personalInfoSection:                 'Information'
//
// Labels
// personalInfoFirstName:               'First Name'
// personalInfoLastName:                'Last Name'
// personalInfoGender:                  'Gender'
// personalInfoNationality:             'Nationality'
// personalInfoDob:                     'Date Of Birth'
// personalInfoPhone:                   'Phone Number(contact)'
// personalInfoEmail:                   'Email'
// personalInfoChooseImage:             'Choose a profile image'
//
// Hints
// personalInfoFirstNameHint:           'Ex: Choub'
// personalInfoLastNameHint:            'Ex: Khunrithy'
// personalInfoSelectHint:              'Select'
// personalInfoPhoneHint:               '0312287763'
// personalInfoEmailHint:               'choubkhunrithy@gmail.com'
// personalInfoDobHint:                 'Select Date of Birth'
//
// Buttons
// personalInfoNextButton:              'Next'
// personalInfoGalleryButton:           'Go to Gallery'
// personalInfoImageSelected:           'Image Selected ✓'
//
// Image picker dialog
// personalInfoImageSourceTitle:        'Choose Image Source'
// personalInfoCameraOption:            'Camera'
// personalInfoGalleryOption:           'Gallery'
//
// Validation
// personalInfoFieldRequired:           'This field is required'
// personalInfoLettersOnly:             'Only letters are allowed'
// personalInfoNameMinLength:           'Name must be at least 2 characters'
// personalInfoEmailRequired:           'Email is required'
// personalInfoEmailAtSign:             'Email must contain @'
// personalInfoEmailDotCom:             'Email must contain .com'
// personalInfoPhoneRequired:           'Phone number is required'
// personalInfoPhoneMinDigits:          'Phone must be at least 8 digits'
// personalInfoSelectGender:            'Please select gender'
// personalInfoSelectNationality:       'Please select nationality'
// personalInfoSelectDob:               'Please select date of birth'
// personalInfoSelectImage:             'Please choose a profile image'
//
// Gender list
// personalInfoGenderMale:              'Male'
// personalInfoGenderFemale:            'Female'
// personalInfoGenderOther:             'Other'
//
// Nationality list
// personalInfoNationalityCambodian:    'Cambodian'
// personalInfoNationalityVietnamese:   'Vietnamese'
// personalInfoNationalityLaotian:      'Laotian'
// personalInfoNationalityChinese:      'Chinese'
// personalInfoNationalityAmerican:     'American'
// personalInfoNationalityJapanese:     'Japanese'
// personalInfoNationalityKorean:       'Korean'
// personalInfoNationalityOther:        'Other'

// ──────────────────────────────────────────────────────────────
// 18. education_background_screen.dart
// ──────────────────────────────────────────────────────────────
// AppBar
// educationAppBar:                     'Fill Personal information'
//
// Section
// educationSection:                    'Education Background'
//
// Labels
// educationInstitution:                'Current Institution'
// educationDegree:                     'Current Degree'
// educationMajor:                      'Current Major'
// educationGradYear:                   'Year of Graduation'
// educationGpa:                        'GPA/Grade'
//
// Hints
// educationInstitutionHint:            'Current your Institution'
// educationDegreeHint:                 'Current your Degree'
// educationMajorHint:                  'your current Major'
// educationGradYearHint:               'year of Graduation'
// educationGpaHint:                    'GPA/Grade'
//
// Button
// educationNextButton:                 'Next'
//
// Validation
// educationInstitutionRequired:        'Institution is required'
// educationInstitutionTooShort:        'Institution name is too short'
// educationGpaRequired:                'GPA/Grade is required'
// educationSelectDegree:               'Please select your degree'
// educationSelectMajor:                'Please select your major'
// educationSelectGradYear:             'Please select graduation year'
//
// Degree list
// educationDegreeHighSchool:           'High School'
// educationDegreeAssociate:            'Associate Degree'
// educationDegreeBachelor:             "Bachelor's Degree"
// educationDegreeMaster:               "Master's Degree"
// educationDegreePhd:                  'Doctoral Degree (PhD)'
//
// Major list
// educationMajorCS:                    'Computer Science'
// educationMajorIT:                    'Information Technology'
// educationMajorSE:                    'Software Engineering'
// educationMajorEngineering:           'Engineering'
// educationMajorBusiness:              'Business Administration'
// educationMajorEconomics:             'Economics'
// educationMajorFinance:               'Finance'
// educationMajorArts:                  'Arts and Humanities'
// educationMajorSciences:              'Natural Sciences'
// educationMajorMedicine:              'Medicine'
// educationMajorLaw:                   'Law'
// educationMajorEducation:             'Education'
// educationMajorArchitecture:          'Architecture'
// educationMajorOther:                 'Other'

// ──────────────────────────────────────────────────────────────
// 19. languages_screen.dart
// ──────────────────────────────────────────────────────────────
// AppBar
// languagesAppBar:                     'Fill Personal information'
//
// Section
// languagesSection:                    'Your languages'
//
// Labels
// languagesSpokenLabel:                'Spoken Language'
// languagesEnglishLevelLabel:          'English Level'
// languagesIeltsCertLabel:             'English IELTS Certificate'
//
// Hints
// languagesSpokenHint:                 'Spoken Language'
// languagesEnglishLevelHint:           'English Level'
// languagesIeltsCertHint:              'IELTS Certificate'
//
// Button
// languagesNextButton:                 'Next'
//
// Validation
// languagesSelectSpoken:               'Please select spoken language'
// languagesSelectLevel:                'Please select English level'
// languagesSelectIelts:                'Please select IELTS certificate level'
//
// Spoken language list
// languagesKhmer:                      'Khmer'
// languagesEnglish:                    'English'
// languagesMandarinChinese:            'Chinese (Mandarin)'
// languagesCantoneseChinese:           'Chinese (Cantonese)'
// languagesThai:                       'Thai'
// languagesVietnamese:                 'Vietnamese'
// languagesFrench:                     'French'
// languagesSpanish:                    'Spanish'
// languagesJapanese:                   'Japanese'
// languagesKorean:                     'Korean'
// languagesGerman:                     'German'
// languagesArabic:                     'Arabic'
// languagesOther:                      'Other'
//
// English level list
// languagesLevelBeginner:              'Beginner (A1)'
// languagesLevelElementary:            'Elementary (A2)'
// languagesLevelIntermediate:          'Intermediate (B1)'
// languagesLevelUpperIntermediate:     'Upper Intermediate (B2)'
// languagesLevelAdvanced:              'Advanced (C1)'
// languagesLevelProficient:            'Proficient (C2)'
// languagesLevelNative:                'Native Speaker'
//
// IELTS certificate list
// languagesIeltsNone:                  'No Certificate'
// languagesIeltsBand4:                 'Band 4.0'
// languagesIeltsBand4_5:               'Band 4.5'
// languagesIeltsBand5:                 'Band 5.0'
// languagesIeltsBand5_5:               'Band 5.5'
// languagesIeltsBand6:                 'Band 6.0'
// languagesIeltsBand6_5:               'Band 6.5'
// languagesIeltsBand7:                 'Band 7.0'
// languagesIeltsBand7_5:               'Band 7.5'
// languagesIeltsBand8:                 'Band 8.0'
// languagesIeltsBand8_5:               'Band 8.5'
// languagesIeltsBand9:                 'Band 9.0'

// ──────────────────────────────────────────────────────────────
// 20. work_experience_screen.dart
// ──────────────────────────────────────────────────────────────
// AppBar
// workExpAppBar:                       'Fill Personal information'
//
// Section
// workExpSection:                      'Work & Volunteer Experience'
//
// Labels
// workExpExperienceLabel:              'Work experience'
// workExpDurationLabel:                'Work Duration'
// workExpTypeLabel:                    'Work Type'
//
// Hints
// workExpExperienceHint:               'Work Experience'
// workExpDurationHint:                 'Work Duration'
// workExpTypeHint:                     'Work Type'
//
// Button
// workExpNextButton:                   'Next'
//
// Validation
// workExpSelectExperience:             'Please select work experience'
// workExpSelectDuration:               'Please select work duration'
// workExpSelectType:                   'Please select work type'
//
// Experience list
// workExpNoExperience:                 'No Experience'
// workExpFreshGraduate:                'Fresh Graduate'
// workExpIntern:                       'Intern'
// workExp1To2Years:                    '1-2 years'
// workExp2To5Years:                    '2-5 years'
// workExp5To10Years:                   '5-10 years'
// workExp10PlusYears:                  '10+ years'
//
// Duration list
// workExpDurationLess6Months:          'Less than 6 months'
// workExpDuration6MonthsTo1Year:       '6 months - 1 year'
// workExpDuration1To2Years:            '1-2 years'
// workExpDuration2To3Years:            '2-3 years'
// workExpDuration3To5Years:            '3-5 years'
// workExpDuration5PlusYears:           '5+ years'
//
// Work type list
// workExpTypeFullTime:                 'Full-time'
// workExpTypePartTime:                 'Part-time'
// workExpTypeInternship:               'Internship'
// workExpTypeVolunteer:                'Volunteer'
// workExpTypeFreelance:                'Freelance'
// workExpTypeContract:                 'Contract'
// workExpTypeSelfEmployed:             'Self-employed'

// ──────────────────────────────────────────────────────────────
// 21. research_experience_screen.dart
// ──────────────────────────────────────────────────────────────
// AppBar
// researchAppBar:                      'Fill Personal information'
//
// Section
// researchSection:                     'Research Experience'
//
// Labels
// researchExperienceLabel:             'Research Experience'
// researchAuthorsLabel:                'Author/s'
// researchFieldLabel:                  'Research Field'
// researchPublisherLabel:              'Publisher'
// researchLocationLabel:               'Location'
//
// Hints
// researchExperienceHint:              'Research Experience'
// researchAuthorsHint:                 'Select author role'
// researchFieldHint:                   'Name of Field'
// researchPublisherHint:               'Publisher'
// researchLocationHint:                'Location'
//
// Button
// researchNextButton:                  'Next'
//
// Validation
// researchSelectExperience:            'Please select research experience'
// researchSelectAuthors:               'Please select author/s'
// researchSelectField:                 'Please select research field'
// researchSelectPublisher:             'Please select publisher'
// researchSelectLocation:              'Please select location'
//
// Research experience list
// researchExpNone:                     'No Research Experience'
// researchExpUndergrad:                'Undergraduate Research'
// researchExpGrad:                     'Graduate Research'
// researchExpThesis:                   'Thesis / Capstone Project'
// researchExpConference:               'Conference Presentation'
// researchExpAssistant:                'Research Assistant'
// researchExpIndependent:              'Independent Research'
// researchExpPublished:                'Published Research'
// researchExpCollaborative:            'Collaborative Research'
//
// Author roles
// researchAuthorSingle:                'Single Author'
// researchAuthorFirst:                 'First Author'
// researchAuthorCo:                    'Co-Author'
// researchAuthorCorresponding:         'Corresponding Author'
// researchAuthorTeamMember:            'Research Team Member'
//
// Research field list
// researchFieldCS:                     'Computer Science'
// researchFieldEngineering:            'Engineering'
// researchFieldNatural:                'Natural Sciences'
// researchFieldSocial:                 'Social Sciences'
// researchFieldMedicine:               'Medicine & Health'
// researchFieldBusiness:               'Business & Economics'
// researchFieldEnvironmental:          'Environmental Studies'
// researchFieldMath:                   'Mathematics'
// researchFieldPhysics:                'Physics'
// researchFieldChemistry:              'Chemistry'
// researchFieldBiology:                'Biology'
// researchFieldOther:                  'Other'
//
// Publisher list
// researchPubNotPublished:             'Not Published'
// researchPubJournal:                  'Journal Article'
// researchPubConference:               'Conference Proceedings'
// researchPubBookChapter:              'Book Chapter'
// researchPubThesis:                   'Thesis/Dissertation'
// researchPubWorking:                  'Working Paper'
// researchPubOnline:                   'Online Publication'
// researchPubUniversity:               'University Repository'
//
// Location list
// researchLocCambodia:                 'Cambodia'
// researchLocVietnam:                  'Vietnam'
// researchLocSingapore:                'Singapore'
// researchLocMalaysia:                 'Malaysia'
// researchLocUS:                       'United States'
// researchLocUK:                       'United Kingdom'
// researchLocAustralia:                'Australia'
// researchLocJapan:                    'Japan'
// researchLocSouthKorea:               'South Korea'
// researchLocChina:                    'China'
// researchLocOnline:                   'Online/Virtual'
// researchLocOther:                    'Other'

// ──────────────────────────────────────────────────────────────
// 22. award_achievement_screen.dart
// ──────────────────────────────────────────────────────────────
// AppBar
// awardAppBar:                         'Fill Personal information'
//
// Section
// awardSection:                        'Award & Special Achievement'
//
// Labels
// awardAchievementLabel:               'Award & Special Achievement'
// awardProgramNameLabel:               'Program Name'
// awardOrganizationLabel:              'Organization'
// awardLocationLabel:                  'Location'
// awardDescriptionLabel:               'Description'
//
// Hints (same as labels)
// awardAchievementHint:                'Award & Special Achievement'
// awardProgramNameHint:                'Program Name'
// awardOrganizationHint:               'Organization'
// awardLocationHint:                   'Location'
// awardDescriptionHint:                'Description'
//
// Button
// awardNextButton:                     'Next'
//
// Validation
// awardSelectAchievement:              'Please select award & special achievement'
// awardSelectProgram:                  'Please select program name'
// awardSelectOrganization:             'Please select organization'
// awardSelectLocation:                 'Please select location'
// awardSelectDescription:              'Please select description'
//
// Award list
// awardNone:                           'No Award/Achievement'
// awardAcademicExcellence:             'Academic Excellence Award'
// awardScholarshipRecipient:           'Scholarship Recipient'
// awardCompetitionWinner:              'Competition Winner'
// awardDeansList:                      "Dean's List"
// awardHonorRoll:                      'Honor Roll'
// awardBestStudent:                    'Best Student Award'
// awardResearchGrant:                  'Research Grant'
// awardLeadership:                     'Leadership Award'
// awardCommunityService:               'Community Service Award'
// awardSports:                         'Sports Achievement'
// awardArtsCulture:                    'Arts & Culture Award'
// awardOther:                          'Other'
//
// Program name list
// awardProgScholarship:                'Scholarship Program'
// awardProgAcademic:                   'Academic Excellence Program'
// awardProgCompetition:                'Competition'
// awardProgResearch:                   'Research Program'
// awardProgLeadership:                 'Leadership Program'
// awardProgCommunity:                  'Community Service Program'
// awardProgSports:                     'Sports Program'
// awardProgArts:                       'Arts Program'
// awardProgInnovation:                 'Innovation Challenge'
// awardProgEntrepreneurship:           'Entrepreneurship Program'
// awardProgExchange:                   'Exchange Program'
// awardProgOther:                      'Other'
//
// Organization list
// awardOrgUniversity:                  'University/College'
// awardOrgGovernment:                  'Government Agency'
// awardOrgPrivate:                     'Private Company'
// awardOrgNonProfit:                   'Non-Profit Organization'
// awardOrgInternational:               'International Organization'
// awardOrgResearch:                    'Research Institution'
// awardOrgProfessional:                'Professional Association'
// awardOrgCommunity:                   'Community Organization'
// awardOrgEduFoundation:               'Educational Foundation'
// awardOrgCorpFoundation:              'Corporate Foundation'
// awardOrgOther:                       'Other'
//
// Location list
// awardLocCambodia:                    'Cambodia'
// awardLocVietnam:                     'Vietnam'
// awardLocSingapore:                   'Singapore'
// awardLocMalaysia:                    'Malaysia'
// awardLocIndonesia:                   'Indonesia'
// awardLocPhilippines:                 'Philippines'
// awardLocUS:                          'United States'
// awardLocUK:                          'United Kingdom'
// awardLocAustralia:                   'Australia'
// awardLocJapan:                       'Japan'
// awardLocSouthKorea:                  'South Korea'
// awardLocChina:                       'China'
// awardLocInternational:               'International / Multiple Countries'
// awardLocOther:                       'Other'
//
// Description list
// awardDescTop1:                       'Top 1%'
// awardDescTop5:                       'Top 5%'
// awardDescTop10:                      'Top 10%'
// awardDescFirst:                      'First Place'
// awardDescSecond:                     'Second Place'
// awardDescThird:                      'Third Place'
// awardDescHonorable:                  'Honorable Mention'
// awardDescFinalist:                   'Finalist'
// awardDescParticipant:                'Participant'
// awardDescCertAchievement:            'Certificate of Achievement'
// awardDescCertCompletion:             'Certificate of Completion'
// awardDescOther:                      'Other'

// ──────────────────────────────────────────────────────────────
// 23. scholarship_preference_screen.dart
// ──────────────────────────────────────────────────────────────
// AppBar
// prefAppBar:                          'Fill Personal information'
//
// Section
// prefSection:                         'Scholarship Preference'
//
// Labels
// prefCountryLabel:                    'Destination Country'
// prefUniversityLabel:                 'Preferred University'
// prefDegreeLabel:                     'Preferred Degree'
// prefMajorLabel:                      'Preferred Major'
//
// Hints (same as labels)
// prefCountryHint:                     'Destination Country'
// prefUniversityHint:                  'Preferred University'
// prefDegreeHint:                      'Preferred Degree'
// prefMajorHint:                       'Preferred Major'
//
// Button
// prefNextButton:                      'Next'
//
// Validation
// prefSelectCountry:                   'Please select destination country'
// prefSelectUniversity:                'Please select preferred university'
// prefSelectDegree:                    'Please select preferred degree'
// prefSelectMajor:                     'Please select preferred major'
//
// Destination country list
// prefCountryCambodia:                 'Cambodia'
// prefCountryVietnam:                  'Vietnam'
// prefCountryThailand:                 'Thailand'
// prefCountrySingapore:                'Singapore'
// prefCountryMalaysia:                 'Malaysia'
// prefCountryIndonesia:                'Indonesia'
// prefCountryPhilippines:              'Philippines'
// prefCountryJapan:                    'Japan'
// prefCountrySouthKorea:               'South Korea'
// prefCountryChina:                    'China'
// prefCountryUS:                       'United States'
// prefCountryUK:                       'United Kingdom'
// prefCountryAustralia:                'Australia'
// prefCountryCanada:                   'Canada'
// prefCountryGermany:                  'Germany'
// prefCountryFrance:                   'France'
// prefCountryNetherlands:              'Netherlands'
// prefCountrySweden:                   'Sweden'
// prefCountryNewZealand:               'New Zealand'
// prefCountryOther:                    'Other'
//
// University list (Cambodian)
// prefUniRUPP:                         'Royal University of Phnom Penh (RUPP)'
// prefUniITC:                          'Institute of Technology of Cambodia (ITC)'
// prefUniNUM:                          'National University of Management (NUM)'
// prefUniRUA:                          'Royal University of Agriculture (RUA)'
// prefUniUHS:                          'University of Health Sciences (UHS)'
// prefUniPUC:                          'Pannasastra University of Cambodia (PUC)'
// prefUniAUPP:                         'American University of Phnom Penh (AUPP)'
// prefUniZaman:                        'Zaman University'
// prefUniParagon:                      'Paragon International University'
// prefUniCamEd:                        'CamEd Business School'
// prefUniLimkokwing:                   'Limkokwing University'
// prefUniUBB:                          'University of Battambang (UBB)'
// prefUniMeanChey:                     'Mean Chey University'
// prefUniSVAY:                         'Svay Rieng University'
//
// University list (International)
// prefUniHarvard:                      'Harvard University'
// prefUniMIT:                          'Massachusetts Institute of Technology (MIT)'
// prefUniStanford:                     'Stanford University'
// prefUniOxford:                       'University of Oxford'
// prefUniCambridge:                    'University of Cambridge'
// prefUniTokyo:                        'University of Tokyo'
// prefUniMelbourne:                    'University of Melbourne'
// prefUniNUS:                          'National University of Singapore (NUS)'
// prefUniOther:                        'Other'
//
// Degree list
// prefDegreeAssociate:                 'Associate Degree'
// prefDegreeBachelor:                  "Bachelor's Degree"
// prefDegreeMaster:                    "Master's Degree"
// prefDegreePhd:                       'Doctoral Degree (PhD)'
// prefDegreePostdoc:                   'Postdoctoral'
// prefDegreeDiploma:                   'Diploma'
// prefDegreeCertificate:               'Certificate Program'
// prefDegreeOther:                     'Other'
//
// Major list
// prefMajorCS:                         'Computer Science'
// prefMajorIT:                         'Information Technology'
// prefMajorSE:                         'Software Engineering'
// prefMajorEngineering:                'Engineering'
// prefMajorBusiness:                   'Business Administration'
// prefMajorEconomics:                  'Economics'
// prefMajorFinance:                    'Finance'
// prefMajorAccounting:                 'Accounting'
// prefMajorArts:                       'Arts and Humanities'
// prefMajorSciences:                   'Natural Sciences'
// prefMajorMedicine:                   'Medicine'
// prefMajorLaw:                        'Law'
// prefMajorEducation:                  'Education'
// prefMajorArchitecture:               'Architecture'
// prefMajorIR:                         'International Relations'
// prefMajorPsychology:                 'Psychology'
// prefMajorEnvScience:                 'Environmental Science'
// prefMajorPublicHealth:               'Public Health'
// prefMajorOther:                      'Other'

// ──────────────────────────────────────────────────────────────
// 24. reference_screen.dart
// ──────────────────────────────────────────────────────────────
// AppBar
// referenceAppBar:                     'Fill Personal information'
//
// Section
// referenceSection:                    'Reference'
//
// Labels
// referenceFullName:                   'Full Name'
// referencePosition:                   'Position'
// referenceWorkPlace:                  'Work Place'
// referencePhone:                      'Your Phone Number'
// referenceEmail:                      'Your Email'
//
// Hints
// referenceFullNameHint:               'Please fill full name'
// referencePositionHint:               'Your Position'
// referenceWorkPlaceHint:              'Work Place'
// referencePhoneHint:                  'Your Phone Number'
// referenceEmailHint:                  'Your Email'
//
// Button
// referenceSubmitButton:               'Submit'
//
// Messages
// referenceSubmitSuccess:              'Application submitted successfully!'
//
// Validation
// referenceNameRequired:               'Full name is required'
// referenceNameMinLength:              'Name must be at least 2 characters'
// referencePhoneRequired:              'Phone number is required'
// referencePhoneMinDigits:             'Phone must be at least 8 digits'
// referenceEmailRequired:              'Email is required'
// referenceEmailAtSign:                'Email must contain @'
// referenceEmailDomain:                'Email must contain a domain'
// referenceSelectPosition:             'Please select position'
// referenceSelectWorkPlace:            'Please select work place'
//
// Position list
// referenceProfessor:                  'Professor'
// referenceAssocProfessor:             'Associate Professor'
// referenceAsstProfessor:              'Assistant Professor'
// referenceLecturer:                   'Lecturer'
// referenceTeacher:                    'Teacher'
// referenceDeptHead:                   'Department Head'
// referenceAcademicAdvisor:            'Academic Advisor'
// referenceResearchSupervisor:         'Research Supervisor'
// referenceManager:                    'Manager'
// referenceDirector:                   'Director'
// referenceSupervisor:                 'Supervisor'
// referenceTeamLeader:                 'Team Leader'
// referenceHRManager:                  'HR Manager'
// referenceOther:                      'Other'
//
// Work place list
// referenceWpUniversity:               'University'
// referenceWpCollege:                  'College'
// referenceWpHighSchool:               'High School'
// referenceWpResearchInst:             'Research Institution'
// referenceWpPrivateCompany:           'Private Company'
// referenceWpGovernment:               'Government Agency'
// referenceWpNonProfit:                'Non-Profit Organization'
// referenceWpInternational:            'International Organization'
// referenceWpEducational:              'Educational Institution'
// referenceWpCorporate:                'Corporate Office'
// referenceWpOther:                    'Other'

// ──────────────────────────────────────────────────────────────
// 25. custom_app_bar.dart  — NO hardcoded strings (title is a parameter)
// ──────────────────────────────────────────────────────────────

// ──────────────────────────────────────────────────────────────
// 26. section_header.dart  — NO hardcoded strings (title is a parameter)
// ──────────────────────────────────────────────────────────────

// ──────────────────────────────────────────────────────────────
// 27. button.dart  — NO hardcoded strings (text is a parameter)
// ──────────────────────────────────────────────────────────────
}
