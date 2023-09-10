
// backup events
const event_backup_login = 'backup_login';

const event_backup_login_params_type_name = 'type';
enum event_backup_login_params_type { google, apple }

const event_backup_logout = 'backup_logout';

const event_backup_upload = 'backup_upload';
const event_backup_upload_params_action_name = 'action';
enum event_backup_upload_params_action { confirm, cancel }

const event_backup_download = 'backup_download';
const event_backup_download_params_action_name = 'action';
enum event_backup_download_params_action { confirm, cancel }

const event_backup_delete = 'backup_delete';
const event_backup_delete_params_action_name = 'action';
enum event_backup_delete_params_action { confirm, cancel }

const event_setting_country = 'setting_country';
const event_setting_country_params_country_code_name = 'country_code';
const event_setting_country_params_country_code_checked_name = 'checked';


// home events
const event_search = 'home_search';
const event_search_params_keyword_name = 'keyword';

const event_previous_month = 'home_previous_month';
const event_next_month = 'home_next_month';
const event_select_date = 'home_select_month';
const event_select_date_params_position_name = 'position';
enum event_select_date_params_position { home, edit, add }
const event_back_to_today = 'home_back_to_today';

const event_add_event = 'home_add_event';
const event_add_event_params_position_name = 'position';
enum event_add_event_params_position { menu, dialog }

const event_home_menu = 'home_menu_click';
const event_home_menu_params_feature_name = 'feature';
enum event_home_menu_params_feature { setting, add_event, my_event }

// my list events
const event_delete_my_event = 'my_event_delete';
const event_delete_my_event_params_count_name = 'count';
const event_edit_my_event = 'my_event_edit';
const event_edit_my_event_params_position_name = 'position';
enum event_edit_my_event_params_position { dialog, my_event, search }



