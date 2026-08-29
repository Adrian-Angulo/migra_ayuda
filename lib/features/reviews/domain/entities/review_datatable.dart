import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:migra_ayuda/core/utils/format/time_formatter.dart';
import 'package:migra_ayuda/features/reviews/domain/entities/review_entity.dart';

class ReviewDatatable extends DataTableSource {
  final List<ReviewEntity> listReviews;

  ReviewDatatable({required this.listReviews});

  @override
  DataRow? getRow(int index) {
    if (index >= listReviews.length) return null;

    final review = listReviews[index];

    return DataRow2.byIndex(
      index: index,
      cells: [
        DataCell(Text('${index + 1}')),
        DataCell(Text(review.nameEntity)),
        DataCell(Text(review.userName)),
        DataCell(Text(review.userCountry)),
        DataCell(_buildRatingChip(review.rating)),
        DataCell(
          Tooltip(
            message: review.comment,
            child: Text(
              review.comment,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ),
        DataCell(Text(TimeFormatter.formatShortDate(review.createdAt))),
      ],
    );
  }

  Widget _buildRatingChip(double rating) {
    final color = rating >= 4.0
        ? Colors.green
        : rating >= 2.5
            ? Colors.orange
            : Colors.red;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star_rounded, size: 16, color: Colors.amber.shade700),
        const SizedBox(width: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          child: Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => listReviews.length;

  @override
  int get selectedRowCount => 0;
}
