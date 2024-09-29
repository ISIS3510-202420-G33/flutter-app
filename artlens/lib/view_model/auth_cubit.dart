import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../entities/user.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class Authenticated extends AuthState {
  final User user;
  Authenticated(this.user);
}

class Unauthenticated extends AuthState {}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  // Log in and save user session
  Future<void> logIn(User user) async {
    emit(Authenticated(user));  // Emit authenticated state immediately
    await _saveUserSession(user);  // Save session in SharedPreferences
  }

  // Log out and clear user session
  Future<void> logOut() async {
    emit(Unauthenticated());  // Emit unauthenticated state immediately
    await _clearUserSession();  // Clear session from SharedPreferences
  }

  // Check if the user is logged in
  bool isLoggedIn() {
    return state is Authenticated;
  }

  // Save the user session in SharedPreferences (only id and name)
  Future<void> _saveUserSession(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('id', user.id);
    await prefs.setString('userName', user.userName);
  }

  // Clear the user session from SharedPreferences
  Future<void> _clearUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();  // Clears all stored preferences
  }

  // Optionally: Load the user session on startup (only id and name)
  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('id');
    final userName = prefs.getString('userName');

    // Check if user data exists, if so, emit Authenticated state
    if (id != null && userName != null) {
      emit(Authenticated(User(
        id: id,
        userName: userName,
        name: '',  // Set empty or default value for name
        email: '',  // Set empty or default value for email
        likedArtworks: [],  // Set empty list for liked artworks
      )));
    }
  }
}
