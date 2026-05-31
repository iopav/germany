import 'package:easy_localization/easy_localization.dart';

enum ErrorMsg {

  error400('network_errors.error_400'),
  error401('network_errors.error_401'),
  error403('network_errors.error_403'),
  error404('network_errors.error_404'),
  error413('network_errors.error_413'),
  error422('network_errors.error_422'),
  error500('network_errors.error_500'),
  error503('network_errors.error_503'),
  
  errorTimeout('network_errors.error_timeout'),
  errorConnection('network_errors.error_connection'),
  errorCancel('network_errors.error_cancel'),
  errorUnknown('network_errors.error_unknown'),
  errorNoAuth('network_errors.error_no_auth'),
  
  
  ;

  final String key;
  
  const ErrorMsg(this.key);

  String get message => key.tr(); 
}
