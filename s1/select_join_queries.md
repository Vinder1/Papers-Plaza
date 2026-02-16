1. Выборка всех данных из таблицы

1.1 Получить список всех стран (Id + Название)
```sql
SELECT * FROM identity.country;
```
![фото](select_join_screenshots/1_1.png)

1.2 Получить все данные таблицы криминальных случаев
```sql
SELECT * FROM criminal."case";
```
<img width="363" height="136" alt="image" src="https://github.com/user-attachments/assets/18430a60-a024-4997-9495-757616bf9bd3" />

2. Выборка отдельных столбцов

2.1 Получить названия всех стран
```sql
SELECT name FROM identity.country;
```
![фото](select_join_screenshots/2_1.png)

2.2 Получить название всех типов предметов
```sql
select itemName from items.LuggageItemType;
```
<img width="180" height="113" alt="image" src="https://github.com/user-attachments/assets/ae681671-df53-48ac-bd3b-892f224f6438" />

3. Присвоение новых имен столбцам при формировании выборки

3.1 Получить из списка паспортов все имена приезжих с их страной
```sql
SELECT fullname, country as from
FROM identity.passport;
```
![фото](select_join_screenshots/3_1.png)

3.2 Получить из списка предметов и подставить заголовок "Название предмета" в колонку
```sql
select itemName as "Название предмета" from items.LuggageItemType;
```
<img width="270" height="110" alt="image" src="https://github.com/user-attachments/assets/70e186be-a7fe-40df-9224-9d85a82f30b8" />

4. Выборка данных с созданием вычисляемого столбца

4.1 Получить из списка паспортов все имена приезжих с данными о валидности паспорта
```sql
SELECT fullName,
    validUntil > CURRENT_DATE AS is_valid
FROM identity.passport;
```
![фото](select_join_screenshots/4_1.png)

4.2 Получить таблицу преступлений и вычисляемым столбцом с Id > 2
```sql
select description, id > 2 as Id_BiggerThenTwo from Criminal.CaseType;
```
<img width="545" height="140" alt="image" src="https://github.com/user-attachments/assets/528f1159-1258-40ad-9489-431d8b840be9" />

5. Выборка данных, вычисляемые столбцы, математические функции

5.1 Получить из списка паспортов все имена приезжих с квадратным корнем идентификатора (зачем? неважно)
```sql
SELECT fullName, sqrt(id) as square_root 
FROM identity.passport;
```
![фото](select_join_screenshots/5_1.png)

5.2 Получить все криминальные случаи и их Id помноженным на число Pi
```sql
select description, id * pi() as "Id and pi" from Criminal.CaseType;
```
<img width="531" height="136" alt="image" src="https://github.com/user-attachments/assets/1185fc17-0f1f-4c11-80fd-5965cc2dc09e" />

6. Выборка данных, вычисляемые столбцы, логические функции

6.1 Получить из списка паспортов все имена приезжих, помеченные как просроченные, если паспорт недействителен, иначе как действительные
```sql
SELECT fullName,
CASE
    WHEN validUntil > CURRENT_DATE
    THEN '[действительно]'
    ELSE '[просрочено]'
END AS validTag
FROM identity.passport;
```
![фото](select_join_screenshots/6_1.png)

6.2 Получить все предметы и проставить какие из них на английском
```sql
select itemName,
       case
           when itemName ~ '^[A-Za-z]+$'
               then '[Английский]'
           else '[Русский]'
           end
           as Is_English
from items.LuggageItemType;
```
<img width="407" height="114" alt="image" src="https://github.com/user-attachments/assets/41ac5424-cbb0-4161-bbdd-899731013865" />


7. Выборка данных по условию

7.1 Получить паспорт пользователя с именем 'Джеки Чан'
```sql
SELECT *
FROM identity.passport
WHERE fullName = 'Джеки Чан';
```
![фото](select_join_screenshots/7_1.png)

7.2 Получить все предметы с русскими названиями
```sql
select itemName
from items.luggageitemtype
where not(itemname ~ '^[A-Za-z]+$');
```
<img width="181" height="74" alt="image" src="https://github.com/user-attachments/assets/5c65f29b-d151-4cd9-9d70-aee7f7e48380" />

8. Выборка данных, логические операции

8.1 Получить паспорта пользователей, чьё ФИО больше 10 букв и у которых есть биометрия
```sql
SELECT *
FROM identity.passport
WHERE LENGTH(fullname) > 10 AND biometry IS NOT NULL;
```
![фото](select_join_screenshots/8_1.png)

8.2 Получить описания всех предметов у которых длина слова большье 30 и Id > 2
```sql
select description
from criminal.casetype
where length(description) < 30 and id > 2;
```
<img width="202" height="80" alt="image" src="https://github.com/user-attachments/assets/c5b3cf08-ec21-4050-af44-afc44eef0fae" />

9. Выборка данных, оператор BETWEEN

9.1 Получить ФИО и ID пользователей с паспортами, чьё ФИО длиной от 3 до 10 букв
```sql
SELECT id, fullname
FROM identity.passport
WHERE LENGTH(fullname) BETWEEN 3 AND 10;
```
![фото](select_join_screenshots/9_1.png)

9.2 Получить описание всех преступлений с названием от 20 до 40 символов
```sql
select description
from criminal.casetype
where length(description) between 20 and 40;
```
<img width="205" height="49" alt="image" src="https://github.com/user-attachments/assets/c9691a01-b3ab-4b05-b73b-f2af8326ec50" />

10. Выборка данных, оператор IN

10.1 Получить ФИО и ID пользователей с паспортами из Китая(4) и России(1)
```sql
SELECT id, fullname, country
FROM identity.passport
WHERE country IN (1, 4);
```
![фото](select_join_screenshots/10_1.png)

10.2 Получить все преступления Id которых на 1 и не 3
```sql
select description
from criminal.casetype
where id not in (1, 3);
```
<img width="270" height="84" alt="image" src="https://github.com/user-attachments/assets/678af50b-4dae-4bad-ad3f-7b075fedbec8" />

11. Выборка данных с сортировкой

11.1 Получить ФИО пользователей с паспортами в лексикографическом порядке
```sql
SELECT fullname
FROM identity.passport
ORDER BY fullname;
```
![фото](select_join_screenshots/11_1.png)

11.2 Получить все преступления в обратном порядке по Id
```sql
select description
from criminal.casetype
order by id desc;
```
<img width="268" height="131" alt="image" src="https://github.com/user-attachments/assets/440ab32c-184c-4e1c-a4f3-7a1612720d5c" />

12. Выборка данных, оператор LIKE

12.1 Получить ФИО пользователей с паспортами, у которых в ФИО присутствует буква Д
```sql
SELECT fullname
FROM identity.passport
WHERE fullname LIKE '%Д%';
```
![фото](select_join_screenshots/12_1.png)

12.2 Получить названия всех предметов у которых в названии два слова
```sql
select itemName
from items.luggageitemtype
where itemname like '_% _%';
```
<img width="169" height="52" alt="image" src="https://github.com/user-attachments/assets/84a6331a-6b28-41f2-ba75-b2e808e44f39" />

13. Выбор уникальных элементов столбца

13.1 Получить ID стран, куда можно въезжать иностранцам
```sql
SELECT DISTINCT toId
FROM identity.citizenEntryPermission;
```
![фото](select_join_screenshots/13_1.png)

13.2 Получить уникальные названия всех предметов у которых в названии два слова 
```sql
select distinct itemName
from items.luggageitemtype
where itemname like '_% _%';
```
<img width="169" height="52" alt="image" src="https://github.com/user-attachments/assets/84a6331a-6b28-41f2-ba75-b2e808e44f39" />

14. Выбор ограниченного количества возвращаемых строк.

14.1 Получить какую-то одну страну, в которые можно въезжать гражданам США
```sql
SELECT DISTINCT toId
FROM identity.citizenEntryPermission
WHERE fromID = 2
LIMIT 1;
```
![фото](select_join_screenshots/14_1.png)

14.2 Получить две случайные строки с предметами
```sql
select itemName
from items.luggageitemtype
order by random()
limit 2;
```
<img width="173" height="79" alt="image" src="https://github.com/user-attachments/assets/57dd364b-e18e-44c6-8ae0-876b8b3a1048" />

15. Соединение INNER JOIN

15.1 Получить ФИО пользователей с паспортами вместе с названиями стран, откуда они
```sql
SELECT p.fullname, c.name
FROM identity.passport p
INNER JOIN identity.country c ON p.country = c.id;
```
![фото](select_join_screenshots/15_1.png)

15.2 Соединить две таблицы с криминальными случаями и преступлениями
```sql
select "case".id, description
from criminal."case" join criminal.casetype c on "case".casetype_id = c.id;
```
<img width="445" height="139" alt="image" src="https://github.com/user-attachments/assets/2d57c6ee-687d-4d4f-bfc1-50fea31a85fc" />

16. Внешнее соединение LEFT OUTER JOIN

16.1 Получить список пользователей и, при наличии удостоверения дипломата, дату истечения его срока
```sql
SELECT p.fullname, d.validUntil
FROM identity.passport p
LEFT JOIN papers.diplomatCertificate d ON p.fullName = d.fullName;
```
![фото](select_join_screenshots/16_1.png)

16.2 Получить имена преступников и их преступления
```sql
select fullname, description
from identity.passport left join identity.biometry b on b.id = passport.biometry
left join criminal.record r on b.id = r.biometryid
left join criminal."case" c on r.crimeid = c.id
left join criminal.casetype c2 on c.casetype_id = c2.id;
```
<img width="474" height="131" alt="image" src="https://github.com/user-attachments/assets/df678686-fd4c-4d33-bd54-969ace121789" />

17. Внешнее соединение RIGHT OUTER JOIN

17.1 Получить все удостоверения дипломата и, при наличии данных, дату истечения срока действия паспортов дипломатов
```sql
SELECT d.fullname, p.validUntil
FROM identity.passport p
RIGHT JOIN papers.diplomatCertificate d ON p.fullName = d.fullName;
```
![фото](select_join_screenshots/17_1.png)

17.2 Получить все преступления и сопоставить к ним людей
```sql
select fullname, description
from identity.passport right join identity.biometry b on b.id = passport.biometry
                       right join criminal.record r on b.id = r.biometryid
                       right join criminal."case" c on r.crimeid = c.id
                       right join criminal.casetype c2 on c.casetype_id = c2.id;
```
<img width="505" height="164" alt="image" src="https://github.com/user-attachments/assets/f2b4893b-5923-4c2f-9e16-a47b5870864c" />

18. Перекрестное соединение CROSS JOIN

18.1 Получить все возможные пары стран (ограничиться 10-ю)
```sql
SELECT c1.name, c2.name
FROM identity.country c1, identity.country c2
LIMIT 10;
```
![фото](select_join_screenshots/18_1.png)

18.2 Переженить всех
```sql
select distinct p1.fullname as "Муж", p2.fullname as "Жена"
from identity.passport p1, identity.passport p2
```
<img width="341" height="266" alt="image" src="https://github.com/user-attachments/assets/953d00e4-b34e-41ec-ad8f-3222f05ba86f" />

19. Запросы на выборку из нескольких таблиц

19.1 Получить все записи о том, из какой страны в какую можно въезжать, но вместо ID их названия
```sql
SELECT c1.name as from, c2.name as to
FROM identity.citizenEntryPermission perm
INNER JOIN identity.country c1 ON perm.fromId = c1.id
INNER JOIN identity.country c2 ON perm.toId = c2.id;
```
![фото](select_join_screenshots/19_1.png)

19.2 Получить все преступления и сопоставить к ним людей
```sql
select fullname, description
from identity.passport right join identity.biometry b on b.id = passport.biometry
                       right join criminal.record r on b.id = r.biometryid
                       right join criminal."case" c on r.crimeid = c.id
                       right join criminal.casetype c2 on c.casetype_id = c2.id;
```
<img width="505" height="164" alt="image" src="https://github.com/user-attachments/assets/f2b4893b-5923-4c2f-9e16-a47b5870864c" />
