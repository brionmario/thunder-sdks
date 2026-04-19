/// All Thunder SDK error codes (spec §10.2).
enum IAMErrorCode {
  // Configuration
  sdkNotInitialized,
  alreadyInitialized,
  invalidConfiguration,
  invalidRedirectUri,

  // Authentication
  authenticationFailed,
  userAccountLocked,
  userAccountDisabled,
  sessionExpired,
  mfaRequired,
  mfaFailed,
  invalidGrant,
  consentRequired,

  // Registration
  userAlreadyExists,
  invalidInput,
  invitationCodeInvalid,
  invitationCodeExpired,
  registrationDisabled,

  // Recovery
  recoveryFailed,
  confirmationCodeInvalid,
  confirmationCodeExpired,

  // Network & Server
  networkError,
  requestTimeout,
  serverError,
  unknownError;

  static const _codeMap = {
    'SDK_NOT_INITIALIZED': IAMErrorCode.sdkNotInitialized,
    'ALREADY_INITIALIZED': IAMErrorCode.alreadyInitialized,
    'INVALID_CONFIGURATION': IAMErrorCode.invalidConfiguration,
    'INVALID_REDIRECT_URI': IAMErrorCode.invalidRedirectUri,
    'AUTHENTICATION_FAILED': IAMErrorCode.authenticationFailed,
    'USER_ACCOUNT_LOCKED': IAMErrorCode.userAccountLocked,
    'USER_ACCOUNT_DISABLED': IAMErrorCode.userAccountDisabled,
    'SESSION_EXPIRED': IAMErrorCode.sessionExpired,
    'MFA_REQUIRED': IAMErrorCode.mfaRequired,
    'MFA_FAILED': IAMErrorCode.mfaFailed,
    'INVALID_GRANT': IAMErrorCode.invalidGrant,
    'CONSENT_REQUIRED': IAMErrorCode.consentRequired,
    'USER_ALREADY_EXISTS': IAMErrorCode.userAlreadyExists,
    'INVALID_INPUT': IAMErrorCode.invalidInput,
    'INVITATION_CODE_INVALID': IAMErrorCode.invitationCodeInvalid,
    'INVITATION_CODE_EXPIRED': IAMErrorCode.invitationCodeExpired,
    'REGISTRATION_DISABLED': IAMErrorCode.registrationDisabled,
    'RECOVERY_FAILED': IAMErrorCode.recoveryFailed,
    'CONFIRMATION_CODE_INVALID': IAMErrorCode.confirmationCodeInvalid,
    'CONFIRMATION_CODE_EXPIRED': IAMErrorCode.confirmationCodeExpired,
    'NETWORK_ERROR': IAMErrorCode.networkError,
    'REQUEST_TIMEOUT': IAMErrorCode.requestTimeout,
    'SERVER_ERROR': IAMErrorCode.serverError,
    'UNKNOWN_ERROR': IAMErrorCode.unknownError,
  };

  static IAMErrorCode fromString(String code) =>
      _codeMap[code] ?? IAMErrorCode.unknownError;

  String get value => name
      .replaceAllMapped(RegExp(r'[A-Z]'), (m) => '_${m[0]}')
      .toUpperCase()
      .replaceFirst('_', '');
}

class IAMException implements Exception {
  final IAMErrorCode code;
  final String message;
  final Object? cause;

  const IAMException(this.code, this.message, {this.cause});

  @override
  String toString() => '[${code.value}] $message';
}
