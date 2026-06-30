// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appDatabaseHash() => r'4db1c5efe1a73afafa926c6e91d12e49a68b1abc';

/// See also [appDatabase].
@ProviderFor(appDatabase)
final appDatabaseProvider = AutoDisposeProvider<AppDatabase>.internal(
  appDatabase,
  name: r'appDatabaseProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$appDatabaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AppDatabaseRef = AutoDisposeProviderRef<AppDatabase>;
String _$todoViewmodelHash() => r'e591b95216d536606349b439cf7bcb4a635d2545';

/// See also [TodoViewmodel].
@ProviderFor(TodoViewmodel)
final todoViewmodelProvider =
    AutoDisposeAsyncNotifierProvider<TodoViewmodel, TodoState>.internal(
  TodoViewmodel.new,
  name: r'todoViewmodelProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$todoViewmodelHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TodoViewmodel = AutoDisposeAsyncNotifier<TodoState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
