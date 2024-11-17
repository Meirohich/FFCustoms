// flutter_reorderable_grid_view: ^4.0.0
// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'index.dart'; // Imports other custom widgets
import 'package:flutter_reorderable_grid_view/entities/order_update_entity.dart';
import 'package:flutter_reorderable_grid_view/widgets/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_admin_a_p_s_d_s_k/catalogue/catal_project/catal_project_model.dart'
    as model;

class ReorderableGridViewCustom extends StatefulWidget {
  const ReorderableGridViewCustom({
    super.key,
    this.width,
    this.height,
    required this.project,
    required this.onMainChanged,
  });

  final double? width;
  final double? height;
  final CatalProjectsRow project;
  final Future Function(String imageUrl) onMainChanged;

  @override
  State<ReorderableGridViewCustom> createState() =>
      _ReorderableGridViewCustomState();
}

class _ReorderableGridViewCustomState extends State<ReorderableGridViewCustom> {
  final _scrollController = ScrollController();
  final _gridViewKey = GlobalKey();
  late List<String> imageUrls;
  String? _selectedImageUrl;
  late model.CatalProjectModel modell;

  @override
  void initState() {
    super.initState();
    imageUrls =
        widget.project.gallery.where((url) => url != null).toSet().toList() ??
            [];
  }

  Future<void> _updateGalleryOrderInSupabase() async {
    final client = Supabase.instance.client;

    final response = await client.from('catal_projects').update(
        {'gallery': imageUrls}).match({'id': widget.project.id}).execute();

    setState(() => modell.requestCompleter = null);
    await modell.waitForRequestCompleted();
  }

  Future<void> _deleteImage(String imageUrl) async {
    final isMainPicture = imageUrl == widget.project.mainPicture;

    final shouldDelete = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Подтверждение'),
              content: const Text(
                  'Вы уверены в том, что хотите удалить данное изображение?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Отмена'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Удалить'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (shouldDelete) {
      final isMainPicture = imageUrl == widget.project.mainPicture;

      setState(() {
        imageUrls.remove(imageUrl);
        _selectedImageUrl = null;
      });
      await _updateGalleryOrderInSupabase();

      if (isMainPicture) {
        await _updateMainPicture('no picture');
      }
    }
  }

  Future<void> _updateMainPicture(String imageUrl) async {
    final client = Supabase.instance.client;
    final response = await client.from('catal_projects').update(
        {'mainPicture': imageUrl}).match({'id': widget.project.id}).execute();

    widget.onMainChanged(imageUrl);

    setState(() => modell.requestCompleter = null);
    await modell.waitForRequestCompleted();
  }

  @override
  Widget build(BuildContext context) {
    final generatedChildren = List.generate(
      imageUrls.length,
      (index) {
        final imageUrl = imageUrls.elementAt(index);
        final isSelected = _selectedImageUrl == imageUrl;
        return GestureDetector(
          key: Key('gesture_$index'),
          onTap: () {
            setState(() {
              _selectedImageUrl = isSelected ? null : imageUrl;
            });
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                key: Key(imageUrls.elementAt(index)),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              if (isSelected) ...[
                Positioned.fill(
                  child: Container(
                    color: Colors.black45,
                  ),
                ),
                Positioned.fill(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.white),
                        onPressed: () => _deleteImage(imageUrl),
                      ),
                      IconButton(
                        icon: const Icon(Icons.photo, color: Colors.white),
                        onPressed: () => _updateMainPicture(imageUrl),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );

    return ReorderableBuilder(
      children: generatedChildren,
      scrollController: _scrollController,
      onReorder: (List<OrderUpdateEntity> orderUpdateEntities) {
        setState(() {
          print("reorder");
          for (final orderUpdateEntity in orderUpdateEntities) {
            final imageUrl = imageUrls.removeAt(orderUpdateEntity.oldIndex);
            imageUrls.insert(orderUpdateEntity.newIndex, imageUrl);
          }
        });
        _updateGalleryOrderInSupabase();
      },
      builder: (children) {
        return GridView(
          key: _gridViewKey,
          controller: _scrollController,
          children: children,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 6,
            crossAxisSpacing: 8,
          ),
        );
      },
    );
  }
}