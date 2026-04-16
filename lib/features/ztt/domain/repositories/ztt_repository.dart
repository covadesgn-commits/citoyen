import '../models/ztt_report.dart';
import '../models/factory_model.dart';

abstract class IZttRepository {
  Future<List<ZttReport>> getHistory();
  Future<void> submitSortingReport({
    required List<WasteTypeSelection> selections,
    required String factoryId,
  });
  Future<List<FactoryModel>> getFactories();
}
