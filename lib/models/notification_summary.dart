    class NotificationSummary {
        final int total;
        final int noLeidas;

        NotificationSummary({
            required this.total,
            required this.noLeidas,
        });

        factory NotificationSummary.fromJson(Map<String, dynamic> json) {
            return NotificationSummary(
            total: json['total'] as int? ?? 0,
            noLeidas: json['no_leidas'] as int? ?? 0,
            );
        }
    }
