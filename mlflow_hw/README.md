### Домашнее задание по теме MLFlow

Для выполнения задания будут сделаны следующие шаги:

- создать 2 виртуальные машины для разворачивания MLflow и модели, упакованной в контейнер соответственно. [Манифест](/terraform/main.tf) Terraform для создания двух виртуалок.

- при помощи плейбуков ansible развернуть MlFlow и модель в контейнере

[Плейбук деплоя MLflow](/ansible/mlflow_deploy.yml), который сначала устанавливает и запускает Postgres, а затем запускает MLFlow с Postgres в качестве хранилища. Для того, чтобы MLflow работала как сервис, копируется файл [mlflow.service](/ansible/mlflow.service) в директорию `/lib/systemd/system/`

В качестве модели я взял файлы, прикрепленные к занятию в ЛК. Эта модель упакована в докер и обёрнута во Flask приложение. [Плейбук деплоя модели](/ansible/model_deploy.yml) сначала устанавливает и запускает доккер, затем копирует [папку](/ansible/model/) с моделью, и запускает docker-compose файл. 

К сожалению, в данный момент я имею доступ только к Гитхаб и Яндекс Облако и не смог разобраться, как настроить pipeline деплоя модели, так как нашёл только инструкцию по деплоя в AWS. 

Ниже приведены скриншоты поэтапного выполнения домашней работы.

![](pics/Screen%20Shot%202022-08-10%20at%208.28.38%20pm.png)
![](pics/Screen%20Shot%202022-08-10%20at%208.34.19%20pm.png)
![](pics/Screen%20Shot%202022-08-10%20at%208.35.14%20pm.png)
![](pics/Screen%20Shot%202022-08-10%20at%208.41.23%20pm.png)
![](pics/Screen%20Shot%202022-08-10%20at%208.41.59%20pm.png)
![](pics/Screen%20Shot%202022-08-10%20at%208.42.13%20pm.png)
