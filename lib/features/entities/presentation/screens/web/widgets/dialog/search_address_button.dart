
import 'package:flutter/material.dart';

class SearchAddressButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;

  const SearchAddressButton({super.key, 
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(11),
          bottomRight: Radius.circular(11),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onTap,
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.search, color: Colors.white),
          ),
        ),
      ),
    );
  }
}