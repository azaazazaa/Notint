# ###########################################################
# handlers

# command handlers
start_h <- CommandHandler('start', start)
state_h <- CommandHandler('state', state)
reset_h <- CommandHandler('reset', reset)

# message handlers
## !MessageFilters$command - означает что команды данные обработчики не обрабатывают, 
## только текстовые сообщения
wait_category_h  <- MessageHandler(enter_category,  MessageFilters$wait_category  & !MessageFilters$command)
wait_cost_h <- MessageHandler(enter_cost, MessageFilters$wait_cost & !MessageFilters$command)
wait_comment_h <- MessageHandler(enter_comment, MessageFilters$wait_comment & !MessageFilters$command)
