import 'package:flutter/material.dart';
import '../Controllers/verduracontroller.dart';
import '../Models/verduramodel.dart';

class VerduraListScreen extends StatefulWidget {
  const VerduraListScreen({super.key});

  @override
  _VerduraListScreenState createState() => _VerduraListScreenState();
}

class _VerduraListScreenState extends State<VerduraListScreen> {
  final VerduraService _verduraService = VerduraService();
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await _verduraService.fetchVerduras();
    } catch (e) {
      _errorMessage = e.toString();
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _showFormDialog({Verdura? verdura}) async {
    final isEdit = verdura != null;
    final TextEditingController codigoController =
        TextEditingController(text: isEdit ? verdura.codigo.toString() : '');
    final TextEditingController descripcionController =
        TextEditingController(text: isEdit ? verdura.descripcion : '');
    final TextEditingController precioController =
        TextEditingController(text: isEdit ? verdura.precio.toString() : '');

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEdit ? 'Editar Verdura' : 'Agregar Verdura'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: codigoController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Código'),
                enabled: !isEdit,
              ),
              TextField(
                controller: descripcionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
              ),
              TextField(
                controller: precioController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Precio'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                final int codigo = int.tryParse(codigoController.text) ?? 0;
                final String descripcion = descripcionController.text;
                final double precio =
                    double.tryParse(precioController.text) ?? 0.0;

                if (codigo > 0 && descripcion.isNotEmpty && precio > 0.0) {
                  final nuevaVerdura = Verdura(
                    codigo: codigo,
                    descripcion: descripcion,
                    precio: precio,
                  );

                  setState(() {
                    if (isEdit) {
                      _verduraService.updateVerdura(codigo, nuevaVerdura);
                    } else {
                      _verduraService.addVerdura(nuevaVerdura);
                    }
                  });

                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Por favor completa todos los campos correctamente.')),
                  );
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _deleteVerdura(int codigo) {
    setState(() {
      _verduraService.deleteVerdura(codigo);
    });
  }

  @override
  Widget build(BuildContext context) {
    final verduras = _verduraService.getAllVerduras();

    return Scaffold(
      appBar: AppBar(
        title: const Text('CRUD de Verduras'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.pinkAccent, Colors.lightBlueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : verduras.isEmpty
                  ? const Center(child: Text('No hay verduras disponibles'))
                  : ListView.builder(
                      itemCount: verduras.length,
                      itemBuilder: (context, index) {
                        final verdura = verduras[index];
                        return MouseRegion(
                          onEnter: (_) => setState(() {}),
                          child: GestureDetector(
                            onTap: () {},
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Colors.pinkAccent,
                                    Colors.lightBlueAccent
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(15.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 5.0,
                                    offset: Offset(2, 2),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                title: Text(verdura.descripcion,
                                    style:
                                        const TextStyle(color: Colors.black)),
                                subtitle: Text(
                                    'Precio: \$${verdura.precio.toStringAsFixed(2)}',
                                    style:
                                        const TextStyle(color: Colors.black87)),
                                leading: CircleAvatar(
                                  backgroundColor: Colors.white24,
                                  child: Text(
                                    '${verdura.codigo}',
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.black),
                                      onPressed: () =>
                                          _showFormDialog(verdura: verdura),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () =>
                                          _deleteVerdura(verdura.codigo),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFormDialog(),
        tooltip: 'Agregar Verdura',
        backgroundColor: Colors.pinkAccent,
        child: const Icon(Icons.add),
      ),
    );
  }
}
