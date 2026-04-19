class Organization {
  final String id;
  final String name;
  final String? handle;

  const Organization({required this.id, required this.name, this.handle});

  factory Organization.fromMap(Map<dynamic, dynamic> map) => Organization(
        id: map['id'] as String,
        name: map['name'] as String,
        handle: map['handle'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        if (handle != null) 'handle': handle,
      };
}

class AllOrganizationsResponse {
  final List<Organization> organizations;
  final int? totalCount;
  final String? nextPage;

  const AllOrganizationsResponse({
    required this.organizations,
    this.totalCount,
    this.nextPage,
  });

  factory AllOrganizationsResponse.fromMap(Map<dynamic, dynamic> map) =>
      AllOrganizationsResponse(
        organizations: (map['organizations'] as List)
            .map((o) => Organization.fromMap(o as Map))
            .toList(),
        totalCount: map['totalCount'] as int?,
        nextPage: map['nextPage'] as String?,
      );
}
