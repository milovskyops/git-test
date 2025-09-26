**Создание S3 bucket**

Для создания новых бакетов мы используем только модуль v3. 

Также присутствует модуль без номера (называем его v1) и v2.

Версию три стоит использовать из соображений внутренней безопасности, если интересны подробности – можно почитать вот тут: Перенос бакетов v2 на v3

Как понять какая версия у уже созданного бакета – смотрим на строчку:


```hcl
terraform {
  source = "git::git@github.com:DayMarket/infra-modules.git//modules/s3/yandex-v2?ref=v1.1.1"
}
```
Собственно если yandex-v2 или просто yandex → это v2 и v1 соответственно.

Если yandex-v3 → очевидно что v3.


**Как создать бакет**


Пример созданного бакета: https://github.com/DayMarket/infra-live/blob/master/environments/prod/s3/yandex/um-prod-recsys-models/terragrunt.hcl 

Обращаю внимание на блок:


```hcl
dependency "ml-recsys-sa" {
  config_path = "../../../sa/data/ml-recsys-sa"
  mock_outputs = {
    service_account_id = "mock_account_id"
  }
  mock_outputs_merge_strategy_with_state = "deep_map_only"
}
```

Который потом используется вот тут:


```hcl
  admin_users = [
    "ajeve12vlvr3glt7fvf4", #Nariman Daniyar
    dependency.ml-recsys-sa.outputs.service_account_id
  ]
  ```
  
Доступные опции для разграничения прав пользователей: admin_users, write_with_delete_users, write_without_delete_users, view_users.

Блок dependency позволяет получить ресурс (в данном случае id сервис-аккаунта) из другой части terragrunt кода.

Если мы перейдем по относительному пути, то как раз это заметим.

Предлагаю запомнить этот момент, тк он понадобится в блоке.
