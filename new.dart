class Person{
    final String name; 
    final int age;

    Person({required this.name, required this.age});
}

void main(){
    Person p1 = Person(name: "Mitul", age: 25);
    print("Hi ${p1.name}, Are you ${p1.age} years old?");

}


