import 'package:flutter/material.dart';

void main() {
  runApp(BookBorrowingApp());
}

// Model Siswa
class Student {
  String name;
  String username;
  String password;

  Student(this.name, this.username, this.password);
}

// Daftar siswa global
List<Student> students = [];

// Variabel global untuk menyimpan nama pengguna yang login
String loggedInUsername = '';
String loggedInRole = '';

// Aplikasi Peminjaman Buku
class BookBorrowingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Peminjaman Buku',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(),
      debugShowCheckedModeBanner: false, // Menghilangkan tanda debug
    );
  }
}

// Halaman Login
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login(String role) {
  String username = _usernameController.text;
  String password = _passwordController.text;

  if (username.isEmpty || password.isEmpty) {
    _showSnackbar('Username dan Password tidak boleh kosong');
    return;
  }

  // Login Siswa
  if (role == 'siswa') {
    final student = students.firstWhere(
      (student) => student.username == username && student.password == password,
      orElse: () => Student('', '', ''), // Ganti dengan objek Student kosong
    );

    if (student.username.isNotEmpty) { // Cek apakah siswa ditemukan
      setState(() {
        loggedInUsername = student.name;
        loggedInRole = 'siswa';
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen(role: 'siswa')),
      );
    } else {
      _showSnackbar('Username atau Password salah');
    }
  }
  // Login Admin
  else if (role == 'admin' && username == 'admin' && password == 'password') {
    setState(() {
      loggedInUsername = username;
      loggedInRole = 'admin';
    });
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen(role: 'admin')),
    );
  } else {
    _showSnackbar('Username atau Password salah');
  }
}


  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _login('siswa'),
              child: Text('Login sebagai Siswa'),
            ),
            ElevatedButton(
              onPressed: () => _login('admin'),
              child: Text('Login sebagai Admin'),
            ),
          ],
        ),
      ),
    );
  }
}

// Halaman Utama dengan Navbar
class HomeScreen extends StatefulWidget {
  final String role;

  HomeScreen({required this.role});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    DashboardScreen(),
    BookListScreen(),
    ProfileScreen(),
  ];

  final List<Widget> _adminPages = [
    DashboardScreen(),
    BookManagementScreen(),
    StudentManagementScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.role == 'admin' ? 'Admin Dashboard' : 'Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: widget.role == 'admin' ? _adminPages[_selectedIndex] : _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Daftar Buku'),
          if (widget.role == 'admin')
            BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Kelola Siswa'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

// Halaman Dashboard
class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Selamat Datang di Aplikasi Peminjaman Buku',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}

// Halaman Daftar Buku untuk Siswa
class BookListScreen extends StatefulWidget {
  @override
  _BookListScreenState createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  final List<Book> books = [
    Book('Flutter for Beginners', 'John Doe', 'Panduan lengkap untuk belajar Flutter dari awal.', false),
    Book('Dart Programming Guide', 'Jane Smith', 'Panduan mendalam tentang pemrograman dengan Dart.', false),
    Book('Advanced Flutter', 'Michael Brown', 'Pelajari teknik Flutter lanjutan untuk aplikasi profesional.', false),
  ];

  void _toggleBorrowStatus(int index) {
    setState(() {
      books[index].isBorrowed = !books[index].isBorrowed;
    });

    final message = books[index].isBorrowed
        ? 'Anda meminjam buku "${books[index].title}"'
        : 'Anda mengembalikan buku "${books[index].title}"';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Buku'),
      ),
      body: ListView.builder(
        itemCount: books.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(books[index].title),
            subtitle: Text('Penulis: ${books[index].author}'),
            trailing: ElevatedButton(
              onPressed: () => _toggleBorrowStatus(index),
              child: Text(books[index].isBorrowed ? 'Kembalikan' : 'Pinjam'),
            ),
          );
        },
      ),
    );
  }
}


// Model Buku
class Book {
  String title;
  String author;
  String description;
  bool isBorrowed;

  Book(this.title, this.author, this.description, this.isBorrowed);
}

// Halaman Kelola Siswa (Khusus Admin)
class StudentManagementScreen extends StatefulWidget {
  @override
  _StudentManagementScreenState createState() => _StudentManagementScreenState();
}

class _StudentManagementScreenState extends State<StudentManagementScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _addStudent() {
    if (_nameController.text.isEmpty || _usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnackbar('Semua kolom harus diisi');
      return;
    }

    setState(() {
      students.add(Student(
        _nameController.text,
        _usernameController.text,
        _passwordController.text,
      ));
    });

    _nameController.clear();
    _usernameController.clear();
    _passwordController.clear();
    _showSnackbar('Siswa berhasil ditambahkan');
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kelola Siswa'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Nama Siswa'),
            ),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addStudent,
              child: Text('Tambah Siswa'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: students.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(students[index].name),
                    subtitle: Text('Username: ${students[index].username}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Halaman Profil
class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Profil Pengguna: $loggedInUsername\nRole: $loggedInRole',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// Halaman Manajemen Buku (Khusus Admin)
class BookManagementScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Halaman Manajemen Buku (Admin)',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}