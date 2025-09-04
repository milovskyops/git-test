<details>
<summary><b>Terraform</b></summary>

Для YC кластеров кафки, пользователи и топики создаются в репозитории [infra-live](https://github.com/DayMarket/infra-live)

<details>
<summary><i>Создание топиков</i></summary>

Чтобы найти конфигурацию топиков Kafka, необходимо пройти по пути:
`environments → [окружение] → kafka → topics → [кластер] → terragrunt.hcl`


Пример файла конфигурации топиков для common kafka cluster на dev окружении:
https://github.com/DayMarket/infra-live/blob/master/environments/dev/kafka/topics/common/terragrunt.hcl

```hcl
# environments/dev/kafka/topics/common/terragrunt.hcl

locals {
  # Конфигурации топиков
  topic_configs = {
    "wms-dev" = {
      partitions               = 3
      replication_factor       = 2
      config                   = {
        "cleanup.policy"      = "delete"
        "retention.ms"        = "604800000" # 7 дней
        "min.insync.replicas" = "1"
      }
    },
    "analytics-dev-1" = {
      partitions               = 6
      replication_factor       = 2
      config                   = {
        "cleanup.policy"      = "delete"
        "retention.ms"        = "2592000000" # 30 дней
        "min.insync.replicas" = "1"
      }
    },
    "default" = {
      partitions               = 1
      replication_factor       = 2
      config                   = {
        "cleanup.policy"      = "delete"
        "retention.ms"        = "86400000" # 1 день
        "min.insync.replicas" = "1"
      }
    }
  }
}

inputs = {
  kafka_cluster_id = dependency.cluster_kafka_id.outputs.cluster_id
  
  ###_Create_Topic_###
  topic_list = {
    "accepted_invoice"         = local.topic_configs["wms-dev"],
    "accepted_shipping_box"    = local.topic_configs["wms-dev"],
    "analytics-buyers"         = local.topic_configs["analytics-dev-1"],
    "analytics-delayed_buyers" = local.topic_configs["analytics-dev-1"],
    "analytics-new_buyers"     = local.topic_configs["analytics-dev-1"],
    # ... остальные топики
  }
}
```


Создание своего топика

Чтобы создать новый топик надо добавить в конец topic_list новую строку

```hcl
topic_name = local.topic_configs["<название конфигурации>"]
```
Подумай какой конфиг нужен для твоего топика и укажи название конфигурации. Если из сущесвтующих конфигураций ничего не подоходит, то опиши свою и укажи ее.

Если сомневаешься то можешь использовать конфигурацию "default"
</details>

<details>
<summary><i>Создание пользователей</i></summary>

Чтобы найти конфигурацию пользователей, необходимо пройти по пути:
`environments → [окружение] → kafka → users → [кластер] → terragrunt.hcl`


Пример файла конфигурации пользователей для common kafka cluster на dev окружении:

https://github.com/DayMarket/infra-live/blob/master/environments/dev/kafka/users/common/terragrunt.hcl

```hcl
######_kafka_users_creation_#####
  users = [
    {
      name = "admin"
      topics = {
        "*" = ["ACCESS_ROLE_CONSUMER", "ACCESS_ROLE_PRODUCER"]
      }
    },
    {
      name = "ecom-platform"
      topics = {
        "translate.v1"        = ["ACCESS_ROLE_CONSUMER", "ACCESS_ROLE_PRODUCER"],
        "translate_result.v1" = ["ACCESS_ROLE_CONSUMER"],
      }
    },
# ... остальные  пользователи
```

Создание своего пользователя и добавление прав

```hcl
    {
      name = "название-юзера"
      topics = {
        "Название топика к которому нужны права"   = ["уроверь доступа",]
 
      }
    },
```
Если вы перейдете в конфигурационный файл, то можете заметить, что используются только уровня доступа: 

ACCESS_ROLE_CONSUMER = read only 
ACCESS_ROLE_PRODUCER = read write 

</details>

</details>

