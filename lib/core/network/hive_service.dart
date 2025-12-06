// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:rolo/app/constant/hive_table_constant.dart';
// import 'package:rolo/features/auth/data/model/user_hive_model.dart';
// import 'package:rolo/features/cart/data/model/cart_item_hive_model.dart';
// import 'package:rolo/features/home/data/model/category_hive_model.dart';
// import 'package:rolo/features/home/data/model/home_data_hive_model.dart';
// import 'package:rolo/features/home/data/model/home_section_hive_model.dart';
// import 'package:rolo/features/home/data/model/ribbon_hive_model.dart';
// import 'package:rolo/features/product/data/model/product_hive_model.dart';

// class HiveService {
//   Future<void> init() async {
//     var directory = await getApplicationDocumentsDirectory();
//     Hive.init(directory.path);
//     if (!Hive.isAdapterRegistered(HiveTableConstant.userTableId)) {
//       Hive.registerAdapter(UserHiveModelAdapter());
//     }
//     if (!Hive.isAdapterRegistered(HiveTableConstant.productTableId)) {
//       Hive.registerAdapter(ProductHiveModelAdapter());
//     }
//     if (!Hive.isAdapterRegistered(HiveTableConstant.cartItemTableId)) {
//       Hive.registerAdapter(CartItemHiveModelAdapter());
//     }
//     if (!Hive.isAdapterRegistered(HiveTableConstant.categoryTableId)) {
//       Hive.registerAdapter(CategoryHiveModelAdapter());
//     }
//     if (!Hive.isAdapterRegistered(HiveTableConstant.ribbonTableId)) {
//       Hive.registerAdapter(RibbonHiveModelAdapter());
//     }
//     if (!Hive.isAdapterRegistered(HiveTableConstant.homeSectionTableId)) {
//       Hive.registerAdapter(HomeSectionHiveModelAdapter());
//     }
//     if (!Hive.isAdapterRegistered(HiveTableConstant.homeDataTableId)) {
//       Hive.registerAdapter(HomeDataHiveModelAdapter());
//     }
//   }

//   Future<void> register(UserHiveModel auth) async {
//     var box = await Hive.openBox<UserHiveModel>(
//       HiveTableConstant.userBox,
//     );
//     await box.put(auth.userId, auth);
//   }

//   Future<UserHiveModel?> login(String email, String password) async {
//     var box = await Hive.openBox<UserHiveModel>(
//       HiveTableConstant.userBox,
//     );
//     try {
//       final user = box.values.firstWhere(
//         (element) => element.email == email && element.password == password,
//       );
//       await box.close();
//       return user;
//     } catch (e) {
//       await box.close();
//       return null;
//     }
//   }

//   Future<void> clearAll() async {
//     await Hive.deleteFromDisk();
//   }

//   Future<void> close() async {
//     await Hive.close();
//   }
// }