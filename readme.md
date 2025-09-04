# Создание топиков Apache Kafka через Terraform

## Общая информация

Инфраструктура UZUM разворачивается и обновляется через изменения в коде. Код находится в репозитории: [https://github.com/DayMarket/infra-live](https://github.com/DayMarket/infra-live)

## Расположение конфигурации топиков

Чтобы найти конфигурацию топиков Kafka, необходимо пройти по пути:
`environments → [окружение] → kafka → topics → [кластер] → terragrunt.hcl`

## Пример конфигурации

Пример файла конфигурации топиков для common kafka cluster на dev окружении:

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
# Создание топика
Чтобы создать новый топик надо добавить в конец topic_list новую строку

```hcl
topic_name = local.topic_configs["<название конфигурации>"]
```
Подумай какой конфиг нужен для твоего топика и укажи название конфигурации. Если из сущесвтующих конфигураций ничего не подоходит, то опиши свою и укажи ее.

Если сомневаешься то можешь использовать конфигурацию "default"

Тегнуть апруверов можно в слак канале #dx-team-infra-notifications-market 


