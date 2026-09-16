/// Mirrors the `region_cameroun` Postgres enum exactly (10 values).
enum RegionCameroun {
  adamaoua('Adamaoua'),
  centre('Centre'),
  est('Est'),
  extremeNord('Extreme-Nord'),
  littoral('Littoral'),
  nord('Nord'),
  nordOuest('Nord-Ouest'),
  ouest('Ouest'),
  sud('Sud'),
  sudOuest('Sud-Ouest');

  const RegionCameroun(this.dbValue);

  /// Exact string stored in Postgres — do not localize/alter.
  final String dbValue;

  static RegionCameroun? fromDb(String? value) {
    if (value == null) return null;
    for (final region in RegionCameroun.values) {
      if (region.dbValue == value) return region;
    }
    return null;
  }
}
