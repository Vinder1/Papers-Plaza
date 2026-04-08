from pymongo import MongoClient

client = MongoClient("mongodb://localhost:27017/")
    
# Проверка соединения
client.admin.command("ping")
print("Успешное подключение к MongoDB")

# Задание 1 — Создание коллекции и вставка документов:

# Создайте базу данных shopDB и коллекцию products.
# Добавьте 3–4 документа, описывающих товары интернет-магазина.
# Каждый документ должен содержать:
# name — название товара
# category — категория
# price — цена
# inStock — есть ли в наличии
# manufacturer — вложенный объект с полями name и country

db = client["shopDB"]
collection = db["products"]

# Очистка данных с прошлых запусков перед добавлением новых
collection.delete_many({})

products = [
    {
        "name": "Смартфон Nokia 3310",
        "category": "Электроника",
        "price": 9990,
        "inStock": True,
        "manufacturer": {"name": "Nokia", "country": "Финляндия"}
    },
    {
        "name": "Ноутбук MacBook Air M3",
        "category": "Электроника",
        "price": 124990,
        "inStock": False,
        "manufacturer": {"name": "Apple", "country": "США"}
    },
    {
        "name": "Наушники Sony WH-1000XM5",
        "category": "Электроника",
        "price": 34990,
        "inStock": True,
        "manufacturer": {"name": "Sony", "country": "Япония"}
    },
    {
        "name": "Кроссовки Nike Air Max 90",
        "category": "Обувь",
        "price": 12990,
        "inStock": True,
        "manufacturer": {"name": "Nike", "country": "США"}
    }
]

insert_result = collection.insert_many(products)
print(f"1) Вставлено {len(insert_result.inserted_ids)} документов.\n")

# Задание 2 — Простой запрос:

# Напишите запрос, который:
# Найдёт все товары, которые есть в наличии
# Найдёт все товары категории, которую вы указали в первом задании

print("2) Товары в наличии:")
for doc in collection.find({"inStock": True}):
    print(f"    > {doc['name']} ({doc['price']} ₽)")
print()

chosen_category = "Электроника"
print(f"Все товары категории '{chosen_category}':")
for doc in collection.find({"category": chosen_category}):
    print(f"    > {doc['name']} ({doc['price']} ₽)")
print()

# Задание 3 — Более сложный запрос:

# Напишите запрос, который:
# найдёт товары дороже 10000
# только из категории в задании 1
# выведет только название и цену
# Подсказка: используйте оператор $gt.

docs_found = collection.find(
    {"price": {"$gt": 10000}, "category": chosen_category},
    {"_id": 0, "name": 1, "price": 1})

print(f"3) {chosen_category} дороже 10000 ₽ (только название и цена):")
for doc in docs_found:
    print(f"    > {doc['name']}: {doc['price']} ₽")

# Результат в result.png