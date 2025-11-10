enum LocalDBConstant {
  supportMobileNumber(1, 'supportMobileNumber'),
  supportWhatsAppNumber(2, 'supportWhatsAppNumber'),
  userToken(3, 'userToken'),
  userId(4, 'userId');

  final int id;
  final String key;

  const LocalDBConstant(this.id, this.key);
}