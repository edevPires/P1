import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? username = prefs.getString('username');

  runApp(MyApp(initialRoute: username == null ? '/login' : '/home'));
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  MyApp({required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: initialRoute,
      routes: {
        '/login': (context) => LoginScreen(),
        '/home': (context) => Principal(),
      },
    );
  }
}

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    String path = join(await getDatabasesPath(), 'users.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE users(id INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT, password TEXT)',
        );
      },
    );
  }

  Future<void> insertUser(String username, String password) async {
    final db = await database;
    await db.insert(
      'users',
      {'username': username, 'password': password},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<bool> verifyUser(String username, String password) async {
    final db = await database;
    List<Map<String, dynamic>> users = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    return users.isNotEmpty;
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: usernameController,
                decoration: InputDecoration(labelText: 'Usuário'),
              ),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(labelText: 'Senha'),
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final db = DatabaseHelper();
                  bool isValid = await db.verifyUser(
                    usernameController.text,
                    passwordController.text,
                  );

                  if (isValid) {
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    prefs.setString('username', usernameController.text);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => Principal()),
                    );
                  } else {
                    // Exibir mensagem de erro
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Usuário ou senha inválidos')),
                    );
                  }
                },
                child: Text('Entrar'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterScreen()),
                  );
                },
                child: Text('Cadastrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastrar'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: usernameController,
                decoration: InputDecoration(labelText: 'Usuário'),
              ),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(labelText: 'Senha'),
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final db = DatabaseHelper();
                  await db.insertUser(
                    usernameController.text,
                    passwordController.text,
                  );
                  Navigator.pop(context);
                },
                child: Text('Cadastrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Principal extends StatefulWidget {
  @override
  State<Principal> createState() => _PrincipalState();
}

class _PrincipalState extends State<Principal> {
  final EventosRepository eventos = EventosRepository();

  @override
  void initState() {
    super.initState();
    eventos.loadEventos().then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agenda de Eventos'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.remove('username');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Cadastro(eventos: eventos),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 20.0),
                  child: Text("Cadastrar Evento"),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Listagem(eventos: eventos),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 20.0),
                  child: Text("Listar Eventos"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Listagem extends StatefulWidget {
  final EventosRepository eventos;
  Listagem({required this.eventos});

  @override
  State<Listagem> createState() => ListagemState(eventos: eventos);
}

class ListagemState extends State<Listagem> {
  final EventosRepository eventos;

  ListagemState({required this.eventos});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Listagem de Eventos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: eventos.getEventos().isEmpty
            ? Center(
                child: Text(
                  'Nenhum evento cadastrado',
                  style: TextStyle(fontSize: 18),
                ),
              )
            : ListView.builder(
                itemCount: eventos.getEventos().length,
                itemBuilder: (context, index) {
                  Evento e = eventos.getEventos()[index];
                  return Card(
                    child: ListTile(
                      title: Text(e.titulo,
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(e.data),
                      trailing: IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Edicao(
                                  evento: e, eventos: eventos, index: index),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class Edicao extends StatefulWidget {
  final Evento evento;
  final EventosRepository eventos;
  final int index;

  Edicao({required this.evento, required this.eventos, required this.index});

  @override
  _EdicaoState createState() => _EdicaoState();
}

class _EdicaoState extends State<Edicao> {
  late TextEditingController tituloController;
  late TextEditingController dataController;

  @override
  void initState() {
    super.initState();
    tituloController = TextEditingController(text: widget.evento.titulo);
    dataController = TextEditingController(text: widget.evento.data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edição de Evento'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: tituloController,
              decoration: InputDecoration(labelText: 'Título'),
            ),
            TextField(
              controller: dataController,
              decoration: InputDecoration(labelText: 'Data'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  widget.eventos.updateEvento(
                    widget.index,
                    Evento(titulo: tituloController.text, data: dataController.text),
                  );
                });
                Navigator.pop(context);
              },
              child: Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}

class Cadastro extends StatefulWidget {
  final EventosRepository eventos;

  Cadastro({required this.eventos});

  @override
  _CadastroState createState() => _CadastroState();
}

class _CadastroState extends State<Cadastro> {
  final TextEditingController tituloController = TextEditingController();
  final TextEditingController dataController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastrar Evento'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: tituloController,
              decoration: InputDecoration(labelText: 'Título'),
            ),
            TextField(
              controller: dataController,
              decoration: InputDecoration(labelText: 'Data'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  widget.eventos.addEvento(
                    Evento(titulo: tituloController.text, data: dataController.text),
                  );
                });
                Navigator.pop(context);
              },
              child: Text('Cadastrar'),
            ),
          ],
        ),
      ),
    );
  }
}

class Evento {
  String titulo;
  String data;

  Evento({required this.titulo, required this.data});
}

class EventosRepository {
  List<Evento> _eventos = [];

  List<Evento> getEventos() => _eventos;

  void addEvento(Evento evento) {
    _eventos.add(evento);
  }

  void updateEvento(int index, Evento evento) {
    _eventos[index] = evento;
  }

  Future<void> loadEventos() async {

  }
}
