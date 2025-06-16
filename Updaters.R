library(telegram.bot)
library(googlesheets4)
library(data.table)
library(lubridate)

state_env <- "asd"
source("envFunction.R")



# googlesheets4::gs4_auth()
source("GoogleConn.R")

# 
source("Functions.R")
source("GoogleFunctions.R")

# Для обработки диалога
source("Handlers.R")
source("MessageFilters.R")


# создаём экземпляр класса Updater
updater <- Updater(token = Sys.getenv("R_TELEGRAM_BOT_my_life"))


# Пишем метод для приветсвия
say_hello <- function(bot, update) {
  
  # Имя пользователя с которым надо поздароваться
  user_name <- update$effective_user()$first_name
  
  # Отправка приветственного сообщения
  bot$sendMessage(update$from_chat_id(),
                  text = paste0("Моё почтение, ", user_name, "!"),
                  parse_mode = "Markdown")
  
}

# создаём обработчик
day <- CommandHandler('day', get_cost_day)
week <- CommandHandler('week', get_cost_week)
month <- CommandHandler('month', get_cost_month)

# Регистрируем
updater <- updater + day + week + month

# Для диалога
updater <- updater + start_h + state_h + reset_h + wait_category_h + wait_cost_h + wait_comment_h


# запускаем бота
updater$start_polling()
