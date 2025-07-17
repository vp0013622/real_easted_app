class RegisterPageProvider {
  // Page titles and headers
  static String title = "Register User";
  static String editTitle = "Edit User";
  static String greet = "Create a new user account";
  static String editGreet = "Update user information";

  // Form field labels
  static String role = "Role";
  static String email = "Email Address";
  static String firstName = "First Name";
  static String lastName = "Last Name";
  static String phoneNumber = "Phone Number";
  static String password = "Password";

  // Button labels
  static String registerButton = "Register User";
  static String saveChanges = "Save Changes";

  // Validation messages
  static String roleValidationMessage = "Role is required";
  static String emailValidationMessage = "Please enter a valid email address";
  static String firstNameValidationMessage = "First name is required";
  static String lastNameValidationMessage = "Last name is required";
  static String phoneNumberValidationMessage =
      "Please enter a valid phone number";
  static String passwordValidationMessage =
      "Password must be at least 6 characters";

  // Success/Error messages
  static String registrationSuccess = "User registered successfully";
  static String registrationError = "Registration failed. Please try again.";
  static String loadRolesError = "Failed to load roles. Please try again.";
}
