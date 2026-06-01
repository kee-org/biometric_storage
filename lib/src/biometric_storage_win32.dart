import 'dart:convert';
import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:logging/logging.dart';
import 'package:win32/win32.dart';

import './biometric_storage.dart';

final _logger = Logger('biometric_storage_win32');

class Win32BiometricStoragePlugin extends BiometricStorage {
  Win32BiometricStoragePlugin() : super.create();

  static const namePrefix = 'design.codeux.authpass.';

  /// Registers this class as the default instance of [PathProviderPlatform]
  static void registerWith() {
    BiometricStorage.instance = Win32BiometricStoragePlugin();
  }

  @override
  Future<CanAuthenticateResponse> canAuthenticate({
    StorageFileInitOptions? options,
  }) async {
    return CanAuthenticateResponse.errorHwUnavailable;
  }

  @override
  Future<BiometricStorageFile> getStorage(
    String name, {
    StorageFileInitOptions? options,
    bool forceInit = false,
    PromptInfo promptInfo = PromptInfo.defaultValues,
  }) async {
    return BiometricStorageFile(this, namePrefix + name, promptInfo);
  }

  @override
  Future<bool> linuxCheckAppArmorError() async => false;

  @override
  Future<bool> delete(
    String name,
    PromptInfo promptInfo,
  ) async {
    final namePointer = name.toPcwstr(allocator: calloc);
    try {
      final result = CredDelete(namePointer, CRED_TYPE_GENERIC);
      if (!result.value) {
        if (result.error == ERROR_NOT_FOUND) {
          _logger.fine('Unable to find credential of name $name');
        } else {
          _logger.warning('Error: ${result.error}');
        }
        return false;
      }
    } finally {
      calloc.free(namePointer);
    }
    return true;
  }

  @override
  Future<String?> read(
    String name,
    PromptInfo promptInfo,
  ) async {
    _logger.finer('read($name)');
    final credPointer = calloc<Pointer<CREDENTIAL>>();
    final namePointer = name.toPcwstr(allocator: calloc);
    try {
      final result = CredRead(namePointer, CRED_TYPE_GENERIC, credPointer);
      if (!result.value) {
        if (result.error == ERROR_NOT_FOUND) {
          _logger.fine('Unable to find credential of name $name');
        } else {
          _logger.warning(
              'Error: ${result.error} ', WindowsException(result.error.toHRESULT()));
        }
        return null;
      }
      final cred = credPointer.value.ref;
      final blob = cred.CredentialBlob.asTypedList(cred.CredentialBlobSize);

      _logger.fine('CredFree()');
      CredFree(credPointer.value);

      return utf8.decode(blob);
    } finally {
      _logger.fine('free(credPointer)');
      calloc.free(credPointer);
      _logger.fine('free(namePointer)');
      calloc.free(namePointer);
      _logger.fine('read($name) done.');
    }
  }

  @override
  Future<void> write(
    String name,
    String content,
    PromptInfo promptInfo,
  ) async {
    _logger.fine('write()');
    final examplePassword = utf8.encode(content);
    final blob = examplePassword.toNative(allocator: calloc);
    final namePointer = name.toPwstr(allocator: calloc);
    final userNamePointer = 'flutter.biometric_storage'.toPwstr(allocator: calloc);

    final credential = calloc<CREDENTIAL>()
      ..ref.Type = CRED_TYPE_GENERIC
      ..ref.TargetName = namePointer
      ..ref.Persist = CRED_PERSIST_LOCAL_MACHINE
      ..ref.UserName = userNamePointer
      ..ref.CredentialBlob = blob
      ..ref.CredentialBlobSize = examplePassword.length;
    try {
      final result = CredWrite(credential, 0);
      if (!result.value) {
        throw BiometricStorageException(
            'Error writing credential $name: ${result.error}');
      }
    } finally {
      _logger.fine('free');
      calloc.free(blob);
      calloc.free(credential);
      calloc.free(namePointer);
      calloc.free(userNamePointer);
      _logger.fine('free done');
    }
  }

  @override
  Future<void> dispose(String name, PromptInfo promptInfo) async {
    // Nothing to dispose for Win32 implementation
  }
}
