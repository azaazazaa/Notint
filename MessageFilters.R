# ###########################################################
# message state filters

# фильтр сообщений в состоянии ожидания имени
MessageFilters$wait_category <- BaseFilter(function(message) {
  get_state( message$chat_id )  == "wait_category"
}
)

# фильтр сообщений в состоянии ожидания возраста
MessageFilters$wait_cost <- BaseFilter(function(message) {
  get_state( message$chat_id )   == "wait_cost"
}
)


# фильтр сообщений в состоянии ожидания возраста
MessageFilters$wait_comment <- BaseFilter(function(message) {
  get_state( message$chat_id )== "wait_comment"
}
)