import 'package:flutter/material.dart';

class SizeSelector extends StatefulWidget {
  final List<String> sizes;
  final ValueChanged<String> onSizeSelected;

  const SizeSelector({
    super.key,
    required this.sizes,
    required this.onSizeSelected,
  });

  @override
  State<SizeSelector> createState() => _SizeSelectorState();
}

class _SizeSelectorState extends State<SizeSelector> {
  String? _selectedSize;

  @override
  void initState() {
    super.initState();
    if (widget.sizes.isNotEmpty) {
      _selectedSize = widget.sizes[1]; // Default to 'S' or second option
      widget.onSizeSelected(_selectedSize!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'SELECT SIZE',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
                color: Colors.white70,
              ),
            ),
            TextButton(
              onPressed: () {
                // Show standard size helper sheet
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (context) => const SizeChartSheet(),
                );
              },
              child: Text(
                'SIZE CHART',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: widget.sizes.map((size) {
            final isSelected = _selectedSize == size;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedSize = size;
                });
                widget.onSizeSelected(size);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 12),
                height: 46,
                width: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.white24,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  size,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.white70,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class SizeChartSheet extends StatelessWidget {
  const SizeChartSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Size Guide',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(height: 24, color: Colors.white24),
          const SizedBox(height: 8),
          Table(
            border: TableBorder.all(
                color: Colors.white12, borderRadius: BorderRadius.circular(8)),
            children: const [
              TableRow(
                decoration: BoxDecoration(color: Colors.white10),
                children: [
                  TableCell(
                      child: Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Text('Size',
                              style: TextStyle(fontWeight: FontWeight.bold)))),
                  TableCell(
                      child: Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Text('Bust (in)',
                              style: TextStyle(fontWeight: FontWeight.bold)))),
                  TableCell(
                      child: Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Text('Waist (in)',
                              style: TextStyle(fontWeight: FontWeight.bold)))),
                  TableCell(
                      child: Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Text('Length (in)',
                              style: TextStyle(fontWeight: FontWeight.bold)))),
                ],
              ),
              TableRow(
                children: [
                  TableCell(
                      child: Padding(
                          padding: EdgeInsets.all(12.0), child: Text('XS'))),
                  TableCell(
                      child: Padding(
                          padding: EdgeInsets.all(12.0), child: Text('32'))),
                  TableCell(
                      child: Padding(
                          padding: EdgeInsets.all(12.0), child: Text('26'))),
                  TableCell(
                      child: Padding(
                          padding: EdgeInsets.all(12.0), child: Text('14'))),
                ],
              ),
              TableRow(
                children: [
                  TableCell(
                      child: Padding(
                          padding: EdgeInsets.all(12.0), child: Text('S'))),
                  TableCell(
                      child: Padding(
                          padding: EdgeInsets.all(12.0), child: Text('34'))),
                  TableCell(
                      child: Padding(
                          padding: EdgeInsets.all(12.0), child: Text('28'))),
                  TableCell(
                      child: Padding(
                          padding: EdgeInsets.all(12.0), child: Text('14.5'))),
                ],
              ),
              TableRow(
                children: [
                  TableCell(
                      child: Padding(
                          padding: EdgeInsets.all(12.0), child: Text('M'))),
                  TableCell(
                      child: Padding(
                          padding: EdgeInsets.all(12.0), child: Text('36'))),
                  TableCell(
                      child: Padding(
                          padding: EdgeInsets.all(12.0), child: Text('30'))),
                  TableCell(
                      child: Padding(
                          padding: EdgeInsets.all(12.0), child: Text('15'))),
                ],
              ),
              TableRow(
                children: [
                  TableCell(
                      child: Padding(
                          padding: EdgeInsets.all(12.0), child: Text('L'))),
                  TableCell(
                      child: Padding(
                          padding: EdgeInsets.all(12.0), child: Text('38'))),
                  TableCell(
                      child: Padding(
                          padding: EdgeInsets.all(12.0), child: Text('32'))),
                  TableCell(
                      child: Padding(
                          padding: EdgeInsets.all(12.0), child: Text('15.5'))),
                ],
              ),
              TableRow(
                children: [
                  TableCell(
                      child: Padding(
                          padding: EdgeInsets.all(12.0), child: Text('XL'))),
                  TableCell(
                      child: Padding(
                          padding: EdgeInsets.all(12.0), child: Text('40'))),
                  TableCell(
                      child: Padding(
                          padding: EdgeInsets.all(12.0), child: Text('34'))),
                  TableCell(
                      child: Padding(
                          padding: EdgeInsets.all(12.0), child: Text('16'))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            '* Please note: all measurements are in inches and represent garment dimensions.',
            style: TextStyle(
                fontSize: 12,
                color: Colors.white54,
                fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}
