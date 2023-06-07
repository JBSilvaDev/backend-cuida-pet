import 'package:cuidapet_api/modules/chat/chat_router.dart';
import 'package:cuidapet_api/modules/schedules/schedules_routers.dart';
import 'package:cuidapet_api/modules/supplier/supplier_router.dart';
import 'package:cuidapet_api/modules/user/user_router.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../modules/categories/categories_router.dart';
import './i_router.dart';

class IRouterConfig{
  final Router _router;

  final List<IRouter> _routers = [
    UserRouter(),
    CategoriesRouter(),
    SupplierRouter(),
    SchedulesRouters(),
    ChatRouter()
  ];

  IRouterConfig(this._router);

  void configure() {
    for (var r in _routers) {
      r.configure(_router);

    }

  }
}
