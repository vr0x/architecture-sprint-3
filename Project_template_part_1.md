«Тёплый дом» — это небольшая компания, которая организует удалённое управление отоплением в доме. Недавно она выиграла тендер и получила заказ на создание экосистемы умных посёлков на территории нескольких регионов страны. 


# Задание 1. Анализ и планирование

## Текущее решение
* Нынешнее приложение компании позволяет только управлять отоплением в доме и проверять температуру.
* Каждая установка сопровождается выездом специалиста по подключению системы отопления в доме к текущей версии системы.
* Архитектура приложения представляет из себя монолит на Java с СУБД Postgres. Всё синхронно. Никаких асинхронных вызовов, микросервисов и реактивного взаимодействия в системе нет. Всё управление идёт от сервера к датчику. Данные о температуре также получаются через запрос от сервера к дат+чику.
* Самостоятельно подключить свой датчик к системе пользователь не может.
## Целевая экосистема, которую необходимо создать
* Экосистема доступна пользователю в режиме самообслуживания по модели SaaS.
* Система позволяет управлять отоплением, включать и выключать свет, запирать и отпирать автоматические ворота, удалённо наблюдать за домом. Также в будущем могут появиться запросы на добавление новой * функциональности. Решение должно быть легко расширяемым.
* Пользователь самостоятельно выбирает необходимые ему модули умного дома (устройства), сам их подключает, настраивает сценарии работы и просматривает телеметрию.
* Компания не занимается производством устройств, но поддерживает подключение к экосистеме устройств партнёров по стандартным протоколам.
* Веб-разработка передана на аутсорс и не входит в требования данной работы.

### 1. Описание функциональности монолитного приложения

**Управление отоплением:**

- Пользователи могут удалённо включать/выключать отопление в своих домах.
- Система позволяет сохранять состояние отопительных приборов, целевые и текущие показатели температуры, управлять состоянием приборов.

**Мониторинг температуры:**

- Пользователи могут получать данные о температуре в своих домах.
- Система позволяет получать и сохранять данные о текущих значениях температуры и времени в каждом датчике.  


### 2. Анализ архитектуры монолитного приложения

- Язык программирования: Java
- База данных: PostgreSQL
- Архитектура: Монолитная, все компоненты системы (обработка запросов, бизнес-логика, работа с данными) находятся в рамках одного приложения.
- Взаимодействие: Синхронное, запросы обрабатываются последовательно.
-  Масштабируемость: Ограничена, так как монолит сложно масштабировать по частям.
-  Развёртывание: Требует остановки всего приложения.

### 3. Определение доменов и границы контекстов

В данной реализации домен один - 'Управление устройствами', выделены два поддомена 
- Управление оборудованием
- Мониторинг температуры

### **4. Проблемы монолитного решения**

- Ограниченная мастшабируемость
- Сложности в расширении функционала
- Зависимость развертывания от изменений в частяи приложения

Разбитие на микросервисы актуальна.

### 5. Визуализация контекста системы — диаграмма С4

Диаграмму контекста в модели C4 AsIs реализована c помощью плагина PlantUml. В репозитории находится в папке diarams:

\architecture-sprint-3\smart-home-monolith\diagrams\context\smart-home_Context.puml

[Диаграмма контекста С4](https://www.plantuml.com/plantuml/uml/bLD1Inj15BxFhvZcb88rbvuysSQ2XLh4jEUmIOOui3EppCvIfGZQ73oaL2WUIqkRFn1jWslKpLzuyu_wdgEkaZNWXf2PR_Pzt_U-ULbDNMHTfcBcf8i5RodSydMZ16yQxSIEusiowjj8yLVfsvGnPnBk3EyOvupYFMb5rqcZ6NicTJVEUYApCTzsBabN6WqRVLhkIxUTTR9Ks2uHQhVSDQgn9RkHxPdtKYGYRZHVljYC8-q-Rhnhg2XrmYBKRXgL64qL2HbacyAcHjU9QedNu1SKSE6_mXd-diBOVu49xMiBphW_WDmVq1Ok_V2kMwIiFMUCEewa5hRzscIw5zdT-lKR54Th5sqfulvTKi2u30mPFZEEJmKBGTR4QqRX0N4SGu7L4xXQuNu0CxyFO_HvGGZaC46G910ku9nMr0GMv46ZV8Ah-hg8N2lhbFpK_p_yB5Q10faBc9KGN59yy1sc6DStVtYBBt4uzSCAT8hrLy5f23ZaCeC9gU71mE_x8OPRuNh3QEcCbRg_s3ly8178oIoovhZ--vWG4JpXzU1hZ-snuAdzPiTTfuccoXiVpL_6N7R-YBHXLCRiZqWIYlj1vxUJY2NX04x8fHzGmqGSaaLZzmnz42eHDdAP5IsXKsD9wGyHaG9CoDoTWsEWzWwHPGhvutspBH7V_9KgPdnKCItXIkYBvLJzSEeUfeOKJnZhgZI3HjMCpCTHWvzmGcgK9Z9DwO9cKD02pcv2FLyGnghGlKp5_m40)



# Задание 2. Проектирование микросервисной архитектуры

Разработаны диаграммы в модели C4: диаграмма контейнеров, диаграмма компонентов, диаграмма кода одного из ToBe сервисов - сервисв управления отоплением.

**Диаграмма контейнеров (Containers)**

Диграмма контейнеров разработана с учетом выделенных доменов мо методике DDD с учетом ToBe сервисов. Применен паттерн Database per Service.

[Диаграмма контейнеров С4](https://www.plantuml.com/plantuml/uml/d5PHJ-is57xFh_3w11BGbptnj0qceGqcHc5xH6xhjH5973ak6vecqQ89iKv3GtkSDZ6qzz9BBgNGy1ViVtIFJvewA6tfHLLbdsEVxtpdox6Jpo99XMpvdYDTwJ5IyS4aMzndP8C7ahe14sJJfGr1VSUHF2IIaogNalkaxWfMaouF7ESJDwXvhJfh2OyqfGoZzN9Pq1_N6gvijggjY8aQeB50hjMuNzvpQrJK-JSk2vbNtlXqTTUZWJpOsIxxD99CWEjmW_iX3qn4QDWvkqn4F5WoK2kafFvLYNhKlwjx6FkgfpigDdPfpXhHRJNGRJIVT7TIAa2MbftA2MJsbz1foazjWBEA673OwKo4EVo2ju8w5IVpmvR9pmwnSYvzpwgVXo7iWGc1cGTo61aD_bVqcAwGIYZSe875N07RsrNrh4_LG3r2HU_1CO9v35Jog5_J7uueHEomAA8DHgg27p5XC705mVu4b4GDLQnFZHe9_6xrnHZm0G0HiL3T5gCI-032U5PQDXNbzkAM2XF7ResPHDScXUeRlTU9ka7wFR0VC_949Re3wP-jIpsD2nx2q_f3dsV-5QBwkZl5EuJuaUvWJVXyySa2P6oomSAPFjLTgAf8TPDAMgKHioMHp6L8xF98DWIhVBkDbFv7zgCqjRuawWxDaUxgNsqXWwpHieNqcTsg11dsaSWlCoJUPnxpcHGda6yodoxp3WzSoKs359N-sqY2J1AJ7ERlPia2mOjlBwXe2LifBV65nLJn2p6d9i_al4F7EGGDNvLpatCHGJOSYpAYUrQxwhDfxTf7YSopxW710PRo3rX3emwCQKlUmwhrvCEGRe53JZoqtooSJJHNbsstqPG0XcDH5tH_d2w9ReCZrXV5OxpOGROGdOMEK95mJaIqtofYeHXzELVCxzmwum2AOr5CTCyIquoGEyO3s8CAGHEqaPQXQdVejluDng7g4RomqS1Bfq-AqIdf8fESIcY_LQMvrArY3lpJb-7Xbp_9x1KoUJsg6zqUNzqFPWQWlS8x0T1mg-qxVMaQ3FR4K-_TyKBQCD2lT-aNGFQ-p1FQPtx819Kjg9e54HScqty623F4I2vZy5VkwXaKkp8FZEVQbdbbhutqsyI6wkw2LqqUFkruYt-Tdfn5iISdBL5FBt6n9tAyvxKdn69k-pcbUg-tXRF7lF7ts-GBw21Y4P5DHYBC3Bi-j5a6EGY4G13y2l4bFaPlwit_6yLAfchtk5CD3LcOvYi2xoVDvL_zVOsnJ3cV7b3692z35GDXQeLXlja3TZtQGf7U8IXKN5FF_DrJB4gLqx8wafN1M2OlPHYcL9E6AgBkA-4Zap1rVMce8f99VbrCojGqfQ6AI2OwmBwiETtpni4MS7GHu4dBGjwfrMttkgxtr-tzV7m0)

**Диаграмма компонентов (Components)**

Диаграмма компонентов детализирует контейнеры с реализацией API Gateway и Kafka.

[Диаграмма компонентов С4](https://www.plantuml.com/plantuml/uml/V4zDImCn4BtdLumzjL2x5q-Ur8fug58inMF9xavt1p8p8PaWYt_Uh8LwCvTvxy7xo4CsdwnmS4OM40vSARmg8soLemgAmJFv8NbspZI2ARHgfWmz9UoCL9ox8Ub2wR6a0ADPpFTDa_pNPY0RIriofax5K6pJAJSVrFdKwpjXnD1ixsxtmOiTttOD-soOgdIwjc_YlCxjCMMLvHorXiMndaMzZp0Be6Um4U5C9fWpr2ajv2aRycBb3hzW-KAsepDUMBN-_NGEkiZ0Nln0CW0ZjxLnf9ZNaBiH-nAmGYyzH3ynYkMQxROgvaamdPwqIE_Jz5_H2huTr7TrBJ-n_Ucy2dQRY87elLzXvGHI-G5E55MYXLOg177VDYQicdQZx5B4eLBJ2bMbY0hE20aXxaaW45Ao_GNxZnW_ksiNht4R9BIU6R_nyxonuovrknqgY2eapIO7SpoAsyDaBrbapMwFY2bRV1HZCRmZBkI1c8XpKOgVv9ZHUDouJGleVrQ_MqiRgm-IWhzANXDQ6maPAXVjmP-lIL5K3vnv-__GVvGytquel4vbJzgSRVQoRQqC8c3xWMYMOYh6ye39FWrBCPGdXl5lIgnp-eLSuKb1MwOSPkJipix7j2RlxQLRN2ttHIqaHc8Y-tUP-8eg3SW-lwmH4wKy918NrYN-cBfEnRbyBuyl_OjCZEHfZNTA-9ayL3kZs3j62Ic9kC3Q0meSoGDvMl7rAcmsjDHDQLrhk8g4C7Qhni6CHu7llynJ785ErawtWgcMkGAigsR7ST8sCuw6zUG5zGtRCNwRRZ-Wmp9rrcQIk-oC2_GsihneztZpyHhg_GtIp7HTvHaJFs3EvAbyOrMQeBXKPHCmVJyK9Se_gbepr4TFUOVlyAAdkhyQXtjfFTjDYqmTDh-TFYdTmQXK96ZyFQGzWUFJuwrYsUjcgKmMwvSctyqpfQuUD1nDMgG9ovKx8gfTtL6sybrRMp6-gcrT3NG8yyXnJA3fjTHTph9UJYlYMwygGg4hGXxLNH4ZtLr4T4149zZIPxAcIYpwwclW5qMjnuM5zGGPhIM6CHqrm9vLcDMHh1ojb7PttQCAYACexBdLjBkEYhMMjbyKb13VUh4GkfbOfUoJOonF_FiySgDxAGxZrqrGMJ3Noc8OLNPjbMPPPG5obTME5h-1ie0uoiAULrclil8igl2pjCKpIenllS88XHHMN-8mniqv44Cb56pGKvJj3DcNR-ax5GE6HmKC_6gCc8-MPs7fG4bBXs5CEWrOoNBRgGQeVEulikirpyZ_9xNz0DF8RqzyA11f362Sne0zTsC4LFAQP87-F-4Tysotxr3zXC_Lgzq-rDL4Tuf-N3PCH5jNSzI0pDiLCRssVLxLftJVBGWXPdzsFLproseeLHXjLqW_AUxP8154VH2ES124g0-o3Mr13WhXgwY5UtotHNzg_GK0)

**Диаграмма кода (Code)**

Диаграмма кода детализирует компоненты микросервиса управления теплом Heating, в ней представлены основные классы компонентов, прописаны ассоциативные связи.

[Диаграмма кода С4 Heating](https://www.plantuml.com/plantuml/uml/rP4_3zCm4CLtVufZ0rLj5YO6L9GE38KY2ZEwsDVKaksBpkUW2lMxuwW5-YT8h6psU-_atpkliw9eYS6erq3mdb1zwc5FCdfBqB8Zs7Zi1QCnoWCeGyUg7C5v8QkUap4lVBAXE2eIuAWwv3TD8_XzrNizbgva4ij9AUdAScm-UulY-AEdWKBJlbv-2fZqwuTj4p4hIPM-jHm7JjF4CD4POmFc_8jlVwgv23yCBBPSSRshfuuv42RmUPVgrN7f0e6YzAHVA0uag4NeZsMB2AKxxppxK5lXXKCWcPw4nJr5Jtedl7prd2c3GwMPsCZUWHP9k_Ge70utIguT7fjSxCsbJBNQfpurSPxVtVM3Btqsg0GJu7JPgzGKe5K_UZtz9a3dtbsr6owXo2FT6l_VUlxsrylbszcb_Vk0cHkVYPar9LTY-0a0)

# Задание 3. Разработка ER-диаграммы

ER-диаграмма отражает ключевые сущности системы, их атрибуты и тип связей между ними.
Выделены слудующие сущности:

* User - пользователь системы
* House - дом с установленным оборудованием
* System - система оборудования, с типом представленным в таблице 
SystemType, это может быть система отопления, открывания воротб, управление светом, видеонаблюдения.
* SystemType - тип системы оборудования с приборами из таблице DeviceType.
* DeviceType - nип устройства
* Телеметрия — TelemetryData.

[ER диаграмма](https://www.plantuml.com/plantuml/uml/XPBFYjim4CRlynHJ7nSIjz1JJWi9Iw6RKjhTSvXOqrYWFqOQxHAMVVTATeDSrz1B9Cqty_rc9hwFGa6IDI1Q3EE3baVzY_78zimXzdh08pcwi6KdkFUAyQ3f4iW2Y1zGF9wzYBUeTE1Ej7S07xJhJ5ASWi5UP8YxjWtqkhrewTCvHGwTTv8DjvstxG_TKL3-c-Q1JRl_lFbkoCdpyR6r58L33ftstWxUbOgXz0gGhrgks3ndimRV0F4EY_59AzoXIwNx7DniHgNtMPkaXwzLTMHvXoyKkfxAcorfW_F8G36--g1cmVSA_r9icpUeWChEvBMEIAd0CSxiwZ0_htbS-sUOE3vMngcQN0TUJ5Gx-JiUXIHbwjbxm-JWVG5zAbOJU1sf-4Lt_2-o6Xt6ZFyQ2HksBE5wKYIqQ5yeN5X6vLQ9ymqztOepOGKnCV9gJU9vEFlbzo7_ZcPGFXfiFZKv7vkFs-rTW-DVYJ0T2srQ4Kp7JIj7tHtKwwAuhWNgTPxJrAdWdfrArlm6)

Связи:
* User - House (пользователь — дом): один ко многим, один пользователь может иметь доступ к нескольким домам, но каждый дом связан только с одним пользователем.
* House - System (дом — система): один ко многим, один дом может содержать несколько систем, и каждая система принадлежит только одному дому.
* System - SystemType (система - тип системы): один к одному, система представлена своим типом
* SystemType - DeviceType (тип системы - тип прибороа), один ко многим, система может иметь приборы разного типа
* DeviceType  — Telemetry (тип прибора - Телеметрия): один ко многим, одно устройство может генерировать множество записей телеметрии.

