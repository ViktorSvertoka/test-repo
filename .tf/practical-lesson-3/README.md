# Практичне заняття №3

**Вітаю на третьому і останньому занятті!**

**Наближаємось до фіналу!**

VPC, EC2-інстанси, секʼюріті-групи, RDS ми вже створювали на минулих заняттях, тому не будемо витрачати на них час, вони будуть створені на ваших очах за допомогою [terraform](https://www.terraform.io/).

**Сьогодні розглядаємо**:

- Роботу з S3 (Тема 7. Зберігання та кешування даних в AWS)
- Розширений моніторинг інстансів (Тема 8. Моніторинг та аналітика в AWS)
- Підготовку та деплой застосунку на Elastic Beanstalk (Тема 9. Розгортання та DevOps)
- Фінальний проєкт

> [!IMPORTANT]
> Всі ключі, паролі, посилання, тощо будуть недійсні вже по закінченню заняття!

## Завдання

1. Створити бакет в S3 та завантажити архів з кодом застосунку для Elastic Beanstalk.

   - Створити S3-бакет з публічним доступом до файлів
   - Підготувати архів для деплою:
     - Клонувати git-репозиторій локально чи в CloudShell
     - Створити virtualenv, встановити залежності
     - Згенерувати статичні ресурси за допомогою `python manage.py collectstatic`
     - Створити архів (приклад для Linux та MacOS, з віндою не працюю принципово):
       ```bash
       zip -r ../django_app.zip . -x '.venv/*' '.git/*' '*__pycache__*'
       ```
       ⚠️ Зверніть увагу на те, що архів створюється на директорію вище ⚠️
   - Завантажити архів до S3
   - Поділитися посиланням в Slack

2. Для існуючого інстансу "NAT Instance" додати метрику по памʼяті.  

   - Створити IAM-роль для інстансу з потрібними дозволами:
     - `AmazonEC2RoleforSSM`
     - `AmazonSSMManagedInstanceCore`
     - `CloudWatchAgentServerPolicy`
   - Додати цю роль до інстансу
   - [Встановити SSM-агент](https://docs.aws.amazon.com/systems-manager/latest/userguide/agent-install-al2.html)
   - Встановити та налаштувати CloudWatch Agent за допомогою SSM
   - Знайти в CloudWatch потрібну метрику

3. Створити Beanstalk-застосунок
   - Створити застосунок в Elastic Beanstalk з наступними параметрами:
     - Configure environment
       - **Environment tier**: `Web server environment`
       - **Platform**: `Python`
       - **Platform branch**: `Python 3.13 running on 64bit Amazon Linux 2023`
     - Application code
       - **Upload your code**
       - **Public S3 URL**: посилання на архів з першого кроку
     - Configure service access
       - **Service role**: створити і використати
       - **EC2 instance profile**: створити і використати
       - **EC2 key pair**: обрати "django", сам ключ знайдете в Slack
     - Set up networking, database, and tags:
       - **Instance settings**:
         - **Public IP address**: `⬜ Activated`
         - **Instance subnets**: обираємо лише приватні підмережі (в нас є безкоштовний NAT Instance замість платного NAT gateway)
       - **Database**: ми вже маємо базу даних, не чіпаємо (доступи в Slack)
     - Configure instance traffic and scaling
       - **Instances**:
         - **EC2 security groups**: обираємо вже створену групу `django-application`
       - **Capacity**:
         - **Auto scaling group**:
           - **Environment type**: `Load balanced`
           - **Instance types**: обираємо лише безкоштовні `t2.micro` та `t3.micro`
         - **Scaling triggers** давайте налаштуємо на CPUUtilization > 70%
       - **Load balancer network settings**:
         - **Visibility**: `public`
           - **Load balancer subnets**: обираємо лише публічні підмережі
       - **Load Balancer Type**: `Application load balancer`
     - Configure updates, monitoring, and logging
       - **Platform software**:
         - **Environment properties**: створити всі необхідні змінні середовища по [README](https://github.com/GoIT-FCC/django_app/blob/main/README.md)
   - Створити адміністратора в застосунку, залогінитись та створити опитування
4. Намалювати схему створеного проєкту в [draw.io](https://draw.io)

## Самостійне відтворення чи повторення

> [!NOTE]
> [terraform](https://www.terraform.io/) не входить в рамки курсу Foundations of Cloud Computing!  
> Ментор не зобовʼязаний допомагати із проблемами, повʼязаними з його неналежним використанням!

### Створення підготовленої інфраструктури

Щоб потренуватися самостійно (чи ще раз) над завданнями, [встановіть terraform](https://developer.hashicorp.com/terraform/install), зклонуйте цей репозиторій і в ньому перейдіть в папку `.tf/practical-lesson-3`, ініціалізуйте terraform та застосуйте:

```bash
cd .tf/practical-lesson-3
terraform init
terraform apply
```

> [!WARNING]
> Без додаткових налаштувань terraform буде використовувати дані з дефолтного профілю!  
> https://registry.terraform.io/providers/hashicorp/aws/latest/docs?product_intent=terraform#authentication-and-configuration  
> Впевніться, що Ви використовуєте в дефолтному профілі саме свій аккаунт!

### Видалення підготовленої інфраструктури

**Лише після видалення всього, що створите по завданню**, видаліть створені за допомогою terraform ресурси командою

```bash
terraform destroy
```

> [!IMPORTANT]
> Якщо в VPC на момент виконання команди будуть існувати ресурси, про яких не знає terraform, скоріш за все дестрой зафейлиться
