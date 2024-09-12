import 'package:flutter/material.dart';

class InfoCard extends StatefulWidget {
  final String text;
  final IconData icon;
  final void Function()? onPressed;
  final bool editable;

  const InfoCard({
    Key? key,
    required this.text,
    required this.icon,
    required this.onPressed,
    this.editable = false,
  }) : super(key: key);

  @override
  _InfoCardState createState() => _InfoCardState();
}

class _InfoCardState extends State<InfoCard> {
  late TextEditingController _controller;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.text);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.editable ? _startEditing : widget.onPressed,
      child: Card(
        color: Colors.white,
        margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        child: ListTile(
          leading: Icon(
            widget.icon,
            color: Colors.grey[500],
          ),
          title: _isEditing
              ? TextFormField(
                  controller: _controller,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 30,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onEditingComplete: _endEditing,
                  autofocus: true,
                )
              : Text(
                  widget.text,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 30,
                  ),
                ),
        ),
      ),
    );
  }

  void _startEditing() {
    setState(() {
      _isEditing = true;
    });
  }

  void _endEditing() {
    setState(() {
      _isEditing = false;
      widget.onPressed?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
