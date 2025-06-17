
# Функции для получения информации о затратах сегодня в разрезе катергорий
get_cost_day <- function(bot, update) {
  dt_inner <- cost_data %>% copy()
  dt_inner[, Дата := as.POSIXct(Дата)]
  
  # Имя пользователя с которым надо поздароваться
  user_name <- update$effective_user()$first_name
  
  table <- dt_inner[, Всего := sum(Стоимость), by = c("Категория", "Дата")] %>%
    .[Дата == as.POSIXct(Sys.Date()), c("Категория", "Всего")]
  
  
  
  bot$sendMessage(update$from_chat_id(),
                  text = to_tg_table(table),
                  parse_mode = "Markdown")
  
}


# Функция для получения информации о затратах за неделю в разрезе катергорий
get_cost_week <- function(bot, update) {
  dt_inner <- cost_data %>% copy()
  dt_inner[, Дата := as.POSIXct(Дата)]
  
  # Вычисляем начало текущей недели (по понедельникам)
  current_week_start <- as.POSIXct(floor_date(as.POSIXct(Sys.Date() - days(1)), unit="week") + days(1))
  current_week_end <- current_week_start + days(6)
  
  
  
  dt_inner <- dt_inner[Дата >= current_week_start & Дата <= current_week_end, ]
  dt_inner[, Всего := sum(Стоимость), by = c("Категория")]
  
  dt_inner <- dt_inner[, c("Категория", "Всего")] %>% unique()
  table <- rbindlist(list(dt_inner, data.table(Категория = c("Всего"), Всего = sum(dt_inner[, Всего]))), use.names = TRUE)
  
  bot$sendMessage(update$from_chat_id(),
                  text = to_tg_table(table),
                  parse_mode = "Markdown")
}

# Функция для получения информации о затратах за месяц в разрезе катергорий
# Функция для получения информации о затратах за неделю в разрезе катергорий
get_cost_month <- function(bot, update) {
  dt_inner <- cost_data %>% copy()
  dt_inner[, Дата := as.POSIXct(Дата)]
  
  # Вычисляем начало текущей недели (по понедельникам)
  current_month_start <- as.POSIXct(floor_date(as.POSIXct(Sys.Date()), unit="month"))
  current_month_end <- current_month_start + months(1) - days(1)
  
  
  
  
  
  dt_inner <- dt_inner[Дата >= current_month_start & Дата <= current_month_end, ]
  dt_inner[, Всего := sum(Стоимость), by = c("Категория")]
  
  dt_inner <- dt_inner[, c("Категория", "Всего")] %>% unique()
  table <- rbindlist(list(dt_inner, data.table(Категория = c("Всего"), Всего = sum(dt_inner[, Всего]))), use.names = TRUE)
  
  bot$sendMessage(update$from_chat_id(),
                  text = to_tg_table(table),
                  parse_mode = "Markdown")  
}

# start dialog
start <- function(bot, update) {
  # Send query
  bot$sendMessage(update$message$chat_id, 
                  text = "Введите категорию трат")
  
  categories[, Описание := fifelse(is.na(Описание), "", Описание)]
  bot$sendMessage(update$from_chat_id(),
                  text = to_tg_table(categories),
                  parse_mode = "Markdown")
  
  # переключаем состояние диалога в режим ожидания ввода имени
  set_state(chat_id = update$message$chat_id, state = 'wait_category')
  
}

# get current chat state
state <- function(bot, update) {
  
  chat_state <- get_state(update$message$chat_id)
  
  # Send state
  bot$sendMessage(update$message$chat_id, 
                  text = unlist(chat_state))
  
}

# reset dialog state
reset <- function(bot, update) {
  update_local_data()
  set_state(chat_id = update$message$chat_id, state = 'start')
  
}

enter_category <- function(bot, update) {
  category_env <<- as.character(update$message$text)

  # проверяем было введено число или нет
  if ( is.na(category_env) ) {

    # если введено не число то переспрашиваем возраст
    bot$sendMessage(update$message$chat_id, 
                    text = "Ты ввёл некорректные данные, введи строку")

  } else {

    # если введено число сообщаем что возраст принят
    bot$sendMessage(update$message$chat_id, 
                    text = "ОК, категория принята")

    # записываем глобальную переменную с возрастом
    
    bot$sendMessage(update$message$chat_id, 
                    text = "Введите сумму траты")

    # переводим диалог в следующее состояние
    set_state(chat_id = update$message$chat_id, state = 'wait_cost')
  }

}

  
enter_cost <- function(bot, update) {
  cost_env <<- as.numeric(update$message$text)
  
  # проверяем было введено число или нет
  if ( is.na(cost_env) ) {
    
    # если введено не число то переспрашиваем возраст
    bot$sendMessage(update$message$chat_id, 
                    text = "Ты ввёл некорректные данные, введи число")
    
  } else {
    
    # если введено число сообщаем что возраст принят
    bot$sendMessage(update$message$chat_id, 
                    text = "ОК, принято")
    
    bot$sendMessage(update$message$chat_id, 
                    text = "Оставьте комментарий")
    
    # переводим диалог в следующее состояние
    set_state(chat_id = update$message$chat_id, state = 'wait_comment')
  }
  
}

enter_comment <- function(bot, update) {
  comment_env <<- as.character(update$message$text)
  if(is.na(comment_env)) {
    comment_env <<- ""
  }
  
  dt_inner <- cost_data %>% copy()
  
  today <- as.POSIXct(Sys.Date())
  
  table <- rbindlist(list(dt_inner,
                          data.table(Дата = today, Категория = category_env, Стоимость = cost_env, Комментарий = comment_env)), use.names = TRUE, fill=TRUE)
  table[, Комментарий := fifelse(is.na(Комментарий), "", Комментарий)]
  
  
  gh_url <- "https://docs.google.com/spreadsheets/d/1PgV0B_Nndi4CUP_5foUv5QKrka0hgpRMe4ExNPBKO90/edit?gid=0#gid=0"
  
  googlesheets4::range_write(gh_url, table, sheet = "Повседневные")
  update_local_data()
  
  bot$sendMessage(update$message$chat_id,
                  text = "Данные обновлены",
                  parse_mode = "Markdown")
  # 
  set_state(123, "menu")
  
}
