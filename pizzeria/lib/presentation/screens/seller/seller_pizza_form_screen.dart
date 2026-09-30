import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pizzeria/core/validators/form_validators.dart';
import 'package:pizzeria/models/pizza_model.dart';
import 'package:pizzeria/presentation/providers/pizza_provider.dart';
import 'package:pizzeria/presentation/providers/restaurant_provider.dart';
import 'package:pizzeria/presentation/widgets/widgets.dart';
import 'package:pizzeria/theme/app_colors.dart';

class SellerPizzaFormScreen extends ConsumerStatefulWidget {
  final PizzaModel? initialPizza;

  const SellerPizzaFormScreen({super.key, this.initialPizza});

  @override
  ConsumerState<SellerPizzaFormScreen> createState() => _SellerPizzaFormScreenState();
}

class _SellerPizzaFormScreenState extends ConsumerState<SellerPizzaFormScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _descController;
  late final TextEditingController _imageUrlController;

  final ValueNotifier<String?> _nameErrorNotifier = ValueNotifier<String?>(null);
  final ValueNotifier<String?> _priceErrorNotifier = ValueNotifier<String?>(null);
  final ValueNotifier<String?> _descErrorNotifier = ValueNotifier<String?>(null);
  final ValueNotifier<String?> _imageErrorNotifier = ValueNotifier<String?>(null);
  final ValueNotifier<String> _categoryNotifier = ValueNotifier<String>('Clasicas');
  final ValueNotifier<String> _imagePreviewNotifier = ValueNotifier<String>('');
  final ValueNotifier<List<String>> _sizesNotifier = ValueNotifier<List<String>>(['Personal', 'Mediana', 'Familiar']);
  final ValueNotifier<bool> _isLoadingNotifier = ValueNotifier<bool>(false);

  final List<String> _availableSizes = ['Personal', 'Mediana', 'Familiar', 'Jumbo'];
  final List<String> _categories = ['Clasicas', 'Especiales', 'Gourmet', 'Vegetarianas', 'Dulces'];

  @override
  void initState() {
    super.initState();
    final p = widget.initialPizza;
    _nameController = TextEditingController(text: p?.name ?? '');
    _priceController = TextEditingController(text: p != null ? p.price.toString() : '');
    _descController = TextEditingController(text: p?.description ?? '');
    final initialUrl = p?.imageUrl ??
        'https://images.unsplash.com/photo-1534308983496-4fabb1a015ee?w=500&auto=format&fit=crop&q=80';
    _imageUrlController = TextEditingController(text: initialUrl);
    _imagePreviewNotifier.value = initialUrl;
    _categoryNotifier.value = p?.category ?? 'Clasicas';

    if (p != null && p.sizes.isNotEmpty) {
      _sizesNotifier.value = List<String>.from(p.sizes);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descController.dispose();
    _imageUrlController.dispose();
    _nameErrorNotifier.dispose();
    _priceErrorNotifier.dispose();
    _descErrorNotifier.dispose();
    _imageErrorNotifier.dispose();
    _categoryNotifier.dispose();
    _imagePreviewNotifier.dispose();
    _sizesNotifier.dispose();
    _isLoadingNotifier.dispose();
    super.dispose();
  }

  bool _validate() {
    _nameErrorNotifier.value = FormValidators.requiredField(
      _nameController.text,
      'Ingresa el nombre de la pizza',
    );
    _priceErrorNotifier.value = FormValidators.positiveNumber(
      _priceController.text,
      'Ingresa un precio mayor a 0',
    );
    _descErrorNotifier.value = FormValidators.requiredField(
      _descController.text,
      'Ingresa los ingredientes o descripción',
    );
    _imageErrorNotifier.value = FormValidators.validUrl(_imageUrlController.text);

    return _nameErrorNotifier.value == null &&
        _priceErrorNotifier.value == null &&
        _descErrorNotifier.value == null &&
        _imageErrorNotifier.value == null;
  }

  Future<void> _handleSave() async {
    if (!_validate()) return;
    if (_sizesNotifier.value.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona al menos un tamaño disponible')),
      );
      return;
    }

    _isLoadingNotifier.value = true;
    try {
      final restaurant = await ref.read(sellerRestaurantProvider.future);
      final restaurantId = restaurant?.id;

      final pizza = PizzaModel(
        id: widget.initialPizza?.id ?? '',
        restaurantId: restaurantId,
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
        price: double.tryParse(_priceController.text.trim()) ?? 0.0,
        imageUrl: _imageUrlController.text.trim(),
        sizes: _sizesNotifier.value,
        category: _categoryNotifier.value,
        isAvailable: widget.initialPizza?.isAvailable ?? true,
      );

      if (widget.initialPizza == null) {
        await ref.read(sellerPizzasProvider.notifier).addPizza(pizza);
      } else {
        await ref.read(sellerPizzasProvider.notifier).editPizza(pizza);
      }

      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.initialPizza == null
                ? 'Pizza agregada exitosamente'
                : 'Pizza actualizada correctamente',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      _isLoadingNotifier.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialPizza != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppTopBar(
        title: isEditing ? 'Editar Pizza' : 'Nueva Pizza',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ValueListenableBuilder<String?>(
              valueListenable: _nameErrorNotifier,
              builder: (context, err, _) {
                return CustomTextField(
                  controller: _nameController,
                  label: 'Nombre de la Pizza',
                  hintText: 'Ej. Pizza Margarita Especial',
                  prefixIcon: Icons.local_pizza_outlined,
                  errorText: err,
                  onChanged: (_) => _nameErrorNotifier.value = null,
                );
              },
            ),
            const SizedBox(height: 16),
            ValueListenableBuilder<String?>(
              valueListenable: _priceErrorNotifier,
              builder: (context, err, _) {
                return CustomTextField(
                  controller: _priceController,
                  label: 'Precio Base (\$ MXN)',
                  hintText: 'Ej. 189.00',
                  prefixIcon: Icons.attach_money,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  errorText: err,
                  onChanged: (_) => _priceErrorNotifier.value = null,
                );
              },
            ),
            const SizedBox(height: 16),
            ValueListenableBuilder<String?>(
              valueListenable: _descErrorNotifier,
              builder: (context, err, _) {
                return CustomTextField(
                  controller: _descController,
                  label: 'Descripción / Ingredientes',
                  hintText: 'Salsa pomodoro, queso mozzarella, albahaca fresca, aceite de oliva.',
                  prefixIcon: Icons.description_outlined,
                  maxLines: 3,
                  errorText: err,
                  onChanged: (_) => _descErrorNotifier.value = null,
                );
              },
            ),
            const SizedBox(height: 16),
            ValueListenableBuilder<String?>(
              valueListenable: _imageErrorNotifier,
              builder: (context, err, _) {
                return CustomTextField(
                  controller: _imageUrlController,
                  label: 'URL de Imagen (Enlace web)',
                  hintText: 'https://images.unsplash.com/...',
                  prefixIcon: Icons.image_outlined,
                  keyboardType: TextInputType.url,
                  errorText: err,
                  onChanged: (val) {
                    _imageErrorNotifier.value = null;
                    _imagePreviewNotifier.value = val.trim();
                  },
                );
              },
            ),
            const SizedBox(height: 12),
            ValueListenableBuilder<String>(
              valueListenable: _imagePreviewNotifier,
              builder: (context, previewUrl, _) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    previewUrl,
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, st) => Container(
                      height: 100,
                      color: AppColors.inputBackground,
                      child: const Center(
                        child: Text(
                          'Vista previa de imagen no disponible',
                          style: TextStyle(color: AppColors.textLight, fontSize: 12),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Categoría',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            ValueListenableBuilder<String>(
              valueListenable: _categoryNotifier,
              builder: (context, selectedCategory, _) {
                return Wrap(
                  spacing: 8,
                  children: _categories.map((cat) {
                    final isSelected = selectedCategory == cat;
                    return ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          _categoryNotifier.value = cat;
                        }
                      },
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Tamaños que incluye',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            ValueListenableBuilder<List<String>>(
              valueListenable: _sizesNotifier,
              builder: (context, selectedSizes, _) {
                return Wrap(
                  spacing: 8,
                  children: _availableSizes.map((size) {
                    final isChecked = selectedSizes.contains(size);
                    return FilterChip(
                      label: Text(size),
                      selected: isChecked,
                      selectedColor: AppColors.primaryLight,
                      checkmarkColor: AppColors.primary,
                      onSelected: (val) {
                        final list = List<String>.from(selectedSizes);
                        if (val) {
                          list.add(size);
                        } else {
                          list.remove(size);
                        }
                        _sizesNotifier.value = list;
                      },
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 32),
            ValueListenableBuilder<bool>(
              valueListenable: _isLoadingNotifier,
              builder: (context, isLoading, _) {
                return CustomButton(
                  text: isEditing ? 'Actualizar Pizza' : 'Guardar Pizza',
                  isLoading: isLoading,
                  onPressed: _handleSave,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
