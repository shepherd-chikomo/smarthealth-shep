/// Clears session-scoped secure data on sign-out.
class SecureDataWipe {
  SecureDataWipe({Future<void> Function()? onSignOutHook})
      : _onSignOutHook = onSignOutHook;

  final Future<void> Function()? _onSignOutHook;

  Future<void> onSignOut() async {
    await _onSignOutHook?.call();
  }

  Future<void> onAccountDeletion() async {
    await _onSignOutHook?.call();
  }
}
