# Создание топиков в Apache Kafka через Terraform

## Общая информация
Инфраструктура UZUM реализована по принципу **Infrastructure as Code** и разворачивается через изменения в репозитории.

**Расположение кода:** https://github.com/DayMarket/infra-live

## Структура конфигурации топиков
Конфигурация топиков находится по пути:
environments → [окружение] → kafka → topics → [кластер] → terragrunt.hcl

text

## Пример конфигурации
```hcl
# environments/dev/kafka/topics/common/terragrunt.hcl

locals {
  topic_configs = {
    "default" = {
      partitions               = 1
      replication_factor       = 1
      config                   = {}
    }
    "wms-dev" = {
      partitions               = 3
      replication_factor       = 2
      config                   = {
        "retention.ms" = "604800000"
      }
    }
    "analytics-dev-1" = {
      partitions               = 6
      replication_factor       = 2
      config                   = {
        "retention.ms" = "2592000000"
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

## Процесс создания нового топика
1. Добавление конфигурации топика
Добавьте запись в конец блока topic_list:

hcl
"new_topic_name" = local.topic_configs["config_name"]
2. Выбор конфигурации
Доступные варианты:

"default" - базовая конфигурация

"wms-dev" - для WMS-сервисов

"analytics-dev-1" - для аналитических данных

## Создание кастомной конфигурации
Если стандартные конфигурации не подходят, добавьте новую в блок locals.topic_configs:

hcl
"custom-config" = {
  partitions         = 4
  replication_factor = 2
  config             = {
    "retention.ms" = "86400000"
    "cleanup.policy" = "delete"
  }
}
4. Создание Pull Request
Сделайте PR с изменениями в репозиторий https://github.com/DayMarket/infra-live
