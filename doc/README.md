## ЗАПРОСЫ

1. Method POST `/login/` - Удалить файл и запись о нём

запрос:

| Поле     | Тип  | Описание | Значение       | Обязательность |
| -------- | ---- | -------- | -------------- | -------------- |
| login    | text | логин    | До 32 символов | +              |
| password | text | пароль   | До 32 символов | +              |

ответ:

```
{
  "id":1,
  "status": "ok"
}

{
  "status": "fail",
  "message":"причина ошибки"
}
```

2. Method POST `/logout/` - Поменять статус файла на 1

| Поле | Тип  | Описание | Значение | Обязательность |
| ---- | ---- | -------- | -------- | -------------- |
|      |      |          |          |                |

ответ:

```
{
  "status": "ok"
}

{
  "status": "fail",
  "message":"причина ошибки"
}
```

3. Method POST `user/add/` - Загрузить файл, добавить записи о пользователе в таблицы

запрос:

| Поле        | Тип      | Описание                    | Значение                   | Обязательность |
| ----------- | -------- | --------------------------- | -------------------------- | -------------- |
| login       | text     | Логин                       | До 256 букв                | +              |
| email       | text     | Электронный адрес           | До 24 символов             | +              |
| status      | text     | Статус                      | 0 или 1                    |                |
| surname     | text     | Фамилия                     | До 24 букв                 |                |
| name        | text     | Имя                         | До 24 букв                 |                |
| patronymic  | text     | Отчество                    | До 24 букв                 |                |
| phone       | text     | Телефонный номер            | До 18 символов             |                |
| password    | text     | Пароль                      | До 32 символов             | +              |
| upload      | file     | Загружаемый файл            | Файл                       |                |
| description | textarea | Описание загружаемого файла | До 256 букв, цифр и знаков |                |

ответ:

```
{
  "id": 1,
  "status": "ok"
}

{
  "status": "fail",
  "message":"причина ошибки"
}
```

4. Method POST `user/save/` - Сохранить файл и записи о пользователе

запрос:

| Поле        | Тип      | Описание                    | Значение                   | Обязательность |
| ----------- | -------- | --------------------------- | -------------------------- | -------------- |
| id          | text     | Id загруженного файла       | До 9 цифр, обязательно     | +              |
| login       | text     | Логин                       | До 256 букв                | +              |
| email       | text     | Емэйл                       | До 24 символов             | +              |
| status      | text     | Статус                      | 0 или 1                    | +              |
| surname     | text     | Фамилия                     | До 24 букв                 |                |
| name        | text     | Имя                         | До 24 букв                 |                |
| patronymic  | text     | Отчество                    | До 24 букв                 |                |
| phone       | text     | Телефонный номер            | До 18 символов             |                |
| password    | text     | Пароль                      | До 32 символов             | +              |
| newpassword | text     | Новый пароль                | До 32 символов             | +              |
| upload      | file     | Загружаемый файл            | Файл                       |                |
| description | textarea | Описание загружаемого файла | До 256 букв, цифр и знаков |                |

*Примечание: если установлен newpassword, то password обязателен*

ответ:

```
{
  "id":1,
  "status":"ok"
}


{
  "status": "fail",
  "message":"причина ошибки"
}
```

5. Method POST `user/delete/` - Удалить файл и запись о нём

запрос:

| Поле | Тип  | Описание              | Значение  | Обязательность |
| ---- | ---- | --------------------- | --------- | -------------- |
| id   | text | Id загруженного файла | До 9 цифр | +              |

ответ:

```
{
  "id":1,
  "status": "ok"
}

{
  "status": "fail",
  "message":"причина ошибки"
}
```

6. Method POST `user/activate/` - Поменять статус файла на 1

запрос:

| Поле | Тип  | Описание              | Значение  | Обязательность |
| ---- | ---- | --------------------- | --------- | -------------- |
| id   | text | Id загруженного файла | До 9 цифр | +              |

ответ:

```
{
  "id":1,
  "status": "ok"
}

{
  "status": "fail",
  "message":"причина ошибки"
}
```

7. Method POST `user/deactivate/` -  Поменять статус файла на 0

запрос:

| Поле | Тип  | Описание              | Значение  | Обязательность |
| ---- | ---- | --------------------- | --------- | -------------- |
| id   | text | Id загруженного файла | До 9 цифр | +              |

ответ:

```
{
  "id":1,
  "status": "ok"
}

{
  "status": "fail",
  "message":"причина ошибки"
}
```

8. Method POST `user/edit/` - Получить запись о файле по id

запрос:

| Поле | Тип  | Описание              | Значение  | Обязательность |
| ---- | ---- | --------------------- | --------- | -------------- |
| id   | text | Id загруженного файла | До 9 цифр | +              |

*Примечание: extention всегда в нижнем регистре*

ответ:

```
{
  "data":
  {
    "id":               22,
    "login":           "login",
    "email":           "email",
    "status":          "status",
    "surname":         "surname",
    "name":            "name",
    "patronymic":      "patronymic",
    "phone":           "+7(921)1111111",
    "extension":        "svg",
    "filename":         "bMLryezYQWaEi2z22X4mwC8Gma1L0k7flVWCsMCrYAyzwgAa",
    "url":              "http://house/uploads/bMLryezYQWaEi2z22X4mwC8Gma1L0k7flVWCsMCrYAyzwgAa.svg",
    "mime":             "image/svg+xml",
    "size":             973,
    "real_filename":    "eye-slash-solid.svg"
  },
  "status":"ok"
}


{
  "status": "fail",
  "message":"причина ошибки"
}
```

9. Method POST `user/index/` - Получить список записей

запрос:

| Поле       | Тип  | Описание                                | Значение | Обязательность |
| ---------- | ---- | --------------------------------------- | -------- | -------------- |
| per_page   | int  | Кол-во записей на странице              |          | +              |
| page       | int  | Номер страницы                          |          |                |
| sort       | text | Сортировка                              | asc/desc |                |
| sort_field | text | Поле, по которому проводится сортировка |          |                |

*Примечание:  если page нету, показываем первую страницу*. *По умолчанию сортировка asc, sort_field = id*

ответ:

```
{
  "data":
  {
    "id":               1,
    "login":           "login",
    "email":           "email",
    "status":          "0",
    "surname":         "surname",
    "name":            "name",
    "patronymic":      "patronymic",
    "phone":           "+7(921)1111111",
    "extension":        "svg",
    "filename":         "bMLryezYQWaEi2z22X4mwC8Gma1L0k7flVWCsMCrYAyzwgAa",
    "url":              "http://house/uploads/bMLryezYQWaEi2z22X4mwC8Gma1L0k7flVWCsMCrYAyzwgAa.svg",
    "mime":             "image/svg+xml",
    "size":             973,
    "real_filename":    "eye-slash-solid.svg"
  },
    {
    "id":               2,
    "login":           "login",
    "email":           "email",
    "status":          "1",
    "surname":         "surname",
    "name":            "name",
    "patronymic":      "patronymic",
    "phone":           "+7(921)1111111",
    "extension":        "svg",
    "filename":         "bMLryezYQWaEi2z22X4mwC8Gma1L0k7flVWCsMCrYAyzwgAa",
    "url":              "http://house/uploads/bMLryezYQWaEi2z22X4mwC8Gma1L0k7flVWCsMCrYAyzwgAa.svg",
    "mime":             "image/svg+xml",
    "size":             973,
    "real_filename":    "eye-slash-solid.svg"
  },
  "status":"ok",
  "total":"2"
}


{
  "status": "fail",
  "message":"причина ошибки"
}
```