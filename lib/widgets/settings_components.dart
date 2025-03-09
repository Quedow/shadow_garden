import 'package:flutter/material.dart';

class SettingToggleTile extends StatelessWidget {
  final String label;
  final String description;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const SettingToggleTile({super.key, required this.label, required this.description, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
      title: Text(label, style: Theme.of(context).textTheme.bodyLarge),
      subtitle: Text(description, style: Theme.of(context).textTheme.labelMedium!.copyWith(color: Theme.of(context).colorScheme.tertiary)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}

class SettingSliderTile extends StatelessWidget {
  final String label;
  final String description;
  final double value;
  final ValueChanged<double>? onChanged;
  final String? leftLabel;
  final String? rightLabel;

  const SettingSliderTile({super.key, required this.label, required this.description, required this.value, required this.onChanged, this.leftLabel, this.rightLabel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyLarge),
          Text(description, style: Theme.of(context).textTheme.labelMedium!.copyWith(color: Theme.of(context).colorScheme.tertiary)),
          Slider(
            value: value,
            max: 1.0, divisions: 20, label: (value * 100).round().toString(),
            onChanged: onChanged,
          ),
          if (leftLabel != null && rightLabel != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(leftLabel!, style: Theme.of(context).textTheme.labelMedium!.copyWith(color: Theme.of(context).colorScheme.tertiary)),
                Text(rightLabel!, style: Theme.of(context).textTheme.labelMedium!.copyWith(color: Theme.of(context).colorScheme.tertiary)),
              ],
            ),
        ],
      ),
    );
  }
}

class SettingButtonTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final void Function() onPressed;

  const SettingButtonTile({super.key, required this.label, required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onPressed,
      leading: Icon(icon),
      title: Text(label, style: Theme.of(context).textTheme.bodyLarge),
      trailing: Icon(Icons.arrow_forward_ios_rounded, color: Theme.of(context).hintColor),
    );
  }
}

class SettingIconButtonTile extends StatelessWidget {
  final String label;
  final String description;
  final IconData icon;
  final VoidCallback onPressed;

  const SettingIconButtonTile({super.key, required this.label, required this.description, required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
      title: Text(label, style: Theme.of(context).textTheme.bodyLarge),
      subtitle: Text(description, style: Theme.of(context).textTheme.labelMedium!.copyWith(color: Theme.of(context).colorScheme.tertiary)),
      trailing: IconButton(onPressed: onPressed, icon: Icon(icon)),
    );
  }
}

class SettingListView extends StatelessWidget {
  final List<String> items;
  final void Function(int index) onPressed;

  const SettingListView({super.key, required this.items, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: items.length * 50,
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return ListTile(
            dense: true,
            textColor: Theme.of(context).colorScheme.tertiary,
            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
            title: Text(items[index], style: Theme.of(context).textTheme.labelMedium),
            trailing: IconButton(
              icon: Icon(Icons.close_rounded, color: Theme.of(context).unselectedWidgetColor), 
              onPressed: () => onPressed(index),
            ),
          );
        },
      ),
    );
  }
}