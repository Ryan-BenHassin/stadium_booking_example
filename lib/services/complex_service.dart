import '../models/complex.dart';

class ComplexService {
  Future<List<Complex>> fetchComplexes() async {
    // Simulate API delay
    await Future.delayed(Duration(seconds: 5));
    
    // Return mock data (will be replaced with actual API call later)
    List<Complex> complexes_list = [
      Complex(
        name: 'Complex Beb Saadoun',
        longitude: 36.809019,
        latitude: 10.149182,
        description: 'Beb Saadoun Complex',
      ),

      Complex(
        name: 'Complex Ras Tabia',
        latitude: 36.819857,
        longitude: 10.151501,
        description: 'Ras tabia Complex',
      ),

      Complex(
        name: 'Complex B',
        latitude: 35.0522,
        longitude: -118.900,
        description: 'Los Angeles Complex',
      ),
    ];

    return complexes_list;


  }
}
