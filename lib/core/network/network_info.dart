/// Interface para verificar conectividad
abstract class NetworkInfo {
  Future<bool> get isConnected;
}

/// Implementación de NetworkInfo
/// TODO: Implementar con connectivity_plus cuando se necesite
class NetworkInfoImpl implements NetworkInfo {
  @override
  Future<bool> get isConnected async {
    // Por ahora asumimos que hay conexión
    // Instalar connectivity_plus para implementación real
    return true;
  }
}
