// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import 'data/datasources/remote_datasource.dart' as _i920;
import 'data/datasources/remote_datasource_impl.dart' as _i559;
import 'data/datasources/sellio_api.dart' as _i724;
import 'data/register_module.dart' as _i365;
import 'data/repositories/category_repository_impl.dart' as _i1032;
import 'data/repositories/section_repository_impl.dart' as _i34;
import 'domain/repositories/category_repository.dart' as _i615;
import 'domain/repositories/section_repository.dart' as _i819;
import 'domain/usecases/create_section.dart' as _i1042;
import 'domain/usecases/delete_section.dart' as _i301;
import 'domain/usecases/get_categories.dart' as _i664;
import 'domain/usecases/get_sections.dart' as _i290;
import 'domain/usecases/update_section.dart' as _i878;
import 'presentation/viewmodels/admin_panel_viewmodel.dart' as _i254;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    gh.lazySingleton<_i361.Dio>(() => registerModule.dio);
    gh.lazySingleton<_i724.SellioApi>(
      () => registerModule.getSellioApi(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i920.IRemoteDataSource>(
      () => _i559.RemoteDataSourceImpl(api: gh<_i724.SellioApi>()),
    );
    gh.lazySingleton<_i615.ICategoryRepository>(
      () => _i1032.CategoryRepositoryImpl(gh<_i920.IRemoteDataSource>()),
    );
    gh.lazySingleton<_i819.ISectionRepository>(
      () => _i34.SectionRepositoryImpl(gh<_i920.IRemoteDataSource>()),
    );
    gh.lazySingleton<_i1042.CreateSection>(
      () => _i1042.CreateSection(gh<_i819.ISectionRepository>()),
    );
    gh.lazySingleton<_i301.DeleteSection>(
      () => _i301.DeleteSection(gh<_i819.ISectionRepository>()),
    );
    gh.lazySingleton<_i290.GetSections>(
      () => _i290.GetSections(gh<_i819.ISectionRepository>()),
    );
    gh.lazySingleton<_i878.UpdateSection>(
      () => _i878.UpdateSection(gh<_i819.ISectionRepository>()),
    );
    gh.lazySingleton<_i664.GetCategories>(
      () => _i664.GetCategories(gh<_i615.ICategoryRepository>()),
    );
    gh.factory<_i254.AdminPanelViewModel>(
      () => _i254.AdminPanelViewModel(
        getSections: gh<_i290.GetSections>(),
        createSection: gh<_i1042.CreateSection>(),
        updateSection: gh<_i878.UpdateSection>(),
        deleteSection: gh<_i301.DeleteSection>(),
        getCategories: gh<_i664.GetCategories>(),
      ),
    );
    return this;
  }
}

class _$RegisterModule extends _i365.RegisterModule {}
