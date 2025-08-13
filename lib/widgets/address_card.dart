import 'package:flutter/material.dart';
import '../models/address_model.dart';
import '../utils/app_colors.dart';

class AddressCard extends StatelessWidget {
  final AddressModel address;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const AddressCard({
    super.key,
    required this.address,
    this.isSelected = false,
    this.isSelectionMode = false,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: isSelected 
            ? Border.all(color: AppColors.primary, width: 2)
            : Border.all(color: AppColors.border),
        boxShadow: [
          if (isSelected)
            BoxShadow(
              color: AppColors.primary.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          else
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getTypeColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      address.typeDisplayName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _getTypeColor(),
                      ),
                    ),
                  ),
                  
                  if (address.isDefault) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Default',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                  ],
                  
                  const Spacer(),
                  
                  if (!isSelectionMode) ...[
                    GestureDetector(
                      onTap: onEdit,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        child: const Icon(
                          Icons.edit_outlined,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: onDelete,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        child: const Icon(
                          Icons.delete_outline,
                          size: 20,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                  
                  if (isSelected)
                    const Icon(
                      Icons.check_circle,
                      color: AppColors.primary,
                      size: 24,
                    ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Name and Phone
              Text(
                address.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              
              const SizedBox(height: 4),
              
              Text(
                address.phoneNumber,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Address
              Text(
                address.fullAddress,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTypeColor() {
    switch (address.type) {
      case AddressType.home:
        return AppColors.primary;
      case AddressType.work:
        return AppColors.info;
      case AddressType.other:
        return AppColors.secondary;
    }
  }
}