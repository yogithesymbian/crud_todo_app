import 'package:crud_todo_app/navigator/config/crud_todo_config.dart';
import 'package:flutter/material.dart';

enum TodoPath {
  category('categories'),
  todo('todo'),
  unknown('404');

  const TodoPath(this.name);

  final String name;
}

class CrudTodoInformationParser extends RouteInformationParser<CrudTodoConfig> {
  @override
  Future<CrudTodoConfig> parseRouteInformation(
    RouteInformation routeInformation,
  ) async {
    final uri = Uri.parse(routeInformation.location ?? '');
    final newPaths = uri.pathSegments.map((seg) => seg.toLowerCase()).toList();

    switch (newPaths.length) {
      case 0:
        return const CrudTodoConfigCategoryList();
      case 1:
        if (newPaths[0] == TodoPath.category.name) {
          return const CrudTodoConfigCategoryList();
        }
        break;
      case 2:
        final segments = (newPaths[0], newPaths[1]);
        if (segments.$1 == TodoPath.category.name && segments.$2.isNotEmpty) {
          return CrudTodoConfigTodoList(segments.$2);
        }
        break;
      case 3:
        final segments = (newPaths[0], newPaths[1], newPaths[2]);
        if (segments.$1 == TodoPath.category.name) {
          if (segments.$2.isNotEmpty && segments.$3 == TodoPath.todo.name) {
            return CrudTodoConfigAddTodo(segments.$2);
          }
        }
        break;
      case 4:
        final segments = (newPaths[0], newPaths[1], newPaths[2], newPaths[3]);
        if (segments.$1 == TodoPath.category.name && segments.$2.isNotEmpty) {
          if (segments.$3 == TodoPath.todo.name && segments.$4.isNotEmpty) {
            return CrudTodoConfigUpdateTodo(segments.$2, segments.$4);
          }
        }
        break;
    }

    return const CrudTodoConfig.unknown();
  }

  @override
  RouteInformation? restoreRouteInformation(CrudTodoConfig configuration) {
    return configuration.when(
      categoryList: () => RouteInformation(
        location: '/${TodoPath.category.name}',
      ),
      todoList: (categoryId) => RouteInformation(
        location: '/${TodoPath.category.name}/$categoryId',
      ),
      addTodo: (id) => RouteInformation(
        location: '/${TodoPath.category.name}/$id/${TodoPath.todo.name}/',
      ),
      updateTodo: (id, tId) => RouteInformation(
        location: '/${TodoPath.category.name}/$id/${TodoPath.todo.name}/$tId',
      ),
      unknown: () => RouteInformation(location: '/${TodoPath.unknown.name}'),
    );
  }
}
