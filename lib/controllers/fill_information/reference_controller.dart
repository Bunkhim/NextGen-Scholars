import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scholarship_app/routes/app_routes.dart';
import 'package:scholarship_app/services/application_data.dart';
import 'package:scholarship_app/translations/app_localizations.dart';

class ReferenceController extends GetxController {
	final fullNameController = TextEditingController();
	final phoneController = TextEditingController();
	final emailController = TextEditingController();

	final _appData = ApplicationData();

	final Rxn<String> selectedPosition = Rxn<String>();
	final Rxn<String> selectedWorkPlace = Rxn<String>();

	final RxnString fullNameError = RxnString();
	final RxnString positionError = RxnString();
	final RxnString workPlaceError = RxnString();
	final RxnString phoneError = RxnString();
	final RxnString emailError = RxnString();

	final RxBool hasAttemptedSubmit = false.obs;

	List<String> getPositions(AppLocalizations t) => [
				t.translate('referenceProfessor'),
				t.translate('referenceAssocProfessor'),
				t.translate('referenceAsstProfessor'),
				t.translate('referenceLecturer'),
				t.translate('referenceTeacher'),
				t.translate('referenceDeptHead'),
				t.translate('referenceAcademicAdvisor'),
				t.translate('referenceResearchSupervisor'),
				t.translate('referenceManager'),
				t.translate('referenceDirector'),
				t.translate('referenceSupervisor'),
				t.translate('referenceTeamLeader'),
				t.translate('referenceHRManager'),
				t.translate('referenceOther'),
			];

	List<String> getWorkPlaces(AppLocalizations t) => [
				t.translate('referenceWpUniversity'),
				t.translate('referenceWpCollege'),
				t.translate('referenceWpHighSchool'),
				t.translate('referenceWpResearchInst'),
				t.translate('referenceWpPrivateCompany'),
				t.translate('referenceWpGovernment'),
				t.translate('referenceWpNonProfit'),
				t.translate('referenceWpInternational'),
				t.translate('referenceWpEducational'),
				t.translate('referenceWpCorporate'),
				t.translate('referenceWpOther'),
			];

	@override
	void onInit() {
		super.onInit();
		_loadSavedData();

		fullNameController.addListener(_onTextChanged);
		phoneController.addListener(_onTextChanged);
		emailController.addListener(_onTextChanged);
	}

	@override
	void onClose() {
		fullNameController.removeListener(_onTextChanged);
		phoneController.removeListener(_onTextChanged);
		emailController.removeListener(_onTextChanged);
		fullNameController.dispose();
		phoneController.dispose();
		emailController.dispose();
		super.onClose();
	}

	void _loadSavedData() {
		fullNameController.text = _appData.referenceFullName ?? '';
		phoneController.text = _appData.referencePhone ?? '';
		emailController.text = _appData.referenceEmail ?? '';
		selectedPosition.value = _appData.referencePosition;
		selectedWorkPlace.value = _appData.referenceWorkPlace;
	}

	void _saveData() {
		_appData.referenceFullName = fullNameController.text;
		_appData.referencePhone = phoneController.text;
		_appData.referenceEmail = emailController.text;
		_appData.referencePosition = selectedPosition.value;
		_appData.referenceWorkPlace = selectedWorkPlace.value;
	}

	void _onTextChanged() {
		if (!hasAttemptedSubmit.value) return;
		fullNameError.value = validateName(fullNameController.text);
		phoneError.value = validatePhone(phoneController.text);
		emailError.value = validateEmail(emailController.text);
	}

	String? validateName(String? value, [AppLocalizations? t]) {
		final localizations = t ?? AppLocalizations.of(Get.context!);
		if (value == null || value.trim().isEmpty) {
			return localizations.translate('referenceNameRequired');
		}
		if (value.trim().length < 2) {
			return localizations.translate('referenceNameMinLength');
		}
		if (!RegExp(r'^[\p{L}\s]+$', unicode: true).hasMatch(value.trim())) {
			return localizations.translate('referenceNameAllowUnicode');
		}
		return null;
	}

	String? validatePhone(String? value, [AppLocalizations? t]) {
		final AppLocalizations localizations =
			t ?? AppLocalizations.of(Get.context!);
		if (value == null || value.trim().isEmpty) {
			return localizations.translate('referencePhoneRequired');
		}
		final digitsOnly = value.replaceAll(RegExp(r'[\s\-\+]'), '');
		if (!RegExp(r'^\d+$').hasMatch(digitsOnly)) {
			return localizations.translate('referencePhoneDigitsOnly');
		}
		if (digitsOnly.length < 8) {
			return localizations.translate('referencePhoneMinDigits');
		}
		if (digitsOnly.length > 15) {
			return localizations.translate('referencePhoneMaxDigits');
		}
		return null;
	}

	String? validateEmail(String? value, [AppLocalizations? t]) {
		final AppLocalizations localizations =
			t ?? AppLocalizations.of(Get.context!);
		if (value == null || value.trim().isEmpty) {
			return localizations.translate('referenceEmailRequired');
		}
		final emailRegex = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,}$');
		if (!emailRegex.hasMatch(value.trim())) {
			return localizations.translate('referenceEmailInvalid');
		}
		return null;
	}

	void selectPosition(String? value) {
		selectedPosition.value = value;
		positionError.value = null;
	}

	void selectWorkPlace(String? value) {
		selectedWorkPlace.value = value;
		workPlaceError.value = null;
	}

	void clearErrors() {
		fullNameError.value = null;
		positionError.value = null;
		workPlaceError.value = null;
		phoneError.value = null;
		emailError.value = null;
	}

	void onSave(AppLocalizations t) {
		_saveData();
		ApplicationData().saveToPrefs();
		Get.snackbar(
			'',
			t.translate('fillInfoSaved'),
			snackPosition: SnackPosition.BOTTOM,
		);
	}

	bool submitForm(AppLocalizations t) {
		hasAttemptedSubmit.value = true;

		fullNameError.value = validateName(fullNameController.text, t);
		phoneError.value = validatePhone(phoneController.text, t);
		emailError.value = validateEmail(emailController.text, t);
		positionError.value = selectedPosition.value == null
				? t.translate('referenceSelectPosition')
				: null;
		workPlaceError.value = selectedWorkPlace.value == null
				? t.translate('referenceSelectWorkPlace')
				: null;

		final isValid = fullNameError.value == null &&
				phoneError.value == null &&
				emailError.value == null &&
				positionError.value == null &&
				workPlaceError.value == null;

		if (!isValid) {
			return false;
		}

		_saveData();
		ApplicationData().saveToPrefs();
		return true;
	}

	void goHome() {
		Get.offAllNamed(AppRoutes.homeScreen);
	}
}
