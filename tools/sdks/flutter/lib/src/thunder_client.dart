import 'channel/thunder_channel.dart';
import 'models/iam_error.dart';
import 'models/thunder_config.dart';
import 'models/user.dart';
import 'models/user_profile.dart';
import 'models/organization.dart';
import 'models/token_response.dart';
import 'models/flow_models.dart';
import 'models/sign_in_options.dart';
import 'models/sign_out_options.dart';
import 'models/token_exchange_config.dart';

/// Flutter SDK client — Core Lib layer, delegates all protocol operations to
/// the native iOS and Android Platform SDKs via [ThunderChannel] (spec §7.1).
class ThunderClient {
  final ThunderChannel _channel;
  bool _initialized = false;
  bool _isLoading = false;

  ThunderClient({ThunderChannel? channel}) : _channel = channel ?? ThunderChannel();

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  /// Initializes the SDK. Must be called once before any other method (spec §5.1).
  Future<bool> initialize(ThunderConfig config) async {
    if (_initialized) {
      throw const IAMException(IAMErrorCode.alreadyInitialized, 'SDK is already initialized');
    }
    final result = await _channel.invoke<bool>('initialize', config.toMap());
    _initialized = result ?? false;
    return _initialized;
  }

  Future<bool> reInitialize({String? baseUrl, String? clientId}) async {
    _requireInitialized();
    final result = await _channel.invoke<bool>('reInitialize', {
      if (baseUrl != null) 'baseUrl': baseUrl,
      if (clientId != null) 'clientId': clientId,
    });
    return result ?? false;
  }

  // ── Authentication ────────────────────────────────────────────────────────

  /// App-native sign-in via Flow Execution API (spec §6.1).
  Future<EmbeddedFlowResponse> signIn({
    required EmbeddedSignInPayload payload,
    required EmbeddedFlowRequestConfig request,
    String? sessionId,
  }) async {
    _requireInitialized();
    _isLoading = true;
    try {
      final result = await _channel.invokeMap('signIn', {
        'payload': payload.toMap(),
        'request': request.toMap(),
        if (sessionId != null) 'sessionId': sessionId,
      });
      return EmbeddedFlowResponse.fromMap(result);
    } finally {
      _isLoading = false;
    }
  }

  /// Builds the redirect-based sign-in URL. Open this in an in-app browser or
  /// custom tab, then call [handleRedirectCallback] with the callback URL.
  Future<String> buildSignInUrl({SignInOptions? options}) async {
    _requireInitialized();
    final result = await _channel.invoke<String>('buildSignInUrl', {
      if (options != null) 'options': options.toMap(),
    });
    return result ?? '';
  }

  /// Handles the callback URL after a redirect-based sign-in (spec §6.1).
  Future<User> handleRedirectCallback(String url) async {
    _requireInitialized();
    _isLoading = true;
    try {
      final result = await _channel.invokeMap('handleRedirectCallback', {'url': url});
      return User.fromMap(result);
    } finally {
      _isLoading = false;
    }
  }

  Future<String> signOut({SignOutOptions? options, String? sessionId}) async {
    _requireInitialized();
    _isLoading = true;
    try {
      final result = await _channel.invoke<String>('signOut', {
        if (options != null) 'options': options.toMap(),
        if (sessionId != null) 'sessionId': sessionId,
      });
      return result ?? '/';
    } finally {
      _isLoading = false;
    }
  }

  Future<bool> isSignedIn({String? sessionId}) async {
    _requireInitialized();
    final result = await _channel.invoke<bool>('isSignedIn', {
      if (sessionId != null) 'sessionId': sessionId,
    });
    return result ?? false;
  }

  /// Synchronous — reflects whether the SDK is mid-initialization or mid-token-refresh (spec §7.1).
  bool isLoading() => _isLoading;

  // ── Registration ──────────────────────────────────────────────────────────

  Future<EmbeddedFlowResponse> signUp({
    EmbeddedSignInPayload? payload,
    EmbeddedFlowRequestConfig? request,
  }) async {
    _requireInitialized();
    final result = await _channel.invokeMap('signUp', {
      if (payload != null) 'payload': payload.toMap(),
      if (request != null) 'request': request.toMap(),
    });
    return EmbeddedFlowResponse.fromMap(result);
  }

  // ── Token & Session ───────────────────────────────────────────────────────

  Future<String> getAccessToken({String? sessionId}) async {
    _requireInitialized();
    final result = await _channel.invoke<String>('getAccessToken', {
      if (sessionId != null) 'sessionId': sessionId,
    });
    return result ?? '';
  }

  Future<Map<String, dynamic>> decodeJwtToken(String token) async {
    _requireInitialized();
    final result = await _channel.invokeMap('decodeJwtToken', {'token': token});
    return result.cast<String, dynamic>();
  }

  Future<TokenResponse> exchangeToken(TokenExchangeRequestConfig config, {String? sessionId}) async {
    _requireInitialized();
    final result = await _channel.invokeMap('exchangeToken', {
      'config': config.toMap(),
      if (sessionId != null) 'sessionId': sessionId,
    });
    return TokenResponse.fromMap(result);
  }

  void clearSession({String? sessionId}) {
    if (!_initialized) return;
    _channel.invoke<void>('clearSession', {
      if (sessionId != null) 'sessionId': sessionId,
    });
  }

  // ── User & Profile ────────────────────────────────────────────────────────

  Future<User> getUser({Map<String, dynamic>? options}) async {
    _requireInitialized();
    final result = await _channel.invokeMap('getUser', options);
    return User.fromMap(result);
  }

  Future<UserProfile> getUserProfile({Map<String, dynamic>? options}) async {
    _requireInitialized();
    final result = await _channel.invokeMap('getUserProfile', options);
    return UserProfile.fromMap(result);
  }

  Future<User> updateUserProfile(Map<String, dynamic> payload, {String? userId}) async {
    _requireInitialized();
    final result = await _channel.invokeMap('updateUserProfile', {
      'payload': payload,
      if (userId != null) 'userId': userId,
    });
    return User.fromMap(result);
  }

  // ── Organizations ─────────────────────────────────────────────────────────

  Future<AllOrganizationsResponse> getAllOrganizations({
    Map<String, dynamic>? options,
    String? sessionId,
  }) async {
    _requireInitialized();
    final result = await _channel.invokeMap('getAllOrganizations', {
      if (options != null) ...options,
      if (sessionId != null) 'sessionId': sessionId,
    });
    return AllOrganizationsResponse.fromMap(result);
  }

  Future<List<Organization>> getMyOrganizations({String? sessionId}) async {
    _requireInitialized();
    final result = await _channel.invokeList('getMyOrganizations', {
      if (sessionId != null) 'sessionId': sessionId,
    });
    return result.map((o) => Organization.fromMap(o as Map)).toList();
  }

  Future<Organization?> getCurrentOrganization({String? sessionId}) async {
    _requireInitialized();
    final result = await _channel.invoke<Map>('getCurrentOrganization', {
      if (sessionId != null) 'sessionId': sessionId,
    });
    return result != null ? Organization.fromMap(result) : null;
  }

  Future<Organization> createOrganization({
    required String name,
    String? handle,
    String? sessionId,
  }) async {
    _requireInitialized();
    final result = await _channel.invokeMap('createOrganization', {
      'name': name,
      if (handle != null) 'handle': handle,
      if (sessionId != null) 'sessionId': sessionId,
    });
    return Organization.fromMap(result);
  }

  Future<TokenResponse> switchOrganization(Organization organization, {String? sessionId}) async {
    _requireInitialized();
    final result = await _channel.invokeMap('switchOrganization', {
      'organization': organization.toMap(),
      if (sessionId != null) 'sessionId': sessionId,
    });
    return TokenResponse.fromMap(result);
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  void _requireInitialized() {
    if (!_initialized) {
      throw const IAMException(
        IAMErrorCode.sdkNotInitialized,
        'Call initialize() before using the SDK',
      );
    }
  }
}
