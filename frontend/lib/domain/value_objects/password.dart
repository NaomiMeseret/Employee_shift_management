class Password {
  final String value;
  Password(this.value) {
    if (value.length < 6) {
      throw FormatException('Password must be at least 6 characters');
    }
  }
} 