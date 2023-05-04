import 'package:flutter/material.dart';
import 'package:rate_it/auth/Authentication.dart';
import '../firestore/database.dart';
import '../model/user.dart';
import 'package:rate_it/auth/validation.dart';

class ChangeName extends StatefulWidget {
  const ChangeName({super.key});


  @override
  State<ChangeName> createState() => _ChangeNameState();
}

class _ChangeNameState extends State<ChangeName> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Change Name'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: TextFormField(
                      controller: _firstNameController,
                      keyboardType: TextInputType.name,
                      decoration: InputDecoration(
                        labelText: 'First Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your first name';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: TextFormField(
                      controller: _lastNameController,
                      keyboardType: TextInputType.name,
                      decoration: InputDecoration(
                        labelText: 'Last Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your last name';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
              ],
              ),
              ElevatedButton(
                onPressed: () async {
                  String uid = Authentication.auth.currentUser!.uid;
                  if (_formKey.currentState!.validate()) {
                    String firstName = _firstNameController.text;
                    String lastName = _lastNameController.text;
                    Database.updateName(uid, firstName, lastName);
                    Navigator.pop(context);
                  }
                },
                child: Text('Save changes'),
              ),
            ]
          ),
        ),
      ),
    );
  }
}

class ChangeBio extends StatefulWidget {
  const ChangeBio({super.key});


  @override
  State<ChangeBio> createState() => _ChangeBioState();
}

class _ChangeBioState extends State<ChangeBio> {
  TextEditingController _bioController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Change Biography'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Biography',
                  border: OutlineInputBorder(),
                ),
                controller: _bioController,
                keyboardType: TextInputType.multiline,
                minLines: 1,
                maxLines: 5,
              ),
              ElevatedButton(
                onPressed: () async {
                  String uid = Authentication.auth.currentUser!.uid;
                  String bio = _bioController.text;
                  Database.updateBio(uid, bio);
                  Navigator.pop(context);
                },
                child: Text('Save changes'),
              ),
            ],
        ),
      ),
    );
  }
}


class ChangePhone extends StatefulWidget {
  const ChangePhone({super.key});


  @override
  State<ChangePhone> createState() => _ChangePhoneState();
}

class _ChangePhoneState extends State<ChangePhone> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Change Biography'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                decoration: InputDecoration(
                    labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                minLines: 1,
                validator: (value){
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  if(Validation.invalidPhone(value)){
                    return 'Enter valid PT phone number';
                  }
                  return null;
                },
              ),
              ElevatedButton(
                onPressed: () async {
                  if(_formKey.currentState!.validate()){
                    String uid = Authentication.auth.currentUser!.uid;
                    String phone = _phoneController.text;
                    Database.updatePhone(uid, phone);
                    Navigator.pop(context);
                  }
                },
                child: Text('Save changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class SettingsPage1 extends StatefulWidget {
  const SettingsPage1({
    Key? key,
    required this.user,
  }) : super(key: key);

  final User user;

  @override
  State<SettingsPage1> createState() => _SettingsPageState1();
}

class _SettingsPageState1 extends State<SettingsPage1> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  bool usedUsername = false;

  Future<void> checkUsername(String value) async {
    bool ans = await Validation.usedUsername(value);
    setState(() {
      usedUsername = ans;
    });

  }

  @override
  void initState() {
    super.initState();
    _firstNameController.text = widget.user.firstName;
    _lastNameController.text = widget.user.lastName;
    _usernameController.text = widget.user.username;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form (
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  hintText: 'Enter your first name',
                  border: OutlineInputBorder(),

                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your first name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              const SizedBox(height: 8),
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(
                  hintText: 'Enter your last name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your last name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),

                validator: (value) {
                  if (Validation.emptyField(value)) {
                    return 'Please enter your password';
                  }
                  if (Validation.shortPassword(value)) {
                    return 'Password must be at least 6 characters long';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Enter a new password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Processing Data')),
                    );
                  }
                  // Update user profile with new info
                  String uid = Authentication.auth.currentUser!.uid;
                  String firstName = _firstNameController.text;
                  String lastName = _lastNameController.text;
                  String username = _usernameController.text;
                  String password = _passwordController.text;
                  if (firstName != widget.user.firstName ||
                      lastName != widget.user.lastName) {
                    Database.updateName(uid, firstName, lastName);
                    setState(() {
                      widget.user.firstName = firstName;
                      widget.user.lastName = lastName;
                    });
                  }
                  if (username != widget.user.username) {
                    await checkUsername(username);
                    if(!usedUsername){
                      Database.updateUsername(uid, username);
                    }
                  }
                  if (password.isNotEmpty) {
                    //Authentication.updatePassword(password);
                  }
                },
                child: Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
