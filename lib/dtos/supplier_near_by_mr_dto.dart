// ignore_for_file: public_member_api_docs, sort_constructors_first
class SupplierNearByMrDto {
  final int id;
  final String name;
  final String? logo;
  final double distance;
  final int categoryId;
  
  SupplierNearByMrDto({
    required this.id,
    required this.name,
    this.logo,
    required this.distance,
    required this.categoryId,
  });
}
