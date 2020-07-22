class Person {
  Person({
    this.name,
    this.email,
    this.home,
    this.image,
    this.birth,
  });

  factory Person.fromJson(Map<String, dynamic> data) {
    final String age = "${data['dob']['age']}";
    return Person(
      name:
          "${data['name']['title']} ${data['name']['first']} ${data['name']['last']}",
      email: "${data['email']}",
      home: "${data['location']['city']}, ${data['location']['state']}",
      image: "${data['picture']['large']}",
      birth: 2020 - int.parse(age),
    );
  }
  final String name;
  final String email;
  final String home;
  final String image;
  final int birth;

  @override
  String toString() {
    return 'name: $name email: $email home: $home image: $image age: $birth';
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'email': email,
      'home': home,
      'image': image,
      'birth': birth
    };
  }
}
