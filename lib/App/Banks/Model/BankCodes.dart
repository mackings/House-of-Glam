// models/nigerian_banks.dart
class NigerianBank {
  final String name;
  final String code;
  final String slug;

  const NigerianBank({
    required this.name,
    required this.code,
    required this.slug,
  });
}

class NigerianBanks {
  static const List<NigerianBank> banks = [
    NigerianBank(name: 'Access Bank', code: '044', slug: 'access-bank'),
    NigerianBank(
      name: 'Access Bank (Diamond)',
      code: '063',
      slug: 'access-bank-diamond',
    ),
    NigerianBank(name: 'Citibank Nigeria', code: '023', slug: 'citibank'),
    NigerianBank(name: 'Ecobank Nigeria', code: '050', slug: 'ecobank'),
    NigerianBank(name: 'Fidelity Bank', code: '070', slug: 'fidelity-bank'),
    NigerianBank(
      name: 'First Bank of Nigeria',
      code: '011',
      slug: 'first-bank',
    ),
    NigerianBank(name: 'First City Monument Bank', code: '214', slug: 'fcmb'),
    NigerianBank(name: 'Globus Bank', code: '00103', slug: 'globus-bank'),
    NigerianBank(name: 'Guaranty Trust Bank', code: '058', slug: 'gtbank'),
    NigerianBank(name: 'Heritage Bank', code: '030', slug: 'heritage-bank'),
    NigerianBank(name: 'Keystone Bank', code: '082', slug: 'keystone-bank'),
    NigerianBank(name: 'Kuda Bank', code: '50211', slug: 'kuda-bank'),
    NigerianBank(name: 'Polaris Bank', code: '076', slug: 'polaris-bank'),
    NigerianBank(name: 'Providus Bank', code: '101', slug: 'providus-bank'),
    NigerianBank(name: 'Stanbic IBTC Bank', code: '221', slug: 'stanbic-ibtc'),
    NigerianBank(
      name: 'Standard Chartered Bank',
      code: '068',
      slug: 'standard-chartered',
    ),
    NigerianBank(name: 'Sterling Bank', code: '232', slug: 'sterling-bank'),
    NigerianBank(name: 'Suntrust Bank', code: '100', slug: 'suntrust-bank'),
    NigerianBank(
      name: 'Union Bank of Nigeria',
      code: '032',
      slug: 'union-bank',
    ),
    NigerianBank(name: 'United Bank for Africa', code: '033', slug: 'uba'),
    NigerianBank(name: 'Unity Bank', code: '215', slug: 'unity-bank'),
    NigerianBank(name: 'Wema Bank', code: '035', slug: 'wema-bank'),
    NigerianBank(name: 'Zenith Bank', code: '057', slug: 'zenith-bank'),
    NigerianBank(name: 'Jaiz Bank', code: '301', slug: 'jaiz-bank'),
    NigerianBank(name: 'Lotus Bank', code: '303', slug: 'lotus-bank'),
    NigerianBank(name: 'Parallex Bank', code: '526', slug: 'parallex-bank'),
    NigerianBank(
      name: 'Sparkle Microfinance Bank',
      code: '51310',
      slug: 'sparkle',
    ),
    NigerianBank(name: 'Titan Trust Bank', code: '102', slug: 'titan-trust'),
    NigerianBank(name: 'Opay', code: '999992', slug: 'opay'),
    NigerianBank(name: 'PalmPay', code: '999991', slug: 'palmpay'),
    NigerianBank(name: 'Moniepoint', code: '50515', slug: 'moniepoint'),
    NigerianBank(name: 'VFD Microfinance Bank', code: '566', slug: 'vfd'),
    NigerianBank(name: 'Rubies Bank', code: '125', slug: 'rubies-bank'),
    NigerianBank(
      name: 'Coronation Merchant Bank',
      code: '559',
      slug: 'coronation',
    ),
    NigerianBank(name: 'FSDH Merchant Bank', code: '501', slug: 'fsdh'),
    NigerianBank(
      name: 'Rand Merchant Bank',
      code: '502',
      slug: 'rand-merchant',
    ),
  ];

  static NigerianBank? findByCode(String code) {
    try {
      return banks.firstWhere((bank) => bank.code == code);
    } catch (e) {
      return null;
    }
  }

  static NigerianBank? findByName(String name) {
    try {
      return banks.firstWhere((bank) => bank.name == name);
    } catch (e) {
      return null;
    }
  }

  static List<NigerianBank> searchBanks(String query) {
    if (query.isEmpty) return banks;

    final lowerQuery = query.toLowerCase();
    return banks.where((bank) {
      return bank.name.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}
