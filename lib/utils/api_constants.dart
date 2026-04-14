class ApiConstants {
  static const String baseUrl = 'https://surefit.myweb.net.au';

  // Auth
  static const String login = '/api/authentication/login';
  static const String mobileLogin = '/api/authentication/mobile-login';

  // Product
  static const String productByBarcode = '/api/ProductItems/barcode';

  // Issue
  static const String outboundDispatches = '/api/OutboundDispatches';

  // Receive
  static const String inboundReceipts = '/api/InboundReceipts';

  // Optional
  static const String vehicles = '/api/vehicle';
  static const String issueProductsByVehicle = '/api/issue/products';
  static const String receiveProductsByVehicle = '/api/receive/products';
  static const String stockCheck = '/api/stockcheck';
}