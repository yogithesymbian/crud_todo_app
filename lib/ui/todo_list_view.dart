import 'package:context_menus/context_menus.dart';
import 'package:crud_todo_app/common/adaptive_contextual_layout.dart';
import 'package:crud_todo_app/common/extension.dart';
import 'package:crud_todo_app/dependency/dependency.dart';
import 'package:crud_todo_app/model/category_model.dart';
import 'package:crud_todo_app/model/todo_model.dart';
import 'package:crud_todo_app/ui/widgets/custom_message.dart';
import 'package:crud_todo_app/ui/widgets/todo_item.dart';
import 'package:crud_todo_app/viewmodel/category/category_provider.dart';
import 'package:crud_todo_app/viewmodel/todo/todo_provider.dart';
import 'package:crud_todo_app/viewmodel/todo/todo_state.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

typedef NavigatorToTodo = void Function(String, String?);

class TodoListView extends HookConsumerWidget {
  const TodoListView({
    required this.categoryId,
    required this.onGoToTodo,
    super.key,
  });

  final String categoryId;
  final NavigatorToTodo onGoToTodo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryData = ref.watch(categoryDetailPod(categoryId));
    final todoData = ref.watch(todoListPod(categoryId));

    final existsCategory = ref.watch(
      categoryDetailPod(categoryId).select((value) => value.hasValue),
    );

    ref.listen(
      todoViewModelPod,
      (_, TodoState state) => _onChangeState(context, state),
    );

    return ContextMenuOverlay(
      child: Scaffold(
        backgroundColor: const Color(0xFF4A78FA),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          actions: <Widget>[
            if (existsCategory)
              Tooltip(
                message: 'Delete category',
                child: IconButton(
                  icon: const Icon(Icons.delete_forever),
                  onPressed: () {
                    ref
                        .read(categoryViewModelPod.notifier)
                        .deleteCategory(categoryId);
                    Navigator.pop(context);
                  },
                ),
              ),
          ],
        ),
        body: categoryData.when(
          data: (category) => todoData.whenOrNull(
            data: (todos) => CategorySection(
              category: category,
              todos: todos,
              onEdit: (todoId) => onGoToTodo(categoryId, todoId),
            ),
            error: (e, _) => Center(
              child: Text(
                e.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
          ),
          loading: () => const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
          error: (e, s) => Center(
            child: Text(
              e.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, color: Colors.white),
            ),
          ),
        ),
        floatingActionButton: existsCategory
            ? FloatingActionButton(
                backgroundColor: const Color(0xFF4A78FA),
                onPressed: () => onGoToTodo(categoryId, null),
                child: const Icon(Icons.add),
              )
            : null,
      ),
    );
  }

  void _onChangeState(BuildContext context, TodoState state) {
    final action = state.maybeWhen(success: (a) => a, orElse: () => null);
    final error = state.maybeWhen(error: (m) => m, orElse: () => null);

    if (action != null) {
      if (action == TodoAction.add) {
        showCustomMessage(context, 'Todo created successfully');
      } else if (action == TodoAction.update) {
        showCustomMessage(context, 'Todo updated successfully');
      } else if (action == TodoAction.remove) {
        showCustomMessage(context, 'Todo removed successfully');
      } else if (action == TodoAction.check) {
        showCustomMessage(context, 'Todo finished successfully');
      }
    }

    if (error != null) showCustomMessage(context, error);
  }
}

class CategorySection extends ConsumerWidget {
  const CategorySection({
    required this.category,
    required this.todos,
    required this.onEdit,
    super.key,
  });

  final Category category;
  final List<Todo> todos;
  final ValueSetter<String?> onEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          flex: isPortrait(context) ? 1 : 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
                height: 60,
                width: 60,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Hero(
                  tag: '${category.id}_${category.emoji.name}',
                  child: Material(
                    color: Colors.transparent,
                    child: Text(
                      category.emoji.code,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 30),
                    ),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    category.name,
                    style: const TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ).paddingOnly(b: 5),
                  Text(
                    '${category.todoSize} Tasks',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ).paddingOnly(l: 35),
        ),
        Expanded(
          flex: 2,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: todos.isNotEmpty
                ? TodoList(
                    todoList: todos,
                    onEditItem: (todo) => onEdit(todo.id),
                  ).paddingSymmetric(h: 24, v: 20)
                : const Center(
                    child: Text(
                      'Empty data, add a task',
                      style: TextStyle(fontSize: 25),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

class TodoList extends ConsumerWidget {
  const TodoList({required this.todoList, required this.onEditItem, super.key});

  final List<Todo> todoList;
  final ValueSetter<Todo> onEditItem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(todoViewModelPod.notifier);

    return ListView(
      children: <Widget>[
        for (final item in todoList)
          if (desktopSegments.contains(getDevice()))
            TodoItem.contextual(
              todo: item,
              onEdit: () => onEditItem(item),
              onRemove: () => viewModel.deleteTodo(item.id!, item.categoryId),
              onCheck: (value) => viewModel.checkTodo(item, isChecked: value),
            )
          else
            TodoItem(
              todo: item,
              onEdit: () => onEditItem(item),
              onRemove: () => viewModel.deleteTodo(item.id!, item.categoryId),
              onCheck: (value) => viewModel.checkTodo(item, isChecked: value),
            )
      ],
    );
  }
}
