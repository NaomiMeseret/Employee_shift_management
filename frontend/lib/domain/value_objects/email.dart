class Email {
  final String value;
  Email(this.value) {
    if (!RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}").hasMatch(value)) {
      throw FormatException('Invalid email format');
    }
  }
} 