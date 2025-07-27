class VpnConfig {
  final String name;
  final String privateKey;
  final String address;
  final String dns;
  final String publicKey;
  final String presharedKey;
  final String allowedIPs;
  final String endpoint;
  final int persistentKeepalive;
  final String configData;

  VpnConfig({
    required this.name,
    required this.privateKey,
    required this.address,
    required this.dns,
    required this.publicKey,
    required this.presharedKey,
    required this.allowedIPs,
    required this.endpoint,
    required this.persistentKeepalive,
    required this.configData,
  });

  factory VpnConfig.fromConfigString(String configString, String name) {
    final lines = configString.split('\n');
    
    String privateKey = '';
    String address = '';
    String dns = '';
    String publicKey = '';
    String presharedKey = '';
    String allowedIPs = '';
    String endpoint = '';
    int persistentKeepalive = 0;

    for (String line in lines) {
      line = line.trim();
      if (line.startsWith('PrivateKey')) {
        privateKey = line.split('=')[1].trim();
      } else if (line.startsWith('Address')) {
        address = line.split('=')[1].trim();
      } else if (line.startsWith('DNS')) {
        dns = line.split('=')[1].trim();
      } else if (line.startsWith('PublicKey')) {
        publicKey = line.split('=')[1].trim();
      } else if (line.startsWith('PresharedKey')) {
        presharedKey = line.split('=')[1].trim();
      } else if (line.startsWith('AllowedIPs')) {
        allowedIPs = line.split('=')[1].trim();
      } else if (line.startsWith('Endpoint')) {
        endpoint = line.split('=')[1].trim();
      } else if (line.startsWith('PersistentKeepalive')) {
        persistentKeepalive = int.tryParse(line.split('=')[1].trim()) ?? 0;
      }
    }

    return VpnConfig(
      name: name,
      privateKey: privateKey,
      address: address,
      dns: dns,
      publicKey: publicKey,
      presharedKey: presharedKey,
      allowedIPs: allowedIPs,
      endpoint: endpoint,
      persistentKeepalive: persistentKeepalive,
      configData: configString,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'privateKey': privateKey,
      'address': address,
      'dns': dns,
      'publicKey': publicKey,
      'presharedKey': presharedKey,
      'allowedIPs': allowedIPs,
      'endpoint': endpoint,
      'persistentKeepalive': persistentKeepalive,
      'configData': configData,
    };
  }

  factory VpnConfig.fromJson(Map<String, dynamic> json) {
    return VpnConfig(
      name: json['name'] ?? '',
      privateKey: json['privateKey'] ?? '',
      address: json['address'] ?? '',
      dns: json['dns'] ?? '',
      publicKey: json['publicKey'] ?? '',
      presharedKey: json['presharedKey'] ?? '',
      allowedIPs: json['allowedIPs'] ?? '',
      endpoint: json['endpoint'] ?? '',
      persistentKeepalive: json['persistentKeepalive'] ?? 0,
      configData: json['configData'] ?? '',
    );
  }
}
