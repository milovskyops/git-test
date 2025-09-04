
*Сейчас мы используем два типа кластеров кафки:*

Первый - исторически сложившийся - кластер кафки в яндекс-облаке, в котором кластер используется для различных целей различными командами. Топики создаются через TF, что может быть неудобно для сервисов типа дебезиума, который должен создавать топики сам.

Второй – кафка в k8s. Тут уже кластера создаются под конкретные задачи, например, только под дебезиум-коннекторы и для команд/сервисов их использующих. 


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
Если вы перейдете в конфигурационный файл, то можете заметить, что используются только два уровня доступа: 

ACCESS_ROLE_CONSUMER = read only 

ACCESS_ROLE_PRODUCER = read write 

</details>

</details>

<details>
<summary><b>K8S</b></summary>


<details>
<summary><i>Создание топиков</i></summary>

В данном случае топики создаются через репозиторий   [infra-argocd](https://github.com/DayMarket/infra-argocd)

Чтобы найти конфигурацию топиков Kafka, необходимо пройти по пути:
` [окружение] → kafka → data-apps(dev/prod) или infra-apps(stage) → strimzi-operator → kafka-topics.yaml`

Пример из Stage:
https://github.com/DayMarket/infra-argocd/blob/master/stage/infra-apps/strimzi/kafka-topics.yaml

```hcl
apiVersion: kafka.strimzi.io/v1beta2
kind: KafkaTopic
metadata:
  name: search.fast-categories-ranking-updates.v1
  namespace: svc-data-kafka-connect
  labels:
    strimzi.io/cluster: stage-kafka-cluster
spec:
  topicName: search.fast_categories_ranking_updates.v1
  partitions: 3
  replicas: 3
  config:
    min.insync.replicas: 1
    retention.bytes: 1073741824
    retention.ms: 172800001
    segment.bytes: 314572800
    flush.messages: 1000
    flush.ms: 1800000
    file.delete.delay.ms: 0
    cleanup.policy: delete
    compression.type: lz4
---
apiVersion: kafka.strimzi.io/v1beta2
kind: KafkaTopic
metadata:
  name: discovery.sku.filters.updates
  namespace: svc-data-kafka-connect
  labels:
    strimzi.io/cluster: stage-kafka-cluster
spec:
  topicName: discovery.sku.filters.updates
  partitions: 3
  replicas: 3
  config:
    min.insync.replicas: 1
    retention.bytes: 1073741824
    retention.ms: 172800001
    segment.bytes: 314572800
    flush.messages: 1000
    flush.ms: 1800000
    file.delete.delay.ms: 0
    cleanup.policy: delete
    compression.type: lz4
```
</details>

<details>
<summary><i>Вложенный заголовок</i></summary>

Пользователей мы создаем через репозиторий [infra-helm](https://github.com/DayMarket/infra-helm)

Найти конфигурационный файл можно по пути: 

`charts → kafka-users → окружение.values.yaml`

Пример конфигурационного файла из stage окружения: 

https://github.com/DayMarket/infra-helm/blob/master/charts/kafka-users/dev.values.yaml

```hcl

users:
  user1:
    passwordKey: example_user_1_password
    acls:
      - host: "*"
        resource:
          type: topic
          name: "topic-example-wildcard-"
          patternType: prefix
        operations:
          - All
      - host: "*"
        resource:
          type: topic
          name: "topic_example"
          patternType: prefix
        operations:
          - All
      - host: "*"
        resource:
          type: group
          name: "*"
          patternType: literal
        operations:
          - All
  user2:
    passwordKey: example_user_2_password
    acls:
      - host: "*"
        resource:
          type: topic
          name: "user2-topic"
          patternType: literal
        operations:
          - Read 
```
</details>

</details>


Если у вас нет доступа к репозиториям, то его можно получить через заявку в [JSM](https://jsm.uzum.com/servicedesk/customer/portal/5)

Если вы думаете, что  про ваш PR забыли, тегнуть апруверов можно в слак канале #dx-team-infra-notifications-market 






