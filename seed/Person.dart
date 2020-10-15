class Person {
  Person({
    this.name,
    this.email,
    this.home,
    this.image,
  });

  factory Person.fromJson(Map<String, dynamic> data) {
    return Person(
      name:
          "${data['name']['title']} ${data['name']['first']} ${data['name']['last']}",
      email: "${data['email']}",
      home: "${data['location']['city']}, ${data['location']['state']}",
      image: "${data['picture']['large']}",
    );
  }
  final String name;
  String email;
  final String home;
  final String image;

  @override
  String toString() {
    return 'name: $name email: $email home: $home image: $image ';
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'email': email,
      'home': home,
      'image': image,
    };
  }
}
