
**Создание S3 и SA**

Для создания новых бакетов мы используем только модуль v3. 

Также присутствует модуль без номера (называем его v1) и v2.

Как понять какая версия у уже созданного бакета – смотрим на строчку:
``hcl
terraform {
  source = "git::git@github.com:DayMarket/infra-modules.git//modules/s3/yandex-v2?ref=v1.1.1"
}
``

Собственно если yandex-v2 или просто yandex → это v2 и v1 соответственно.

Если yandex-v3 → очевидно что v3.

**Как создать SA**

Тут крайне все просто.

Достаточно посмотреть на пример созданного SA: https://github.com/DayMarket/infra-live/blob/master/environments/dev/sa/data/mlgrowth-sa-dev/terragrunt.hcl

```hcl

locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals
}

include "state" {
  path = find_in_parent_folders()
}

include "yc" {
  path = find_in_parent_folders("yc.hcl")
}

terraform {
  source = "git::git@github.com:DayMarket/infra-modules.git//modules/sa?ref=v1.24.4"
}

inputs = {
  name             = "mlgrowth-sa-dev"
  description      = "mlgrowth-sa-dev SA in dev env"
  key_description  = "Key mlgrowth-sa-dev sa in dev env"
  roles            = []
  keep_static_keys = true
}
```




*Стоит запомнить относительный путь и название директорий, они понадобятся дальше.*

**Как создать бакет**
Пример созданного бакета: https://github.com/DayMarket/infra-live/blob/master/environments/prod/s3/yandex/um-prod-recsys-models/terragrunt.hcl 

Обращаю внимание на блок:


``hcl
dependency "ml-recsys-sa" {
  config_path = "../../../sa/data/ml-recsys-sa"
  mock_outputs = {
    service_account_id = "mock_account_id"
  }
  mock_outputs_merge_strategy_with_state = "deep_map_only"
}
``
Который потом используется вот тут:


``hcl
  admin_users = [
    "ajeve12vlvr3glt7fvf4", #Nariman Daniyar
    dependency.ml-recsys-sa.outputs.service_account_id
  ]
  ``
Доступные опции для разграничения прав пользователей: admin_users, write_with_delete_users, write_without_delete_users, view_users.

Блок dependency позволяет получить ресурс (в данном случае id сервис-аккаунта) из другой части terragrunt кода.





