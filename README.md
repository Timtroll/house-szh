## ЗАПРОСЫ

1. Method POST `/add/` - Загрузить файл, добавить записи о пользователе в таблицы

запрос:

| Поле        | Тип      | Описание                    | Значение                   |
| ----------- | -------- | --------------------------- | -------------------------- |
| login       | text     | Логин                       | До 256 букв                |
| email       | text     | Электронный адрес           | До 24 символов             |
| status      | text     | Статус                      | 0 или 1                    |
| surname     | text     | Фамилия                     | До 24 букв                 |
| name        | text     | Имя                         | До 24 букв                 |
| patronymic  | text     | Отчество                    | До 24 букв                 |
| phone       | text     | Телефонный номер            | До 18 символов             |
| password    | text     | Пароль                      | До 32 символов             |
| upload      | file     | Загружаемый файл            | Файл, обязателен           |
| description | textarea | Описание загружаемого файла | До 256 букв, цифр и знаков |

ответ:

```
{
  "id": 1,
  "mime": "",
  "url": "",
  "status": "ok"
}

{
  "status": "fail",
  "message":"причина ошибки"
}
```

2. Method POST `/save/` - Сохранить файл и записи о пользователе

запрос:

| Поле        | Тип      | Описание                    | Значение                   |
| ----------- | -------- | --------------------------- | -------------------------- |
| id          | text     | Id загруженного файла       | До 9 цифр, обязательно     |
| login       | text     | Логин                       | До 256 букв                |
| email       | text     | Емэйл                       | До 24 символов             |
| status      | text     | Статус                      | 0 или 1                    |
| surname     | text     | Фамилия                     | До 24 букв                 |
| name        | text     | Имя                         | До 24 букв                 |
| patronymic  | text     | Отчество                    | До 24 букв                 |
| phone       | text     | Телефонный номер            | До 18 символов             |
| password    | text     | Пароль                      | До 32 символов             |
| newpassword | text     | Новый пароль                | До 32 символов             |
| upload      | file     | Загружаемый файл            | Файл, обязателен           |
| description | textarea | Описание загружаемого файла | До 256 букв, цифр и знаков |

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

3. Method POST `/delete/` - Удалить файл и запись о нём

запрос:

| Поле | Тип  | Описание              | Значение               |
| ---- | ---- | --------------------- | ---------------------- |
| id   | text | Id загруженного файла | До 9 цифр, обязательно |

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

4. Method POST `/activate/` - Поменять статус файла на 1

запрос:

| Поле | Тип  | Описание              | Значение               |
| ---- | ---- | --------------------- | ---------------------- |
| id   | text | Id загруженного файла | До 9 цифр, обязательно |

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

5. Method POST `/deactivate/` -  Поменять статус файла на 0

запрос:

| Поле | Тип  | Описание              | Значение               |
| ---- | ---- | --------------------- | ---------------------- |
| id   | text | Id загруженного файла | До 9 цифр, обязательно |

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

6. Method POST `/edit/` - Получить запись о файле по id

запрос:

| Поле | Тип  | Описание              | Значение  |
| ---- | ---- | --------------------- | --------- |
| id   | text | Id загруженного файла | До 9 цифр |

ответ:

```
{
  "data":
  {
    "login":           "login",
    "email":           "email",
    "status":          "status",
    "surname":         "surname",
    "name":            "name",
    "patronymic":      "patronymic",
    "phone":           "+7(921)1111111",
    "extension":        "svg",
    "filename":         "bMLryezYQWaEi2z22X4mwC8Gma1L0k7flVWCsMCrYAyzwgAa",
    "id":               22,
    "url":              "",
    "mime":             "",
    "size":             973,
    "real_filename":    "eye-slash-solid.svg",
  },
  "status":"ok"
}


{
  "status": "fail",
  "message":"причина ошибки"
}
```

7. Method POST `/index/` - Получить список записей

запрос:

| Поле | Тип  | Описание | Значение |
| ---- | ---- | -------- | -------- |
|      |      |          |          |

ответ:

```
{
  "data":
  {
    "login":           "login",
    "email":           "email",
    "status":          "status",
    "surname":         "surname",
    "name":            "name",
    "patronymic":      "patronymic",
    "phone":           "+7(921)1111111",
    "extension":        "svg",
    "filename":         "bMLryezYQWaEi2z22X4mwC8Gma1L0k7flVWCsMCrYAyzwgAa",
    "id":               1,
    "url": "",
    "mime":             "",
    "size":             973,
    "real_filename":    "eye-slash-solid.svg",
  },
    {
    "login":           "login",
    "email":           "email",
    "status":          "status",
    "surname":         "surname",
    "name":            "name",
    "patronymic":      "patronymic",
    "phone":           "+7(921)1111111",
    "extension":        "svg",
    "filename":         "bMLryezYQWaEi2z22X4mwC8Gma1L0k7flVWCsMCrYAyzwgAa",
    "id":               2,
    "url": "",
    "mime":             "",
    "size":             973,
    "real_filename":    "eye-slash-solid.svg",
  },
  "status":"ok"
}


{
  "status": "fail",
  "message":"причина ошибки"
}
```
