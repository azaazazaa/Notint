get_state <- function(chat_id) {
  return(state_env)
}

set_state <- function(chat_id, state) {
  state_env <<- state
}
