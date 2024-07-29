library(magrittr)
library(telegram.bot)
library(httr2)
library(stringr)
library(tidyr)
library(jsonlite)

NOTION_TOKEN <- Sys.getenv("R_NITION_API_TOKEN_my_life")
DATABASE_ID <- "62b6ef37c6054cc0bb33cd5375b8efe8"
base_url <- "https://api.notion.com/v1/"

## 1.1: Создаем путь ----
base_request <- request(base_url) %>%
  req_headers("Notion-Version" = "2022-06-28", "Authorization" = NOTION_TOKEN)

## 1.2 Создаем фильтр ----
tm <- as.POSIXlt(Sys.time() - (60 * 60 * 24), "UTC") # Время вчерашнего дня
tag_json <- list(filter = list(property = "Dfqq", date = list(after = strftime(tm , "%Y-%m-%dT%H:%M:%S"))))

# 1.3 Делаем запрос с фильтром ----
notion_one <- base_request %>%
  req_url_path_append("databases") %>%
  req_url_path_append(DATABASE_ID) %>%
  req_url_path_append("query") %>%
  req_body_json(tag_json) %>%
  req_method("POST") %>% # меняем метод запроса
  req_perform() %>%
  resp_body_json()

View(notion_one)


length(notion_one$results)

unnest_auto(notion_one)

notion_one %>% View()

# создаём экземпляр бота
bot <- Bot(token = Sys.getenv("R_TELEGRAM_BOT_my_life"))

# Запрашиваем информацию о боте
print(bot$getMe())
?Bot
# Получаем обновления бота, т.е. список отправленных ему сообщений
updates <- bot$getUpdates()

# Запрашиваем идентификатор чата
# Примечание: перед запросом обновлений вы должны отправить боту сообщение
chat_id <- updates[[1L]]$from_chat_id()

user_name <- paste0(
  updates[[1L]]$message$from$first_name,
  " ",
  updates[[1L]]$message$from$last_name
)
# Отправка сообщения
bot$sendMessage(chat_id,
  text = paste0("Привет *", user_name, "*. _А это курсив_"),
  parse_mode = "Markdown"
)

tg_table <- to_tg_table(ToothGrowth[1:20, ])
bot$sendMessage(
  chat_id,
  tg_table,
  "Markdown"
)
