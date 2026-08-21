/* 
  Future<void> _searchAddress() async {
    final address = _addressController.text.trim();

    
    final RegExp regExp = RegExp(
      r'^(Calle|Carrera)\s+\d+\s*#\d+-\d+,\s*Pasto$',
      caseSensitive: false,
    );

    if (address.isEmpty) return;

    if (!regExp.hasMatch(address)) {
      setState(() {
        _addressNotFound = false;
      });
      if (_autovalidateMode != AutovalidateMode.disabled) {
        _formKey.currentState?.validate();
      }
      return;
    }

    setState(() {
      _isSearching = true;
      _addressNotFound = false;
    });

    try {
      final coords = await _getCoordinates(address);
      if (!mounted) return;
      setState(() {
        location = coords;
        _isSearching = false;
        _addressNotFound = coords == null;
      });
      if (coords != null) {
        _latitudController.text = coords.latitude.toString();
        _longitudController.text = coords.longitude.toString();
      }
    } finally {
      // Esto asegura que el loading siempre se apaga aunque falle
      if (mounted && _isSearching) {
        setState(() {
          _isSearching = false;
        });
      }
    }

    // Solo forzar revalidación si el form está en modo autovalidate
    if (_autovalidateMode != AutovalidateMode.disabled) {
      _formKey.currentState?.validate();
    }
  } */


 

 /*  /// Valida y ejecuta la operación (crear o actualizar).
  /// El cierre del modal es responsabilidad del padre via [ref.listen].
  Future<void> _submit() async {
    setState(() {
      _imageErrorMsg = null;
      _servicesErrorMsg = null;
      _autovalidateMode = AutovalidateMode.onUserInteraction;
    });

    if (!_formKey.currentState!.validate()) return;

    // Imagen obligatoria solo al crear, mostrar error debajo de la imagen
    if (!widget.isEditing && _selectedImageBytes == null) {
      setState(() {
        _imageErrorMsg = 'Por favor seleccione una imagen';
      });
      return;
    }

    // Servicio obligatorio, mostrar error debajo de la selección de servicios
    if (selectedServices.isEmpty) {
      setState(() {
        _servicesErrorMsg = 'Por favor seleccione al menos un servicio';
      });
      return;
    }

    if (_latitudController.text.isEmpty || _longitudController.text.isEmpty) {
      // Esto está cubierto por el validator del campo dirección ya
      return;
    }

    final notifier = ref.read(entitiesCrudProvider.notifier);

    if (widget.isEditing) {
      final updated = EntityEntity(
        id: widget.entity!.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        services: selectedServices,
        address: _addressController.text.trim(),
        localitation: GeoPoint(
          double.parse(_latitudController.text),
          double.parse(_longitudController.text),
        ),
        phone: _phoneController.text.trim(),
        imageUrl: widget.entity!.imageUrl,
        schedule: _scheduleController.text.trim(),
      );
      await notifier.updateEntity(
        entity: updated,
        imagenBytes: _selectedImageBytes,
        fileName: _selectedImage?.name,
      );
    } else {
      final newEntity = EntityEntity(
        id: '',
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        services: selectedServices,
        address: _addressController.text.trim(),
        localitation: GeoPoint(
          double.parse(_latitudController.text),
          double.parse(_longitudController.text),
        ),
        phone: _phoneController.text.trim(),
        imageUrl: '',
        schedule: _scheduleController.text.trim(),
      );
      await notifier.registerEntity(
        entity: newEntity,
        imagenBytes: _selectedImageBytes!,
        fileName: _selectedImage?.name ?? '',
      );
    }
    // El modal escucha entitiesCrudProvider y se cierra solo.
    // En mobile (sin modal) cerramos aquí.
    if (!kIsWeb && mounted) {
      final state = ref.read(entitiesCrudProvider);
      if (state.hasValue && !state.hasError) Navigator.pop(context);
    }
  } */

/* 
 ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      widget.existingImageUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      // Si falla la carga de la imagen de Internet, mostrar el placeholder
                      errorBuilder: (context, error, stackTrace) {
                        return _buildPlaceholder();
                      },
                    ),
                  ) */