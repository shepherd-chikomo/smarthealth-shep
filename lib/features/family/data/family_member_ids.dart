/// Whether [id] is a server-issued family member UUID.
bool isServerFamilyMemberId(String id) {
  return RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
    caseSensitive: false,
  ).hasMatch(id);
}

/// Local-only ids from demo seed or offline client generation.
bool isLocalOnlyFamilyMemberId(String id) =>
    id.isEmpty || !isServerFamilyMemberId(id);
