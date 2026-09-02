import 'package:app_act_1/presentation/widgets/dialog_content.dart';
import 'package:app_act_1/presentation/widgets/preference_item.dart';
import 'package:app_act_1/presentation/widgets/row_item.dart';
import 'package:app_act_1/presentation/widgets/section_card.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  final ValueNotifier<String?> _genderNotifier = ValueNotifier<String?>(
    'Masculino',
  );
  final ValueNotifier<Map<String, bool>> _hobbiesNotifier =
      ValueNotifier<Map<String, bool>>({
        'Deportes': false,
        'Música': false,
        'Lectura': false,
      });
  final ValueNotifier<String?> _countryNotifier = ValueNotifier<String?>(null);

  final List<String> _countries = [
    'México',
    'USA',
    'Canadá',
    'España',
    'Colombia',
    'Argentina',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _genderNotifier.dispose();
    _hobbiesNotifier.dispose();
    _countryNotifier.dispose();
    super.dispose();
  }

  void _showSaveModal() {
    final name = _nameController.text.trim();
    final age = _ageController.text.trim();

    showDialog(
      context: context,
      builder: (context) {
        return CustomDialog(name: name, age: age, onClose: () {});
      },
    );
  }

  void _showPreferencesModal() {
    final selectedHobbies = _hobbiesNotifier.value.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20.0,
            right: 20.0,
            top: 20.0,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.0,
                  height: 4.0,
                  margin: const EdgeInsets.only(bottom: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade50,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: const Icon(Icons.tune, color: Colors.indigo),
                  ),
                  const SizedBox(width: 12.0),
                  const Text(
                    'Resumen de Preferencias',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              const Divider(),
              const SizedBox(height: 8.0),
              PreferenceItem(
                icon: Icons.person_outline,
                title: 'Nombre',
                value: _nameController.text.trim().isEmpty
                    ? 'No registrado'
                    : _nameController.text.trim(),
              ),
              PreferenceItem(
                icon: Icons.cake_outlined,
                title: 'Edad',
                value: _ageController.text.trim().isEmpty
                    ? 'No registrada'
                    : '${_ageController.text.trim()} años',
              ),
              PreferenceItem(
                icon: Icons.wc_outlined,
                title: 'Género',
                value: _genderNotifier.value ?? 'No seleccionado',
              ),
              PreferenceItem(
                icon: Icons.sports_basketball_outlined,
                title: 'Hobbies',
                value: selectedHobbies.isEmpty
                    ? 'Ninguno seleccionado'
                    : selectedHobbies.join(', '),
              ),
              PreferenceItem(
                icon: Icons.public_outlined,
                title: 'País de residencia',
                value: _countryNotifier.value ?? 'No seleccionado',
              ),
              const SizedBox(height: 20.0),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cerrar'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        centerTitle: true,
        title: const Text(
          'Registro de Preferencias',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            children: [
              SectionCard(
                accentColor: const Color(0xFF2563EB),
                backgroundColor: Colors.white,
                icon: Icons.info_outline_rounded,
                title: 'Sección 1: Información General',
                child: Text(
                  'Completa los siguientes datos personales básicos y configura tus preferencias de visualización y pasatiempos.',
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.blueGrey.shade700,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              SectionCard(
                accentColor: const Color(0xFF059669),
                backgroundColor: Colors.white,
                icon: Icons.person_outline_rounded,
                title: 'Sección 2: Datos Personales',
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Nombre Completo',
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        prefixIcon: const Icon(Icons.person_rounded),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(
                            color: Color(0xFF059669),
                            width: 1.8,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    TextField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Edad',
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        prefixIcon: const Icon(Icons.calendar_today_rounded),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(
                            color: Color(0xFF059669),
                            width: 1.8,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              SectionCard(
                accentColor: const Color(0xFFD97706),
                backgroundColor: Colors.white,
                icon: Icons.view_agenda_outlined,
                title: 'Sección 3: Distribución de Filas',
                child: Column(
                  children: [
                    RowItemWidget(
                      label: 'Fila 1',
                      description: 'Color Rojo',
                      color: const Color(0xFFEF4444),
                      lightColor: const Color(0xFFFEF2F2),
                    ),
                    const SizedBox(height: 8.0),
                    RowItemWidget(
                      label: 'Fila 2',
                      description: 'Color Amarillo',
                      color: const Color(0xFFEAB308),
                      lightColor: const Color(0xFFFEFCE8),
                    ),
                    const SizedBox(height: 8.0),
                    RowItemWidget(
                      label: 'Fila 3',
                      description: 'Color Azul',
                      color: const Color(0xFF3B82F6),
                      lightColor: const Color(0xFFEFF6FF),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              SectionCard(
                accentColor: const Color(0xFFEA580C),
                backgroundColor: Colors.white,
                icon: Icons.grid_view_rounded,
                title: 'Sección 4: Cuatro Hijos en Colores',
                child: Row(
                  children: [
                    _buildChildBox(
                      text: 'Hijo 1',
                      color: const Color(0xFFEF4444),
                      bg: const Color(0xFFFEE2E2),
                    ),
                    const SizedBox(width: 8.0),
                    _buildChildBox(
                      text: 'Hijo 2',
                      color: const Color(0xFFD97706),
                      bg: const Color(0xFFFEF3C7),
                    ),
                    const SizedBox(width: 8.0),
                    _buildChildBox(
                      text: 'Hijo 3',
                      color: const Color(0xFF2563EB),
                      bg: const Color(0xFFDBEAFE),
                    ),
                    const SizedBox(width: 8.0),
                    _buildChildBox(
                      text: 'Hijo 4',
                      color: const Color(0xFF059669),
                      bg: const Color(0xFFD1FAE5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              SectionCard(
                accentColor: const Color(0xFF7C3AED),
                backgroundColor: Colors.white,
                icon: Icons.tune_rounded,
                title: 'Sección 5: Controles UI',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Género',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14.0,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    ValueListenableBuilder<String?>(
                      valueListenable: _genderNotifier,
                      builder: (context, genderValue, _) {
                        return RadioGroup<String>(
                          groupValue: genderValue,
                          onChanged: (value) {
                            _genderNotifier.value = value;
                          },
                          child: Wrap(
                            spacing: 8.0,
                            runSpacing: 4.0,
                            children: ['Masculino', 'Femenino', 'Otro'].map((
                              gender,
                            ) {
                              return InkWell(
                                borderRadius: BorderRadius.circular(8.0),
                                onTap: () {
                                  _genderNotifier.value = gender;
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Radio<String>(
                                      value: gender,
                                      activeColor: const Color(0xFF7C3AED),
                                    ),
                                    Text(
                                      gender,
                                      style: const TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 8.0),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12.0),
                    const Text(
                      'Hobbies',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14.0,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    ValueListenableBuilder<Map<String, bool>>(
                      valueListenable: _hobbiesNotifier,
                      builder: (context, hobbiesMap, _) {
                        return Wrap(
                          spacing: 8.0,
                          runSpacing: 4.0,
                          children: hobbiesMap.keys.map((hobby) {
                            final isChecked = hobbiesMap[hobby] ?? false;
                            return InkWell(
                              borderRadius: BorderRadius.circular(8.0),
                              onTap: () {
                                _hobbiesNotifier.value = {
                                  ..._hobbiesNotifier.value,
                                  hobby: !isChecked,
                                };
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Checkbox(
                                    value: isChecked,
                                    activeColor: const Color(0xFF7C3AED),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4.0),
                                    ),
                                    onChanged: (bool? value) {
                                      _hobbiesNotifier.value = {
                                        ..._hobbiesNotifier.value,
                                        hobby: value ?? false,
                                      };
                                    },
                                  ),
                                  Text(
                                    hobby,
                                    style: const TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 8.0),
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                    const SizedBox(height: 16.0),
                    const Text(
                      'País de residencia',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14.0,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    ValueListenableBuilder<String?>(
                      valueListenable: _countryNotifier,
                      builder: (context, countryValue, _) {
                        return DropdownButtonFormField<String>(
                          initialValue: countryValue,
                          hint: const Text('Selecciona un país'),
                          dropdownColor: Colors.white,
                          focusColor: Colors.white,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            prefixIcon: const Icon(Icons.public_rounded),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                          ),
                          items: _countries.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            _countryNotifier.value = newValue;
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              offset: const Offset(0, -4),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14.0),
                  side: const BorderSide(color: Color(0xFF2563EB)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                onPressed: _showPreferencesModal,
                icon: const Icon(
                  Icons.visibility_outlined,
                  color: Color(0xFF2563EB),
                ),
                label: const Text(
                  'Preferencias',
                  style: TextStyle(
                    color: Color(0xFF2563EB),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14.0),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                onPressed: _showSaveModal,
                icon: const Icon(Icons.save_outlined),
                label: const Text(
                  'Guardar',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChildBox({
    required String text,
    required Color color,
    required Color bg,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14.0),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13.0,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }
}
