# Habits + Groups modullari

Auth moduli bilan bir xil qatlamlar: `domain` → `data` → `presentation`,
BLoC + get_it + dio + dartz. Offline rejim yo'q — har bir amal serverga boradi.

## Nima uchun Riverpod/freezed emas

Spec'da "loyihada boshqasi ishlatilayotgan bo'lsa, o'shani ayt" deyilgan.
Loyihada allaqachon **BLoC** va qo'lda `fromJson` bor (auth moduli), shuning
uchun shu stack davom ettirildi:

| Spec taklifi | Bu loyihada | Sabab |
| --- | --- | --- |
| Riverpod | `flutter_bloc` | Auth moduli BLoC'da; ikkita state management bir ilovada — keraksiz murakkablik |
| freezed + json_serializable | Qo'lda `fromJson` | `build_runner` yo'q → build tez, generatsiya qilingan fayllar git'da yotmaydi |
| `AsyncValue` | `HabitsState.status` + `failure` | Bir xil ma'no, BLoC uslubida |
| `table_calendar` | `WeekStrip` (o'z widget'imiz) | Bizga faqat bitta hafta qatori kerak, butun kalendar paketi ortiqcha |

## Icon va rang

Backend `icon` va `color` ni oddiy string sifatida saqlaydi. Ma'nosini faqat
ilova biladi — [core/constants/habit_visuals.dart](../../core/constants/habit_visuals.dart).

**Emoji ishlatiladi, icon paketi emas.** Emoji — Unicode belgi, uni chizish
uchun `Text` yetarli: hech qanday paket, asset yoki font kerak emas, tizim
emojilari (iOS'da Apple, Android'da Noto) allaqachon rangli. Icon paketlari
esa monoxrom bo'lib, har bir ikonkani qo'lda bo'yash kerak bo'lardi.

```dart
Text(HabitEmoji.resolve(habit.icon))   // noma'lum kalitda '❓'
HabitColors.parse(habit.color)         // buzuq hex'da default rang
```

Yangi icon qo'shish: `HabitEmoji.catalog` ga bitta qator. Backend'ga tegilmaydi.

## Optimistik yangilash

Bosh ekrandagi eng muhim qism — [habits_bloc.dart](presentation/bloc/habits_bloc.dart)
dagi `_optimistic()`:

1. UI **darhol** yangilanadi (vaqtinchalik `HabitLog` bilan)
2. Odat `pendingIds` ga qo'shiladi → takroriy bosish to'siladi
3. So'rov ketadi
4. Muvaffaqiyat → serverdagi haqiqiy log bilan almashtiriladi;
   `newly_unlocked` bo'sh bo'lmasa yutuq oynasi ochiladi
5. Xatolik → **rollback**: avvalgi ro'yxat qaytariladi + snackbar

Miqdor qo'shishda serverga **qo'shiladigan** miqdor ketadi, jami emas:
"+0,5 L" → `{"value": 0.5}`. Server o'zi qo'shadi va `completed` ni hisoblaydi.

## Sana bilan ishlash

Backend faqat `"YYYY-MM-DD"` qabul qiladi. `toIso8601String()` **yaramaydi** —
u vaqt va timezone qo'shadi. [core/utils/api_date.dart](../../core/utils/api_date.dart)
shu uchun bor: `ApiDate.format`, `ApiDate.parse`, `ApiDate.dayOnly`.

Hafta kunlari `1 = Dushanba … 7 = Yakshanba` — Dart'dagi `DateTime.weekday`
bilan aynan bir xil, konvertatsiya shart emas.

## Ekranlar

| Ekran | Fayl | So'rovlar |
| --- | --- | --- |
| Bugun | [today_page.dart](presentation/pages/today_page.dart) | `GET /habits?date=` — **bitta** so'rov, loglar ichida keladi |
| Progress qo'shish | `LogValueSheet` | `POST /habits/{id}/logs` |
| Yutuq oynasi | `AchievementDialog` | so'rovsiz — `newly_unlocked` javobdan keladi |
| Shablonlar | [group_templates_page.dart](../groups/presentation/pages/group_templates_page.dart) | so'rovsiz — katalog client'da |
| Guruh formasi | [group_edit_page.dart](../groups/presentation/pages/group_edit_page.dart) | `POST/PATCH/DELETE /groups` |

Guruh shablonlari backendda **yo'q** (`GET /templates` faqat odatlar uchun),
shuning uchun katalog [group_template_catalog.dart](../groups/data/group_template_catalog.dart)
da — client tomonda. Tanlanganda forma oldindan to'ldiriladi, xolos.

## Hali qilinmagan

Odat yaratish/tahrirlash formasi, timer ekrani, statistika, yutuqlar ro'yxati,
ta'til ekrani, drag-and-drop tartiblash, lokal bildirishnomalar
(`flutter_local_notifications`). Ularning **data va domain qatlami tayyor** —
`HabitsRepository`, `ProgressRepository` va `GroupsRepository` da tegishli
metodlar bor, faqat use case + bloc + ekran qo'shiladi.
