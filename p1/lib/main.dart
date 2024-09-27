import 'package:flutter/material.dart';

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

class Principal extends StatelessWidget {
  final EventosRepository eventos = EventosRepository();

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

class Listagem extends StatelessWidget {
  final EventosRepository eventos;
  Listagem({required this.eventos});

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
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(e.titulo),
                      subtitle: Text(e.data),
                    ),
                  );
                },
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
  final List<Evento> eventos = [];

  void addEvento(Evento e) {
    eventos.add(e);
  }

  List<Evento> getEventos() {
    return eventos;
  }
}
