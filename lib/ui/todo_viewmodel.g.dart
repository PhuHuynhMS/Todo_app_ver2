// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appDatabaseHash() => r'4c20f914a3c547001c20f44f1138a1d70037da2d';

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
String _$todoViewmodelHash() => r'4f26f197fa35eb110dba226ed34714180114af98';

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
