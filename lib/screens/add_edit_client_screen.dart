import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/client_model.dart';
import '../providers/client_provider.dart';

class AddEditClientScreen extends StatefulWidget {
  final Client? client;

  const AddEditClientScreen({super.key, this.client});

  @override
  State<AddEditClientScreen> createState() => _AddEditClientScreenState();
}

class _AddEditClientScreenState extends State<AddEditClientScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _lastName;
  late String _username;
  late String _password;
  late String? _url;
  late String _phone;
  late DateTime _startDate;
  late DateTime _endDate;
  late int _months;
  late double _price;
  late String? _referredBy;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    if (widget.client != null) {
      _name = widget.client!.name;
      _lastName = widget.client!.lastName;
      _username = widget.client!.username;
      _password = widget.client!.password;
      _url = widget.client!.url;
      _phone = widget.client!.phone;
      _startDate = widget.client!.startDate;
      _endDate = widget.client!.endDate;
      _months = widget.client!.months;
      _price = widget.client!.price;
      _referredBy = widget.client!.referredBy;
    } else {
      _name = '';
      _lastName = '';
      _username = '';
      _password = '';
      _url = '';
      _phone = '';
      _startDate = DateTime.now();
      _endDate = DateTime.now().add(const Duration(days: 30));
      _months = 1;
      _price = 0.0;
      _referredBy = '';
    }
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final newClient = Client(
        id: widget.client?.id,
        name: _name,
        lastName: _lastName,
        username: _username,
        password: _password,
        url: _url,
        phone: _phone,
        startDate: _startDate,
        endDate: _endDate,
        months: _months,
        price: _price,
        referredBy: _referredBy,
      );

      if (widget.client == null) {
        Provider.of<ClientProvider>(context, listen: false).addClient(newClient);
      } else {
        Provider.of<ClientProvider>(context, listen: false).updateClient(newClient);
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.client == null ? 'Añadir Cliente' : 'Editar Cliente'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Nombre'),
                autofocus: false,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Por favor, ingrese un nombre.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _name = value!;
                },
              ),
              TextFormField(
                initialValue: _lastName,
                decoration: const InputDecoration(labelText: 'Apellido'),
                autofocus: false,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Por favor, ingrese un apellido.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _lastName = value!;
                },
              ),
              TextFormField(
                initialValue: _username,
                decoration: const InputDecoration(labelText: 'Usuario'),
                autofocus: false,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Por favor, ingrese un nombre de usuario.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _username = value!;
                },
              ),
              TextFormField(
                initialValue: _password,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
                obscureText: !_isPasswordVisible,
                autofocus: false,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Por favor, ingrese una contraseña.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _password = value!;
                },
              ),
              TextFormField(
                initialValue: _url,
                decoration: const InputDecoration(labelText: 'URL'),
                autofocus: false,
                textInputAction: TextInputAction.next,
                onSaved: (value) {
                  _url = value;
                },
              ),
              TextFormField(
                initialValue: _phone,
                decoration: const InputDecoration(labelText: 'Teléfono'),
                keyboardType: TextInputType.phone,
                autofocus: false,
                textInputAction: TextInputAction.next,
                onSaved: (value) {
                  _phone = value!;
                },
              ),
              TextFormField(
                initialValue: _referredBy,
                decoration: const InputDecoration(labelText: 'Referido por'),
                autofocus: false,
                textInputAction: TextInputAction.next,
                onSaved: (value) {
                  _referredBy = value;
                },
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                        'Fecha de inicio: ${DateFormat.yMd().format(_startDate)}'),
                  ),
                  TextButton(
                    child: const Text('Cambiar'),
                    onPressed: () {
                      showDatePicker(
                        context: context,
                        initialDate: _startDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      ).then((pickedDate) {
                        if (pickedDate != null) {
                          setState(() {
                            _startDate = pickedDate;
                          });
                        }
                      });
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child:
                        Text('Fecha de fin: ${DateFormat.yMd().format(_endDate)}'),
                  ),
                  TextButton(
                    child: const Text('Cambiar'),
                    onPressed: () {
                      showDatePicker(
                        context: context,
                        initialDate: _endDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      ).then((pickedDate) {
                        if (pickedDate != null) {
                          setState(() {
                            _endDate = pickedDate;
                          });
                        }
                      });
                    },
                  ),
                ],
              ),
              TextFormField(
                initialValue: _months.toString(),
                decoration: const InputDecoration(labelText: 'Meses'),
                keyboardType: TextInputType.number,
                autofocus: false,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value!.isEmpty || int.tryParse(value) == null) {
                    return 'Por favor, ingrese un número válido de meses.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _months = int.parse(value!);
                },
              ),
              TextFormField(
                initialValue: _price.toString(),
                decoration: const InputDecoration(labelText: 'Precio'),
                keyboardType: TextInputType.number,
                autofocus: false,
                textInputAction: TextInputAction.done,
                validator: (value) {
                  if (value!.isEmpty || double.tryParse(value) == null) {
                    return 'Por favor, ingrese un precio válido.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _price = double.parse(value!);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
