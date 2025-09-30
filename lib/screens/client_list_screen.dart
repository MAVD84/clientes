import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../providers/client_provider.dart';
import '../models/client_model.dart';
import '../providers/activation_provider.dart';
import '../theme/theme.dart';
import 'add_edit_client_screen.dart';
import 'analytics_screen.dart';
import 'dashboard_screen.dart';

class ClientListScreen extends StatefulWidget {
  const ClientListScreen({super.key});

  @override
  State<ClientListScreen> createState() => _ClientListScreenState();
}

class _ClientListScreenState extends State<ClientListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Provider.of<ClientProvider>(context, listen: false).loadClients();
    _searchController.addListener(() {
      Provider.of<ClientProvider>(context, listen: false).searchClients(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showActivationPrompt() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Por favor, activa la aplicación para usar esta función.'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Future<void> _importClients() async {
    final activationProvider = Provider.of<ActivationProvider>(context, listen: false);
    if (!activationProvider.isActivated) {
      _showActivationPrompt();
      return;
    }

    final clientProvider = Provider.of<ClientProvider>(context, listen: false);
    try {
      final message = await clientProvider.importClientsFromCsv();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al importar: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _exportClients() async {
    final activationProvider = Provider.of<ActivationProvider>(context, listen: false);
    if (!activationProvider.isActivated) {
      _showActivationPrompt();
      return;
    }

    final clientProvider = Provider.of<ClientProvider>(context, listen: false);
    try {
      final message = await clientProvider.exportClientsToCsv();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al exportar: $e'), backgroundColor: Colors.red),
      );
    }
  }
  
  Future<void> _refreshClients() async {
    await Provider.of<ClientProvider>(context, listen: false).loadClients();
  }

  @override
  Widget build(BuildContext context) {
    final clientProvider = Provider.of<ClientProvider>(context);
    final activationProvider = Provider.of<ActivationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes IPTV'),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: _importClients,
            tooltip: 'Importar Clientes desde CSV',
          ),
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: _exportClients,
            tooltip: 'Exportar Clientes a CSV',
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: RefreshIndicator(
        onRefresh: _refreshClients,
        child: Column(
          children: [
            _buildSearchBar(),
            _buildFilterChips(),
            _buildClientList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (!activationProvider.isActivated && clientProvider.clients.isNotEmpty) {
            _showActivationPrompt();
          } else {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const AddEditClientScreen()),
            );
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: Theme(
        data: darkTheme, // Apply the dark theme to the drawer
        child: SafeArea(
          child: Consumer<ActivationProvider>(
            builder: (context, activationProvider, child) {
              return Column(
                children: <Widget>[
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: <Widget>[
                        Builder(builder: (themeContext) {
                          return DrawerHeader(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: const NetworkImage('https://images.unsplash.com/photo-1579546929518-9e396f3cc809?q=80&w=2070&auto=format&fit=crop'),
                                fit: BoxFit.cover,
                                colorFilter: ColorFilter.mode(
                                  const Color(0x99000000),
                                  BlendMode.darken,
                                ),
                              ),
                            ),
                            child: Stack(
                              children: [
                                const Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text('Menú', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                                ),
                                Align(
                                  alignment: Alignment.topRight,
                                  child: IconButton(
                                    icon: const Icon(Icons.close, color: Colors.white),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        ListTile(leading: const Icon(Icons.home), title: const Text('Inicio'), onTap: () => Navigator.pop(context)),
                        ListTile(
                          leading: const Icon(Icons.dashboard),
                          title: const Text('Dashboard'),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.of(context).push(MaterialPageRoute(builder: (context) => const DashboardScreen()));
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.analytics),
                          title: const Text('Analítica'),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AnalyticsScreen()));
                          },
                        ),
                        const Divider(),
                        if (activationProvider.isActivated)
                          const ListTile(
                            leading: Icon(Icons.check_circle, color: Colors.green),
                            title: Text('Aplicación Activada'),
                          )
                        else
                          ListTile(
                            leading: const Icon(Icons.vpn_key),
                            title: const Text('Activar Aplicación'),
                            onTap: () {
                              Navigator.pop(context);
                              _showActivationDialog(context);
                            },
                          ),
                      ],
                    ),
                  ),
                  // Version number at the bottom
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Text(
                      'Version 3.0',
                      style: TextStyle(
                        color: const Color(0xB3FFFFFF),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _showActivationDialog(BuildContext context) {
    final codeController = TextEditingController();
    final activationProvider = Provider.of<ActivationProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Activar Aplicación'),
          content: TextField(
            controller: codeController,
            decoration: const InputDecoration(labelText: 'Introduce tu código de activación'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                final success = await activationProvider.activateApp(codeController.text);
                if (!ctx.mounted) return; // Check if the dialog's context is still valid
                Navigator.of(ctx).pop();
                if (!context.mounted) return; // Check if the screen's context is still valid
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('¡Aplicación activada con éxito!'), backgroundColor: Colors.green),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Código incorrecto. Inténtalo de nuevo.'), backgroundColor: Colors.red),
                  );
                }
              },
              child: const Text('Activar'),
            ),
          ],
        );
      },
    );
  }

  Padding _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          labelText: 'Buscar por nombre, apellido o usuario',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Consumer<ClientProvider>(
      builder: (context, clientProvider, child) {
        return Wrap(
          spacing: 8.0,
          children: [
            FilterChip(label: const Text('Todos'), selected: clientProvider.filterStatus == 'all', onSelected: (s) => clientProvider.filterByStatus('all')),
            FilterChip(label: const Text('Expirados'), selected: clientProvider.filterStatus == 'expired', onSelected: (s) => clientProvider.filterByStatus('expired')),
            FilterChip(label: const Text('Expira pronto'), selected: clientProvider.filterStatus == 'expiring_soon', onSelected: (s) => clientProvider.filterByStatus('expiring_soon')),
          ],
        );
      },
    );
  }

  Expanded _buildClientList() {
    return Expanded(
      child: Consumer<ClientProvider>(
        builder: (context, clientProvider, child) {
          if (clientProvider.clients.isEmpty) {
            return const Center(child: Text('No hay clientes que coincidan.', style: TextStyle(fontSize: 18, color: Colors.grey)));
          }
          return AnimationLimiter(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: clientProvider.clients.length,
              itemBuilder: (context, index) {
                Client client = clientProvider.clients[index];
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: ClientCard(client: client),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class ClientCard extends StatelessWidget {
  final Client client;

  const ClientCard({super.key, required this.client});

  void _showDeleteConfirmationDialog(BuildContext context, Client client) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: Text('¿Estás seguro de que deseas eliminar a ${client.name} ${client.lastName}?'),
          actions: <Widget>[
            TextButton(child: const Text('Cancelar'), onPressed: () => Navigator.of(ctx).pop()),
            TextButton(
              child: const Text('Eliminar'),
              onPressed: () {
                Provider.of<ClientProvider>(context, listen: false).deleteClient(client.id!);
                Navigator.of(ctx).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final today = DateUtils.dateOnly(DateTime.now());
    final endDate = DateUtils.dateOnly(client.endDate);
    final remainingDays = endDate.difference(today).inDays;

    final String statusText;
    final Color statusColor;
    final IconData statusIcon;

    if (remainingDays < 0) {
      statusText = 'Expirado';
      statusColor = Colors.red;
      statusIcon = Icons.error_outline;
    } else if (remainingDays <= 7) {
      statusText = remainingDays == 0 ? 'Expira hoy' : '$remainingDays días';
      statusColor = Colors.orange;
      statusIcon = Icons.warning_amber_rounded;
    } else {
      statusText = 'Activo';
      statusColor = Colors.green;
      statusIcon = Icons.check_circle_outline;
    }

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: () => _showClientDetailsDialog(context, client, remainingDays),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('${client.name} ${client.lastName}', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddEditClientScreen(client: client)));
                      } else if (value == 'delete') {
                        _showDeleteConfirmationDialog(context, client);
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      const PopupMenuItem(value: 'edit', child: ListTile(leading: Icon(Icons.edit), title: Text('Editar'))),
                      const PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete), title: Text('Eliminar'))),
                    ],
                  ),
                ],
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoColumn('Vencimiento', DateFormat.yMd().format(client.endDate)),
                  _buildInfoColumn('Precio', '\$${client.price.toStringAsFixed(2)}'),
                  _buildStatusChip(statusText, statusColor, statusIcon),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  Widget _buildStatusChip(String text, Color color, IconData icon) {
    return Chip(
      avatar: Icon(icon, color: Colors.white, size: 18),
      label: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
    );
  }

  Widget _buildCopyableField(BuildContext context, String label, String value) {
    return Row(
      children: [
        Expanded(child: Text('$label: $value')),
        IconButton(
          icon: const Icon(Icons.copy, size: 18),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: value));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$label copiado al portapapeles'), duration: const Duration(seconds: 1)),
            );
          },
        ),
      ],
    );
  }

  void _showClientDetailsDialog(BuildContext context, Client client, int remainingDays) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: Text('${client.name} ${client.lastName}'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  _buildCopyableField(context, 'Usuario', client.username),
                  _buildCopyableField(context, 'Contraseña', client.password),
                  if (client.url != null && client.url!.isNotEmpty) _buildCopyableField(context, 'URL', client.url!),
                  const SizedBox(height: 8),
                  Text('Teléfono: ${client.phone}'),
                  if (client.referredBy != null && client.referredBy!.isNotEmpty) Text('Referido por: ${client.referredBy}'),
                  const Divider(),
                  Text('Suscripción: ${DateFormat.yMd().format(client.startDate)} - ${DateFormat.yMd().format(client.endDate)}'),
                  Text('Meses: ${client.months}'),
                   const SizedBox(height: 8),
                  Text(
                    'Días restantes: $remainingDays',
                    style: TextStyle(
                      color: remainingDays > 7 ? Colors.green : (remainingDays > 0 ? Colors.orange : Colors.red),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[TextButton(child: const Text('Cerrar'), onPressed: () => Navigator.of(ctx).pop())],
          );
        });
  }
}
