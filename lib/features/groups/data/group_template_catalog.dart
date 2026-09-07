import '../domain/entities/group.dart';

/// Полный каталог экрана «Шаблоны».
///
/// Эти данные **не приходят с сервера** — они нужны только чтобы заранее
/// заполнить форму. Чтобы добавить шаблон, достаточно одной строки здесь.
class GroupTemplateCatalog {
  const GroupTemplateCatalog._();

  static const List<GroupTemplateSection> sections = [
    GroupTemplateSection(
      title: 'Самые популярные',
      templates: [
        GroupTemplate(name: 'Утро', icon: 'morning', color: '#F5A64F'),
        GroupTemplate(name: 'День', icon: 'day', color: '#4FE87A'),
        GroupTemplate(name: 'Вечер', icon: 'evening', color: '#4FA8E8'),
        GroupTemplate(name: 'Ночь', icon: 'night', color: '#6C7BF5'),
        GroupTemplate(name: 'Здоровье', icon: 'health', color: '#F54F6C'),
        GroupTemplate(name: 'Ежедневные', icon: 'daily', color: '#4FE87A'),
        GroupTemplate(name: 'Школа', icon: 'school', color: '#E8C94F'),
        GroupTemplate(name: 'Фитнес', icon: 'fitness', color: '#F54F6C'),
      ],
    ),
    GroupTemplateSection(
      title: 'Время дня',
      templates: [
        GroupTemplate(name: 'Утро', icon: 'morning', color: '#F5A64F'),
        GroupTemplate(name: 'День', icon: 'day', color: '#4FE87A'),
        GroupTemplate(name: 'Вечер', icon: 'evening', color: '#4FA8E8'),
        GroupTemplate(name: 'Ночь', icon: 'night', color: '#6C7BF5'),
      ],
    ),
    GroupTemplateSection(
      title: 'Периоды',
      templates: [
        GroupTemplate(name: 'Выходные', icon: 'weekend', color: '#4FE87A'),
        GroupTemplate(name: 'Ежедневные', icon: 'daily', color: '#4FE87A'),
        GroupTemplate(name: 'Еженедельные', icon: 'weekly', color: '#4FE87A'),
        GroupTemplate(name: 'Ежемесячные', icon: 'monthly', color: '#4FE87A'),
        GroupTemplate(name: 'Ежегодные', icon: 'yearly', color: '#4FE87A'),
      ],
    ),
    GroupTemplateSection(
      title: 'Здоровье',
      templates: [
        GroupTemplate(name: 'Здоровье', icon: 'health', color: '#F54F6C'),
        GroupTemplate(name: 'Фитнес', icon: 'fitness', color: '#F54F6C'),
        GroupTemplate(name: 'Упражнения', icon: 'exercise', color: '#F54F6C'),
        GroupTemplate(name: 'Тренировка', icon: 'workout', color: '#F54F6C'),
        GroupTemplate(name: 'Спортзал', icon: 'gym', color: '#F54F6C'),
      ],
    ),
    GroupTemplateSection(
      title: 'Сферы жизни',
      templates: [
        GroupTemplate(name: 'Деньги', icon: 'money', color: '#4FE87A'),
        GroupTemplate(name: 'Семья', icon: 'family', color: '#B84FF5'),
        GroupTemplate(
          name: 'Отношения',
          icon: 'relationship',
          color: '#F54F6C',
        ),
        GroupTemplate(name: 'Питомцы', icon: 'pets', color: '#F5A64F'),
        GroupTemplate(name: 'Хобби', icon: 'hobby', color: '#F5A64F'),
        GroupTemplate(name: 'Творчество', icon: 'art', color: '#F54F6C'),
        GroupTemplate(name: 'Путешествия', icon: 'travel', color: '#4FA8E8'),
        GroupTemplate(name: 'Чтение', icon: 'reading', color: '#E8C94F'),
        GroupTemplate(name: 'Питание', icon: 'nutrition', color: '#F5A64F'),
        GroupTemplate(
          name: 'Ментальное благополучие',
          icon: 'mental_health',
          color: '#6C7BF5',
        ),
        GroupTemplate(name: 'Сообщество', icon: 'community', color: '#4FA8E8'),
      ],
    ),
    GroupTemplateSection(
      title: 'Другое',
      templates: [
        GroupTemplate(name: 'Школа', icon: 'school', color: '#E8C94F'),
        GroupTemplate(name: 'Работа', icon: 'work', color: '#E8C94F'),
        GroupTemplate(name: 'Личное', icon: 'personal', color: '#B84FF5'),
        GroupTemplate(name: 'Рутина', icon: 'routine', color: '#F54F6C'),
        GroupTemplate(name: 'Дом', icon: 'home', color: '#4FE8C9'),
        GroupTemplate(
          name: 'Продуктивность',
          icon: 'productivity',
          color: '#4FA8E8',
        ),
        GroupTemplate(name: 'Домашние дела', icon: 'chores', color: '#4FA8E8'),
        GroupTemplate(name: 'Жизнь', icon: 'life', color: '#F5A64F'),
        GroupTemplate(name: 'Разум', icon: 'mind', color: '#6C7BF5'),
        GroupTemplate(name: 'Гигиена', icon: 'hygiene', color: '#4FA8E8'),
        GroupTemplate(
          name: 'Забота о себе',
          icon: 'self_care',
          color: '#E8C94F',
        ),
        GroupTemplate(name: 'Учёба', icon: 'study', color: '#6C7BF5'),
        GroupTemplate(
          name: 'Ежедневная рутина',
          icon: 'daily_routine',
          color: '#4FE87A',
        ),
        GroupTemplate(
          name: 'Утренняя рутина',
          icon: 'morning_routine',
          color: '#F5A64F',
        ),
        GroupTemplate(
          name: 'Вечерняя рутина',
          icon: 'evening_routine',
          color: '#6C7BF5',
        ),
        GroupTemplate(name: 'Духовное', icon: 'spiritual', color: '#4FE87A'),
      ],
    ),
  ];

  /// Для поля поиска — фильтрует по названию.
  static List<GroupTemplateSection> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return sections;

    final result = <GroupTemplateSection>[];
    for (final section in sections) {
      final matches = section.templates
          .where((t) => t.name.toLowerCase().contains(q))
          .toList();
      if (matches.isNotEmpty) {
        result.add(
          GroupTemplateSection(title: section.title, templates: matches),
        );
      }
    }
    return result;
  }
}
