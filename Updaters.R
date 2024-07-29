library(telegram.bot)

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
hi_hendler <- CommandHandler('hi', say_hello)

# добаляем обработчик в диспетчер
updater <- updater + hi_hendler

# запускаем бота
updater$start_polling()

