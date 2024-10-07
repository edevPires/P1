import 'package:flutter/material.dart';
import 'dart:convert'; 
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Principal(),
    );
  }
}

class Cadastro extends StatefulWidget {
  final EventosRepository eventos;
  Cadastro({required this.eventos});

  @override
  State<Cadastro> createState() => _CadastroState(eventos: eventos);
}

class _CadastroState extends State<Cadastro> {
  final TextEditingController tituloController = TextEditingController();
  final TextEditingController dataController = TextEditingController();
  final EventosRepository eventos;

  _CadastroState({required this.eventos});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastro de Evento'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Título do Evento',
                  border: OutlineInputBorder(),
                ),
                controller: tituloController,
              ),
              SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Data do Evento (dd/mm/yyyy)',
                  border: OutlineInputBorder(),
                ),
                controller: dataController,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    eventos.addEvento(Evento(
                        titulo: tituloController.text,
                        data: dataController.text));
                  });
                  Navigator.pop(context);
                },
                child: Text('Salvar'),
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Título do Evento',
                  border: OutlineInputBorder(),
                ),
                controller: tituloController,
              ),
              SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Data do Evento (dd/mm/yyyy)',
                  border: OutlineInputBorder(),
                ),
                controller: dataController,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    widget.eventos.updateEvento(
                        widget.index,
                        Evento(
                            titulo: tituloController.text,
                            data: dataController.text));
                  });
                  Navigator.pop(context);
                },
                child: Text('Salvar Alterações'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Evento {
  String titulo;
  String data;

  Evento({required this.titulo, required this.data});

  Map<String, dynamic> toJson() {
    return {
      'titulo': titulo,
      'data': data,
    };
  }

  factory Evento.fromJson(Map<String, dynamic> json) {
    return Evento(
      titulo: json['titulo'],
      data: json['data'],
    );
  }
}

class EventosRepository {
  final List<Evento> eventos = [];

  Future<void> addEvento(Evento e) async {
    eventos.add(e);
    await saveEventos();
  }

  List<Evento> getEventos() {
    return eventos;
  }

  Future<void> updateEvento(int index, Evento e) async {
    eventos[index] = e;
    await saveEventos();
  }

  Future<void> saveEventos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> eventosJson =
        eventos.map((evento) => jsonEncode(evento.toJson())).toList();
    prefs.setStringList('eventos', eventosJson);
  }

  Future<void> loadEventos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? eventosJson = prefs.getStringList('eventos');
    if (eventosJson != null) {
      eventos.clear();
      eventos.addAll(
          eventosJson.map((evento) => Evento.fromJson(jsonDecode(evento))));
    }
  }
}
