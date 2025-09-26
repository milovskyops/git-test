
**Выдача прав для SA в бакете**

Модуль v1 и v2
Вы нашли в infra-live бакет с версией v1 или v2.

К примеру, вот ваш terragrunt файл:





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
  source = "git::git@github.com:DayMarket/infra-modules.git//modules/s3/yandex-v2?ref=v1.1.1"
}

dependency "mlgrowth-sa" {
  config_path = "../../../sa/data/mlgrowth"
  mock_outputs = {
    service_account_id = "mock_account_id"
  }
  mock_outputs_merge_strategy_with_state = "deep_map_only"
}

inputs = {
  yc_folder_id = local.env.folder_id
  bucket       = "mlgrowth"
  bucket_grants = [
    {
      type        = "CanonicalUser"
      permissions = ["READ", "WRITE"]
      id          = dependency.mlgrowth-sa.outputs.service_account_id
      uri         = null
    }
  ]
}
```
И мы хотим добавить прав SA созданному в соседней статье в «Create SA», нам требуется добавить два блока и по итогу наш terragrunt файл начнет выглядеть вот так::


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
  source = "git::git@github.com:DayMarket/infra-modules.git//modules/s3/yandex-v2?ref=v1.1.1"
}

dependency "mlgrowth-sa" {
  config_path = "../../../sa/data/mlgrowth"
  mock_outputs = {
    service_account_id = "mock_account_id"
  }
  mock_outputs_merge_strategy_with_state = "deep_map_only"
}

/// ДОБАВИЛИ ВОТ ТУТ БЛОК ДЛЯ ПОЛУЧЕНИЯ ID СЕРВИСНОГО АККАУНТА 
dependency "mlgrowth-sa-dev" {
  config_path = "../../../sa/data/mlgrowth-sa-dev"
  mock_outputs = {
    service_account_id = "mock_account_id"
  }
  mock_outputs_merge_strategy_with_state = "deep_map_only"
}

inputs = {
  yc_folder_id = local.env.folder_id
  bucket       = "mlgrowth"
  bucket_grants = [
    {
      type        = "CanonicalUser"
      permissions = ["READ", "WRITE"]
      id          = dependency.mlgrowth-sa.outputs.service_account_id
      uri         = null
    },
/// ДОБАВИЛИ ВОТ ТУТ БЛОК ДЛЯ ВЫДАЧИ RW ПРАВ, ЕСЛИ НУЖНО RO –> ОСТАВЛЯЕТЕ ТОЛЬКО READ
    {
      type        = "CanonicalUser"
      permissions = ["READ", "WRITE"]
      id          = dependency.mlgrowth-sa-dev.outputs.service_account_id
      uri         = null
    },
  ]
  ```
}

**V3**


Практически то же самое

Доступные опции для разграничения прав пользователей: admin_users, write_with_delete_users, write_without_delete_users, view_users.

Ваш terragrunt файл выглядел вот так:


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
  source = "git::git@github.com:DayMarket/infra-modules.git//modules/s3/yandex-v3?ref=v1.21.0"
}

dependency "dev-accounting-data-1c-rw" {
  config_path = "../../../sa/data/dev-accounting-data-1c-rw"
  mock_outputs = {
    service_account_id = "mock_account_id"
  }
  mock_outputs_merge_strategy_with_state = "deep_map_only"
}


inputs = {
  yc_folder_id = local.env.folder_id
  bucket       = "um-dev-accounting-data-1c"
  admin_users = [
    dependency.dev-accounting-data-1c-rw.outputs.service_account_id
  ],
}
```
Хотим добавить service account с view правами:


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
  source = "git::git@github.com:DayMarket/infra-modules.git//modules/s3/yandex-v3?ref=v1.21.0"
}

dependency "dev-accounting-data-1c-rw" {
  config_path = "../../../sa/data/dev-accounting-data-1c-rw"
  mock_outputs = {
    service_account_id = "mock_account_id"
  }
  mock_outputs_merge_strategy_with_state = "deep_map_only"
}

/// ДОБАВИЛИ DEPENDENCY ДЛЯ ПОЛУЧЕНИЯ ID SERVICE ACCOUNT
dependency "dev-accounting-data-1c-ro" {
  config_path = "../../../sa/data/dev-accounting-data-1c-ro"
  mock_outputs = {
    service_account_id = "mock_account_id"
  }
  mock_outputs_merge_strategy_with_state = "deep_map_only"
}

inputs = {
  yc_folder_id = local.env.folder_id
  bucket       = "um-dev-accounting-data-1c"
  admin_users = [
    dependency.dev-accounting-data-1c-rw.outputs.service_account_id
  ],
  view_users = [ /// ДОБАВИЛИ ЗДЕСЬ САМО НАЛИЧИЕ VIEW ПРАВ
    dependency.dev-accounting-data-1c-ro.outputs.service_account_id, /// ДОБАВИЛИ SA ПОЛУЧЕННЫЙ ИЗ DEPENDENCY
  ],

