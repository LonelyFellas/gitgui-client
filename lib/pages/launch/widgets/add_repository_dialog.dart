import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

enum _GitType { git, mercurial }

class AddRepositoryDialog extends StatelessWidget {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Function(FormState?) onFormChanged;
  AddRepositoryDialog({super.key, required this.onFormChanged});

  void _onFormChanged() {
    onFormChanged(_formKey.currentState);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      child: Form(
        key: _formKey,
        onChanged: _onFormChanged,
        child: Column(
          spacing: 12,
          mainAxisSize: MainAxisSize.min,
          children: [
            FormField<String>(
              builder: (FormFieldState<String> state) => Row(
                spacing: 12,
                children: [
                  SizedBox(width: 80, child: Text('仓库路径', textAlign: .right)),
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: TextField(
                        controller: TextEditingController(text: state.value),
                        decoration: InputDecoration(
                          hintText: '请输入仓库路径',
                          hintStyle: TextStyle(fontSize: 14),
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 0,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.folder),
                            onPressed: () {
                              FilePicker.platform.getDirectoryPath().then((
                                value,
                              ) {
                                state.didChange(value);
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            FormField<String>(
              builder: (FormFieldState<String> state) => Row(
                spacing: 12,
                children: [
                  SizedBox(
                    width: 80,
                    child: Text('仓库名称', textAlign: TextAlign.right),
                  ),
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: TextField(
                        controller: TextEditingController(text: state.value),
                        decoration: InputDecoration(
                          hintText: '请输入仓库名称',
                          hintStyle: TextStyle(fontSize: 14),
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            FormField<_GitType>(
              builder: (FormFieldState<_GitType> state) => Row(
                spacing: 12,
                children: [
                  SizedBox(
                    width: 80,
                    child: Text('类型', textAlign: TextAlign.right),
                  ),
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: DropdownButtonFormField<_GitType>(
                        initialValue: _GitType.git,
                        style: TextStyle(fontSize: 14, color: Colors.black),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 0,
                          ),
                        ),
                        items: _GitType.values.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(
                              type == _GitType.git ? 'Git' : 'Mercurial',
                            ),
                          );
                        }).toList(),
                        onChanged: (_GitType? newValue) {
                          state.didChange(newValue);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
