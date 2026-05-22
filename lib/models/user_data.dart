class UserData {
  final String uid;
  final String username;
  final String? name;
  String? profilePicUrl;
  String? coverPicUrl;
  String? jobTitle;
  String? organisation;
  String? location;
  String? address;
  List<String>? phoneNumbers;
  List<String>? emails;

  // Edit Content Type
  //links
  String? linkSectionHeader;
  List<String>? linksText;
  List<String>? linkUrl;
  //About me
  String? aboutMe;
  //Scoical
  List<String>? socialNames;
  List<String>? socialUrl;
  List<String>? socialIcons;
  //scheduling url
  String? scheduling;
  //

  UserData({
    required this.uid,
    required this.username,
    this.name,
    this.profilePicUrl,
    this.coverPicUrl,
    this.jobTitle,
    this.organisation,
    this.phoneNumbers,
    this.emails,

    //Edit Content Type
    this.aboutMe,
    //links
    this.linkSectionHeader,
    this.linksText,
    this.linkUrl,
    //
    this.socialIcons,
    this.socialNames,
    this.socialUrl,
    //
    this.scheduling,
  });

  UserData copyWith({
    String? name,
    String? profilePicUrl,
    String? coverPicUrl,
    String? jobTitle,
    String? organisation,
    List<String>? phoneNumbers,
    List<String>? emails,
    String? aboutMe,
    String? linkSectionHeader,
    List<String>? linksText,
    List<String>? linkUrl,
    List<String>? socialIcons,
    List<String>? socialNames,
    List<String>? socialUrl,
    String? scheduling,
  }) {
    return UserData(
      uid: uid,
      username: username,
      name: name ?? this.name,
      profilePicUrl: profilePicUrl ?? this.profilePicUrl,
      coverPicUrl: coverPicUrl ?? this.coverPicUrl,
      jobTitle: jobTitle ?? this.jobTitle,
      organisation: organisation ?? this.organisation,
      phoneNumbers: phoneNumbers ?? this.phoneNumbers,
      emails: emails ?? this.emails,
      linkSectionHeader: linkSectionHeader ?? this.linkSectionHeader,
      linksText: linksText ?? this.linksText,
      linkUrl: linkUrl ?? this.linkUrl,
      aboutMe: aboutMe ?? this.aboutMe,
      socialNames: socialNames ?? this.socialNames,
      socialUrl: socialUrl ?? this.socialUrl,
      socialIcons: socialIcons ?? this.socialIcons,
      scheduling: scheduling ?? this.scheduling,
    );
  }

  factory UserData.fromMap(Map<String, dynamic> data) {
    return UserData(
      uid: data['uid'],
      username: data['username'],
      name: data['name'],
      profilePicUrl: data['profilePicUrl'],
      coverPicUrl: data['coverPicUrl'],
      jobTitle: data['jobTitle'],
      organisation: data['organisation'],
      phoneNumbers: List<String>.from(data['phoneNumbers'] ?? []),
      emails: List<String>.from(data['emails'] ?? []),

      //Edit Content Type

      //links
      linksText: List<String>.from(data['linksText'] ?? []),
      linkSectionHeader: data['linkSectionHeader'],
      linkUrl: List<String>.from(data['linkUrl'] ?? []),
      //AboutMe
      aboutMe: data['aboutMe'],
      //socials
      socialIcons: List<String>.from(data['socialIcons'] ?? []),
      socialNames: List<String>.from(data['socialNames'] ?? []),
      socialUrl: List<String>.from(data['socialUrl'] ?? []),
      //expandableText
      scheduling: data['scheduling'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'name': name,
      'profilePicUrl': profilePicUrl,
      'coverPicUrl': coverPicUrl,
      'jobTitle': jobTitle,
      'organisation': organisation,
      'phoneNumbers': phoneNumbers ?? [],
      'emails': emails ?? [],

      //Edit Content Type
      //links
      'linksSectionHeader': linkSectionHeader,
      'linksText': linksText,
      'linkUrl': linkUrl,
      'aboutMe': aboutMe,
      'socialNames': socialNames,
      'socialUrl': socialUrl,
      'socialIcons': socialIcons,
      'scheduling': scheduling,
    };
  }
}
