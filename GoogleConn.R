# googlesheets4::gs4_auth()

gh_url <- "https://docs.google.com/spreadsheets/d/1PgV0B_Nndi4CUP_5foUv5QKrka0hgpRMe4ExNPBKO90/edit?gid=0#gid=0"


cost_data <- read_sheet(gh_url, range = "A:D", sheet = "Повседневные") %>% as.data.table()


# Функция обновления dt в локальной памяти

# Функции для записи затрат и обновления dt для удержания в локальной памяти

